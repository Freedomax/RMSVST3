unit UMyVstDSP;

interface

type
  TBaseOscillator = class(TObject)
  private
    FSampleRate: double;
    FSampleReci: double;
    FFrequency: double;
    procedure SetFrequency(const Value: double);
    procedure SetSampleRate(const Value: double);
  protected
    function ValueAt(FxPos: double): double; virtual; // FxPos: 0..1
  public
    constructor Create(const SampleRate: double); virtual;
    property Frequency: double read FFrequency write SetFrequency;
    property SampleRate: double read FSampleRate write SetSampleRate;
  end;

type
  TOscillatorBlep = class(TBaseOscillator)
  protected
    function ValueAt(FxPos: double): double; override; // FxPos: 0..1
  private
    function PolyBlep(t: double): double;
  end;

type
  TOscillator = class(TOscillatorBlep)
  private
    FXpos: single;
    FPulseWidth: double;
    function PulseWidthAdjusted(AFxPos: double): double;
    procedure SetPulseWidth(Value: double);
  protected
    function ValueAt(AFxPos: double): double; override;
  public
    property PulseWidth: double read FPulseWidth write SetPulseWidth;
    function Process: single;
    constructor Create(const ASampleRate: double); override;
  end;

type
  TMusicDspMoog = class
  private
    FCutoff, FResonance, FSampleRate: single;
    stage, delay: array[0..3] of single;
    p, k, t1, t2: single;
    procedure SetSampleRate(Value: single);
    procedure SetCutoff(cutoff: single; resonance: single); overload;
    procedure SetCutoff(cutoff: single); overload;
    procedure SetResonance(Value: single);
    procedure Reset;
  public
    property Cutoff: single write SetCutoff;      // 0..20000
    function Process(input: single): single;
    property Resonance: single write SetResonance; // 0..1
    property SampleRate: single write SetSampleRate;
    constructor Create(ASampleRate: single);
  end;

type
  TSimpleSynth = class
  private
    FOscillator: TOscillator;
    FFilter: TMusicDspMoog;
    FKey: integer;
  public
    procedure UpdateParameter(id: integer; Value: single);
    function Process: single;
    constructor Create(SampleRate: single);
    procedure onKeyEvent(pitch: integer; _on: boolean);
  end;

implementation

uses Math;

  { TOscillator }

constructor TBaseOscillator.Create(const SampleRate: double);
begin
  FFrequency := 1000;
  Randomize;
  Self.SampleRate := SampleRate;
end;

function TBaseOscillator.ValueAt(FxPos: double): double;
begin
  if FXPos < 0.5 then Result := 1
  else
    Result := -1;
end;

procedure TBaseOscillator.SetFrequency(const Value: double);
begin
  FFrequency := Value;
end;

procedure TBaseOscillator.SetSampleRate(const Value: double);
begin
  if FSampleRate <> Value then
  begin
    FSampleRate := Value;
    if FSampleRate > 0 then
      FSampleReci := 1 / FSampleRate;
  end;
end;

{ TOscillatorBlep }

// http://www.martin-finke.de/blog/articles/audio-plugins-018-polyblep-oscillator/

function TOscillatorBlep.ValueAt(FxPos: double): double;

  function fmod(s: double): double;
  begin
    Result := s - trunc(s);
  end;

begin
  Result := inherited;
  Result := Result + PolyBlep(FxPos);
  Result := Result - PolyBlep(fmod(FxPos + 1 - 0.5));
end;

constructor TOscillator.Create(const ASampleRate: double);
begin
  inherited;
  FPulseWidth := 0.5;
end;

function TOscillator.Process: single;
begin
  Fxpos := Fxpos + FSampleReci * FFrequency;
  if Fxpos >= 1 then Fxpos := Fxpos - 1;
  Result := ValueAt(FxPos);
end;

function TOscillator.PulseWidthAdjusted(AFxPos: double): double;
begin
  if AFxPos <= fPulseWidth then
    Result := AFxPos * 0.5 / fPulseWidth
  else
    Result := 0.5 + 0.5 * (AFxPos - fPulseWidth) / (1 - fPulseWidth);
end;

function TOscillator.ValueAt(AFxPos: double): double;
begin
  Result := inherited ValueAt(PulseWidthAdjusted(AFxPos));
end;

procedure TOscillator.SetPulseWidth(Value: double);
begin
  if Value < 0.05 then Value := 0.05;
  if Value > 0.95 then Value := 0.95;
  FPulseWidth := Value;
end;

