unit UCMidiMapping;

interface

uses Vst3Base,UVST3Controller;

type CMidiMapping = class(TAggregatedObject,IMidiMapping)
      IVST3:IVST3Controller;
      function getMidiControllerAssignment(busIndex: int32; channel: int16; midiControllerNumber: TCtrlNumber; out tag: TParamID): TResult; stdcall;
      constructor Create(const AController: IVST3Controller);
end;

implementation

uses ULogger;

constructor CMidiMapping.Create(const AController: IVST3Controller);
begin
  inherited Create(AController);
  IVST3:=AController;
  WriteLog('CMidiMapping.Create');
end;

function CMidiMapping.getMidiControllerAssignment(busIndex: int32;  channel: int16; midiControllerNumber: TCtrlNumber;  out tag: TParamID): TResult;  stdcall;
VAR t:integer;
begin
  t:=IVST3.GetMidiCCParamID(channel,midiControllerNumber);
  if t>=0 then begin
                 Tag:=t;
                 Result:=kResultOk;
               end
          else
            result:=kResultFalse;
end;

end.
