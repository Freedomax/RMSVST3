unit UPianoKeyboard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics,
  Controls, Forms, Dialogs, ExtCtrls, StdCtrls;

type
  TOnKeyEvent = procedure(Sender: TObject; key: integer;
    _on, infinite: boolean) of object;

  { TRMCKeyboard }

  TRMCKeyboard = class(TGraphicControl)
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: integer); override;
    procedure MyMouseEnter(Sender: TObject);
    procedure MyMouseLeave(Sender: TObject);
  private
    FLastKey: integer;
    Foctaves: integer;
    FSelected: array of boolean;
    FDown: boolean;
    FOnKeyEvent: TOnKeyEvent;
    function LowerKey: integer;

    procedure SetOctaves(Value: integer);
    function GetKey(X, Y: integer): integer;
    function GetBlackRect(octave, index: integer): TRect;
    function GetWhiteRect(octave, index: integer): TRect;
    procedure DrawBlackKey(octave, index: integer; selected: integer);
    procedure DrawWhiteKey(octave, index: integer; selected: integer);

    procedure SetKey(key: integer; _on: boolean; infinite: boolean = False);
    function xoffset(key: integer): integer;
  public
    constructor Create(Aowner: TComponent); override;
    procedure SetKeyPressed(key: integer; _on: boolean);
  published
    property OnKeyEvent: TOnkeyEvent read FOnKeyEvent write FOnKeyEvent;
    property Octaves: integer read FOctaves write SetOctaves;
    property Anchors;
    property Align;
    property Enabled;
    property Visible;
  end;


procedure Register;

implementation

{ TMyKeyboard }

procedure Register;
begin
  RegisterComponents('RMC', [TRMCKeyboard]); // Ruuds Midi Controls
end;

const
  blackkey: array[0..4] of integer = (1, 3, 6, 8, 10);

const
  whitekey: array[0..7] of integer = (0, 2, 4, 5, 7, 9, 11, 12);

procedure TRMCKeyboard.SetKey(key: integer; _on: boolean; infinite: boolean);
begin
  FSelected[key] := _on;
  if assigned(OnKeyEvent) then
    OnKeyEvent(self, key + LowerKey, _on, infinite and _on);
  Invalidate;
end;

procedure TRMCKeyboard.SetKeyPressed(key: integer; _on: boolean);
begin
  Dec(key, LowerKey);
  if (key >= 0) and (key <= 12 * octaves) then
  begin
    FSelected[key] := _on;
    Invalidate;
  end;
end;

procedure TRMCKeyboard.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: integer);
var
  key: integer;
begin
  key := GetKey(X, Y);
  if key = -1 then exit;
  if Button = mbLeft then
  begin
    FDown := True;
    SetKey(key, True);
  end;
  if Button = mbRight then
    SetKey(key, not FSelected[key], True);

end;

procedure TRMCKeyboard.MouseMove(Shift: TShiftState; X, Y: integer);
var
  key: integer;
begin
  key := GetKey(X, Y);
  if (key <> FLastKey) then
  begin
    if FDown then SetKey(FLastKey, False);
    FLastKey := key;
    if FDown then SetKey(FLastKey, True);
    Invalidate;
  end;
end;

procedure TRMCKeyboard.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  if not FDown then exit;
  if FLastKey <> -1 then
  begin
    FDown := False;
    SetKey(FLastKey, False);
  end;
end;

procedure TRMCKeyboard.MyMouseEnter(Sender: TObject);
begin

end;

procedure TRMCKeyboard.MyMouseLeave(Sender: TObject);
begin
  MouseMove([], -100, -100);
end;

function inRect(x, y: integer; r: TRect): boolean;
begin
  with r do
    Result := (x >= Left) and (x < Right) and (y >= Top) and (y < Bottom);
end;

function TRMCKeyboard.GetKey(X, Y: integer): integer;
var
  i, o: integer;
