{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit RMSVST3;

{$warn 5023 off : no warning about unused units}
interface

uses
  UCComponent, UCEditController, UCMidiMapping, UCPluginFactory, UCPlugView, 
  UCUnitInfo, UVST3Controller, UVST3Processor, UVST3Utils, UVSTInstrument, 
  Vst3Base, UCDataLayer, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('RMSVST3', @Register);
end.
