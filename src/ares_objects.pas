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
some application objects are listed here
}

unit ares_objects;

interface

uses
{comettrees,}classes,classes2,blcksock,const_ares,
windows,sysutils;

type
TDownloadState=(
   dlBittorrentMagnetDiscovery,
   dlSeeding,
   dlFileError,
   dlAllocating,
   dlFinishedAllocating,
   dlRebuilding,
   dlProcessing,
   dlJustCompleted,
   dlCompleted,
   dlDownloading,
   dlPaused,
   dlLeechPaused,
   dlLocalPaused,
   dlCancelled,
   dlQueuedSource,
   dlUploading);

TDownloadStates=set of TDownloadState;

 type
  tSourceState=(srs_paused,
                srs_idle,
                srs_connecting,
                srs_readytorequest,
                srs_receiving,
                srs_waitingPush,
                srs_TCPpushing,
                srs_UDPPushing,
                srs_waitingForUserUdpAck,
                srs_UDPDownloading,
                srs_UDPreceivingICH,
                srs_waitingForUserUDPPieceAck,
                srs_waitingIcomingConnection,
                srs_connected,
                srs_ReceivingReply,
                srs_receivingICH);
  tSourceStates=set of tSourceState;

 type
 TBitTorrentViewMode=(vmFiles,vmSources);

precord_displayed_bittorrentTransfer=^record_displayed_bittorrentTransfer;
record_displayed_bittorrentTransfer=record
 handle_obj:cardinal;
 ID:string;
 FileName,path,trackerStr:string;
 Size:int64;
 downloaded,uploaded:int64;
 hash_sha1:string;
 crcsha1:word;
 SpeedDl,SpeedUl:cardinal;
 state:TDownloadState;
 want_cancelled,
 want_paused,
 want_changeView,
 want_cleared:boolean;
 num_sources:word;
 NumLeechers,NumSeeders,NumConnectedSeeders,NumConnectedLeechers:cardinal;
 ercode:integer;
 bitfield:array of boolean;
 FPieceSize:cardinal;
 elapsed:cardinal;
end;


   


   precord_displayed_downloadsource=^record_displayed_downloadsource;
   record_displayed_downloadsource=record
      handle_obj:cardinal;
      queued_position:integer;
      ip:cardinal;
      ip_alt:cardinal;
      port:word;
      ip_server:cardinal;
      port_server:word;
      nomedisplayw:widestring;  //widestrin!
      should_disconnect:boolean;
      nickname:string;
      versionS:string;
      state:tSourceState;
      speed:integer;
      size:cardinal;
      progress:cardinal;
      startp:int64;
      endp:int64;
   end;

   precord_displayed_download=^record_displayed_download;
   record_displayed_download=packed record
    handle_obj:cardinal;
    VisualBitfield:array of boolean;
    numInDown:byte;
    FPieceSize:cardinal;
    ercode:integer;
    lastDHTCheckForSources:cardinal;

    hash_sha1:string;
    crcsha1:word;
    state:TDownloadState;

    title:string;
    keyword_genre:string;
    progress:int64;
    velocita:int64;
    size:int64;
    filename:string;
    nomedisplayw:widestring;  //widestrin!
    tipo:byte;
    artist:string;
    album:string;
    category:string;
    comments:string;
    language:string;
    date:string;
    url:string;
    param1:cardinal;
    param2:cardinal;
    param3:cardinal;
    num_sources:word;
    num_partial_sources:word;
    want_cancelled:boolean; // per comandare..
    change_paused:boolean;
   end;


type
  precord_alternate=^record_alternate;
  record_alternate= packed record
  ip_user:cardinal;
  port_user:word;
  ip_server:cardinal;
  port_server:word;
  prev,next:precord_alternate;
end;                     

TDownloadPiece=class(TObject)
 FOffset:int64;
 FProgress:int64;
 FHashValue:array[0..19] of byte;
 FDone:boolean;
 FInUse:boolean;
end;

taviHeaderCheckState=(
 aviStateNotAvi,
 aviStateNotChecked,
 aviStateIsAvi);
 
  tdownload = class(tobject)
    FPieces:array of TDownloadPiece;
    FPieceSize:int64;
    allocator:tthread;
