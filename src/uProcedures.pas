unit uProcedures;

interface

uses
  Windows, Classes, SysUtils, ShellAPI, ShlObj, uObjects, Forms, MSHTML,
  UrlMon, activex, Variants, { Modules, } SharedTypes, puny, commctrl, comctrls,
  Graphics, Controls, acAlphaImageList, OverbyteIcsUrl, PluginApi;

const
  SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority = (Value: (0, 0, 0, 0, 0, 5));
  SECURITY_BUILTIN_DOMAIN_RID = $00000020;
  DOMAIN_ALIAS_RID_ADMINS = $00000220;

type
  TFileVersionInfo = record
    FileType, CompanyName, FileDescription, FileVersion, InternalName,
      LegalCopyRight, LegalTradeMarks, OriginalFileName, ProductName,
      ProductVersion, Comments, SpecialBuildStr, PrivateBuildStr,
      FileFunction: string;
    DebugBuild, PreRelease, SpecialBuild, PrivateBuild, Patched,
      InfoInferred: Boolean;
  end;

  tfvi = record
    versionms: Integer;
    versionms2: Integer;
    versionls: Integer;
    versionls2: Integer;
  end;

  TSearchRecW = record
    Time: Integer;
    Size: Integer;
    Attr: Integer;
    Name: widestring;
    ExcludeAttr: Integer;
    FindHandle: THandle;
    FindData: TWin32FindDataW;
  end;

function BytesToGigaBytes(Bytes: int64): string;
function BytesToMegaBytes(Bytes: int64): string;
function BytesToKiloBytes(Bytes: int64): string;
function BytesToText(Bytes: int64): String;
function GetFileVersion(FileName: String): String;
function BrowserFolder(Owner: THandle): String;
function CreateFileName(Url: String): String;
// function ExtractProgFileName(const AUrl: string): String;
function LocalAddress(Url: String): Boolean;
function ExtractAddress(Url: String): String;
// function ExtractUrlFileName(AUrl : String) : String;
function ExtractUrlFileName(const AUrl: string): string;
function GetFreeSpace(Disk: String): int64;
function IsRun: Boolean;
function GetTimeStr(Secs: Integer): String;
function RightFileName(const FileName: string): Boolean;
function CheckThreadIsAlive(Thread: TThread): Boolean;
function GetModuleFileNameStr(Instance: THandle): String;
function DelDir(dir: string): Boolean;
function MyRemoveDir(sDir: String): Boolean;
function StringToVersion(fvn: string): tfvi;
function StringToVersion2(fvn: string): tfvi;
function FileVersion(AFileName: string): string;
function ExtractCookie(Header: String): String;
function ProxyTypeToStr(ProxyType: TProxyMode): String;
function StrToProxyType(ProxyType: string): TProxyMode;
function AuthTypeInStr(AuthType: THttpServerAuthType): String;
function StrInAuthType(AuthType: string): THttpServerAuthType;
function SearchParam1(Page: String; Value: String; Plus: Integer): string;
function SearchParam2(Page: String; Value: String; Plus: Integer;
  Element: String; Minus: Integer): string;
function StartCreateProcess(const ApplicationName, CommandLine,
  CurrentDirectory: string; ShowMethod: Integer;
  Timeout: cardinal = INFINITE; LocalProcess: Boolean = true): Integer;
procedure GetAllLinks(HTMLCode: String; var lnk, txt: TStringList);
function IsAdmin: Boolean;
function DeterminePlugin2(const AUrl: String; const AGUID: TGUID; out Obj;
  out IndexPlugin: Integer): Boolean;
function WideStringToString(const ws: widestring; codePage: Word): AnsiString;
function StringToWideString(const s: AnsiString; codePage: Word): widestring;
function LinkToPunyCode(GetedLink: string; Domain: string): string;
procedure SaveColumnsOrdertoReg(lv: TListView);
procedure LoadColumnsOrderfromReg(lv: TListView);
procedure SaveImageListToFile(ImageList: TImageList; FileName: string);
procedure LoadImageListFromFile(ImageList: TImageList; FileName: string);
procedure SaveAlphaImageListToFile(AlphaImageList: TsAlphaImageList;
  FileName: string);
procedure LoadAlphaImageListFromFile(AlphaImageList: TsAlphaImageList;
  FileName: string);
function HashFromMagnet(Url: string): string;
function GetFormatEtc(fmt: TClipFormat): TFormatEtc;
function IsRightFormat(dataObj: IDataObject; fmt: TClipFormat): Boolean;
function GetText(const dataObj: IDataObject; const fmt: TClipFormat): string;
procedure GetFileList(const dataObj: IDataObject; const FileList: TStringList);

function FindNextW(var F: TSearchRecW): Integer;
function Tnt_FindNextFileW(hFindFile: THandle;
  var lpFindFileData: TWin32FindDataW): BOOL;
function FindFirstW(const Path: widestring; Attr: Integer;
  var F: TSearchRecW): Integer;
procedure FindCloseW(var F: TSearchRecW);
function FindMatchingFileW(var F: TSearchRecW): Integer;
function Tnt_FindFirstFileW(lpFileName: PWideChar;
  var lpFindFileData: TWin32FindDataW): THandle;
procedure _MakeWideWin32FindData(var WideFindData: TWin32FindDataW;
  AnsiFindData: TWIN32FindDataA);
function WStrPCopy(Dest: PWideChar; const Source: widestring): PWideChar;
function WStrLCopy(Dest, Source: PWideChar; MaxLen: cardinal): PWideChar;
function FormatData(s: String; i: Integer): String;
procedure EnableShutdown;
function AppVersion(const FileName: string): string;
function GetModulePath(const Module: HMODULE): string;
function FileSize(const aFilename: String): Int64;

ThreadVar CountValues: TGetCountValues;

implementation

uses uVarsLocaliz, Dialogs, uExtraData2, PluginManager;

////////////////////////////////////////////////////////////////////////////////

function FileSize(const aFilename: String): Int64;
  var
    info: TWin32FileAttributeData;
  begin
    result := -1;

    if NOT GetFileAttributesEx(PWideChar(aFileName), GetFileExInfoStandard, @info) then
      EXIT;

    result := Int64(info.nFileSizeLow) or Int64(info.nFileSizeHigh shl 32);
  end;

////////////////////////////////////////////////////////////////////////////////

function GetModulePath(const Module: HMODULE): string;
var
  L: Integer;
begin
  L := MAX_PATH + 1;
  SetLength(Result, L);
  {$IFDEF MSWINDOWS}
  L := Windows.GetModuleFileName(Module, Pointer(Result), L);
  {$ENDIF MSWINDOWS}
  {$IFDEF UNIX}
  {$IFDEF FPC}
  L := 0; // FIXME
  {$ELSE ~FPC}
  L := GetModuleFileName(Module, Pointer(Result), L);
  {$ENDIF ~FPC}
  {$ENDIF UNIX}
  SetLength(Result, L);
end;

////////////////////////////////////////////////////////////////////////////////

