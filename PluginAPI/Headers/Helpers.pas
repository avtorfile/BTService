unit Helpers;

{$IF CompilerVersion >= 21.0}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

interface

uses
  Windows, //Winapi.Windows,
  SysUtils, //System.SysUtils,
  {$IFNDEF EXCLUDE_CLASSES}
  Classes, //System.Classes,
  {$ENDIF}
  {$IFNDEF EXCLUDE_COMOBJ}
  ComObj, //System.Win.ComObj,
  {$ENDIF}
  ActiveX; //Winapi.ActiveX;

type
  {$IFDEF EXCLUDE_COMOBJ}
  EOleError = class(Exception);

  EOleSysError = class(EOleError)
  private
    FErrorCode: HRESULT;
  public
    constructor Create(const Message: UnicodeString; ErrorCode: HRESULT;
      HelpContext: Integer);
    property ErrorCode: HRESULT read FErrorCode write FErrorCode;
  end;

  EOleException = class(EOleSysError)
  private
    FSource: string;
    FHelpFile: string;
  public
    constructor Create(const Message: string; ErrorCode: HRESULT;
      const Source, HelpFile: string; HelpContext: Integer);
    property HelpFile: string read FHelpFile write FHelpFile;
    property Source: string read FSource write FSource;
  end;

  EOleRegistrationError = class(EOleSysError);
  {$ENDIF}

  EBaseException = class(EOleSysError)
  private
    function GetDefaultCode: HRESULT;
  public
    constructor Create(const Msg: string);
    constructor CreateFmt(const Msg: string; const Args: array of const);
    constructor CreateRes(Ident: Integer); overload;
    constructor CreateRes(ResStringRec: PResStringRec); overload;
    constructor CreateResFmt(Ident: Integer; const Args: array of const); overload;
    constructor CreateResFmt(ResStringRec: PResStringRec; const Args: array of const); overload;
    constructor CreateHelp(const Msg: string; AHelpContext: Integer);
    constructor CreateFmtHelp(const Msg: string; const Args: array of const; AHelpContext: Integer);
    constructor CreateResHelp(Ident: Integer; AHelpContext: Integer); overload;
    constructor CreateResHelp(ResStringRec: PResStringRec; AHelpContext: Integer); overload;
    constructor CreateResFmtHelp(ResStringRec: PResStringRec; const Args: array of const; AHelpContext: Integer); overload;
    constructor CreateResFmtHelp(Ident: Integer; const Args: array of const; AHelpContext: Integer); overload;
  end;

  ECheckedInterfacedObjectError = class(EBaseException);
    ECheckedInterfacedObjectDeleteError = class(ECheckedInterfacedObjectError);
    ECheckedInterfacedObjectDoubleFreeError = class(ECheckedInterfacedObjectError);
    ECheckedInterfacedObjectUseDeletedError = class(ECheckedInterfacedObjectError);

  EInvalidCoreVersion = class(EBaseException);

type
  TDebugName = String[99];

  TCheckedInterfacedObject = class(TInterfacedObject, IInterface)
  private
    FName: TDebugName;
    function GetRefCount: Integer;
  protected
    procedure SetName(const AName: String);
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create;
    procedure BeforeDestruction; override;
    property RefCount: Integer read GetRefCount;
    function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HResult; override;
  end;

const
  GUID_DefaultErrorSource: TGUID = '{1FC872DA-2917-48AC-8E51-552A7AD60E46}';

function HResultFromException(const E: Exception): HRESULT;
function HandleSafeCallException(Caller: TObject; ExceptObject: TObject; ExceptAddr: Pointer): HResult;

implementation

uses
  PluginAPI,
  {$IFDEF EXCLUDE_COMOBJ}
  System.ComConst,
  {$ENDIF}
  CRC16;

{$IFDEF EXCLUDE_COMOBJ}

{ EOleSysError }

constructor EOleSysError.Create(const Message: UnicodeString; ErrorCode: HRESULT; HelpContext: Integer);
var
  S: string;
begin
  S := Message;
  if S = '' then
  begin
    S := SysErrorMessage(Cardinal(ErrorCode));
    if S = '' then
      FmtStr(S, SOleError, [ErrorCode]);
  end;
  inherited CreateHelp(S, HelpContext);
  FErrorCode := ErrorCode;