//    display_node:PCmtVNode;
    display_data:precord_displayed_download;
    startDate:cardinal;
    creationTime:cardinal;
    size:int64;
    progress:int64;

    stream:thandlestream;
    aviHeaderState:taviHeaderCheckState;
    AviIDX1At:cardinal;

     filename,
     remaining,
     hash_sha1,
     in_subfolder,
     hash_of_phash:string;//per cancellazione subfolder nel caso sia libera alla fine
     crcsha1:word;
    num_in_down:cardinal;

    tipo:byte;

    state:TDownloadState;
    paused_sources:boolean;//per evitare di entrare nel ciclo pause all ogni volta
    lista_risorse:tmylist;
    notworking_ips:tmylist;
    speed:integer;
     param1,param2,param3:integer;
     title,artist,album,category,language,comments,date,url,keyword_genre:string;

    phash_verified_progr:int64;
    is_getting_phash:boolean;
    phash_Stream:thandlestream;
    
    ercode:integer;
     socket_push:ttcpblocksocket;
     push_connected:boolean;
     push_testoricevuto:string;
     push_flushed:boolean;
     push_tick:cardinal;
     push_randoms:string;
     push_ip_requested:cardinal;
     push_num_special:byte;
     push_ip_server:cardinal;
     push_port_server:word;
    constructor Create;
    destructor Destroy; override;
    function BitFieldtoStr:string;
    function BitFieldStrLen:integer;
//    procedure AddVisualReference;     //synch
//    procedure RemoveVisualReference;
    procedure AddToBanList(ip:cardinal);
    function isBannedIp(ip:cardinal):boolean;
 end;


type FSTSessionState= (SessIdle,
                       SessConnecting,
                       SessEstablished,
                       SessDisconnected,
                       SessReceivingNa,  //for ares
                       SessFlushingLogin, SessWaitingForLoginReply);


tares_node=class(tobject)
 reports,attempts,connects,
 first_seen,last_seen,last_attempt:cardinal;
 in_use,dejavu,noCrypt,oldProt:boolean;
 state:FSTSessionState;
 out_buf,searchIDS:tmystringlist;//clear out buf
 socket:ttcpblocksocket;
 reported:boolean;
 supportDirectChat:boolean;
 hits_received:cardinal;
 last_lag:cardinal;
  last:cardinal; //per vari timeouts
  last_out_stats:cardinal;
 logtime:cardinal;
 ListSents,HistSentFilelists:cardinal;
 ready_for_filelist,EverSentFilelist:boolean;
     sc:word; // second key
     fc:byte;  // first key algo
     host:string;   //remote host server
     port:word;
 constructor create;
 destructor destroy;override;
 function rate:single;
 //procedure get_prepna;
end;


  TWriteCache=class(TObject)
  Fbuffer:array of byte;
  FStream:THandleStream;
  FCurrentDiskOffset:int64;
  FCurrentInternalOffset:int64;
  constructor create(stream:THandleStream; DiskOffset:int64);
  destructor destroy; override;
  procedure write(data:pointer; len:cardinal);
  procedure flush;
  end;

trisorsa_download = class(tobject)

 writecache:TWriteCache;
// display_node:PCmtVNode;
 display_data:precord_displayed_downloadsource;
 attivato_ip,ICH_passed:boolean;
 failed_ipint,
 has_tried_extIP,
 FailedICHDBRet:boolean;
 handle_download:cardinal;  
 started_time:cardinal;
 nickname:string;
 version:string;
 randoms:string;
 origfilename:string;
 ICH_failed:boolean;
 getting_phash:boolean;
 isFirewalled:boolean; //default = true
 UDP_Socket:Hsocket;
 unAckedPackets:byte;
 UDPNatPort:word;
 UDPICHProgress:integer;
 CurrentUDPPushSupernode:cardinal;
 nextUDPOutInterval:cardinal;
 lastUDPOut:cardinal;

 queued_position:integer;

 speed:int64;
 next_poll:cardinal;
 num_fail:byte;
 numgiven_mesh:byte;
 have_tried:boolean;
 actual_decrypt_key:word;
 encryption_branch:byte;
 ip_interno:cardinal;
 ip:cardinal;
 porta:word;
 his_servers:TMyStringlist;

 state:tSourceState;
 socket:ttcpblocksocket;
 out_buf:string;
 last_in:cardinal;
 last_out_push_req:cardinal;
 tick_attivazione:cardinal;
 succesfull_factor:cardinal;

 start_byte:int64;
 end_byte:int64;
 global_size:int64;
 bytes_prima:int64;
 progress:int64;
 size_to_receive:int64;
 progress_su_disco:int64;

 download:pointer;
 piece:TDownloadPiece;
 constructor create;
