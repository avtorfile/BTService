Unit uSearchLink;

Interface

Uses
   Windows, Classes, SysUtils, uTransferInfo, uFunctions;

Type

TSearchLinkThread = class(TThread)
    TextCap: string;
    WaitTime: integer;
    LastUrl: string;
    ValueA: string;
    ValueB: string;

    procedure Get;
    procedure Post;
    function  Inspect:boolean;
    procedure Log(LogText:string);
    procedure StartRecognition;
    procedure StartDownloadTicket(DTTime:integer);
    function  CheckResultRecognition:boolean;
    function  CheckResultRequest:boolean;
    function  CheckResultLog:boolean;
    procedure CookiesAdd(Cookies:TStringList);
    function  SearchParam1(Page:String;Value:String;Plus:Integer):string;
    function  SearchParam2(Page:String;Value:String;Plus:Integer;
     Element:String;Minus:Integer):string;
    procedure DataPreparation1;
    procedure DataPreparation2;
    procedure DataPreparation3;
    procedure DataPreparation4;
    procedure DataPreparation5;

public
    procedure Execute; override;
    constructor Create(CreateSuspended : Boolean; P : Pointer);

private
    ThreadData          : TInfo;
    LinkInProgram       : string;
    RefererInProgram    : string;
    CookieInProgram     : string;
    ErrorInProgram      : string;
    DataPostInProgram   : string;
end;

Implementation

{TSearchLinkThread}

constructor TSearchLinkThread.Create(CreateSuspended : Boolean; P : Pointer);
begin
 ThreadData:=P;
 inherited Create(CreateSuspended);
 CreateThreadInContainer(ThreadData.ID,Handle);
end;

procedure TSearchLinkThread.Execute;
begin
FreeOnTerminate:=false;
if Inspect then SeekingInContainer(ThreadData.ID);
ThreadData.DataIn.RequestVer := 1;
Get;
DataPreparation1;
Get;
DataPreparation2;
StartDownloadTicket(WaitTime);
Get;
DataPreparation3;
Get;
StartRecognition;
DataPreparation4;
Post;
DataPreparation5;

CompleteInContainer(ThreadData.ID,LinkInProgram,RefererInProgram,
CookieInProgram,ErrorInProgram,DataPostInProgram);
end;

procedure TSearchLinkThread.DataPreparation1;
var PageHtml : string;
begin
  if Inspect then else exit;
  PageHtml := ThreadData.DataOut.PageHtml;
  PageHtml := SearchParam1(PageHtml,
  '<a href="javascript: void(0);" onclick="showSpeedDownload();',
  length('<a href="javascript: void(0);" onclick="showSpeedDownload();'));
  ThreadData.DataIn.Url           := 'http://www.bitoman.ru'+
    SearchParam2(PageHtml,'<a href="',9,'"',1);
  ThreadData.DataIn.DataType      := 0;
  ThreadData.DataIn.Referer       := ThreadData.DataOut.Referer;
  CookiesAdd(ThreadData.DataOut.Cookie);
  ErrorInProgram                  := ThreadData.DataOut.Error;
end;

procedure TSearchLinkThread.DataPreparation2;
var
  PageHtml: string;
begin
  if Inspect then else exit;
  PageHtml := ThreadData.DataOut.PageHtml;
  ThreadData.DataIn.Url := 'http://www.bitoman.ru' + SearchParam2(PageHtml,
    '&nbsp;<a class="linkspeed" id="downloadLink" href="', 51, '"', 1); ;

  try
  WaitTime:=StrToInt(SearchParam2(PageHtml,'download.totalTime = ',21,';',1));
  except
    on E:Exception do
    begin
     ErrorInProgram := E.Message;
     exit;
    end;
  end;

  ThreadData.DataIn.DataType := 0;
  ThreadData.DataIn.Referer := ThreadData.DataOut.Referer;
  CookiesAdd(ThreadData.DataOut.Cookie);
  ErrorInProgram := ThreadData.DataOut.Error;
end;

procedure TSearchLinkThread.DataPreparation3;
var
  PageHtml: string;
begin
  if Inspect then else exit;
  PageHtml := ThreadData.DataOut.PageHtml;
  LastUrl:='http://www.bitoman.ru'+SearchParam2(PageHtml,'<form id="download-captcha-form" action="',
  41,'"',1);
  PageHtml := SearchParam1(PageHtml,
  '<form id="download-captcha-form" action="',41);
  ThreadData.DataIn.Url           := 'http://www.bitoman.ru'+
    SearchParam2(PageHtml,'src="',5,'"',1);
  ValueA := SearchParam2(PageHtml,'<input type="submit" name="',27,'"',1);
  PageHtml := SearchParam1(PageHtml,'<input type="submit" name="',27);
  ValueB := SearchParam2(PageHtml,'value="',7,'"',1);
  ThreadData.DataIn.CaptchaFile   := ThreadData.DataIn.CaptchaPath+ThreadData.ID+'.png';
  ThreadData.DataIn.DataType      := 1;
  ThreadData.DataIn.Referer       := ThreadData.DataOut.Referer;
  CookiesAdd(ThreadData.DataOut.Cookie);
  ErrorInProgram                  := ThreadData.DataOut.Error;
