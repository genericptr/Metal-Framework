{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lazmetalcontrol;

{$warn 5023 off : no warning about unused units}
interface

uses
  MetalControl, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('MetalControl', @MetalControl.Register);
end;

initialization
  RegisterPackage('lazmetalcontrol', @Register);
end.