function AppVersion(const FileName: string): string;
var
  dwHandle: THandle;
  dwSize: DWORD;
  lpData, lpData2: Pointer;
  uiSize: UINT;
begin
  Result := '';
  dwSize := GetFileVersionInfoSize(PChar(FileName), dwSize);
  if dwSize <> 0 then
  begin
    GetMem(lpData, dwSize);
    if GetFileVersionInfo(PChar(FileName), dwHandle, dwSize, lpData) then
    begin
      uiSize := Sizeof(TVSFixedFileInfo);
      VerQueryValue(lpData, '\', lpData2, uiSize);
      with PVSFixedFileInfo(lpData2)^ do
        Result := Format('%d.%02d.%02d.%02d', [HiWord(dwProductVersionMS),
          LoWord(dwProductVersionMS), HiWord(dwProductVersionLS),
          LoWord(dwProductVersionLS)]);
    end;
    FreeMem(lpData, dwSize);
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

procedure EnableShutdown;
var
  hProc, hToken: cardinal;
  mLUID: TLargeInteger;
  mPriv, mNewPriv: TOKEN_PRIVILEGES;
begin
  hProc := GetCurrentProcess;
  OpenProcessToken(hProc, TOKEN_ADJUST_PRIVILEGES + TOKEN_QUERY, hToken);
  LookupPrivilegeValue('', 'SeShutdownPrivilege', mLUID);
  mPriv.PrivilegeCount := 1;
  mPriv.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
  mPriv.Privileges[0].Luid := mLUID;
  mNewPriv.PrivilegeCount := 0;
  AdjustTokenPrivileges(hToken, false, mPriv, 4 + 12 * mPriv.PrivilegeCount,
    mNewPriv, mNewPriv.PrivilegeCount);
end;

/// /////////////////////////////////////////////////////////////////////////////

function FormatData(s: String; i: Integer): String;
begin
  Result := FloatToStr(Round(StrToFloat(s) * exp(i * ln(10))) /
      (exp(i * ln(10))));
end;

/// /////////////////////////////////////////////////////////////////////////////

function WStrLCopy(Dest, Source: PWideChar; MaxLen: cardinal): PWideChar;
var
  Count: cardinal;
begin
  // copies a specified maximum number of characters from Source to Dest
  Result := Dest;
  Count := 0;
  While (Count < MaxLen) and (Source^ <> #0) do
  begin
    Dest^ := Source^;
    Inc(Source);
    Inc(Dest);
    Inc(Count);
  end;
  Dest^ := #0;
end;

function WStrPCopy(Dest: PWideChar; const Source: widestring): PWideChar;
begin
  Result := WStrLCopy(Dest, PWideChar(Source), length(Source));
end;

procedure _MakeWideWin32FindData(var WideFindData: TWin32FindDataW;
  AnsiFindData: TWIN32FindDataA);
begin
  CopyMemory(@WideFindData, @AnsiFindData,
    Integer(@WideFindData.cFileName) - Integer(@WideFindData));
  WStrPCopy(WideFindData.cFileName, AnsiFindData.cFileName);
  WStrPCopy(WideFindData.cAlternateFileName, AnsiFindData.cAlternateFileName);
end;

function Tnt_FindFirstFileW(lpFileName: PWideChar;
  var lpFindFileData: TWin32FindDataW): THandle;
var
  Ansi_lpFindFileData: TWIN32FindDataA;
begin
  if (Win32Platform = VER_PLATFORM_WIN32_NT) then
    Result := FindFirstFileW
    { TNT-ALLOW FindFirstFileW } (lpFileName, lpFindFileData)
  else
  begin
    Result := FindFirstFileA
    { TNT-ALLOW FindFirstFileA } (PAnsiChar(AnsiString(lpFileName)),
      Ansi_lpFindFileData);
    if Result <> INVALID_HANDLE_VALUE then
      _MakeWideWin32FindData(lpFindFileData, Ansi_lpFindFileData);
  end;
end;

function FindMatchingFileW(var F: TSearchRecW): Integer;
var
  LocalFileTime: TFileTime;
begin
  with F do
  begin
    while FindData.dwFileAttributes and ExcludeAttr <> 0 do
      if not Windows.FindNextFileW(FindHandle, FindData) then
      begin
        Result := GetLastError;
        exit;
      end;
    FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
    FileTimeToDosDateTime(LocalFileTime, LongRec(Time).Hi, LongRec(Time).Lo);
    Size := FindData.nFileSizeLow;
    Attr := FindData.dwFileAttributes;
    Name := FindData.cFileName;
  end;
  Result := 0;
end;

procedure FindCloseW(var F: TSearchRecW);
begin
  if F.FindHandle <> INVALID_HANDLE_VALUE then
    Windows.FindClose(F.FindHandle);
end;

function FindFirstW(const Path: widestring; Attr: Integer;
  var F: TSearchRecW): Integer;
const
  faSpecial = faHidden or faSysFile or faVolumeID or faDirectory;
begin
  F.ExcludeAttr := not Attr and faSpecial;
  F.FindHandle := Tnt_FindFirstFileW(PWideChar(Path), F.FindData);
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    Result := FindMatchingFileW(F);
    if Result <> 0 then
      FindCloseW(F);
  end
  else
    Result := GetLastError;
end;

function Tnt_FindNextFileW(hFindFile: THandle;
  var lpFindFileData: TWin32FindDataW): BOOL;
var
  Ansi_lpFindFileData: TWIN32FindDataA;
begin
  if (Win32Platform = VER_PLATFORM_WIN32_NT) then
    Result := FindNextFileW
    { TNT-ALLOW FindNextFileW } (hFindFile, lpFindFileData)
  else
  begin
    Result := FindNextFileA
    { TNT-ALLOW FindNextFileA } (hFindFile, Ansi_lpFindFileData);
    if Result then
      _MakeWideWin32FindData(lpFindFileData, Ansi_lpFindFileData);
  end;
end;

function FindNextW(var F: TSearchRecW): Integer;
begin
  if Tnt_FindNextFileW(F.FindHandle, F.FindData) then
    Result := FindMatchingFileW(F)
  else
    Result := GetLastError;
end;

/// /////////////////////////////////////////////////////////////////////////////

function GetFormatEtc(fmt: TClipFormat): TFormatEtc;
begin
  Result.cfFormat := fmt;
  Result.ptd := nil;
  Result.dwAspect := DVASPECT_CONTENT;
  Result.lindex := -1;
  Result.tymed := TYMED_HGLOBAL;
end;

function IsRightFormat(dataObj: IDataObject; fmt: TClipFormat): Boolean;
begin
  Result := dataObj.QueryGetData(GetFormatEtc(fmt)) = S_OK;
end;

function GetText(const dataObj: IDataObject; const fmt: TClipFormat): string;
var
  Medium: TStgMedium;
  PText: PChar;
begin
  if dataObj.GetData(GetFormatEtc(fmt), Medium) = S_OK then
  begin
    Assert(Medium.tymed = TYMED_HGLOBAL);
    try
      PText := GlobalLock(Medium.hGlobal);
      try
        Result := PText;
      finally
        GlobalUnlock(Medium.hGlobal);
      end;
    finally
      ReleaseStgMedium(Medium);
    end;
  end
  else
    Result := '';
end;

procedure GetFileList(const dataObj: IDataObject; const FileList: TStringList);
var
  FmtEtc: TFormatEtc;
  Medium: TStgMedium;
  FileCount: Integer;
  i: Integer;
  FileNameLength: Integer;
  FileName: string;
begin
  FmtEtc.cfFormat := CF_HDROP;
  FmtEtc.ptd := nil;
  FmtEtc.dwAspect := DVASPECT_CONTENT;
  FmtEtc.lindex := -1;
  FmtEtc.tymed := TYMED_HGLOBAL;
  if dataObj.GetData(FmtEtc, Medium) = S_OK then
    try
      try
        FileCount := DragQueryFile(Medium.hGlobal, $FFFFFFFF, nil, 0);
        for i := 0 to FileCount - 1 do
        begin
          FileNameLength := DragQueryFile(Medium.hGlobal, i, nil, 0);
          SetLength(FileName, FileNameLength);
          DragQueryFile(Medium.hGlobal, i, PChar(FileName), FileNameLength + 1);
          FileList.Add(FileName);
        end;
      finally
        DragFinish(Medium.hGlobal);
      end;
    finally
      ReleaseStgMedium(Medium);
    end;
end;

/// /////////////////////////////////////////////////////////////////////////////

function explode(str: string; separator: string): targuments;
var
  previouslen, ind: Integer;
begin

  if pos('&', str) = 0 then
  begin
    SetLength(Result, 1);
    Result[0] := str;
    exit;
  end;

  previouslen := 1;
  while (length(str) > 0) do
  begin

    SetLength(Result, previouslen);

    ind := pos('&', str);
    if ind <> 0 then
    begin
      Result[previouslen - 1] := copy(str, 1, ind - 1);
      delete(str, 1, ind);
    end
    else
    begin
      Result[previouslen - 1] := str;
      break;
    end;

    Inc(previouslen);
  end;

end;

function isxdigit(Ch: char): Boolean;
begin
  Result := (Ch in ['0' .. '9']) or (Ch in ['a' .. 'z']) or
    (Ch in ['A' .. 'Z']);
end;

function HexToInt(const HexString: String): cardinal;
var
  sss: string;
  i: Integer;
begin
  Result := 0;

  try

    if length(HexString) = 0 then
      exit;
    for i := 1 to length(HexString) do
      if not isxdigit(HexString[i]) then
        exit;

  except
  end;
  sss := '$' + HexString;
  Result := StrToIntdef(sss, 0);

end;

function URLdecode(stringa: string): string;
{ Found or not found that's the question }
var
  i: Integer;
begin
  try
    Result := '';
    i := 1;
    repeat
      if i > length(stringa) then
        break;
      if stringa[i] = '%' then
      begin
        try
          Result := Result + chr(HexToInt(copy(stringa, i + 1, 2)));
          Inc(i, 3);
        except
        end;
      end
      else
      begin
        Result := Result + stringa[i];
        Inc(i);
      end;
    until (not true);

  except
    Result := '';
  end;
end;

function HashFromMagnet(Url: string): string;
var
  hash_sha1s, fname, estensione, titles: string;
  // down:tdownload;
  thearr: targuments;
  i: Integer;
  str, variable, argument: string;
  tracker, hash, suggestedName: string;
begin
  Result := '';
  {
    Here is a description of the Magnet Urn:
    xt - the fingerprint of a file expressed as a sha1 hash
    dn - the name of the file
    xs - the source of a file, potentially on a P2P network or webserver
    as - an alternate (or second) source for the file if available
    }

  try

    // hash_sha1:=copy(url,pos('xt=urn:sha1:',lowercase(url))+12,32);
    // if pos('&',hash_sha1)<>0 then delete(hash_sha1,pos('&',hash_sha1),length(hash_sha1));
    if pos('xt=urn:btih:', lowercase(Url)) <> 0 then
    begin

      if pos('magnet:?', lowercase(Url)) = 1 then
        delete(Url, 1, 8); // strip magnet:?

      tracker := '';
      hash := '';
      suggestedName := '';
      thearr := explode(Url, '&');
      for i := 0 to length(thearr) - 1 do
      begin
        str := thearr[i];
        variable := copy(str, 1, pos('=', str) - 1);
        argument := URLdecode(copy(str, pos('=', str) + 1, length(str)));
        if variable = 'xt' then
          hash := copy(argument, 10, length(argument))
        else if variable = 'dn' then
          suggestedName := argument
        else if variable = 'tr' then
          tracker := argument;

        thearr[i] := '';
      end;

      // bittorrentUtils.loadmagnetTorrent(hash,suggestedName,tracker,id);

      Result := hash;

      SetLength(thearr, 0);
    end;
  except
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

procedure SaveAlphaImageListToFile(AlphaImageList: TsAlphaImageList;
  FileName: string);
var
  B: TBitmap;
  i: Integer;
  s: TFileStream;
begin
  s := TFileStream.Create(FileName, fmCreate);
  try
    for i := 0 to AlphaImageList.Count - 1 do
    begin
      B := TBitmap.Create;
      try
        AlphaImageList.GetBitmap32(i, B);
        B.SaveToStream(s);
      finally
        B.Free;
      end;
    end;
  finally
    s.Free;
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

procedure LoadAlphaImageListFromFile(AlphaImageList: TsAlphaImageList;
  FileName: string);
var
  B: TBitmap;
  s: TFileStream;
begin
  s := TFileStream.Create(FileName, fmOpenRead);
  try
    while s.Position < s.Size do
    begin
      B := TBitmap.Create;
      try
        B.LoadFromStream(s);
        AlphaImageList.Add(B, nil);
      finally
        B.Free;
      end;
    end;
  finally
    s.Free;
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

procedure SaveImageListToFile(ImageList: TImageList; FileName: string);
var
  B: TBitmap;
  i: Integer;
  s: TFileStream;
begin
  s := TFileStream.Create(FileName, fmCreate);
  try
    for i := 0 to ImageList.Count - 1 do
    begin
      B := TBitmap.Create;
      try
        ImageList.GetBitmap(i, B);
        B.SaveToStream(s);
      finally
        B.Free;
      end;
    end;
  finally
    s.Free;
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

procedure LoadImageListFromFile(ImageList: TImageList; FileName: string);
var
  B: TBitmap;
  s: TFileStream;
begin
  s := TFileStream.Create(FileName, fmOpenRead);
  try
    while s.Position < s.Size do
    begin
      B := TBitmap.Create;
      try
        B.LoadFromStream(s);
        ImageList.Add(B, nil);
      finally
        B.Free;
      end;
    end;
  finally
    s.Free;
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

function CompareByDisplayIndexSortList(Item1: Pointer; Item2: Pointer): Integer;
var
  customer1, customer2: TColumnList;
begin
  customer1 := TColumnList(Item1);
  customer2 := TColumnList(Item2);

  // “еперь сравнение строк
  if customer1.DisplayIndex > customer2.DisplayIndex then
    Result := 1
  else if customer1.DisplayIndex = customer2.DisplayIndex then
    Result := 0
  else
    Result := -1;
end;

function CompareByIndexSortList(Item1: Pointer; Item2: Pointer): Integer;
var
  customer1, customer2: TColumnList;
begin
  customer1 := TColumnList(Item1);
  customer2 := TColumnList(Item2);

  // “еперь сравнение строк
  if customer1.Index > customer2.Index then
    Result := 1
  else if customer1.Index = customer2.Index then
    Result := 0
  else
    Result := -1;
end;

procedure SaveColumnsOrdertoReg(lv: TListView);
var
  i, k: Integer;
  lpiArray: array [0 .. 128] of Integer;
  ColumnListData: TColumnList;
  TempColumnListData: TColumnList;
  TempColumnList: TList;
begin
  // with OptionsDFA.ColumnList.LockList do
  // try
  // for i := 0 to Count - 1 do//for i := Count - 1 downto 0 do
  // begin
  // ColumnListData := Items[i];
  // Sort(CompareByDisplayIndexSortList);
  // end;
  // finally
  // OptionsDFA.ColumnList.UnLockList
  // end;

  TempColumnList := TList.Create;
  with OptionsDFA.ColumnList.LockList do
    try
      for i := 0 to Count - 1 do // for i := Count - 1 downto 0 do
      begin
        ColumnListData := Items[i];
        TempColumnListData := TColumnList.Create;
        TempColumnListData.WidthColumn := ColumnListData.WidthColumn;
        TempColumnListData.Index := ColumnListData.Index;
        TempColumnListData.DisplayIndex := ColumnListData.DisplayIndex;
        TempColumnListData.Visible := ColumnListData.Visible;
        TempColumnList.Add(TempColumnListData);
      end;
    finally
      OptionsDFA.ColumnList.UnLockList
    end;

  SendMessage(lv.Handle, LVM_GETCOLUMNORDERARRAY, lv.columns.Count,
    Integer(@lpiArray));
  lv.Invalidate;

  try
    for i := 0 to lv.columns.Count - 1 do
    begin
      with OptionsDFA.ColumnList.LockList do
        try
          for k := 0 to Count - 1 do
          begin
            if i = k then
            begin
              ColumnListData := Items[k];
              ColumnListData.Index := i;
              ColumnListData.DisplayIndex := lpiArray[i];
            end;
          end;
        finally
          OptionsDFA.ColumnList.UnLockList;
        end;
    end;
  except
  end;

  with OptionsDFA.ColumnList.LockList do
    try
      for k := 0 to Count - 1 do
      begin
        ColumnListData := Items[k];
        for i := 0 to TempColumnList.Count - 1 do
        begin
          if ColumnListData.DisplayIndex = TColumnList(TempColumnList[i])
            .DisplayIndex then
          begin
            ColumnListData.Visible := TColumnList(TempColumnList[i]).Visible;
            ColumnListData.WidthColumn := TColumnList(TempColumnList[i])
              .WidthColumn;
          end;
        end;
      end;
    finally
      OptionsDFA.ColumnList.UnLockList;
      TempColumnList.Free;
    end;

  // with OptionsDFA.ColumnList.LockList do
  // try
  // for i := 0 to Count - 1 do//for i := Count - 1 downto 0 do
  // begin
  // ColumnListData := Items[i];
  // Sort(CompareByIndexSortList);
  // end;
  // finally
  // OptionsDFA.ColumnList.UnLockList
  // end;
end;

procedure LoadColumnsOrderfromReg(lv: TListView);
var
  i, k: Integer;
  TempVal: Integer;
  lpiArray: array [0 .. 128] of Integer;
  ColumnListData: TColumnList;
begin
  for i := 0 to lv.columns.Count - 1 do
  begin
    with OptionsDFA.ColumnList.LockList do
      try
        for k := 0 to Count - 1 do
        begin
          if i = k then
          begin
            ColumnListData := Items[k];
            TempVal := ColumnListData.DisplayIndex;
          end;
        end;
      finally
        OptionsDFA.ColumnList.UnLockList;
      end;

    if TempVal >= 0 then
      lpiArray[i] := TempVal
    else
      exit;
  end;

  SendMessage(lv.Handle, LVM_SETCOLUMNORDERARRAY, lv.columns.Count,
    Integer(@lpiArray));
  lv.Invalidate;
end;

/// /////////////////////////////////////////////////////////////////////////////

function LinkToPunyCode(GetedLink: string; Domain: string): string;
var
  i: Integer;
  WideDomain: widestring;
  DomainList: TStringList;
  WidePunyDomain: widestring;
  Added: Boolean;
  DomainNext: string;
  pc: TPunyClass;
  PunyDomain: string;
  Param1: Integer;
  find: Boolean;
begin
  Result := '';
  DomainList := TStringList.Create;
  DomainNext := Domain;
  Added := false;
  repeat
    find := false;
    Param1 := pos('.', DomainNext);
    if (Param1 > 0) then
    begin
      find := true;
      try
      DomainList.Add(copy(DomainNext, 0, Param1 - 1));
      DomainList.Add('.');
      DomainNext := copy(DomainNext, Param1 + 1, 1000000);
      except
      end;
    end;
  until find = false;

  if (trim(DomainNext) <> '') and (Added = false) then
  begin
    // Added := true;
    DomainList.Add(DomainNext);
  end;

  // for I := 0 to DomainList.Count - 1 do
  // begin
  // InfoLog.Write(DomainList[I]);
  // end;

  PunyDomain := '';
  for i := 0 to DomainList.Count - 1 do
  begin
    if trim(DomainList[i]) <> '' then
      if (DomainList[i] = '.') or (DomainList[i] = 'www') then
      begin
        PunyDomain := PunyDomain + DomainList[i];
      end
      else
      begin
        WideDomain := StringToWideString(DomainList[i], 1251);

        pc := TPunyClass.Create;
        try
          WidePunyDomain := pc.Encode(WideDomain);
        finally
          pc.Free;
        end;

        DomainList[i] := WideStringToString(WidePunyDomain, 1251);
        PunyDomain := PunyDomain + 'xn--' + DomainList[i];
      end;
  end;
  Result := StringReplace(GetedLink, Domain, PunyDomain, [rfReplaceAll,
    rfIgnoreCase]);

  DomainList.Free;
end;

/// /////////////////////////////////////////////////////////////////////////////

function WideStringToString(const ws: widestring; codePage: Word): AnsiString;
var
  l: Integer;
begin
  if ws = '' then
    Result := ''
  else
  begin
    l := WideCharToMultiByte(codePage,
      WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
      @ws[1], -1, nil, 0, nil, nil);
    SetLength(Result, l - 1);
    if l > 1 then
      WideCharToMultiByte(codePage,
        WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
        @ws[1], -1, @Result[1], l - 1, nil, nil);
  end;
end; { WideStringToString }

{ :Converts Ansi string to Unicode string using specified code page.
  @param   s        Ansi string.
  @param   codePage Code page to be used in conversion.
  @returns Converted wide string.
  }

function StringToWideString(const s: AnsiString; codePage: Word): widestring;
var
  l: Integer;
begin
  if s = '' then
    Result := ''
  else
  begin
    l := MultiByteToWideChar(codePage, MB_PRECOMPOSED, PAnsiChar(@s[1]), -1,
      nil, 0);
    SetLength(Result, l - 1);
    if l > 1 then
      MultiByteToWideChar(codePage, MB_PRECOMPOSED, PAnsiChar(@s[1]), -1,
        PWideChar(@Result[1]), l - 1);
  end;
end; { StringToWideString }

/// /////////////////////////////////////////////////////////////////////////////

function SearchCoincidence(Link: string; Domains: string): Boolean;
var
  DomainsList: TStringList;
  F: Integer;
  SearchSubDomain: Boolean;
  SubDomain: string;
  a, B, c, e, g: string;
  DomainFromList: string;
  DomainLink: string;
begin
  Result := false;
  DomainsList := TStringList.Create;
  try
    DomainsList.Delimiter := ' ';
    DomainsList.QuoteChar := '|';
    DomainsList.DelimitedText := Domains;

    for F := 0 to DomainsList.Count - 1 do
    begin

      SearchSubDomain := false;
      if pos('*', DomainsList[F]) = 1 then
      begin
        SearchSubDomain := true;
        SubDomain := copy(DomainsList[F], 2, 1000000);
        // InfoLog.Write(SubDomain);
      end;
      if SearchSubDomain then
      begin
        ParseUrl(DomainsList[F], a, B, c, DomainFromList, e, g);
        ParseUrl(Link, a, B, c, DomainLink, e, g);
        // showmessage(DomainLink);
        // showmessage(DomainFromList);
        // if (ExtractAddress(DomainsList[f])=ExtractAddress(Link))
        // or (pos(SubDomain,ExtractAddress(Link))>0)
        if (DomainFromList = DomainLink) or
          ('www.' + DomainFromList = DomainLink) or
          (pos(SubDomain, DomainLink) > 0) then
        begin
          Result := true;
          break;
        end
        else
          SearchSubDomain := false;
      end
      else
      begin
        ParseUrl(DomainsList[F], a, B, c, DomainFromList, e, g);
        ParseUrl(Link, a, B, c, DomainLink, e, g);
        // showmessage(DomainLink);
        // showmessage(DomainFromList);
        // if ExtractAddress(DomainsList[f])=ExtractAddress(Link) then
        if (DomainFromList = DomainLink) or
          ('www.' + DomainFromList = DomainLink) then
        begin
          Result := true;
          break;
        end;
      end;

      // if ExtractAddress(DomainsList[f])=ExtractAddress(Link) then
      // begin result:=true; break; end;

    end;
  finally
    DomainsList.Free;
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

function DeterminePlugin2(const AUrl: String; const AGUID: TGUID; out Obj;
  out IndexPlugin: Integer): Boolean;
var
  X: Integer;
  Plugin: IServicePlugin;
begin
  Result := false;
  for X := 0 to Plugins.Count - 1 do
  begin
    if (Supports(Plugins[X], AGUID, Plugin)) then
      if SearchCoincidence(AUrl, Plugin.GetServices) then
      begin
        Supports(Plugins[X], AGUID, Obj);
        IndexPlugin := X;
        Result := true;
        break;
      end;
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

function IsAdmin: Boolean;
var
  hAccessToken: THandle;
  ptgGroups: PTokenGroups;
  dwInfoBufferSize: DWORD;
  psidAdministrators: PSID;
  X: Integer;
  bSuccess: BOOL;
begin
  Result := false;
  bSuccess := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, true,
    hAccessToken);
  if not bSuccess then
  begin
    if GetLastError = ERROR_NO_TOKEN then
      bSuccess := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY,
        hAccessToken);
  end;
  if bSuccess then
  begin
    GetMem(ptgGroups, 1024);
    bSuccess := GetTokenInformation(hAccessToken, TokenGroups, ptgGroups, 1024,
      dwInfoBufferSize);
    CloseHandle(hAccessToken);
    if bSuccess then
    begin
      AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2,
        SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0,
        psidAdministrators);
{$R-}
      for X := 0 to ptgGroups.GroupCount - 1 do
        if EqualSid(psidAdministrators, ptgGroups.Groups[X].Sid) then
        begin
          Result := true;
          break;
        end;
{$R+}
      FreeSid(psidAdministrators);
    end;
    FreeMem(ptgGroups);
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

