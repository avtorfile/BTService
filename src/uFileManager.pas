unit uFileManager;
 
interface
 
uses
  Classes, SysUtils, Forms;
 
const
  cCaption = 'Notepad';
  cNewFileName = 'Untitled.txt';
 
type
  TTextFileFormat = (ffAnsi, ffUTF8, ffUTF16);
 
  { TTextFileManager }
 
  TTextFileManager = class
  private
    FMainForm : TForm;
    FFileName : String;
    FFileFormat : TTextFileFormat;
  protected
    procedure ApplyFileName;
 
    function GetFileEncoding(AStream : TStream) : TTextFileFormat;
 
    procedure WriteAnsiFile(AStream : TStream; AData : String);
    procedure WriteUTF8File(AStream : TStream; AData : String);
    procedure WriteUTF16File(AStream : TStream; AData : String);
 
    function ReadAnsiFile(AStream : TStream) : String;
    function ReadUTF8File(AStream : TStream) : String;
    function ReadUTF16File(AStream : TStream) : String;
  public
    constructor Create({AMainForm : TForm}); virtual;
    destructor Destroy; override;
 
    function NeedName : Boolean;
 
    procedure New;
    function Load(AFileName : String) : String;
    procedure Save(AData : String); overload;
    procedure Save(AFileName : String; AData : String; AFormat : TTextFileFormat = ffAnsi); overload;
 
    property FileName : String read FFileName;
    property FileFormat : TTextFileFormat read FFileFormat;
  end;
 
implementation
 
const
  hdrUTF8  : String = #$EF#$BB;
  hdrUTF8W : String = #$BF;
  hdrUTF16 : String = #$FF#$FE;
  hdrUTF32 : String = #$FE#$FF;
 
{ TTextFileManager }
 
procedure TTextFileManager.ApplyFileName;
begin
  //FMainForm.Caption := Format('%s - %s',[cCaption,FFileName]);
  //Application.Title := Format('%s - %s',[cCaption,FFileName]);
end;
 
function TTextFileManager.GetFileEncoding(AStream: TStream): TTextFileFormat;
var
  Hdr : String;
begin
  Hdr := '';
  If AStream.Size < 3
    Then Result := ffAnsi
    Else
      Begin
        AStream.Seek(0,soFromBeginning);
        SetLength(Hdr,2);
        AStream.ReadBuffer(Hdr[1],2);
        If Hdr = hdrUTF8
          Then Result := ffUTF8
          Else
            If (Hdr = hdrUTF16) Or (Hdr = hdrUTF32)
              Then Result := ffUTF16
              Else Result := ffAnsi;
      End;
end;
 
procedure TTextFileManager.WriteAnsiFile(AStream: TStream; AData: String);
begin
  AStream.Seek(0,soFromBeginning);
  AStream.WriteBuffer(AData[1],Length(AData));
end;
 
procedure TTextFileManager.WriteUTF8File(AStream: TStream; AData: String);
var
  Buf : UTF8String;
begin
  Buf := AnsiToUTF8(AData);
  AStream.WriteBuffer(hdrUTF8[1],2);
  AStream.WriteBuffer(hdrUTF8W[1],1);
  AStream.WriteBuffer(Buf[1],Length(Buf));
end;
 
procedure TTextFileManager.WriteUTF16File(AStream: TStream; AData: String);
var
  U : UTF8String;
  W : PWideChar;
  szLen : Integer;
  wsLen : Integer;
begin
  U := AnsiToUtf8(AData);
  szLen := Length(AData) * SizeOf(WideChar);
  GetMem(W,szLen);
  FillChar(W^,szLen,#0);
  Try
    wsLen := Utf8ToUnicode(W,PAnsiChar(U),Length(U));
    AStream.Seek(0,soFromBeginning);
    AStream.WriteBuffer(hdrUTF16[1],2);
    AStream.WriteBuffer(W^,(wsLen-1) * SizeOf(WideChar));
  Finally
    FreeMem(W,szLen);
  End;
end;
 
function TTextFileManager.ReadAnsiFile(AStream: TStream): String;
begin
  AStream.Seek(0,soFromBeginning);
  SetLength(Result,AStream.Size);
  AStream.ReadBuffer(Result[1],AStream.Size);
end;
 
function TTextFileManager.ReadUTF8File(AStream: TStream): String;
var
  Buf : UTF8String;
begin
  AStream.Seek(3,soFromBeginning);
  SetLength(Buf,AStream.Size-3);
  AStream.ReadBuffer(Buf[1],AStream.Size-3);
  Result := UTF8ToAnsi(Buf);
end;
 
function TTextFileManager.ReadUTF16File(AStream: TStream): String;
var
  W : PWideChar;
  U : PAnsiChar;
  szLen : Integer;
begin
  Result := '';
  AStream.Seek(2,soFromBeginning);
  szLen := AStream.Size;
  GetMem(W,szLen);
  FillChar(W^,szLen,#0);
  Try
    AStream.ReadBuffer(W^,szLen-2);
    GetMem(U,szLen);
    FillChar(U^,szLen,#0);
    Try
      UnicodeToUtf8(U,W,szLen);
      Result := UTF8ToAnsi(U);
    Finally
      FreeMem(U,szLen);
    End;
  Finally
    FreeMem(W,szLen);
  End;
end;
 
constructor TTextFileManager.Create({AMainForm: TForm});
begin
  inherited Create;
  //If AMainForm = Nil Then Raise Exception.Create('Main form isn''t passed.');
  //FMainForm := AMainForm;
  New;
end;
 
destructor TTextFileManager.Destroy;
begin
  inherited Destroy;
end;
 
function TTextFileManager.NeedName: Boolean;
begin
  Result := FFileName = cNewFileName;
end;
 
procedure TTextFileManager.New;
begin
  FFileName := cNewFileName;
  FFileFormat := ffAnsi;
  ApplyFileName;
end;
 
function TTextFileManager.Load(AFileName: String) : String;
var
  AStream : TFileStream;
  AFormat : TTextFileFormat;
begin
  AStream := TFileStream.Create(AFileName,fmOpenRead Or fmshareDenyWrite);
  Try
    AFormat := GetFileEncoding(AStream);
    Case AFormat Of
      ffUTF8 : Result := ReadUTF8File(AStream);
      ffUTF16 : Result := ReadUTF16File(AStream);
      Else Result := ReadAnsiFile(AStream);
    End;
    FFileName := AFileName;
    FFileformat := AFormat;
    ApplyFileName;
  Finally
    AStream.Free;
  End;
end;
 
procedure TTextFileManager.Save(AData : String);
begin
  Save(FFileName,AData,FFileformat);
end;
 
procedure TTextFileManager.Save(AFileName: String; AData : String; AFormat: TTextFileFormat = ffAnsi);
var
  AStream : TFileStream;
begin
  AStream := TFileStream.Create(AFileName,fmCreate);
  Try
    Case AFormat Of
      ffUTF8 : WriteUTF8File(AStream, AData);
      ffUTF16 : WriteUTF16File(AStream, AData);
      Else WriteAnsiFile(AStream, AData);
    End;
    FFileName := AFileName;
    FFileformat := AFormat;
    ApplyFileName;
  Finally
    AStream.Free;
  End;
end;
 
end.
