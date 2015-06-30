unit uSettings;

interface

uses Windows, Classes, IniFiles, SysUtils;

procedure ReadIniParams;
procedure WriteIniParams;

type

  TSettings = class(TObject)
  public
    Active: boolean;
    UseNumThreadsFromProg: boolean;
    UseNumThreadsPlug: boolean;
    CountThreads: integer;
    TimeRecognition: integer;
    MethodRecognition: integer;
    UseAntigateKey: boolean;
    UseAntigateKeyFromProg: boolean;
    AntigateKey: string;
    RecognitionProg: string;
    CapIniFile: string;
    CatalogLetters: string;
    phrase: boolean;
    regsense: boolean;
    numeric: integer;
    calc: boolean;
    min_len: integer;
    max_len: integer;
    MainPControl: integer;
    UsePremium: boolean;
    LoginPremium: string;
    PasswordPremium: string;
    RecPControl: integer;
    SkinName: string;
    SkinDirectory: string;
    SkinActive: boolean;
    Saturation: integer;
    Hue: integer;
    NumUsualSect: integer;
    NumProxySect: integer;
    SubstituteProxySection: boolean;
  end;

var
  Settings: TSettings;

implementation

uses uFunctions;

procedure ReadIniParams;
var
  IniFile: TIniFile;
  Buffer: array [byte] of char;
  NamePlugin: string;
  PathPlugin: string;
  PathApplication: string;
begin
  if GetModuleFileName(hInstance, @Buffer, SizeOf(Buffer) - 1) > 0 then
    NamePlugin := ExtractFileName(StrPas(Buffer));

  IniFile := TIniFile.Create(ExtractFilePath(GetModuleFileNameStr(0))
      + 'plugins.ini');
  if IniFile.SectionExists(NamePlugin) then
  begin
    Settings.Active := IniFile.ReadBool(NamePlugin, 'Active', true);
    Settings.UseNumThreadsFromProg := IniFile.ReadBool(NamePlugin,
      'CountThreadsProg', false);
    Settings.UseNumThreadsPlug := IniFile.ReadBool(NamePlugin,
      'CountThreadsPlug', true);
    Settings.CountThreads := IniFile.ReadInteger(NamePlugin, 'CountThreads', 100);
    Settings.TimeRecognition := IniFile.ReadInteger(NamePlugin,
      'TimeRecognition', 120000);
    Settings.MethodRecognition := IniFile.ReadInteger(NamePlugin,
      'MethodRecognition', 0);
    Settings.UseAntigateKey := IniFile.ReadBool(NamePlugin, 'UseAntigateKey',
      false);
    Settings.UseAntigateKeyFromProg := IniFile.ReadBool(NamePlugin,
      'UseAntigateKeyFromProg', true);
    Settings.AntigateKey := IniFile.ReadString(NamePlugin, 'AntigateKey', '');
    Settings.RecognitionProg := IniFile.ReadString(NamePlugin,
      'RecognitionProg', '');
    Settings.CapIniFile := IniFile.ReadString(NamePlugin, 'CapIniFile', '');
    Settings.CatalogLetters := IniFile.ReadString(NamePlugin, 'CatalogLetters',
      '');
    Settings.phrase := IniFile.ReadBool(NamePlugin, 'phrase', false);
    Settings.regsense := IniFile.ReadBool(NamePlugin, 'regsense', false);
    Settings.numeric := IniFile.ReadInteger(NamePlugin, 'numeric', 0);
    Settings.calc := IniFile.ReadBool(NamePlugin, 'calc', false);
    Settings.min_len := IniFile.ReadInteger(NamePlugin, 'min_len', 0);
    Settings.max_len := IniFile.ReadInteger(NamePlugin, 'max_len', 0);
    Settings.MainPControl := IniFile.ReadInteger(NamePlugin, 'MainPControl', 0);
    Settings.UsePremium := IniFile.ReadBool(NamePlugin, 'UsePremium', false);
    Settings.LoginPremium := IniFile.ReadString(NamePlugin, 'LoginPremium', '');
    Settings.PasswordPremium := IniFile.ReadString(NamePlugin,
      'PasswordPremium', '');
    Settings.RecPControl := IniFile.ReadInteger(NamePlugin, 'RecPControl', 0);
    Settings.NumUsualSect := IniFile.ReadInteger(NamePlugin, 'NumUsualSect', 0);
    Settings.NumProxySect := IniFile.ReadInteger(NamePlugin, 'NumProxySect', 0);
    Settings.SubstituteProxySection := IniFile.ReadBool(NamePlugin,
      'SubstituteProxySection', true);
    IniFile.Free;
  end
  else
  begin
    IniFile.Free;
    Settings.Active := true;
    Settings.UseNumThreadsFromProg := false;
    Settings.UseNumThreadsPlug := true;
    Settings.CountThreads := 100;
    Settings.TimeRecognition := 120000;
    Settings.MethodRecognition := 0;
    Settings.UseAntigateKey := false;
    Settings.UseAntigateKeyFromProg := true;
    Settings.AntigateKey := '';
    Settings.RecognitionProg := '';
    Settings.CapIniFile := '';
    Settings.CatalogLetters := '';
    Settings.phrase := false;
    Settings.regsense := false;
    Settings.numeric := 0;
    Settings.calc := false;
    Settings.min_len := 0;
    Settings.max_len := 0;
    Settings.MainPControl := 0;
    Settings.UsePremium := false;
    Settings.LoginPremium := '';
    Settings.PasswordPremium := '';
    Settings.RecPControl := 0;
    Settings.NumUsualSect := 0;
    Settings.NumProxySect := 0;
    Settings.SubstituteProxySection := true;
    WriteIniParams;
  end;