function TOscillatorBlep.PolyBlep(t: double): double;
var
  dt: double;
begin

  dt := FSampleReci * FFrequency;
  if dt = 0 then
  begin
    Result := 0;
    exit;
  end;

  // 0 <= t < 1
  if (t < dt) then
  begin
    t := t / dt;
    Result := 2 * t - t * t - 1.0;
  end
  // -1 < t < 0
  else if (t > 1.0 - dt) then
  begin
    t := (t - 1.0) / dt;
    Result := t * t + 2 * t + 1.0;
  end
  // 0 otherwise
  else
    Result := 0.0;
end;


(*********************************************************************************)

constructor TMusicDspMoog.Create(ASampleRate: single);
begin
  FSampleRate := ASampleRate;
  FCutoff := 1000;
  Fresonance := 0;
  Reset;
end;

function TMusicDspMoog.Process(input: single): single;
var
  x: single;
begin
  x := input;
  if x > 1 then x := 1;
  if x < -1 then x := -1;
  x := x - Fresonance * stage[3];
  // Four cascaded one-pole filters (bilinear transform)
  stage[0] := x * p + delay[0] * p - k * stage[0];
  stage[1] := stage[0] * p + delay[1] * p - k * stage[1];
  stage[2] := stage[1] * p + delay[2] * p - k * stage[2];
  stage[3] := stage[2] * p + delay[3] * p - k * stage[3];

  // Clipping band-limited sigmoid
  stage[3] := stage[3] - (stage[3] * stage[3] * stage[3]) / 6.0;

  delay[0] := x;
  delay[1] := stage[0];
  delay[2] := stage[1];
  delay[3] := stage[2];
  // result is in stage[3];
  Result := stage[3];
end;

procedure TMusicDspMoog.Reset;
var
  i: integer;
begin
  for i := 0 to 3 do
  begin
    stage[i] := 0;
    delay[i] := 0;
  end;
  p := 0;
  SetCutoff(FCutoff);
end;

procedure TMusicDspMoog.SetCutoff(cutoff, resonance: single);
begin
  if cutoff <= 5 then exit; // raise Exception.Create('Negative Cutoff?');
  if cutoff >= 20000 then cutoff := 20000; // raise Exception.Create('Negative Cutoff?');
  cutoff := 2.0 * cutoff / FsampleRate;
  if FCutoff <> cutoff then
  begin
    Fcutoff := cutoff;
    p := Fcutoff * (1.8 - 0.8 * Fcutoff);
    k := 2.0 * sin(Fcutoff * pi * 0.5) - 1.0;
    t1 := (1.0 - p) * 1.386249;
    t2 := 12.0 + t1 * t1;
    if resonance >= 0 then Fresonance := resonance;
    SetResonance(Fresonance);
  end
  else if resonance >= 0 then SetResonance(resonance);
end;

procedure TMusicDspMoog.SetCutoff(cutoff: single);
begin
  SetCutoff(cutoff, -1);
end;

procedure TMusicDspMoog.SetResonance(Value: single);
begin
  if (Value > 0.99) then Value := 0.99;
  Fresonance := Value * (t2 + 6.0 * t1) / (t2 - 6.0 * t1);
end;

procedure TMusicDspMoog.SetSampleRate(Value: single);
begin
  FSampleRate := Value;
  SetCutoff(Fcutoff, -1);
end;

{ TSimpleSynth }

constructor TSimpleSynth.Create(SampleRate: single);
begin
  FOscillator := TOscillator.Create(samplerate);
  FFilter := TMusicDspMoog.Create(Samplerate);
end;

procedure TSimpleSynth.onKeyEvent(pitch: integer; _on: boolean);
begin
  if _on then
  begin
    FKey := pitch;
    FOscillator.Frequency := 8.18 * Power(13289 / 8.18, pitch / 128);
  end
  else
    FKey := 0;
end;

function TSimpleSynth.Process: single;
begin
  Result := 0;
  if Fkey <> 0 then
    Result := FFilter.Process(FOscillator.Process);
end;

const
  ID_CUTOFF = 17;

const
  ID_RESONANCE = 18;

const
  ID_PULSEWIDTH = 19;


procedure TSimpleSynth.UpdateParameter(id: integer; Value: single);
begin
  case id of
    ID_CUTOFF: FFilter.Cutoff := 200 * Power(20000 / 200, Value);
    ID_RESONANCE: FFilter.Resonance := Value;
    ID_PULSEWIDTH: FOscillator.PulseWidth := Value;
  end;
end;

end.
