library RMSMyVST3;
{$J-,H+,T-P+,X+,B-,V-,O+,A+,W-,U-,R-,I-,Q-,D-,L-,Y-,C-}
{$E vst3}

uses
  Interfaces,
  Forms,
  Vst3Base,
  UCPluginFactory,
  UMyVst in '..\SimpleSynthCommon\UMyVst.pas',
  UMyVSTForm in '..\SimpleSynthCommon\UMyVSTForm.pas' {FormMyVST},
  UPianoKeyboard in '..\SimpleSynthCommon\UPianoKeyboard.pas',
  UMyVstDSP in '..\SimpleSynthCommon\UMyVstDSP.pas';

var
  gFactory: IPluginFactory;

  function InitDLL: boolean; cdecl; export;
  begin
    Result := True;
  end;

  function ExitDLL: boolean; cdecl; export;
  begin
    Result := True;
  end;

  function GetPluginFactory: pointer; stdcall; export;
  begin
    if gFactory = nil then
      gFactory := CreatePlugin(GetVSTInstrumentInfo)
    else
      gFactory._AddRef;
    Result := gFactory;
  end;


exports
  InitDLL Name 'InitDLL',
  ExitDLL Name 'ExitDLL',
  GetPluginFactory Name 'GetPluginFactory';

begin
  Application.Initialize;
end.
