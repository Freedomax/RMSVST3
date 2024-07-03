
library RMSMyVST3;
{$J-,H+,T-P+,X+,B-,V-,O+,A+,W-,U-,R-,I-,Q-,D-,L-,Y-,C-}
{$E vst3}

uses
  Forms,
  Interfaces,
  UCPluginFactory in 'UCPluginFactory.pas',
  UVST3Utils in 'UVST3Utils.pas',
  UCEditController in 'UCEditController.pas',
  UCAudioProcessor in 'UCAudioProcessor.pas',
  UCComponent in 'UCComponent.pas',
  UCPlugView in 'UCPlugView.pas',
  UCMidiMapping in 'UCMidiMapping.pas',
  UVSTInstrument in 'UVSTInstrument.pas',
  UCUnitInfo in 'UCUnitInfo.pas',
  UCDataLayer in '..\FrameworkCommon\UCDataLayer.pas',
  UVST3Processor in 'UVST3Processor.pas',
  UVST3Controller in 'UVST3Controller.pas',
  UVSTBase in '..\FrameworkCommon\UVSTBase.pas',
  UMyVst in '..\SimpleSynthCommon\UMyVst.pas',
  UMyVSTForm in '..\SimpleSynthCommon\UMyVSTForm.pas' {FormMyVST},
  UPianoKeyboard in '..\SimpleSynthCommon\UPianoKeyboard.pas',
  UMyVstDSP in '..\SimpleSynthCommon\UMyVstDSP.pas',
  Vst3Base in 'Vst3Base.pas',
  ULogger in '..\FrameworkCommon\ULogger.pas';

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