// procedure AddVisualReference;
// procedure RemoveVisualReference;
 procedure InsertServer(ip:cardinal; port:word; clearPrevious:boolean=false);
 procedure InsertServers(buffer:string);
 procedure RemoveServer(ip:cardinal);
 function GetFirstBinaryServerStr:string;
 procedure GetFirstServerDetails(var ip:cardinal; var port:word);
 destructor Destroy; override;
end;


type
  precord_buffer_invio=^record_buffer_invio;
  record_buffer_invio=array[0..1028] of byte; //2942< era 1024

tupload = class(tobject)

       socket:ttcpblocksocket;
       stream:thandlestream;

       filename:string;
       crcfilename:word;
       nickname:string;
       crcnick:word;
       out_reply_header:string;
       his_progress:byte;
       his_upcount:integer;
       his_downcount:integer;
       his_speedDL:cardinal;// 2957+ mostra sua speed per fini statistici
       his_shared:integer;
       his_agent:string; 
       ip_server:cardinal;
       ip_alt:cardinal;
       port_server:word;
       ip_user:cardinal;
       port_user:word;
       
       isUDP:boolean;
       UDPSourceHandle:cardinal;
       lastUDPData:cardinal;
       bsent:int64;
       actual:int64;
       startpoint:int64;
       endpoint:int64;
       size:int64;
       filesize_reale:int64; //crazy maniak
       SentHeader:boolean;

       bytesprima:int64;
       velocita:integer;
       is_phash:boolean; //per invio phash, il flag elimina il file temp alla fine dell'upload
       start_time:cardinal;
       should_display:boolean;
       num_available:byte;

       buffer_invio:record_buffer_invio;
       bytes_in_buffer:integer;
        is_encrypted:boolean;
        encryption_key:word;
        his_buildn:word;
    constructor Create(tim:cardinal);
    destructor Destroy; override;
  end;

 type
 Tpush_out=class(tobject)
  socket:TTCPBlockSocket;
  connected:boolean;
  constructor create(tim:cardinal);
  destructor destroy; override;
 end;

   type
  tbitclass=class(TObject)
   data:array of boolean;
   position:integer;
  public
   constructor create;
   procedure load(datain:string);
   destructor destroy; override;
   procedure seek(newpos:integer);
   function getint(numbit:integer):cardinal;
  end;

  type
  TSharedMemory = class(Tobject)
   HMapping: THandle;
   PMapData: Pointer;
   HMapMutex: THandle;
   procedure OpenMap;
   procedure CloseMap;
   function LockMap:Boolean;
   procedure unLockMap;
  end;

implementation

uses
 {thread_supernode,}helper_diskio,{helper_ares_nodes,}
 ares_types,{ufrmmain,}
 helper_ich,helper_strings,
 helper_ipfunc,helper_datetime;

procedure TSharedMemory.OpenMap;
 var
   llInit: Boolean;
   lInt: Integer;
 begin
   HMapping := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE,
                 0, 512, pchar('MY MUTEX NAME GOES HERE'));
   // Check if already exists
   llInit := (GetLastError() <> ERROR_ALREADY_EXISTS);
   if (hMapping = 0) then
   begin
     //ShowMessage('Can''t Create Memory Map');
     //Application.Terminate;
     exit;
   end;
   PMapData := MapViewOfFile(HMapping, FILE_MAP_ALL_ACCESS, 0, 0, 0);
   if PMapData = nil then
   begin
     CloseHandle(HMapping);
     //ShowMessage('Can''t View Memory Map');
    // Application.Terminate;
     exit;
   end;
   if (llInit) then
   begin
     // Init block to #0 if newly created

      FillChar(PMapData^, 512, 0);
   end
 end;

