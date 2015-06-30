{
 this file is part of Ares
 Aresgalaxy ( http://aresgalaxy.sourceforge.net )

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either
  version 2 of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}

{
Description:
main bittorrent classes
}

unit btcore;

interface

uses
 classes,classes2,windows,sysutils,torrentparser,{comettrees,}
 bdecode,hashes,blcksock,Contnrs,ares_objects,StrUtils, Dialogs, uExtraData{,
 tntsysutils};

const
 NO_ERROR=0;
 ERROR_OFFSET_OUTOFRANGE=1;
 ERROR_READ_BEYONDLIMIT=2;
 ERROR_WRITE_BEYONDLIMIT=3;
 ERROR_STREAM_LOCKED    = 4;

type

  tbittorrenttrackerStatus=(bttrackerUDPConnecting,
                            bttrackerUDPReceiving,
                            bttrackerConnecting,
                            bttrackerreceiving,
                            bttrackerReadyUpdate);
  TBitTorrentTracker=class(TObject)
  public
    ThreadHandle:THandle;
    CreatedThreadTracker:Boolean;
    host:string;
    port:word;
    URL:string;
    visualStr:string;
    FError:string;
    BufferReceive:string;
    Interval,
    Next_Poll:cardinal;
    ipC:cardinal;
    portW:word;
    TrackerID,WarningMessage:string;
    Leechers:cardinal;
    Seeders:cardinal;
    Status:tbittorrenttrackerStatus;
    socket:ttcpblocksocket;
    socketUDP:hsocket;
    isudp:boolean;
    UDPtranscationID:cardinal;
    UDPconnectionID:int64;
    UDPevent:Cardinal;
    UDPKey:cardinal;
    tick:cardinal;
    alreadyStarted,alreadyCompleted:boolean;
    download:pointer;
    CurrTrackerEvent:string;
    isScraping:boolean;
    constructor Create();
    destructor Destroy(); override;
    function Load(Stream:TStream):Boolean;
    function ParseScrape(stream:TStream):boolean;
    function SupportScrape:boolean;
  end;

 type
 TBitTorrentFile=class(Tobject)
  foffset:int64;
  fsize:int64;
  fstream:THandleStream;
  ffilename:string;
  fprogress:int64;
  fowner:TObject;
  modify_date:cardinal;
  constructor create(const rootpath:string; const fname:string; offset:int64; size:int64;
   lowner:TObject; allowCreate:Boolean; themodify_time:cardinal; createLoaded:Boolean);
  destructor destroy; override;
  procedure erase;
  procedure FillZeros;
  procedure update_modify_date;
  procedure read(offsetRead:int64; destination:pointer; len:int64; var bytesProcessed:int64);
  procedure write(offsetWrite:int64; source:pointer; len:int64; var bytesProcessed:int64);
 end;


 TBittorrentBitField=class(TObject)
  bits:array of boolean;
  constructor create(ItemsCount:integer);
  procedure initWithBitField(const bitstring:string);
  destructor destroy; override;
 end;


 type
 TBitTorrentChunk=class(Tobject)
  checked,
  downloadable,
  preview:boolean;
  priority:byte;
  pieces:array of boolean;
  CheckSum:array[0..19] of byte;
  fowner:TObject;
  foffSet:int64;
  fsize:cardinal;
  popularity:word;
  findex:cardinal;
  fprogress:cardinal;
  assignedSource:pointer; 
  constructor create(owner:TObject; offset:int64; size:int64; index:cardinal; pdl:boolean);
  destructor destroy; override;
  procedure check;
  procedure nullChunk;
 end;

 precord_BitTorrentoutgoing_request=^record_BitTorrentoutgoing_request;
 record_BitTorrentoutgoing_request=record
  index:integer;
  offset:cardinal;
  wantedLen:cardinal;
  requestedTick:cardinal;
  source:cardinal;
  requested:integer;
 end;  

 tBittorrentTransfer=class(tobject)
  ThreadHandle:THandle;
  CreatedThreadTransfer:Boolean;
  want_cancelled:Boolean;
  want_paused:Boolean;
  //id:String;
  ffiles:tmylist;
  fsize:int64;
  FDlSpeed,FUlSpeed:cardinal;
  peakSpeedDown:cardinal;
  fdownloaded,fuploaded,tempDownloaded,tempUploaded:int64;
  fpieceLength:cardinal;
  fpieces:array of TBitTorrentChunk;
  isPrivate:boolean;
  trackers:tmylist;
  trackerIndex:integer;
  fid:string;
  fprogressive:boolean;
  fname,fcomment,fhashvalue:string;
  fdate:cardinal;
  dbstream:ThandleStream;
  ferrorCode:integer;
  uploadtreeview,finishedSeeding:boolean;
//  visualNode:pcmtvnode;
  visualData:precord_displayed_bittorrentTransfer;
  fstate:TDownloadState;
  fseeding:boolean;
  fsources:tmylist;
  numConnected:integer;
  outGoingRequests:tmylist;
  optimisticUnchokedSources:tmylist;
  changedVisualBitField:boolean;
  start_date,m_elapsed,lastUpdateDb,lastFlushBannedIPs:cardinal;
  hashFails:cardinal;
  NumConnectedSeeders,NumConnectedLeechers:cardinal;
  NumConnectedSeedersDHT,NumConnectedLeechersDHT:cardinal;
  m_lastudpsearch:cardinal;

  uploadSlots:Tmylist;
  bannedIPs:tMyStringlist;
  ut_metadatasize:integer;
  tempmetastream:thandlestream;
  metafilenameS:string;
  procedure read(offset:int64; destination:pchar; bytesCount:int64; var remaining:int64; var errorCode:integer);
  procedure write(offset:int64; source:pchar; bytesCount:int64; var remaining:int64; var errorCode:integer);
  function FindFileAtOffset(offSet:int64; var Index:integer):TBitTorrentFile;
  function serialize_bitfield:string;
  procedure init(const rootpath:string; info:TTorrentParser);
  procedure initFrom_ut_Meta;
  constructor create;
  destructor destroy; override;
  procedure FreeChunks;
  procedure freeFiles(eraseAll:boolean=false);
  procedure addTracker(URL:string);
  procedure wipeout;
  procedure update_file_dates;
//  procedure AddVisualGlobSource;//sync
  procedure addSource(const ip:string; port:word; const ID:string; const sourcestr:string); overload;
  procedure addSource(ipC:cardinal; port:word; const ID:string; const sourcestr:string; removeExceeding:boolean=true); overload;
  procedure CalculateFilesProgress;
  procedure IncFilesProgress(chunk:TBitTorrentChunk);
  function isCompleted:boolean;
  function isEndGameMode:boolean;
  procedure DoComplete;
  procedure CalculateLeechsSeeds;
  procedure useNextTracker;
 end;

   type
  TBittorrentSourceStatus=(btSourceIdle,
                           btSourceConnecting,
                           btSourceReceivingHandshake,
                           btSourceweMustSendHandshake,
                           btSourceShouldDisconnect,
                           btSourceShouldRemove,
                           btSourceConnected);

  type
  precord_Displayed_source=^record_Displayed_source;
  record_Displayed_source=record
   sourceHandle:cardinal;
   IpS:string;
   port:word;
   ID:string;
   client:string;
   foundby:string;
   status:tbittorrentSourceStatus;
   VisualBitField:TBitTorrentBitField;
   choked,interested,weAreChoked,weAreInterested,isOptimistic:boolean;
   sent,recv:int64;
   speedUp,speedDown:cardinal;
   size:int64;
   FPieceSize:cardinal;
   progress:cardinal;
   should_disconnect:boolean;//set by the GUI
  end;

  TBitTorrentOutPacket=class(TObject)
   priority:boolean;
   isFlushing:boolean;
   payload:string;
   ID:Byte;
   findex,
   foffset,
   fwantedLen:cardinal;
   constructor create;
   destructor destroy; override;
  end;

  TBitTorrentSlotType=(ST_None,ST_Optimistic,ST_Normal);

  type
  tbittorrentSource=class(TObject)
   IpC:cardinal;
   port:word;
   ID,ipS,Client:string;
   bitfield:TBittorrentBitField;
   progress:int64;
   status:TbittorrentSourceStatus;
   socket:ttcpblocksocket;
   foundby:string;
   failedConnectionAttempts,
   hashFails:byte;   // num blocks corrupted when working in contiguous chunk request mode
   blocksReceived:cardinal; //num blocks received and checked       "          "
   isChoked,isInterested,weArechoked,weAreInterested:boolean;
   SendBitfield,changedVisualBitField:boolean;
   outBuffer:tmylist;
   inBuffer:string;
   bytes_in_header:byte;

   tick,
   lastAttempt,
   lastKeepAliveIn,
   lastKeepAliveOut,
   handshakeTick,
   lastDataIn,
   lastDataOut,
   uptime:cardinal;
   NumBytesToSendPerSecond:integer;

   header:array[0..3] of byte;
   dataDisplay:precord_Displayed_source;
//   nodeDisplay:PCmtVNode;
   sent,recv:int64;
   bytes_recv_before,bytes_sent_before:cardinal;
   speed_recv,speed_send,speed_send_max,speed_recv_max:cardinal;
   assignedChunk:TBitTorrentChunk;
   outRequests:byte;

   SlotTimeout:cardinal;
   SlotType:TBitTorrentSlotType;
   NumOptimisticUnchokes:integer; //keeps track of how many times it has been unchoked

   Snubbed,IsIncomingConnection:boolean;

   SupportsExtensions,
   SupportsFastPeer,
   SupportsDHT:boolean;

   portDHT:word;

   ut_pex_opcode:byte;
   ut_metadata_opcode:byte;
   allowedfastpieces:array of tbittorrentchunk;
   
   constructor create;
   destructor destroy; override;
   procedure ClearOutBuffer;
   function isSeeder:boolean;
   function isLeecher:boolean;
   function hasNoChunks:boolean;
   function isNotAzureus:boolean;
  end;


  procedure CloneBitfield(Source:TBitTorrentBitfield; Destination:TBitTorrentBitfield); overload;
  procedure CloneBitfield(transfer:TBitTorrentTransfer); overload;
  procedure CloneBitfield(Source:TBitTorrentBitfield; Destination:TBitTorrentBitfield; var progress:cardinal); overload;
  function SourceIsDuplicate(transfer:TBittorrentTransfer; ipC:cardinal):boolean;
  function PurgeExceedingSource(transfer:TBitTorrentTransfer):boolean;
  function CalcProgressFromBitField(source:TBitTorrentSource):integer;
  procedure AddBannedIp(transfer:TBitTorrentTransfer; ip:cardinal);
  function IsBannedIp(transfer:TBitTorrentTransfer; ip:cardinal):boolean;

implementation

uses
 {ufrmmain,}helper_diskio,BittorrentStringfunc,{tntwindows,}securehash,
 BitTorrentDlDb,helper_datetime,bittorrentConst,
 helper_sorting,thread_bitTorrent,vars_global,helper_unicode,helper_ipfunc,
 helper_strings,ares_types,const_ares;

procedure AddBannedIp(transfer:TBittorrentTransfer; ip:cardinal);
var
ipS:string;
begin
ipS:=int_2_dword_string(ip);
if transfer.bannedIPs=nil then begin
 transfer.bannedIPs:=TMyStringList.create;
 transfer.bannedIPs.add(ipS);
end;
if transfer.bannedIPs.indexof(ipS)<>-1 then exit;

 transfer.bannedIPs.add(ipS);
end;

function IsBannedIp(transfer:TBitTorrentTransfer; ip:cardinal):boolean;
var
ipS:string;
begin
result:=false;

if transfer.BannedIPs=nil then exit;

ipS:=int_2_dword_string(ip);
result:=(transfer.BannedIPs.indexof(ips)<>-1);
end;

function CalcProgressFromBitField(source:TBitTorrentSource):integer;
var
i:integer;
numHave,numTotal:extended;
begin
numHave:=0;
 result:=0;
numTotal:=length(source.bitfield.bits);
for i:=0 to high(source.bitfield.bits) do if source.bitfield.bits[i] then numHave:=numHave+1;
if numTotal=0 then exit;
 result:=trunc((numHave/numTotal) * 100);
end;

procedure CloneBitfield(Source:TBitTorrentBitfield; Destination:TBitTorrentBitfield);
var
i:integer;
begin
if source=nil then exit;
if length(source.bits)=0 then exit;
if destination=nil then exit;
if length(destination.bits)=0 then exit;
if length(destination.bits)<>length(source.bits) then exit;

for i:=0 to high(Source.bits) do Destination.bits[i]:=source.bits[i];
end;

procedure CloneBitfield(Source:TBitTorrentBitfield; Destination:TBitTorrentBitfield; var progress:cardinal);
var
i:integer;
num,tot:extended;
begin
progress:=0;
num:=0;

if source=nil then exit;
if destination=nil then exit;
if length(source.bits)=0 then exit;
if length(destination.bits)<>length(source.bits) then SetLength(destination.bits,length(source.bits));

for i:=0 to high(Source.bits) do begin
 Destination.bits[i]:=source.bits[i];
 if source.bits[i] then num:=num+1;
end;

tot:=length(source.bits);
progress:=round((num/tot)*100);
end;

procedure CloneBitfield(transfer:TBitTorrentTransfer);
var
i:integer;
piece:TBitTorrentChunk;
begin
if length(transfer.visualData.bitfield)=0 then exit;

if length(transfer.visualData.bitfield)<>length(transfer.FPieces) then exit;

for i:=0 to high(transfer.FPieces) do begin
 piece:=transfer.fpieces[i];
 transfer.visualData.bitfield[i]:=piece.checked;
end;
end;


////////  TBitTorrentOutPacket
constructor TBitTorrentOutPacket.create;
begin
isFlushing:=false;
end;

destructor TBitTorrentOutPacket.destroy;
begin
payload:='';
inherited;
end;


//** {tbittorrentSource} *************************

constructor tbittorrentSource.create;
begin
socket:=nil;
status:=btSourceIdle;
lastAttempt:=0;
progress:=0;
failedConnectionAttempts:=0;
tick:=0;
hashFails:=0;
blocksReceived:=0;
IsIncomingConnection:=false;
SlotTimeout:=0;
SlotType:=ST_None;
NumOptimisticUnchokes:=0;
Snubbed:=false;
outRequests:=0;
NumBytesToSendPerSecond:=0;
ipS:='';
client:='';
ID:='';
outbuffer:=tmylist.create;
inbuffer:='';
SendBitfield:=false;
changedVisualBitField:=false;
bitfield:=nil;
bytes_in_header:=0;
dataDisplay:=nil;
//nodeDisplay:=nil;
assignedChunk:=nil;
lastDataIn:=0;
lastDataOut:=0;
sent:=0;
recv:=0;
ut_pex_opcode:=1;
ut_metadata_opcode:=2;
bytes_recv_before:=0;
bytes_sent_before:=0;
speed_recv:=0;
speed_send:=0;
speed_send_max:=0;
speed_recv_max:=0;
lastKeepAliveIn:=0;
portDHT:=0;
lastKeepAliveOut:=0;
handshakeTick:=0;
SupportsExtensions:=false;
SupportsFastPeer:=false;
SupportsDHT:=false;
setlength(allowedfastpieces,0);
end;

procedure TBitTorrentSource.ClearOutBuffer;
var
 outpacket:TBitTorrentOutPacket;
begin
while (outbuffer.count>0) do begin
 outpacket:=outbuffer[outbuffer.count-1];
            outbuffer.delete(outbuffer.count-1);
 outpacket.free;
end;
end;



function tBittorrentSource.isSeeder:boolean;
begin
result:=(progress=100);
end;

function tBittorrentSource.isNotAzureus:boolean;
begin
result:=(copy(client,1,7)<>'Azureus');
end;

function tBitTorrentSource.isLeecher:boolean;
begin
result:=(progress<>100);
end;

function tBitTorrentSource.hasNoChunks:boolean;
var
i:integer;
begin
result:=true;
if bitfield=nil then exit;
if length(bitfield.bits)=0 then exit;

 for i:=0 to high(bitfield.bits) do
  if bitfield.bits[i] then begin
   result:=False;
   exit;
  end;
end;

destructor tbittorrentSource.destroy;
begin
if socket<>nil then socket.free;
id:='';
ipS:='';
client:='';
ClearOutBuffer;
outbuffer.free;
inbuffer:='';
setlength(allowedfastpieces,0);
if bitfield<>nil then bitfield.free;
 inherited;
end;


//************************* TBittorrentBitField *******************************


constructor TBittorrentBitField.create(ItemsCount:integer);
var
i:integer;
begin
//if (itemsCount mod 8)<>0 then inc(itemsCount, (8-(itemsCount mod 8)) );
setLength(bits,ItemsCount);
for i:=0 to high(bits) do bits[i]:=false;
end;

procedure TBitTorrentBitField.initWithBitField(const bitstring:string);
var
i,len,posi,sposi:integer;
begin
len:=length(bitstring);

if high(bits)<((len-1)*8) then begin
 exit;
end;

            
for i:=0 to len-1 do begin
  posi:=(8*i);
  sposi:=ord(bitstring[i+1]);

 if i=len-1 then begin
  if high(bits)>=posi+7 then bits[posi+7] := ((sposi and 1)   = 1);
  if high(bits)>=posi+6 then bits[posi+6] := ((sposi and 2)   = 2);
  if high(bits)>=posi+5 then bits[posi+5] := ((sposi and 4)   = 4);
  if high(bits)>=posi+4 then bits[posi+4] := ((sposi and 8)   = 8);
  if high(bits)>=posi+3 then bits[posi+3] := ((sposi and 16)  = 16);
  if high(bits)>=posi+2 then bits[posi+2] := ((sposi and 32)  = 32);
  if high(bits)>=posi+1 then bits[posi+1] := ((sposi and 64)  = 64);
  if high(bits)>=posi then   bits[posi]   := ((sposi and 128) = 128);
 end else begin
  bits[posi+7] := ((sposi and 1)   = 1);
  bits[posi+6] := ((sposi and 2)   = 2);
  bits[posi+5] := ((sposi and 4)   = 4);
  bits[posi+4] := ((sposi and 8)   = 8);
  bits[posi+3] := ((sposi and 16)  = 16);
  bits[posi+2] := ((sposi and 32)  = 32);
  bits[posi+1] := ((sposi and 64)  = 64);
  bits[posi]   := ((sposi and 128) = 128);
 end;
 
end;


end;

destructor TBittorrentBitField.destroy;
begin
setLength(bits,0);
 inherited;
end;


//************************* TBittorrentChunk *************************

constructor TBitTorrentChunk.create(owner:TObject; offset:int64; size:int64; index:cardinal; pdl:boolean);
var
i:integer;
begin
checked:=false;
downloadable:=false;
preview:=false;
if (pdl=true) or (ProgressiveDL=true) then
priority:=(high(pieces)-index)
else
priority:=0;
fOwner:=owner;
foffset:=offset;
fsize:=size;
findex:=index;
assignedSource:=nil;

if (fsize mod BITTORRENT_PIECE_LENGTH)=0 then setLength(pieces,fsize div BITTORRENT_PIECE_LENGTH)
 else begin
  setLength(pieces,(fsize div BITTORRENT_PIECE_LENGTH)+1);
 end;

for i:=0 to high(pieces) do pieces[i]:=false;
fprogress:=0;
end;

destructor TBitTorrentChunk.destroy;
begin
setLength(pieces,0);
inherited;
end;

procedure TBitTorrentChunk.check;
var
sha1:Tsha1;
buffer:array[0..1023] of byte;
bytesprocessed:cardinal;
errorcode,i:integer;
rem:int64;
toread:cardinal;
hashValue:string;
begin
sha1:=tsha1.create;

bytesProcessed:=0;
while (bytesProcessed<fsize) do begin
  toRead:=sizeof(buffer);

  if bytesProcessed+toRead>fsize then toRead:=fsize-bytesProcessed;

  (fowner as TBitTorrentTransfer).read(foffset+bytesProcessed,@buffer,toread,rem,errorCode);
  if rem<>0 then begin
    checked:=false;
    fprogress:=0;
    for i:=0 to high(pieces) do pieces[i]:=false;

   sha1.Free;
   exit;
  end;
  sha1.Transform(buffer[0],toRead-rem);
  inc(bytesProcessed,toRead-rem);
end;

sha1.complete;
 hashValue:=sha1.HashValue;
sha1.free;

if not CompareMem(@HashValue[1],@CheckSum[0],20) then begin
 //corrupted chunk, re-download it
 checked:=false;
// nullChunk;
 for i:=0 to high(pieces) do pieces[i]:=false;

 fprogress:=0;
end else begin
 checked:=true;
 inc((fowner as TBitTorrentTransfer).fdownloaded,fsize);
 (fOwner as TBitTorrentTransfer).IncFilesProgress(self);
    if gettickcount-(fOwner as TBitTorrentTransfer).lastUpdateDb>5*MINUTE then begin
     BitTorrentDb_updateDbOnDisk((fOwner as TBitTorrentTransfer));
     (fOwner as TBitTorrentTransfer).lastUpdateDb:=gettickcount;
    end;
end;


end;

procedure TBitTorrentChunk.nullChunk;
var
written,towrite:cardinal;
buffer:array[0..1023] of byte;
rem:int64;
errorCode,i:integer;
begin
for i:=0 to high(pieces) do pieces[i]:=false;

fillChar(buffer,sizeof(buffer),0);
written:=0;

  while (written<fsize) do begin
    towrite:=sizeof(buffer);

    if written+towrite>fsize then towrite:=fsize-written;

    (fowner as TBitTorrentTransfer).Write(foffset+written,@buffer,towrite,rem,errorCode);

    inc(written,towrite);
  end;

end;

function Tnt_CreateDirectoryW(lpPathName: PWideChar;
  lpSecurityAttributes: PSecurityAttributes): BOOL;
var Win32PlatformIsUnicode : boolean;
begin
Win32PlatformIsUnicode := (Win32Platform = VER_PLATFORM_WIN32_NT);
  if Win32PlatformIsUnicode then
    Result := CreateDirectoryW{TNT-ALLOW CreateDirectoryW}(lpPathName, lpSecurityAttributes)
  else
    Result := CreateDirectoryA{TNT-ALLOW CreateDirectoryA}(PAnsiChar(AnsiString(lpPathName)), lpSecurityAttributes);
end;

constructor TBittorrentFile.create(const rootpath:string; const fname:string; offset:int64; size:int64;
  lowner:TObject; allowCreate:Boolean; themodify_time:cardinal; createLoaded:Boolean);
var
 folder,fnametemp:string;
 iterations:integer;
begin

ffilename:=rootpath+'\'+fname;


tnt_createdirectoryW(pwidechar(utf8strtowidestr(rootpath)),nil);

foffset:=offset;
fsize:=size;

if createLoaded then
begin
fprogress:=fsize;
end
else fprogress:=0;

fowner:=lowner;

// build path
folder:='';
fnametemp:=fname;
iterations:=0;
while (pos('\',fnametemp)>0) do begin
 folder:=folder+'\'+copy(fnametemp,1,pos('\',fnametemp)-1);
            delete(fnametemp,1,pos('\',fnametemp));
 tnt_createdirectoryW(pwidechar(utf8strtowidestr(rootpath+folder)),nil);
 inc(iterations);
 if iterations>100 then break;
end;


if not FileExists(utf8strtowidestr(ffilename)) then begin

  if not allowCreate then begin
   (fowner as TBitTorrentTransfer).ferrorCode:=BT_DBERROR_FILES_LOCKED;
   (fowner as TBitTorrentTransfer).finishedSeeding:=true;
    exit;
  end;
 
  fstream:=MyFileOpen(utf8strtowidestr(ffilename),ARES_OVERWRITE_EXISTING);

  if fstream=nil then begin
   //ShowMessage('0: '+utf8strtowidestr(ffilename));
   (fowner as TBitTorrentTransfer).ferrorCode:=BT_DBERROR_FILES_LOCKED+1+GetLastError;
   if not allowCreate then (fowner as TBitTorrentTransfer).finishedSeeding:=true;
   exit; // show error to user
  end;
  
  if fstream.size<>fsize then fstream.size:=fsize;//FillZeros

  exit;
end;


 fstream:=MyFileOpen(utf8strtowidestr(ffilename),ARES_WRITE_EXISTING);
 //fstream:=MyFileOpen(widestrtoutf8str(ffilename),ARES_WRITE_EXISTING);
 //fstream:=MyFileOpen(utf8strtowidestr(ffilename),ARES_READONLY_ACCESS);

 if fstream=nil then begin
  //ShowMessage('1: '+utf8strtowidestr(ffilename));
  (fowner as TBitTorrentTransfer).ferrorCode:=BT_DBERROR_FILES_LOCKED+1+GetLastError;
  if not allowCreate then (fowner as TBitTorrentTransfer).finishedSeeding:=true;
  exit;
 end;

 if fstream.size<>fsize then begin  // file is already there, but there's a size mismatch
  //ShowMessage('2: ' + IntToStr(fstream.size)+'<>'+IntToStr(fsize));
  (fowner as TBitTorrentTransfer).ferrorCode:=BT_DBERROR_FILES_LOCKED+1;
  FreeHandleStream(fstream);
  if not allowCreate then (fowner as TBitTorrentTransfer).finishedSeeding:=true;
  exit;
 end;

 if allowCreate then update_modify_date else begin
  modify_date:=themodify_time;
  if (fowner as TBitTorrentTransfer).fstate=dlSeeding then
    if helper_diskio.getLastModifiedW(utf8strtowidestr(ffilename))<>modify_date then begin
     (fowner as TBitTorrentTransfer).finishedSeeding:=true;
    end;
 end;

end;

procedure TBitTorrentFile.update_modify_date;
begin
 modify_date:=helper_diskio.getLastModifiedW(utf8strtowidestr(ffilename));
end;

procedure TBitTorrentFile.FillZeros;
var
wanted:int64;
buffer:array[0..1023] of byte;
begin

FillChar(buffer,sizeof(buffer),0);

while fstream.size<>fsize do begin
 wanted:=fsize-fstream.size;
 if wanted>sizeof(buffer) then wanted:=sizeof(buffer);
 fstream.write(buffer,wanted);
end;

end;

procedure TBitTorrentFile.read(offsetRead:int64; destination:pointer; len:int64; var bytesProcessed:int64);
var
position:int64;
begin
bytesProcessed:=0;
try

if fstream=nil then begin
 (fowner as tbittorrentTransfer).ferrorCode:=ERROR_STREAM_LOCKED;
 bytesProcessed:=-1;
 exit;
end;

 while true do begin
  MyFileSeek(fstream,offsetRead,Ord(soFromBeginning));
  position:=MyFileSeek(fstream,0,Ord(soCurrent));
  if position=offsetRead then break;
 end;
 
if len+offsetRead>fstream.size then len:=fstream.size-offsetRead;
if len=0 then exit;

bytesProcessed:=fstream.Read(destination^,len);

except
end;
end;

procedure TBitTorrentFile.write(offsetWrite:int64; source:pointer; len:int64; var bytesProcessed:int64);
var
position:int64;
begin
bytesProcessed:=0;
try

if fstream=nil then begin
 (fowner as tbittorrentTransfer).ferrorCode:=ERROR_STREAM_LOCKED;
 bytesProcessed:=-1;
 exit;
end;

 while true do begin
  MyFileSeek(fstream,offsetWrite,Ord(soFromBeginning));
  position:=MyFileSeek(fstream,0,Ord(soCurrent));
  if position=offsetWrite then break;
 end;


if len+offsetWrite>fstream.size then len:=fstream.size-offsetWrite;
if len=0 then exit;

bytesProcessed:=fstream.Write(source^,len);
except
end;
end;


destructor TBitTorrentFile.destroy;
begin
if fstream<>nil then FreeHandleStream(fstream);
ffilename:='';
inherited;
end;

procedure TBitTorrentFile.erase;
begin
if fStream<>nil then FreeHandleStream(fstream);
helper_diskio.deletefileW(utf8strtowidestr(ffilename));
end;



constructor tBitTorrentTransfer.create;
begin
uploadtreeview:=false;
fname:='';
fcomment:='';
fhashValue:='';
fSize:=0;
fPieceLength:=0;
fDownloaded:=0;
fUploaded:=0;
finishedSeeding:=false;
tempDownloaded:=0;
lastUpdateDb:=0;
tempUploaded:=0;
trackerIndex:=0;
fdate:=0;
FDlSpeed:=0;
FUlSpeed:=0;
peakSpeedDown:=0;
setLength(fPieces,0);
hashFails:=0;
numConnected:=0;
NumConnectedSeeders:=0;
NumConnectedLeechers:=0;
fErrorCode:=0;
fFiles:=nil;
dbstream:=nil;
fstate:=dlprocessing;
fsources:=tmylist.create;
trackers:=tmylist.create;
changedVisualBitField:=true;
outGoingRequests:=tmylist.create;
optimisticUnchokedSources:=tmylist.create;
start_date:=DelphiDateTimeToUnix(now);
lastFlushBannedIPs:=gettickcount;
uploadSlots:=tmylist.create;
bannedIPs:=nil;
tempmetastream:=nil;
metafilenameS:='';
ut_metadatasize:=0;
m_lastudpsearch:=0;
m_elapsed:=0;
end;

function tBittorrentTransfer.isCompleted:boolean;
begin
result:=(fdownloaded=fsize) and (fsize>0);
end;

function tBittorrentTransfer.isEndGameMode:boolean;
begin
result:=((fsize-fdownloaded)<(fsize div 100)) or
        ((fsize-fdownloaded)<(BITTORRENT_PIECE_LENGTH*100));
end;


procedure tBittorrentTransfer.initFrom_ut_Meta;
var
 Parser:TTorrentParser;
 torrentName:string;
 i:integer;
 ffile:TBittorrentFile;
 source:tbittorrentSource;
 sha1:tsha1;
 len:integer;
 buffer:array[0..1023] of char;
 wrongmeta:boolean;
begin
 fstate:=dlAllocating;
 ferrorCode:=0;

 // check hash
 wrongmeta:=true;
 tempmetastream.position:=0;
 sha1:=tsha1.create;
 while (tempmetastream.position<tempmetastream.size) do begin
  len:=tempmetastream.read(buffer,sizeof(buffer));
  sha1.Transform(buffer,len);
  if len<sizeof(buffer) then break;
 end;
 sha1.Complete;
 if sha1.HashValue<>self.fhashvalue then begin  
  wrongmeta:=true;
 end else begin
  wrongmeta:=false;
 end;
 sha1.free;

 if wrongmeta then begin
  fstate:=dlBittorrentMagnetDiscovery;
  tempmetastream.size:=0;
  ut_metadatasize:=0;
  exit;
 end;

  tempmetastream.position:=0;
 tempmetastream.position:=0;
 Parser:=TTorrentParser.Create;
 Parser.Load(tempmetastream);

 torrentName:=parser.name;
 TorrentName:=StripIllegalFileChars(TorrentName);
 //ftorrentFolder:=torrentPath;

 if length(TorrentName)>200 then delete(TorrentName,200,length(TorrentName));

   if length(torrentName)=0 then torrentName:=bytestr_to_hexstr(parser.hashValue);
   
 {Torrent name already in download?}
   if direxistsW(vars_global.my_torrentFolder+'\'+utf8strtowidestr(torrentName)) then begin
     if FileExists(vars_global.data_Path+'\Data\TempDl\PBTHash_'+bytestr_to_hexstr(parser.hashValue)+'.dat') then begin
       parser.free;
       FreeHandleStream(tempmetastream);
       exit;
     end;

   torrentName:=torrentName+inttohex(random($ff),2)+inttohex(random($ff),2);
   end;
   while direxistsW(vars_global.my_torrentFolder+'\'+utf8strtowidestr(torrentName)) do
    torrentName:=copy(torrentName,1,length(torrentName)-4)+inttohex(random($ff),2)+inttohex(random($ff),2);
  //////////////////////////////////////////

 tnt_createdirectoryW(pwidechar(vars_global.my_torrentFolder),nil);
 if parser.Files.count>1 then tnt_createdirectoryW(pwidechar(vars_global.my_torrentFolder+'\'+utf8strtowidestr(torrentName)),nil);



 freeHandlestream(tempmetastream);

  init(widestrtoutf8str(vars_global.my_torrentFolder)+'\'+torrentName,
       Parser);

 parser.free;
 // let thread_bittorrent know when file is ready for writing
for i:=0 to ffiles.count-1 do begin
 ffile:=ffiles[i];

 FreeHandleStream(ffile.fstream);
 while true do begin
 ffile.fstream:=MyFileOpen(utf8strtowidestr(ffile.ffilename),ARES_WRITE_EXISTING);
 if ffile.fstream<>nil then break else sleep(10);
 end;
end;

 fstate:=dlProcessing;

 for i:=0 to fsources.count-1 do begin
 source:=fsources[i];

  if source.status=btSourceIdle then continue;
   if source.status=btSourceShouldRemove then continue;
    if source.status=btSourceShouldDisconnect then continue;

      source.NumOptimisticUnchokes:=0;
      source.socket.free;
      source.socket:=nil;
      source.bytes_in_header:=0;
      source.ClearOutBuffer;
      source.inbuffer:='';
      source.status:=btSourceIdle;
      source.outRequests:=0;
      source.lastAttempt:=0;
 end;


  deletefileW(utf8strtowidestr(metafilenameS));
  metafilenameS:='';

end;

procedure tBittorrentTransfer.init(const rootpath:string; info:TTorrentParser);
var
ThisFile:TTorrentSubFile;
i,h:integer;
newfile:TBitTorrentFile;
piece:TTorrentPiece;
chunk:TBitTorrentChunk;

//str:string;
chunkOffset:int64;
chunkSize:int64;
ffile:TBitTorrentFile;

//tracker:TBitTorrentTracker;
begin
 fstate:=dlAllocating;
 ferrorCode:=0;

 fname:=rootpath;
 fid:=info.ID;
 fprogressive:=info.Progressive;

  if info._announces.count>0 then begin
   for i:=0 to info._announces.count-1 do addTracker(info._announces[i]);
  end else addTracker(info._announce);

 fcomment:=info.comment;
 fpieceLength:=info.PieceLength;
 fsize:=info.Size;
 fhashvalue:=info.hashValue;
 fdate:=helper_datetime.delphidatetimeToUnix(info.Date);
 isPrivate:=info.isPrivate;

SetLength(fPieces,length(info.pieces));

chunkOffset:=0;

for i:=0 to high(info.pieces) do begin

 piece:=info.Pieces[i];

 chunkSize:=info.PieceLength;

 if i=high(info.pieces) then
  if chunkOffset+ChunkSize>info.Size then begin
   ChunkSize:=info.size-chunkOffset; //last chunk usually shorter
  end;

 chunk:=TBitTorrentChunk.create(self,chunkOffset,chunkSize,i,fprogressive);
  move(piece.HashValue[0],chunk.checksum[0],20);
  fPieces[i]:=chunk;

 chunkOffset:=chunkOffset+chunkSize;
end;

 if ffileS=nil then ffileS:=tmylist.create;
 if info.Files.count=1 then begin
  thisfile:=(info.Files[0] as TTorrentSubFile);
  thisfile.Name:=extractfilename(fname);

  if {FileExists(vars_global.my_torrentFolder+'\'+utf8strtowidestr(thisfile.Path+thisfile.Name)) and}
  (fseeding=true)
  then
  begin
    {if FileExists(vars_global.my_torrentFolder+'\'+utf8strtowidestr(thisfile.Path+thisfile.Name)) then
    showmessage('FileExists1: '+(vars_global.my_torrentFolder)+'\'+utf8strtowidestr(thisfile.Path+thisfile.Name))
    else
    showmessage('FileNotExists1: '+(vars_global.my_torrentFolder)+'\'+utf8strtowidestr(thisfile.Path+thisfile.Name));
    }
    //RenameFile((vars_global.my_torrentFolder)+'\'+utf8strtowidestr(thisfile.Path+thisfile.Name),(vars_global.my_torrentFolder)+'\'+utf8strtowidestr(thisfile.Path+'__INCOMPLETE__'+thisfile.Name));
    newfile:=TBitTorrentFile.create(widestrtoutf8str(vars_global.my_torrentFolder),
                                     thisfile.Path+{'__INCOMPLETE__'+}thisfile.Name,
                                     thisfile.Offset,
                                     thisfile.Length,
                                     self,
                                     false,
                                     0,
                                     false);
    if self.fErrorCode<>0 then begin
    //showmessage('fErrorCode: '+IntToStr(self.fErrorCode)); 
    exit;
   end;
   //fstate:=dlSeeding;//  dlCompleted;
   fdownloaded:=fsize;

   for h:=0 to high(fpieces) do begin
   chunk:=fpieces[h];
   if (fprogressive=true) or (ProgressiveDL=true) then
   chunk.priority:=(high(fpieces)-h)
   else
   chunk.priority:=0;
   chunk.downloadable:=true;
   chunk.checked:=true;
   chunk.fprogress:=chunk.fsize;
   end;
    //showmessage('12344');
   uploadtreeview:=true;
   ffiles.add(newfile);
   DoComplete;
   //showmessage('qwertyu');
  end else
  begin
     newfile:=TBitTorrentFile.create(widestrtoutf8str(vars_global.my_torrentFolder),
                                     thisfile.Path+'__INCOMPLETE__'+thisfile.Name,
                                     thisfile.Offset,
                                     thisfile.Length,
                                     self,
                                     true,
                                     0,
                                     false);

   if self.fErrorCode<>0 then begin
    exit;
   end;
   ffiles.add(newfile);
  end;

 end else  begin

  for i:=0 to info.Files.count-1 do
  begin
    thisfile:=(info.Files[i] as TTorrentSubFile);
    thisfile.Name:=StripIllegalFileChars(thisfile.Name);
    if length(thisfile.Name)>200 then thisfile.name:=copy(thisfile.name,1,200);

    if (fseeding=true) then
    begin
      //RenameFile(thisfile.Path+thisfile.Name,thisfile.Path+'__INCOMPLETE__'+thisfile.Name);
      newfile:=TBitTorrentFile.create(rootpath,
                                   thisfile.Path+{'__INCOMPLETE__'+}thisfile.Name,
                                   thisfile.Offset,
                                   thisfile.Length,
                                   self,
                                   false,
                                   0,
                                   false);
      if self.fErrorCode<>0 then begin
       exit;
      end;  
      ffiles.add(newfile);    
    end
    else
    begin
      if FileExists(thisfile.Path+thisfile.Name) then
      begin
        //showmessage('FileExists2: '+thisfile.Path+thisfile.Name);
        RenameFile(thisfile.Path+thisfile.Name,thisfile.Path+'__INCOMPLETE__'+thisfile.Name);
      end;
     newfile:=TBitTorrentFile.create(rootpath,
                                   thisfile.Path+'__INCOMPLETE__'+thisfile.Name,
                                   thisfile.Offset,
                                   thisfile.Length,
                                   self,
                                   true,
                                   0,
                                   false);

     if self.fErrorCode<>0 then begin
      exit;
     end;
     ffiles.add(newfile);
    end;
  end;

    if (fseeding=true) then
    begin
      for h:=0 to high(fpieces) do begin
        chunk:=fpieces[h];
        if (fprogressive=true) or (ProgressiveDL=true) then
        chunk.priority:=(high(fpieces)-h)
        else
        chunk.priority:=0;
        chunk.downloadable:=true;
        chunk.checked:=true;
        chunk.fprogress:=chunk.fsize;
      end;
      fdownloaded:=fsize;
      uploadtreeview:=true;
      DoComplete;
    end
    else
    begin

     {for i:=0 to ffiles.count-1 do begin
     ffile:=ffiles[i];

      for h:=0 to high(fpieces) do begin
      chunk:=fpieces[h];

      if i=1 then
      begin
      if ((chunk.foffSet+chunk.fsize)>ffile.foffset) and (chunk.foffset<(ffile.foffset+ffile.fsize)) then
      chunk.priority:=(high(fpieces)-h)//0;//high(fpieces)+100//
      else chunk.priority:=1;
      end
      else chunk.priority:=1;


      if (chunk.foffSet+chunk.fsize)<=ffile.foffset then continue;
      if chunk.foffset>(ffile.foffset+ffile.fsize) then continue;

      NumBytes:=chunk.fsize;
      if chunk.foffSet<ffile.foffset then dec(NumBytes,ffile.foffset-chunk.foffSet);
      if chunk.foffSet+chunk.fsize>ffile.foffset+ffile.fsize then dec(NumBytes,(chunk.foffSet+chunk.fsize)-(ffile.foffset+ffile.fsize));

      if chunk.checked then inc(ffile.fprogress,NumBytes);
      chunk.downloadable:=true;
       if BytesAddedPreview<5*MEGABYTE then
       begin
        chunk.preview:=true;
        inc(BytesAddedPreview,NumBytes);
       end;
      end;
     end;}

    end;
 end;

//DoComplete;

BitTorrentDb_updateDbOnDisk(self);

CalculateFilesProgress;

end;


procedure tBittorrentTransfer.FreeChunks;
var
i:integer;
chunk:TBitTorrentChunk;
begin
for i:=0 to high(fpieces) do begin
 if fpieces[i]=nil then continue;
 chunk:=fpieces[i];
 chunk.free;
end;
setLength(fpieces,0);
end;

procedure tbittorrentTransfer.update_file_dates;
var
thisfile:TBitTorrentFile;
i:integer;
begin
for i:=0 to ffiles.count-1 do begin
 thisfile:=ffiles[i];
 thisfile.update_modify_date;
end;
end;

procedure tBitTorrentTransfer.freeFiles(eraseAll:boolean=false);
var
thisfile:TBitTorrentFile;
begin
if ffiles=nil then exit;

while (ffiles.count>0) do begin
 thisfile:=ffiles[ffiles.count-1];
           ffiles.delete(ffiles.count-1);
 if eraseAll then thisfile.erase;
 thisfile.free;
end;

FreeAndNil(ffiles);
end;

destructor tBittorrentTransfer.destroy;
var
 source:TBittorrentSource;
 request:precord_BitTorrentOutgoing_Request;
 tracker:tbittorrentTracker;
begin

uploadSlots.free;
try
FreeChunks;
except
end;

try
FreeFiles;
except
end;

try
bitTorrentDb_CheckErase(self);
except
end;


while (trackers.count>0) do begin
 tracker:=trackers[trackers.count-1];
          trackers.delete(trackers.count-1);
 tracker.free;
end;

try
while (fsources.count>0) do begin
  source:=fsources[fsources.count-1];
          fsources.delete(fsources.count-1);
  source.free;
end;
except
end;
fsources.free;

try
while (outGoingRequests.count>0) do begin
 request:=outGoingRequests[outGoingRequests.count-1];
          outGoingRequests.delete(outGoingRequests.count-1);
 FreeMem(request,sizeof(record_BitTorrentOutgoing_Request));
end;
except
end;
outGoingRequests.free;
optimisticUnchokedSources.free;
fname:='';
fcomment:='';
fhashValue:='';
if bannedIPs<>nil then bannedIPs.free;
if tempmetastream<>nil then freeHandleStream(tempmetastream);
if length(metafilenameS)>0 then begin
 deletefileW(utf8strtowidestr(metafilenameS));
 metafilenameS:='';
end;
inherited;
end;

procedure tBitTorrentTransfer.CalculateLeechsSeeds;
var
i:integer;
source:TBitTorrentSource;
begin

NumConnectedSeeders:=0;
NumConnectedLeechers:=0;

 for i:=0 to fsources.count-1 do begin
  source:=fsources[i];
  if source.status<>btSourceConnected then continue;
  if source.progress<100 then
  begin
    inc(numConnectedLeechers);
    if AnsiLowerCase(source.foundby)='dht' then
    inc(numConnectedLeechersDHT);
  end
  else
  begin
    inc(numConnectedSeeders);
    if AnsiLowerCase(source.foundby)='dht' then
    inc(numConnectedSeedersDHT);
  end;

  end;
end;


procedure tBitTorrentTransfer.IncFilesProgress(chunk:TBitTorrentChunk);
var
i:integer;
ffile:TBitTorrentFile;
RemainingBytes,numBytes:integer;
begin

   RemainingBytes:=chunk.fsize;

   i:=0;
   while ((i<ffiles.count) and (RemainingBytes>0)) do begin
      ffile:=ffiles[i];

    if (chunk.foffSet+chunk.fsize)<=ffile.foffset then begin
     inc(i);
     continue;
    end;
    if chunk.foffset>(ffile.foffset+ffile.fsize) then begin
     inc(i);
     continue;
    end;

    NumBytes:=chunk.fsize;
    if chunk.foffSet<ffile.foffset then dec(NumBytes,ffile.foffset-chunk.foffSet);
    if chunk.foffSet+chunk.fsize>ffile.foffset+ffile.fsize then dec(NumBytes,(chunk.foffSet+chunk.fsize)-(ffile.foffset+ffile.fsize));


    inc(ffile.fprogress,NumBytes); 


    dec(RemainingBytes,NumBytes);
    inc(i);
  end;



end;


procedure tBitTorrentTransfer.CalculateFilesProgress;
var
i,h:integer;
ffile:TBitTorrentFile;
chunk:TBitTorrentChunk;
bytesAddedPreview,
numBytes:int64;
begin
//{>>GpProfile} ProfilerEnterProc(49); try {GpProfile>>}
 for h:=0 to high(fpieces) do begin
   chunk:=fpieces[h];
   if (fprogressive=true) or (ProgressiveDL=true) then
    chunk.priority:=(high(fpieces)-h)
   else
   chunk.priority:=0;
   chunk.downloadable:=false;
 end;

for i:=0 to ffiles.count-1 do begin
 ffile:=ffiles[i];
 BytesAddedPreview:=0;
 for h:=0 to high(fpieces) do begin
   chunk:=fpieces[h];

   if (chunk.foffSet+chunk.fsize)<=ffile.foffset then continue;
   if chunk.foffset>(ffile.foffset+ffile.fsize) then continue;

   NumBytes:=chunk.fsize;
   if chunk.foffSet<ffile.foffset then dec(NumBytes,ffile.foffset-chunk.foffSet);
   if chunk.foffSet+chunk.fsize>ffile.foffset+ffile.fsize then dec(NumBytes,(chunk.foffSet+chunk.fsize)-(ffile.foffset+ffile.fsize));

   if chunk.checked then inc(ffile.fprogress,NumBytes);
   chunk.downloadable:=true;
    if BytesAddedPreview<5*MEGABYTE then
    begin
     chunk.preview:=true;
     inc(BytesAddedPreview,NumBytes);
    end;
 end;
end;

//{>>GpProfile} finally ProfilerExitProc(49); end; {GpProfile>>}
end;

function PurgeExceedingSource(transfer:TBitTorrentTransfer):boolean;
var
source:TBittorrentSource;
i:integer;
begin
result:=False;

with transfer do begin

 if fsources.count<BITTORRENT_MAX_ALLOWED_SOURCES then exit;

  if fsources.count>1 then begin
    if isCompleted then fsources.sort(worstDownloaderFirst)
     else fsources.sort(WorstUploaderFirst);
  end;

  for i:=0 to fsources.count-1 do begin
   source:=fsources[i];
   if source.status=btSourceConnected then continue;
   if source.status=btSourceShouldRemove then continue;
    source.status:=btSourceShouldRemove;
    result:=true;
    break;
  end;

end;

end;

function SourceIsDuplicate(transfer:TBittorrentTransfer; ipC:cardinal):boolean;
var
i:integer;
source:TBittorrentSource;
begin
result:=false;

with transfer do begin

  for i:=0 to fsources.count-1 do begin
   source:=fsources[i];
   if source.ipC=ipC then begin
    result:=True;
    exit;
   end;
  end;

end;
end;

procedure tBittorrentTransfer.addSource(ipC:cardinal; port:word; const ID:string; const sourcestr:string; removeExceeding:boolean=true);
var
source:TBittorrentSource;
ip:string;
begin

//Form1.Memo2.Lines.Add('addSource');

if SourceIsDuplicate(self,ipC) then exit;
if ipC=vars_global.localipC then exit;
if isAntiP2PIP(ipC) then exit;
if ipc=0 then exit;
if port=0 then exit;
if btcore.IsBannedIp(self,ipC) then exit;

if removeExceeding then purgeExceedingSource(self)
 else begin
  if fsources.count>=BITTORRENT_MAX_ALLOWED_SOURCES then exit;
 end;

 ip:=ipint_to_dotstring(ipC);

 source:=TBittorrentSource.create;
  source.IpC:=ipC;
  source.ipS:=ip;
  source.port:=port;
  source.ID:=ID;
  source.foundby:=sourcestr;
   fsources.add(source);

   thread_bittorrent.globSource:=source;
   thread_bittorrent.globTransfer:=self;
//   vars_global.thread_bittorrent.synchronize(vars_global.thread_bittorrent,AddVisualGlobSource);

end;


procedure tBittorrentTransfer.addSource(const ip:string; port:word; const ID:string; const sourcestr:string);
var
source:TBittorrentSource;
ipC:cardinal;
begin

  ipC:=inet_addr(pchar(ip));
  if SourceIsDuplicate(self,ipC) then exit;
  if ipC=vars_global.localipC then exit;
  if isAntiP2PIP(ipC) then exit;
  if ipc=0 then exit;
  if port=0 then exit;
  if btcore.IsBannedIp(self,ipC) then exit;
  
 if fsources.count>=BITTORRENT_MAX_ALLOWED_SOURCES then
  if not purgeExceedingSource(self) then exit;

 source:=TBittorrentSource.create;
  source.IpC:=ipC;
  source.ipS:=ip;
  source.port:=port;
  source.ID:=ID;
  source.foundby:=sourcestr;
   fsources.add(source);

   thread_bittorrent.globSource:=source;
   thread_bittorrent.globTransfer:=self;
//   vars_global.thread_bittorrent.synchronize(vars_global.thread_bittorrent,AddVisualGlobSource);

end;

procedure tBittorrentTransfer.useNextTracker;
var tracker:TBitTorrentTracker;
find:Boolean;
findudp:Boolean;
i:Integer;
begin
inc(trackerIndex);
if trackerIndex>=trackers.count then
trackerIndex:=0;

{find:=false;
findudp:=false;
inc(trackerIndex);

for i:=0 to trackers.count-1 do
begin
tracker:=trackers.Items[trackerIndex];
if tracker.isudp then
begin
findudp:=True;
Break;
end;
end;

if findudp then
repeat
if trackerIndex>=trackers.count then
begin
trackerIndex:=0;
tracker:=trackers.Items[trackerIndex];
if tracker.isudp then
begin
find:=true;
end else inc(trackerIndex);
end else
begin
tracker:=trackers.Items[trackerIndex];
if tracker.isudp then
begin
find:=true;
end else inc(trackerIndex);
end;

until find;}
end;
{
procedure tBittorrentTransfer.AddVisualGlobSource;//sync
var
 dataNode:ares_types.precord_data_node;
 node:PCmtVNode;
 data:btcore.precorD_displayed_source;
begin
    if UploadTreeview then begin
     node:=ares_frmmain.treeview_upload.AddChild(visualNode);
     dataNode:=ares_frmmain.treeview_upload.getdata(node);
    end else begin
     node:=ares_frmmain.treeview_download.AddChild(visualNode);
     dataNode:=ares_frmmain.treeview_download.getdata(node);
    end;

      dataNode^.m_type:=dnt_bittorrentSource;

       data:=AllocMem(sizeof(record_Displayed_source));
       dataNode^.data:=data;

       thread_bittorrent.Globsource.nodeDisplay:=node;
       thread_bittorrent.Globsource.dataDisplay:=data;


       thread_bittorrent.Globsource.dataDisplay^.port:=thread_bittorrent.GlobSource.port;
       thread_bittorrent.Globsource.dataDisplay^.ipS:=thread_bittorrent.GlobSource.ipS;
       thread_bittorrent.Globsource.dataDisplay^.status:=thread_bittorrent.Globsource.status;
       thread_bittorrent.Globsource.dataDisplay^.ID:=thread_bittorrent.Globsource.ID;
       thread_bittorrent.Globsource.dataDisplay^.sourceHandle:=integer(thread_bittorrent.Globsource);
       thread_bittorrent.Globsource.dataDisplay^.VisualBitField:=TBitTorrentBitField.create(length(FPieces));
       thread_bittorrent.Globsource.dataDisplay^.foundby:=thread_bittorrent.Globsource.foundby;
       thread_bittorrent.Globsource.dataDisplay^.choked:=true;
       thread_bittorrent.Globsource.dataDisplay^.interested:=false;
       thread_bittorrent.Globsource.dataDisplay^.weAreChoked:=true;
       thread_bittorrent.Globsource.dataDisplay^.weAreInterested:=false;
       thread_bittorrent.Globsource.dataDisplay^.sent:=0;
       thread_bittorrent.Globsource.dataDisplay^.recv:=0;
       thread_bittorrent.GlobSource.dataDisplay^.size:=fsize;
       thread_bittorrent.GlobSource.dataDisplay^.FPieceSize:=fpieceLength;
       thread_bittorrent.GlobSource.dataDisplay^.progress:=0;
       thread_bittorrent.GlobSource.dataDisplay^.should_disconnect:=false;
end;
}
procedure tBittorrentTransfer.read(offset:int64; destination:pchar; bytesCount:int64; var remaining:int64; var errorCode:integer);
var
StartingIndex:integer;
Startingfile:TBitTorrentFile;
bytesProcessed:int64;
relativeOffset:int64;
begin
errorCode:=ERROR_OFFSET_OUTOFRANGE;
remaining:=bytesCount;

StartingFile:=FindFileAtOffset(offset,StartingIndex);
if StartingFile=nil then exit;

relativeOffset:=offset-StartingFile.foffset;


while (bytesCount>0) do begin

  StartingFile.read(relativeOffset,destination,bytesCount,bytesProcessed);
  if bytesProcessed=-1 then begin
   remaining:=bytesCount;
   errorCode:=ERROR_STREAM_LOCKED;
   exit;
  end;

  bytesCount:=bytesCount-bytesProcessed;
  if bytesCount=0 then break;

  inc(startingIndex);

  if startingIndex>=ffiles.count then begin
   errorCode:=ERROR_READ_BEYONDLIMIT;
   remaining:=bytesCount;
   exit;
  end;


  inc(destination,bytesProcessed);
  StartingFile:=ffiles[StartingIndex];
  relativeOffset:=0;
end;

remaining:=bytesCount;
errorCode:=NO_ERROR;
end;

function tBitTorrentTransfer.FindFileAtOffset(offSet:int64; var Index:integer):TBitTorrentFile;
var
mFile:TBitTorrentFile;
i:integer;
begin
resulT:=nil;

for i:=ffiles.count-1 downto 0 do begin
  mFile:=ffiles[i];

  if mFile.foffset<=offset then begin
   result:=mFile;
   index:=i;
   exit;
  end;
  
end;

end;

procedure tBittorrentTransfer.write(offset:int64; source:pchar; bytesCount:int64; var remaining:int64; var errorCode:integer);
var
StartingIndex:integer;
Startingfile:TBitTorrentFile;
bytesProcessed:int64;
relativeOffset:int64;
begin
errorCode:=ERROR_OFFSET_OUTOFRANGE;
remaining:=bytesCount;

StartingFile:=FindFileAtOffset(offset,StartingIndex);
if StartingFile=nil then exit;

relativeOffset:=offset-StartingFile.foffset;

while (bytesCount>0) do begin

  StartingFile.Write(relativeOffset,source,bytesCount,bytesProcessed);
  if bytesProcessed=-1 then begin
   errorCode:=ERROR_STREAM_LOCKED;
   remaining:=bytesCount;
   exit;
  end;

  dec(bytesCount,bytesProcessed);
  if bytesCount=0 then break;

  inc(startingIndex);

  if startingIndex>=ffiles.count then begin
   errorCode:=ERROR_WRITE_BEYONDLIMIT;
   remaining:=bytesCount;
   exit;
  end;

  inc(source,bytesProcessed);
  StartingFile:=ffiles[StartingIndex];
  relativeOffset:=0;
end;

remaining:=bytesCount;
errorCode:=NO_ERROR;
end;




function tBittorrentTransfer.serialize_bitfield:string;
var
c:byte;
i:integer;
num:integer;
written:boolean;
begin
  num:=high(fPieces)+1;

  c:=0;
  if (num mod 8)>0 then setlength(result,(num div 8)+1)
   else setlength(result, num div 8);

  written:=false;

  for i:=0 to num-1 do begin

    if fPieces[i].checked then inc(c,1 shl (7-(i mod 8)) );

    if (i mod 8)=7 then begin
     result[(i div 8)+1]:=chr(c);
     c:=0;
     written:=true;
    end else written:=false;
    
  end;

  if not written then result[(i div 8)+1]:=chr(c);

end;

procedure tBitTorrentTransfer.wipeout;
var
 newfile:TBitTorrentFile;
begin
if dbstream<>nil then dbstream.size:=0;
bitTorrentDb_CheckErase(self);


if ffiles.count=1 then begin
 newfile:=ffiles[0];
          ffiles.delete(0);
 newfile.erase;
 FreeAndNil(ffiles);
end else begin
 freeFiles(true);
 helper_diskio.erase_dir_recursive(utf8strtowidestr(fName));
end;

free;
end;

function Tnt_MoveFileW(lpExistingFileName, lpNewFileName: PWideChar): BOOL;
var Win32PlatformIsUnicode : boolean;
begin
Win32PlatformIsUnicode := (Win32Platform = VER_PLATFORM_WIN32_NT);
  if Win32PlatformIsUnicode then
    Result := MoveFileW{TNT-ALLOW MoveFileW}(lpExistingFileName, lpNewFileName)
  else
    Result := MoveFileA{TNT-ALLOW MoveFileA}(PAnsiChar(AnsiString(lpExistingFileName)), PAnsiChar(AnsiString(lpNewFileName)));
end;

procedure tBitTorrentTransfer.DoComplete;
var
i:integer;
ffile:TBitTorrentFile;
old_filename,new_filename:widestring;
begin
fstate:=dlSeeding;



for i:=0 to ffiles.count-1 do begin
 ffile:=ffiles[i];

 FreeHandleStream(ffile.fstream);
 ffile.update_modify_date;


 old_filename:=utf8strtowidestr(ffile.ffilename);
 if length(old_filename)>MAX_PATH then old_filename:='\\?\'+old_filename;

 delete(ffile.ffilename,pos('__INCOMPLETE__',ffile.ffilename),14);
 new_filename:=utf8strtowidestr(ffile.ffilename);
 if length(new_filename)>MAX_PATH then new_filename:='\\?\'+new_filename;


 Tnt_MoveFileW(pwidechar(old_filename),pwidechar(new_filename));


 ffile.fstream:=MyFileOpen(utf8strtowidestr(ffile.ffilename),ARES_READONLY_ACCESS);
end;



BitTorrentDb_updateDbOnDisk(self);
//dbstream.size:=0;
//bitTorrentDb_CheckErase(self);
end;


procedure tBitTorrentTransfer.addTracker(URL:string);
var
 tracker:tbittorrentTracker;
 i:integer;
 UrlTracker:string;
begin
if length(url)<10 then exit;

for i:=0 to trackers.count-1 do begin
 tracker:=trackers[i];
 if url=tracker.URL then exit;
end;


tracker:=tBitTorrentTracker.create;
 tracker.url:=url;

 UrlTracker:=tracker.Url;
 tracker.host:=GetHostFromUrl(UrlTracker);
 tracker.port:=GetPortFromUrl(UrlTracker);

 tracker.download:=self;
 if pos('udp://',lowercase(tracker.url))=1 then tracker.isudp:=true;
trackers.add(tracker);

if trackers.count>1 then shuffle_mylist(trackers,0);
//trackers.sort(sortBitTorrentudptrackerfirst);
//trackers.sort(sortBitTorrenthttptrackerfirst);
end;




//****************************   Tracker ***********************************************************************

constructor TBitTorrentTracker.Create();
begin
  FError:='';
  BufferReceive:='';
  socket:=nil;
  alreadyStarted:=false;
  alreadyCompleted:=false;
  next_poll:=0;
  interval:=(TRACKERINTERVAL_WHENFAILED div 1000);//2 minutes
  tick:=0;
  download:=nil;
  CurrTrackerEvent:='';
  url:='';
  trackerID:='';
  warningMessage:='';
  visualStr:='';
  isudp:=false;
  socketUDP:=INVALID_SOCKET;
  isScraping:=false;
  inherited Create();
end;

destructor TBitTorrentTracker.Destroy();
begin
  if socket<>nil then socket.free;
  if isudp then begin
   if socketUDP<>INVALID_SOCKET then TCPSocket_Free(socketUDP);
  end;
  FError:='';
  BufferReceive:='';
  CurrTrackerEvent:='';
  url:='';
  trackerID:='';
  visualStr:='';
  warningMessage:='';
  inherited Destroy();
end;

function TBitTorrentTracker.SupportScrape:boolean;
var
ind:integer;
begin
{
http://example.com/announce          -> http://example.com/scrape
http://example.com/x/announce        -> http://example.com/x/scrape
http://example.com/announce.php      -> http://example.com/scrape.php
http://example.com/a                 -> (scrape not supported)
http://example.com/announce?x<code>2%0644 -> http://example.com/scrape?x</code>2%0644
http://example.com/announce?x=2/4    -> (scrape not supported)
http://example.com/x%064announce     -> (scrape not supported)
}

ind:=pos('/announce',lowercase(url));
if ind=0 then begin
 result:=false;
 exit;
end;

 result:=(PosEx('/',url,ind+9)=0);
end;

function TBitTorrentTracker.ParseScrape(stream:TStream):boolean;
var
o,o2:TObject;
info,f:TObjectHash;
down:TBitTorrentTransfer;
_Tree:TObjectHash;
begin
  result:=false;

  FError:='';
  //WarningMessage:='';
  _Tree:=nil;
    try


      o:=bdecodeStream(Stream);
      if o=nil then begin
       FError:='Invalid Tracker Response; not bencoded metainfo';
       exit;
      end;


    try
        if not (o is TObjectHash) then begin
         FError:='Invalid Tracker Response; metainfo is malformed (not a dictionary)';
         FreeAndNil(o);
        end;
    except
     exit;
    end;


          _Tree:=o as TObjectHash;

     try
          if not _Tree.Exists('files') then begin  // list, old format
           FError:='Error while parsing scrape reply (''files'' dictionary missing)';
           FreeAndNil(o);
           exit;
          end;
    except
    exit;
    end;


    try
          if not (_Tree['files'] is TObjectHash) then begin
            FError:='Error while parsing scrape reply (''files'' not an ojectHash)';
            FreeAndNil(o);
            exit;
          end;
   except
   exit;
   end;


   try
          f:=_Tree['files'] as TObjectHash;
          if f.ItemCount<>1 then begin
            FError:='Error while parsing scrape reply (hash not found...'+inttostr(f.ItemCount)+' files returned by tracker)';
            FreeAndNil(o);
            exit;
          end;
   except
   exit;
   end;


          down:=download;


   try
          if not f.Exists(down.fhashvalue) then begin
           FError:='Invalid Tracker Scrape Response (doesn''t exist infohash key/value)';
            FreeAndNil(o);
           exit;
          end;
   except
   exit;
   end;


   try
          o2:=f.Items[down.fhashvalue];
          if not (o2 is TObjectHash) then begin
            FError:='Invalid Tracker Scrape Response (hash is not an TObjectHash)';
            FreeAndNil(o);
            exit;
          end;
  except
   exit;
  end;

   try
          info:=o2 as TObjectHash;

          if info.Exists('complete') then begin
           seeders:=(info['complete'] as TIntString).IntPart;
          end;

          if info.Exists('incomplete') then begin
           leechers:=(info['incomplete'] as TIntString).IntPart;
          end;
          
          //info.free;
   except
   end;



   finally
    if _Tree<>nil then _Tree.free;
   // FreeAndNil(o);
   end;


 // except
 //   FError:='Error while trying to parse Tracker scrape stats';
  //end;

  Result:=true;
end;

function TBitTorrentTracker.Load(Stream:TStream):Boolean;
var
o:TObject;
info:TObjectHash;
f:TObjectList;
h,n,str:String;
i,j:Integer;
down:tbittorrentTransfer;
_Tree:TObjectHash;
begin
  result:=false;
  
  FError:='';
  WarningMessage:='';
  _Tree:=nil;

    try

      o:=bdecodeStream(Stream);
      if o=nil then begin
       FError:='Invalid Tracker Response; not bencoded metainfo';
       exit;
      end;


    try
        if not (o is TObjectHash) then begin
         FError:='Invalid Tracker Response; metainfo is malformed (not a dictionary)';
            try
            FreeAndNil(o);
            except
            end;
         exit;
        end;
    except
    end;



          _Tree:=o as TObjectHash;

           seeders:=0;
           leechers:=0;

    try
          // parse vars
          if _Tree.Exists('warning message') then begin
           WarningMessage:=(_Tree['warning message'] as TIntString).StringPart;
          // (_Tree['warning message'] as TIntString).free;
          end;

          if _Tree.Exists('failure reason') then begin
           WarningMessage:=(_Tree['failure reason'] as TIntString).StringPart;

           FError:='Error '+(_Tree['failure reason'] as TIntString).StringPart;
           Interval:=600; // do not hammer trackers, 10 minutes?
           exit;
          end;


          if _Tree.Exists('interval') then begin
           Interval:=(_Tree['interval'] as TIntString).IntPart;
          // (_Tree['interval'] as TIntString).free;
          end;
          if _Tree.Exists('min interval') then begin
           Interval:=(_Tree['min interval'] as TIntString).IntPart;
          // (_Tree['min interval'] as TIntString).free;
          end;
          if _Tree.Exists('tracker id') then TrackerID:=(_Tree['tracker id'] as TIntString).StringPart;
          if _Tree.Exists('complete') then begin
           seeders:=(_Tree['complete'] as TIntString).IntPart;
           //(_Tree['complete'] as TIntString):=nil;
          end;
          if _Tree.Exists('incomplete') then begin
           leechers:=(_Tree['incomplete'] as TIntString).IntPart;
          end;
    except
    end;


    try

          if not _Tree.Exists('peers') then begin  // list, old format
            if _Tree.Exists('failure reason') then begin
             FError:='Error '+(_Tree['failure reason'] as TIntString).StringPart;
             Interval:=600; // do not hammer trackers, 10 minutes?
             
            end else FError:='Invalid Tracker Response; missing "peers" segment';
           exit;
          end;

     except
     end;


     try
            if _Tree['peers'] is TObjectList then begin
              f:=_Tree['peers'] as TObjectList;

              for j:=0 to f.Count-1 do begin
                if f.Items[j] is TObjectHash then begin
                  info:=f.Items[j] as TObjectHash;
                  h:={bin2Hex(}(info['peer id'] as TIntString).StringPart{)};
                 // (info['peer id'] as TIntString).free;

                   if info.Exists('port') then begin
                    i:=(info['port'] as TIntString).IntPart;
                  //  (info['port'] as TIntString).free;
                   end else i:=80;

                  n:=(info['ip'] as TIntString).StringPart;
                  if download<>nil then begin
                   down:=download;
                   down.addsource(n,i,h,'Tracker');
                   //ShowMessage('Tracker1: '+IntToStr(ipC));
                  end;
                  //(info['ip'] as TIntString).Free;
                end else FError:='Invalid Tracker Response; info for all peers should be a dictionary';
              end;
              
            end else begin //compact form, new format
              str:=(_Tree['peers'] as TIntString).StringPart;
              while (length(str)>=6) do begin
               h:='';
               n:=ipint_to_dotstring(chars_2_dword(copy(str,1,4)));
               i:=(ord(str[5])*256)+ord(str[6]);//,5,2));
               delete(str,1,6);
                  if download<>nil then begin
                   down:=download;
                   down.addsource(n,i,h,'Tracker');
                   //ShowMessage('Tracker2: '+IntToStr(ipC));
                  end;
              end;
              //(_Tree['peers'] as TIntString).Free;
            end;
      except
      end;


  //  while _Tree.ItemCount>0 do _Tree.FDeleteIndex(0);
  finally
    try
    _Tree.free;
    except
    end;
  end;
 // except
 //   FError:='Error while trying to parse the Tracker state';
 // end;

  Result:=True;
end;




end.


