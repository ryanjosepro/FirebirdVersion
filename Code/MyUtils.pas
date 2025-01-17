unit MyUtils;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Variants, System.StrUtils,
  ShellAPI, Vcl.Forms, Windows, IOUtils, Vcl.Dialogs;

type
  TIntegerArray = array of integer;
  TStringArray = array of string;
  TStringMatrix = array of TStringArray;

  TUtils = class
  public
    class function Iif(Cond: boolean; V1, V2: variant): variant;
    class function IfLess(Value, Value2: integer): integer;
    class function IfEmpty(Value, Replace: string): string;
    class function IfZero(Value, Replace: integer): integer;

    class function IifLess(Cond: boolean; V1, V2: integer): integer;
    class function IifEmpty(Cond: boolean; V1, V2: string): string;
    class function IifZero(Cond: boolean; V1, V2: integer): integer;

    class function Cut(Text, Separator: string): TStringArray;

    class function ArrayToStr(StrArray: TStringArray; Separator: string; StrFinal: string; Starts: integer = 0; EndsBefore: integer = 0): string; overload;
    class function ArrayToStr(StrArray: System.TArray<System.string>; Separator: string; StrFinal: string; Starts: integer = 0; EndsBefore: integer = 0): string; overload;

    class function Extract(StrList: TStringList; Starts, Ends: integer): TStringList; overload;
    class function Extract(StrList: TStringList; Starts, Ends: string; IncStarts: boolean = true; IncEnds: boolean = true): TStringList; overload;
    class function Extract(StrList: TStringList; Starts: integer; Ends: string; IncEnds: boolean = false): TStringList; overload;
    class function Extract(StrList: TStringList; Starts: string; Ends: integer; IncStarts: boolean = false): TStringList; overload;

    class procedure ExecCmd(Comand: string; ShowCmd: integer = 1);
    class function ExecDos(CommandLine: string; Work: string = 'C:\'): string;

    class procedure DeleteIfExistsDir(Dir: string);
    class procedure DeleteIfExistsFile(FileName: string);
    class function GetLastFolder(Dir: String): String;
    class function AppPath: string;

    class function BreakLine: string;

    class function Temp: string;

    class procedure AddFirewallPort(RuleName, Port: string);

    class procedure DeleteFirewallPort(RuleName, Port: string);

    class function IsFileInUse(FileName: TFileName): Boolean; static;

    class function GetFirebirdFileVersion(FileName: string): string;

    class function OpenFileAll(out FileName: string): boolean;
    class function OpenFile(DisplayName, FileMask: string; IncludeAllFiles: boolean;
out FileName: string): boolean;
    class function OpenFolder(out FileName: string): boolean;

    class function SaveFileAll(out FileName: string): boolean;
    class function SaveFile(DisplayName, FileMask: string; IncludeAllFiles: boolean;
out FileName: string): boolean;
    class function SaveFolder(out FileName: string): boolean;
  end;

implementation

//M�todo para usar operador tern�rio
class function TUtils.Iif(Cond: boolean; V1, V2: variant): variant;
begin
  if Cond then
  begin
    Result := V1;
  end
  else
  begin
    Result := V2;
  end;
end;

//Retorna o menor valor
class function TUtils.IfLess(Value, Value2: integer): integer;
begin
  Result := Iif(Value < Value2, Value, Value2);
end;

//Retorna um substituto se o valor for vazio
class function TUtils.IfEmpty(Value, Replace: string): string;
begin
  Result := Iif(Value.Trim = '', Replace, Value);
end;

//Retorna um substituto se o valor for zero
class function TUtils.IfZero(Value, Replace: integer): integer;
begin
  Result := Iif(Value = 0, Replace, Value);
end;

//Iif e IfLess juntos num m�todo s�
class function TUtils.IifLess(Cond: boolean; V1, V2: integer): integer;
begin
  Result := Iif(Cond, V1, IfLess(V2, V1));
end;

//Iif e IfEmpty juntos num m�todo s�
class function TUtils.IifEmpty(Cond: boolean; V1, V2: string): string;
begin
  Result := Iif(Cond, V1, IfEmpty(V2, V1));
end;

//Iif e IfZero juntos num m�todo s�
class function TUtils.IifZero(Cond: boolean; V1, V2: integer): integer;
begin
  Result := Iif(Cond, V1, IfZero(V2, V1));
end;

//Divide uma string em array baseando-se no separador
class function TUtils.Cut(Text, Separator: string): TStringArray;
var
  StrArray: TStringDynArray;
  Cont: integer;
begin
  SetLength(StrArray, Length(SplitString(Text, Separator)));
  StrArray := SplitString(Text, Separator);
  SetLength(Result, Length(StrArray));
  for Cont := 0 to Length(StrArray) - 1 do
  begin
    Result[Cont] := StrArray[Cont];
  end;
end;

//Transforma um array em uma string
class function TUtils.ArrayToStr(StrArray: TStringArray; Separator, StrFinal: string; Starts: integer; EndsBefore: integer): string;
var
  Cont: integer;
begin
  Result := '';
  for Cont := TUtils.Iif(Starts >= Length(StrArray), 0, Starts) to Length(StrArray) - 1 - EndsBefore do
  begin
    if Cont = Length(StrArray) - 1 - EndsBefore then
    begin
      Result := Result + StrArray[Cont] + StrFinal;
    end
    else
    begin
      Result := Result + StrArray[Cont] + Separator;
    end;
  end;
end;

class function TUtils.ArrayToStr(StrArray: System.TArray<System.string>; Separator, StrFinal: string; Starts: integer; EndsBefore: integer): string;
var
  Cont: integer;
begin
  Result := '';
  for Cont := TUtils.Iif(Starts >= Length(StrArray), 0, Starts) to Length(StrArray) - 1 - EndsBefore do
  begin
    if Cont = Length(StrArray) - 1 - EndsBefore then
    begin
      Result := Result + StrArray[Cont] + StrFinal;
    end
    else
    begin
      Result := Result + StrArray[Cont] + Separator;
    end;
  end;
end;

//Extrai uma parte de uma StringList
class function TUtils.Extract(StrList: TStringList; Starts, Ends: integer): TStringList;
var
  Cont: integer;
begin
  Result := TStringList.Create;
  Ends := IfLess(Ends + 1, StrList.Count);
  for Cont := Starts to Ends do
  begin
    Result.Add(StrList[Cont]);
  end;
end;

class function TUtils.Extract(StrList: TStringList; Starts, Ends: string; IncStarts: boolean; IncEnds: boolean): TStringList;
var
  Cont: integer;
begin
  Result := TStringList.Create;
  Cont := 0;
  while StrList[Cont] <> Starts do
  begin
    Inc(Cont);
  end;

  for Cont := Iif(IncStarts, Cont, Cont + 1) to StrList.Count - 1 do
  begin
    if StrList[Cont] <> Ends then
    begin
      Result.Add(StrList[Cont]);
    end
    else
    begin
      if IncEnds then
      begin
        Result.Add(StrList[Cont]);
      end;
      Break;
    end;
  end;
end;

class function TUtils.Extract(StrList: TStringList; Starts: integer; Ends: string; IncEnds: boolean): TStringList;
var
  Cont: integer;
begin
  Result := TStringList.Create;
  for Cont := 0 to StrList.Count - 1 do
  begin
    if StrList[Cont] <> Ends then
    begin
      Result.Add(StrList[Cont]);
    end
    else
    begin
      if IncEnds then
      begin
        Result.Add(StrList[Cont]);
      end;
      Break;
    end;
  end;
end;

class function TUtils.Extract(StrList: TStringList; Starts: string; Ends: integer; IncStarts: boolean): TStringList;
var
  Cont: integer;
begin
  Result := TStringList.Create;
  Cont := 0;
  while StrList[Cont] <> Starts do
  begin
    Inc(Cont);
  end;

  for Cont := Iif(IncStarts, Cont, Cont + 1) to Ends do
  begin
    Result.Add(StrList[Cont]);
  end;
end;

//Executa um comando cmd - async
class procedure TUtils.ExecCmd(Comand: string; ShowCmd: integer = 1);
begin
  ShellExecute(0, nil, 'cmd.exe', PWideChar(Comand), nil, ShowCmd);
end;

//Executa um comando cmd - sync
class function TUtils.ExecDos(CommandLine: string; Work: string = 'C:\'): string;
var
  SecAtrrs: TSecurityAttributes;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  pCommandLine: array[0..255] of AnsiChar;
  BytesRead: Cardinal;
  WorkDir: string;
  Handle: Boolean;
begin
  Result := '';
  with SecAtrrs do begin
    nLength := SizeOf(SecAtrrs);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SecAtrrs, 0);
  try
    with StartupInfo do
    begin
      FillChar(StartupInfo, SizeOf(StartupInfo), 0);
      cb := SizeOf(StartupInfo);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;
    WorkDir := Work;
    Handle := CreateProcess(nil, PChar('cmd.exe /C ' + CommandLine),
                            nil, nil, True, 0, nil,
                            PChar(WorkDir), StartupInfo, ProcessInfo);
    CloseHandle(StdOutPipeWrite);
    if Handle then
      try
        repeat
          WasOK := windows.ReadFile(StdOutPipeRead, pCommandLine, 255, BytesRead, nil);
          if BytesRead > 0 then
          begin
            pCommandLine[BytesRead] := #0;
            Result := Result + pCommandLine;
          end;
        until not WasOK or (BytesRead = 0);
        WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
      finally
        CloseHandle(ProcessInfo.hThread);
        CloseHandle(ProcessInfo.hProcess);
      end;
  finally
    CloseHandle(StdOutPipeRead);
  end;
end;

//M�todos para gerenciar arquivos e diret�rios
class procedure TUtils.DeleteIfExistsDir(Dir: string);
begin
  if TDirectory.Exists(Dir) then
    TDirectory.Delete(Dir, true);
end;

class procedure TUtils.DeleteIfExistsFile(FileName: string);
begin
  if FileExists(FileName) then
    TFile.Delete(FileName);
end;

class function TUtils.GetLastFolder(Dir: String): String;
var
  sa: TStringDynArray;
begin
  sa := SplitString(Dir, PathDelim);
  Result := sa[High(sa)];
end;

class function TUtils.AppPath: string;
begin
  Result := ExtractFilePath(Application.ExeName);
end;

//Retorna uma quebra de linha
class function TUtils.BreakLine: string;
begin
  Result := #13#10;
end;

//Retorna o diret�rio temp
class function TUtils.Temp: string;
begin
  Result := GetEnvironmentVariable('TEMP');
end;

class procedure TUtils.AddFirewallPort(RuleName, Port: string);
begin
  ExecDos('netsh advfirewall firewall add rule name="' + RuleName + '" dir=in action=allow protocol=TCP localport=' + Port);
  ExecDos('netsh advfirewall firewall add rule name="' + RuleName + '" dir=out action=allow protocol=TCP localport=' + Port);
end;

class procedure TUtils.DeleteFirewallPort(RuleName, Port: string);
begin
  ExecDos('netsh advfirewall firewall delete rule name="' + RuleName + '" protocol=TCP localport=' + Port);
end;

class function TUtils.IsFileInUse(FileName: TFileName): Boolean;
var
  HFileRes: HFILE;
begin
  Result := False;
  if not FileExists(FileName) then Exit;
  HFileRes := CreateFile(PChar(FileName),
                         GENERIC_READ or GENERIC_WRITE,
                         0,
                         nil,
                         OPEN_EXISTING,
                         FILE_ATTRIBUTE_NORMAL,
                         0);
  Result := (HFileRes = INVALID_HANDLE_VALUE);
  if not Result then
    CloseHandle(HFileRes);
end;

//Get Firebird file version by ods version on HEX of file
class function TUtils.GetFirebirdFileVersion(FileName: string): string;
var
  Buff: array[0..64] of Byte;
  HexText: array[0..129] of Char;
begin
//  if CreateFileCopy then
//  begin
//    var TempDir := Temp + '\FirebirdVersion';
//    NewFileName := TempDir + '\' + ExtractFileName(FileName);
//
//    TDirectory.CreateDirectory(TempDir);
//
//    CopyFile(PWideChar(FileName), PWideChar(NewFileName), false);
//
//    Sleep(300);
//  end
//  else
//    NewFileName := FileName;

  ///////////

  var FileStream := TFileStream.Create(FileName, fmShareDenyNone);

  try
    var CountRead := FileStream.Read(Buff, SizeOf(Buff));

    BinToHex(Buff, HexText, CountRead);

    var OdsVersion := (HexText[36] + HexText[37]);
    var OdsMinorVersion := (HexText[128] + HexText[129]);

    case IndexStr(UpperCase(OdsVersion), ['0A', '0B', '0C', '0D']) of
    //Ods 10
    0:
      case IndexStr(UpperCase(OdsMinorVersion), ['00', '01']) of
        0:
          //Ods 10.0
          Result := '1.0';
        1:
          //Ods 10.1
          Result := '1.5';
        else
          Result := 'Unknown';
      end;
    //Ods 11
    1:
      case IndexStr(UpperCase(OdsMinorVersion), ['00', '01', '02']) of
        0:
          //Ods 11.0
          Result := '2.0';
        1:
          //Ods 11.1
          Result := '2.1';
        2:
          //Ods 11.2
          Result := '2.5';
        else
          Result := 'Unknown';
      end;
    2:
      //Ods 12
      Result := '3.0';
    3:
      //Ods 13
      Result := '4.0';
    else
      Result := 'Unknown';
    end;
  finally
    FileStream.Free;
  end;
end;

//M�todos de salvar ou carregar arquivos
class function TUtils.OpenFileAll(out FileName: string): boolean;
var
  OD: TFileOpenDialog;
begin
  OD := TFileOpenDialog.Create(nil);

  try
    with OD.FileTypes.Add do
    begin
      DisplayName := 'Todos os Arquivos';
      FileMask := '*';
    end;

    Result := OD.Execute;

    if Result then
      FileName := OD.FileName;
  finally
    FreeAndNil(OD);
  end;
end;

class function TUtils.OpenFile(DisplayName, FileMask: string; IncludeAllFiles: boolean;
out FileName: string): boolean;
var
  OD: TFileOpenDialog;
begin
  OD := TFileOpenDialog.Create(nil);

  try
    OD.FileTypes.Add;
    OD.FileTypes[0].DisplayName := DisplayName;
    OD.FileTypes[0].FileMask := FileMask;
    OD.DefaultExtension := ReplaceStr(ExtractFileExt(FileMask), '.', '');

    if IncludeAllFiles then
    begin
      with OD.FileTypes.Add do
      begin
        DisplayName := 'Todos os Arquivos';
        FileMask := '*';
      end;
    end;

    Result := OD.Execute;

    if Result then
      FileName := OD.FileName;
  finally
    FreeAndNil(OD);
  end;
end;

class function TUtils.OpenFolder(out FileName: string): boolean;
var
  OD: TFileOpenDialog;
begin
  OD := TFileOpenDialog.Create(nil);

  try
    OD.Options := OD.Options + [fdoPickFolders];

    Result := OD.Execute;

    if Result then
      FileName := OD.FileName;
  finally
    FreeAndNil(OD);
  end;
end;

class function TUtils.SaveFileAll(out FileName: string): boolean;
var
  SD: TFileSaveDialog;
begin
  SD := TFileSaveDialog.Create(nil);

  try
    SD.Options := SD.Options - [fdoPickFolders];

    with SD.FileTypes.Add do
    begin
      DisplayName := 'Todos os Arquivos';
      FileMask := '*';
    end;

    Result := SD.Execute;

    if Result then
      FileName := SD.FileName;
  finally
    FreeAndNil(SD);
  end;
end;

class function TUtils.SaveFile(DisplayName, FileMask: string; IncludeAllFiles: boolean;
out FileName: string): boolean;
var
  SD: TFileSaveDialog;
begin
  SD := TFileSaveDialog.Create(nil);

  try
    SD.Options := SD.Options - [fdoPickFolders];

    SD.FileTypes.Add;
    SD.FileTypes[0].DisplayName := DisplayName;
    SD.FileTypes[0].FileMask := FileMask;
    SD.DefaultExtension := ReplaceStr(ExtractFileExt(FileMask), '.', '');

    if IncludeAllFiles then
    begin
      with SD.FileTypes.Add do
      begin
        DisplayName := 'Todos os Arquivos';
        FileMask := '*';
      end;
    end;

    Result := SD.Execute;

    if Result then
      FileName := SD.FileName;
  finally
    FreeAndNil(SD);
  end;
end;

class function TUtils.SaveFolder(out FileName: string): boolean;
var
  SD: TFileSaveDialog;
begin
  SD := TFileSaveDialog.Create(nil);

  try
    SD.Options := SD.Options + [fdoPickFolders];

    Result := SD.Execute;

    if Result then
      FileName := SD.FileName;
  finally
    FreeAndNil(SD);
  end;
end;

end.