procedure TSharedMemory.CloseMap;
begin
 if PMapData<>nil then UnMapViewOfFile(PMapData);
 if HMapping<>0 then CloseHandle(HMapping);
end;

function TSharedMemory.LockMap:Boolean;
begin
   Result:=true;
   HMapMutex := CreateMutex(nil, false,pchar('Ares_mmap_mutex'));
   if HMapMutex = 0 then begin
    // ShowMessage('Can''t create map mutex');
     Result := false;
   end else begin
     if WaitForSingleObject(HMapMutex,1000) = WAIT_FAILED then begin
       // timeout
      // ShowMessage('Can''t lock memory mapped file');
       Result := false;
     end
   end
 end;
 
procedure TSharedMemory.UnlockMap;
begin
 ReleaseMutex(HMapMutex);
 CloseHandle(HMapMutex);
end;



constructor tbitclass.create;
begin
inherited;
 position:=0;
end;

procedure tbitclass.load(datain:string);
var
 i:integer;
 thebyte:byte;
begin
position:=0;
setLength(data,length(datain)*8);

for i:=1 to length(datain) do begin
 thebyte:=ord(datain[i]);

 data[(i-1)*8]:=((thebyte and 128)=128);
 data[((i-1)*8)+1]:=((thebyte and 64)=64);
 data[((i-1)*8)+2]:=((thebyte and 32)=32);
 data[((i-1)*8)+3]:=((thebyte and 16)=16);
 data[((i-1)*8)+4]:=((thebyte and 8)=8);
 data[((i-1)*8)+5]:=((thebyte and 4)=4);
 data[((i-1)*8)+6]:=((thebyte and 2)=2);
 data[((i-1)*8)+7]:=((thebyte and 1)=1);
end;

end;

procedure tbitclass.seek(newpos:integer);
begin
 position:=position+newpos;
end;

function tbitclass.getint(numbit:integer):cardinal;
var
 i:integer;
 multiplier:cardinal;
begin
result:=0;
multiplier:=1;

for i:=(position+numbit)-1 downto position do begin
 result:=result+(integer(data[i])*multiplier);
 multiplier:=multiplier*2;
end;

inc(position,numbit);
end;

destructor tbitclass.destroy;
begin
 setlength(data,0);
inherited;
end;

constructor Tpush_out.create(tim:cardinal);
begin
 socket:=ttcpblocksocket.create(true);
 socket.tag:=tim;
 connected:=false;
end;

destructor tPush_out.destroy;
begin
 if socket<>nil then socket.free;
inherited;
end;

constructor trisorsa_download.create;
begin
inherited create;

 piece:=nil;
 writecache:=nil;
// display_node:=nil;
 display_data:=nil;
 attivato_ip:=false;
 num_fail:=0;
 socket:=nil;
 ip_interno:=0;
 failed_ipint:=false;
 CurrentUDPPushSupernode:=0;
 has_tried_extIP:=false;
 FailedICHDBRet:=false;
 numgiven_mesh:=0;
 ICH_failed:=false;
 isFirewalled:=true;
 getting_phash:=false;
 last_out_push_req:=0;
 out_buf:='';
 origfilename:='';
 ICH_passed:=false;
 version:='';
 ip:=0;
 porta:=0;
 his_servers:=TMyStringlist.create;
 succesfull_factor:=0;
 UDP_Socket:=INVALID_SOCKET;
 queued_position:=0;
 actual_decrypt_key:=0;
 encryption_branch:=0;

 state:=srs_idle;
 have_tried:=false;
 start_byte:=0;
 end_byte:=0;
 progress:=0;
 speed:=0;
 global_size:=0;
 tick_attivazione:=0;
end;

procedure trisorsa_download.InsertServer(ip:cardinal; port:word; clearPrevious:boolean=false);
var
ipb:array[0..3] of byte;
str:string;
i:integer;
begin

if clearPrevious then his_servers.clear else
if his_servers.count>0 then begin
 move(ip,ipb[0],4);
 for i:=0 to his_servers.count-1 do begin
  str:=his_servers.strings[i];
  if compareMem(@ipb[0],@str[1],4) then exit;
 end;
end;
if ip_firewalled(ip) then exit;
if isAntiP2PIP(ip) then exit;