procedure GetAllLinks(HTMLCode: String; var lnk, txt: TStringList);
var
  s: string;
  i: Integer;
  Doc: IHTMLDocument2;
  v: OleVariant;
  DocA: IHTMLElementCollection;
  DocElement: IHtmlElement;
begin
  Doc := coHTMLDocument.Create as IHTMLDocument2;

  v := VarArrayCreate([0, 0], VarVariant);
  v[0] := HTMLCode;
  Doc.Write(PSafeArray(TVarData(v).VArray));

  // showmessage(Doc.domain);

  DocA := Doc.All.Tags('A') as IHTMLElementCollection;
  For i := 0 to DocA.length - 1 do
  // For i:=0 to Doc.links.length-1 do
  begin
    DocElement := DocA.Item(i, 0) as IHtmlElement;
    // DocElement := Doc.links.Item(i, 0) as IHtmlElement;
    lnk.Add(DocElement.innerHTML);
    txt.Add(DocElement.getAttribute('href', 0));
  end;

end;

/// /////////////////////////////////////////////////////////////////////////////

function StartCreateProcess(const ApplicationName, CommandLine,
  CurrentDirectory: string; ShowMethod: Integer;
  Timeout: cardinal = INFINITE; LocalProcess: Boolean = true): Integer;
var
  Si: StartupInfo;
  Prin: TProcessInformation;
  Data: cardinal;
  P11, P22, P33: PChar;
