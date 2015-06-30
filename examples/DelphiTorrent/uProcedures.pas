unit uProcedures;

interface

uses windows, Classes, SysUtils, uObjects, {OverByteIcsUrl,}
  PluginAPI, PluginManager;

type

  tfvi = record
    versionms: Integer;
    versionms2: Integer;
    versionls: Integer;
    versionls2: Integer;
  end;

function StringToVersion(fvn: string): tfvi;
function GetFreeSpace(Disk: String): int64;
function BytesToGigaBytes(Bytes: int64): string;
function BytesToMegaBytes(Bytes: int64): string;
function BytesToKiloBytes(Bytes: int64): string;
function BytesToText(Bytes: int64): String;
function HashFromMagnet(Url: string): string;
function ExtractUrlFileName(const AUrl: string): string;
function RightFileName(const FileName: string): Boolean;
function DeterminePlugin2(const AUrl: String; const AGUID: TGUID; out Obj;
  out IndexPlugin: Integer): Boolean;

implementation

type
  TCharSet = set of AnsiChar;

const
  UriProtocolSchemeAllowedChars: TCharSet = ['a' .. 'z', '0' .. '9', '+',
    '-', '.'];

function Posn(const s, t: String; Count: Integer): Integer;
var
  i, h, Last: Integer;
  u: String;
begin
  u := t;
  if Count > 0 then
  begin
    Result := Length(t);
    for i := 1 to Count do
    begin
      h := Pos(s, u);
      if h > 0 then
        u := Copy(u, h + 1, Length(u))
      else
      begin
        u := '';
        Inc(Result);
      end;
    end;
    Result := Result - Length(u);
  end
  else if Count < 0 then
  begin
    Last := 0;
    for i := Length(t) downto 1 do
    begin
      u := Copy(t, i, Length(t));
      h := Pos(s, u);
      if (h <> 0) and ((h + i) <> Last) then
      begin
        Last := h + i - 1;
        Inc(Count);
        if Count = 0 then
          break;
      end;
    end;
    if Count = 0 then
      Result := Last
    else
      Result := 0;
  end
  else
    Result := 0;
end;

function IcsLowerCase(const s: AnsiString): AnsiString;
begin
{$IFDEF USE_ICS_RTL}
  Result := IcsLowerCaseA(s);
{$ELSE}
{$IFNDEF COMPILER12_UP}
  Result := SysUtils.LowerCase(s);
{$ELSE}
  Result := IcsLowerCaseA(s);
{$ENDIF}
{$ENDIF}
end;

