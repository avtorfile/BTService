unit uFunctions;

interface

Uses Windows, SysUtils, Classes, uStatus, 
  ShlObj;

Type
TThreeBytes = array[0..2] of Byte;  

function GetPluginVersion: string;
function StatusInString(Status: TStatus): string;
function StringInStatus(Status: string): TStatus;
function FindErrorRecognition(ResultRec: string): boolean;
function CheckThreadIsAlive(Thread: TThread): boolean;
function GetModuleFileNameStr(Instance: THandle): String;
function BrowserFolder(Owner: THandle): String;
function ExtractAddress(Url: String): String;
function FileSize(const aFilename: String): Int64;
function SearchParam1(Page:String;Value:String;
 Plus:Integer):string;
function SearchParam2(Page:String;Value:String;
 Plus:Integer;Element:String;Minus:Integer):string;
function SearchParam3(Page:String;Value:String;
 Plus:Integer;Element:String;Plus2:Integer):string;
var nBegin, nEnd: Integer;
function isUTF8FileBOM(const FileName: string): boolean;
procedure DeleteBOM(aFileName: string);
function StringToPWide(sStr: string): PWideChar;
function PWideToString(pw: PWideChar): string;
function SizeFile(s: string): int64;
function RightFileName(const FileName: string): Boolean;

implementation

function RightFileName(const FileName: string): Boolean;
const
  CHARS: array [1 .. 9] of char = ('\', '/', ':', '*',
    { '.', } '?', '"', '<', '>', '|');
var
  i: Integer;
begin
  for i := 1 to 9 do
    if pos(CHARS[i], FileName) <> 0 then
    begin
      Result := false;
      exit;
    end;
  Result := true;
end;

function PWideToString(pw: PWideChar): string;
var
  p: PAnsiChar;
  iLen: integer;
begin
  iLen := lstrlenw(pw) + 1;
  GetMem(p, iLen);

  WideCharToMultiByte(CP_ACP, 0, pw, iLen, p, iLen * 2, nil, nil);

  Result := p;
  FreeMem(p, iLen);
end;

function StringToPWide(sStr: string{; var iNewSize: integer}): PWideChar;
var
  pw: PWideChar;
  iSize: integer;
  iNewSize: integer;
begin
  iSize := Length(sStr) + 1;
  iNewSize := iSize * 2;

  pw := AllocMem(iNewSize);

  MultiByteToWideChar(CP_ACP, 0, PAnsiChar(sStr), iSize, pw, iNewSize);

  Result := pw;
end;

function isUTF8FileBOM(const FileName: string): boolean;
var
  txt: file;
  bytes: array[0..2] of byte;
  amt: integer;
begin
  FileMode := fmOpenRead;
  AssignFile(txt, FileName);
  Reset(txt, 1);
  try
    BlockRead(txt, bytes, 3, amt);
    result := (amt=3) and (bytes[0] = $EF) and (bytes[1] = $BB) and (bytes[2] = $BF);
  finally
    CloseFile(txt);
  end;
end;

procedure DeleteBOM(aFileName: string);
var
  ms: TMemoryStream;
  fS: TFileStream;
  buf: TThreeBytes;
const
  sBOM: TThreeBytes = ($EF, $BB, $BF);
begin
  fS := TFileStream.Create(aFileName, fmOpenReadWrite);
  try
    fS.ReadBuffer(buf, SizeOf(buf));
    if CompareMem(@buf, @sBOM, SizeOf(sBOM)) then
    begin
      ms := TMemoryStream.Create;
      try
        ms.CopyFrom(fS, fS.Size - SizeOf(sBOM));
        fS.Position := 0;
        fS.CopyFrom(ms, 0);
        fS.Size := ms.Size;
      finally
        ms.Free;
      end;
    end;
  finally
    fS.Free;
  end;
end;

function SearchParam1(Page:String;Value:String;
 Plus:Integer):string;
var nBegin : Integer;
begin
 nBegin := Pos (Value, Page);
 if nBegin <> 0
 then result := Copy (Page, nBegin + Plus, 1000000)
 else result:='';