begin
  for o := 0 to Octaves - 1 do
  begin
    for i := 0 to 4 do if inRect(X, Y, GetBlackRect(o, i)) then
      begin
        Result := blackkey[i] + 12 * o;
        exit;
      end;
  end;
  for o := 0 to Octaves - 1 do
    for i := 0 to 7 do if inRect(X, Y, GetWhiteRect(o, i)) then
      begin
        Result := whitekey[i] + 12 * o;
        exit;
      end;
  if inRect(X, Y, GetWhiteRect(Octaves, 0)) then Result := 12 * Octaves
  else
    Result := -1;
end;

function TRMCKeyboard.GetBlackRect(octave, index: integer): TRect;
const
  off: array[0..4] of integer = (17, 49, 95, 126, 156);

  function pixw(w, f1, f2: integer): integer;
  begin
    Result := round(w * f2 / f1);
  end;

var
  w, x, scalew: integer;
begin
  scalew := xoffset(7);
  x := pixw(off[index], 186, scalew) + xoffset(7 * octave);
  w := pixw(17, 186, scalew);
  Result := Rect(x, 0, x + w, round(Height * 0.63));
end;

function TRMCKeyboard.xoffset(key: integer): integer;
begin
  Result := round(Width * key / (7 * octaves + 1));
end;

function TRMCKeyboard.GetWhiteRect(octave, index: integer): TRect;
var
  x, w: integer;
begin
  x := xoffset(7 * octave) + xoffset(index);
  w := xoffset(index + 1) - xoffset(index);
  Result := Rect(x, 0, x + w, Height);
end;

function TRMCKeyboard.LowerKey: integer;
begin
  Result := 12 * (5 - Octaves div 2);
end;

constructor TRMCKeyboard.Create(Aowner: TComponent);
begin
  inherited;
  OnMouseEnter := @MyMouseEnter;
  OnMouseLeave := @MyMouseLeave;
  Octaves := 3;
  Width := 600;
  Height := 90;
  FLastKey := -1;
end;

procedure TRMCKeyboard.DrawBlackKey(octave, index: integer; selected: integer);
begin
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Width := 1;
  Canvas.Brush.Style := bsSolid;
  case selected of
    0: Canvas.Brush.Color := clBlack;
    1: Canvas.Brush.Color := clLtGray;
    2: Canvas.Brush.Color := clDkGray;
  end;
  with GetBlackRect(octave, index) do
    Canvas.Rectangle(Left, Top, Right, Bottom);
end;

procedure TRMCKeyboard.DrawWhiteKey(octave, index: integer; selected: integer);
begin
  begin
    Canvas.Pen.Color := clBlack;
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Width := 1;
    Canvas.Brush.Style := bsSolid;
    case selected of
      0: Canvas.Brush.Color := clWhite;
      1: Canvas.Brush.Color := clDkGray;
      2: Canvas.Brush.Color := clLtGray;
    end;
    with GetWhiteRect(octave, index) do
      Canvas.Rectangle(Left, Top, Right, Bottom);
  end;
end;

procedure TRMCKeyboard.Paint;

  function getSelect(key: integer): integer;
  begin
    if Fselected[key] then Result := 1
    else if key = FLastKey then Result := 2
    else
      Result := 0;
  end;

var
  i, o: integer;
begin
  for o := 0 to Octaves - 1 do
  begin
    for i := 0 to 6 do DrawWhiteKey(o, i, getSelect(o * 12 + whitekey[i]));
    if o = octaves - 1 then DrawWhiteKey(o, 7, getSelect(octaves * 12));
    for i := 0 to 4 do DrawBlackKey(o, i, getSelect(o * 12 + blackkey[i]));
  end;
end;

procedure TRMCKeyboard.SetOctaves(Value: integer);
var
  i: integer;
begin
  Foctaves := Value;
  setLength(FSelected, 12 * FOctaves + 1);
  for i := 0 to 12 * FOctaves do FSelected[i] := False;
  Invalidate;
end;

end.