{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{$IFDEF COMPILER12_UP}

function IcsLowerCase(const s: UnicodeString): UnicodeString;
begin
  Result := SysUtils.LowerCase(s);
end;
{$ENDIF}

procedure ParseURL(const Url: String; var Proto, User, Pass, Host, Port,
  Path: String);
var
  p, q, i: Integer;
  s: String;
  CurPath: String;
begin
  CurPath := Path;
  Proto := '';
  User := '';
  Pass := '';
  Host := '';
  Port := '';
  Path := '';

  if Length(Url) < 1 then
    Exit;

  { Handle path beginning with "./" or "../". }
  { This code handle only simple cases ! }
  { Handle path relative to current document directory }
  if (Copy(Url, 1, 2) = './') then
  begin
    p := Posn('/', CurPath, -1);
    if p > Length(CurPath) then
      p := 0;
    if p = 0 then
      CurPath := '/'
    else
      CurPath := Copy(CurPath, 1, p);
    Path := CurPath + Copy(Url, 3, Length(Url));
    Exit;
  end
  { Handle path relative to current document parent directory }
  else if (Copy(Url, 1, 3) = '../') then
  begin
    p := Posn('/', CurPath, -1);
    if p > Length(CurPath) then
      p := 0;
    if p = 0 then
      CurPath := '/'
    else
      CurPath := Copy(CurPath, 1, p);

    s := Copy(Url, 4, Length(Url));
    { We could have several levels }
    while TRUE do
    begin
      CurPath := Copy(CurPath, 1, p - 1);
      p := Posn('/', CurPath, -1);
      if p > Length(CurPath) then
        p := 0;
      if p = 0 then
        CurPath := '/'
      else
        CurPath := Copy(CurPath, 1, p);
      if (Copy(s, 1, 3) <> '../') then
        break;
      s := Copy(s, 4, Length(s));
    end;

    Path := CurPath + Copy(s, 1, Length(s));
    Exit;
  end;

  p := Pos('://', Url);
  q := p;
  if p <> 0 then
  begin
    s := IcsLowerCase(Copy(Url, 1, p - 1));
    for i := 1 to Length(s) do
    begin
      if not(AnsiChar(s[i]) in UriProtocolSchemeAllowedChars) then
      begin
        q := i;
        break;
      end;
    end;
    if q < p then
    begin
      p := 0;
      Proto := 'http';
    end;
  end;
  if p = 0 then
  begin
    if (Url[1] = '/') then
    begin
      { Relative path without protocol specified }
      Proto := 'http';
      // p     := 1;     { V6.05 }
      if (Length(Url) > 1) then
      begin
        if (Url[2] <> '/') then
        begin
          { Relative path }
          Path := Copy(Url, 1, Length(Url));
          Exit;
        end
        else
          p := 2; { V6.05 }
      end
      else
      begin { V6.05 }
        Path := '/'; { V6.05 }
        Exit; { V6.05 }
      end;
    end
    else if IcsLowerCase(Copy(Url, 1, 5)) = 'http:' then
    begin
      Proto := 'http';
      p := 6;
      if (Length(Url) > 6) and (Url[7] <> '/') then
      begin
        { Relative path }
        Path := Copy(Url, 6, Length(Url));
        Exit;
      end;
    end
    else if IcsLowerCase(Copy(Url, 1, 7)) = 'mailto:' then
    begin
      Proto := 'mailto';
      p := Pos(':', Url);
    end;
  end
  else
  begin
    Proto := IcsLowerCase(Copy(Url, 1, p - 1));
    Inc(p, 2);
  end;
  s := Copy(Url, p + 1, Length(Url));

  p := Pos('/', s);
  q := Pos('?', s);
  if (q > 0) and ((q < p) or (p = 0)) then
    p := q;
  if p = 0 then
    p := Length(s) + 1;
  Path := Copy(s, p, Length(s));
  s := Copy(s, 1, p - 1);

  { IPv6 URL notation, for instance "[2001:db8::3]" }
  p := Pos('[', s);
  q := Pos(']', s);
  if (p = 1) and (q > 1) then
  begin
    Host := Copy(s, 2, q - 2);
    s := Copy(s, q + 1, Length(s));
  end;

  p := Posn(':', s, -1);
  if p > Length(s) then
    p := 0;
  q := Posn('@', s, -1);
  if q > Length(s) then
    q := 0;
  if (p = 0) and (q = 0) then
  begin { no user, password or port }
    if Host = '' then
      Host := s;
    Exit;
  end
  else if q < p then
  begin { a port given }
    Port := Copy(s, p + 1, Length(s));
    if Host = '' then
      Host := Copy(s, q + 1, p - q - 1);
    if q = 0 then
      Exit; { no user, password }
    s := Copy(s, 1, q - 1);
  end
  else
  begin
    if Host = '' then
      Host := Copy(s, q + 1, Length(s));
    s := Copy(s, 1, q - 1);
  end;
  p := Pos(':', s);
  if p = 0 then
    User := s
  else
  begin
    User := Copy(s, 1, p - 1);
    Pass := Copy(s, p + 1, Length(s));
  end;
end;

function RightFileName(const FileName: string): Boolean;
const
  CHARS: array [1 .. 9] of char = ('\', '/', ':', '*',
    { '.', } '?', '"', '<', '>', '|');
var
  i: Integer;
begin
  for i := 1 to 9 do
    if Pos(CHARS[i], FileName) <> 0 then // Найден запрещённый символ
    begin
      Result := false;
      Exit;
    end;
  Result := TRUE;
end;

function ExtractUrlFileName(const AUrl: string): string;
var
  i: Integer;
  Url: string;
begin
  i := LastDelimiter('/', AUrl);
  Url := Copy(AUrl, i + 1, Length(AUrl) - (i));
  if (trim(Url) = '') then
    Result := 'NoName'
  else
    Result := Url;
end;

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
      if Pos('*', DomainsList[F]) = 1 then
      begin
        SearchSubDomain := TRUE;
        SubDomain := Copy(DomainsList[F], 2, 1000000);
      end;
      if SearchSubDomain then
      begin
        ParseURL(DomainsList[F], a, B, c, DomainFromList, e, g);
        ParseURL(Link, a, B, c, DomainLink, e, g);
        if (DomainFromList = DomainLink) or
          ('www.' + DomainFromList = DomainLink) or
          (Pos(SubDomain, DomainLink) > 0) then
        begin
          Result := TRUE;
          break;
        end
        else
          SearchSubDomain := false;
      end
      else
      begin
        ParseURL(DomainsList[F], a, B, c, DomainFromList, e, g);
        ParseURL(Link, a, B, c, DomainLink, e, g);
        if (DomainFromList = DomainLink) or
          ('www.' + DomainFromList = DomainLink) then
        begin
          Result := TRUE;
          break;
        end;
      end;
    end;
  finally
    DomainsList.Free;
  end;
end;

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
        Result := TRUE;
        break;
      end;
  end;
end;

function explode(str: string; separator: string): targuments;
var
  previouslen, ind: Integer;
begin

  if Pos('&', str) = 0 then
  begin
    SetLength(Result, 1);
    Result[0] := str;
    Exit;
  end;

  previouslen := 1;
  while (Length(str) > 0) do
  begin

    SetLength(Result, previouslen);

    ind := Pos('&', str);
    if ind <> 0 then
    begin
      Result[previouslen - 1] := Copy(str, 1, ind - 1);
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

    if Length(HexString) = 0 then
      Exit;
    for i := 1 to Length(HexString) do
      if not isxdigit(HexString[i]) then
        Exit;

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
      if i > Length(stringa) then
        break;
      if stringa[i] = '%' then
      begin
        try
          Result := Result + chr(HexToInt(Copy(stringa, i + 1, 2)));
          Inc(i, 3);
        except
        end;
      end
      else
      begin
        Result := Result + stringa[i];
        Inc(i);
      end;
    until (not TRUE);

  except
    Result := '';
  end;
end;

function HashFromMagnet(Url: string): string;
var
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
    if Pos('xt=urn:btih:', LowerCase(Url)) <> 0 then
    begin

      if Pos('magnet:?', LowerCase(Url)) = 1 then
        delete(Url, 1, 8); // strip magnet:?

      tracker := '';
      hash := '';
      suggestedName := '';
      thearr := explode(Url, '&');
      for i := 0 to Length(thearr) - 1 do
      begin
        str := thearr[i];
        variable := Copy(str, 1, Pos('=', str) - 1);
        argument := URLdecode(Copy(str, Pos('=', str) + 1, Length(str)));
        if variable = 'xt' then
          hash := Copy(argument, 10, Length(argument))
        else if variable = 'dn' then
          suggestedName := argument
        else if variable = 'tr' then
          tracker := argument;

        thearr[i] := '';
      end;
      Result := hash;
      SetLength(thearr, 0);
    end;
  except
  end;
end;

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

function StringToVersion(fvn: string): tfvi;
var
  hw, lw: Word;
  e: Integer;
  sep: string;

begin
  Result.versionms := -1;
  Result.versionls := -1;

  sep := '';
  if Pos('.', fvn) > 0 then
    sep := '.';
  if Pos(',', fvn) > 0 then
    sep := ',';

  if Pos(sep, fvn) > 0 then
  begin
    Val(Copy(fvn, 1, Pos(sep, fvn) - 1), hw, e);
    System.delete(fvn, 1, Pos(sep, fvn));

    if (Pos(sep, fvn) > 0) and (e = 0) then
    begin
      Val(Copy(fvn, 1, Pos(sep, fvn) - 1), lw, e);
      Result.versionms := MakeLong(lw, hw);
      System.delete(fvn, 1, Pos(sep, fvn));
      if (Pos(sep, fvn) > 0) and (e = 0) then
      begin
        Val(Copy(fvn, 1, Pos(sep, fvn) - 1), hw, e);
        System.delete(fvn, 1, Pos(sep, fvn));
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

end.