end;

function SearchParam2(Page:String;Value:String;
 Plus:Integer;Element:String;Minus:Integer):string;
var nBegin, nEnd: Integer;
begin
 nBegin := Pos (Value, Page);
 if nBegin <> 0 then
 begin
   Page := Copy (Page, nBegin + Plus, 1000000);
   nEnd:=Pos(Element, Page);
   result:=Copy(Page, 1, nEnd - Minus);
 end else result:='';
end;

function SearchParam3(Page:String;Value:String;
 Plus:Integer;Element:String;Plus2:Integer):string;
var nBegin, nEnd: Integer;
begin
 nBegin := Pos (Value, Page);
 if nBegin <> 0 then
 begin
   Page := Copy (Page, nBegin + Plus, 1000000);
   nEnd:=Pos(Element, Page);
   result:=Copy(Page, 1, nEnd + Plus2);
 end else result:='';
end;

function SizeFile(s: string): int64;
var
  SearchRecA : _WIN32_FIND_DATAA;
  SearchRecW : _WIN32_FIND_DATAW;
begin
  if Win32Platform=VER_PLATFORM_WIN32_NT then
  begin
    FindFirstFileW(PWideChar(s), SearchRecW);
    result := (SearchRecW.nFileSizeHigh * 4294967296) + (SearchRecW.nFileSizeLow);
  end
  else
  begin
    FindFirstFileA(PAnsiChar(s), SearchRecA);
    result := (SearchRecA.nFileSizeHigh * 4294967296) + (SearchRecA.nFileSizeLow);
    //result := (SearchRec.nFileSizeHigh shl 32) + (SearchRec.nFileSizeLow);
    //result := (SearchRec.nFileSizeHigh * (MAXDWORD+1)) + (SearchRec.nFileSizeLow);
  end;
end;

function FileSize(const aFilename: String): Int64;
  var
    info: TWin32FileAttributeData;
  begin
    result := -1;

    if NOT GetFileAttributesEx(PAnsiChar(aFileName), GetFileExInfoStandard, @info) then
      EXIT;
    result := (info.nFileSizeLow) or (info.nFileSizeHigh * 4294967296);
    //result := Int64(info.nFileSizeLow) or Int64(info.nFileSizeHigh shl 32);
  end;

function ExtractAddress(Url: String): String;
begin
  if Pos('//', Url) > 0 then
    Delete(Url, 1, Pos('//', Url) + 1);
  if Pos('www.', Url) > 0 then
    Delete(Url, 1, Pos('www.', Url) + 3);
  if Pos('/', Url) > 0 then
    Delete(Url, Pos('/', Url), Length(Url));
  Url := TrimLeft(Url);
  Url := TrimRight(Url);
  Result := Url;
end;

function GetPluginVersion: string;
var
  Buffer: array [byte] of char;
  Info: Pointer;
  InfoSize: DWORD;
  FileInfo: PVSFixedFileInfo;
  FileInfoSize: DWORD;
  Tmp: DWORD;
  Major1, Major2, Minor1, Minor2: Integer;
  NamePlug: string;