begin
  if (ApplicationName = '') and (CommandLine = '') then
  begin
    Result := -3;
    exit;
  end;
  // ошибочно заданные параметры
  ZeroMemory(@Si, Sizeof(Si));
  Si.cb := Sizeof(Si);
  Si.dwflags := STARTF_USESHOWWINDOW;
  Si.wShowWindow := ShowMethod;
  if ApplicationName <> '' then
  begin // если им€ приложени€ задано
    GetMem(P11, 1024);
    StrPLCopy(P11, ApplicationName, 1024);
  end
  else
    P11 := nil;
  if CommandLine <> '' then
  begin // если командна€ строка задана
    GetMem(P22, 1024);
    StrPLCopy(P22, CommandLine, 1024);
  end
  else
    P22 := nil;
  if CurrentDirectory <> '' then
  begin // если текуща€ директори€ задана
    GetMem(P33, 1024);
    StrPLCopy(P33, CurrentDirectory, 1024);
  end
  else
    P33 := nil;
  if CreateProcess(P11, P22, nil, nil, false,
    { CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS } 0, nil, P33, Si, Prin) then
    Result := 0
  else
    Result := -1;
  if P11 <> nil then
    FreeMem(P11, 1024); // удалить лишние данные
  if P22 <> nil then
    FreeMem(P22, 1024);
  if P33 <> nil then
    FreeMem(P33, 1024);
  if Result < 0 then
    exit;
  if Prin.dwProcessId = 0 then
  begin
    Result := -5;
    exit;
  end;
  if Timeout = 0 then
  begin
    Result := 0;
    exit;
  end; // не ждать окончани€ работы
  if LocalProcess then
  begin
    // while(MsgWaitForMultipleObjects(1,Prin.hProcess,false,Timeout,QS_ALLINPUT)=WAIT_OBJECT_0+1)do
    // Application.ProcessMessages;
    while (GetExitCodeProcess(Prin.hProcess, Data) and (Data = STILL_ACTIVE)) do
    begin
      Application.ProcessMessages;
      sleep(100);
    end;
  end
  else
    WaitForSingleObject(Prin.hProcess, Timeout);
  if (WaitForSingleObject(Prin.hProcess, 0) <> WAIT_OBJECT_0) then
  begin
    TerminateProcess(Prin.hProcess, cardinal(-1));
    Result := -1;
  end
  else
  begin
    GetExitCodeProcess(Prin.hProcess, Data);
    Result := Data;
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