end;

procedure TSearchLinkThread.DataPreparation4;
var PageHtml : string;
begin
  if Inspect then else exit;
  PageHtml := ThreadData.DataOut.PageHtml;
  ThreadData.DataIn.Url:=LastUrl;
  ThreadData.DataIn.DataPost.Add('DownloadCaptchaForm[captcha]='+TextCap);
  ThreadData.DataIn.DataPost.Add(ValueA+'='+ValueB);
  ThreadData.DataIn.DataType         := 0;
  ThreadData.DataIn.Referer          := ThreadData.DataOut.Referer;
  CookiesAdd(ThreadData.DataOut.Cookie);
  ErrorInProgram                     := ThreadData.DataOut.Error;
end;


procedure TSearchLinkThread.DataPreparation5;
begin
 if Inspect then else exit;
 LinkInProgram:=SearchParam2(ThreadData.DataOut.PageHtml,
 'var timer = setTimeout("document.location.href=''',48,'''',1);

 if Trim(LinkInProgram)='' then ErrorInProgram:='LINK_NOT_FOUND'
 else ErrorInProgram:=ThreadData.DataOut.Error;

 RefererInProgram := ThreadData.DataOut.Referer;
 CookiesAdd(ThreadData.DataOut.Cookie); //ThreadData.DataIn.Cookie.AddStrings(ThreadData.DataOut.Cookie);
 CookieInProgram  := ThreadData.DataIn.Cookie.Text;
end;


////////////////////////////////////////////////////////////////////////////////


function TSearchLinkThread.CheckResultRequest:boolean;
begin
 result:=false;
 if (ThreadData.DataOut.Status = 'sRequestDone') then
 begin
  Result:=true;
  ThreadData.DataOut.Status := '';
 end;
end;

procedure TSearchLinkThread.Get;
begin
if Inspect then else exit;
if (Terminated=false) then GetInContainer(ThreadData.ID);
  repeat
   CheckResultRequest; sleep(100);
  until (CheckResultRequest=true) or (Terminated);
end;

procedure TSearchLinkThread.Post;
begin
if Inspect then else exit;
if (Terminated=false) then PostInContainer(ThreadData.ID);
  repeat
   CheckResultRequest; sleep(100);
  until (CheckResultRequest=true) or (Terminated);
end;

function TSearchLinkThread.CheckResultLog:boolean;
begin
 result:=false;
 if (ThreadData.DataOut.Status = 'sLogDone') then
 begin
  Result:=true;
  ThreadData.DataOut.Status := '';
 end;
end;

procedure TSearchLinkThread.Log(LogText:string);
begin
if (Terminated=false) then LogInContainer(ThreadData.ID,LogText);
  repeat
   CheckResultLog; sleep(100);
  until (CheckResultLog=true) or (Terminated);
end;

procedure TSearchLinkThread.CookiesAdd(Cookies:TStringList);
var I: integer;
begin
  for I := 0 to Cookies.Count - 1 do
  begin
    if ThreadData.DataIn.Cookie.IndexOf(Cookies[I]) = -1 then
       ThreadData.DataIn.Cookie.Add(Cookies[I]);
  end;
end;

function TSearchLinkThread.SearchParam1(Page:String;Value:String;
 Plus:Integer):string;
var nBegin : Integer;
begin
 nBegin := Pos (Value, Page);
 if nBegin <> 0
 then result := Copy (Page, nBegin + Plus, 1000000)
 else result:='';
end;

function TSearchLinkThread.SearchParam2(Page:String;Value:String;
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

function TSearchLinkThread.CheckResultRecognition:boolean;
begin
result:=false;
if (ThreadData.DataOut.Status = 'sCompleteRecognition') then
 begin
  if FindErrorRecognition(ThreadData.DataOut.ResultRecognition)=true
  then ErrorInProgram:=ThreadData.DataOut.ResultRecognition
  else TextCAP:=ThreadData.DataOut.ResultRecognition;
  Result:=true;
  ThreadData.DataOut.Status := '';
 end;
end;

procedure TSearchLinkThread.StartRecognition;
begin
if Inspect then else exit;
if (Terminated=false) then RecognitionInContainer(ThreadData.ID);
 repeat
   CheckResultRecognition;
   sleep(100);
 until (CheckResultRecognition=true) or (Terminated);
end;

procedure TSearchLinkThread.StartDownloadTicket(DTTime:integer);
var i,g:integer;
    DT:integer;
begin
  if Inspect then else exit;
  DTInContainer(ThreadData.ID,IntToStr(DTTime),IntToStr(DTTime));
  for i:=0 to DTTime do
  begin
    if Terminated then break else
    begin
     for g:=0 to 20 do if Terminated=false then sleep(50) else break;
     DT:=DTTime-i;
     DTInContainer(ThreadData.ID,IntToStr(DTTime),IntToStr(DT));
    end;
  end;
end;

function TSearchLinkThread.Inspect:boolean;
begin
 if (ErrorInProgram='') and (not Terminated)
 then Result:=true else Result:=false;
end;

end.
