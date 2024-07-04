unit UMyVst;

interface

uses UVSTInstrument, Forms, Classes, UVSTBase, UMyVSTDSP;

const
  ID_CUTOFF = 17;

const
  ID_RESONANCE = 18;

const
  ID_PULSEWIDTH = 19;

type

  { TMyVSTPlugin }

  TMyVSTPlugin = class(TVSTInstrument)
  private
    FSimpleSynth: TSimpleSynth;
    procedure DoUpdateHostParameter(id: integer; Value: double);
  protected
    procedure Process32(samples, channels: integer; inputp, outputp: PPSingle); override;
    procedure UpdateProcessorParameter(id: integer; Value: double); override;
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure UpdateEditorParameter(id: integer; Value: double); override;
    procedure OnEditOpen; override;
    procedure OnProgramChange(prgm: integer); override;
    procedure OnMidiEvent(byte0, byte1, byte2: integer); override;
    procedure onKeyEvent(key: integer; _on: boolean); // called from Host
    procedure doKeyEvent(key: integer; _on: boolean); // called from UI
  public
  end;

function GetVSTInstrumentInfo: TVSTInstrumentInfo;

implementation

{ TmyVST }

uses UMyVSTForm, SysUtils, Windows, ULogger;

  {$POINTERMATH ON}
  {$define DebugLog}

procedure TMyVSTPlugin.UpdateProcessorParameter(id: integer; Value: double);
begin
  FSimpleSynth.UpdateParameter(id, Value);
end;

procedure TMyVSTPlugin.Process32(samples, channels: integer; inputp, outputp: PPSingle);
var
  i, channel: integer;
  sample: single;
begin
  for i := 0 to samples - 1 do
  begin
    sample := FSimpleSynth.process;
    for channel := 0 to 1 do
      outputp[channel][i] := sample;
  end;
end;

procedure TMyVSTPlugin.OnInitialize;
begin
  FSimpleSynth := TSimpleSynth.Create(44100); // a simple synth...
  AddParameter(ID_CUTOFF, 'Cutoff', 'Cutoff', 'Hz', 20, 20000, 10000);
  AddParameter(ID_RESONANCE, 'Resonance', 'Resonance', '', 0, 1, 0);
  AddParameter(ID_PULSEWIDTH, 'Pulse Width', 'PWM', '%', 0, 100, 50);
  //  AddProgram('Program 1');
  //  AddProgram('Program 2');
  //  AddProgram('Program 3');
end;

procedure TMyVSTPlugin.OnFinalize;
begin
  WriteLog('TMyVSTPlugin.OnFinalize');
  FreeAndNil(FSimpleSynth);
  inherited OnFinalize;
end;

procedure TMyVSTPlugin.OnMidiEvent(byte0, byte1, byte2: integer);

  procedure KeyEvent(key: integer; _on: boolean);
  begin
    OnKeyEvent(key, _on);
    // don't do this with Cubase!    TFormMyVST(EditorForm).SetKey(key,_on);
  end;

var
  status: integer;
const
  MIDI_NOTE_ON = $90;
  MIDI_NOTE_OFF = $80;
  MIDI_CC = $B0;
begin
  // careful:
  // OnMidiEvent can be called from NON-UI thread. (in VST3)
  // Update UI on own risk
  // in this case we need to update the keyboard in the form
  // note that for parameter based changed, you only have to update the processor
  // we COULD make an extra method in the fw OnMidiEventEditor, but that should be discussed
  // this is perhaps one of the reasons Steinberg chose to 'depricate' midi stuff
  WriteLog('TMyVSTPlugin.OnMidiEvent:' + byte0.ToString + ' ' +
    byte1.ToString + ' ' + byte2.ToString);

  status := byte0 and $F0;
  if status = MIDI_NOTE_ON then KeyEvent(byte1, byte2 > 0)
  else if status = MIDI_NOTE_OFF then KeyEvent(byte1, False)
  else if (status = MIDI_CC) and (byte1 = 74) then
    UpdateHostParameter(ID_CUTOFF, byte2 / 127); // this also updates UI
end;

procedure TMyVSTPlugin.OnProgramChange(prgm: integer);
begin
  if EditorForm <> nil then
    TFormMyVST(EditorForm).SetProgram(prgm);
end;

procedure TMyVSTPlugin.OnEditOpen;
begin
  ResendParameters;
  TFormMyVST(EditorForm).HostUpdateParameter := @DoUpdateHostParameter;
  TFormMyVST(EditorForm).HostKeyEvent := @DoKeyEvent;
  TFormMyVST(EditorForm).HostPrgmChange := @DoProgramChange;
end;

procedure TMyVSTPlugin.onKeyEvent(key: integer; _on: boolean); // from Host
const
  MIDI_NOTE_ON = $90;
  MIDI_NOTE_OFF = $80;
begin
  FSimpleSynth.OnKeyEvent(key, _on);
end;

procedure TMyVSTPlugin.doKeyEvent(key: integer; _on: boolean); // from UI
const
  MIDI_NOTE_ON = $90;
  MIDI_NOTE_OFF = $80;
begin
  FSimpleSynth.OnKeyEvent(key, _on);
  DoMidiEvent(MIDI_NOTE_ON, key, 127 * Ord(_on));   // just a test
end;


procedure TMyVSTPlugin.DoUpdateHostParameter(id: integer; Value: double);
const
  MIDI_CC = $B0;
begin
  UpdateHostParameter(id, Value);
  DoMidiEvent(MIDI_CC, id, round(127 * Value));   // just a test
end;

procedure TMyVSTPlugin.UpdateEditorParameter(id: integer; Value: double);
begin
  TFormMyVST(EditorForm).UpdateEditorParameter(id, Value);
end;

const
  UID_CMyVSTPlugin: TGUID = '{4be90c10-36f7-46f2-b931-076a0f8bdca7}';

function GetVSTInstrumentInfo: TVSTInstrumentInfo;
begin
  with Result do
  begin
    with PluginDef do
    begin
      vst3id := UID_CMyVSTPlugin;
      cl := TMyVSTPlugin;
      Name := 'SimpleSynth';
      ecl := TFormMyVST;
      isSynth := True;
      vst2id := 'ERMS';
    end;
    with factoryDef do
    begin
      vendor := 'Ermers Consultancy';
      url := 'www.ermers.org';
      email := 'ruud@ermers.org';
    end;
  end;
end;

end.