function AuthTypeInStr(AuthType: THttpServerAuthType): String;
begin
  if AuthType = httpAuthNoneType then
    Result := 'httpAuthNone';
  if AuthType = httpAuthBasicType then
    Result := 'httpAuthBasic';
  if AuthType = httpAuthNtlmType then
    Result := 'httpAuthNtlm';
  if AuthType = httpAuthDigestType then
    Result := 'httpAuthDigest';
end;

function StrInAuthType(AuthType: string): THttpServerAuthType;
begin
  if AuthType = 'httpAuthNone' then
    Result := httpAuthNoneType;
  if AuthType = 'httpAuthBasic' then
    Result := httpAuthBasicType;
  if AuthType = 'httpAuthNtlm' then
    Result := httpAuthNtlmType;
  if AuthType = 'httpAuthDigest' then
    Result := httpAuthDigestType;
end;

function ProxyTypeToStr(ProxyType: TProxyMode): String;
begin
  if ProxyType = pmProxyNone then
    Result := 'pmProxyNone';
  if ProxyType = pmProxyHttp then
    Result := 'pmProxyHttp';
  if ProxyType = pmProxySocks4 then
    Result := 'pmProxySocks4';
  if ProxyType = pmProxySocks5 then
    Result := 'pmProxySocks5';
  if ProxyType = pmProxyFtp then
    Result := 'pmProxyFtp';
