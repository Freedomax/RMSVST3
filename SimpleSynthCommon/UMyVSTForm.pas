unit UMyVSTForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, UMyVST, UPianoKeyboard, ULogger;

type
  THostKeyEvent = procedure(key: integer; _on: boolean) of object;
  THostUpdateParameter = procedure(id: integer; Value: double) of object;
  THostPrgmChange = procedure(prgm: integer) of object;

  { TFormMyVST }

  TFormMyVST = class(TForm)
    ScrollBar1: TScrollBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ScrollBar2: TScrollBar;
    ScrollBar3: TScrollBar;
    Button1: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FScrollBars: array[0..2] of TScrollBar;
    Fkeyboard: TRMCKeyboard;
    procedure CBOnKeyEvent(Sender: TObject; key: integer; _on, infinite: boolean);
  public
    { Public declarations }
    { property } HostKeyEvent: THostKeyEvent;
    { property } HostUpdateParameter: THostUpdateParameter;
    { property } HostPrgmChange: THostPrgmChange;
    procedure UpdateEditorParameter(index: integer; Value: double);
    procedure SetProgram(prgm: integer);
    procedure SetKey(key: integer; _on: boolean);
  end;

var
  FormMyVST: TFormMyVST;

implementation

{$R *.dfm}

procedure TFormMyVST.FormCreate(Sender: TObject);
begin
  Fkeyboard := TRMCKeyboard.Create(self);
  Fkeyboard.Parent := self;
  Fkeyboard.Align := alBottom;
  Fkeyboard.Height := 80;
  FScrollBars[0] := ScrollBar1;
  FScrollBars[1] := ScrollBar2;
  FScrollBars[2] := ScrollBar3;
  Fkeyboard.OnKeyEvent := @CBOnKeyEvent;

  WriteLog('MyVST FormCreate');
end;

procedure TFormMyVST.ScrollBar1Change(Sender: TObject);
var
  isb: integer;
begin
  for isb := 0 to 2 do
    if Sender = FScrollBars[isb] then
      if assigned(HostUpdateParameter) then
        HostUpdateParameter(ID_CUTOFF + isb, FScrollBars[isb].Position / 100);
end;

procedure TFormMyVST.FormDestroy(Sender: TObject);
begin
  WriteLog('MyVST FormDestroy');
end;

procedure TFormMyVST.Button1Click(Sender: TObject);
begin
  if assigned(HostPrgmChange) then
    HostPrgmChange(1);
end;

procedure TFormMyVST.CBOnKeyEvent(Sender: TObject; key: integer; _on, infinite: boolean);
begin
  if assigned(HostKeyEvent) then
    HostKeyEvent(key, _on);
end;

procedure TFormMyVST.SetKey(key: integer; _on: boolean);
begin
  Fkeyboard.SetKeyPressed(key, _on);
end;

procedure TFormMyVST.SetProgram(prgm: integer);
begin
  Label2.Caption := 'Program:' + prgm.toString;
end;

procedure TFormMyVST.UpdateEditorParameter(index: integer; Value: double);
var
  isb: integer;
begin
  for isb := 0 to 2 do
    if index = ID_CUTOFF + isb then
      FScrollBars[isb].Position := round(100 * Value);
end;

end.