if his_servers.count>=NUM_SESSIONS_TO_SUPERNODES then his_servers.delete(0);

his_servers.add(int_2_dword_string(ip)+
                int_2_word_string(port));
end;

function trisorsa_download.GetFirstBinaryServerStr:string;
begin
if his_servers.count=0 then begin
 result:=CHRNULL+CHRNULL+CHRNULL+CHRNULL+
         CHRNULL+CHRNULL;
 exit;
end;

result:=his_servers.strings[0];

if length(result)<>6 then result:=CHRNULL+CHRNULL+CHRNULL+CHRNULL+
                                  CHRNULL+CHRNULL;
end;

procedure trisorsa_download.GetFirstServerDetails(var ip:cardinal; var port:word);
var
str:string;
begin

if his_servers.count=0 then begin
 ip:=0;
 port:=0;
 exit;
end;

str:=his_servers.strings[0];
 ip:=chars_2_dword(copy(str,1,4));
 port:=chars_2_word(copy(str,5,2));
end;

procedure trisorsa_download.InsertServers(buffer:string);
var
tempip:cardinal;
begin
if his_servers.count>0 then his_servers.clear;

while (length(buffer)>=6) do begin
tempip:=chars_2_dword(copy(buffer,1,4));

 if not ip_firewalled(tempip) then
  if not isAntiP2PIP(tempip) then
   his_servers.add(copy(buffer,1,6));

  delete(buffer,1,6);
 if his_servers.count>=NUM_SESSIONS_TO_SUPERNODES then break;
end;

end;

procedure trisorsa_download.RemoveServer(ip:cardinal);
var
ipb:array[0..3] of byte;
str:string;
i:integer;
begin
if his_servers.count=0 then exit;

move(ip,ipb[0],4);

for i:=0 to his_servers.count-1 do begin
 str:=his_servers[i];
 if compareMem(@ipb[0],@str[1],4) then begin
  his_servers.delete(i);
  exit;
 end;
end;

end;

{
procedure trisorsa_download.AddVisualReference;
var
dataNode:precord_data_node;
aNode:PcmtVnode;
down:TDownload;
begin
 down:=download;

 aNode:=ares_frmmain.treeview_download.addchild(down.display_node);

  dataNode:=ares_frmmain.treeview_download.getdata(aNode);
  dataNode^.m_type:=dnt_downloadSource;
  dataNode^.data:=AllocMem(sizeof(record_displayed_downloadsource));


  display_node:=aNode;
  display_data:=dataNode^.data;

  with display_data^ do begin
    handle_obj:=cardinal(self);
    ip:=self.ip;
    ip_alt:=self.ip_interno;
    port:=self.porta;
    self.GetFirstServerDetails(ip_server,port_server);
    should_disconnect:=false;
    nickname:=self.nickname;
    speed:=0;
    size:=0;
    progress:=0;
    startp:=0;
    endp:=0;
    state:=self.state;
    
     if self.origfilename<>'' then nomedisplayw:=utf8strtowidestr(self.origfilename)
      else nomedisplayw:=down.display_data^.nomedisplayw;
   end;
end;
}{
procedure trisorsa_download.RemoveVisualReference;
begin
if display_node<>nil then begin
 ares_frmmain.treeview_download.deletenode(display_node);
end;

end;}


destructor trisorsa_download.Destroy;
begin
try
his_servers.free;
except
end;
try
if socket<>nil then socket.free;
except
end;

socket:=nil;

if UDP_Socket<>INVALID_SOCKET then TCPSocket_Free(UDP_Socket);

out_buf:='';
nickname:=''; // nostro proto
randoms:='';
origfilename:='';
version:='';

//RemoveVisualReference;

inherited destroy;
end;



constructor tdownload.create;
begin
inherited Create;

    SetLength(FPieces,0);
    FPieceSize:=0;
    
    aviHeaderState:=aviStateNotChecked;
    AviIDX1At:=0;
    
//     display_node:=nil;
     display_data:=nil;

    lista_risorse:=tmylist.create;
    notworking_ips:=nil;
    num_in_down:=0;
    speed:=0;
    progress:=0;
    
    paused_sources:=false;
    in_subfolder:='';
    hash_of_phash:='';

    stream:=nil;

    phash_verified_progr:=0;
    is_getting_phash:=false;

    phash_stream:=nil;
    ercode:=0;
    socket_push:=nil;
    state:=dlProcessing;
    creationTime:=gettickcount;

   FPieceSize:=helper_ich.ICH_calc_chunk_size(size);