end;

function StrToProxyType(ProxyType: string): TProxyMode;
begin
  if ProxyType = 'pmProxyNone' then
    Result := pmProxyNone;
  if ProxyType = 'pmProxyHttp' then
    Result := pmProxyHttp;
  if ProxyType = 'pmProxySocks4' then
    Result := pmProxySocks4;
  if ProxyType = 'pmProxySocks5' then
    Result := pmProxySocks5;
  if ProxyType = 'pmProxyFtp' then
    Result := pmProxyFtp;
end;

function SearchParam1(Page: String; Value: String; Plus: Integer): string;
var
  nBegin: Integer;
begin
  nBegin := pos(AnsiLowerCase(Value), AnsiLowerCase(Page));
  if nBegin <> 0 then
    Result := copy(Page, nBegin + Plus, 1000000)
  else
    Result := '';
end;

function SearchParam2(Page: String; Value: String; Plus: Integer;
  Element: String; Minus: Integer): string;
var
  nBegin, nEnd: Integer;
begin
  nBegin := pos(AnsiLowerCase(Value), AnsiLowerCase(Page));
  if nBegin <> 0 then
  begin
    Page := copy(Page, nBegin + Plus, 1000000);
    nEnd := pos(AnsiLowerCase(Element), AnsiLowerCase(Page));
    Result := copy(Page, 1, nEnd - Minus);
  end
  else
    Result := '';
end;

function ExtractCookie(Header: String): String;
var
  BeginCookie: Integer;
  EndCookie: Integer;
  CookieList: TStringList;
  Cookie: string;
begin
  CookieList := TStringList.Create;
  try
    repeat
      BeginCookie := pos('Set-Cookie:', Header);
      if BeginCookie > 0 then
      begin
        try
         Header := trim(copy(Header, BeginCookie + 11, 1000000));
         EndCookie := pos(';', Header);
        except
        end;
        if EndCookie > 0 then
        begin
          try
            Cookie := trim(copy(Header, 1, EndCookie - 1));
            CookieList.Add(Cookie);
          except
          end;
        end;
      end;
    until BeginCookie = 0;
  finally
    Result := CookieList.Text;
    CookieList.Free;
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

function FileVersion(AFileName: string): string;
var
  szName: array [0 .. 255] of char;
  P: Pointer;
  Value: Pointer;
  Len: UINT;
  GetTranslationString: string;
  FFileName: PChar;
  FValid: Boolean;
  FSize: DWORD;
  FHandle: DWORD;
  FBuffer: PChar;