end;

procedure WriteIniParams;
var
  IniFile: TIniFile;
  Buffer: array [byte] of char;
  NamePlugin: string;
begin
  if GetModuleFileName(hInstance, @Buffer, SizeOf(Buffer) - 1) > 0 then
  begin
    NamePlugin := ExtractFileName(StrPas(Buffer));
  end;
  IniFile := TIniFile.Create(ExtractFilePath(GetModuleFileNameStr(0))
      + 'plugins.ini');
  IniFile.WriteBool(NamePlugin, 'Active', Settings.Active);
  IniFile.WriteBool(NamePlugin, 'CountThreadsProg', Settings.UseNumThreadsFromProg);
  IniFile.WriteBool(NamePlugin, 'CountThreadsPlug', Settings.UseNumThreadsPlug);
  IniFile.WriteInteger(NamePlugin, 'CountThreads', Settings.CountThreads);
  IniFile.WriteInteger(NamePlugin, 'TimeRecognition', Settings.TimeRecognition);
  IniFile.WriteInteger(NamePlugin, 'MethodRecognition',
    Settings.MethodRecognition);
  IniFile.WriteBool(NamePlugin, 'UseAntigateKey', Settings.UseAntigateKey);
  IniFile.WriteBool(NamePlugin, 'UseAntigateKeyFromProg',
    Settings.UseAntigateKeyFromProg);
  IniFile.WriteString(NamePlugin, 'AntigateKey', Settings.AntigateKey);
  IniFile.WriteString(NamePlugin, 'RecognitionProg', Settings.RecognitionProg);
  IniFile.WriteString(NamePlugin, 'CapIniFile', Settings.CapIniFile);
  IniFile.WriteString(NamePlugin, 'CatalogLetters', Settings.CatalogLetters);
  IniFile.WriteBool(NamePlugin, 'phrase', Settings.phrase);
  IniFile.WriteBool(NamePlugin, 'regsense', Settings.regsense);
  IniFile.WriteBool(NamePlugin, 'calc', Settings.calc);
  IniFile.WriteInteger(NamePlugin, 'numeric', Settings.numeric);
  IniFile.WriteInteger(NamePlugin, 'min_len', Settings.min_len);
  IniFile.WriteInteger(NamePlugin, 'max_len', Settings.max_len);
  IniFile.WriteInteger(NamePlugin, 'MainPControl', Settings.MainPControl);
  IniFile.WriteBool(NamePlugin, 'UsePremium', Settings.UsePremium);
  IniFile.WriteString(NamePlugin, 'LoginPremium', Settings.LoginPremium);
  IniFile.WriteString(NamePlugin, 'PasswordPremium', Settings.PasswordPremium);
  IniFile.WriteInteger(NamePlugin, 'RecPControl', Settings.RecPControl);
  IniFile.WriteInteger(NamePlugin, 'NumUsualSect', Settings.NumUsualSect);
  IniFile.WriteInteger(NamePlugin, 'NumProxySect', Settings.NumProxySect);
  IniFile.WriteBool(NamePlugin, 'SubstituteProxySection',
    Settings.SubstituteProxySection);
  IniFile.Free;
end;

end.