end;
{
procedure TDownload.RemoveVisualReference;
begin
if display_node<>nil then ares_frmmain.treeview_download.deleteNode(display_node);
end;
}{
procedure TDownload.AddVisualReference;     //synch
var
dataNode:precord_data_node;
someNode:pcmtVNode;
begin
     someNode:=ares_frmmain.treeview_download.AddChild(nil);

      dataNode:=ares_frmmain.treeview_download.getdata(someNode);
      dataNode^.m_type:=dnt_download;
      dataNode^.data:=AllocMem(sizeof(record_displayed_download));

      self.display_data:=dataNode^.data;
      self.display_node:=someNode;

    helper_download_misc.UpdateVisualDownload(self);
end;}

procedure TDownload.AddToBanList(ip:cardinal);
var
i:integer;
ipc:precord_ip;
begin
if notworking_ips=nil then notworking_ips:=tmylist.create;

 for i:=0 to notworking_ips.count-1 do begin
  ipc:=notworking_ips[i];
   if ipc^.ip=ip then exit;
 end;

 ipc:=AllocMem(sizeof(record_ip));
  ipc^.ip:=ip;
 notworking_ips.add(ipc);
end;

function TDownload.isBannedIp(ip:cardinal):boolean;
var
i:integer;
ipc:precord_ip;
begin
result:=false;
if notworking_ips=nil then exit;

 for i:=0 to notworking_ips.count-1 do begin
  ipc:=notworking_ips[i];
   if ipc^.ip=ip then begin
    result:=true;
    exit;
   end;
 end;

end;


function TDownload.BitFieldStrLen:integer;
var
num:integer;
begin
if length(FPieces)=0 then begin
 result:=0;
 exit;
end;

num:=high(fPieces)+1;
if (num mod 8)>0 then result:=(num div 8)+1
 else result:=num div 8;
end;

function TDownload.BitFieldtoStr:string;
var
c:byte;
i:integer;
//num:integer;
written:boolean;
piece:TDownloadPiece;
begin

 if length(FPieces)=0 then begin
  result:='';
  exit;
 end;

 // num:=high(fPieces)+1;

  c:=0;
  SetLength(result,BitFieldStrLen);
  //SetLength(result,(length(FPieces) div 8)+1);
  written:=false;

  for i:=0 to high(FPieces) do begin
    piece:=FPieces[i];
    if piece.FDone then inc(c,1 shl (7-(i mod 8)) );

    if (i mod 8)=7 then begin
     result[(i div 8)+1]:=chr(c);
     c:=0;
     written:=true;
    end else written:=false;
  end;

  if not written then result[(i div 8)+1]:=chr(c);
end;


destructor tdownload.Destroy;
var
ipc:precord_ip;
i:integer;
piece:TDownloadPiece;
begin

filename:='';
remaining:='';
in_subfolder:='';
hash_of_phash:='';
hash_sha1:='';
keyword_genre:='';
title:='';
artist:='';
album:='';
category:='';
language:='';
date:='';
url:='';
comments:='';
push_testoricevuto:='';
push_randoms:='';

//RemoveVisualReference;

if allocator<>nil then begin
 allocator.terminate;
 allocator.waitfor;
 allocator.free;
end;

if length(FPieces)>0 then begin
 for i:=0 to High(FPieces) do begin
  piece:=FPieces[i];
  piece.free;
 end;
SetLength(FPieces,0);
end;

try
 if stream<>nil then FreeHandleStream(stream);
except
end;

try
  if phash_stream<>nil then FreeHandleStream(phash_stream);
except
end;

try
if notworking_ips<>nil then begin
  while (notworking_ips.count>0) do begin
    ipc:=notworking_ips[notworking_ips.count-1];
         notworking_ips.delete(notworking_ips.count-1);
    FreeMem(ipc,sizeof(record_ip));
  end;
FreeAndNil(notworking_ips);
end;
except
end;