begin
  if GetModuleFileName(hInstance, @Buffer, SizeOf(Buffer) - 1) > 0 then
    NamePlug := string(Buffer);

  InfoSize := GetFileVersionInfoSize(PChar(NamePlug), Tmp);

  if InfoSize = 0 then // Файл не содержит информации о версии
  else
  begin
    GetMem(Info, InfoSize);
    try
      GetFileVersionInfo(PChar(NamePlug), 0, InfoSize, Info);
      VerQueryValue(Info, '\', Pointer(FileInfo), FileInfoSize);
      Major1 := FileInfo.dwFileVersionMS shr 16;
      Major2 := FileInfo.dwFileVersionMS and $FFFF;
      Minor1 := FileInfo.dwFileVersionLS shr 16;
      Minor2 := FileInfo.dwFileVersionLS and $FFFF;
      Result := IntToStr(Major1) + '.' + IntToStr(Major2) + '.' + IntToStr
        (Minor1) + '.' + IntToStr(Minor2);
    finally
      FreeMem(Info, FileInfoSize);
    end;
  end;
end;

function GetModuleFileNameStr(Instance: THandle): String;
var
  Buffer: array [0 .. MAX_PATH] of char;
begin
  GetModuleFileName(Instance, Buffer, MAX_PATH);
  Result := Buffer;
end;

function StatusInString(Status: TStatus): string;
begin
  if Status = sSearchCompleted then
    Result := 'sSearchCompleted';
  if Status = sSeeking then
    Result := 'sSeeking';
  if Status = sSearchStoped then
    Result := 'sSearchStoped';
  if Status = sRecognition then
    Result := 'sRecognition';
  if Status = sDownloadTicket then
    Result := 'sDownloadTicket';
  if Status = sStartCreatedThread then
    Result := 'sStartCreatedThread';
  if Status = sCreatedThread then
    Result := 'sCreatedThread';
  if Status = sGet then
    Result := 'sGet';
  if Status = sPost then
    Result := 'sPost';
  if Status = sLog then
    Result := 'sLog';
  if Status = sHead then
    Result := 'sHead';
end;

function StringInStatus(Status: string): TStatus;
begin
  if Status = 'sSearchCompleted' then
    Result := sSearchCompleted;
  if Status = 'sSeeking' then
    Result := sSeeking;
  if Status = 'sSearchStoped' then
    Result := sSearchStoped;
  if Status = 'sRecognition' then
    Result := sRecognition;
  if Status = 'sDownloadTicket' then
    Result := sDownloadTicket;
  if Status = 'sStartCreatedThread' then
    Result := sStartCreatedThread;
  if Status = 'sCreatedThread' then
    Result := sCreatedThread;
  if Status = 'sGet' then
    Result := sGet;
  if Status = 'sPost' then
    Result := sPost;
  if Status = 'sLog' then
    Result := sLog;
  if Status = 'sHead' then
    Result := sHead;
end;

function BrowserFolder(Owner: THandle): String;
var
  TitleName: String;
  lpItemID: PItemIDList;
  BrowseInfo: TBrowseInfo;
  DisplayName: Array [0 .. MAX_PATH] of char;
  TempPath: Array [0 .. MAX_PATH] of char;
begin
  FillChar(BrowseInfo, SizeOf(TBrowseInfo), #0);
  BrowseInfo.hwndOwner := Owner;
  BrowseInfo.pszDisplayName := @DisplayName;
  TitleName := 'Выберите директорию';
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
    Result := '';
end;

function FindErrorRecognition(ResultRec: string): boolean;
begin
  Result := false;
  if (Pos('ERROR_', ResultRec) > 0) or (ResultRec = 'CAPTCHA_NOT_READY') then
    Result := true;
  { if (ResultRec='ERROR_CONTACT_SUPPORT')
    or (ResultRec='ERROR_ZERO_BALANCE')
    or (ResultRec='ERROR_NO_SLOT_AVAILABLE')
    or (ResultRec='ERROR_NO_SUCH_CAPTCHA_ID')
    or (ResultRec='ERROR_WRONG_USER_KEY')
    or (ResultRec='ERROR_KEY_DOES_NOT_EXIST')
    or (ResultRec='ERROR_ZERO_CAPTCHA_FILESIZE')
    or (ResultRec='ERROR_NO_SUCH_METHOD')
    or (ResultRec='ERROR_IMAGE_IS_NOT_JPEG')
    or (ResultRec='CAPTCHA_NOT_READY')
    or (ResultRec='ERROR_CAPTCHA_UNSOLVABLE')
    or (ResultRec='ERROR_DNS_RECORD_EXPIRED')
    or (ResultRec='ERROR_RECOGNITION_TIMEOUT')
    or (pos('ERROR_RECOGNITION_',ResultRec)>0) }
end;

function CheckThreadIsAlive(Thread: TThread): boolean;
begin
  Result := WaitForSingleObject(Thread.Handle, 0) = WAIT_OBJECT_0;
end;

end.