begin
  try
    FFileName := StrPCopy(StrAlloc(length(AFileName) + 1), AFileName);
    FValid := false;
    FSize := GetFileVersionInfoSize(FFileName, FHandle);
    if FSize > 0 then
      try
        GetMem(FBuffer, FSize);
        FValid := GetFileVersionInfo(FFileName, FHandle, FSize, FBuffer);
      except
        FValid := false;
        raise ;
      end;
    Result := '';
    if FValid then
      VerQueryValue(FBuffer, '\VarFileInfo\Translation', P, Len)
    else
      P := nil;
    if P <> nil then
      GetTranslationString := IntToHex(MakeLong(HiWord(Longint(P^)),
          LoWord(Longint(P^))), 8);
    if FValid then
    begin
      StrPCopy(szName,
        '\StringFileInfo\' + GetTranslationString + '\FileVersion');
      if VerQueryValue(FBuffer, szName, Value, Len) then
        Result := StrPas(PChar(Value));
    end;
  finally
    try
      if FBuffer <> nil then
        FreeMem(FBuffer, FSize);
    except
    end;
    try
      StrDispose(FFileName);
    except
    end;
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

function StringToVersion(fvn: string): tfvi;
var
  hw, lw: Word;
  e: Integer;
  sep: string;

begin
  Result.versionms := -1;
  Result.versionls := -1;

  sep := '';
  if pos('.', fvn) > 0 then
    sep := '.';
  if pos(',', fvn) > 0 then
    sep := ',';

  if pos(sep, fvn) > 0 then
  begin
    Val(copy(fvn, 1, pos(sep, fvn) - 1), hw, e);
    system.delete(fvn, 1, pos(sep, fvn));

    if (pos(sep, fvn) > 0) and (e = 0) then
    begin
      Val(copy(fvn, 1, pos(sep, fvn) - 1), lw, e);
      Result.versionms := MakeLong(lw, hw);
      system.delete(fvn, 1, pos(sep, fvn));
      if (pos(sep, fvn) > 0) and (e = 0) then
      begin
        Val(copy(fvn, 1, pos(sep, fvn) - 1), hw, e);
        system.delete(fvn, 1, pos(sep, fvn));
        Val(fvn, lw, e);
        if e = 0 then
          Result.versionls := MakeLong(lw, hw);
      end
      else
      begin
        Val(fvn, hw, e);
        Result.versionls := MakeLong(0, hw);
      end;
    end
    else
    begin
      Val(fvn, lw, e);
      Result.versionms := MakeLong(lw, hw);
      Result.versionls := MakeLong(0, 0);
    end;
  end
  else
  begin
    Val(fvn, hw, e);
    if (e = 0) then
    begin
      Result.versionms := MakeLong(0, hw);
      Result.versionls := MakeLong(0, 0);
    end;
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

function StringToVersion2(fvn: string): tfvi;
var
  hw, lw: Word;
  e: Integer;
  sep: string;

begin
  Result.versionms := -1;
  Result.versionms2 := -1;
  Result.versionls := -1;
  Result.versionls2 := -1;

  sep := '';
  if pos('.', fvn) > 0 then
    sep := '.';
  if pos(',', fvn) > 0 then
    sep := ',';

  if pos(sep, fvn) > 0 then
  begin
    Val(copy(fvn, 1, pos(sep, fvn) - 1), hw, e);
    system.delete(fvn, 1, pos(sep, fvn));

    if (pos(sep, fvn) > 0) and (e = 0) then
    begin
      Val(copy(fvn, 1, pos(sep, fvn) - 1), lw, e);
      // Result.VersionMS := makelong(lw,hw);
      Result.versionms := hw;
      Result.versionms2 := lw;
      system.delete(fvn, 1, pos(sep, fvn));
      if (pos(sep, fvn) > 0) and (e = 0) then
      begin
        Val(copy(fvn, 1, pos(sep, fvn) - 1), hw, e);
        system.delete(fvn, 1, pos(sep, fvn));
        Val(fvn, lw, e);
        if e = 0 then
          // Result.VersionLS2 := makelong(lw,hw);
          Result.versionls := hw;
        Result.versionls2 := lw;
      end
      else
      begin
        Val(fvn, hw, e);
        // Result.VersionLS  := makelong(0,hw);
        Result.versionls := hw;
        Result.versionls2 := 0;
      end;
    end
    else
    begin
      Val(fvn, lw, e);
      // Result.versionMS := makelong(lw,hw);
      // Result.versionLS := makelong(0,0);
      Result.versionms := hw;
      Result.versionms2 := lw;
      Result.versionls := 0;
      Result.versionls2 := 0;
    end;
  end
  else
  begin
    Val(fvn, hw, e);
    if (e = 0) then
    begin
      // Result.versionMS := makelong(0,hw);
      // Result.versionLS := makelong(0,0);
      Result.versionms := hw;
      Result.versionms2 := 0;
      Result.versionls := 0;
      Result.versionls2 := 0;
    end;
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

function DelDir(dir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, Sizeof(fos));
  with fos do
  begin
    wFunc := FO_DELETE;
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom := PChar(dir + #0);
  end;
  Result := (0 = ShFileOperation(fos));
end;

/// /////////////////////////////////////////////////////////////////////////////

function MyRemoveDir(sDir: String): Boolean;
var
  iIndex: Integer;
  SearchRec: TSearchRec;
  sFileName: String;
begin
  Result := false;
  sDir := sDir + '*.*';
  iIndex := FindFirst(sDir, faAnyFile, SearchRec);
  while iIndex = 0 do
  begin
    sFileName := ExtractFileDir(sDir) + '\' + SearchRec.Name;
    if SearchRec.Attr = faDirectory then
    begin
      if (SearchRec.Name <> '') and (SearchRec.Name <> '.') and
        (SearchRec.Name <> '..') then
        MyRemoveDir(sFileName);
    end
    else
    begin
      if SearchRec.Attr <> faArchive then
        FileSetAttr(sFileName, faArchive);
      if NOT DeleteFile(sFileName) then
        InfoLog.WriteError('Could NOT delete ' + sFileName);
    end;
    iIndex := FindNext(SearchRec);
  end;
  FindClose(SearchRec);
  RemoveDir(ExtractFileDir(sDir));
  Result := true;
end;

/// /////////////////////////////////////////////////////////////////////////////

function GetModuleFileNameStr(Instance: THandle): String;
var
  buffer: array [0 .. MAX_PATH] of char;
begin
  GetModuleFileName(Instance, buffer, MAX_PATH);
  Result := buffer;
end;

/// /////////////////////////////////////////////////////////////////////////////

function CheckThreadIsAlive(Thread: TThread): Boolean;
begin
  Result := WaitForSingleObject(Thread.Handle, 0) = WAIT_OBJECT_0;
end;

/// /////////////////////////////////////////////////////////////////////////////

function BytesToGigaBytes(Bytes: int64): string;
begin
  Result := FloatToStrF(Bytes / 1073741824, ffNumber, 18, 1);
end;

/// /////////////////////////////////////////////////////////////////////////////

function BytesToMegaBytes(Bytes: int64): string;
begin
  Result := FloatToStrF(Bytes / 1048576, ffNumber, 18, 1);
end;

/// /////////////////////////////////////////////////////////////////////////////

function BytesToKiloBytes(Bytes: int64): string;
begin
  Result := FloatToStrF(Bytes / 1024, ffNumber, 18, 1);
end;

/// /////////////////////////////////////////////////////////////////////////////

function BytesToText(Bytes: int64): String;
begin
  if Bytes div 1024 < 1 then
    Result := IntToStr(Bytes) + ' B';
  if Bytes div 1024 >= 1 then
    Result := FloatToStrF(Bytes / 1024, ffNumber, 18, 1) + ' KB';
  if Bytes div 1024 >= 1024 then
    Result := FloatToStrF(Bytes / 1048576, ffNumber, 18, 1) + ' MB';
  if Bytes div 1024 >= 1048576 then
    Result := FloatToStrF(Bytes / 1073741824, ffNumber, 18, 2) + ' GB';
end;

/// /////////////////////////////////////////////////////////////////////////////

function GetFileVersion(FileName: String): String;
var
  Data: Pointer;
  DataSize, InfoSize: DWORD;
  Dummy: cardinal;
  buffer: array [0 .. MAX_PATH] of char;
  Major1, Major2, Minor1, Minor2: Integer;
  FileInfo: PVSFixedFileInfo;

begin

  StrCat(buffer, PChar(FileName));
  DataSize := GetFileVersionInfoSize(buffer, Dummy);

  if DataSize > 0 then
  begin

    GetMem(Data, DataSize);
    GetFileVersionInfo(buffer, 0, DataSize, Data);
    VerQueryValue(Data, '\', Pointer(FileInfo), InfoSize);

    Major1 := FileInfo.dwFileVersionMS shr 16;
    Major2 := FileInfo.dwFileVersionMS and $FFFF;
    Minor1 := FileInfo.dwFileVersionLS shr 16;
    Minor2 := FileInfo.dwFileVersionLS and $FFFF;

    Result := IntToStr(Major1) + '.' + IntToStr(Major2) + '.' + IntToStr
      (Minor1) + ' build ' + IntToStr(Minor2);

    FreeMem(Data, DataSize);

  end;

end;

/// /////////////////////////////////////////////////////////////////////////////

function BrowserFolder(Owner: THandle): String;
var
  TitleName: String;
  lpItemID: PItemIDList;
  BrowseInfo: TBrowseInfo;
  DisplayName: Array [0 .. MAX_PATH] of char;
  TempPath: Array [0 .. MAX_PATH] of char;

begin

  FillChar(BrowseInfo, Sizeof(TBrowseInfo), #0);

  BrowseInfo.hwndOwner := Owner;
  BrowseInfo.pszDisplayName := @DisplayName;

  TitleName := GetLangStringA(STR_CHANGE_DIRECTORY);

  BrowseInfo.lpszTitle := PChar(TitleName);
  BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS;

  lpItemID := SHBrowseForFolder(BrowseInfo);

  if lpItemID <> nil then
  begin

    SHGetPathFromIDList(lpItemID, TempPath);
    GlobalFreePtr(lpItemID);

    Result := TempPath;

  end
  else
  begin

    Result := '';

  end;

end;

/// /////////////////////////////////////////////////////////////////////////////
{
  function CreateFileName(Url : String) : String;
  var
  i : Integer;
  Url2:string;
  begin
  Result := '';
  if Pos('//', Url) > 0 then Delete(Url, 1, Pos('//', Url) + 1);
  if Url = '' then Exit;
  if Pos('/', Url) > 0 then Delete(Url, 1, Pos('/', Url))
  else Delete(Url, 1, Length(Url));

  if Url = '' then
  begin
  Result := 'index.html';
  Exit;
  end;

  if Url[Length(Url)] <> '/' then
  begin
  i := Length(Url);
  repeat
  i := i - 1;
  until Url[i] = '/';
  Url2 :=Copy(Url, i + 1, Length(Url) - i);
  if Pos('?',Url2)>0 then
  Result:=Copy(Url2,1, Pos('?', Url2)-1)
  else
  Result:=Copy(Url, i + 1, Length(Url) - i);
  end
  else Result := 'index.html';

  end;
}

function CreateFileName(Url: String): String;
var
  i: Integer;
begin
  Result := '';
  if pos('//', Url) > 0 then
    delete(Url, 1, pos('//', Url) + 1);
  if Url = '' then
    exit;
  if pos('/', Url) > 0 then
    delete(Url, 1, pos('/', Url))
  else
    delete(Url, 1, length(Url));
  if Url = '' then
  begin
    Result := 'NoName';
    exit;
  end;
  if Url[length(Url)] <> '/' then
  begin
    i := length(Url);
    repeat
      i := i - 1;
    until Url[i] = '/';
    Result := copy(Url, i + 1, length(Url) - i);
  end
  else
    Result := 'NoName';
end;

/// /////////////////////////////////////////////////////////////////////////////

function ExtractUrlFileName(const AUrl: string): string;
var
  i: Integer;
  Url: string;
begin
  i := LastDelimiter('/', AUrl);
  Url := copy(AUrl, i + 1, length(AUrl) - (i));
  if (trim(Url) = '') then
    Result := 'NoName'
  else
    Result := Url;
end;

/// /////////////////////////////////////////////////////////////////////////////

function LocalAddress(Url: String): Boolean;
begin
  Result := false;

  if pos('//', Url) > 0 then
    delete(Url, 1, pos('//', Url) + 1);
  if pos('/', Url) > 0 then
    delete(Url, pos('/', Url), length(Url));

  if lowercase(Url) = 'localhost' then
    Result := true;
  if lowercase(Url) = '127.0.0.1' then
    Result := true;
end;

/// /////////////////////////////////////////////////////////////////////////////

function ExtractAddress(Url: String): String;
begin
  if pos('//', Url) > 0 then
    delete(Url, 1, pos('//', Url) + 1);
  if pos('www.', Url) > 0 then
    delete(Url, 1, pos('www.', Url) + 3);
  if pos('/', Url) > 0 then
    delete(Url, pos('/', Url), length(Url));
  Url := TrimLeft(Url);
  Url := TrimRight(Url);
  Result := Url;
end;

/// /////////////////////////////////////////////////////////////////////////////

function ExtractProgFileName(Url: String): String;
begin
  if pos('//', Url) > 0 then
    delete(Url, 1, pos('//', Url) + 1);
  if pos('/', Url) > 0 then
    delete(Url, 1, pos('/', Url));
  Url := TrimLeft(Url);
  Url := TrimRight(Url);
  Result := Url;
end;

/// /////////////////////////////////////////////////////////////////////////////

function GetFreeSpace(Disk: String): int64;
var
  TotalBytes: int64;
  TotalFreeBytes: PLargeInteger;
  FreeBytesCall: int64;
begin
  New(TotalFreeBytes);
  try
    GetDiskFreeSpaceEx(PChar(Disk), FreeBytesCall, TotalBytes, TotalFreeBytes);
    Result := TotalFreeBytes^;
  finally
    Dispose(TotalFreeBytes);
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

function IsRun: Boolean;
var
  Mutex: Integer;
begin
  Result := false;
  Mutex := CreateMutex(nil, true, 'BankClientServer');
  if GetLastError <> 0 then
  begin
    CloseHandle(Mutex);
    Result := true;
  end;
end;

/// /////////////////////////////////////////////////////////////////////////////

function GetTimeStr(Secs: Integer): String;

  function LeadingZero(N: Integer): String;
  begin
    if N < 10 then
      Result := '0' + IntToStr(N)
    else
      Result := IntToStr(N);
  end;

var
  Hours, Mins: Integer;
begin
  Hours := Secs div 3600;
  Secs := Secs - Hours * 3600;
  Mins := Secs div 60;
  Secs := Secs - Mins * 60;
  Result := LeadingZero(Hours) + ':' + LeadingZero(Mins) + ':' + LeadingZero
    (Secs);
end;

function RightFileName(const FileName: string): Boolean;
const
  CHARS: array [1 .. 9] of char = ('\', '/', ':', '*',
    { '.', } '?', '"', '<', '>', '|');
var
  i: Integer;
begin
  for i := 1 to 9 do
    if pos(CHARS[i], FileName) <> 0 then // Ќайден запрещЄнный символ
    begin
      Result := false;
      exit;
    end;
  Result := true;
end;

end.