try
if lista_risorse<>nil then FreeAndNil(lista_risorse);
except
end;


try
if socket_push<>nil then FreeAndNil(socket_push);
except
end;


inherited destroy;
end;

constructor tares_node.create;
begin
 last_attempt:=0;
 first_seen:=0;
 last_seen:=0;
 connects:=0;
 reports:=0;
 attempts:=0;
 in_use:=false;
 dejavu:=false;
 noCrypt:=false;
 oldProt:=false;
 state:=sessIdle;
 out_buf:=nil;//clear out buf
 socket:=nil;
 hits_received:=0;
 last:=0;
 last_lag:=0;
 searchIDS:=nil;
 reported:=false;
     sc:=0; // second key
     fc:=0;  // first key algo
     host:='';   //remote host server
     port:=0;
     ListSents:=0;
     ready_for_filelist:=falsE;
     HistSentFilelists:=0;
     supportDirectChat:=false;
end;

function tares_node.rate:single;
var
 rateofsuccess,historical,popularity:single;
 nowunix:cardinal;
begin
  result:=0;
  nowunix:=DelphiDateTimeToUnix(now);

  if connects=0 then begin  // no connect, recently we've heard about it but we didn't try it yet
     if (reports>5) and
        (attempts=0) and
        (nowunix-last_seen<1800) then result:=1;
     exit;
  end;

  rateofsuccess:=((connects + 1) / (attempts + 1));  // rate of tried-succeded

  if nowunix-last_seen<86400 then begin // recently seen?
   if (last_seen - first_seen) / 86400>=10 then historical:=4 else historical:=2;   //add two if we've seen it in the last 24 hours, four if it's older than 10 days
  end else historical:=86400 / (nowunix-last_seen);

  popularity:=(reports / rateofsuccess);

  result:=((connects*5)+(popularity/10)) * (2*rateofsuccess) * historical;
{
 	result:= (connects * 50.0) +
	         (reports * 10.0) +
	         (((connects + 1) / (attempts + 1)) * 200.0) +
	         (((last_seen - first_seen) / 86400) * 10.0) +
	         (((last_seen - helper_ares_nodes.db_nodes_oldest_last_seen) / 600) * 1.0); }
end;

destructor tares_node.destroy;
begin

 if out_buf<>nil then FreeAndNil(out_buf);//clear out buf
 if socket<>nil then FreeAndNil(socket);
     host:='';   //remote host server
  if searchIDs<>nil then FreeAndNil(searchIDS);
  
     inherited destroy;
end;

constructor tupload.create(tim:cardinal);
begin
inherited Create;
bsent:=0;
filename:='';
nickname:='';
out_reply_header:='';
start_time:=tim;
is_encrypted:=false;
bytes_in_buffer:=0;
SentHeader:=false;
his_progress:=0;
is_phash:=false;
isUDP:=false;
his_agent:='';
socket:=nil;
stream:=nil;
end;

destructor tupload.Destroy;
begin
filename:='';
nickname:='';
out_reply_header:='';
his_agent:='';
try
if socket<>nil then socket.free;
except
end;

try
if stream<>nil then FreeHandleStream(stream);
except
end;

inherited destroy;
end;



{ TWriteCache }
procedure TWriteCache.flush;
begin
helper_diskio.MyFileSeek(FStream,FCurrentDiskOffset,ord(soFromBeginning));
FStream.write(FBuffer[0],FCurrentInternalOffset);
inc(FCurrentDiskOffset,FCurrentInternalOffset);
FCurrentInternalOffset:=0;
end;

Procedure TWriteCache.write(data:pointer; len:cardinal);
begin
if len+FCurrentInternalOffset>length(FBuffer) then Flush;

move(data^,FBuffer[FCurrentInternalOffset],len);
inc(FCurrentInternalOffset,len);

end;


constructor TWriteCache.create(stream:THandleStream; DiskOffset:int64);
begin
inherited create;

FStream:=stream;
FCurrentDiskOffset:=diskoffset;
FCurrentInternalOffset:=0;
setLength(Fbuffer,65536{16384}{8192});
end;

destructor TWriteCache.destroy;
begin
if FCurrentInternalOffset>0 then Flush;
setLength(FBuffer,0);

inherited destroy;
end;


end.