end;

{ EOleException }

constructor EOleException.Create(const Message: string; ErrorCode: HRESULT; const Source, HelpFile: string; HelpContext: Integer);

  function TrimPunctuation(const S: string): string;
  var
    P: PChar;
  begin
    Result := S;
    P := AnsiLastChar(Result);
    while (Length(Result) > 0) and CharInSet(P^, [#0..#32, '.']) do
    begin
      SetLength(Result, P - PChar(Result));
      P := AnsiLastChar(Result);
    end;
  end;

begin
  inherited Create(TrimPunctuation(Message), ErrorCode, HelpContext);
  FSource := Source;
  FHelpFile := HelpFile;
end;

{$ENDIF}

resourcestring
  rsInvalidDelete  = 'Попытка удалить объект %s при активной интерфейсной ссылке; счётчик ссылок: %d';
  rsDoubleFree     = 'Попытка повторно удалить уже удалённый объект %s';
  rsUseDeleted     = 'Попытка использовать уже удалённый объект %s';

{ TCheckedInterfacedObject }

constructor TCheckedInterfacedObject.Create;
begin
  FName := TDebugName(Format('[$%s] %s', [IntToHex(PtrUInt(Self), SizeOf(Pointer) * 2), ClassName]));
  inherited;
end;

procedure TCheckedInterfacedObject.SetName(const AName: String);
begin
  FillChar(FName, SizeOf(FName), 0);
  FName := TDebugName(AName);
end;

procedure TCheckedInterfacedObject.BeforeDestruction;
begin
  if FRefCount < 0 then
    raise ECheckedInterfacedObjectDoubleFreeError.CreateFmt(rsDoubleFree, [String(FName)])
  else
  if FRefCount <> 0 then
    raise ECheckedInterfacedObjectDeleteError.CreateFmt(rsInvalidDelete, [String(FName), FRefCount]);
  inherited;
  FRefCount := -1;
end;

function TCheckedInterfacedObject.GetRefCount: Integer;
begin
  if FRefCount < 0 then
    Result := 0
  else
    Result := FRefCount;
end;

function TCheckedInterfacedObject._AddRef: Integer;
begin
  if FRefCount < 0 then
    raise ECheckedInterfacedObjectUseDeletedError.CreateFmt(rsUseDeleted, [String(FName)]);
  Result := InterlockedIncrement(FRefCount);
end;

function TCheckedInterfacedObject._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;

function TCheckedInterfacedObject.SafeCallException(ExceptObject: TObject;
  ExceptAddr: Pointer): HResult;
begin
  Result := HandleSafeCallException(Self, ExceptObject, ExceptAddr);
end;

{ EBaseException }

function EBaseException.GetDefaultCode: HRESULT;
begin
  Result := MakeResult(SEVERITY_ERROR, FACILITY_ITF, CalcCRC16(ClassName));
end;

constructor EBaseException.Create(const Msg: string);
begin
  inherited Create(Msg, GetDefaultCode, 0);
end;

constructor EBaseException.CreateFmt(const Msg: string; const Args: array of const);
begin
  inherited Create(Format(Msg, Args), GetDefaultCode, 0);
end;

constructor EBaseException.CreateFmtHelp(const Msg: string; const Args: array of const; AHelpContext: Integer);
begin
  inherited Create(Format(Msg, Args), GetDefaultCode, AHelpContext);
end;

constructor EBaseException.CreateHelp(const Msg: string; AHelpContext: Integer);
begin
  inherited Create(Msg, GetDefaultCode, AHelpContext);
end;

constructor EBaseException.CreateRes(Ident: Integer);
begin
  inherited Create(LoadStr(Ident), GetDefaultCode, 0);
end;

constructor EBaseException.CreateRes(ResStringRec: PResStringRec);
begin
  inherited Create(LoadResString(ResStringRec), GetDefaultCode, 0);
end;

constructor EBaseException.CreateResFmt(Ident: Integer; const Args: array of const);
begin
  inherited Create(Format(LoadStr(Ident), Args), GetDefaultCode, 0);
end;

constructor EBaseException.CreateResFmt(ResStringRec: PResStringRec; const Args: array of const);
begin
  inherited Create(Format(LoadResString(ResStringRec), Args), GetDefaultCode, 0);
end;

constructor EBaseException.CreateResFmtHelp(ResStringRec: PResStringRec; const Args: array of const; AHelpContext: Integer);
begin
  inherited Create(Format(LoadResString(ResStringRec), Args), GetDefaultCode, AHelpContext);
end;

constructor EBaseException.CreateResFmtHelp(Ident: Integer; const Args: array of const; AHelpContext: Integer);
begin
  inherited Create(Format(LoadStr(Ident), Args), GetDefaultCode, AHelpContext);
end;

constructor EBaseException.CreateResHelp(Ident, AHelpContext: Integer);
begin
  inherited Create(LoadStr(Ident), GetDefaultCode, AHelpContext);
end;

constructor EBaseException.CreateResHelp(ResStringRec: PResStringRec; AHelpContext: Integer);
begin
  inherited Create(LoadResString(ResStringRec), GetDefaultCode, AHelpContext);
end;

// _____________________________________________________________________________

type
  OleSysErorClass = class of EOleSysError;
  OleExceptionClass = class of EOleException;

function HResultFromException(const E: Exception): HRESULT;
begin
  if E.ClassType = Exception then
    Result := E_UNEXPECTED
  else
  if E is EOleSysError then
    Result := EOleSysError(E).ErrorCode
  else
  if E is EOSError then
    Result := HResultFromWin32(EOSError(E).ErrorCode)
  else
    Result := MakeResult(SEVERITY_ERROR, FACILITY_ITF, CalcCRC16(E.ClassName));
end;

function HandleSafeCallException(Caller: TObject; ExceptObject: TObject; ExceptAddr: Pointer): HResult;
var
  E: TObject;
  CreateError: ICreateErrorInfo;
  ErrorInfo: IErrorInfo;
  Source: WideString;
begin
  Result := E_UNEXPECTED;
  E := ExceptObject;
  if Succeeded(CreateErrorInfo(CreateError)) then
  begin
    Source := 'pluginsystem.' + Caller.ClassName;
    CreateError.SetSource(PWideChar(Source));
    if E is Exception then
    begin
      CreateError.SetDescription(PWideChar(WideString(Exception(E).Message)));
      CreateError.SetHelpContext(Exception(E).HelpContext);
      if (E is EOleSysError) and (EOleSysError(E).ErrorCode < 0) then
        Result := EOleSysError(E).ErrorCode
      else
      if E is EOSError then
        Result := HResultFromWin32(EOleSysError(E).ErrorCode)
      else
        Result := HResultFromException(Exception(E));
    end;
    if HResultFacility(Result) = FACILITY_ITF then
      CreateError.SetGUID(GUID_DefaultErrorSource)
    else
      CreateError.SetGUID(GUID_NULL);
    if CreateError.QueryInterface(IErrorInfo, ErrorInfo) = S_OK then
      SetErrorInfo(0, ErrorInfo);
  end;
end;

procedure CustomSafeCallError(ErrorCode: HResult; ErrorAddr: Pointer);

  function CreateExceptionFromCode(ACode: HRESULT): Exception;
  var
    ExceptionClass: ExceptClass;
    ErrorInfo: IErrorInfo;
    Source, Description, HelpFile: WideString;
    HelpContext: Longint;
  begin
    if HResultFacility(ACode) = FACILITY_WIN32 then
      ExceptionClass := EOSError
    else
    case HRESULT(ErrorCode) of
      {E_ArgumentException:                      ExceptionClass := EArgumentException;
      E_ArgumentOutOfRangeException:            ExceptionClass := EArgumentOutOfRangeException;
      E_PathTooLongException:                   ExceptionClass := EPathTooLongException;
      E_NotSupportedException:                  ExceptionClass := ENotSupportedException;
      E_DirectoryNotFoundException:             ExceptionClass := EDirectoryNotFoundException;
      E_FileNotFoundException:                  ExceptionClass := EFileNotFoundException;
      E_NoConstructException:                   ExceptionClass := ENoConstructException;}
      E_Abort:                                  ExceptionClass := EAbort;
      E_HeapException:                          ExceptionClass := EHeapException;
      E_OutOfMemory:                            ExceptionClass := EOutOfMemory;
      E_InOutError:                             ExceptionClass := EInOutError;
      E_InvalidPointer:                         ExceptionClass := EInvalidPointer;
      E_InvalidCast:                            ExceptionClass := EInvalidCast;
      E_ConvertError:                           ExceptionClass := EConvertError;
      E_VariantError:                           ExceptionClass := EVariantError;
      E_PropReadOnly:                           ExceptionClass := EPropReadOnly;
      E_PropWriteOnly:                          ExceptionClass := EPropWriteOnly;
      E_AssertionFailed:                        ExceptionClass := EAssertionFailed;
      E_AbstractError:                          ExceptionClass := EAbstractError;
      E_IntfCastError:                          ExceptionClass := EIntfCastError;
      E_InvalidContainer:                       ExceptionClass := EInvalidContainer;
      E_InvalidInsert:                          ExceptionClass := EInvalidInsert;
      E_PackageError:                           ExceptionClass := EPackageError;
      {E_Monitor:                                ExceptionClass := EMonitor;
      E_MonitorLockException:                   ExceptionClass := EMonitorLockException;
      E_NoMonitorSupportException:              ExceptionClass := ENoMonitorSupportException;
      E_ProgrammerNotFound:                     ExceptionClass := EProgrammerNotFound;}
      {$IFNDEF EXCLUDE_CLASSES}
      E_StreamError:                            ExceptionClass := EStreamError;
      E_FileStreamError:                        ExceptionClass := EFileStreamError;
      E_FCreateError:                           ExceptionClass := EFCreateError;
      E_FOpenError:                             ExceptionClass := EFOpenError;
      E_FilerError:                             ExceptionClass := EFilerError;
      E_ReadError:                              ExceptionClass := EReadError;
      E_WriteError:                             ExceptionClass := EWriteError;
      E_ClassNotFound:                          ExceptionClass := EClassNotFound;
      E_MethodNotFound:                         ExceptionClass := EMethodNotFound;
      E_InvalidImage:                           ExceptionClass := EInvalidImage;
      E_ResNotFound:                            ExceptionClass := EResNotFound;
      E_ListError:                              ExceptionClass := EListError;
      E_BitsError:                              ExceptionClass := EBitsError;
      E_StringListError:                        ExceptionClass := EStringListError;
      E_ComponentError:                         ExceptionClass := EComponentError;
      E_ParserError:                            ExceptionClass := EParserError;
      E_OutOfResources:                         ExceptionClass := EOutOfResources;
      E_InvalidOperation:                       ExceptionClass := EInvalidOperation;
      {$ENDIF}
      E_CheckedInterfacedObjectError:           ExceptionClass := ECheckedInterfacedObjectError;
      E_CheckedInterfacedObjectDeleteError:     ExceptionClass := ECheckedInterfacedObjectDeleteError;
      E_CheckedInterfacedObjectDoubleFreeError: ExceptionClass := ECheckedInterfacedObjectDoubleFreeError;
      E_CheckedInterfacedObjectUseDeletedError: ExceptionClass := ECheckedInterfacedObjectUseDeletedError;
      E_InvalidCoreVersion:                     ExceptionClass := EInvalidCoreVersion;
    else
      ExceptionClass := EOleException;
    end;

    if GetErrorInfo(0, ErrorInfo) = S_OK then
    begin
      ErrorInfo.GetSource(Source);
      ErrorInfo.GetDescription(Description);
      ErrorInfo.GetHelpFile(HelpFile);
      ErrorInfo.GetHelpContext(HelpContext);
    end
    else
    begin
      Source := '';
      Description := '';
      HelpFile := '';
      HelpContext := 0;
    end;

    if ExceptionClass.InheritsFrom(EOleException) then
      Result := OleExceptionClass(ExceptionClass).Create(Description, ACode, Source, HelpFile, HelpContext)
    else
    if ExceptionClass.InheritsFrom(EOleSysError) then
      Result := OleSysErorClass(ExceptionClass).Create(Description, ACode, HelpContext)
    else
    begin
      Result := ExceptionClass.Create(Description);
      if Result is EOSError then
        EOSError(Result).ErrorCode := HResultCode(ACode);
    end;
  end;

var
  E: Exception;
begin
  E := CreateExceptionFromCode(HRESULT(ErrorCode));
  raise E at ErrorAddr;
end;

initialization
  SafeCallErrorProc := CustomSafeCallError;
finalization
  SafeCallErrorProc := nil;
end.
