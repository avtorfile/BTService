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
bittorrent worker thread
}

unit thread_bitTorrent;

interface

uses
 classes,windows,sysutils,btcore,blcksock,synsock,classes2,dht_consts,
 {comettrees,tntwindows,}dht_int160,dht_search,dht_socket,activex,dht_zones,
 dialogs,uExtraData,IniFiles, uFunctions;

type
TThreadTracker=class(tthread)
 private
  TrackerIndex:Integer;
  UDP_RemoteSin:TVarSin;
 protected
  procedure log(txt:string);
 public
  Transfer:tbittorrentTransfer;
  procedure execute; override;
  constructor Create(CreateSuspended : Boolean; P : Pointer; TrackerNum: Integer);
end;

type
TThreadTransfer=class(tthread)
 private
   tickTransfer:Cardinal;
   bufferRecvBittorrent:array[0..4095] of char;
 protected
   procedure disconnectSource(transfer:TBittorrentTransfer; source:TBittorrentSource; RemoveRequests:boolean);
   procedure RemoveSource(transfer:TBittorrentTransfer; source:TBittorrentSource);
   function transferDeal(transfer:TBittorrentTransfer; source:tBitTorrentSource):boolean; overload;
   procedure SourceFlush(transfer:TBitTorrentTransfer; source:TBittorrentSource);
   procedure log(txt:string);
   procedure calcSourceUptime(source:TBitTorrentSource);
   procedure SourceParsePacket(transfer:TBitTorrentTransfer; source:TBittorrentSource);
   procedure updateBitField(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
   procedure ResetBitField(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
   procedure HandleIncomingRequest(transfer:TBittorrentTransfer; source:TBittorrentSource);
   procedure handleIncomingPiece(transfer:TBittorrentTransfer; source:TBittorrentSource);
   procedure mdht_handle_udpport(source:tbittorrentSource);
   procedure Handle_FastPeer_SuggestPiece(transfer:TBittorrentTransfer; source:TBittorrentSource);
   procedure Handle_FastPeer_HaveAll(transfer:TBittorrentTransfer; source:TBittorrentSource);
   procedure Handle_FastPeer_HaveNone(transfer:TBittorrentTransfer; source:TBittorrentSource);
   procedure Handle_FastPeer_RejectRequest(transfer:TBittorrentTransfer; source:TBittorrentSource);
   procedure handle_fastpeer_allowedfast(transfer:TBittorrentTransfer; source:TBittorrentSource);
   procedure Handle_ExtensionProtocol_Message(transfer:TBittorrentTransfer; source:TBittorrentSource);
   procedure RemoveoutGointRequest(transfer:tbittorrentTransfer; source:tbittorrentSource; pieceindex:cardinal; offset:cardinal; wantedlen:cardinal);
   procedure SetAllNotinterested(transfer:TBitTorrentTransfer);//download completed we no longer need seeders
   procedure areWeStillInterested(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
   function GetNumConnecting(transfer:TBitTorrentTransfer):integer;
   procedure SourceAddFailedAttempt(transfer:TBitTorrentTransfer; source:TBittorrentSource);
   procedure SendDHTPort(source:TBitTorrentSource);
 public
   Transfer:tbittorrentTransfer;
   procedure execute; override;
   constructor Create(CreateSuspended : Boolean; P : Pointer);
end;

type
tthread_bitTorrent=class(tthread)
 private
 last_sec,
 lasT_min,
 tick:cardinal;
 acceptedsockets:tmylist;
 UDP_RemoteSin:TVarSin;
 loc_numDownloads,loc_numUploads:word;
 //loc_speedDownloads,loc_SpeedUploads:cardinal;
 //loc_downloadedBytes,loc_UploadedBytes:int64;
 FMaxUlSpeed:cardinal;
 FHasLimitedOutput:boolean;
 bufferRecvBittorrent:array[0..4095] of char;

   mdht_nextExpireLists,
   mdht_nextExpirePartialSources,
   mdht_lastContact,
   mdht_bigTimer,
   mdht_nextSelfLookup,
   mdht_lastSecond,
   mdht_startTime,
   mdht_nextBackUpNodes,
   mdht_nextCacheCheck,
   mdht_lastBootstrap:cardinal;


 protected
  procedure AddVisualTransfers;//sync
  procedure execute; override;
  procedure log(txt:string);
//  procedure Update_Hint(node:PCmtVNode; treeview:TCometTree);
  procedure calcSourceUptime(source:TBitTorrentSource);


  procedure checkTracker; overload;
  procedure checkTracker(transfer:TBittorrentTransfer); overload;
//  procedure CompleteVisualTransfer;//sync
  procedure init_vars;
  procedure TrackerDeal; overload;
  procedure TrackerDeal(transfer:TBittorrentTransfer); overload;
  procedure transferDeal; overload;
  procedure transferDeal(transfer:TBittorrentTransfer); overload;
  function transferDeal(transfer:TBittorrentTransfer; source:tBitTorrentSource):boolean; overload;
  procedure shuffle_sources;
  function GetNumConnecting(transfer:TBitTorrentTransfer):integer;
  procedure SourceFlush(transfer:TBitTorrentTransfer; source:TBittorrentSource);
  procedure SourceParsePacket(transfer:TBitTorrentTransfer; source:TBittorrentSource);
  procedure shutdown;
  procedure getHandshaked_FromAcceptedSockets;
  procedure disconnectSource(transfer:TBittorrentTransfer; source:TBittorrentSource; RemoveRequests:boolean);
  procedure RemoveSource(transfer:TBittorrentTransfer; source:TBittorrentSource);

//  procedure deleteVisualGlobSource; //synch
//  procedure AddVisualGlobSource;//sync
  procedure AddVisualTransferReference(tran:TBitTorrentTransfer);
  procedure SendDHTPort(source:TBitTorrentSource);
  procedure SourceAddFailedAttempt(transfer:TBitTorrentTransfer; source:TBittorrentSource);
  procedure ResetBitField(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
  procedure updateBitField(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
  procedure handleIncomingPiece(transfer:TBittorrentTransfer; source:TBittorrentSource);
  procedure HandleIncomingRequest(transfer:TBittorrentTransfer; source:TBittorrentSource);
  procedure checkSourcesVisual(list:tmylist); overload;
  procedure checkSourcesVisual(transfer:TBittorrentTransfer); overload;
  procedure checkSourcesVisual; overload;
//  procedure update_transfer_visual;  //synch coming from ut_metadata aquisition
  procedure putStats;//sync
  function GetTransferFromHash(const HashStr:string):TbittorrentTransfer;
//  procedure updateVisualGlobSource;
  procedure processTempDownloads;//sync
  procedure BitTorrentCancelTransfer(Transfer:TBitTorrentTransfer);
  procedure BitTorrentPauseTransfer(Transfer:TBitTorrentTransfer);
  procedure areWeStillInterested(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
  procedure SetAllNotinterested(transfer:TBitTorrentTransfer);//download completed we no longer need seeders

  procedure Handle_FastPeer_SuggestPiece(transfer:TBittorrentTransfer; source:TBittorrentSource);
  procedure Handle_FastPeer_HaveAll(transfer:TBittorrentTransfer; source:TBittorrentSource);
  procedure Handle_FastPeer_HaveNone(transfer:TBittorrentTransfer; source:TBittorrentSource);
  procedure Handle_FastPeer_RejectRequest(transfer:TBittorrentTransfer; source:TBittorrentSource);
  procedure handle_fastpeer_allowedfast(transfer:TBittorrentTransfer; source:TBittorrentSource);
  procedure RemoveoutGointRequest(transfer:tbittorrentTransfer; source:tbittorrentSource; pieceindex:cardinal; offset:cardinal; wantedlen:cardinal);
  procedure Handle_ExtensionProtocol_Message(transfer:TBittorrentTransfer; source:TBittorrentSource);

  procedure mdht_fill_random_id; //synch
  procedure mdht_create_listener;
  procedure mdht_Receive;
  procedure mdht_check_second;
  procedure mdht_check_events;

  procedure mdht_handle_ping_req(const remoteconnectionid:string; remoteIPC:cardinal; remoteportW:word);
  procedure mdht_handle_ping_rep(const mdht_remote_node_id:string; remoteIPC:cardinal; remoteportW:word);
  procedure mdht_handle_getpeer_req(const remoteconnectionid:string; const info_hash:string; remoteIPC:cardinal; remoteportW:word);
  procedure mdht_handle_getpeer_rep(const mdht_remote_node_id:string; targetsearch:TmDHTsearch; const token:string; nodes:string; values:string; remoteIPC:cardinal; remoteportW:word);
  procedure mdht_handle_findnode_req(const mdht_remote_node_id:string; const remoteconnectionid:string; const target:string; remoteIPC:cardinal; remoteportW:word);
  procedure mdht_handle_findnode_rep(const mdht_remote_node_id:string; targetsearch:TmDHTsearch; nodes:string; token:string; remoteIPC:cardinal; remoteportW:word);
  procedure mdht_handle_announcepeer_req(const remoteconnectionid:string; const info_hash:string; const tcpport:string; const token:string; remoteIPC:cardinal; remoteportW:word);
  procedure mdht_handle_announcepeer_rep(const mdht_remote_node_id:string; remoteIPC:cardinal; remoteportW:word);
  procedure mdht_doannounce(transfer:tbittorrentTransfer; const mdht_token:string; remoteIPC:cardinal; remoteportW:word);
  procedure mdht_addContact(data:pbytearray; ip:cardinal; port:word; fromHelloReq:boolean);

  procedure mdht_handle_udpport(source:tbittorrentSource);
  procedure mdht_trybootstrap;
  procedure mdht_parse_incoming_message(ipC:cardinal; portW:word);
  procedure mdht_parse_incoming_query(ipC:cardinal; portW:word);
  procedure mdht_parse_incoming_reply(ipC:cardinal; portW:word);
  procedure mdht_parse_incoming_error(ipC:cardinal; portW:word);
  function mdht_numsrcsources:integer;
  procedure mdht_flush_announcedTorrents;


 public
  BittorrentTransfers:tmylist;
  TrackersThreadList:TList;
  TransfersThreadList:TList;
end;

 procedure UnChokeBestSourcesForaLeecher(HowMany:integer; transfer:TBittorrentTransfer; tick:cardinal);
 procedure UnChokeBestSourcesForaSeeder(HowMany:integer; transfer:TBittorrentTransfer; tick:cardinal);
// procedure updateVisualGlobSource;
 procedure CancelOutGoingRequestsForPiece(transfer:TBitTorrentTransfer; Source:TBittorrentSource; index:cardinal; offset:Cardinal);

 procedure ChokesDeal(list:Tmylist; tick:cardinal);
 procedure ChokesSeederDeal(transfer:TBittorrentTransfer; tick:cardinal);
 procedure ChokesLeecherDeal(transfer:TBittorrentTransfer; tick:cardinal);
 
 procedure RemoveOutGoingRequestForPiece(transfer:TBittorrentTransfer; index:integer);

 procedure ExpireOutGoingRequests(Transfer:TBitTorrentTransfer; tick:cardinal); overload;
 procedure ExpireOutGoingRequests(list:Tmylist; tick:cardinal); overload;
 procedure checkKeepAlives(list:Tmylist; tick:cardinal); overload;
 procedure checkKeepAlives(transfer:TBitTorrentTransfer; tick:cardinal); overload;
 procedure SendBitField(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
 procedure HandleCancelMessage(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
 procedure CalcChunksPopularity(transfer:TBitTorrentTransfer);
 procedure IncChunkPopularity(transfer:TBitTorrentTransfer; source:TBitTorrentSource; index:integer);
 function AskChunk(Transfer:TBitTorrentTransfer; source:TBitTorrentSource; tick:cardinal):boolean;
 procedure SourceDisconnect(source:TBitTorrentSource);
 procedure BroadcastHave(transfer:TBitTorrentTransfer; piece:TBitTorrentChunk);
 procedure RemoveOutGoingRequests(transfer:TBitTorrentTransfer); overload;
 procedure RemoveOutGoingRequests(transfer:TBitTorrentTransfer; source:TBitTorrentSource); overload;
 procedure CalcNumConnected(transfer:TBitTorrentTransfer);
 procedure DisconnectSeeders(transfer:TBitTorrentTransfer);//download completed we no longer need seeders
 procedure DropOlderIdleSources(transfer:TBitTorrentTransfer);
 function GetoptimumNumOutRequests(speedRecv:cardinal):integer;
 procedure Source_AddOutPacket(source:TBittorrentSource; const packet:string; ID:Byte; haspriority:boolean = false; index:cardinal = 0; offset:cardinal = 0; wantedLen:cardinal = 0); overload;
 procedure Source_AddOutPacket(transfer:TBitTorrentTransfer; sourceId:cardinal; const packet:string; ID:Byte; haspriority:boolean = false; index:cardinal = 0; offset:cardinal = 0; wantedLen:cardinal = 0); overload;
 function FindSourceFromID(transfer:TBitTorrentTransfer; ID:cardinal):TBitTorrentSource;

 function DropWorstConnectedInactiveSource(transfer:TBitTorrentTransfer; source:TBitTorrentSource; tick:cardinal):boolean;
 function PerformOptimisticUnchoke(transfer:TBitTorrentTransfer; tick:cardinal; isUpload:boolean=false):boolean;
 procedure ChokeEveryOneElse(transfer:TBitTorrentTransfer; UntouchableSourcesList:Tmylist);
 procedure CancelOutGoingPiece(transfer:TBitTorrentTransfer; source:TBitTorrentSource; index,offset:cardinal);
 procedure ParseHandshakeReservedBytes(source:TBittorrentSource; const extStr:string);
 Procedure SourceSetConnected(source:TBitTorrentSource);

 function FindPieceNotRequestedBySource(transfer:TBitTorrentTransfer; source:TBittorrentSource; piece:TBitTorrentChunk):integer;
 function FindPieceNotRequestedByAnySource(transfer:TBitTorrentTransfer; piece:TBitTorrentchunk):integer;
 function FindAnyPieceMissing(transfer:TBitTorrentTransfer; piece:TBitTorrentchunk):integer;

 function ChoseIncompleteChunk(transfer:TBitTorrentTransfer; source:TBitTorrentSource; var SuggestedFreeOffSetIndex:integer):TBittorrentChunk;
 function ChoseAnyChunk(transfer:TBitTorrentTransfer; source:TBitTorrentSource; var SuggestedFreeOffSetIndex:integer):TBittorrentChunk;
 function ChoseLeastPopularChunk(transfer:TBitTorrentTransfer; source:TBitTorrentSource; var SuggestedFreeOffSetIndex:integer):TBitTorrentChunk;
 function ChosePrioritaryChunk(transfer:TBitTorrentTransfer; source:TBitTorrentSource; var SuggestedFreeOffSetIndex:integer):TBitTorrentChunk;
 function Source_PeekRequest_InIncomingBuffer(source:TBitTorrentSource; request:precord_BitTorrentoutgoing_request):boolean;
 procedure Source_Increase_ReceiveStats(transfer:TBittorrentTransfer; Source:TBittorrentSource; previousLen,len_recv:integer; tick:cardinal);


 procedure parse_ut_pex(transfer:TBittorrentTransfer; cont:string);
 procedure saveTransfersDb(list:Tmylist);
 procedure DropCheatingClients(list:TMylist; tick:cardinal); overload;
 procedure DropCheatingClients(transfer:TBittorrentTransfer; tick:cardinal); overload;
 function CalcSourceOriginality(transfer:TBittorrentTransfer; source:TBittorrentSource):integer;
 function sourceIsTheOnlyOneHavingPiece(transfer:TBittorrentTransfer; source:TBittorrentSource; index:cardinal):boolean;
 function HasLimitedOutPut(UpSpeed:cardinal):boolean;
 procedure SendPexHandshake(source:tbittorrentSource);
 procedure mdht_ping_host(ipC:cardinal; portW:word);
 procedure mdht_sortCloserContacts(list:Tmylist; FromTarget:pCU_INT160);
 procedure FlushBannedIPs(list:TMylist; tick:cardinal);

 var
 globSource:tbittorrentSource;
 GlobTransfer:TBitTorrentTransfer;
 mypeerID,myrandkey,myAzIdentity,aresTorrentSignature:string;

 mdht_bootstrapclients:tmystringlist;
 DHTme160:CU_INT160;
 MDHT_len_tosend,
 MDHT_len_recvd:integer;
 MDHT_RemoteSendSin:TVarSin;
 MDHT_buffer:array[0..9999] of byte;
 MDHT_socket:hsocket;
 MDHT_AliveContacts:integer;
 MDHT_availableContacts:integer;
 MDHT_Searches:Tmylist;
 mdht_typemsg:byte;
 mdht_cont:string;
 mdht_nowt:cardinal;
 mdht_availablenodes:integer;
 mdht_routerbittorrentaddr:cardinal;
 mdht_lastFlushAnnouncedTorrents:cardinal;

 MDHT_udp_outpackets:tmylist;
 MDHT_Events:tmylist;
 MDHT_routingZone:TMDHTRoutingZone;
 mdht_announced_torrents:tmylist;
 
implementation

uses
 {ufrmmain,}BittorrentStringfunc,bitTorrentConst,vars_global,helper_strings,
 securehash,BitTorrentDlDb,helper_sorting,ares_objects,helper_datetime,
 const_ares,ares_types,helper_unicode,vars_localiz,
 helper_ipfunc,helper_sockets,helper_urls,helper_diskio,helper_registry,
 dht_searchManager;

constructor TThreadTracker.Create(CreateSuspended : Boolean; P : Pointer; TrackerNum: Integer);
var Tracker:TBittorrentTracker;
begin
 Transfer:=P;
 TrackerIndex:=TrackerNum;
 inherited Create(CreateSuspended);
 Tracker:=Transfer.trackers[TrackerIndex];
 Tracker.ThreadHandle:=Handle;
end;

constructor TThreadTransfer.Create(CreateSuspended : Boolean; P : Pointer);
begin
 Transfer:=P;
 inherited Create(CreateSuspended);
 Transfer.ThreadHandle:=Handle;       
end;

procedure mdht_sortCloserContacts(list:Tmylist; FromTarget:pCU_INT160);

  function SCompare(item1,item2:pointer):integer;
  var
  c1,c2:Tmdhtbucket;
  begin
  c1:=Tmdhtbucket(item1);
  c2:=Tmdhtbucket(item2);
  {
   result:=(synsock.ntohl(c1.id[0]) xor synsock.ntohl(FromTarget[0])) -
           (synsock.ntohl(c2.id[0]) xor synsock.ntohl(FromTarget[0]));   //smaller distance first
   if result<>0 then exit;
   result:=(synsock.ntohl(c1.id[1]) xor synsock.ntohl(FromTarget[1])) -
           (synsock.ntohl(c2.id[1]) xor synsock.ntohl(FromTarget[1]));   //smaller distance first
   if result<>0 then exit;
   result:=(synsock.ntohl(c1.id[2]) xor synsock.ntohl(FromTarget[2])) -
           (synsock.ntohl(c2.id[2]) xor synsock.ntohl(FromTarget[2]));   //smaller distance first
   if result<>0 then exit;
   result:=(synsock.ntohl(c1.id[3]) xor synsock.ntohl(FromTarget[3])) -
           (synsock.ntohl(c2.id[3]) xor synsock.ntohl(FromTarget[3]));   //smaller distance first
   if result<>0 then exit;
   result:=(synsock.ntohl(c1.id[4]) xor synsock.ntohl(FromTarget[4])) -
           (synsock.ntohl(c2.id[4]) xor synsock.ntohl(FromTarget[4]));   //smaller distance first  }

   result:=(c1.id[0] xor FromTarget[0]) -
           (c2.id[0] xor FromTarget[0]);   //smaller distance first
   if result<>0 then exit;
   result:=(c1.id[1] xor FromTarget[1]) -
           (c2.id[1] xor FromTarget[1]);   //smaller distance first
   if result<>0 then exit;
   result:=(c1.id[2] xor FromTarget[2]) -
           (c2.id[2] xor FromTarget[2]);   //smaller distance first
   if result<>0 then exit;
   result:=(c1.id[3] xor FromTarget[3]) -
           (c2.id[3] xor FromTarget[3]);   //smaller distance first
   if result<>0 then exit;
   result:=(c1.id[4] xor FromTarget[4]) -
           (c2.id[4] xor FromTarget[4]);   //smaller distance first

  end;

  procedure QuickSort(SortList: TmyList; L, R: Integer);
  var
    I, J: Integer;
    P, T: Pointer;
  begin
  try
   repeat
    I := L;
    J := R;
    P := SortList[(L + R) shr 1];
    repeat
      while SCompare(SortList[I], P) < 0 do Inc(I);
      while SCompare(SortList[J], P) > 0 do Dec(J);
      if I <= J then begin
        T := SortList[I];
        SortList[I] := SortList[J];
        SortList[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSort(SortList, L, J);
    L := I;
   until I >= R;
   except
   end;
  end;

begin
if list.count>0 then QuickSort(List, 0, List.Count - 1);
end;

procedure tthread_bitTorrent.init_vars;
var
zero:CU_INT160;
begin
tick:=gettickcount;
last_sec:=tick;
last_min:=tick;
 randseed:=gettickcount;

acceptedsockets:=tmylist.create;

loc_numDownloads:=0;
loc_numUploads:=0;
loc_speedDownloads:=0;
loc_speedUploads:=0;
loc_downloadedBytes:=0;
loc_UploadedBytes:=0;
 FMaxUlSpeed:=0;
 FHasLimitedOutput:=false;


aresTorrentSignature:='-'+BITTORRENT_APPNAME+BittorrentStringFunc.GetSerialized4CharVersionNumber+'-';
aresTorrentSignature:=TrimRight(aresTorrentSignature);
aresTorrentSignature:=TrimLeft(aresTorrentSignature);
//ShowMessage(aresTorrentSignature);
//Form1.Memo2.Lines.Add(aresTorrentSignature);
myAzidentity:=GetrandomChars(20);
thread_bittorrent.mypeerID:=aresTorrentSignature+GetrandomAsciiChars(12);
thread_bittorrent.myrandkey:=GetrandomAsciiChars(8);


 
 FillChar(MDHT_RemoteSendSin, Sizeof(MDHT_RemoteSendSin), 0);
 MDHT_Searches:=tmylist.create;
 MDHT_Events:=tmylist.create;

 mdht_routerbittorrentaddr:=0;
 mdht_bigtimer:=time_now;
 mdht_startTime:=mdht_bigtimer;
 mdht_lastSecond:=mdht_bigtimer;
 mdht_lastFlushAnnouncedTorrents:=mdht_bigtimer;
 mdht_nextExpireLists:=mdht_bigTimer+MIN2S(60);
 mdht_nextExpirePartialSources:=mdht_bigTimer+MIN2S(10);
 mdht_nextSelfLookup:=mdht_bigtimer+SEC(60);
 mdht_nextBackUpNodes:=mdht_bigTimer+MIN2S(10);
 mdht_nextCacheCheck:=mdht_bigTimer+MIN2S(4);
 mdht_lastContact:=0;
 dht_socket.mdht_currentOutpacketIndex:=0;
 MDHT_availableContacts:=0;
 MDHT_AliveContacts:=0;
 mdht_bootstrapclients:=tmystringlist.create;
 dht_socket.mdht_outpackets:=tmylist.create;
 MDHT_udp_outpackets:=tmylist.create;
 mdht_announced_torrents:=tmylist.create;


 CU_Int160_setValue(@zero,0);

  // random ID
  EnterCriticalSection(ServiceSection);
  try
  {synchronize}(mdht_fill_random_id);
  finally
    LeaveCriticalSection(ServiceSection);
  end;
  reg_getMDHT_ID(@DHTme160);
 

  MDHT_routingZone:=TMDHTRoutingZone.create;
  MDHT_routingZone.init(nil, 0, @zero, false);

  //Form1.Memo2.Lines.Add('data_path: '+vars_global.data_path+'\Data\MDHTnodes.dat');
  dht_zones.MDHT_readnodeFile(vars_global.data_path+'\Data\MDHTnodes.dat',MDHT_routingZone);
  MDHT_routingZone.startTimer;



 mdht_create_listener;

 reg_setMDHT_ID(DHTme160);  // set it right here
end;

procedure tthread_bitTorrent.mdht_create_listener;
var
sin:TVarSin;
er:integer;
ini: TMemIniFile;
begin
 FillChar(Sin, Sizeof(Sin), 0);
 Sin.sin_family:=AF_INET;
 Sin.sin_port:=synsock.htons(vars_global.my_mdht_port);
 Sin.sin_addr.s_addr:=0;

 MDHT_socket:=synsock.socket(PF_INET,integer(SOCK_DGRAM),IPPROTO_UDP);

 er:=synsock.Bind(MDHT_socket,@Sin,SizeOfVarSin(Sin));
 if er=0 then
 begin
   if PortableApp then
   begin
    ini:=TMemIniFile.Create(IniName);
    try
      ini.WriteInteger('Torrent','mdhtPort', vars_global.my_mdht_port);
    finally
      ini.UpdateFile;
      ini.Free;
    end;
   end
   else
   helper_registry.set_reginteger('Torrent.mdhtPort',vars_global.my_mdht_port);
 end;
 end;

procedure tthread_bitTorrent.mdht_Receive;
var
 er,len:integer;
 MDHT_RemoteSin:TVarSin;
begin

 if not TCPSocket_canRead(MDHT_socket,0,er) then exit;
 Len:=SizeOf(MDHT_RemoteSin);
 FillChar(MDHT_RemoteSin, Sizeof(MDHT_RemoteSin), 0);

 MDHT_len_recvd:=synsock.RecvFrom(MDHT_socket,
                                  MDHT_Buffer,
                                  sizeof(MDHT_buffer),
                                  0,
                                  @MDHT_RemoteSin,
                                  Len);

 if MDHT_len_recvd<5 then exit;

 if isAntiP2PIP(MDHT_remoteSin.sin_addr.S_addr) then exit;
 if ip_firewalled(MDHT_remoteSin.sin_addr.S_addr) then exit;
 if probable_fw(MDHT_remoteSin.sin_addr.S_addr) then exit;



 if (MDHT_Buffer[0]<>100) or
    (MDHT_Buffer[1]<>49) or
    (MDHT_Buffer[2]<>58) or
    (MDHT_Buffer[MDHT_len_recvd-1]<>101) then begin  // d1: <--> e
  exit;
 end;

 mdht_lastContact:=time_now; // prevents > 15 minutes inactivity (see check events)

 mdht_typemsg:=MDHT_Buffer[MDHT_len_recvd-2];

 setlength(mdht_cont,MDHT_len_recvd-2);
 move(MDHT_BUFFER[1],mdht_cont[1],length(mdht_cont));

 //streamlog.write(MDHT_Buffer,MDHT_len_recvd);
 mdht_parse_incoming_message(MDHT_remoteSin.sin_addr.S_addr,MDHT_remoteSin.sin_port);

 sleep(2);
end;

procedure tthread_bittorrent.mdht_parse_incoming_message(ipC:cardinal; portW:word);
var
 introStr:string;
begin
 introStr:=copy(mdht_cont,1,3);
 delete(mdht_cont,1,3);

 if introStr='1:a' then mdht_parse_incoming_query(ipC,portW) else
 if introStr='1:r' then mdht_parse_incoming_reply(ipC,portW) else
 if introStr='1:e' then mdht_parse_incoming_error(ipC,portW) else
end;

procedure tthread_bittorrent.mdht_parse_incoming_query(ipC:cardinal; portW:word);
var
  mdht_remote_node_id,mdht_target,mdht_info_hash,mdht_tcpport,mdht_token:string;

 procedure process_variable(variable:string; argument:string);
 begin
   if variable='id' then mdht_remote_node_id:=argument else
   if variable='target' then mdht_target:=argument else
   if variable='info_hash' then mdht_info_hash:=argument else
   if variable='port' then mdht_tcpport:=argument else
   if variable='token' then mdht_token:=argument else
   log('MDHT unknown variable: -->'+variable+'->'+argument+'<-- in query');
 end;

 procedure parse_query_dict(querydict:string);
 var
  consumed,lenStr,iterations:integer;
  variable,argument:string;
 begin
   consumed:=1;
   iterations:=0;
   while (length(querydict)>0) do begin

    if querydict[1]='e' then begin
     delete(mdht_cont,1,consumed+1);
     break;
    end;

     lenStr:=strtointdef(copy(querydict,1,pos(':',querydict)-1),0);
     delete(querydict,1,length(inttostr(lenStr))+1); inc(consumed,length(inttostr(lenStr))+1);
      variable:=copy(querydict,1,lenStr);
     delete(querydict,1,lenStr); inc(consumed,lenStr);

     if length(querydict)>2 then
      if querydict[1]='i' then begin
       delete(querydict,1,1); inc(consumed);
       argument:=copy(querydict,1,pos('e',querydict)-1);
       delete(querydict,1,length(argument)+1); inc(consumed,length(argument)+1);
          process_variable(variable,argument);
       inc(iterations);
       if iterations>10 then break;
       continue;
      end;

     lenStr:=strtointdef(copy(querydict,1,pos(':',querydict)-1),0);
     delete(querydict,1,length(inttostr(lenStr))+1); inc(consumed,length(inttostr(lenStr))+1);
      argument:=copy(querydict,1,lenStr);
     delete(querydict,1,lenStr); inc(consumed,lenStr);

     process_variable(variable,argument);
     inc(iterations);
     if iterations>10 then break;
    end;
 end;

var
 action:byte;
 variablename,variableargument:string;
 alen,iterations:integer;
 mdht_remoteconnectionid:string;
begin
action:=MDHT_ACTION_NONE;

   mdht_remoteconnectionid:='';

   parse_query_dict(copy(mdht_cont,2,length(mdht_cont)));

   if length(mdht_remote_node_id)<>20 then begin
    exit;
   end;

       iterations:=0;
       while (length(mdht_cont)>0) do begin
         // 1:q9:find_node1:t2:aa
        alen:=strtointdef(copy(mdht_cont,1,pos(':',mdht_cont)-1),0);
        delete(mdht_cont,1,length(inttostr(alen))+1);
         variablename:=copy(mdht_cont,1,alen);
        delete(mdht_cont,1,alen);
         alen:=strtointdef(copy(mdht_cont,1,pos(':',mdht_cont)-1),0);
         delete(mdht_cont,1,length(inttostr(alen))+1);
          variableargument:=copy(mdht_cont,1,alen);
         delete(mdht_cont,1,alen);


         if variablename='q' then begin
           if action=MDHT_ACTION_NONE then begin
            if variableargument='ping' then action:=MDHT_PING_REQ else
            if variableargument='get_peers' then action:=MDHT_GETPEER_REQ else
            if variableargument='find_node' then action:=MDHT_FINDNODE_REQ else
            if variableargument='announce_peer' then action:=MDHT_ANNOUNCEPEER_REQ else
            begin
             exit;
            end;
           end;
         end else
         if variablename='t' then begin
          mdht_remoteconnectionid:=variableargument;
         end;


         
         inc(iterations);
         if iterations>10 then break;
       end;


         case action of
           MDHT_PING_REQ:mdht_handle_ping_req(mdht_remoteconnectionid,ipC,portW);
           MDHT_GETPEER_REQ:mdht_handle_getpeer_req(mdht_remoteconnectionid,mdht_info_hash,ipC,portW);
           MDHT_FINDNODE_REQ:mdht_handle_findnode_req(mdht_remote_node_id,mdht_remoteconnectionid,mdht_target,ipC,portW);
           MDHT_ANNOUNCEPEER_REQ:mdht_handle_announcepeer_req(mdht_remoteconnectionid,mdht_info_hash,mdht_tcpport,mdht_token,ipC,portW);
         end;

end;


procedure tthread_bittorrent.mdht_parse_incoming_reply(ipC:cardinal; portW:word);
var
 mdht_remote_node_id,mdht_nodes,mdht_token,mdht_values:string;

 procedure process_variable(variable:string; argument:string);
 var
  dummys:string;
 begin
   if variable='id' then mdht_remote_node_id:=argument else
   if variable='nodes' then mdht_nodes:=argument else
   if variable='token' then mdht_token:=argument else
   if variable='values' then mdht_values:=argument else
   if variable='nodes2' then dummys:=argument else
   log('MDHT unknown variable:'+variable+'->'+argument+' in reply from:'+ipint_to_dotstring(ipC));
 end;

 procedure parse_values(var strin:string; var consumedbytes:integer);
 var
 lenstr:integer;
 begin
  while (length(strin)>1) do begin
   if strin[1]='e' then begin
    delete(strin,1,1);
    break;
   end;
    if pos('6:',strin)=1 then begin
     delete(strin,1,2);
     mdht_values:=mdht_values+copy(strin,1,6);
     delete(strin,1,6);
     inc(consumedbytes,8);
    end else
    if (pos(':',strin)=3) and (strtointdef(copy(strin,1,2),0)>0) then begin
     lenStr:=strtointdef(copy(strin,1,2),0);
     delete(strin,1,3);
     mdht_values:=mdht_values+copy(strin,1,lenStr);
     delete(strin,1,lenStr);
     inc(consumedBytes,3+lenStr);
    end else
    if (pos(':',strin)=4) and (strtointdef(copy(strin,1,3),0)>0) then begin
     lenStr:=strtointdef(copy(strin,1,3),0);
     delete(strin,1,4);
     mdht_values:=mdht_values+copy(strin,1,lenStr);
     delete(strin,1,lenStr);
     inc(consumedBytes,4+lenStr);
    end
    else begin
     break;
    end;
  end;
 end;

 procedure parse_reply_dict(replydict:string);
 var
  consumed,lenStr,iterations:integer;
  variable,argument:string;
 begin
   consumed:=1;
   iterations:=0;
   while (length(replydict)>0) do begin

     if length(replydict)=0 then begin
       delete(mdht_cont,1,consumed);
       break;
      end else
       if length(replydict)>=1 then begin
        if replydict[1]='e' then begin
         delete(mdht_cont,1,consumed+1);
         break;
        end;
      end;

     lenStr:=strtointdef(copy(replydict,1,pos(':',replydict)-1),0);
     delete(replydict,1,length(inttostr(lenStr))+1); inc(consumed,length(inttostr(lenStr))+1);
      variable:=copy(replydict,1,lenStr);
     delete(replydict,1,lenStr); inc(consumed,lenStr);

     if variable='values' then begin
       inc(consumed,2);
       delete(replydict,1,1);
       parse_values(replydict,consumed);
       continue;
     end;

     lenStr:=strtointdef(copy(replydict,1,pos(':',replydict)-1),0);
     delete(replydict,1,length(inttostr(lenStr))+1); inc(consumed,length(inttostr(lenStr))+1);
      argument:=copy(replydict,1,lenStr);
     delete(replydict,1,lenStr); inc(consumed,lenStr);


     process_variable(variable,argument);

     inc(iterations);
     if iterations>10 then break;

      if length(replydict)=0 then begin
       delete(mdht_cont,1,consumed);
       break;
      end else
       if length(replydict)>=1 then begin
        if replydict[1]='e' then begin
         delete(mdht_cont,1,consumed+1);
         break;
        end;

      end;

    end;
 end;

var
 variablename,variableargument,mdht_compconnectionid:string;
 outpacket:dht_socket.precord_outpacket;
 packetid:word;
 alen,iterations:integer;
 savemdht_cont:string;
begin

   parse_reply_dict(copy(mdht_cont,2,length(mdht_cont)));

   savemdht_cont:=mdht_cont;
   mdht_compconnectionid:='';

   if length(mdht_remote_node_id)<>20 then begin
    exit;
   end;

    iterations:=0;
    while (length(mdht_cont)>0) do begin
         // 1:q9:find_node1:t2:aa
        alen:=strtointdef(copy(mdht_cont,1,pos(':',mdht_cont)-1),0);
        delete(mdht_cont,1,length(inttostr(alen))+1);
         variablename:=copy(mdht_cont,1,alen);
        delete(mdht_cont,1,alen);
         alen:=strtointdef(copy(mdht_cont,1,pos(':',mdht_cont)-1),0);
         delete(mdht_cont,1,length(inttostr(alen))+1);
          variableargument:=copy(mdht_cont,1,alen);
         delete(mdht_cont,1,alen);



         if variablename='t' then begin
          mdht_compconnectionid:=variableargument;
          break;
         end;
         inc(iterations);
         if iterations>10 then break;
   end;

      if length(mdht_compconnectionid)<>2 then begin
        exit;
       end;

       move(mdht_compconnectionid[1],packetid,2);
       outpacket:=dht_socket.mdht_find_outpacket(packetid,ipC,portW);
       //find connection id to understand to what correlate this message
       if outpacket=nil then begin
        exit;
       end;

       case outpacket.ttype of
        query_ping:mdht_handle_ping_rep(mdht_remote_node_id,ipC,portW);
        query_getpeer:mdht_handle_getpeer_rep(mdht_remote_node_id,outpacket^.targetsearch,mdht_token,mdht_nodes,mdht_values,ipC,portW);
        query_findnode:mdht_handle_findnode_rep(mdht_remote_node_id,outpacket^.targetsearch,mdht_nodes,mdht_token,ipC,portW);
        query_announce:mdht_handle_announcepeer_rep(mdht_remote_node_id,ipC,portW);
       end;

       mdht_delete_outpacket(outpacket);
 end;

procedure tthread_bittorrent.mdht_parse_incoming_error(ipC:cardinal; portW:word);
begin
//
end;

procedure TThreadTransfer.mdht_handle_udpport(source:tbittorrentSource);
var
 strHost:string;
begin
if not source.SupportsDHT then begin
 exit;
end;

if source.portDHT<>0 then exit; //already assigned

if source.isNotAzureus then begin
 source.portDHT:=chars_2_word(copy(source.inBuffer,1,2));

 mdht_ping_host(source.ipC,source.portDHT);

 strHost:=int_2_dword_string(source.ipC)+int_2_word_string(source.portDHT);
 if mdht_bootstrapclients.count>=100 then mdht_bootstrapclients.delete(0);
 mdht_bootstrapclients.add(strHost);
end;

end;

procedure tthread_bittorrent.mdht_handle_udpport(source:tbittorrentSource);
var
 strHost:string;
begin
if not source.SupportsDHT then begin
 exit;
end;

if source.portDHT<>0 then exit; //already assigned

if source.isNotAzureus then begin
 source.portDHT:=chars_2_word(copy(source.inBuffer,1,2));

 mdht_ping_host(source.ipC,source.portDHT);

 strHost:=int_2_dword_string(source.ipC)+int_2_word_string(source.portDHT);
 if mdht_bootstrapclients.count>=100 then mdht_bootstrapclients.delete(0);
 mdht_bootstrapclients.add(strHost);
end;

end;

procedure tthread_bittorrent.mdht_handle_ping_rep(const mdht_remote_node_id:string; remoteIPC:cardinal; remoteportW:word);
var
// bucket:tmdhtbucket;
 me160,outstr:string;
begin


   if (mdht_routerbittorrentaddr=remoteIpC) then begin

           me160:=CU_INT160_tohexbinstr(@DHTme160);

           outstr:='d'+
                    '1:a'+
                     'd'+
                      '2:id20:'+me160+
                      '6:target20:'+me160+
                     'e'+
                    '1:q9:find_node'+
                    '1:t2:'+int_2_word_string(mdht_currentOutpacketIndex)+
                    '1:y1:q'+
                   'e';

           MDHT_len_tosend:=length(outstr);
           move(outstr[1],MDHT_buffer,length(outstr));

           dht_socket.mdht_send(remoteIPC,remoteportW,dht_socket.query_findnode,nil);
   exit;
  end;

  mdht_addContact(@mdht_remote_node_id[1] ,remoteIPC, remoteportW,false);

	// Set contact to alive.
	MDHT_RoutingZone.setAlive(remoteIPC,remoteportW);


end;

procedure tthread_bittorrent.mdht_addContact(data:pbytearray; ip:cardinal; port:word; fromHelloReq:boolean);
var
id,distance:CU_INT160;
ttype:byte;
c:tmdhtbucket;
begin

 move(data[0],id[0],4);
 move(data[4],id[1],4);
 move(data[8],id[2],4);
 move(data[12],id[3],4);
 move(data[16],id[4],4);
 
 id[0]:=synsock.ntohl(id[0]);
 id[1]:=synsock.ntohl(id[1]);
 id[2]:=synsock.ntohl(id[2]);
 id[3]:=synsock.ntohl(id[3]);
 id[4]:=synsock.ntohl(id[4]);

 ttype:=2;

  CU_INT160_FillNXor(@distance,@DHTme160,@id);
  c:=MDHT_routingZone.getContact(@id,@distance);
	if c<>nil then begin
    if c.ipC<>ip then exit; // another host may 'takeover 'any ID?
		//c.m_ip:=ip;
		c.portW:=port;
	end else begin
     // if he's unknown don't allow contacts too close to me, should be very far from me anyway...
      // since we use search rather than ping for closer distances
      if ((distance[0]<10000) or
          (distance[1]<10000) or
          (distance[2]<10000) or
          (distance[3]<10000) or
          (distance[4]<10000)) then begin
          exit;
      end;

      c:=MDHT_routingZone.FindHost(ip);
      if c<>nil then exit;        //we have seen already this host but with a different ID, probably a LAN network issue

			MDHT_routingZone.add(@id, ip, port, ttype);
   end;

end;

procedure tthread_bittorrent.mdht_handle_getpeer_rep(const mdht_remote_node_id:string; targetsearch:TmDHTsearch; const token:string; nodes:string; values:string; remoteIPC:cardinal; remoteportW:word);
var
 i,h:integer;
 ipC:cardinal;
 portW:word;
 transfer:tbittorrentTransfer;
 templist:tmystringlist;
 index:integer;
 bucket:tmdhtbucket;
 compid:cu_int160;

 id,zero,distance:CU_INT160;
 his_ip:cardinal;
 his_port:word;
 results,tempContacts:tmylist;
 found:boolean;
 s:tmdhtsearch;
begin

if (mdht_routerbittorrentaddr<>remoteIpC) then begin
   // Set contact to alive.
 MDHT_RoutingZone.setAlive(remoteipC,remoteportW);
end;

found:=false;
for i:=0 to MDHT_Searches.count-1 do begin
   s:=MDHT_Searches[i];
   if s=targetSearch then begin
    found:=true;
    break;
   end;
end;
if not found then exit;

CU_INT160_copyFromBufferRev(@s.m_target,@compid);
found:=false;
for i:=0 to BittorrentTransfers.count-1 do begin
 transfer:=BittorrentTransfers[i];
 if not CU_INT160_Compare(@transfer.fhashValue[1],@compid) then continue;
  found:=true;
  break;
end;
if not found then exit;




    if length(values)>=6 then begin //alt sources available!
      log('Results!'+inttostr(length(values) div 6));

      templist:=tmystringlist.create;

        index:=1;
        while (index<=length(values)) do begin
         if templist.indexof(copy(values,index,4))<>-1 then begin
          inc(index,6);
          continue;
         end;
         templist.add(copy(values,index,4));

         ipC:=chars_2_dword(copy(values,index,4));
         portW:=chars_2_wordRev(copy(values,index+4,2));
         transfer.addSource(ipC,portW,'','DHT');
         //ShowMessage('DHT: '+IntToStr(ipC));
         if templist.count>=100 then break;
         inc(index,6);
        end;


        templist.free;
        if transfer.fsources.count>=250 then targetSearch.expire;
     end;



    if length(nodes)>=26 then begin
     //log('FIND PEER TO FAR!');
     results:=tmylist.create;
     tempContacts:=tmylist.create;

     CU_Int160_setValue(@zero,0);
  
     for h:=0 to 7 do begin
      if length(nodes)<26 then break;

      CU_INT160_CopyFromBufferRev(@nodes[1],@id);

      move(nodes[21],his_ip,4);
       move(nodes[25],his_port,2);
      delete(nodes,1,26);

      if CU_INT160_Compare(@id,@zero) then continue;

      if isAntiP2PIP(his_ip) then continue;
      if ip_Firewalled(his_ip) then continue;
      if probable_fw(his_ip) then continue;


      // *********************  check for duplicates *****************************
       bucket:=MDHT_routingZone.FindHost(his_ip);
       if bucket<>nil then begin
          if ((bucket.ID[0]<>id[0]) or
              (bucket.ID[1]<>id[1]) or
              (bucket.ID[2]<>id[2]) or
              (bucket.ID[3]<>id[3]) or
              (bucket.ID[4]<>id[3])) then continue; // already seen this ip but with different ID
         end else begin
           CU_INT160_FillNXor(@distance,@DHTMe160,@id);
           bucket:=MDHT_routingZone.getContact(@id,@distance);
           if bucket<>nil then
            if his_ip<>bucket.ipC then continue; //already seen ID but with different IP
         end;
        // ***************************************************************************
        if (mdht_routerbittorrentaddr<>his_ip) then begin
         MDHT_routingZone.add(@id, his_ip, his_port, 2);
        end;

        bucket:=tmdhtbucket.create;
         bucket.ipC:=his_ip;
         bucket.portW:=his_port;
         CU_INT160_CopyFromBuffer(@id,@bucket.ID);

         results.add(bucket);
         tempContacts.add(bucket);
       end;

      if results.count>0 then dht_searchManager.processResponse(s, remoteIPC,remoteportW, results, tempContacts);

     tempContacts.free;
     results.free;
    end;



    if not vars_global.im_firewalled then begin
      mdht_doannounce(transfer,token,remoteIPC,remoteportW);
    end;



end;


procedure tthread_bittorrent.mdht_doannounce(transfer:tbittorrentTransfer; const mdht_token:string; remoteIPC:cardinal; remoteportW:word);
var
 outstr,me160:string;
begin
//d1:ad2:id20:abcdefghij01234567899:info_hash20:mnopqrstuvwxyz1234564:porti6881e5:token8:aoeusnthe1:q13:announce_peer1:t2:aa1:y1:qe
me160:=CU_INT160_tohexbinstr(@DHTme160);

outstr:='d'+
         '1:a'+
           'd'+
             '2:id20:'+me160+
             '9:info_hash20:'+transfer.fhashValue+
             '4:porti'+inttostr(vars_global.myport)+'e'+
             '5:token'+inttostr(length(mdht_token))+':'+mdht_token+
           'e'+
         '1:q13:announce_peer'+
         '1:t2:'+int_2_word_string(mdht_currentOutpacketIndex)+
         '1:y1:q'+
        'e';

MDHT_len_tosend:=length(outstr);
move(outstr[1],MDHT_buffer,length(outstr));

dht_socket.mdht_send(remoteIPC,remoteportW,dht_socket.query_announce);
end;

procedure tthread_bittorrent.mdht_handle_findnode_rep(const mdht_remote_node_id:string; targetsearch:TmDHTsearch; nodes:string; token:string; remoteIPC:cardinal; remoteportW:word);
var
 results:tmylist;
 tempContacts:tmylist;
 i:integer;
 id,zero,distance:CU_INT160;
 his_ip:cardinal;
 his_port:word;
// strtemp:string;
 bucket:tmdhtbucket;
 s:tmdhtsearch;
 found:boolean;
begin
 if (mdht_routerbittorrentaddr<>remoteIpC) then begin
   // Set contact to alive.
  MDHT_RoutingZone.setAlive(remoteipC,remoteportW);
 end;

 if length(nodes)<26 then exit;

found:=false;
for i:=0 to MDHT_Searches.count-1 do begin
   s:=MDHT_Searches[i];
   if s=targetSearch then begin
    found:=true;
    break;
   end;
end;
if (not found) and
   (mdht_routerbittorrentaddr<>remoteIpC) then exit;


  results:=tmylist.create;
  tempContacts:=tmylist.create;

  CU_Int160_setValue(@zero,0);
  
for i:=0 to 7 do begin
 if length(nodes)<26 then break;

  CU_INT160_CopyFromBufferRev(@nodes[1],@id);
 // strtemp:=copy(nodes,1,20);

  move(nodes[21],his_ip,4);
  move(nodes[25],his_port,2);
 delete(nodes,1,26);

 if CU_INT160_Compare(@id,@zero) then continue;

   if isAntiP2PIP(his_ip) then continue;
   if ip_Firewalled(his_ip) then continue;
   if probable_fw(his_ip) then continue;


   // *********************  check for duplicates *****************************
    bucket:=MDHT_routingZone.FindHost(his_ip);
    if bucket<>nil then begin
       if ((bucket.ID[0]<>id[0]) or
           (bucket.ID[1]<>id[1]) or
           (bucket.ID[2]<>id[2]) or
           (bucket.ID[3]<>id[3]) or
           (bucket.ID[4]<>id[3])) then continue; // already seen this ip but with different ID
    end else begin
      CU_INT160_FillNXor(@distance,@DHTMe160,@id);
      bucket:=MDHT_routingZone.getContact(@id,@distance);
       if bucket<>nil then
         if his_ip<>bucket.ipC then continue; //already seen ID but with different IP
    end;
   // ***************************************************************************
   if (mdht_routerbittorrentaddr<>his_ip) then begin
    MDHT_routingZone.add(@id, his_ip, his_port, 2);
   end;

     bucket:=tmdhtbucket.create;
      bucket.ipC:=his_ip;
      bucket.portW:=his_port;
      CU_INT160_CopyFromBuffer(@id,@bucket.ID);

      results.add(bucket);
      tempContacts.add(bucket);
 end;

if (found) and
   (results.count>0) then dht_searchManager.processResponse(s, remoteIPC,remoteportW, results, tempContacts);

 tempContacts.free;
 results.free;
end;

procedure tthread_bittorrent.mdht_handle_announcepeer_rep(const mdht_remote_node_id:string; remoteIPC:cardinal; remoteportW:word);
begin

//
end;



procedure tthread_bittorrent.mdht_handle_ping_req(const remoteconnectionid:string; remoteIPC:cardinal; remoteportW:word);
var
 outstr:string;
begin

outstr:=CU_INT160_tohexbinstr(@DHTme160);
outstr:='d1:rd2:id20:'+outstr+'e'+
        '1:t'+inttostr(length(remoteconnectionid))+':'+remoteconnectionid+
        '1:y1:re';

MDHT_len_tosend:=length(outstr);
move(outstr[1],MDHT_buffer,length(outstr));
dht_socket.mdht_send(remoteIPC,remoteportW);
end;

procedure tthread_bittorrent.mdht_handle_getpeer_req(const remoteconnectionid:string; const info_hash:string; remoteIPC:cardinal; remoteportW:word);
var
 outstr:string;
 distance:CU_INT160;
 results:tmylist;
// count:integer;
 i:integer;
 nodesStr,token,hostStr,replystring:string;
 c:tmdhtbucket;
 targetid:CU_INT160;
 sha1:Tsha1;
 found:boolean;
 dht_announcedTorrent:precord_mdht_announced_torrent;
begin
replystring:='';

 //calculate reply token
 hostStr:=ipint_to_dotstring(remoteIPC);
 sha1:=tsha1.create;
 sha1.Transform(hostStr[1],length(hoststr));
 sha1.complete;
 token:=sha1.HashValue;
 sha1.free;
 delete(token,9,length(token));


 found:=false;
 for i:=0 to mdht_announced_torrents.count-1 do begin
  dht_announcedTorrent:=mdht_announced_torrents[i];
  if dht_announcedTorrent^.hash[4]<>info_hash[4] then continue;
   if dht_announcedTorrent^.hash<>info_hash then continue;
   found:=true;
   break;
 end;
 if found then begin
  for i:=0 to dht_announcedTorrent^.clients.count-1 do replystring:=replystring+dht_announcedTorrent^.clients[i];
  replystring:='6:values'+inttostr(length(replystring))+':'+replystring;
 // log('Incoming get peer req, adding some values:'+replystring);
 end;

if length(replystring)<60 then begin
CU_INT160_copyFromBufferRev(@info_hash[1],@targetid);

CU_INT160_fillNXor(@distance,@DHTme160,@targetid);

//log('Incoming getpeerREQ:'+CU_INT160_tohexstr(@info_hash[1],false)+'  me:'+CU_INT160_tohexstr(@DHTme160,true)+' dist from me:'+CU_INT160_tohexstr(@distance,true));


	//This is the target node trying to be found.
  CU_INT160_FillNXor(@distance,@DHTme160,@targetid); // distance relative to my tree


	// Get 8 nodes close to wanted target
 results:=tmylist.create;
	MDHT_RoutingZone.getClosestTo(2, @targetid, @distance, 8, results);

 nodesStr:='';
 for i:=0 to 7 do begin
  if i>=results.count then break;
  c:=results[i];
  nodesStr:=nodesStr+CU_INT160_tohexbinstr(@c.ID)+
                     int_2_dword_string(c.ipC)+
                     int_2_word_string(c.portW);

  CU_INT160_fillNXor(@distance,@c.ID,@targetid);
 // log('Adding reply node:'+CU_INT160_tohexstr(@c.ID,true)+' distance:'+CU_INT160_tohexstr(@distance,true));
 end;
 if length(nodesStr)>=26 then begin
  replystring:=replystring+'5:nodes'+inttostr(length(nodesStr))+':'+nodesStr;
 end;
 results.free;

 // log('Incoming getpeerREQ:'+ipint_to_dotstring(remoteIPC)+' replylen:'+inttostr(length(nodesStr) div 26));


end;

 if length(replystring)=0 then exit;

 
 outstr:=CU_INT160_tohexbinstr(@DHTme160);
 outstr:='d'+
           '1:r'+
             'd'+
              '2:id20:'+outstr+
              '5:token'+inttostr(length(token))+':'+token+
              replystring+
             'e'+
           '1:t'+inttostr(length(remoteconnectionid))+':'+remoteconnectionid+
           '1:y1:r'+
         'e';

 MDHT_len_tosend:=length(outstr);
 move(outstr[1],MDHT_buffer,length(outstr));
 dht_socket.mdht_send(remoteIPC,remoteportW);
end;

procedure tthread_bittorrent.mdht_handle_findnode_req(const mdht_remote_node_id:string; const remoteconnectionid:string; const target:string; remoteIPC:cardinal; remoteportW:word);
var
 outstr:string;
 distance:CU_INT160;
 results:tmylist;
// count:integer;
 i:integer;
 nodesStr:string;
 c:tmdhtbucket;
 targetid:CU_INT160;
begin

CU_INT160_copyFromBufferRev(@target[1],@targetid);

CU_INT160_fillNXor(@distance,@DHTme160,@targetid);

//me160str:=CU_INT160_tohexstr(@DHTme160,true);
//log('Incoming findnodeREQ:'+CU_INT160_tohexstr(@target[1],false)+'  me:'+me160str+' dist from me:'+CU_INT160_tohexstr(@distance,true));


  mdht_addContact(@mdht_remote_node_id[1],remoteIPC, remoteportW,false);

	//This is the target node trying to be found.
  CU_INT160_FillNXor(@distance,@DHTme160,@targetid); // distance relative to my tree


	// Get 8 nodes close to wanted target
 results:=tmylist.create;
	MDHT_RoutingZone.getClosestTo(2, @targetid, @distance, 8, results);

 nodesStr:='';
 for i:=0 to 7 do begin
  if i>=results.count then break;
  c:=results[i];
  nodesStr:=nodesStr+CU_INT160_tohexbinstr(@c.ID)+
                     int_2_dword_string(c.ipC)+
                     int_2_word_string(c.portW);

  CU_INT160_fillNXor(@distance,@c.ID,@targetid);
 // log('Adding reply node:'+CU_INT160_tohexstr(@c.ID,true)+' distance:'+CU_INT160_tohexstr(@distance,true));
 end;
 if results.count=0 then begin
  results.free;
  exit;
 end;
 results.free;

 //log('----------------');

 outstr:=CU_INT160_tohexbinstr(@DHTme160);
 outstr:='d'+
           '1:r'+
             'd'+
              '2:id20:'+outstr+
              '5:nodes'+inttostr(length(nodesStr))+':'+nodesStr+
             'e'+
           '1:t'+inttostr(length(remoteconnectionid))+':'+remoteconnectionid+
           '1:y1:r'+
         'e';

 MDHT_len_tosend:=length(outstr);
 move(outstr[1],MDHT_buffer,length(outstr));
 dht_socket.mdht_send(remoteIPC,remoteportW);
end;

procedure tthread_bittorrent.mdht_flush_announcedTorrents;
var
 i:integer;
 dht_announcedTorrent:precord_mdht_announced_torrent;
begin
i:=0;
 while (i<mdht_announced_torrents.count) do begin
  dht_announcedTorrent:=mdht_announced_torrents[i];
  if mdht_nowt-dht_announcedTorrent^.last>MIN2S(30) then begin
    log('Flushing old announcedTorrent:'+bytestr_to_hexstr(dht_announcedTorrent^.hash));
    mdht_announced_torrents.delete(i);
     dht_announcedTorrent^.hash:='';
     dht_announcedTorrent.clients.free;
    FreeMem(dht_announcedTorrent,sizeof(record_mdht_announced_torrent));
    continue;
  end;
  inc(i);
 end;
end;

procedure tthread_bittorrent.mdht_handle_announcepeer_req(const remoteconnectionid:string; const info_hash:string;
 const tcpport:string; const token:string; remoteIPC:cardinal; remoteportW:word);
var
 hostStr,tokencomp,outstr:string;
 sha1:tsha1;
 announcedid,distance:cu_int160;
 i,ind:integer;
 found:boolean;
 dht_announcedTorrent:precord_mdht_announced_torrent;
begin



 if length(info_hash)<>20 then begin
  log('incoming announce malformed info_hash');
  exit;
 end;
 if length(token)<>8 then begin
  log('incoming announce malformed token len:'+inttostr(length(token)));
  exit;
 end;

 hostStr:=ipint_to_dotstring(remoteIPC);
 sha1:=tsha1.create;
 sha1.Transform(hostStr[1],length(hoststr));
 sha1.complete;
 tokencomp:=sha1.HashValue;
 sha1.free;
 delete(tokencomp,9,length(tokencomp));

 if token<>tokencomp then begin
  log('Incoming announceREQ:'+ipint_to_dotstring(remoteIPC)+' WRONG TOKEN!');
  exit;
 end;

 CU_INT160_copyFromBufferRev(@info_hash[1],@announcedid);
 CU_INT160_fillNXor(@distance,@DHTme160,@announcedid);

 if DHTme160[0] xor announcedid[0] > MDHT_SEARCH_TOLERANCE then begin
  log('Incoming announceREQ NOT acceptable:'+CU_INT160_tohexstr(@info_hash[1],false)+
     '  me:'+CU_INT160_tohexstr(@DHTme160,true)+
     ' dist from me:'+CU_INT160_tohexstr(@distance,true));
     exit;
 end;

// log('Incoming announceREQ:'+CU_INT160_tohexstr(@info_hash[1],false)+
 //     '  me:'+CU_INT160_tohexstr(@DHTme160,true)+' dist from me:'+CU_INT160_tohexstr(@distance,true)+
 //     ' host:'+ipint_to_dotstring(remoteipC)+':'+tcpport);

 hostStr:=int_2_dword_string(remoteIPC)+
          int_2_word_stringrev(strtointdef(tcpport,0));

 found:=false;
 for i:=0 to mdht_announced_torrents.count-1 do begin
  dht_announcedTorrent:=mdht_announced_torrents[i];
  if dht_announcedTorrent^.hash[4]<>info_hash[4] then continue;
   if dht_announcedTorrent^.hash<>info_hash then continue;
    ind:=dht_announcedTorrent.clients.indexof(hoststr);
    if ind<>-1 then dht_announcedTorrent.clients.delete(ind);
    if dht_announcedTorrent.clients.count>=100 then dht_announcedTorrent.clients.delete(0);
    dht_announcedTorrent.clients.add(hoststr);
    dht_announcedTorrent.last:=mdht_nowt;
   // log('Added host to known torrent:'+bytestr_to_hexstr(info_hash)+' host:'+ipint_to_dotstring(remoteipC)+':'+inttostr(strtointdef(tcpport,0)));
    found:=true;
    break;
 end;
 if (not found) and
    (mdht_announced_torrents.count<2000) then begin
  dht_announcedTorrent:=AllocMem(sizeof(record_mdht_announced_torrent));
   dht_announcedTorrent^.hash:=info_hash;
   dht_announcedTorrent^.last:=mdht_nowt;
   dht_announcedTorrent^.clients:=tmystringlist.create;
   dht_announcedTorrent^.clients.add(hoststr);
  mdht_announced_torrents.add(dht_announcedTorrent);
  //log('Added announced torrent:'+bytestr_to_hexstr(info_hash)+' host:'+ipint_to_dotstring(remoteipC)+':'+inttostr(strtointdef(tcpport,0)));
 end;

 
  outstr:=CU_INT160_tohexbinstr(@DHTme160);
  outstr:='d'+
            '1:r'+
             'd'+
              '2:id20:'+outstr+
             'e'+
            '1:t'+inttostr(length(remoteconnectionid))+':'+remoteconnectionid+
            '1:y1:r'+
           'e';



   MDHT_len_tosend:=length(outstr);
   move(outstr[1],MDHT_buffer,length(outstr));
   dht_socket.mdht_send(remoteIPC,remoteportW);



end;

function tthread_bittorrent.mdht_numsrcsources:integer;
var
i:integer;
src:tmdhtsearch;
begin                  
result:=0;
 for i:=0 to MDHT_Searches.count-1 do begin
  src:=MDHT_Searches[i];
  if src.m_type=dht_consts.FINDSOURCE then inc(result);
 end;
end;

procedure tthread_bitTorrent.mdht_check_second;
var
 i:integer;
 tran:tbittorrentTransfer;
 Find:boolean;
begin
if mdht_lastSecond>mdht_nowt then exit;
 mdht_lastSecond:=mdht_nowt+1;

if vars_global.InternetConnectionOK then begin

 if ((mdht_lastContact=0) or
     (mdht_nowt-mdht_lastContact>MDHT_DISCONNECTDELAY)) then
     if mdht_nowt-mdht_startTime>SEC(60) then mdht_trybootstrap;

 dht_searchManager.checkSearches(mdht_nowt);

 dht_socket.mdht_expireoutpackets(mdht_nowt);

 if (mdht_numsrcsources=0) and (mdht_nowt-mdht_startTime>SEC(20)) then begin
   BitTorrentTransfers.sort(sort_lastudpsearchlast);
   Find:=false;
   for i:=0 to BitTorrentTransfers.count-1 do begin
    tran:=BitTorrentTransfers[i];
    if tran.fstate=dlPaused then continue;
    if tran.fstate=dlAllocating then continue;
    if tran.fsources.count>200 then continue;
    if tran.fstate=dlSeeding then continue;

    if mdht_nowt-tran.m_lastudpsearch>MIN2S(15) then begin
     dht_searchmanager.mdht_get_peers(tran);  
     Find:=True;
     break;
    end;
   end;

   if find=False then
   for i:=0 to BitTorrentTransfers.count-1 do begin
    tran:=BitTorrentTransfers[i];
    if tran.fstate=dlPaused then continue;
    if tran.fstate=dlAllocating then continue;
    if tran.fsources.count>200 then continue;  

    if mdht_nowt-tran.m_lastudpsearch>MIN2S(15) then begin
     dht_searchmanager.mdht_get_peers(tran);
     break;
    end;
   end;

 end;

 if mdht_nowt-mdht_lastFlushAnnouncedTorrents>MIN2S(30) then begin
  mdht_lastFlushAnnouncedTorrents:=mdht_nowt;
  mdht_flush_announcedTorrents;
 end;

 if mdht_nextSelfLookup<=mdht_nowt then begin // self lookup ...search for closest hosts
	if dht_SearchManager.findNodeComplete then mdht_nextSelfLookup:=mdht_nowt+MIN2S(18);
 end;

end;



end;

procedure tthread_bittorrent.mdht_check_events;
var
i:integer;
zone:TMDHTRoutingZone;
FeelsAlone:boolean;
begin

FeelsAlone:=((mdht_lastContact>0) and
             (mdht_nowt-mdht_lastContact>MDHT_DISCONNECTDELAY-MIN2S(5)));

for i:=0 to MDHT_events.count-1 do begin
  zone:=TMDHTRoutingZone(MDHT_events[i]);


     if mdht_bigtimer<=mdht_nowt then begin

        if ((zone.m_nextBigTimer<=mdht_nowt) or (FeelsAlone)) then begin

						if zone.onBigTimer then begin
							zone.m_nextBigTimer:=HR2S(1)+mdht_nowt;
							mdht_bigTimer:=SEC(10)+mdht_nowt;
						end;

				end;

      end;


      if zone.m_nextSmallTimer<=mdht_nowt then begin
				zone.onSmallTimer;
				zone.m_nextSmallTimer:=MIN2S(1)+mdht_nowt;
			end;

end;


end;

procedure mdht_ping_host(ipC:cardinal; portW:word);
var
 strout,mydhtidstr:string;
begin
mydhtidstr:=CU_INT160_tohexbinstr(@DHTme160);

strout:='d'+
         '1:a'+
          'd'+
           '2:id20:'+mydhtidstr+
          'e'+
         '1:q4:ping'+
         '1:t2:'+int_2_word_string(mdht_currentOutpacketIndex)+
         '1:y1:q'+
        'e';


MDHT_len_tosend:=length(strout);
move(strout[1],MDHT_buffer,MDHT_len_tosend);


dht_socket.mdht_send(ipC,portW,dht_socket.query_ping);
end;

procedure tthread_bitTorrent.mdht_trybootstrap;
var
 strHost:string;
 ipC:cardinal;
 portW:word;
 HostEnt: PHostEnt;
 addr:tvarsin;
begin

if mdht_bootstrapclients.count=0 then begin

 if (mdht_nowt-mdht_lastBootstrap>MIN2S(15)) or
    (mdht_lastBootstrap=0) then begin
   mdht_lastBootstrap:=mdht_nowt;

        HostEnt:=synsock.GetHostByName(PChar('router.bittorrent.com'));
        if HostEnt<>nil then begin
         addr.sin_addr.s_addr:=u_long(Pu_long(HostEnt^.h_addr_list^)^);
         mdht_routerbittorrentaddr:=addr.sin_addr.s_addr;
         log('pinging router.bittorrent.com');
         mdht_ping_host(mdht_routerbittorrentaddr,synsock.htons(6881));
          exit;
       end;
 end;

exit;
end;


if mdht_bootstrapclients.count>1 then shuffle_mystringlist(mdht_bootstrapclients);

strHost:=mdht_bootstrapclients[0];
         mdht_bootstrapclients.delete(0);

ipC:=chars_2_dword(copy(strHost,1,4));
portW:=chars_2_word(copy(strHost,5,2));


mdht_ping_host(ipC,portW);
end;


procedure tthread_bitTorrent.mdht_fill_random_id; //synch
var
 i:integer;
 tim:cardinal;
 guid:Tguid;
 buffer:array[0..19] of byte;
begin
coinitialize(nil);
cocreateguid(guid);
couninitialize;

move(guid,buffer[0],16);
tim:=gettickcount;
move(tim,buffer[16],4);

 //shuffle a bit
  for i:=0 to 19 do buffer[i]:=buffer[i]+random(256);
  for i:=19 downto 0 do buffer[i]:=buffer[i]+random(256);
  for i:=0 to 19 do buffer[i]:=buffer[i]+random(256);
  for i:=19 downto 0 do buffer[i]:=buffer[i]+random(256);

  move(buffer[0],DHTme160[0],4);
  move(buffer[4],DHTme160[1],4);
  move(buffer[8],DHTme160[2],4);
  move(buffer[12],DHTme160[3],4);
  move(buffer[16],DHTme160[4],4);

end;



procedure tthread_bitTorrent.AddVisualTransferReference(tran:TBitTorrentTransfer);
var
// dataNode:ares_types.precord_data_node;
// node:PCMtVNode;
 data:precord_displayed_bittorrentTransfer;
 afile:TBitTorrentFile;
 tracker:tbittorrentTracker;
begin

//     if tran.UploadTreeview then begin
//       node:=ares_frmmain.treeview_upload.AddChild(nil);
//       dataNode:=ares_frmmain.treeview_upload.getdata(Node);
//     end else begin
//       node:=ares_frmmain.treeview_download.AddChild(nil);
//       dataNode:=ares_frmmain.treeview_download.getdata(Node);
//      end;
//      dataNode^.m_type:=dnt_bittorrentMain;
//
//      data:=AllocMem(sizeof(record_displayed_bittorrentTransfer));
//      dataNode^.data:=Data;
//
//     tran.visualNode:=node;
     tran.visualData:=data;
     tran.visualData^.handle_obj:=longint(tran);
     tran.visualData^.ID:=tran.fid;
     tran.visualData^.FileName:=widestrtoutf8str(helper_urls.extract_fnameW(utf8strtowidestr(tran.fname)));
     tran.visualData^.Size:=tran.fsize;
     tran.visualData^.downloaded:=tran.fdownloaded;
     tran.visualData^.uploaded:=tran.fuploaded;
     tran.visualData^.hash_sha1:=tran.fhashvalue;
     tran.visualData^.crcsha1:=crcstring(tran.fhashvalue);
     tran.visualData^.SpeedDl:=0;
     tran.visualData^.SpeedUl:=0;
     tran.visualData^.elapsed:=tran.m_elapsed;
     tran.visualData^.want_cancelled:=false;
     tran.visualData^.want_paused:=false;
     tran.visualData^.want_changeView:=false;
     tran.visualData^.want_cleared:=false;
     tran.visualData^.uploaded:=tran.fuploaded;
     tran.visualData^.downloaded:=tran.fdownloaded;
     tran.visualData^.num_Sources:=0;
     tran.visualData^.ercode:=0;
     tran.visualData^.state:=tran.fstate;
     if tran.trackers.count>0 then begin
      tracker:=tran.trackers[tran.trackerIndex];
      tran.visualData^.trackerStr:=tracker.URL;
     end else tran.visualData^.trackerStr:='';
     tran.visualData^.Fpiecesize:=tran.fpieceLength;
     tran.visualData^.NumLeechers:=0;
     tran.visualData^.NumSeeders:=0;
     if tran.ffiles.count=1 then begin
       afile:=tran.ffiles[0];
       tran.visualData^.path:=afile.ffilename;
     end else tran.visualData^.path:=tran.fname;
     tran.visualData^.NumConnectedSeeders:=tran.NumConnectedSeeders;
     tran.visualData^.NumConnectedLeechers:=tran.NumConnectedLeechers;
    SetLength(tran.visualData^.bitfield,length(tran.FPieces));

//   btcore.CloneBitField(tran);
end;

procedure tthread_bitTorrent.processTempDownloads;//sync
var
BitTran:tbittorrentTransfer;
sock:TTCPBlockSocket;
begin
  if vars_global.BitTorrentTempList<>nil then
  while (vars_global.BitTorrentTempList.count>0) do
  begin
//      showmessage(IntToStr(vars_global.BitTorrentTempList.count));
      BitTran:=vars_global.BitTorrentTempList[vars_global.BitTorrentTempList.count-1];
               vars_global.BitTorrentTempList.delete(vars_global.BitTorrentTempList.count-1);
      BitTorrentTransfers.add(BitTran);
  end;

  while (vars_global.bittorrent_Accepted_sockets.count>0) do
  begin
     //Form1.Memo2.Lines.Add('AddAcceptedsockets: '+inttostr(vars_global.bittorrent_Accepted_sockets.count));
     sock:=vars_global.bittorrent_Accepted_sockets[0];
           vars_global.bittorrent_Accepted_sockets.delete(0);
     sock.tag:=tick;
     acceptedsockets.add(sock);
  end;
end;

procedure tthread_bittorrent.BitTorrentCancelTransfer(Transfer:TBitTorrentTransfer);
begin
//Transfer.visualData^.handle_obj:=INVALID_HANDLE_VALUE;
//Transfer.visualData^.state:=dlCancelled;
//Transfer.visualData^.SpeedDl:=0;
//Transfer.visualData^.speedUl:=0;
//
//if transfer.uploadtreeview then begin
// ares_frmmain.treeview_upload.invalidatenode(Transfer.visualNode);
// ares_frmmain.treeview_upload.deleteChildren(Transfer.visualNode,true);
//end else begin
// ares_frmmain.treeview_download.invalidatenode(Transfer.visualNode);
// ares_frmmain.treeview_download.deleteChildren(Transfer.visualNode,true);
//end;


Transfer.FState:=dlCancelled;
Transfer.wipeout;
end;

procedure tthread_bittorrent.BitTorrentPauseTransfer(Transfer:TBitTorrentTransfer);
var
 i:integer;
 source:TBitTorrentSource;
 tracker:tbittorrentTracker;
begin

RemoveOutGoingRequests(transfer);
transfer.numConnected:=0;

if transfer.trackers.count>0 then begin
 tracker:=transfer.trackers[transfer.trackerIndex];
 if tracker.socket<>nil then begin
  tracker.socket.free;
  tracker.socket:=nil;
  tracker.next_poll:=tick+(tracker.interval*1000)+(30000);
 end;
end;

for i:=0 to transfer.fsources.count-1 do begin
 source:=transfer.fsources[i];

 if source.status=btSourceIdle then continue;
  if source.status=btSourceShouldRemove then continue;
   if source.status=btSourceShouldDisconnect then continue;

 disconnectSource(transfer,source,false);
end;

transfer.CalculateLeechsSeeds;

BitTorrentDlDb.BitTorrentDb_updateDbOnDisk(Transfer);
end;

procedure tthread_bittorrent.AddVisualTransfers;//sync
var
i:integer;
tran:TBitTorrentTransfer;
begin
// Form1.Memo2.Lines.Add('BitTorrentCount: '+IntToStr(BitTorrentTransfers.count));

 for i:=0 to BitTorrentTransfers.count-1 do begin
  tran:=BitTorrentTransfers[i];
//  Form1.Memo2.Lines.Add(tran.fname);
//  showmessage(tran.fname);
  AddVisualTransferReference(tran);
 end;
end;

procedure tthread_bitTorrent.execute;
var
 last_udp_out:cardinal;
 i:integer;
 tran:TBitTorrentTransfer;
 x:integer;
 Tracker:tbittorrentTracker;
begin
freeonterminate:=false;
priority:=tpnormal;

sleep(1000);
//{synchronize}(AddVisualTransfers);

init_vars;
last_udp_out:=0;
 
while (not terminated) do begin
 try

 tick:=gettickcount;   
 mdht_nowt:=time_now;

 if tick-last_udp_out>=150 then begin
   last_udp_out:=tick;
   while (MDHT_udp_outpackets.count>0) do dht_socket.mdht_flush_udp_packet; //dht_socket.mdht_flush_udp_packet;
 end;

 if tick-last_sec>1000 then begin

  if not terminated then checkSourcesVisual(BitTorrentTransfers);
   last_sec:=tick;

  
  if not terminated then
  begin
   EnterCriticalSection(ServiceSection);
   try
    {synchronize}(processTempDownloads);
   finally
     LeaveCriticalSection(ServiceSection);
   end;
  end;

  if not terminated then
  begin
    for i:=0 to BitTorrentTransfers.count-1 do begin
    tran:=BittorrentTransfers[i];
    begin
      for x:=0 to tran.trackers.count-1 do
      begin
        Tracker:=tran.trackers[x];
        if Tracker.CreatedThreadTracker=False then
        begin
          TrackersThreadList.Add(TThreadTracker.Create(False, tran, x));
          Tracker.CreatedThreadTracker:=True;
        end;
      end;
    end;
    end;
  end;
  
  //if not terminated then TrackerDeal;
  //if not terminated then checkTracker;

  if not terminated then shuffle_sources;
   sleep(5);
  if not terminated then getHandshaked_FromAcceptedSockets;
  if not terminated then ExpireOutGoingRequests(BitTorrentTransfers,tick);

   ChokesDeal(BitTorrentTransfers,tick);

   if tick-last_min>60000 then begin
    last_min:=tick;
    FMaxUlSpeed:=0; // reset value here as it's a very dynamic value
    if not terminated then checkKeepAlives(BitTorrentTransfers,tick);
    DropCheatingClients(BitTorrentTransfers,tick);
    flushBannedIps(BitTorrentTransfers,tick);

     if mdht_nextBackUpNodes<=mdht_nowt then begin
      mdht_nextBackUpNodes:=mdht_nowt+MIN2S(30);
      MDHT_writeNodeFile(vars_global.data_path+'\Data\MDHTnodes.dat', MDHT_routingZone);
     end;

   end;

 end;

 mdht_check_events;
 mdht_check_second;

 //TransferDeal;

 for i:=0 to BitTorrentTransfers.count-1 do begin
    tran:=BittorrentTransfers[i];
    if tran.CreatedThreadTransfer=False then
    begin
      TransfersThreadList.Add(TThreadTransfer.Create(False, tran));
      tran.CreatedThreadTransfer:=True;
    end;
 end;

 mdht_Receive;

 if terminated then break else sleep(10);
 except
 end;
end;

shutdown;
end;

function HasLimitedOutPut(UpSpeed:cardinal):boolean;
begin
result:=(UpSpeed<40000);
end;

procedure FlushBannedIPs(list:TMylist; tick:cardinal);
var
tran:tbittorrentTransfer;
i:integer;
begin
 for i:=0 to list.count-1 do begin
  tran:=list[i];
  if tran.bannedIPs=nil then continue;
  if tick-tran.lastFlushBannedIPs>3600000 then begin
   tran.lastFlushBannedIPs:=tick;
   tran.bannedIPs.clear;
  end;
 end;
end;

procedure DropCheatingClients(list:TMylist; tick:cardinal);
var
tran:tbittorrentTransfer;
i:integer;
begin
 for i:=0 to list.count-1 do begin
  tran:=list[i];
  DropCheatingClients(tran,tick);
 end;
end;

procedure DropCheatingClients(transfer:TBittorrentTransfer; tick:cardinal);
var
 i:integer;
 source:TBittorrentSource;
 uptime:integer;
begin

for i:=0 to transfer.fsources.count-1 do begin
 source:=transfer.fsources[i];
 if source.status=btSourceShouldRemove then continue;
 if tick-source.handshakeTick<MINUTE then continue;

 if copy(source.id,1,8)=aresTorrentSignature then begin
   if length(source.client)<13{'Ares 1.9.4.3XXX'} then begin
    btcore.AddBannedIp(transfer,source.ipC);
    source.status:=btSourceShouldRemove;
   end;
 end;
 if transfer.numConnected<20 then continue;


{ //compare remote pieces with ours if we find more that nn pieces that there's something fishy going on
 if (not source.isSeeder) and
    (not source.isInterested) and
    (source.bitfield<>nil) then begin
     cheating:=false;
     shouldWant:=0;
     for hiz:=0 to high(transfer.Fpieces) do begin
      piece:=transfer.FPieces[hiz];
      if not piece.checked then continue;
        if source.bitfield.bits[hiz] then continue;
         inc(shouldWant);
         if shouldWant>=20 then begin
          cheating:=true;
          break;
        end;
     end;
     if cheating then begin
      source.status:=btSourceShouldRemove;

     end;
 end;   }

 uptime:=tick-source.handshakeTick;

 if not source.weAreInterested then begin
  if (uptime>5*MINUTE) and (source.sent>0) then source.status:=btSourceShouldRemove;
  continue;
 end;

  if (not source.isSeeder) then begin
   if (uptime>5*MINUTE) and (source.recv<32000) then source.status:=btSourceShouldRemove else
     if source.recv<source.sent then begin
      if source.sent div 3>source.recv then source.status:=btSourceShouldRemove;
     end;
  end else
   if (uptime>10*MINUTE) and (source.recv<32000)  then source.status:=btSourceShouldRemove;

end;
end;

procedure ChokesDeal(list:Tmylist; tick:cardinal);
var
i:integer;
tran:TbittorrentTransfer;
begin
 for i:=0 to list.count-1 do begin
  tran:=list[i];
  if tran.fstate=dlBittorrentMagnetDiscovery then continue;
  if tran.isCompleted then ChokesSeederDeal(tran,tick)
   else ChokesLeecherDeal(tran,tick);
 end;
end;

procedure TThreadTransfer.calcSourceUptime(source:TBitTorrentSource);
begin
source.uptime:=(tickTransfer-source.handshakeTick) div 1000;
end;

procedure tthread_bittorrent.calcSourceUptime(source:TBitTorrentSource);
begin
source.uptime:=(tick-source.handshakeTick) div 1000;
end;

function PerformOptimisticUnchoke(transfer:TBitTorrentTransfer; tick:cardinal; isUpload:Boolean=false):boolean;
var
i:integer;
source:TBitTorrentSource;
candidates:tmylist;
begin
 result:=false;

 candidates:=Tmylist.create;

 for i:=0 to transfer.fsources.count-1 do begin
  source:=transfer.fsources[i];
  if source.status<>btSourceConnected then continue;
   if source.isSeeder then continue;
    if not source.isInterested then continue;
     if not source.isChoked then continue;

      if not isUpload then begin // unchoked three times, received nothing but sent quite a few
        if source.NumOptimisticUnchokes>=3 then
         if source.recv=0 then
          if source.weAreInterested then
           if source.sent>MEGABYTE then continue;
      end;

    if transfer.uploadSlots.IndexOf(source)<>-1 then continue; // it's already a 'best source'

    if transfer.optimisticUnchokedSources.indexof(source)=-1 then candidates.add(source);
 end;



 if transfer.optimisticUnchokedSources.count>0 then
  if candidates.count=0 then begin
    transfer.optimisticUnchokedSources.clear;

      for i:=0 to transfer.fsources.count-1 do begin
       source:=transfer.fsources[i];
       if source.status<>btSourceConnected then continue;
        if source.isSeeder then continue;
         if not source.isInterested then continue;
          if not source.isChoked then continue;

          if not isUpload then begin // unchoked three times, received nothing but sent quite a few
           if source.NumOptimisticUnchokes>=3 then
            if source.weAreInterested then
             if source.recv=0 then
              if source.sent>MEGABYTE then continue;
         end;

         if transfer.uploadSlots.IndexOf(source)<>-1 then continue; // it's already a 'best source'

       candidates.add(source);
     end;
  end;




 if candidates.count=0 then begin
  candidates.free;
  exit;
 end;
 
 randseed:=gettickcount;
 if candidates.count>1 then shuffle_mylist(candidates,0);

 source:=candidates[0];
 source.isChoked:=false;
 Source_AddOutPacket(source,'',CMD_BITTORRENT_UNCHOKE);
  if not isUpload then inc(source.NumOptimisticUnchokes);
 source.SlotType:=ST_OPTIMISTIC;
 source.SlotTimeout:=tick+(30000);
 transfer.uploadSlots.add(source);
 transfer.optimisticUnchokedSources.add(source);

 candidates.free;

 result:=true;
end;

procedure UnChokeBestSourcesForALeecher(HowMany:integer; transfer:TBittorrentTransfer; tick:cardinal);
var
i,numDone:integer;
source:TBitTorrentSource;
candidates,slowCandidates:tmylist;
begin

 NumDone:=0;

 candidates:=Tmylist.create;
 slowCandidates:=Tmylist.create;

 for i:=0 to transfer.fsources.count-1 do begin
  source:=transfer.fsources[i];
  if source.status<>btSourceConnected then continue;
   if source.isSeeder then continue;
    if not source.isInterested then continue;  
     if not source.weAreInterested then continue;
      if source.Snubbed then continue;
       if transfer.uploadSlots.IndexOf(source)<>-1 then continue; // it's already a 'best source'

      if source.speed_recv<256 then begin
          if source.recv>0 then
           if (source.sent div source.recv)<=3 then slowCandidates.add(source); //source too slow, but not leeching badly
      end else candidates.add(source);
      
 end;



 if candidates.count>1 then candidates.Sort(sortBitTorrentBestDownRateFirst);
 if slowCandidates.count>1 then SlowCandidates.Sort(sortBitTorrentBestDownBytesFirst);

   while (candidates.count>0) do begin
     source:=candidates[0];
             candidates.delete(0);

     if source.isChoked then begin
      Source_AddOutPacket(source,'',CMD_BITTORRENT_UNCHOKE);
      source.isChoked:=false;
     end;
     
     source.SlotType:=ST_NORMAL;
     source.SlotTimeout:=tick+(10000);
     transfer.uploadSlots.add(source);

     inc(NumDone);
     if NumDone>=HowMany then begin
      candidates.free;
      slowCandidates.free;
      exit;
     end;
   end;

   candidates.free;


   // not enough, let's add also historically good sources
   while (SlowCandidates.count>0) do begin
     source:=SlowCandidates[0];
             SlowCandidates.delete(0);

     if source.isChoked then begin
      Source_AddOutPacket(source,'',CMD_BITTORRENT_UNCHOKE);
      source.isChoked:=false;
     end;
     
     source.SlotType:=ST_NORMAL;
     source.SlotTimeout:=tick+(10000);
     transfer.uploadSlots.add(source);

     inc(NumDone);
     if NumDone>=HowMany then begin
      slowCandidates.free;
      exit;
     end;
   end;


 slowCandidates.free;

 // still not enough, unchoke all possible candidates
end;

procedure UnChokeBestSourcesForaSeeder(HowMany:integer; transfer:TBittorrentTransfer; tick:cardinal);
var
i,numDone:integer;
source:TBitTorrentSource;
candidates,slowCandidates:tmylist;
begin

 NumDone:=0;

 candidates:=Tmylist.create;
 slowCandidates:=Tmylist.create;

 for i:=0 to transfer.fsources.count-1 do begin
  source:=transfer.fsources[i];
  if source.status<>btSourceConnected then continue;
   if source.isSeeder then continue;   
    if not source.isInterested then continue;
     if transfer.uploadSlots.IndexOf(source)<>-1 then continue; // it's already a 'best source'

      if source.speed_send<256 then slowCandidates.add(source) //source too slow
       else candidates.add(source);
 end;



 if candidates.count>1 then candidates.Sort(sortBitTorrentBestUpRateFirst);
 if slowCandidates.count>1 then SlowCandidates.Sort(sortBitTorrentBestUpBytesFirst);

   while (candidates.count>0) do begin
     source:=candidates[0];
             candidates.delete(0);

     if source.isChoked then begin
      Source_AddOutPacket(source,'',CMD_BITTORRENT_UNCHOKE);
      source.isChoked:=false;
     end;
     
     source.SlotType:=ST_NORMAL;
     source.SlotTimeout:=tick+(10000);
     transfer.uploadSlots.add(source);

     inc(NumDone);
     if NumDone>=HowMany then begin
      candidates.free;
      slowCandidates.free;
      exit;
     end;
   end;

   candidates.free;


   // not enough, let's add also historically good sources
   while (SlowCandidates.count>0) do begin
     source:=SlowCandidates[0];
             SlowCandidates.delete(0);

     if source.isChoked then begin
      Source_AddOutPacket(source,'',CMD_BITTORRENT_UNCHOKE);
      source.isChoked:=false;
     end;
     
     source.SlotType:=ST_NORMAL;
     source.SlotTimeout:=tick+(10000);
     transfer.uploadSlots.add(source);

     inc(NumDone);
     if NumDone>=HowMany then begin
      slowCandidates.free;
      exit;
     end;
   end;


 slowCandidates.free;
end;

procedure ChokesSeederDeal(transfer:TBittorrentTransfer; tick:cardinal);
var
 i,NumAllowedSlots:integer;
 OptimisticCount:integer;
 source:TBitTorrentSource;
begin
try
if transfer.fstate=dlPaused then exit;


 NumAllowedSlots:=4;
 OptimisticCount:=0;
// expire upload slots
i:=0;
while (i<transfer.uploadSlots.count) do begin
 source:=transfer.uploadSlots[i];
 if tick>source.SlotTimeout then transfer.uploadSlots.delete(i)
 else begin
  if source.SlotType=ST_OPTIMISTIC then inc(OptimisticCount);
  inc(i);
 end;
end;


     
// unchoke best sources (downloadwise)
if OptimisticCount>0 then NumAllowedSlots:=5;
if transfer.uploadSlots.count<NumAllowedSlots then UnChokeBestSourcesForaSeeder(NumAllowedSlots-transfer.uploadSlots.count,transfer,tick);

// perform optimistic unchoke
if (OptimisticCount=0) or
   ((transfer.uploadSlots.count<NumAllowedSlots) and (OptimisticCount<3)) then begin

 while (PerformOptimisticUnchoke(transfer,tick,true)) do begin
  inc(OptimisticCount);
  if OptimisticCount>=3 then break; // leave room for at least one regular unchoke (we need to be able to quickly chose fast sources)
  if transfer.uploadSlots.count>=NumAllowedSlots then break;
 end;

end;


// choke every other source (keeps NumAllowedSlots right)
ChokeEveryOneElse(transfer,transfer.uploadSlots);

except
end;
end;

procedure ChokesLeecherDeal(transfer:TBittorrentTransfer; tick:cardinal);
var
i,NumAllowedSlots,OptimisticCount:integer;
source:TBitTorrentSource;
begin
try
if transfer.fstate=dlPaused then exit;

if transfer.FUlSpeed<5000 then NumAllowedSlots:=3
 else
if transfer.FUlSpeed<10000 then NumAllowedSlots:=4
 else
if transfer.FUlSpeed<25000 then NumAllowedSlots:=5
 else
if transfer.FUlSpeed<45000 then NumAllowedSlots:=6
 else
if transfer.FUlSpeed<70000 then NumAllowedSlots:=7
 else
if transfer.FUlSpeed<100000 then NumAllowedSlots:=8
 else NumAllowedSlots:=10;

OptimisticCount:=0;

// expire upload slots
i:=0;
while (i<transfer.uploadSlots.count) do begin
 source:=transfer.uploadSlots[i];
 if tick>source.SlotTimeout then transfer.uploadSlots.delete(i)
 else begin
  if source.SlotType=ST_OPTIMISTIC then inc(OptimisticCount);
  inc(i);
 end;
end;

// unchoke best sources (downloadwise)
 if OptimisticCount>0 then inc(NumAllowedSlots);
if transfer.uploadSlots.count<NumAllowedSlots then UnChokeBestSourcesForaLeecher(NumAllowedSlots-transfer.uploadSlots.count,transfer,tick);

// perform optimistic unchoke
if (OptimisticCount=0) or
   ((transfer.uploadSlots.count<NumAllowedSlots) and (OptimisticCount<3)) then begin

 while (PerformOptimisticUnchoke(transfer,tick,false)) do begin
  inc(OptimisticCount);
  if OptimisticCount>=3 then break; // leave room for at least two regular unchokes (we need to be able to quickly reciprocate fast sources)
  if transfer.uploadSlots.count>=NumAllowedSlots then break;
 end;

end;


// choke every other source (keeps NumAllowedSlots right)
ChokeEveryOneElse(transfer,transfer.uploadSlots);


except
end;
end;

procedure ChokeEveryOneElse(transfer:TBitTorrentTransfer; UntouchableSourcesList:Tmylist);
var
i:integer;
source:TBitTorrentSource;
begin

for i:=0 to transfer.fsources.count-1 do begin
 source:=transfer.fsources[i];
 if source.status<>btSourceConnected then continue;
 if source.isSeeder then continue;
 if source.isChoked then continue;
 if UntouchableSourcesList.indexof(source)<>-1 then continue;

 source.isChoked:=true;
 Source_AddOutPacket(source,'',CMD_BITTORRENT_CHOKE);
end;

end;

procedure tthread_bitTorrent.checkSourcesVisual(list:tmylist);
var
i:integer;
TempUlSpeed:cardinal;
tran:TBittorrentTransfer;
begin
loc_numDownloads:=0;
loc_numUploads:=0;
loc_speedDownloads:=0;
loc_SpeedUploads:=0;
TempUlSpeed:=0;

 i:=0;
 while (i<BitTorrentTransfers.count) do begin
  tran:=BitTorrentTransfers[i];
  if (tran.fstate=dlProcessing) or
     (tran.fstate=dldownloading) then inc(tran.m_elapsed);

  checkSourcesVisual(tran);
  if tran.FUlSpeed>0 then inc(TempUlSpeed,tran.FUlSpeed);
  inc(i);
 end;

 if TempUlSpeed>FMaxUlSpeed then FMaxUlSpeed:=TempUlSpeed;
 FHasLimitedOutput:=HasLimitedOutPut(FMaxUlSpeed);

 EnterCriticalSection(ServiceSection);
 try
 {synchronize}(putStats);
 finally
   LeaveCriticalSection(ServiceSection);
 end;
end;

procedure tthread_bitTorrent.putStats;//sync
begin
 numTorrentDownloads:=loc_numDownloads;
 numTorrentUploads:=loc_NumUploads;
 speedTorrentdownloads:=loc_speedDownloads;
 speedTorrentUploads:=loc_speedUploads;
 BitTorrentDownloadedBytes:=loc_downloadedBytes;
 BitTorrentUploadedBytes:=loc_uploadedBytes;
end;


procedure tthread_bitTorrent.checkSourcesVisual(transfer:TBittorrentTransfer);
var
i:integer;
source:TBitTorrentSource;
begin
transfer.FDlSpeed:=0;
transfer.FUlSpeed:=0;


for i:=0 to transfer.fsources.count-1 do begin
 source:=transfer.fsources[i];
 if source.status<>btSourceConnected then continue;

 source.speed_recv:=((source.speed_recv div 10)*9) + ((source.recv-source.bytes_recv_before) div 10);
 source.bytes_recv_before:=source.recv;
 if source.speed_recv>source.speed_recv_max then source.speed_recv_max:=source.speed_recv;

 //if source.isChoked then source.speed_send:=0
  //else
  source.speed_send:=((source.speed_send div 10)*9) + ((source.sent-source.bytes_sent_before) div 10);
 source.bytes_sent_before:=source.sent;
 if source.speed_send>source.speed_send_max then source.speed_send_max:=source.speed_send;

 if transfer.fstate<>dlSeeding then
  if source.speed_recv>0 then
   inc(transfer.FDlSpeed,source.speed_recv);

 if source.speed_send>0 then inc(transfer.FUlSpeed,source.speed_send);

 source.NumBytesToSendPerSecond:=source.speed_recv+1024;
end;

 if transfer.FDlSpeed>transfer.peakSpeedDown then transfer.peakSpeedDown:=transfer.fDlSpeed;

 if transfer.FDlSpeed=0 then begin
  if transfer.fstate=dlDownloading then transfer.fstate:=dlProcessing;
 end else inc(loc_SpeedDownloads,transfer.FDlSpeed);

  
GlobTransfer:=transfer;

EnterCriticalSection(ServiceSection);
try
{synchronize}(checkSourcesVisual);
finally
  LeaveCriticalSection(ServiceSection);
end;
end;

{
procedure tthread_bitTorrent.update_transfer_visual;  //synch coming from ut_metadata aquisition
var
 afile:TBitTorrentFile;
 source:tbittorrentSource;
 i:integer;
 piece:TBitTorrentChunk;
begin
 GlobTransfer.visualData^.FileName:=widestrtoutf8str(helper_urls.extract_fnameW(utf8strtowidestr(GlobTransfer.fname)));
 GlobTransfer.visualData^.Size:=GlobTransfer.fsize;
 GlobTransfer.visualData^.state:=GlobTransfer.fstate;
 if GlobTransfer.ffiles.count=1 then begin
  afile:=GlobTransfer.ffiles[0];
  GlobTransfer.visualData^.path:=afile.ffilename;
 end else GlobTransfer.visualData^.path:=GlobTransfer.fname;

  SetLength(GlobTransfer.visualData^.bitfield,length(GlobTransfer.FPieces));

  for i:=0 to high(GlobTransfer.FPieces) do begin
   piece:=GlobTransfer.fpieces[i];
   GlobTransfer.visualData.bitfield[i]:=piece.checked;
  end;
  
  GlobTransfer.visualData^.Fpiecesize:=GlobTransfer.fpieceLength;

for i:=0 to GlobTransfer.fsources.count-1 do begin
 source:=GlobTransfer.fsources[i];
 if source.dataDisplay=nil then continue;
 source.datadisplay.size:=GlobTransfer.fsize;
 source.dataDisplay.VisualBitField.free;
 source.datadisplay.VisualBitField:=TBitTorrentBitField.create(length(GlobTransfer.FPieces));
 source.dataDisplay^.size:=globtransfer.fsize;
 source.dataDisplay^.FPieceSize:=globtransfer.fpieceLength;
 source.dataDisplay^.status:=Globsource.status;
 ares_frmmain.treeview_download.InvalidateNode(source.nodeDisplay);
end;

 ares_frmmain.treeview_download.Sort(Globtransfer.visualNode,3,sdDescending);
end;}

procedure tthread_bitTorrent.checkSourcesVisual; //sync
var
 index:integer;
// i:integer;
// source:TBitTorrentSource;
// tracker:tbittorrentTracker;
// istrackerBusy:boolean;
begin
if GlobTransfer.fstate=dlFinishedAllocating then begin
 GlobTransfer.fstate:=dlProcessing;
end;

if GlobTransfer.fstate=dlAllocating then exit;

/////////////////////////////////// CANCEL TRANSFER
if GlobTransfer.finishedSeeding then begin
     index:=BittorrentTransfers.indexof(GlobTransfer);
     if index<>-1 then begin
     BittorrentTransfers.delete(index);
        try
         if GlobTransfer.dbstream<>nil then GlobTransfer.dbstream.size:=0;
         bitTorrentDb_CheckErase(GlobTransfer);
        except
        end;
        //ares_frmmain.treeview_upload.DeleteNode(GlobTransfer.visualNode);
        GlobTransfer.free;
   end;
end else
if GlobTransfer.want_cancelled then begin // cancel transfer, update GUI so clearIdle may be effective
  //GlobTransfer.want_cancelled:=false;

 if GlobTransfer.Uploadtreeview then begin //remove from treeview_upload and stop seeding

   index:=BittorrentTransfers.indexof(GlobTransfer);
   if index<>-1 then begin
     BittorrentTransfers.delete(index);
      {GlobTransfer.visualData^.state:=dlCancelled;
      GlobTransfer.visualData^.handle_obj:=INVALID_HANDLE_VALUE;
      GlobTransfer.visualData^.SpeedDl:=0;
      GlobTransfer.visualData^.speedUl:=0;
      ares_frmmain.treeview_upload.deleteChildren(GlobTransfer.visualNode,true);
      ares_frmmain.treeview_upload.invalidateNode(GlobTransfer.visualNode);}
        try
         if GlobTransfer.dbstream<>nil then GlobTransfer.dbstream.size:=0;
         bitTorrentDb_CheckErase(GlobTransfer);
        except
        end;
     GlobTransfer.free;
     exit;
   end;

 end else begin

  if GlobTransfer.fstate<>dlSeeding then begin
   index:=BittorrentTransfers.indexof(GlobTransfer);
    if index<>-1 then begin
     BittorrentTransfers.delete(index);
     BitTorrentCancelTransfer(GlobTransfer);
     exit;
    end;
  end;

 end;

end;



// SHOW POSSIBLE ERRORS
{if GlobTransfer.ferrorCode<>0 then begin
  if GlobTransfer.visualData^.erCode<>GlobTransfer.ferrorCode then begin
   GlobTransfer.visualData^.erCode:=GlobTransfer.ferrorCode;
    if ares_frmmain.tabs_pageview.activepage=IDTAB_TRANSFER then
     if GlobTransfer.uploadTreeview then begin
      ares_frmmain.treeview_upload.InvalidateNode(GlobTransfer.visualNode);
      Update_Hint(GlobTransfer.visualNode,ares_frmmain.treeview_upload);
     end else begin
      ares_frmmain.treeview_download.InvalidateNode(GlobTransfer.visualNode);
      Update_Hint(GlobTransfer.visualNode,ares_frmmain.treeview_download);
    end;
  end;
exit;
end;}




// STATS
{for i:=0 to GlobTransfer.fsources.count-1 do begin
 source:=GlobTransfer.fsources[i];
 if source.status<>btSourceConnected then continue;
 if source.dataDisplay=nil then continue;
 source.dataDisplay^.recv:=source.recv;
 source.dataDisplay^.sent:=source.sent;
 source.dataDisplay^.speedup:=source.speed_send;
 source.dataDisplay^.speeddown:=source.speed_recv;

 source.datadisplay^.choked:=source.isChoked;
 source.datadisplay^.interested:=source.isinterested;
 source.datadisplay^.weAreChoked:=source.weArechoked;
 Source.datadisplay^.weAreInterested:=Source.weAreInterested;
 Source.datadisplay^.isOptimistic:=((source.slotType=ST_OPTIMISTIC) and (not source.isChoked));
 Source.datadisplay^.port:=source.port;
 Source.dataDisplay^.client:=source.client;
 Source.dataDisplay^.foundby:=source.foundby;

  if source.changedVisualBitField then begin
   source.changedVisualBitField:=false;
   btcore.CloneBitfield(source.bitfield,source.datadisplay^.VisualBitField,source.datadisplay^.progress);
  end;

  if Source.dataDisplay^.should_disconnect then begin
   Source.dataDisplay^.should_disconnect:=false;
   source.status:=btSourceShouldRemove;
   btcore.AddBannedIp(GlobTransfer,source.ipC);
  end;

 if ares_frmmain.tabs_pageview.activepage=IDTAB_TRANSFER then
  if GlobTransfer.uploadTreeview then begin
   ares_frmmain.treeview_upload.InvalidateNode(source.nodeDisplay);
   Update_Hint(source.nodeDisplay,ares_frmmain.treeview_upload);
  end else begin
   ares_frmmain.treeview_download.InvalidateNode(source.nodeDisplay);
   Update_Hint(source.nodeDisplay,ares_frmmain.treeview_download);
  end;

end;

GlobTransfer.visualData^.downloaded:=GlobTransfer.TempDownloaded;
GlobTransfer.visualData^.uploaded:=GlobTransfer.fuploaded;
GlobTransfer.visualData^.speedDl:=GlobTransfer.FDlSpeed;
GlobTransfer.visualData^.speedUl:=GlobTransfer.FUlSpeed;
GlobTransfer.visualData^.num_sources:=GlobTransfer.fsources.count;
GlobTransfer.visualData^.state:=GlobTransfer.fstate;
GlobTransfer.visualData^.elapsed:=GlobTransfer.m_elapsed;

if GlobTransfer.trackers.count>0 then begin
 tracker:=GlobTransfer.trackers[GlobTransfer.trackerIndex];
 istrackerbusy:=false;
 if tracker.isUdp then begin
  if tracker.socketUDP<>INVALID_SOCKET then begin
   GlobTransfer.visualData^.trackerStr:=tracker.visualStr;
   istrackerbusy:=true;
  end;
 end else begin
  if tracker.socket<>nil then begin
   GlobTransfer.visualData^.trackerStr:=tracker.visualStr;
   istrackerbusy:=true;
  end;
 end;

 if not istrackerBusy then begin
    if tracker.next_poll<tick then GlobTransfer.visualData^.trackerStr:=tracker.visualStr+', '+
                                              GetLangStringW(STR_REFRESH)+' '+
                                              format_time(0)
      else GlobTransfer.visualData^.trackerStr:=tracker.visualStr+', '+
                                                GetLangStringW(STR_REFRESH)+' '+
                                                format_time((tracker.next_poll-tick) div 1000);
 end;

 GlobTransfer.visualData^.NumLeechers:=tracker.Leechers;
 GlobTransfer.visualData^.NumSeeders:=tracker.Seeders;
end else GlobTransfer.visualData^.trackerStr:='DHT';


GlobTransfer.visualData^.NumConnectedSeeders:=GlobTransfer.NumConnectedSeeders;
GlobTransfer.visualData^.NumConnectedLeechers:=GlobTransfer.NumConnectedLeechers;

if GlobTransfer.fstate=dlDownloading then inc(loc_numDownloads);

// write upload stats now that this transfer is in treeview_upload
if GlobTransfer.fstate=dlSeeding then
 if GlobTransfer.uploadtreeview then begin
  inc(loc_numUploads);
  inc(loc_speedUploads,GlobTransfer.FUlSpeed);
  inc(loc_UploadedBytes,GlobTransfer.TempUploaded);
  GlobTransfer.TempUploaded:=0;
 end;

if globTransfer.changedVisualBitField then begin
  globTransfer.changedVisualBitField:=false;
  CloneBitfield(GlobTransfer);
end;

if ares_frmmain.tabs_pageview.activepage=IDTAB_TRANSFER then
 if globTransfer.Uploadtreeview then begin
  if ares_frmmain.treeview_upload.visible then begin
   ares_frmmain.treeview_upload.invalidatenode(GlobTransfer.visualNode);
   Update_Hint(GlobTransfer.visualNode,ares_frmmain.treeview_upload);
  end;
 end else begin
  if ares_frmmain.treeview_download.visible then begin
   ares_frmmain.treeview_download.invalidatenode(GlobTransfer.visualNode);
   Update_Hint(GlobTransfer.visualNode,ares_frmmain.treeview_download);
  end;
 end;



if GlobTransfer.fstate=dlSeeding then
 if GlobTransfer.visualData^.want_cleared then
  if not GlobTransfer.UploadTreeview then begin  //ClearIdle on a transfer in seed mode...migrate to treeview_upload
   GlobTransfer.visualData^.want_cleared:=false;

   if GlobTransfer.visualnode=previous_hint_node then formhint_hide;
   ares_frmmain.treeview_download.deleteNode(GlobTransfer.visualNode,true);

    GlobTransfer.UploadTreeview:=true;
   AddVisualTransferReference(GlobTransfer);

    for i:=0 to GlobTransfer.FSources.count-1 do begin
     GlobSource:=GlobTransfer.Fsources[i];
     GlobSource.dataDisplay:=nil;
     GlobSource.nodeDisplay:=nil;
     AddVisualGlobSource;
    end;

   exit;
  end;}






if GlobTransfer.want_paused then begin
  //GlobTransfer.want_paused:=false;
   if GlobTransfer.fstate<>dlSeeding then begin
    if GlobTransfer.fstate=dlPaused then begin
      GlobTransfer.fstate:=dlProcessing;
      BitTorrentDlDb.BitTorrentDb_updateDbOnDisk(GlobTransfer);
    end else begin
     GlobTransfer.fstate:=dlPaused;
     BitTorrentPauseTransfer(GlobTransfer);
     //GlobTransfer.visualData^.speedDl:=0;
    end;
    {GlobTransfer.visualData^.state:=GlobTransfer.fstate;
     if GlobTransfer.uploadtreeview then ares_frmmain.treeview_upload.invalidatenode(GlobTransfer.visualNode)
      else ares_frmmain.treeview_download.invalidatenode(GlobTransfer.visualNode);}
    exit;
   end;
end;

end;




{
procedure tthread_bittorrent.Update_Hint(node:PCmtVNode; treeview:TCometTree);
begin
if vars_global.formhint.top=10000 then exit;
if node<>vars_global.previous_hint_node then exit;
helper_bighints.mainGui_hintTimer(treeview,node);
end;
}{
procedure tthread_bittorrent.CompleteVisualTransfer;//sync
var
 i:integer;
 source:TBitTorrentSource;
 afile:TBitTorrentFile;
begin
GlobTransfer.visualData^.speedDl:=0;
GlobTransfer.fstate:=dlSeeding;
GlobTransfer.visualData^.state:=GlobTransfer.fstate;

for i:=0 to GlobTransfer.fsources.count-1 do begin
 source:=GlobTransfer.fsources[i];
 source.speed_recv:=0;
end;

if GlobTransfer.ffiles.count=1 then begin
 afile:=GlobTransfer.ffiles[0];
 GlobTransfer.visualData^.path:=afile.ffilename;
end;

// TODO
// should we add shareable files to our share list now,
// like we do with regular downloads?
// some torrent downloads come as .rar archive and wait for user action...
ares_frmmain.treeview_download.invalidatenode(GlobTransfer.visualNode);
end;
}
procedure checkKeepAlives(list:Tmylist; tick:cardinal);
var
 i:integer;
 tran:TBitTorrentTransfer;
begin
 for i:=0 to list.count-1 do begin
  tran:=list[i];
  checkkeepAlives(tran,tick);
  if (i mod 5)=0 then sleep(1);
 end;
end;

procedure checkKeepAlives(transfer:TBitTorrentTransfer; tick:cardinal);
var
i:integer;
source:TBitTorrentSource;
begin
for i:=0 to transfer.fsources.count-1 do begin
  source:=transfer.fsources[i];
   if source.status<>btSourceConnected then continue;
   if tick-source.lastKeepAliveOut<BTKEEPALIVETIMEOUT then continue;

    source_AddOutPacket(source,'',CMD_BITTORRENT_KEEPALIVE);

   source.lastKeepAliveOut:=tick;
end;
end;


procedure saveTransfersDb(list:Tmylist);
var
i:integer;
tran:TBitTorrentTransfer;
begin
//update fname
for i:=0 to list.count-1 do begin
 tran:=list[i];
 if tran.isCompleted then continue;

 BitTorrentDb_updateDbOnDisk(tran);
end;

end;

procedure tthread_bitTorrent.shutdown;
var
sockeT:ttcpblocksocket;
tmpTran:tbittorrentTransfer;
s:TMDHTSearch;
packet:precord_mdht_packet;
dht_announcedTorrent:precord_mdht_announced_torrent;
i:Integer;
Tracker:tbittorrentTracker;
//chunk:TBitTorrentChunk;
//request:precord_BitTorrentoutgoing_request;
find: boolean;
begin
saveTransfersDb(bittorrentTransfers);

log('shutdown start');

repeat
find:=False;
for i := TrackersThreadList.Count - 1 downto 0 do
begin
  if CheckThreadIsAlive(TThreadTracker(TrackersThreadList.Items[i])) = true then
  begin
    TThreadTracker(TrackersThreadList.Items[i]).Terminate;
    TThreadTracker(TrackersThreadList.Items[i]).WaitFor;
    TThreadTracker(TrackersThreadList.Items[i]).Free;
    TrackersThreadList.Delete(i);
    find:=true;
    Break;
  end;
end;
until find=False;
TrackersThreadList.Free;

log('Trackers threads released');

repeat
find:=False;
for i := TransfersThreadList.Count - 1 downto 0 do
begin
  if CheckThreadIsAlive(TThreadTransfer(TransfersThreadList.Items[i])) = true then
  begin
    TThreadTransfer(TransfersThreadList.Items[i]).Terminate;
    TThreadTransfer(TransfersThreadList.Items[i]).WaitFor;
    TThreadTransfer(TransfersThreadList.Items[i]).Free;
    TransfersThreadList.Delete(i);
    find:=True;
    Break;
  end;
end;

until find=False;
TransfersThreadList.Free;

log('Transfers threads released');

try
while (acceptedsockets.count>0) do begin
 socket:=acceptedsockets[acceptedsockets.count-1];
 acceptedsockets.delete(acceptedsockets.count-1);
 socket.free;
end;
except
end;
acceptedsockets.free;

log('acceptedsockets list released');    

try
while (bittorrentTransfers.count>0) do begin
   tmpTran:=BittorrentTransfers[BittorrentTransfers.count-1];

   repeat
     find := false;
   for i:=0 to tmpTran.trackers.Count-1 do
   begin
     tracker:=tmpTran.trackers[i];
     tmpTran.trackers.delete(i);
     tracker.free;
     //tracker:=nil;
     find := true;
     break;
   end;
   until find = false;

   tmpTran.trackers.Free;
   //tmpTran.trackers:=nil;

   {for i:=0 to high(tmpTran.fpieces) do
   begin
     chunk:=tmpTran.fpieces[i];
     //tmpTran.fpieces.delete(i);
     chunk.free;
   end;}

   {for i:=0 to tmpTran.outGoingRequests.Count-1 do
   begin
     request:=tmpTran.outGoingRequests[i];
     tmpTran.outGoingRequests.delete(i);
     //request.free;
   end;}


   //for hi:=0 to high(chunk.pieces) do chunk.pieces[hi]:=true;

   //tmpTran.dbstream.Free;
   //tmpTran.dbstream:=nil;

   BittorrentTransfers.delete(BittorrentTransfers.Count-1);
   tmpTran.free;
end;
except
end;

log('trackers list and transfers list released');

while (vars_global.bittorrent_Accepted_sockets.count>0) do begin
 socket:=vars_global.bittorrent_Accepted_sockets[vars_global.bittorrent_Accepted_sockets.count-1];
 vars_global.bittorrent_Accepted_sockets.delete(vars_global.bittorrent_Accepted_sockets.count-1);
 socket.free;
end;
vars_global.bittorrent_Accepted_sockets.free;

log('vars_global.bittorrent_Accepted_sockets list released');

BittorrentTransfers.free;

TCPSocket_Free(MDHT_socket);

 //try
 while (MDHT_Searches.count>0) do begin
  s:=MDHT_Searches[MDHT_Searches.count-1];
     MDHT_Searches.delete(MDHT_Searches.count-1);
  s.free;
 end;
 //except
 //end;
 MDHT_Searches.free;

 log('dht list released');

 mdht_bootstrapclients.free;
 mdht_freeoutpackets;


 while (mdht_announced_torrents.count>0) do begin
  dht_announcedTorrent:=mdht_announced_torrents[mdht_announced_torrents.count-1];
                    mdht_announced_torrents.delete(mdht_announced_torrents.count-1);
  dht_announcedTorrent^.clients.free;
  dht_announcedTorrent^.hash:='';
  FreeMem(dht_announcedTorrent,sizeof(record_mdht_announced_torrent));
 end;
 mdht_announced_torrents.free;


 while (MDHT_udp_outpackets.count>0) do begin
  packet:=MDHT_udp_outpackets[MDHT_udp_outpackets.count-1];
          MDHT_udp_outpackets.delete(MDHT_udp_outpackets.count-1);
  setLength(packet^.buffer,0);
  FreeMem(packet,sizeof(record_mdht_packet));
 end;
 MDHT_udp_outpackets.free;

 MDHT_Events.free;


 MDHT_writeNodeFile(vars_global.data_path+'\Data\MDHTnodes.dat', MDHT_routingZone);
 MDHT_routingZone.free;

 log('shutdown complete!');
end;

procedure tthread_bitTorrent.getHandshaked_FromAcceptedSockets;
var
i,hi:integer;
ipC:cardinal;
found:boolean;
socket:ttcpblocksocket;
source:TBittorrentSource;
transfer:TBitTorrentTransfer;
begin
//Form1.Memo2.Lines.Add('getHandshaked_FromAcceptedSockets');

try

i:=0;
while (i<acceptedsockets.count) do begin
 socket:=acceptedsockets[i];
   //Form1.Memo2.Lines.Add('getHandshaked_FromAcceptedSockets: '+IntToStr(acceptedsockets.count));
   transfer:=GetTransferFromHash(copy(socket.buffstr,29,20));
   if transfer=nil then begin
     acceptedSockets.delete(i);
     socket.free;
     continue;
   end;



   if transfer.fErrorCode<>0 then begin
     acceptedSockets.delete(i);
     socket.free;
     continue;
   end;
   if transfer.fstate=dlAllocating then begin
     acceptedSockets.delete(i);
     socket.free;
     continue;
   end;

   ipC:=inet_addr(pchar(socket.ip));

   if btcore.IsBannedIp(transfer,ipC) then begin
     acceptedSockets.delete(i);
     socket.free;
     continue;
   end;


   // check duplicates
   found:=false;
   for hi:=0 to transfer.fsources.count-1 do begin
    source:=transfer.fsources[hi];
     if ipC<>source.ipC then continue;
     found:=true;
     break;
   end;
   if found then begin
     acceptedSockets.delete(i);
     socket.free;
     continue;
   end;
   
   
   acceptedSockets.delete(i);

   if transfer.fstate=dlPaused then begin
    socket.free;
    continue;
   end;

   
   if transfer.numConnected>=BITTORENT_MAXNUMBER_CONNECTION_ACCEPTED then begin
    socket.free;
    continue;
   end;

    if transfer.fsources.count>=BITTORRENT_MAX_ALLOWED_SOURCES then begin
     socket.free;
     continue;
    end;

  source:=TBittorrentSource.create;
   source.socket:=socket;
   source.IpC:=ipC;
   source.ipS:=socket.ip;
   source.port:=socket.port;
   source.ID:=copy(socket.buffstr,49,20);
   source.Client:=BTIDtoClientName(source.ID);
   source.foundby:='Inc';
   //Form1.Memo2.Lines.Add('addSource1');
  transfer.fsources.add(source);
    source.status:=btSourceweMustSendHandshake;
    source.tick:=tick;
    source.IsIncomingConnection:=true;

   ParseHandshakeReservedBytes(source,copy(socket.buffstr,21,8));

   socket.buffstr:='';

   globSource:=source;
   globTransfer:=transfer;
//   synchronize(AddVisualGlobSource);

end;

except
end;
end;

function tthread_bittorrent.GetTransferFromHash(const HashStr:string):TbittorrentTransfer;
var
 i:integer;
 tran:tbittorrentTransfer;
begin
result:=nil;

 for i:=0 to BitTorrentTransfers.count-1 do begin
   tran:=BitTorrentTransfers[i];
   if tran.fhashvalue<>HashStr then continue;
    result:=tran;
    exit;
 end;
end;
{
procedure tthread_bitTorrent.AddVisualGlobSource;//sync
var
dataNode:ares_types.precord_data_node;
node:PcmtVNode;
data:btcore.precord_displayed_source;
begin
      if GlobTransfer.uploadtreeview then begin
       node:=ares_frmmain.treeview_upload.AddChild(GlobTransfer.visualNode);
       dataNode:=ares_frmmain.treeview_upload.getdata(node);
      end else begin
       node:=ares_frmmain.treeview_download.AddChild(GlobTransfer.visualNode);
       dataNode:=ares_frmmain.treeview_download.getdata(node);
      end;

      dataNode^.m_type:=dnt_bittorrentSource;

       data:=AllocMem(sizeof(record_Displayed_source));
       dataNode^.data:=data;

       Globsource.dataDisplay:=data;
       Globsource.nodeDisplay:=node;

       Globsource.dataDisplay^.port:=GlobSource.port;
       Globsource.dataDisplay^.ipS:=GlobSource.ipS;
       Globsource.dataDisplay^.status:=Globsource.status;
       Globsource.dataDisplay^.client:=Globsource.client;
       Globsource.dataDisplay^.foundby:=GlobSource.foundby;
       Globsource.dataDisplay^.ID:=Globsource.ID;
       Globsource.dataDisplay^.sourceHandle:=integer(Globsource);
       Globsource.dataDisplay^.VisualBitField:=TBitTorrentBitField.create(length(GlobTransfer.FPieces));
       Globsource.dataDisplay^.choked:=true;
       Globsource.dataDisplay^.interested:=false;
       Globsource.dataDisplay^.weAreChoked:=true;
       Globsource.dataDisplay^.weAreInterested:=false;
       Globsource.dataDisplay^.sent:=0;
       Globsource.dataDisplay^.recv:=0;
       GlobSource.dataDisplay^.size:=globtransfer.fsize;
       GlobSource.dataDisplay^.FPieceSize:=globtransfer.fpieceLength;
       GlobSource.dataDisplay^.progress:=0;
       GlobSource.dataDisplay^.should_disconnect:=false;
end;
}

procedure SourceDisconnect(source:TBitTorrentSource);
begin
 source.status:=btSourceShouldDisconnect;
end;

procedure tthread_Bittorrent.shuffle_sources;
var
i:integer;
tran:TBittorrentTransfer;
begin
 for i:=0 to BitTorrentTransfers.count-1 do begin
  tran:=BitTorrentTransfers[i];
  if tran.fstate=dlAllocating then continue;
  if tran.fsources.count>3 then shuffle_mylist(tran.fsources,0);
 end;
end;


procedure tthread_Bittorrent.transferDeal;
var
i:integer;
tran:TBittorrentTransfer;
begin
 for i:=0 to BitTorrentTransfers.count-1 do begin
  tran:=BitTorrentTransfers[i];
  if tran.fstate=dlAllocating then continue;
  transferDeal(tran);
  if terminated then break;
  if (i mod 3)=0 then sleep(1);
 end;
end;

function TThreadTransfer.transferDeal(transfer:TBittorrentTransfer; source:tBitTorrentSource):boolean;
var
 er,len_recv,to_recv,previousLen:integer;
 wanted_payload_len:cardinal;
 buffhead:array[0..3] of byte;
begin
result:=false;
//Form1.Memo2.Lines.Add('transferDeal');
try

//reveive and flush
if source.outbuffer.count>0 then begin
 SourceFlush(transfer,source);
 if source.status<>btSourceConnected then exit;
 if source.outbuffer.count>=25 then exit; //try to flush buffer before catching more requests
end;

if not TCPSocket_CanRead(source.socket.socket,0,er) then begin
 if ((er<>0) and (er<>WSAEWOULDBLOCK)) then begin
   log('Disconnecting source '+source.ipS+' hangup on receive1');
  calcSourceUptime(source);

  SourceDisconnect(source);
 end;
 exit;
end;

// receive 4 byte header
if source.bytes_in_header<4 then begin
 len_recv:=TCPSocket_RecvBuffer(source.socket.socket,@source.header[source.bytes_in_header],4-source.bytes_in_header,er);
 if er=WSAEWOULDBLOCK then exit;
 if er<>0 then begin
   log('Disconnecting source '+source.ipS+' hangup on receive2');
   calcSourceUptime(source);

   SourceDisconnect(source);
   exit;
 end;
 inc(source.bytes_in_header,len_recv);
 if source.bytes_in_header<4 then exit;
end;

  buffhead[3]:=source.header[0];
  buffhead[2]:=source.header[1];
  buffhead[1]:=source.header[2];
  buffhead[0]:=source.header[3];
  move(buffhead,wanted_payload_len,4);
  {
  wanted_payload_len:=ord(source.header[0]);
  wanted_payload_len:=wanted_payload_len shl 8;
  wanted_payload_len:=wanted_payload_len + ord(source.header[1]);
  wanted_payload_len:=wanted_payload_len shl 8;
  wanted_payload_len:=wanted_payload_len + ord(source.header[2]);
  wanted_payload_len:=wanted_payload_len shl 8;
  wanted_payload_len:=wanted_payload_len + ord(source.header[3]);
 }
  if wanted_payload_len=0 then begin
   source.bytes_in_header:=0; //next packet
   source.inBuffer:='';
   source.lastKeepAliveIn:=tickTransfer;
   exit;
  end;


     if wanted_payload_len>BITTORRENT_PIECE_LENGTH+50{9} then begin
      log('Disconnecting source '+source.ipS+' packet receive too big');
      source.status:=btSourceShouldDisconnect;
      exit;
     end;


while (cardinal(length(source.inBuffer))<wanted_payload_len) do begin
  to_recv:=wanted_payload_len-cardinal(length(source.inbuffer));
  if to_recv>4096 then to_recv:=4096;

  len_recv:=TCPSocket_RecvBuffer(source.socket.socket,@bufferRecvBittorrent,to_recv,er);
  if er=WSAEWOULDBLOCK then exit;
  if er<>0 then begin
   log('Disconnecting source '+source.ipS+' hangup on receive3');
   calcSourceUptime(source);

   SourceDisconnect(source);
   exit;
  end;
  if len_recv=0 then begin

   exit;
  end;

  previousLen:=length(source.inBuffer);
  SetLength(source.inBuffer,previousLen+len_recv);
  move(bufferRecvBittorrent,source.inBuffer[previousLen+1],len_recv);

  Source_Increase_ReceiveStats(transfer,source,previousLen,len_recv,tickTransfer);
  if terminated then exit;
end;

// if cardinal(length(source.inBuffer))>wanted_payload_len then begin

// end;

 SourceParsePacket(transfer,source);

 source.bytes_in_header:=0;
 source.inBuffer:='';
 
 if source.status<>btSourceConnected then begin
  result:=false;

  calcSourceUptime(source);
 
 end else result:=true;

except
end;
end;

function tthread_bitTorrent.transferDeal(transfer:TBittorrentTransfer; source:tBitTorrentSource):boolean;
var
 er,len_recv,to_recv,previousLen:integer;
 wanted_payload_len:cardinal;
 buffhead:array[0..3] of byte;
begin
result:=false;
//Form1.Memo2.Lines.Add('transferDeal');
try

//reveive and flush
if source.outbuffer.count>0 then begin
 SourceFlush(transfer,source);
 if source.status<>btSourceConnected then exit;
 if source.outbuffer.count>=25 then exit; //try to flush buffer before catching more requests
end;

if not TCPSocket_CanRead(source.socket.socket,0,er) then begin
 if ((er<>0) and (er<>WSAEWOULDBLOCK)) then begin
   log('Disconnecting source '+source.ipS+' hangup on receive1');
  calcSourceUptime(source);

  SourceDisconnect(source);
 end;
 exit;
end;

// receive 4 byte header
if source.bytes_in_header<4 then begin
 len_recv:=TCPSocket_RecvBuffer(source.socket.socket,@source.header[source.bytes_in_header],4-source.bytes_in_header,er);
 if er=WSAEWOULDBLOCK then exit;
 if er<>0 then begin
   log('Disconnecting source '+source.ipS+' hangup on receive2');
   calcSourceUptime(source);

   SourceDisconnect(source);
   exit;
 end;
 inc(source.bytes_in_header,len_recv);
 if source.bytes_in_header<4 then exit;
end;

  buffhead[3]:=source.header[0];
  buffhead[2]:=source.header[1];
  buffhead[1]:=source.header[2];
  buffhead[0]:=source.header[3];
  move(buffhead,wanted_payload_len,4);
  {
  wanted_payload_len:=ord(source.header[0]);
  wanted_payload_len:=wanted_payload_len shl 8;
  wanted_payload_len:=wanted_payload_len + ord(source.header[1]);
  wanted_payload_len:=wanted_payload_len shl 8;
  wanted_payload_len:=wanted_payload_len + ord(source.header[2]);
  wanted_payload_len:=wanted_payload_len shl 8;
  wanted_payload_len:=wanted_payload_len + ord(source.header[3]);
 }
  if wanted_payload_len=0 then begin
   source.bytes_in_header:=0; //next packet
   source.inBuffer:='';
   source.lastKeepAliveIn:=tick;
   exit;
  end;


     if wanted_payload_len>BITTORRENT_PIECE_LENGTH+50{9} then begin
      log('Disconnecting source '+source.ipS+' packet receive too big');
      source.status:=btSourceShouldDisconnect;
      exit;
     end;


while (cardinal(length(source.inBuffer))<wanted_payload_len) do begin
  to_recv:=wanted_payload_len-cardinal(length(source.inbuffer));
  if to_recv>4096 then to_recv:=4096;

  len_recv:=TCPSocket_RecvBuffer(source.socket.socket,@bufferRecvBittorrent,to_recv,er);
  if er=WSAEWOULDBLOCK then exit;
  if er<>0 then begin
   log('Disconnecting source '+source.ipS+' hangup on receive3');
   calcSourceUptime(source);

   SourceDisconnect(source);
   exit;
  end;
  if len_recv=0 then begin

   exit;
  end;

  previousLen:=length(source.inBuffer);
  SetLength(source.inBuffer,previousLen+len_recv);
  move(bufferRecvBittorrent,source.inBuffer[previousLen+1],len_recv);

  Source_Increase_ReceiveStats(transfer,source,previousLen,len_recv,tick);
  if terminated then exit;
end;

// if cardinal(length(source.inBuffer))>wanted_payload_len then begin

// end;

 SourceParsePacket(transfer,source);

 source.bytes_in_header:=0;
 source.inBuffer:='';
 
 if source.status<>btSourceConnected then begin
  result:=false;

  calcSourceUptime(source);
 
 end else result:=true;

except
end;
end;

procedure Source_Increase_ReceiveStats(transfer:TBittorrentTransfer; Source:TBittorrentSource; previousLen,len_recv:integer; tick:cardinal);
begin
  // increase receive count if it's a piece packet


  if length(source.InBuffer)=0 then exit;
   if source.InBuffer[1]=chr(CMD_BITTORRENT_PIECE) then begin

     if previousLen=0 then begin
       if len_recv>9 then inc(source.recv,Len_recv-9);
     end else inc(source.recv,Len_recv);

       if transfer.fstate<>dlPaused then
        if transfer.Fstate<>dlSeeding then transfer.fstate:=dlDownloading;
        source.Snubbed:=false;
        source.lastDataIn:=tick; //good guy
   end;
end;


procedure parse_ut_pex(transfer:TBittorrentTransfer; cont:string);
var
 ipC:cardinal;
 portW:word;
 added:integer;
begin
if transfer.fsources.count>=BITTORRENT_MAX_ALLOWED_SOURCES then exit;
 added:=0;
 while (length(cont)>=6) do begin
  ipC:=chars_2_dword(copy(cont,1,4));
  portW:=chars_2_wordRev(copy(cont,5,2));
  delete(cont,1,6);
  transfer.addSource(ipC,portW,'','PEX',false);  
  if transfer.fsources.count>=BITTORRENT_MAX_ALLOWED_SOURCES then break;
  inc(added);
  if added>=50 then break;
 end;
end;

procedure TThreadTransfer.SourceParsePacket(transfer:TBittorrentTransfer;source:TBittorrentSource);
var
 cmdId:byte;
 ind:integer;
begin
try
if transfer.fstate=dlPaused then begin
 source.status:=btSourceShouldDisconnect;
 exit;
end;


  cmdId:=ord(source.inBuffer[1]);
  delete(source.inBuffer,1,1);


case cmdId of
 CMD_BITTORRENT_CHOKE:begin
                       source.weAreChoked:=true;
                       if transfer.isCompleted then exit;
                       
                       RemoveOutGoingRequests(transfer,source);//remove all pending 'inUse' requests
                       if not source.isSeeder then
                        if source.SlotType<>ST_OPTIMISTIC then
                         if source.speed_recv>0 then begin
                          source.snubbed:=true;
                            if not source.isChoked then begin
                             source.isChoked:=true;
                             ind:=transfer.UploadSlots.indexof(source);
                             if ind<>-1 then transfer.UploadSlots.delete(ind);
                             source_AddOutPacket(source,'',CMD_BITTORRENT_CHOKE);
                            end;
                          end;
                      end;
 CMD_BITTORRENT_UNCHOKE:begin
                        if not source.weAreChoked then begin

                         exit;
                        end;

                        RemoveOutGoingRequests(transfer,source);//remove all pending 'inUse' requests
                        source.weAreChoked:=false;
                        if transfer.fstate=dlBittorrentMagnetDiscovery then exit;
                        if source.weAreInterested then
                         begin
                           while (source.outRequests<GetoptimumNumOutRequests(source.speed_recv)) do
                                  if not AskChunk(Transfer,source,tickTransfer) then break;
                           end;
                        end;
 CMD_BITTORRENT_INTERESTED:begin
                           source.isInterested:=true;
                          // if not source.ischocked then ChokeWorstDownload(transfer,source); // a good uploader is now interested, let's choke our worst downloader(worst downloading uploader)
                           end;
 CMD_BITTORRENT_NOTINTERESTED:begin
                             source.isInterested:=false;
                             if not source.isSeeder then
                              if not source.isChoked then begin
                               source.isChoked:=true;
                               ind:=transfer.uploadSlots.indexof(source);
                               if ind<>-1 then transfer.uploadSlots.delete(ind);
                               source_AddOutPacket(source,'',CMD_BITTORRENT_CHOKE);
                              end;
                             end;
 CMD_BITTORRENT_HAVE:UpdateBitField(transfer,source);
 CMD_BITTORRENT_BITFIELD:ResetBitField(transfer,source);
 CMD_BITTORRENT_REQUEST:HandleIncomingRequest(transfer,source);
 CMD_BITTORRENT_PIECE:handleIncomingPiece(transfer,source);
 CMD_BITTORRENT_CANCEL:HandleCancelMessage(transfer,source);
 CMD_BITTORRENT_DHTUDPPORT:mdht_handle_udpport(source);//  dht udp port

 CMD_BITTORRENT_SUGGESTPIECE:Handle_FastPeer_SuggestPiece(transfer,source);
 CMD_BITTORRENT_HAVEALL:Handle_FastPeer_HaveAll(transfer,source);
 CMD_BITTORRENT_HAVENONE:Handle_FastPeer_HaveNone(transfer,source);
 CMD_BITTORRENT_REJECTREQUEST:Handle_FastPeer_RejectRequest(transfer,source);
 CMD_BITTORRENT_ALLOWEDFAST:handle_fastpeer_allowedfast(transfer,source);
 CMD_BITTORRENT_EXTENSION:Handle_ExtensionProtocol_Message(transfer,source);

 end;

except
end;
end;

procedure tthread_bitTorrent.SourceParsePacket(transfer:TBittorrentTransfer;source:TBittorrentSource);
var
 cmdId:byte;
 ind:integer;
begin
try
if transfer.fstate=dlPaused then begin
 source.status:=btSourceShouldDisconnect;
 exit;
end;


  cmdId:=ord(source.inBuffer[1]);
  delete(source.inBuffer,1,1);


case cmdId of
 CMD_BITTORRENT_CHOKE:begin
                       source.weAreChoked:=true;
                       if transfer.isCompleted then exit;
                       
                       RemoveOutGoingRequests(transfer,source);//remove all pending 'inUse' requests
                       if not source.isSeeder then
                        if source.SlotType<>ST_OPTIMISTIC then
                         if source.speed_recv>0 then begin
                          source.snubbed:=true;
                            if not source.isChoked then begin
                             source.isChoked:=true;
                             ind:=transfer.UploadSlots.indexof(source);
                             if ind<>-1 then transfer.UploadSlots.delete(ind);
                             source_AddOutPacket(source,'',CMD_BITTORRENT_CHOKE);
                            end;
                          end;
                      end;
 CMD_BITTORRENT_UNCHOKE:begin
                        if not source.weAreChoked then begin

                         exit;
                        end;

                        RemoveOutGoingRequests(transfer,source);//remove all pending 'inUse' requests
                        source.weAreChoked:=false;
                        if transfer.fstate=dlBittorrentMagnetDiscovery then exit;
                        if source.weAreInterested then
                         begin
                           while (source.outRequests<GetoptimumNumOutRequests(source.speed_recv)) do
                                  if not AskChunk(Transfer,source,tick) then break;
                           end;
                        end;
 CMD_BITTORRENT_INTERESTED:begin
                           source.isInterested:=true;
                          // if not source.ischocked then ChokeWorstDownload(transfer,source); // a good uploader is now interested, let's choke our worst downloader(worst downloading uploader)
                           end;
 CMD_BITTORRENT_NOTINTERESTED:begin
                             source.isInterested:=false;
                             if not source.isSeeder then
                              if not source.isChoked then begin
                               source.isChoked:=true;
                               ind:=transfer.uploadSlots.indexof(source);
                               if ind<>-1 then transfer.uploadSlots.delete(ind);
                               source_AddOutPacket(source,'',CMD_BITTORRENT_CHOKE);
                              end;
                             end;
 CMD_BITTORRENT_HAVE:UpdateBitField(transfer,source);
 CMD_BITTORRENT_BITFIELD:ResetBitField(transfer,source);
 CMD_BITTORRENT_REQUEST:HandleIncomingRequest(transfer,source);
 CMD_BITTORRENT_PIECE:handleIncomingPiece(transfer,source);
 CMD_BITTORRENT_CANCEL:HandleCancelMessage(transfer,source);
 CMD_BITTORRENT_DHTUDPPORT:mdht_handle_udpport(source);//  dht udp port

 CMD_BITTORRENT_SUGGESTPIECE:Handle_FastPeer_SuggestPiece(transfer,source);
 CMD_BITTORRENT_HAVEALL:Handle_FastPeer_HaveAll(transfer,source);
 CMD_BITTORRENT_HAVENONE:Handle_FastPeer_HaveNone(transfer,source);
 CMD_BITTORRENT_REJECTREQUEST:Handle_FastPeer_RejectRequest(transfer,source);
 CMD_BITTORRENT_ALLOWEDFAST:handle_fastpeer_allowedfast(transfer,source);
 CMD_BITTORRENT_EXTENSION:Handle_ExtensionProtocol_Message(transfer,source);

 end;

except
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

procedure TThreadTransfer.Handle_ExtensionProtocol_Message(transfer:TBittorrentTransfer; source:TBittorrentSource);
var
 opCode:byte;
 lenTag:byte;
 lencont:integer;
 tag:string;
 cont:string;
 reqpieceid:integer;
 SavedId:string;
 SavedProgressive:Boolean;
begin

if not source.SupportsExtensions then begin
 source.status:=btSourceShouldDisconnect;

 exit;
end;

if length(source.inBuffer)<2 then exit;

 opcode:=ord(source.inBuffer[1]);
 if opcode=OUR_UT_PEX_OPCODE then begin
   delete(source.inBuffer,1,2);

   while (length(source.inBuffer)>10) do begin
    lentag:=strtointdef(copy(source.inBuffer,1,pos(':',source.inBuffer)-1),0);
    if lentag<>5 then break;

    tag:=copy(source.inBuffer,length(inttostr(lentag))+2,lentag);
    if length(tag)<>lentag then begin

     break;
    end;
    if tag<>'added' then begin

     break;
    end;
     delete(source.inBuffer,1,lentag+length(inttostr(lentag))+1);

    lencont:=strtointdef(copy(source.inBuffer,1,pos(':',source.inBuffer)-1),0);
    if lencont<6 then begin

     break;
    end;
    cont:=copy(source.inBuffer,length(inttostr(lencont))+2,lencont);
    if length(cont)<>lencont then begin

     break;
     end;
     delete(source.inBuffer,1,lencont+length(inttostr(lencont))+1);
    parse_ut_pex(transfer,cont);
    break;
   end;

  exit;
 end;
 if opcode=OUR_UT_METADATA_OPCODE then begin
   delete(source.inBuffer,1,2);
   if pos('8:msg_typei1e',source.inBuffer)=0 then begin

    exit;
   end;
   cont:=copy(source.inBuffer,pos('5:piecei',source.inBuffer)+8,length(source.inBuffer));
   delete(cont,pos('e',cont),length(cont));
   reqpieceid:=strtointdef(cont,-1);
   if reqpieceid=-1 then begin

    exit;
   end;
   if reqpieceid*16384>transfer.ut_metadatasize then begin
    exit;
   end;
   delete(source.inBuffer,1,pos('ee',source.inBuffer)+1);

   if transfer.tempmetastream=nil then exit;
   transfer.tempmetastream.Seek(reqpieceid*16384,soFromBeginning);
   transfer.tempmetastream.Write(source.inBuffer[1],length(source.inBuffer));
   if transfer.tempmetastream.size>=transfer.ut_metadatasize then begin

    //ShowMessage('1: '+transfer.fid);
    SavedId:=transfer.fid;
    SavedProgressive:=transfer.fprogressive;
    transfer.initFrom_ut_Meta;
    transfer.fid:=SavedId;
    transfer.fprogressive:=SavedProgressive;
    GlobTransfer:=transfer;

//     synchronize(update_transfer_visual);
   end else begin
      reqpieceid:=(transfer.tempmetastream.size div 16384);

      source_AddOutPacket(source,
                          chr(source.ut_metadata_opcode)+'d8:msg_typei0e5:piecei'+inttostr(reqpieceid)+'ee',
                          CMD_BITTORRENT_EXTENSION);
   end;

   exit;
 end;

 if opcode=OPCODE_EXTENDED_HANDSHAKE then begin

   if source.port=0 then begin
    if pos('1:pi',source.inBuffer)<>0 then begin
     cont:=copy(source.inBuffer,pos('1:pi',source.inBuffer)+4,6);
     delete(cont,pos('e',cont),length(cont));
      source.port:=strtointdef(cont,0);
    end;
   end;

   cont:=copy(source.inBuffer,pos('6:ut_pexi',source.inBuffer)+9,1);
   source.ut_pex_opcode:=strtointdef(cont,0);

   cont:=copy(source.inBuffer,pos('11:ut_metadatai',source.inBuffer)+15,1);
   source.ut_metadata_opcode:=strtointdef(cont,0);
   cont:=copy(source.inBuffer,pos('13:metadata_sizei',source.inBuffer)+17,length(source.inBuffer));
   delete(cont,pos('e',cont),length(cont));
   if transfer.ut_metadatasize=0 then transfer.ut_metadatasize:=strtointdef(cont,0);
   if (transfer.fstate=dlBittorrentMagnetDiscovery) and
      (transfer.ut_metadatasize>0) then begin

    transfer.metafilenameS:=widestrtoutf8str(vars_global.data_Path+'\Data\TempDl\META_'+bytestr_to_hexstr(transfer.fHashValue)+'.dat');

     tnt_createdirectoryW(pwidechar(vars_global.data_Path+'\Data'),nil);
     tnt_createdirectoryW(pwidechar(vars_global.data_Path+'\Data\TempDl'),nil);
      if transfer.tempmetastream=nil then transfer.tempmetastream:=MyFileOpen(utf8strtowidestr(transfer.metafilenameS),ARES_OVERWRITE_EXISTING);
      if transfer.tempmetastream=nil then exit;
      reqpieceid:=(transfer.tempmetastream.size div 16384);

      source_AddOutPacket(source,
                          chr(source.ut_metadata_opcode)+'d8:msg_typei0e5:piecei'+inttostr(reqpieceid)+'ee',
                          CMD_BITTORRENT_EXTENSION);

   end;

 end;


end;

procedure tthread_bittorrent.Handle_ExtensionProtocol_Message(transfer:TBittorrentTransfer; source:TBittorrentSource);
var
 opCode:byte;
 lenTag:byte;
 lencont:integer;
 tag:string;
 cont:string;
 reqpieceid:integer;
 SavedId:string;
 SavedProgressive:Boolean;
begin

if not source.SupportsExtensions then begin
 source.status:=btSourceShouldDisconnect;

 exit;
end;

if length(source.inBuffer)<2 then exit;

 opcode:=ord(source.inBuffer[1]);
 if opcode=OUR_UT_PEX_OPCODE then begin
   delete(source.inBuffer,1,2);

   while (length(source.inBuffer)>10) do begin
    lentag:=strtointdef(copy(source.inBuffer,1,pos(':',source.inBuffer)-1),0);
    if lentag<>5 then break;

    tag:=copy(source.inBuffer,length(inttostr(lentag))+2,lentag);
    if length(tag)<>lentag then begin

     break;
    end;
    if tag<>'added' then begin

     break;
    end;
     delete(source.inBuffer,1,lentag+length(inttostr(lentag))+1);

    lencont:=strtointdef(copy(source.inBuffer,1,pos(':',source.inBuffer)-1),0);
    if lencont<6 then begin

     break;
    end;
    cont:=copy(source.inBuffer,length(inttostr(lencont))+2,lencont);
    if length(cont)<>lencont then begin

     break;
     end;
     delete(source.inBuffer,1,lencont+length(inttostr(lencont))+1);
    parse_ut_pex(transfer,cont);
    break;
   end;

  exit;
 end;
 if opcode=OUR_UT_METADATA_OPCODE then begin
   delete(source.inBuffer,1,2);
   if pos('8:msg_typei1e',source.inBuffer)=0 then begin

    exit;
   end;
   cont:=copy(source.inBuffer,pos('5:piecei',source.inBuffer)+8,length(source.inBuffer));
   delete(cont,pos('e',cont),length(cont));
   reqpieceid:=strtointdef(cont,-1);
   if reqpieceid=-1 then begin

    exit;
   end;
   if reqpieceid*16384>transfer.ut_metadatasize then begin
    exit;
   end;
   delete(source.inBuffer,1,pos('ee',source.inBuffer)+1);

   if transfer.tempmetastream=nil then exit;
   transfer.tempmetastream.Seek(reqpieceid*16384,soFromBeginning);
   transfer.tempmetastream.Write(source.inBuffer[1],length(source.inBuffer));
   if transfer.tempmetastream.size>=transfer.ut_metadatasize then begin

    //ShowMessage('1: '+transfer.fid);
    SavedId:=transfer.fid;
    SavedProgressive:=transfer.fprogressive;
    transfer.initFrom_ut_Meta;
    transfer.fid:=SavedId;
    transfer.fprogressive:=SavedProgressive;
    GlobTransfer:=transfer;

//     synchronize(update_transfer_visual);
   end else begin
      reqpieceid:=(transfer.tempmetastream.size div 16384);

      source_AddOutPacket(source,
                          chr(source.ut_metadata_opcode)+'d8:msg_typei0e5:piecei'+inttostr(reqpieceid)+'ee',
                          CMD_BITTORRENT_EXTENSION);
   end;

   exit;
 end;

 if opcode=OPCODE_EXTENDED_HANDSHAKE then begin

   if source.port=0 then begin
    if pos('1:pi',source.inBuffer)<>0 then begin
     cont:=copy(source.inBuffer,pos('1:pi',source.inBuffer)+4,6);
     delete(cont,pos('e',cont),length(cont));
      source.port:=strtointdef(cont,0);
    end;
   end;

   cont:=copy(source.inBuffer,pos('6:ut_pexi',source.inBuffer)+9,1);
   source.ut_pex_opcode:=strtointdef(cont,0);

   cont:=copy(source.inBuffer,pos('11:ut_metadatai',source.inBuffer)+15,1);
   source.ut_metadata_opcode:=strtointdef(cont,0);
   cont:=copy(source.inBuffer,pos('13:metadata_sizei',source.inBuffer)+17,length(source.inBuffer));
   delete(cont,pos('e',cont),length(cont));
   if transfer.ut_metadatasize=0 then transfer.ut_metadatasize:=strtointdef(cont,0);
   if (transfer.fstate=dlBittorrentMagnetDiscovery) and
      (transfer.ut_metadatasize>0) then begin

    transfer.metafilenameS:=widestrtoutf8str(vars_global.data_Path+'\Data\TempDl\META_'+bytestr_to_hexstr(transfer.fHashValue)+'.dat');

     tnt_createdirectoryW(pwidechar(vars_global.data_Path+'\Data'),nil);
     tnt_createdirectoryW(pwidechar(vars_global.data_Path+'\Data\TempDl'),nil);
      if transfer.tempmetastream=nil then transfer.tempmetastream:=MyFileOpen(utf8strtowidestr(transfer.metafilenameS),ARES_OVERWRITE_EXISTING);
      if transfer.tempmetastream=nil then exit;
      reqpieceid:=(transfer.tempmetastream.size div 16384);

      source_AddOutPacket(source,
                          chr(source.ut_metadata_opcode)+'d8:msg_typei0e5:piecei'+inttostr(reqpieceid)+'ee',
                          CMD_BITTORRENT_EXTENSION);

   end;

 end;


end;

procedure TThreadTransfer.Handle_FastPeer_SuggestPiece(transfer:TBittorrentTransfer; source:TBittorrentSource);
begin
exit;
 // Suggest Piece: <len=0x0005><op=0x0D><index>
if not source.SupportsFastPeer then begin
 source.status:=btSourceShouldDisconnect;

 exit;
end;
end;

procedure tthread_bitTorrent.Handle_FastPeer_SuggestPiece(transfer:TBittorrentTransfer; source:TBittorrentSource);
begin
exit;
 // Suggest Piece: <len=0x0005><op=0x0D><index>
if not source.SupportsFastPeer then begin
 source.status:=btSourceShouldDisconnect;

 exit;
end;
end;

procedure TThreadTransfer.handle_fastpeer_allowedfast(transfer:TBittorrentTransfer; source:TBittorrentSource);
begin
exit;
 // Suggest Piece: <len=0x0005><op=0x0D><index>
if not source.SupportsFastPeer then begin
 source.status:=btSourceShouldDisconnect;
 exit;
end;
end;

procedure tthread_bitTorrent.handle_fastpeer_allowedfast(transfer:TBittorrentTransfer; source:TBittorrentSource);
begin
exit;
 // Suggest Piece: <len=0x0005><op=0x0D><index>
if not source.SupportsFastPeer then begin
 source.status:=btSourceShouldDisconnect;
 exit;
end;
end;

procedure TThreadTransfer.Handle_FastPeer_HaveAll(transfer:TBittorrentTransfer; source:TBittorrentSource);
var
i:integer;
piece:TBitTorrentChunk;
begin
exit;
// Have All: <len=0x0001><op=0x0E>
if not source.SupportsFastPeer then begin
 source.status:=btSourceShouldDisconnect;
 exit;
end;


if source.bitfield=nil then source.bitfield:=tbittorrentBitfield.create(length(transfer.fpieces));
for i:=0 to high(source.bitfield.bits) do source.bitfield.bits[i]:=true;


for i:=0 to high(transfer.Fpieces) do begin
 piece:=transfer.FPieces[i];
 if piece.checked then continue;

      if not source.weAreInterested then begin // we are interested, let remote peer know
        source_AddOutPacket(source,'',CMD_BITTORRENT_INTERESTED);
        source.weAreInterested:=true;
      end;
        break;
end;

 source.progress:=100;
 CalcChunksPopularity(transfer);
 source.changedVisualBitField:=true;

 transfer.CalculateLeechsSeeds;

if transfer.isCompleted then
 if source.isSeeder then source.status:=btSourceShouldRemove;
end;

procedure tthread_bitTorrent.Handle_FastPeer_HaveAll(transfer:TBittorrentTransfer; source:TBittorrentSource);
var
i:integer;
piece:TBitTorrentChunk;
begin
exit;
// Have All: <len=0x0001><op=0x0E>
if not source.SupportsFastPeer then begin
 source.status:=btSourceShouldDisconnect;
 exit;
end;


if source.bitfield=nil then source.bitfield:=tbittorrentBitfield.create(length(transfer.fpieces));
for i:=0 to high(source.bitfield.bits) do source.bitfield.bits[i]:=true;


for i:=0 to high(transfer.Fpieces) do begin
 piece:=transfer.FPieces[i];
 if piece.checked then continue;

      if not source.weAreInterested then begin // we are interested, let remote peer know
        source_AddOutPacket(source,'',CMD_BITTORRENT_INTERESTED);
        source.weAreInterested:=true;
      end;
        break;
end;

 source.progress:=100;
 CalcChunksPopularity(transfer);
 source.changedVisualBitField:=true;

 transfer.CalculateLeechsSeeds;

if transfer.isCompleted then
 if source.isSeeder then source.status:=btSourceShouldRemove;
end;

procedure TThreadTransfer.Handle_FastPeer_HaveNone(transfer:TBittorrentTransfer; source:TBittorrentSource);
var
i:integer;
//piece:TBitTorrentChunk;
begin
exit;
 // Have None: <len=0x0001><op=0x0F>
if not source.SupportsFastPeer then begin
 source.status:=btSourceShouldDisconnect;
 exit;
end;

if source.bitfield=nil then source.bitfield:=tbittorrentBitfield.create(length(transfer.fpieces));
for i:=0 to high(source.bitfield.bits) do source.bitfield.bits[i]:=false;

 if source.weAreInterested then begin // we are interested, let remote peer know
  source_AddOutPacket(source,'',CMD_BITTORRENT_NOTINTERESTED);
  source.weAreInterested:=false;
 end;

 source.progress:=0;
 CalcChunksPopularity(transfer);
 source.changedVisualBitField:=true;
 transfer.CalculateLeechsSeeds;
end;

procedure tthread_bitTorrent.Handle_FastPeer_HaveNone(transfer:TBittorrentTransfer; source:TBittorrentSource);
var
i:integer;
//piece:TBitTorrentChunk;
begin
exit;
 // Have None: <len=0x0001><op=0x0F>
if not source.SupportsFastPeer then begin
 source.status:=btSourceShouldDisconnect;
 exit;
end;

if source.bitfield=nil then source.bitfield:=tbittorrentBitfield.create(length(transfer.fpieces));
for i:=0 to high(source.bitfield.bits) do source.bitfield.bits[i]:=false;

 if source.weAreInterested then begin // we are interested, let remote peer know
  source_AddOutPacket(source,'',CMD_BITTORRENT_NOTINTERESTED);
  source.weAreInterested:=false;
 end;

 source.progress:=0;
 CalcChunksPopularity(transfer);
 source.changedVisualBitField:=true;
 transfer.CalculateLeechsSeeds;
end;

procedure TThreadTransfer.Handle_FastPeer_RejectRequest(transfer:TBittorrentTransfer; source:TBittorrentSource);
var
 pieceindex,wantedlen,offset:cardinal;
begin
exit;
 // Reject Request: <len=0x000D><op=0x10><index><begin><offset>

if not source.SupportsFastPeer then begin
 source.status:=btSourceShouldDisconnect;
 exit;
end;


 pieceindex:=chars_2_dwordRev(copy(source.inBuffer,1,4));
 offset:=chars_2_dwordRev(copy(source.inBuffer,5,4));
 wantedlen:=chars_2_dwordRev(copy(source.inBuffer,9,4));

 

 RemoveoutGointRequest(transfer,
                       source,
                       pieceindex,
                       offset,
                       wantedlen);


end;

procedure tthread_bitTorrent.Handle_FastPeer_RejectRequest(transfer:TBittorrentTransfer; source:TBittorrentSource);
var
 pieceindex,wantedlen,offset:cardinal;
begin
exit;
 // Reject Request: <len=0x000D><op=0x10><index><begin><offset>

if not source.SupportsFastPeer then begin
 source.status:=btSourceShouldDisconnect;
 exit;
end;


 pieceindex:=chars_2_dwordRev(copy(source.inBuffer,1,4));
 offset:=chars_2_dwordRev(copy(source.inBuffer,5,4));
 wantedlen:=chars_2_dwordRev(copy(source.inBuffer,9,4));

 

 RemoveoutGointRequest(transfer,
                       source,
                       pieceindex,
                       offset,
                       wantedlen);


end;

procedure TThreadTransfer.RemoveoutGointRequest(transfer:tbittorrentTransfer; source:tbittorrentSource; pieceindex:cardinal; offset:cardinal; wantedlen:cardinal);
var
i:integer;
request:precord_BitTorrentoutgoing_request;
begin

for i:=0 to transfer.outgoingRequests.Count-1 do begin
 request:=transfer.outgoingRequests[i];
 if longint(request^.source)<>longint(source) then continue;

 if cardinal(request^.index)<>pieceindex then continue;

 if request^.offset<>offset then continue;
 //if request^.wantedlen<>wantedlen then continue;


    transfer.outgoingRequests.delete(i);
    freeMem(request,sizeof(record_BitTorrentoutgoing_request));
    break;
end;

end;

procedure tthread_bitTorrent.RemoveoutGointRequest(transfer:tbittorrentTransfer; source:tbittorrentSource; pieceindex:cardinal; offset:cardinal; wantedlen:cardinal);
var
i:integer;
request:precord_BitTorrentoutgoing_request;
begin

for i:=0 to transfer.outgoingRequests.Count-1 do begin
 request:=transfer.outgoingRequests[i];
 if longint(request^.source)<>longint(source) then continue;

 if cardinal(request^.index)<>pieceindex then continue;

 if request^.offset<>offset then continue;
 //if request^.wantedlen<>wantedlen then continue;


    transfer.outgoingRequests.delete(i);
    freeMem(request,sizeof(record_BitTorrentoutgoing_request));
    break;
end;

end;

procedure TThreadTransfer.HandleIncomingRequest(transfer:TBittorrentTransfer; source:TBittorrentSource);
var
index,offset,wlen:cardinal;
piece:TBitTorrentChunk;
er:integer;
rem:int64;
buffer:array[0..16383] of char;
str:string;
begin
try

if transfer.fstate=dlPaused then exit;
if length(source.inBuffer)<12 then exit;

index:=chars_2_dwordRev(copy(source.inBuffer,1,4));
offset:=chars_2_dwordRev(copy(source.inBuffer,5,4));
wlen:=chars_2_dwordRev(copy(source.inBuffer,9,4));


if wlen>BITTORRENT_PIECE_LENGTH then begin
 source.status:=btSourceShouldDisconnect;

 exit;
end;

if index>cardinal(high(transfer.fpieces)) then begin
 source.status:=btSourceShouldDisconnect;

 exit;
end;

piece:=transfer.fpieces[index];
if not piece.checked then begin
 exit;
end;

if source.isChoked then begin
 exit;
end;

 CancelOutGoingPiece(transfer,source,index,offset); //cancel previous outgoing requests
 

 transfer.read((int64(index)*int64(transfer.fpiecelength))+int64(offset),
               @buffer,
               wlen,
               rem,
               er);
               
 if rem<>0 then begin
   source.status:=btSourceShouldDisconnect;

  exit;
 end;

 SetLength(str,wlen-rem);
 move(buffer,str[1],length(str));

 source_AddOutPacket(source,int_2_dword_stringRev(index)+
                            int_2_dword_stringRev(offset)+
                            str,
                            CMD_BITTORRENT_PIECE,
                            false,
                            index,
                            offset,
                            wlen);



except
end;
end;

procedure tthread_bitTorrent.HandleIncomingRequest(transfer:TBittorrentTransfer; source:TBittorrentSource);
var
index,offset,wlen:cardinal;
piece:TBitTorrentChunk;
er:integer;
rem:int64;
buffer:array[0..16383] of char;
str:string;
begin
try

if transfer.fstate=dlPaused then exit;
if length(source.inBuffer)<12 then exit;

index:=chars_2_dwordRev(copy(source.inBuffer,1,4));
offset:=chars_2_dwordRev(copy(source.inBuffer,5,4));
wlen:=chars_2_dwordRev(copy(source.inBuffer,9,4));


if wlen>BITTORRENT_PIECE_LENGTH then begin
 source.status:=btSourceShouldDisconnect;

 exit;
end;

if index>cardinal(high(transfer.fpieces)) then begin
 source.status:=btSourceShouldDisconnect;

 exit;
end;

piece:=transfer.fpieces[index];
if not piece.checked then begin
 exit;
end;

if source.isChoked then begin
 exit;
end;

 CancelOutGoingPiece(transfer,source,index,offset); //cancel previous outgoing requests
 

 transfer.read((int64(index)*int64(transfer.fpiecelength))+int64(offset),
               @buffer,
               wlen,
               rem,
               er);
               
 if rem<>0 then begin
   source.status:=btSourceShouldDisconnect;

  exit;
 end;

 SetLength(str,wlen-rem);
 move(buffer,str[1],length(str));

 source_AddOutPacket(source,int_2_dword_stringRev(index)+
                            int_2_dword_stringRev(offset)+
                            str,
                            CMD_BITTORRENT_PIECE,
                            false,
                            index,
                            offset,
                            wlen);



except
end;
end;

procedure RemoveOutGoingRequestForPiece(transfer:TBittorrentTransfer; index:integer);
var
i:integer;
request:precord_BitTorrentoutgoing_request;
begin
i:=0;
while (i<transfer.outgoingRequests.Count) do begin
 request:=transfer.outgoingRequests[i];

 if request^.index<>index then begin
  inc(i);
  continue;
 end;

   Source_AddOutPacket(transfer,
                      request^.source,
                      int_2_dword_stringRev(request^.index)+int_2_dword_stringRev(request^.offset)+int_2_dword_stringRev(request^.wantedLen),
                      CMD_BITTORRENT_CANCEL,
                      true,
                      request^.index,
                      request^.offset,
                      request^.wantedLen);

    transfer.outgoingRequests.delete(i);
    freeMem(request,sizeof(record_BitTorrentoutgoing_request));
end;

end;



procedure CancelOutGoingRequestsForPiece(transfer:TBitTorrentTransfer; Source:TBittorrentSource; index:cardinal; offset:Cardinal);
var
i:integer;
request:precord_BitTorrentoutgoing_request;
tmpSource:TBitTorrentSource;
begin
i:=0;
while (i<transfer.outgoingRequests.Count) do begin
 request:=transfer.outgoingRequests[i];

 if cardinal(request^.index)<>index then begin
  inc(i);
  continue;
 end;

 if request^.offset<>offset then begin
   inc(i);
   continue;
 end;

  // if we sent this to another source send a cancel packet for this piece
  if longint(request^.source)<>longint(source) then begin
   tmpSource:=FindSourceFromID(transfer,request^.source);
    if tmpSource<>nil then begin
      if Source_PeekRequest_InIncomingBuffer(tmpsource,request) then begin

      end else begin
       Source_AddOutPacket(tmpSource,
                           int_2_dword_stringRev(request^.index)+int_2_dword_stringRev(request^.offset)+int_2_dword_stringRev(request^.wantedLen),
                           CMD_BITTORRENT_CANCEL,
                           true,
                           request^.index,
                           request^.offset,
                           request^.wantedLen);
      end;
    end;
  end;
  
    transfer.outgoingRequests.delete(i);
    freeMem(request,sizeof(record_BitTorrentoutgoing_request));
 end;

end;

procedure TThreadTransfer.handleIncomingPiece(transfer:TBittorrentTransfer; source:TBittorrentSource);
var
index,
offset:cardinal;
LenData:integer;

piece:TBitTorrentChunk;
rem:int64;
er:integer;
tracker:tbittorrentTracker;
begin
try
if transfer.fstate=dlPaused then exit;
if transfer.fstate=dlSeeding then exit;

if length(source.inBuffer)<9 then begin

 exit;
end;
//log('handleIncomingPiece: 1');
if source.weAreChoked then begin //should we care?

 exit;
end;

//log('handleIncomingPiece: 2');

index:=chars_2_dwordRev(copy(source.inBuffer,1,4));
offset:=chars_2_dwordRev(copy(source.inBuffer,5,4));
if index>cardinal(high(transfer.fpieces)) then begin

 exit;
end;
 //log('handleIncomingPiece: 3');
 CancelOutGoingRequestsForPiece(transfer,source,index,offset);


 LenData:=length(source.inBuffer)-8;

 piece:=transfer.fpieces[index];

 if (offset div BITTORRENT_PIECE_LENGTH)>cardinal(high(piece.pieces)) then begin

  exit;
 end;
 //log('handleIncomingPiece: 4');
 if piece.pieces[offset div BITTORRENT_PIECE_LENGTH] then begin

  exit;
 end;
 //log('handleIncomingPiece: 5');
 if lenData<>BITTORRENT_PIECE_LENGTH then begin
   if piece.findex<>cardinal(high(transfer.fpieces)) then begin
    log('Disconnecting source '+source.ipS+' sent us wrong piecelen');
    source.status:=btSourceShouldRemove;
    exit;
   end;
 end;
 //log('handleIncomingPiece: 6');
  transfer.write((int64(piece.findex)*int64(transfer.fpieceLength))+int64(offset),
                 @source.inbuffer[9],
                 lenData,
                 rem,
                 er);
 //log('handleIncomingPiece: 7');
  if rem<>0 then begin

   exit;
  end;
 //log('handleIncomingPiece: 8');
 piece.pieces[offset div BITTORRENT_PIECE_LENGTH]:=true;
 inc(piece.fprogress,lenData);
 if source.outRequests>=1 then dec(source.outRequests);
 //log('handleIncomingPiece: 9');
 if transfer.tempDownloaded+LenData<=transfer.fsize then inc(transfer.tempDownloaded,lenData);
 inc(loc_downloadedBytes,lenData);
 //log('handleIncomingPiece: 10');

 if piece.fprogress=piece.fsize then begin // time to check SHA1
   if transfer.hashFails>=NUMMAX_TRANSFER_HASHFAILS then begin
    if piece=source.assignedChunk then begin
     source.assignedChunk:=nil;
     piece.assignedSource:=nil;
    end;
   end;
   //log('handleIncomingPiece: 11');
   piece.check;
   //log('handleIncomingPiece: 12');
   if piece.checked then begin
    RemoveOutGoingRequestForPiece(transfer,piece.findex);

    if transfer.hashFails>=NUMMAX_TRANSFER_HASHFAILS then inc(source.blocksReceived);
    //log('handleIncomingPiece: 13');
    transfer.changedVisualBitField:=true;
    BroadcastHave(transfer,piece);
    //log('handleIncomingPiece: 14');
    if transfer.isCompleted then begin
    //log('handleIncomingPiece: 15');
     DisconnectSeeders(transfer);
     SetAllNotinterested(transfer);
     transfer.DoComplete;
    //log('handleIncomingPiece: 16');

     if transfer.trackers.count>0 then begin
      tracker:=transfer.trackers[transfer.trackerIndex];
      tracker.next_poll:=0; //send notification to tracker
     end;
     transfer.fstate:=dlSeeding;
      GlobTransfer:=transfer;
//      synchronize(CompleteVisualTransfer);
    end;
    if source.weAreInterested then areWeStillInterested(transfer,source);
   end else begin
    dec(transfer.tempDownloaded,piece.fsize);
    inc(transfer.hashFails);
    if transfer.hashFails>NUMMAX_TRANSFER_HASHFAILS then begin
     inc(source.hashFails);
       if source.hashFails>=NUMMAX_SOURCE_HASHFAILS then begin
         log('Disconnecting source '+source.ipS+' too many hashfails');
        source.status:=btSourceShouldRemove;
        btcore.AddBannedIp(transfer,source.ipC);
        exit;
       end;
    end;
   end;
 end;
  //log('handleIncomingPiece: 17');
  if transfer.fstate=dlBittorrentMagnetDiscovery then exit;

  if source.weAreInterested then begin
   while (source.outRequests<GetoptimumNumOutRequests(source.speed_recv)) do begin
    if not AskChunk(Transfer,source,tickTransfer) then break; //ask another piece
   end;
  end;
  //log('handleIncomingPiece: 18');

 except
 end;
end;

procedure tthread_bitTorrent.handleIncomingPiece(transfer:TBittorrentTransfer; source:TBittorrentSource);
var
index,
offset:cardinal;
LenData:integer;

piece:TBitTorrentChunk;
rem:int64;
er:integer;
tracker:tbittorrentTracker;
begin
try
if transfer.fstate=dlPaused then exit;
if transfer.fstate=dlSeeding then exit;

if length(source.inBuffer)<9 then begin

 exit;
end;
//log('handleIncomingPiece: 1');
if source.weAreChoked then begin //should we care?

 exit;
end;

//log('handleIncomingPiece: 2');

index:=chars_2_dwordRev(copy(source.inBuffer,1,4));
offset:=chars_2_dwordRev(copy(source.inBuffer,5,4));
if index>cardinal(high(transfer.fpieces)) then begin

 exit;
end;
 log('handleIncomingPiece: 3');
 CancelOutGoingRequestsForPiece(transfer,source,index,offset);


 LenData:=length(source.inBuffer)-8;

 piece:=transfer.fpieces[index];

 if (offset div BITTORRENT_PIECE_LENGTH)>cardinal(high(piece.pieces)) then begin

  exit;
 end;
 log('handleIncomingPiece: 4');
 if piece.pieces[offset div BITTORRENT_PIECE_LENGTH] then begin

  exit;
 end;
 log('handleIncomingPiece: 5');
 if lenData<>BITTORRENT_PIECE_LENGTH then begin
   if piece.findex<>cardinal(high(transfer.fpieces)) then begin
    log('Disconnecting source '+source.ipS+' sent us wrong piecelen');
    source.status:=btSourceShouldRemove;
    exit;
   end;
 end;
 log('handleIncomingPiece: 6');
  transfer.write((int64(piece.findex)*int64(transfer.fpieceLength))+int64(offset),
                 @source.inbuffer[9],
                 lenData,
                 rem,
                 er);
 log('handleIncomingPiece: 7');
  if rem<>0 then begin

   exit;
  end;
 //log('handleIncomingPiece: 8');
 piece.pieces[offset div BITTORRENT_PIECE_LENGTH]:=true;
 inc(piece.fprogress,lenData);
 if source.outRequests>=1 then dec(source.outRequests);
 //log('handleIncomingPiece: 9');
 if transfer.tempDownloaded+LenData<=transfer.fsize then inc(transfer.tempDownloaded,lenData);
 inc(loc_downloadedBytes,lenData);
 //log('handleIncomingPiece: 10');

 if piece.fprogress=piece.fsize then begin // time to check SHA1
   if transfer.hashFails>=NUMMAX_TRANSFER_HASHFAILS then begin
    if piece=source.assignedChunk then begin
     source.assignedChunk:=nil;
     piece.assignedSource:=nil;
    end;
   end;
   //log('handleIncomingPiece: 11');
   piece.check;
   //log('handleIncomingPiece: 12');
   if piece.checked then begin
    RemoveOutGoingRequestForPiece(transfer,piece.findex);

    if transfer.hashFails>=NUMMAX_TRANSFER_HASHFAILS then inc(source.blocksReceived);
    //log('handleIncomingPiece: 13');
    transfer.changedVisualBitField:=true;
    BroadcastHave(transfer,piece);
    //log('handleIncomingPiece: 14');
    if transfer.isCompleted then begin
    //log('handleIncomingPiece: 15');
     DisconnectSeeders(transfer);
     SetAllNotinterested(transfer);
     transfer.DoComplete;
    //log('handleIncomingPiece: 16');

     if transfer.trackers.count>0 then begin
      tracker:=transfer.trackers[transfer.trackerIndex];
      tracker.next_poll:=0; //send notification to tracker
     end;
     transfer.fstate:=dlSeeding;
      GlobTransfer:=transfer;
//      synchronize(CompleteVisualTransfer);
    end;
    if source.weAreInterested then areWeStillInterested(transfer,source);
   end else begin
    dec(transfer.tempDownloaded,piece.fsize);
    inc(transfer.hashFails);
    if transfer.hashFails>NUMMAX_TRANSFER_HASHFAILS then begin
     inc(source.hashFails);
       if source.hashFails>=NUMMAX_SOURCE_HASHFAILS then begin
         log('Disconnecting source '+source.ipS+' too many hashfails');
        source.status:=btSourceShouldRemove;
        btcore.AddBannedIp(transfer,source.ipC);
        exit;
       end;
    end;
   end;
 end;
  //log('handleIncomingPiece: 17');
  if transfer.fstate=dlBittorrentMagnetDiscovery then exit;

  if source.weAreInterested then begin
   while (source.outRequests<GetoptimumNumOutRequests(source.speed_recv)) do begin
    if not AskChunk(Transfer,source,tick) then break; //ask another piece
   end;
  end;
  //log('handleIncomingPiece: 18');

 except
 end;
end;

procedure DisconnectSeeders(transfer:TBitTorrentTransfer);//download completed we no longer need seeders
var
i:integer;
source:TBitTorrentSource;
begin
for i:=0 to transfer.fsources.count-1 do begin
  source:=transfer.fsources[i];
  if source.progress<100 then continue;
  source.status:=btSourceShouldRemove;
end;
end;

procedure TThreadTransfer.SetAllNotinterested(transfer:TBitTorrentTransfer);//download completed we no longer need seeders
var
i:integer;
source:TBitTorrentSource;
begin
 for i:=0 to transfer.fsources.count-1 do begin
  source:=transfer.fsources[i];
  if source.status<>btSourceConnected then continue;

   if source.isInterested then begin
     source.isInterested:=false;
     Source_AddOutPacket(source,'',CMD_BITTORRENT_NOTINTERESTED);
   end;

 end;
end;

procedure tthread_bittorrent.SetAllNotinterested(transfer:TBitTorrentTransfer);//download completed we no longer need seeders
var
i:integer;
source:TBitTorrentSource;
begin
 for i:=0 to transfer.fsources.count-1 do begin
  source:=transfer.fsources[i];
  if source.status<>btSourceConnected then continue;

   if source.isInterested then begin
     source.isInterested:=false;
     Source_AddOutPacket(source,'',CMD_BITTORRENT_NOTINTERESTED);
   end;

 end;
end;

function DropWorstConnectedInactiveSource(transfer:TBitTorrentTransfer; source:TBitTorrentSource; tick:cardinal):boolean;
var
i:integer;
tmpSource:TBitTorrentSource;
begin
result:=false;

if transfer.isCompleted then transfer.fsources.sort(BitTorrentSortWorstForaSeederInactiveSourceFirst)
 else transfer.fsources.sort(BitTorrentSortWorstForaLeecherInactiveSourceFirst);
 
for i:=0 to transfer.fsources.count-1 do begin
 tmpSource:=transfer.fsources[i];
 if tmpSource=source then continue;
 if tmpSource.status<>btSourceConnected then continue;
 if tick-tmpSource.handShakeTick<5*MINUTE then continue;//minimum threshold

 tmpSource.status:=btSourceShouldDisconnect;
 result:=true;
 break;
end;

end;

procedure BroadcastHave(transfer:TBitTorrentTransfer; piece:TBitTorrentChunk);
var
i:integer;
source:TBittorrentSource;
str:string;
begin

str:=int_2_dword_stringRev(piece.findex);
     
for i:=0 to transfer.fsources.count-1 do begin
 source:=transfer.fsources[i];
 if source.status<>btSourceConnected then continue;

 //if source.bitfield<>nil then
  //if source.bitfield.bits[piece.index] then continue; //already have this piece, don't send my have message?

   source_AddOutPacket(source,str,CMD_BITTORRENT_HAVE);
end;

end;

function ChoseAnyChunk(transfer:TBitTorrentTransfer; source:TBitTorrentSource; var SuggestedFreeOffSetIndex:integer):TBittorrentChunk;
var
i:integer;
piece:TBitTorrentChunk;
begin
result:=nil;

 for i:=0 to high(transfer.fpieces) do begin
  piece:=transfer.fpieces[i];
  if piece.checked then continue;
  if not piece.downloadable then continue; //this chunk is related to a file we do not want
  if not source.bitfield.bits[i] then continue;

     SuggestedFreeOffSetIndex:=FindAnyPieceMissing(transfer,piece);
     if SuggestedFreeOffSetIndex=-1 then continue;

      result:=piece;
      exit;

 end;

end;

function ChoseIncompleteChunk(transfer:TBitTorrentTransfer; source:TBitTorrentSource; var SuggestedFreeOffSetIndex:integer):TBittorrentChunk;
var
i:integer;
piece:TBitTorrentChunk;
begin
result:=nil;

 for i:=0 to high(transfer.fpieces) do begin
  piece:=transfer.fpieces[i];
  if piece.checked then continue;
  if not piece.downloadable then continue; //this chunk is related to a file we do not want
  if not source.bitfield.bits[i] then continue;
  if piece.fprogress=0 then continue;


   if transfer.isEndGameMode then begin
     SuggestedFreeOffSetIndex:=FindPieceNotRequestedBySource(transfer,source,piece);
     if SuggestedFreeOffSetIndex=-1 then continue;
   end else begin
     if piece.assignedSource<>nil then continue;

     SuggestedFreeOffSetIndex:=FindPieceNotRequestedByAnySource(transfer,piece);
     if SuggestedFreeOffSetIndex=-1 then continue;
   end;

      result:=piece;
      exit;
 end;
end;

procedure SendPexHandshake(source:tbittorrentSource);
begin
source_AddOutPacket(source,
                          chr(0)+'d1:ei0e1:md'+
                                 '6:ut_pexi'+inttostr(OUR_UT_PEX_OPCODE)+'e'+
                                 '11:ut_metadatai'+inttostr(OUR_UT_METADATA_OPCODE)+'e'+
                                 'e1:pi'+inttostr(vars_global.myport)+'e1:v'+inttostr(1+length(AGENT_NAME2)+length(vars_global.versioneares))+':'+AGENT_NAME2+' '+vars_global.versioneares+'6:yourip4:'+int_2_dword_string(source.ipC)+'e',
                          CMD_BITTORRENT_EXTENSION);
end;

function FindAnyPieceMissing(transfer:TBitTorrentTransfer; piece:TBitTorrentchunk):integer;
var
i:integer;
begin
result:=-1;

 if not piece.pieces[random(length(piece.pieces))] then begin
  result:=i;
  exit;
 end;

 for i:=0 to high(piece.pieces) do begin
   if piece.pieces[i] then continue;
   result:=i;
   exit;
 end;
end;

function FindPieceNotRequestedByAnySource(transfer:TBitTorrentTransfer; piece:TBitTorrentchunk):integer;
var
i,h:integer;
cmpOffset:cardinal;
request:precord_BitTorrentoutgoing_request;
found:boolean;
begin
result:=-1;

 for i:=0 to high(piece.pieces) do begin
   if piece.pieces[i] then continue;
   cmpOffset:=i*BITTORRENT_PIECE_LENGTH;

    found:=false;
    for h:=0 to transfer.outGoingRequests.count-1 do begin
     request:=transfer.outGoingRequests[h];
      if cardinal(request^.index)<>piece.findex then continue;
      if request^.offset<>cmpOffset then continue;
      found:=true;
      break;
    end;

    if not found then begin
     result:=i;
     exit;
    end;

 end;
end;

function FindPieceNotRequestedBySource(transfer:TBitTorrentTransfer; source:TBittorrentSource; piece:TBitTorrentchunk):integer;
var
i,h:integer;
cmpOffset:cardinal;
request:precord_BitTorrentoutgoing_request;
found:boolean;
begin
result:=-1;

 for i:=0 to high(piece.pieces) do begin
   if piece.pieces[i] then continue;
   cmpOffset:=i*BITTORRENT_PIECE_LENGTH;

    found:=false;
    for h:=0 to transfer.outGoingRequests.count-1 do begin
     request:=transfer.outGoingRequests[h];
      if longint(request^.source)<>longint(source) then continue;
      if request^.index<>piece.findex then continue;
      if request^.offset<>cmpOffset then continue;
      found:=true;
      break;
    end;

    if not found then begin
     result:=i;
     exit;
    end;

 end;
end;

procedure ExpireOutGoingRequests(list:Tmylist; tick:cardinal);
var
 i,h:integer;
 tran:TBitTorrentTransfer;
 source:TBitTorrentSource;
begin
 for i:=0 to list.count-1 do begin
  tran:=list[i];

  ExpireOutGoingRequests(tran,tick);

  if tran.fstate=dlBittorrentMagnetDiscovery then continue;
  if tran.isCompleted then continue;
  if (i mod 3)=0 then sleep(1);
  
  //request again
  for h:=0 to tran.fsources.count-1 do begin
   source:=tran.fsources[h];
   if source.status<>btSourceConnected then continue;
   if source.weArechoked then continue;
   if not source.weAreInterested then continue;

     while (source.outRequests<GetoptimumNumOutRequests(source.speed_recv)) do begin
      if not AskChunk(Tran,source,tick) then break; //ask another piece
     end;
     
  end;


 end;

 //reask to unchocked hosts
end;

function Source_PeekRequest_InIncomingBuffer(source:TBitTorrentSource; request:precord_BitTorrentoutgoing_request):boolean;
var
pieceIndex,
pieceOffset:cardinal;
begin
result:=false;



 if length(source.InBuffer)<9 then exit; //not enough data
 if source.InBuffer[1]<>chr(CMD_BITTORRENT_PIECE) then exit; //incoming packet is not a piece packet

 pieceIndex:=chars_2_dwordRev(copy(source.inBuffer,2,4));
 pieceOffset:=chars_2_dwordRev(copy(source.inBuffer,6,4));


if pieceIndex<>cardinal(request^.index) then exit;
if pieceOffset<>request^.offset then exit;

result:=true;
end;

procedure ExpireOutGoingRequests(Transfer:TBitTorrentTransfer; tick:cardinal);
var
i:integer;
request:precord_BitTorrentoutgoing_request;
source:TBitTorrentSource;
piece:TBitTorrentChunk;
begin
try

if transfer.fstate=dlPaused then exit;

i:=0;
while (i<transfer.outgoingRequests.count) do begin
 request:=transfer.outGoingRequests[i];

 if tick-request^.requestedTick<EXPIRE_OUTREQUEST_INTERVAL then begin
  inc(i);
  continue;
 end;



   source:=FindSourceFromID(transfer,request^.source);
   if source=nil then begin
    transfer.outGoingRequests.delete(i);
    FreeMem(request,sizeof(record_BitTorrentoutgoing_request));
    continue;
   end;

   if request^.requested>=5 then begin
    if source.outRequests>=1 then dec(source.outRequests);
    transfer.outGoingRequests.delete(i);
    FreeMem(request,sizeof(record_BitTorrentoutgoing_request));
    continue;
   end;
   
   if Source_PeekRequest_InIncomingBuffer(source,request) then begin  // this piece is arriving, do not ask again, simply leave the request untouched
    inc(i);
    continue;
   end;

   if source.weAreChoked then begin
    if source.outRequests>=1 then dec(source.outRequests);
    transfer.outGoingRequests.delete(i);
    FreeMem(request,sizeof(record_BitTorrentoutgoing_request));
    continue;
   end;

   if not source.weAreInterested then begin
    if source.outRequests>=1 then dec(source.outRequests);
    transfer.outGoingRequests.delete(i);
    FreeMem(request,sizeof(record_BitTorrentoutgoing_request));
    continue;
   end;

   piece:=transfer.fpieces[request^.index];
   if piece.checked then begin
    if source.outRequests>=1 then dec(source.outRequests);
    transfer.outGoingRequests.delete(i);
    FreeMem(request,sizeof(record_BitTorrentoutgoing_request));
    continue;
   end;

   request^.requestedTick:=tick;
   inc(request^.requested);
   Source_AddOutPacket(source,
                       int_2_dword_stringRev(request^.index)+
                       int_2_dword_stringRev(request^.offset)+
                       int_2_dword_stringRev(request^.WantedLen),
                       CMD_BITTORRENT_REQUEST,
                       true,
                       request^.index,
                       request^.offset,
                       request^.WantedLen);

  inc(i);
end;

except
end;
end;

function AskChunk(Transfer:TBitTorrentTransfer; source:TBitTorrentSource; tick:cardinal):boolean;
var
offset,pieceOffsetIndex:integer;
wantedLen:int64;
piece:TBitTorrentChunk;
request:precord_BitTorrentoutgoing_request;
begin
result:=false;

try
if ((source.assignedChunk<>nil) and
    (transfer.hashFails>=NUMMAX_TRANSFER_HASHFAILS) and
    (not transfer.isEndGameMode)) then begin

 piece:=source.assignedChunk;
 pieceOffsetIndex:=FindPieceNotRequestedBySource(transfer,source,piece);
 if pieceOffsetIndex=-1 then begin

  exit;
 end;

end else begin

  piece:=ChoseIncompleteChunk(transfer,source,pieceOffsetIndex);
  if (piece=nil) then begin
   piece:=ChosePrioritaryChunk(transfer,source,pieceOffsetIndex);
  
   if piece=nil then begin
     piece:=ChoseLeastPopularChunk(transfer,source,pieceOffsetIndex);
     if (piece=nil) and (ProgressiveDL) then  Exit;
     if piece=nil then begin
         if transfer.isEndGameMode then begin
           piece:=ChoseAnyChunk(transfer,source,pieceOffsetIndex);
           if piece=nil then begin

            exit;
           end;
         end else begin
           exit;
         end;
    end;
   end;
  end;

end;

offset:=pieceOffsetIndex*BITTORRENT_PIECE_LENGTH;

WantedLen:=BITTORRENT_PIECE_LENGTH;

if piece.findex=cardinal(high(transfer.Fpieces)) then
 if pieceOffsetIndex=high(piece.pieces) then begin
  WantedLen:=transfer.Fsize-int64(int64(piece.findex*transfer.fpieceLength)+offset);
 end;

 Source_AddOutPacket(source,
                     int_2_dword_stringRev(piece.findex)+
                     int_2_dword_stringRev(offset)+
                     int_2_dword_stringRev(WantedLen),
                     CMD_BITTORRENT_REQUEST,
                     true,
                     piece.findex,
                     offset,
                     wantedLen);

inc(source.outRequests);

if ((transfer.hashFails>=NUMMAX_TRANSFER_HASHFAILS) and
    (not transfer.isEndGameMode)) then begin // assign the same chunk to the same source, so that we can isolate malicious clients
 source.assignedChunk:=piece;
 piece.assignedSource:=source;
end;

 request:=AllocMem(sizeof(record_BitTorrentoutgoing_request));
  request^.index:=piece.findex;
  request^.offset:=offset;
  request^.wantedLen:=wantedLen;
  request^.requestedTick:=tick;
  request^.source:=longint(source);
  request^.requested:=1;
   transfer.outGoingRequests.add(request);

result:=true;

//if transfer.fsize-transfer.fdownloaded<MEGABYTE then

except
end;
end;

function FindSourceFromID(transfer:TBittorrentTransfer; ID:cardinal):TBitTorrentSource;
var
i:integer;
source:TBitTorrentSource;
begin
result:=nil;

 for i:=0 to transfer.fsources.count-1 do begin
  source:=transfer.fsources[i];
  if longint(source)<>longint(ID) then continue;
   result:=source;
   break;
 end;

end;

procedure Source_AddOutPacket(transfer:TBitTorrentTransfer; sourceId:cardinal; const packet:string; ID:Byte; haspriority:boolean = false; index:cardinal = 0; offset:cardinal = 0; wantedLen:cardinal = 0);
var
source:TBitTorrentSource;
begin
  source:=FindSourceFromID(transfer,sourceID);
  if source=nil then exit;
  if source.status<>btSourceConnected then exit;
  Source_AddOutPacket(source,packet,ID,haspriority,index,offset,wantedLen);
end;

procedure Source_AddOutPacket(source:TBittorrentSource; const packet:string; ID:Byte; haspriority:boolean = false; index:cardinal = 0; offset:cardinal = 0; wantedLen:cardinal = 0);
var
apacket,cmppacket:TBitTorrentOutPacket;
i,lastAcceptablePos:integer;
begin
aPacket:=TBitTorrentOutPacket.create;
 aPacket.priority:=hasPriority;
 aPacket.isFlushing:=false;
 aPacket.findex:=index;
 aPacket.foffset:=offset;
 aPacket.fwantedLen:=wantedLen;

 if ID=CMD_BITTORRENT_KEEPALIVE then begin
  { if source.SupportsAZmessaging then begin
      aPacket.payload:=int_2_dword_stringRev(length(CMD_AZ_BITTORRENT_KEEPALIVE))+
                       CMD_AZ_BITTORRENT_KEEPALIVE+
                       chr(1);
      aPacket.payload:=int_2_dword_stringRev(length(aPacket.payload))+aPacket.payload;
   end
    else  }
    aPacket.payload:=int_2_dword_string(0);
 end else begin
    {if source.SupportsAZmessaging then begin
        aPacket.payload:=int_2_dword_stringRev(length(AZ_CMD_LOOKUP[ID]))+
                         AZ_CMD_LOOKUP[ID]+
                         chr(1)+
                         packet;
        aPacket.payload:=int_2_dword_stringRev(length(aPacket.payload))+aPacket.payload;
    end
     else }
     aPacket.payload:=int_2_dword_stringRev(length(packet)+1)+
                           chr(ID)+
                           packet;
  end;
  
 aPacket.ID:=ID;

if not hasPriority then begin
 source.outBuffer.add(apacket);
 exit;
end;

if source.outBuffer.count=0 then source.outBuffer.add(apacket)
 else begin
  lastAcceptablePos:=source.outBuffer.count;

  for i:=source.outBuffer.count-1 downto 0 do begin // loop downward till we find a busy packet or another request
   cmpPacket:=source.outBuffer[i];
   if cmpPacket.isFlushing then break;
   if cmpPacket.priority then break;
   lastAcceptablePos:=i;
  end;

  if lastAcceptablePos>=source.outBuffer.count then source.outBuffer.add(apacket)
   else source.outbuffer.Insert(lastAcceptablePos,apacket);
 end;
end;


procedure RemoveOutGoingRequests(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
var
i:integer;
request:precord_BitTorrentoutgoing_request;
begin
source.outRequests:=0;

 i:=0;
 while (i<transfer.outgoingRequests.count) do begin
  request:=transfer.outGoingRequests[i];
  if longint(source)=longint(request^.source) then begin
    transfer.outGoingRequests.delete(i);
    FreeMem(request,sizeof(record_BitTorrentoutgoing_request));
    continue;
  end else inc(i);
 end;

end;

procedure RemoveOutGoingRequests(transfer:TBitTorrentTransfer);
var
 request:precord_BitTorrentoutgoing_request;
begin

 while (transfer.outgoingRequests.count>0) do begin
  request:=transfer.outGoingRequests[transfer.outgoingRequests.count-1];
            transfer.outGoingRequests.delete(transfer.outgoingRequests.count-1);
    FreeMem(request,sizeof(record_BitTorrentoutgoing_request));
 end;

end;


procedure HandleCancelMessage(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
var
i:integer;
aPacket:TBitTorrentOutPacket;
index,offset,wantedLen:cardinal;
begin
if length(source.inBuffer)<12 then exit;

index:=chars_2_dwordRev(copy(source.inBuffer,1,4));
if index>cardinal(high(transfer.fpieces)) then exit;
offset:=chars_2_dwordRev(copy(source.inBuffer,5,4));
wantedLen:=chars_2_dwordRev(copy(source.inBuffer,9,4));

i:=0;
while (i<source.outbuffer.count) do begin

  aPacket:=source.outbuffer[i];

   if aPacket.isFlushing then begin
    inc(i);
    continue; //we can't remove this...
   end;

  if aPacket.ID<>CMD_BITTORRENT_PIECE then begin
   inc(i);
   continue;
  end;

  if aPacket.findex=index then
   if aPacket.foffset=offset then
    if aPacket.fwantedLen=wantedLen then begin
      source.outbuffer.delete(i);
      aPacket.free;
      continue;
    end;

   inc(i);
end;

end;

procedure CancelOutGoingPiece(transfer:TBitTorrentTransfer; source:TBitTorrentSource; index,offset:cardinal);
var
i:integer;
str:string;
aPacket:TBitTorrentOutPacket;
begin
str:=int_2_dword_stringRev(index)+
     int_2_dword_stringRev(offset);

i:=0;
while (i<source.outbuffer.count) do begin

  aPacket:=source.outbuffer[i];

   if aPacket.isFlushing then begin
    inc(i);
    continue; //we can't remove this...
   end;

  if aPacket.ID<>CMD_BITTORRENT_PIECE then begin
   inc(i);
   continue;
  end;

  if copy(aPacket.payload,6,8)=str then begin
    source.outbuffer.delete(i);
      aPacket.free;
      continue;
   end;

   inc(i);
end;

end;

procedure TThreadTransfer.areWeStillInterested(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
var
i:integer;
piece:TBitTorrentChunk;
begin
if transfer.isCompleted then begin
 source.weAreInterested:=false;
 source_AddOutPacket(source,'',CMD_BITTORRENT_NOTINTERESTED);

exit;
end;

for i:=0 to high(transfer.Fpieces) do begin
 piece:=transfer.FPieces[i];
 if piece.checked then continue;
 if source.bitfield.bits[i] then exit; //ok we are still interested
end;

source.weAreInterested:=false;
 source_AddOutPacket(source,'',CMD_BITTORRENT_NOTINTERESTED);

end;

procedure tthread_bitTorrent.areWeStillInterested(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
var
i:integer;
piece:TBitTorrentChunk;
begin
if transfer.isCompleted then begin
 source.weAreInterested:=false;
 source_AddOutPacket(source,'',CMD_BITTORRENT_NOTINTERESTED);

exit;
end;

for i:=0 to high(transfer.Fpieces) do begin
 piece:=transfer.FPieces[i];
 if piece.checked then continue;
 if source.bitfield.bits[i] then exit; //ok we are still interested
end;

source.weAreInterested:=false;
 source_AddOutPacket(source,'',CMD_BITTORRENT_NOTINTERESTED);

end;

procedure TThreadTransfer.ResetBitField(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
var
i:integer;
piece:TBitTorrentChunk;
begin
if (transfer.fstate=dlBittorrentMagnetDiscovery) or
   (transfer.fstate=dlAllocating) then exit;
if source.bitfield=nil then source.bitfield:=tbittorrentBitfield.create(length(transfer.fpieces));
source.bitfield.initWithBitField(source.inBuffer);


for i:=0 to high(transfer.Fpieces) do begin
 piece:=transfer.FPieces[i];
 if piece.checked then continue;
  if not source.bitfield.bits[i] then continue;
    //if not isFullyRequested(transfer,piece) then begin
      if not source.weAreInterested then begin // we are interested, let remote peer know
          source_AddOutPacket(source,'',CMD_BITTORRENT_INTERESTED);
        source.weAreInterested:=true;
      end;
        break;
     //end;
end;

 source.progress:=CalcProgressFromBitField(source);
 CalcChunksPopularity(transfer);
 source.changedVisualBitField:=true;

 transfer.CalculateLeechsSeeds;

{
 if not transfer.isCompleted then
  if source.isLeecher then
   if transfer.numConnected>=BITTORENT_MAXNUMBER_CONNECTION_ESTABLISH then
    if CalcSourceOriginality(transfer,source)=0 then source.status:=btSourceShouldDisconnect;
}


if transfer.isCompleted then
 if source.isSeeder then source.status:=btSourceShouldRemove;
end;

procedure tthread_bitTorrent.ResetBitField(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
var
i:integer;
piece:TBitTorrentChunk;
begin
if (transfer.fstate=dlBittorrentMagnetDiscovery) or
   (transfer.fstate=dlAllocating) then exit;
if source.bitfield=nil then source.bitfield:=tbittorrentBitfield.create(length(transfer.fpieces));
source.bitfield.initWithBitField(source.inBuffer);


for i:=0 to high(transfer.Fpieces) do begin
 piece:=transfer.FPieces[i];
 if piece.checked then continue;
  if not source.bitfield.bits[i] then continue;
    //if not isFullyRequested(transfer,piece) then begin
      if not source.weAreInterested then begin // we are interested, let remote peer know
          source_AddOutPacket(source,'',CMD_BITTORRENT_INTERESTED);
        source.weAreInterested:=true;
      end;
        break;
     //end;
end;

 source.progress:=CalcProgressFromBitField(source);
 CalcChunksPopularity(transfer);
 source.changedVisualBitField:=true;

 transfer.CalculateLeechsSeeds;

{
 if not transfer.isCompleted then
  if source.isLeecher then
   if transfer.numConnected>=BITTORENT_MAXNUMBER_CONNECTION_ESTABLISH then
    if CalcSourceOriginality(transfer,source)=0 then source.status:=btSourceShouldDisconnect;
}


if transfer.isCompleted then
 if source.isSeeder then source.status:=btSourceShouldRemove;
end;

function CalcSourceOriginality(transfer:TBittorrentTransfer; source:TBittorrentSource):integer;
var
i:integer;
piece:TBittorrentChunk;
begin
 result:=0;
 
 for i:=0 to high(source.bitfield.bits) do begin
   if not source.bitfield.bits[i] then continue;
   piece:=transfer.fpieces[i];
    if piece.checked then continue; //computation based on what we need
    if sourceIsTheOnlyOneHavingPiece(transfer,source,i) then begin // this source has a piece that no one else has
     result:=1;
     exit;
    end;
 end;
 
end;

function sourceIsTheOnlyOneHavingPiece(transfer:TBittorrentTransfer; source:TBittorrentSource; index:cardinal):boolean;
var
i:integer;
tmpsource:TBittorrentSource;
begin
 result:=true;

 for i:=0 to transfer.fsources.count-1 do begin
   tmpsource:=transfer.fsources[i];
   if tmpsource=source then continue;
    if tmpsource.status<>btSourceConnected then continue;
     if tmpsource.isSeeder then continue;
      if tmpsource.bitfield=nil then continue;
       if cardinal(high(tmpsource.bitfield.bits))<index then continue; //what?
   if tmpsource.bitfield.bits[index] then begin  //someone else has this piece
    result:=false;
    exit;
   end;
 end;
end;

procedure CalcChunksPopularity(transfer:TBitTorrentTransfer);
var
i,h:integer;
piece:TBitTorrentChunk;
source:TBitTorrentSource;
begin
for i:=0 to high(transfer.FPieces) do begin //reset popularity
 piece:=transfer.FPieces[i];
 if piece.checked then piece.popularity:=1
  else piece.popularity:=0;
end;

for i:=0 to transfer.FSources.count-1 do begin
 source:=transfer.FSources[i];
 if source.isSeeder then continue;
 if source.bitfield=nil then continue;

 for h:=0 to high(transfer.FPieces) do begin
  piece:=transfer.FPieces[h];
  if source.bitfield.bits[h] then inc(piece.popularity);
 end;
end;
end;

function ChosePrioritaryChunk(transfer:TBitTorrentTransfer; source:TBitTorrentSource; var SuggestedFreeOffSetIndex:integer):TBitTorrentChunk;
var
i:integer;
piece:TBitTorrentChunk;
list:TMylist;
begin
result:=nil;

list:=tmylist.create;

for i:=0 to high(transfer.Fpieces) do begin 
 piece:=transfer.FPieces[i];
 if piece.checked then continue;
 if not piece.downloadable then continue; //this chunk is related to a file we do not want
 if piece.Priority=0 then continue;
 if not source.bitfield.bits[i] then continue;
 if piece.fprogress>0 then continue; //only brand new pieces
 list.add(piece);
end;

//if list.count>1 then list.sort(sortMostPrioritaryFirst);

for i:=0 to list.count-1 do begin
 piece:=list[i];

   if transfer.isEndGameMode then begin
     SuggestedFreeOffSetIndex:=FindPieceNotRequestedBySource(transfer,source,piece);
     if SuggestedFreeOffSetIndex=-1 then continue;
   end else begin
     if piece.assignedSource<>nil then continue;
     SuggestedFreeOffSetIndex:=FindPieceNotRequestedByAnySource(transfer,piece);
     if SuggestedFreeOffSetIndex=-1 then continue;
   end;


  result:=piece;
  list.free;
  exit;
end;



list.free;

end;

function ChoseLeastPopularChunk(transfer:TBitTorrentTransfer; source:TBitTorrentSource; var SuggestedFreeOffSetIndex:integer):TBitTorrentChunk;
var
i,lowestPopularity,oneTenth:integer;
piece:TBitTorrentChunk;
list:TMylist;
begin
result:=nil;

list:=tmylist.create;

// seek a random point in the array
lowestPopularity:=100;
for i:=0 to high(transfer.FPieces) do begin
 piece:=transfer.FPieces[i];

 if piece.checked then continue;
 if not piece.downloadable then continue; //this chunk is related to a file we do not want
 if piece.fprogress>0 then continue; //only brand new pieces
 if not source.bitfield.bits[i] then continue;

  if not transfer.isEndGameMode then
   if piece.assignedSource<>nil then continue;


 list.add(piece);
 if piece.popularity<lowestPopularity then lowestPopularity:=piece.popularity;
end;



if list.count>1 then begin
 // malicious clients seem to fake a lot popularity ratings these days...
 // therefore do not always chose by popularity
  shuffle_mylist(list,0);

  if not transfer.isEndGameMode then
   if random(600)>300 then begin
    list.sort(sortLeastPopularFirst);
     if list.count>10 then begin
      oneTenth:=list.count div 10;
      if oneTenth<20 then oneTenth:=20;
      while (list.count>oneTenth) do list.delete(list.count-1);
     end;
    shuffle_mylist(list,0);
   end;

end;



for i:=0 to list.count-1 do begin
 piece:=list[i];

   if transfer.isEndGameMode then begin
     SuggestedFreeOffSetIndex:=FindPieceNotRequestedBySource(transfer,source,piece);
     if SuggestedFreeOffSetIndex=-1 then continue;
   end else begin
     SuggestedFreeOffSetIndex:=FindPieceNotRequestedByAnySource(transfer,piece);
     if SuggestedFreeOffSetIndex=-1 then continue;
   end;


  result:=piece;
  list.free;
  exit;
end;



list.free;
end;


procedure IncChunkPopularity(transfer:TBitTorrentTransfer; source:TBitTorrentSource; index:integer);
var
piece:TBitTorrentChunk;
begin
if (transfer.fstate=dlBittorrentMagnetDiscovery) or
   (transfer.fstate=dlAllocating) then exit;
if source.bitfield=nil then source.bitfield:=TBitTorrentBitField.create(length(transfer.FPieces));
if source.bitfield.bits[index] then exit;
piece:=transfer.fpieces[index];
inc(piece.popularity);
end;

procedure TThreadTransfer.updateBitField(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
var
indeX:cardinal;
piece:TBitTorrentChunk;
begin
if (transfer.fstate=dlBittorrentMagnetDiscovery) or
   (transfer.fstate=dlAllocating) then exit;
if length(source.inBuffer)<4 then exit;

index:=chars_2_dwordRev(copy(source.inBuffer,1,4));
if index>=cardinal(length(transfer.fpieces)) then begin
 exit;
end;
if source.bitfield=nil then source.bitfield:=tbittorrentBitfield.create(length(transfer.fpieces));

source.bitfield.bits[index]:=true;
source.changedVisualBitField:=true; //update visual bitfield in checkSourceVisual

source.progress:=CalcProgressFromBitField(source);
IncChunkPopularity(transfer,source,index);
transfer.CalculateLeechsSeeds;

{
if not transfer.isCompleted then
 if source.progress>2 then
  if source.isLeecher then
   if transfer.numConnected>=BITTORENT_MAXNUMBER_CONNECTION_ESTABLISH then
    if CalcSourceOriginality(transfer,source)=0 then source.status:=btSourceShouldDisconnect;
}

 if transfer.isCompleted then
  if source.isSeeder then begin  //it's a seeder now and we are too, so get rid of it
   source.status:=btSourceShouldRemove;
   exit;
  end;



piece:=transfer.FPieces[index];
if not piece.checked then begin// we are interested, let remote peer know
  if not source.weAreInterested then begin
              source_AddOutPacket(source,'',CMD_BITTORRENT_INTERESTED);

  source.weAreInterested:=true;
  end;
end;

end;

procedure tthread_bitTorrent.updateBitField(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
var
indeX:cardinal;
piece:TBitTorrentChunk;
begin
if (transfer.fstate=dlBittorrentMagnetDiscovery) or
   (transfer.fstate=dlAllocating) then exit;
if length(source.inBuffer)<4 then exit;

index:=chars_2_dwordRev(copy(source.inBuffer,1,4));
if index>=cardinal(length(transfer.fpieces)) then begin
 exit;
end;
if source.bitfield=nil then source.bitfield:=tbittorrentBitfield.create(length(transfer.fpieces));

source.bitfield.bits[index]:=true;
source.changedVisualBitField:=true; //update visual bitfield in checkSourceVisual

source.progress:=CalcProgressFromBitField(source);
IncChunkPopularity(transfer,source,index);
transfer.CalculateLeechsSeeds;

{
if not transfer.isCompleted then
 if source.progress>2 then
  if source.isLeecher then
   if transfer.numConnected>=BITTORENT_MAXNUMBER_CONNECTION_ESTABLISH then
    if CalcSourceOriginality(transfer,source)=0 then source.status:=btSourceShouldDisconnect;
}

 if transfer.isCompleted then
  if source.isSeeder then begin  //it's a seeder now and we are too, so get rid of it
   source.status:=btSourceShouldRemove;
   exit;
  end;



piece:=transfer.FPieces[index];
if not piece.checked then begin// we are interested, let remote peer know
  if not source.weAreInterested then begin
              source_AddOutPacket(source,'',CMD_BITTORRENT_INTERESTED);

  source.weAreInterested:=true;
  end;
end;

end;

procedure TThreadTransfer.SourceFlush(transfer:TBitTorrentTransfer; source:TBittorrentSource);
var
tosend,er,len_sent:integer;
aPacket:TBitTorrentOutPacket;
begin
try
if source.outbuffer.count>40 then begin
    log('Disconnecting source '+source.ipS+' too many pieces in outbuffer');
   calcSourceUptime(source);
   //logSourceDisconnect(source,tick);
   SourceDisconnect(source);
 exit;
end;



while (source.outbuffer.count>0) do begin

  aPacket:=source.outbuffer[0];
  toSend:=length(aPacket.payload);

 if not transfer.isCompleted then
  if aPacket.ID=CMD_BITTORRENT_PIECE then
   if not source.isChoked then
    if source.SlotType<>ST_OPTIMISTIC then begin
      if source.NumBytesToSendPerSecond<=0 then exit;
      if source.NumBytesToSendPerSecond-tosend<0 then tosend:=source.NumBytesToSendPerSecond;
    end;

   if tosend>1024 then tosend:=1024;

  len_sent:=TCPSocket_SendBuffer(source.socket.socket,
                                 pchar(aPacket.payload),
                                 tosend,
                                 er);
                                 
  if er=WSAEWOULDBLOCK then exit;
  if er<>0 then begin
    log('Disconnecting source '+source.ipS+' hangup on flush');
   calcSourceUptime(source);
   //logSourceDisconnect(source,tick);
   SourceDisconnect(source);
   exit;
  end;
  if len_sent=0 then begin

   exit;
  end;



  aPacket.isFlushing:=true;

  if aPacket.ID=CMD_BITTORRENT_PIECE then begin
    if not transfer.isCompleted then
     if not source.isChoked then
      if source.SlotType<>ST_OPTIMISTIC then dec(source.NumBytesToSendPerSecond,len_sent);
   inc(source.sent,len_sent);
   inc(transfer.fuploaded,len_sent);
   inc(Transfer.TempUploaded,len_sent);
   source.lastDataOut:=tickTransfer;
  end;

  aPacket.isFlushing:=true;
  delete(aPacket.payload,1,len_sent);


  if length(aPacket.payload)=0 then begin
   source.outbuffer.delete(0);
   aPacket.free;
  end;

  if terminated then exit;
end;

except
end;
end;

procedure tthread_bitTorrent.SourceFlush(transfer:TBitTorrentTransfer; source:TBittorrentSource);
var
tosend,er,len_sent:integer;
aPacket:TBitTorrentOutPacket;
begin
try
if source.outbuffer.count>40 then begin
    log('Disconnecting source '+source.ipS+' too many pieces in outbuffer');
   calcSourceUptime(source);
   //logSourceDisconnect(source,tick);
   SourceDisconnect(source);
 exit;
end;



while (source.outbuffer.count>0) do begin

  aPacket:=source.outbuffer[0];
  toSend:=length(aPacket.payload);

 if not transfer.isCompleted then
  if aPacket.ID=CMD_BITTORRENT_PIECE then
   if not source.isChoked then
    if source.SlotType<>ST_OPTIMISTIC then begin
      if source.NumBytesToSendPerSecond<=0 then exit;
      if source.NumBytesToSendPerSecond-tosend<0 then tosend:=source.NumBytesToSendPerSecond;
    end;

   if tosend>1024 then tosend:=1024;

  len_sent:=TCPSocket_SendBuffer(source.socket.socket,
                                 pchar(aPacket.payload),
                                 tosend,
                                 er);
                                 
  if er=WSAEWOULDBLOCK then exit;
  if er<>0 then begin
    log('Disconnecting source '+source.ipS+' hangup on flush');
   calcSourceUptime(source);
   //logSourceDisconnect(source,tick);
   SourceDisconnect(source);
   exit;
  end;
  if len_sent=0 then begin

   exit;
  end;



  aPacket.isFlushing:=true;

  if aPacket.ID=CMD_BITTORRENT_PIECE then begin
    if not transfer.isCompleted then
     if not source.isChoked then
      if source.SlotType<>ST_OPTIMISTIC then dec(source.NumBytesToSendPerSecond,len_sent);
   inc(source.sent,len_sent);
   inc(transfer.fuploaded,len_sent);
   inc(Transfer.TempUploaded,len_sent);
   source.lastDataOut:=tick;
  end;

  aPacket.isFlushing:=true;
  delete(aPacket.payload,1,len_sent);


  if length(aPacket.payload)=0 then begin
   source.outbuffer.delete(0);
   aPacket.free;
  end;

  if terminated then exit;
end;

except
end;
end;

function TThreadTransfer.GetNumConnecting(transfer:TBitTorrentTransfer):integer;
var
i:integer;
source:TBitTorrentSource;
begin
result:=0;
for i:=0 to transfer.fsources.count-1 do begin
 source:=transfer.fsources[i];
 if source.status=btSourceConnecting then inc(result);
enD;
end;

function tthread_bitTorrent.GetNumConnecting(transfer:TBitTorrentTransfer):integer;
var
i:integer;
source:TBitTorrentSource;
begin
result:=0;
for i:=0 to transfer.fsources.count-1 do begin
 source:=transfer.fsources[i];
 if source.status=btSourceConnecting then inc(result);
enD;
end;
{
procedure updateVisualGlobSource; //synch
var
MustSort:boolean;
begin
if globsource.dataDisplay=nil then exit;

globsource.dataDisplay^.ID:=globsource.ID;
MustSort:=(globSource.status<>globSource.datadisplay^.status);
globsource.datadisplay^.status:=globsource.status;

 if GlobSource.bitfield<>nil then
  btcore.CloneBitfield(Globsource.bitfield,globsource.datadisplay^.VisualBitField,globsource.datadisplay^.progress);

  globsource.datadisplay^.choked:=Globsource.isChoked;
  globsource.datadisplay^.interested:=Globsource.isinterested;
  globsource.datadisplay^.weAreChoked:=Globsource.weArechoked;
  globSource.datadisplay^.weAreInterested:=GlobSource.weAreInterested;

  globSource.datadisplay^.client:=GlobSource.client;
  globSource.datadisplay^.recv:=GlobSource.recv;
  globSource.datadisplay^.sent:=GlobSource.sent;
  
  
if ares_frmmain.tabs_pageview.activepage=IDTAB_TRANSFER then begin
 if GlobTransfer.uploadtreeview then begin
   ares_frmmain.treeview_upload.InvalidateNode(globsource.nodeDisplay);
   if MustSort then ares_frmmain.treeview_upload.Sort(Globtransfer.visualNode,3,sdDescending);
 end else begin
   ares_frmmain.treeview_download.InvalidateNode(globsource.nodeDisplay);
   if MustSort then ares_frmmain.treeview_download.Sort(Globtransfer.visualNode,3,sdDescending);
 end;
end;

end;
}{
procedure tthread_bittorrent.updateVisualGlobSource; //synch
var
MustSort:boolean;
begin
if globsource.dataDisplay=nil then exit;

globsource.dataDisplay^.ID:=globsource.ID;
MustSort:=(globSource.status<>globSource.datadisplay^.status);
globsource.datadisplay^.status:=globsource.status;

 if GlobSource.bitfield<>nil then
  btcore.CloneBitfield(Globsource.bitfield,globsource.datadisplay^.VisualBitField,globsource.datadisplay^.progress);

  globsource.datadisplay^.choked:=Globsource.isChoked;
  globsource.datadisplay^.interested:=Globsource.isinterested;
  globsource.datadisplay^.weAreChoked:=Globsource.weArechoked;
  globSource.datadisplay^.weAreInterested:=GlobSource.weAreInterested;

  globSource.datadisplay^.client:=GlobSource.client;
  globSource.datadisplay^.recv:=GlobSource.recv;
  globSource.datadisplay^.sent:=GlobSource.sent;

if ares_frmmain.tabs_pageview.activepage=IDTAB_TRANSFER then begin
 if GlobTransfer.uploadtreeview then begin
   ares_frmmain.treeview_upload.InvalidateNode(globsource.nodeDisplay);
   if MustSort then ares_frmmain.treeview_upload.Sort(Globtransfer.visualNode,3,sdDescending);
 end else begin
   ares_frmmain.treeview_download.InvalidateNode(globsource.nodeDisplay);
   if MustSort then ares_frmmain.treeview_download.Sort(Globtransfer.visualNode,3,sdDescending);
 end;
end;

end;
}{
procedure tthread_bitTorrent.deleteVisualGlobSource; //synch
begin
if globsource.nodedisplay=nil then exit;

 if globsource.nodedisplay=previous_hint_node then formhint_hide;

  if GlobTransfer.uploadtreeview then ares_frmmain.treeview_upload.DeleteNode(globsource.nodeDisplay,true)
   else ares_frmmain.treeview_download.DeleteNode(globsource.nodeDisplay,true);
end;
}

procedure TThreadTransfer.disconnectSource(transfer:TBittorrentTransfer; source:TBittorrentSource; RemoveRequests:boolean);
var
piece:TBitTorrentChunk;
ind:integer;
begin
 ind:=transfer.uploadSlots.indexof(source);
 if ind<>-1 then transfer.uploadSlots.delete(ind);

 if source.port=0 then begin
  source.status:=btSourceShouldRemove; // we wont be able to connect cause we don't know his port
  exit;
 end;

      source.NumOptimisticUnchokes:=0;
      source.socket.free;
      source.socket:=nil;
      source.bytes_in_header:=0;
      source.ClearOutBuffer;
      source.inbuffer:='';
      source.status:=btSourceIdle;
      source.outRequests:=0;

      if source.assignedChunk<>nil then begin
       piece:=source.assignedChunk;
       piece.assignedSource:=nil;
       source.assignedChunk:=nil;
      end;

      source.lastAttempt:=tickTransfer; // do not connect before a given interval

      GlobTransfer:=transfer;
      globSource:=source;
//      synchronize(updateVisualGlobsource);

      if RemoveRequests then begin
       RemoveOutGoingRequests(transfer,source);
       CalcNumConnected(transfer);
       transfer.CalculateLeechsSeeds;
      end;
end;

procedure tthread_bittorrent.disconnectSource(transfer:TBittorrentTransfer; source:TBittorrentSource; RemoveRequests:boolean);
var
piece:TBitTorrentChunk;
ind:integer;
begin
 ind:=transfer.uploadSlots.indexof(source);
 if ind<>-1 then transfer.uploadSlots.delete(ind);

 if source.port=0 then begin
  source.status:=btSourceShouldRemove; // we wont be able to connect cause we don't know his port
  exit;
 end;

      source.NumOptimisticUnchokes:=0;
      source.socket.free;
      source.socket:=nil;
      source.bytes_in_header:=0;
      source.ClearOutBuffer;
      source.inbuffer:='';
      source.status:=btSourceIdle;
      source.outRequests:=0;

      if source.assignedChunk<>nil then begin
       piece:=source.assignedChunk;
       piece.assignedSource:=nil;
       source.assignedChunk:=nil;
      end;

      source.lastAttempt:=tick; // do not connect before a given interval

      GlobTransfer:=transfer;
      globSource:=source;
//      synchronize(updateVisualGlobsource);

      if RemoveRequests then begin
       RemoveOutGoingRequests(transfer,source);
       CalcNumConnected(transfer);
       transfer.CalculateLeechsSeeds;
      end;
end;

procedure TThreadTransfer.RemoveSource(transfer:TBittorrentTransfer; source:TBittorrentSource);
var
piece:TBitTorrentChunk;
ind:integer;
ipC:cardinal;
begin
ind:=transfer.uploadSlots.indexof(source);
if ind<>-1 then transfer.uploadSlots.delete(ind);

RemoveOutGoingRequests(transfer,source);
ipC:=source.ipC;
 if source.assignedChunk<>nil then begin
  piece:=source.assignedChunk;
  piece.assignedSource:=nil;
  source.assignedChunk:=nil;
 end;

 globSource:=source;
 GlobTransfer:=transfer;
// synchronize(deleteVisualGlobSource);

 if source.bitfield<>nil then CalcChunksPopularity(transfer); // must perform before source freeing
 source.free;

 CalcNumConnected(transfer);
 transfer.CalculateLeechsSeeds;
end;

procedure TThread_bittorrent.RemoveSource(transfer:TBittorrentTransfer; source:TBittorrentSource);
var
piece:TBitTorrentChunk;
ind:integer;
ipC:cardinal;
begin
ind:=transfer.uploadSlots.indexof(source);
if ind<>-1 then transfer.uploadSlots.delete(ind);

RemoveOutGoingRequests(transfer,source);
ipC:=source.ipC;
 if source.assignedChunk<>nil then begin
  piece:=source.assignedChunk;
  piece.assignedSource:=nil;
  source.assignedChunk:=nil;
 end;

 globSource:=source;
 GlobTransfer:=transfer;
// synchronize(deleteVisualGlobSource);

 if source.bitfield<>nil then CalcChunksPopularity(transfer); // must perform before source freeing
 source.free;

 CalcNumConnected(transfer);
 transfer.CalculateLeechsSeeds;
end;

procedure TThreadTransfer.execute;
var
i,er,len,hi:integer;
source,tmpSource:tbittorrentSource;
str:string;
buffer:array[0..67] of char;
timeint:cardinal;
PortStr:string;
begin
FreeOnTerminate:=False;

repeat
tickTransfer:=GetTickCount;

try
i:=0;

EnterCriticalSection(TrackerCriticalSection);
try

while (i<transfer.fsources.count) do begin

 if terminated then break;
 source:=transfer.fsources[i];  
 case source.status of

    btSourceShouldDisconnect:begin
      DisconnectSource(transfer,source,true);
      inc(i);
      continue;
    end;

    btSourceShouldRemove:begin
      transfer.fsources.delete(i);
      RemoveSource(transfer,source);
     continue;
    end;
    
    btSourceConnected:begin
      while transferDeal(transfer,source) do ;
      inc(i);
      continue;
    end;

    btSourceIdle:begin
      if transfer.fstate=dlPaused then begin
       inc(i);
       continue;
      end;
      if transfer.numConnected>=BITTORENT_MAXNUMBER_CONNECTION_ESTABLISH then begin //no need to connect to more sources
       inc(i);
       continue;
      end;
      if GetNumConnecting(transfer)>=MAX_OUTGOING_ATTEMPTS then begin
       inc(i);
       continue;
      end;
      if (source.lastAttempt<>0) and (tickTransfer-source.lastAttempt<BTSOURCE_CONN_ATTEMPT_INTERVAL) then begin
       inc(i);
       continue;
      end;
      if transfer.fErrorCode<>0 then begin
//       Form1.Memo2.Lines.Add('transferDealExit');
       Break;//exit;
      end;
       
      if transfer.isCompleted then
       if source.isSeeder then begin  //this source is a seeder, connect to leechers only, now that data has been downloaded...
        inc(i);
        continue;
       end;
      source.lastAttempt:=tickTransfer;
      if source.socket<>nil then source.socket.free;
      source.ClearOutBuffer;
      source.inbuffer:='';
      source.socket:=TTCPBlockSocket.create(true);
      source.socket.block(false);
      //helper_sockets.assign_proxy_settings(source.socket);

     if vars_global.socks_type=SocTNone then begin
      source.socket.SocksIP:='';
      source.socket.SocksPort:='0';
     end else begin
      source.socket.FLastTime:=gettickcount; //per vari timeout in TCPSocket_connesso()
      source.socket.SocksIp:=vars_global.socks_ip;
      source.socket.SocksPort:=inttostr(vars_global.socks_port);
      if vars_global.socks_type=SocTSock5 then begin
        source.socket.SocksType:=ST_Socks5;
        source.socket.SocksUsername:=vars_global.socks_username;
        source.socket.SocksPassword:=vars_global.socks_password;
      end else source.socket.SocksType:=ST_Socks4;
      source.socket.FStatoConn:=PROXY_InConnessione;
     end;

      source.tick:=tickTransfer;
      source.status:=btSourceConnecting;
      source.IsIncomingConnection:=false;
      try
        PortStr:=inttostr(source.port);
      except  
      end;
      source.socket.connect(source.ipS,PortStr);
      GlobTransfer:=transfer;
      globSource:=source;
//      synchronize(updateVisualGlobsource);
    end;


    btSourceConnecting:begin
      if (transfer.fsources.count>=50) or
         (transfer.numConnected>15) then timeint:=5000 else timeint:=TIMEOUTTCPCONNECTION;
      if tickTransfer-source.tick>timeint then begin
        SourceAddFailedAttempt(transfer,source);
        inc(i);
        continue;
      end;
      er:=TCPSocket_ISConnected(source.socket);
      if er=WSAEWOULDBLOCK then begin
       inc(i);
       continue;
      end;
      if ((er<>0) and (er<>WSAEWOULDBLOCK)) then begin
        SourceAddFailedAttempt(transfer,source);
        inc(i);
        continue;
      end;

      str:=STR_BITTORRENT_PROTOCOL_HANDSHAKE+
           STR_BITTORRENT_PROTOCOL_EXTENSIONS+
           transfer.fhashvalue+
           thread_bittorrent.mypeerID;
//      ShowMessage(str);
      TCPSocket_SendBuffer(source.socket.socket,pchar(str),length(str),er);
      if er=WSAEWOULDBLOCK then begin
       inc(i);
       continue;
      end;
      if er<>0 then begin
       SourceAddFailedAttempt(transfer,source);
       inc(i);
       continue;
      end;

      source.status:=btSourceReceivingHandshake;
      source.tick:=tickTransfer;
      GlobTransfer:=transfer;
      globSource:=source;
//      synchronize(updateVisualGlobsource);
    end;

    btSourceReceivingHandshake:begin
      if (transfer.fsources.count>=50) or
         (transfer.numConnected>15) then timeint:=5000 else timeint:=TIMEOUTTCPRECEIVE;
      if tickTransfer-source.tick>timeint then begin
       SourceAddFailedAttempt(transfer,source);
       inc(i);
       continue;
      end;
      if not TCPSocket_CanRead(source.socket.socket,0,er) then begin
        if ((er<>0) and (er<>WSAEWOULDBLOCK)) then SourceAddFailedAttempt(transfer,source);
        inc(i);
        continue;
      end;

      len:=TCPSocket_RecvBuffer(source.socket.socket,@buffer,68,er);
      if er=WSAEWOULDBLOCK then begin
       inc(i);
       continue;
      end;
      if er<>0 then begin
        SourceAddFailedAttempt(transfer,source);
        inc(i);
        continue;
      end;

      SetLength(str,len);
      move(buffer,str[1],len);

      if copy(str,1,20)<>STR_BITTORRENT_PROTOCOL_HANDSHAKE then begin
        SourceAddFailedAttempt(transfer,source);
        inc(i);
        continue;
      end;

      if copy(str,29,20)<>transfer.fhashvalue then begin
       source.status:=btSourceShouldRemove;
       inc(i);
       continue;
      end;
      if length(source.id)=20 then begin
       if copy(str,49,20)<>source.id then begin

       end;
      end else begin
       source.id:=copy(str,49,20);

      end;

       ParseHandshakeReservedBytes(source,copy(str,21,8));

       source.tick:=tickTransfer;
       SourceSetConnected(source);
     
       inc(transfer.numConnected);
       //if GetShouldSendBitfield(transfer) then
       if transfer.fstate<>dlBittorrentMagnetDiscovery then SendBitField(transfer,source);
       if source.SupportsExtensions then SendPexHandshake(source);
       if (source.SupportsDHT) and (source.isNotAzureus) then SendDHTPort(source);

       globSource:=source;
       globTransfer:=transfer;
//       synchronize(updateVisualGlobsource);
    end;



    btSourceweMustSendHandshake:begin //accepted source we received her handshake, now we send ours
      if (transfer.fsources.count>=50) or
         (transfer.numConnected>15) then timeint:=5000 else timeint:=TIMEOUTTCPRECEIVE;
       if tickTransfer-source.tick>timeint then begin
        source.status:=btSourceShouldRemove;
        inc(i);
        continue;
       end;
       if not TCPSocket_CanWrite(source.socket.socket,0,er) then begin
         if ((er<>0) and (er<>WSAEWOULDBLOCK)) then begin
           source.status:=btSourceShouldRemove;
         end;
         inc(i);
         continue;
       end;
       str:=STR_BITTORRENT_PROTOCOL_HANDSHAKE+
            STR_BITTORRENT_PROTOCOL_EXTENSIONS+
            transfer.fhashvalue+
            thread_bittorrent.mypeerID;
       TCPSocket_SendBuffer(source.socket.socket,pchar(str),length(str),er);
       //ShowMessage('TCPSocket_SendBuffer');
       if er=WSAEWOULDBLOCK then begin
        inc(i);
        continue;
       end;
       if er<>0 then begin
        source.status:=btSourceShouldRemove;
        inc(i);
        continue;
       end;

       for hi:=0 to transfer.fsources.count-1 do begin
        tmpsource:=transfer.fsources[hi];
        if tmpsource=source then continue;
         if tmpsource.ipC<>source.ipC then continue;
           if tmpsource.status<>btSourceConnected then tmpsource.status:=btSourceShouldRemove
            else source.status:=btSourceShouldRemove;
         Break;//exit;
       end;


       source.tick:=tickTransfer;
       SourceSetConnected(source);

       inc(transfer.numConnected);

       GlobTransfer:=transfer;
       globSource:=source;
//       synchronize(updateVisualGlobsource);

       if transfer.fsources.count>BITTORRENT_MAX_ALLOWED_SOURCES then begin
        if not DropWorstConnectedInactiveSource(transfer,source,tickTransfer) then begin
         source.status:=btSourceShouldRemove;
         inc(i);
         continue;
        end;
       end;

       if transfer.numConnected>BITTORENT_MAXNUMBER_CONNECTION_ACCEPTED then begin //limit accepted connections
         if not DropWorstConnectedInactiveSource(transfer,source,tickTransfer) then begin
          source.status:=btSourceShouldRemove;
          inc(i);
          continue;
         end;
       end;

       //if GetShouldSendBitfield(transfer) then
      // if source.SupportsAZmessaging then SendAzHandshake(transfer,source);
        if transfer.fstate<>dlBittorrentMagnetDiscovery then SendBitField(transfer,source);
        if source.SupportsExtensions then SendPexHandshake(source);
        if (source.SupportsDHT) and (source.isNotAzureus) then SendDHTPort(source);
    end;

 end; // endof case switch

inc(i); 
end;

finally
LeaveCriticalSection(TrackerCriticalSection);
end;

except
end;

if not Terminated then
Sleep(3);
until Terminated;

end;

procedure tthread_bitTorrent.transferDeal(transfer:TBittorrentTransfer);
var
i,er,len,hi:integer;
source,tmpSource:tbittorrentSource;
str:string;
buffer:array[0..67] of char;
timeint:cardinal;
begin
try
i:=0;
while (i<transfer.fsources.count) do begin
 if terminated then break;
 source:=transfer.fsources[i];  
 case source.status of

    btSourceShouldDisconnect:begin
      DisconnectSource(transfer,source,true);
      inc(i);
      continue;
    end;

    btSourceShouldRemove:begin
      transfer.fsources.delete(i);
      RemoveSource(transfer,source);
     continue;
    end;
    
    btSourceConnected:begin
      while transferDeal(transfer,source) do ;
      inc(i);
      continue;
    end;

    btSourceIdle:begin
      if transfer.fstate=dlPaused then begin
       inc(i);
       continue;
      end;
      if transfer.numConnected>=BITTORENT_MAXNUMBER_CONNECTION_ESTABLISH then begin //no need to connect to more sources
       inc(i);
       continue;
      end;
      if GetNumConnecting(transfer)>=MAX_OUTGOING_ATTEMPTS then begin
       inc(i);
       continue;
      end;
      if (source.lastAttempt<>0) and (tick-source.lastAttempt<BTSOURCE_CONN_ATTEMPT_INTERVAL) then begin
       inc(i);
       continue;
      end;
      if transfer.fErrorCode<>0 then begin
//       Form1.Memo2.Lines.Add('transferDealExit');
       exit;
      end;
       
      if transfer.isCompleted then
       if source.isSeeder then begin  //this source is a seeder, connect to leechers only, now that data has been downloaded...
        inc(i);
        continue;
       end;
      source.lastAttempt:=tick;
      if source.socket<>nil then source.socket.free;
      source.ClearOutBuffer;
      source.inbuffer:='';
      source.socket:=TTCPBlockSocket.create(true);
      source.socket.block(false);
      helper_sockets.assign_proxy_settings(source.socket);
      source.tick:=tick;
      source.status:=btSourceConnecting;
      source.IsIncomingConnection:=false;
      source.socket.connect(source.ipS,inttostr(source.port));
      GlobTransfer:=transfer;
      globSource:=source;
//      synchronize(updateVisualGlobsource);
    end;


    btSourceConnecting:begin
      if (transfer.fsources.count>=50) or
         (transfer.numConnected>15) then timeint:=5000 else timeint:=TIMEOUTTCPCONNECTION;
      if tick-source.tick>timeint then begin
        SourceAddFailedAttempt(transfer,source);
        inc(i);
        continue;
      end;
      er:=TCPSocket_ISConnected(source.socket);
      if er=WSAEWOULDBLOCK then begin
       inc(i);
       continue;
      end;
      if ((er<>0) and (er<>WSAEWOULDBLOCK)) then begin
        SourceAddFailedAttempt(transfer,source);
        inc(i);
        continue;
      end;

      str:=STR_BITTORRENT_PROTOCOL_HANDSHAKE+
           STR_BITTORRENT_PROTOCOL_EXTENSIONS+
           transfer.fhashvalue+
           thread_bittorrent.mypeerID;
//      ShowMessage(str);
      TCPSocket_SendBuffer(source.socket.socket,pchar(str),length(str),er);
      if er=WSAEWOULDBLOCK then begin
       inc(i);
       continue;
      end;
      if er<>0 then begin
       SourceAddFailedAttempt(transfer,source);
       inc(i);
       continue;
      end;

      source.status:=btSourceReceivingHandshake;
      source.tick:=tick;
      GlobTransfer:=transfer;
      globSource:=source;
//      synchronize(updateVisualGlobsource);
    end;

    btSourceReceivingHandshake:begin
      if (transfer.fsources.count>=50) or
         (transfer.numConnected>15) then timeint:=5000 else timeint:=TIMEOUTTCPRECEIVE;
      if tick-source.tick>timeint then begin
       SourceAddFailedAttempt(transfer,source);
       inc(i);
       continue;
      end;
      if not TCPSocket_CanRead(source.socket.socket,0,er) then begin
        if ((er<>0) and (er<>WSAEWOULDBLOCK)) then SourceAddFailedAttempt(transfer,source);
        inc(i);
        continue;
      end;

      len:=TCPSocket_RecvBuffer(source.socket.socket,@buffer,68,er);
      if er=WSAEWOULDBLOCK then begin
       inc(i);
       continue;
      end;
      if er<>0 then begin
        SourceAddFailedAttempt(transfer,source);
        inc(i);
        continue;
      end;

      SetLength(str,len);
      move(buffer,str[1],len);

      if copy(str,1,20)<>STR_BITTORRENT_PROTOCOL_HANDSHAKE then begin
        SourceAddFailedAttempt(transfer,source);
        inc(i);
        continue;
      end;

      if copy(str,29,20)<>transfer.fhashvalue then begin
       source.status:=btSourceShouldRemove;
       inc(i);
       continue;
      end;
      if length(source.id)=20 then begin
       if copy(str,49,20)<>source.id then begin

       end;
      end else begin
       source.id:=copy(str,49,20);

      end;

       ParseHandshakeReservedBytes(source,copy(str,21,8));

       source.tick:=tick;
       SourceSetConnected(source);
     
       inc(transfer.numConnected);
       //if GetShouldSendBitfield(transfer) then
       if transfer.fstate<>dlBittorrentMagnetDiscovery then SendBitField(transfer,source);
       if source.SupportsExtensions then SendPexHandshake(source);
       if (source.SupportsDHT) and (source.isNotAzureus) then SendDHTPort(source);

       globSource:=source;
       globTransfer:=transfer;
//       synchronize(updateVisualGlobsource);
    end;



    btSourceweMustSendHandshake:begin //accepted source we received her handshake, now we send ours
      if (transfer.fsources.count>=50) or
         (transfer.numConnected>15) then timeint:=5000 else timeint:=TIMEOUTTCPRECEIVE;
       if tick-source.tick>timeint then begin
        source.status:=btSourceShouldRemove;
        inc(i);
        continue;
       end;
       if not TCPSocket_CanWrite(source.socket.socket,0,er) then begin
         if ((er<>0) and (er<>WSAEWOULDBLOCK)) then begin
           source.status:=btSourceShouldRemove;
         end;
         inc(i);
         continue;
       end;
       str:=STR_BITTORRENT_PROTOCOL_HANDSHAKE+
            STR_BITTORRENT_PROTOCOL_EXTENSIONS+
            transfer.fhashvalue+
            thread_bittorrent.mypeerID;
       TCPSocket_SendBuffer(source.socket.socket,pchar(str),length(str),er);
       //ShowMessage('TCPSocket_SendBuffer');
       if er=WSAEWOULDBLOCK then begin
        inc(i);
        continue;
       end;
       if er<>0 then begin
        source.status:=btSourceShouldRemove;
        inc(i);
        continue;
       end;

       for hi:=0 to transfer.fsources.count-1 do begin
        tmpsource:=transfer.fsources[hi];
        if tmpsource=source then continue;
         if tmpsource.ipC<>source.ipC then continue;
           if tmpsource.status<>btSourceConnected then tmpsource.status:=btSourceShouldRemove
            else source.status:=btSourceShouldRemove;
         exit;
       end;


       source.tick:=tick;
       SourceSetConnected(source);

       inc(transfer.numConnected);

       GlobTransfer:=transfer;
       globSource:=source;
//       synchronize(updateVisualGlobsource);

       if transfer.fsources.count>BITTORRENT_MAX_ALLOWED_SOURCES then begin
        if not DropWorstConnectedInactiveSource(transfer,source,tick) then begin
         source.status:=btSourceShouldRemove;
         inc(i);
         continue;
        end;
       end;

       if transfer.numConnected>BITTORENT_MAXNUMBER_CONNECTION_ACCEPTED then begin //limit accepted connections
         if not DropWorstConnectedInactiveSource(transfer,source,tick) then begin
          source.status:=btSourceShouldRemove;
          inc(i);
          continue;
         end;
       end;

       //if GetShouldSendBitfield(transfer) then
      // if source.SupportsAZmessaging then SendAzHandshake(transfer,source);
        if transfer.fstate<>dlBittorrentMagnetDiscovery then SendBitField(transfer,source);
        if source.SupportsExtensions then SendPexHandshake(source);
        if (source.SupportsDHT) and (source.isNotAzureus) then SendDHTPort(source);
    end;

 end; // endof case switch

inc(i);
end;

except
end;
end;


Procedure SourceSetConnected(source:TBitTorrentSource);
begin
with source do begin
 Client:=BTIDtoClientName(ID);
 status:=btSourceConnected;
 lastKeepAliveIn:=tick;
 lastKeepAliveOut:=tick;
 isChoked:=true;
 isInterested:=false;
 weArechoked:=true;
 weAreInterested:=false;
 bytes_in_header:=0;
 recv:=0;
 sent:=0;
 bytes_recv_before:=0;
 bytes_sent_before:=0;
 speed_recv:=0;
 speed_send:=0;
 speed_recv_max:=0;
 speed_send_max:=0;
 handshakeTick:=tick;
 lastDataIn:=0;
 lastDataOut:=0;
 snubbed:=false;
 failedConnectionAttempts:=0;
end;

end;

procedure ParseHandshakeReservedBytes(source:TBittorrentSource; const extStr:string);
begin
 with source do begin
  //SupportsAZmessaging:=false;//((ord(extStr[1]) and $80) <> 0);
  SupportsExtensions:=((ord(extStr[6]) and $10) <> 0);
  SupportsFastPeer:=((ord(extStr[8]) and $04) <> 0);
  SupportsDHT:=((ord(extStr[8]) and $01) <> 0);
 end;
end;

procedure CalcNumConnected(transfer:TBitTorrentTransfer);
var
i:integer;
source:TBitTorrentSource;
begin
transfer.numConnected:=0;
for i:=0 to transfer.fsources.count-1 do begin
 source:=transfer.fsources[i];
 if source.status=btSourceConnected then inc(transfer.numConnected);
end;
end;

function GetoptimumNumOutRequests(speedRecv:cardinal):integer;
begin
if speedRecv<KBYTE then result:=1
   else
    if speedRecv<5*KBYTE then result:=2
     else
      if speedRecv<10*KBYTE then result:=3
       else
        if speedRecv<20*KBYTE then result:=4
         else
          result:=5;
end;

procedure SendBitField(transfer:TBitTorrentTransfer; source:TBitTorrentSource);
var
str:string;
begin
    {
    if source.SupportsFastPeer then begin
         if transfer.isCompleted then begin
          Source_AddOutPacket(source,'',CMD_BITTORRENT_HAVEALL);
          exit;
         end else
           if transfer.fdownloaded=0 then begin
            Source_AddOutPacket(source,'',CMD_BITTORRENT_HAVENONE);
            exit;
           end;
     end;
     }

  str:=transfer.serialize_bitfield;
  source_AddOutPacket(source,str,CMD_BITTORRENT_BITFIELD,true);
end;

procedure TThreadTransfer.SendDHTPort(source:TBitTorrentSource);
var
 portW:word;
 str:string;
begin
 portW:=vars_global.my_mdht_port;
 str:=int_2_word_stringRev(portW);
 source_AddOutPacket(source,str,CMD_BITTORRENT_DHTUDPPORT,true);
end;

procedure tthread_bitTorrent.SendDHTPort(source:TBitTorrentSource);
var
 portW:word;
 str:string;
begin
 portW:=vars_global.my_mdht_port;
 str:=int_2_word_stringRev(portW);
 source_AddOutPacket(source,str,CMD_BITTORRENT_DHTUDPPORT,true);
end;

procedure TThreadTransfer.SourceAddFailedAttempt(transfer:TBitTorrentTransfer; source:TBittorrentSource);
begin
 source.socket.free;
 source.socket:=nil;
 source.status:=btSourceIdle;
 source.inBuffer:='';
 source.bytes_in_header:=0;
 source.ClearOutBuffer;
 inc(source.failedConnectionAttempts);
 if transfer.fsources.count>=100 then begin
  source.status:=btSourceShouldRemove;
  AddBannedIP(transfer,source.ipC);
 end else begin
  if source.failedConnectionAttempts>=BT_MAXSOURCE_FAILED_ATTEMPTS then begin
   source.status:=btSourceShouldRemove;
   AddBannedIP(transfer,source.ipC);
  end;
 end;

 GlobTransfer:=transfer;
 globSource:=source;
// synchronize(updateVisualGlobsource);
end;

procedure tthread_bitTorrent.SourceAddFailedAttempt(transfer:TBitTorrentTransfer; source:TBittorrentSource);
begin
 source.socket.free;
 source.socket:=nil;
 source.status:=btSourceIdle;
 source.inBuffer:='';
 source.bytes_in_header:=0;
 source.ClearOutBuffer;
 inc(source.failedConnectionAttempts);
 if transfer.fsources.count>=100 then begin
  source.status:=btSourceShouldRemove;
  AddBannedIP(transfer,source.ipC);
 end else begin
  if source.failedConnectionAttempts>=BT_MAXSOURCE_FAILED_ATTEMPTS then begin
   source.status:=btSourceShouldRemove;
   AddBannedIP(transfer,source.ipC);
  end;
 end;

 GlobTransfer:=transfer;
 globSource:=source;
// synchronize(updateVisualGlobsource);
end;


////  **************   TRACKER   ************************************************

procedure tthread_bittorrent.checkTracker;
var
i,x:integer;
tran:tbittorrentTransfer;
tracker:tbittorrentTracker;
TrackerReady:Boolean;
begin
 for i:=0 to BitTorrentTransfers.count-1 do begin
  tran:=BitTorrentTransfers[i];

  TrackerReady:=False;
  for x:=0 to tran.trackers.count-1 do begin
    tracker:=tran.trackers[x];
    if x=tran.trackerIndex then
    begin
      if tracker.Status=bttrackerReadyUpdate then
      begin
        TrackerReady:=True;
        Break;
      end;
    end;
  end;

  for x:=0 to tran.trackers.count-1 do begin
    tracker:=tran.trackers[x];
    if (tick>=tracker.next_poll) and
    //(tracker.Status=bttrackerReadyUpdate) and
    (TrackerReady)
    then
    begin
      tran.trackerIndex:=x;
      //Break;
    end;
  end;
  checkTracker(tran);
 end;
end;

procedure tthread_bitTorrent.checkTracker(transfer:TBittorrentTransfer);
var
 tracker:tbittorrentTracker;
 er:integer;
 sin:TVarSin;
 buffer:array[0..15] of byte;
 action:cardinal;
// localsin:TSockAddrIn;
// lensin:integer;
 HostEnt: PHostEnt;
begin
try
if transfer.fstate=dlPaused then exit;
if transfer.trackers.count=0 then exit;

tracker:=transfer.trackers[transfer.trackerIndex];
if tick<tracker.next_poll then exit;

if not tracker.isudp then begin
 if tracker.socket<>nil then begin
  tracker.socket.free;
  tracker.socket:=nil;
 end;
end else begin
 if tracker.socketUDP<>INVALID_SOCKET then TCPSocket_free(tracker.socketUDP);
end;

if transfer.fErrorCode<>0 then exit;
if transfer.fstate=dlAllocating then exit;

tracker.ferror:='';
tracker.next_poll:=tick+(tracker.interval*1000)+(30000);

if tracker.isudp then begin
  tracker.UDPtranscationID:=gettickcount;

   FillChar(Sin, Sizeof(Sin), 0);
   Sin.sin_family:=AF_INET;
   Sin.sin_port:=0;
   Sin.sin_addr.s_addr:=0;
   tracker.socketUDP:=synsock.socket(PF_INET,integer(SOCK_DGRAM),IPPROTO_UDP);
   er:=synsock.Bind(tracker.socketUDP,@Sin,SizeOfVarSin(Sin));
   tracker.Status:=bttrackerUDPConnecting;

   tracker.UDPconnectionID:=0;//$41727101980;
   buffer[0]:=0;
   buffer[1]:=0;
   buffer[2]:=4;
   buffer[3]:=$17;
   buffer[4]:=$27;
   buffer[5]:=$10;
   buffer[6]:=$19;
   buffer[7]:=$80;
     action:=0;
    move(action,buffer[8],4);
    move(tracker.UDPtranscationID,buffer[12],4);
    FillChar(UDP_RemoteSin, Sizeof(UDP_RemoteSin), 0);
     UDP_RemoteSin.sin_family:=AF_INET;
     UDP_RemoteSin.sin_port:=synsock.htons(tracker.port);
     UDP_RemoteSin.sin_addr.s_addr:=synsock.inet_addr(PChar(tracker.host));
        if UDP_RemoteSin.sin_addr.s_addr=u_long(INADDR_NONE) then begin
          HostEnt:=synsock.GetHostByName(PChar(tracker.host));
          if HostEnt<>nil then begin
            UDP_RemoteSin.sin_addr.s_addr:=u_long(Pu_long(HostEnt^.h_addr_list^)^);
            tracker.host:=ipint_to_dotstring(UDP_RemoteSin.sin_addr.s_addr);

          end;
        end;
   tracker.portW:=UDP_RemoteSin.sin_port;
   tracker.ipC:=UDP_RemoteSin.sin_addr.s_addr;
   synsock.SendTo(tracker.socketUDP,buffer,16,0,@UDP_RemoteSin,SizeOf(UDP_RemoteSin));

   tracker.visualStr:=widestrtoutf8str(AddBoolString(getLangStringW(STR_CONNECTING)+' ['+tracker.url+']',(not tracker.isScraping)))+
                   widestrtoutf8str(AddBoolString('Scraping ['+GetFullScrapeURL(tracker.url)+']',tracker.isScraping));

tracker.Tick:=tick;
tracker.FError:='';
end else begin
 tracker.socket:=ttcpblocksocket.create(true);
 tracker.socket.block(false);
 assign_proxy_settings(tracker.socket);
 tracker.socket.Connect(tracker.host,inttostr(tracker.port));
 tracker.Status:=bttrackerConnecting;
end;

tracker.visualStr:=widestrtoutf8str(AddBoolString(getLangStringW(STR_CONNECTING)+' ['+tracker.url+']',(not tracker.isScraping)))+
                   widestrtoutf8str(AddBoolString('Scraping ['+GetFullScrapeURL(tracker.url)+']',tracker.isScraping));

tracker.Tick:=tick;
tracker.FError:='';

except
end;
end;

procedure tthread_bittorrent.TrackerDeal;
var
i:integer;
tran:TBittorrentTransfer; 
begin
 for i:=0 to BitTorrentTransfers.count-1 do begin
  tran:=BittorrentTransfers[i];
    TrackerDeal(tran);
 end;
end;

procedure TThreadTracker.execute;
var
//UDP_RemoteSin:TVarSin;
er,len:integer;
buffer:array[0..1023] of char;
trackerHost,trackerIDStr:string;
stream:tmemorystream;
NumWanted,indexRead:integer;

ind,ind2,contentLength:integer;
contentLengthStr:string;
headerHTTP,OutStr:string;
previous_len:integer;
//tracker:tbittorrentTracker;
UDP_buffer:array[0..16384] of byte;
len_recvd:integer;
action,transactionID,ipC:cardinal;
portW:word;
outudpstr:string;

tracker:tbittorrentTracker;
 //er:integer;
 sin:TVarSin;
 ByteBuffer:array[0..15] of byte;
 //action:cardinal;
// localsin:TSockAddrIn;
// lensin:integer;
 HostEnt: PHostEnt;
 Bittick:cardinal;
 i:Integer;

 Int64Downloaded : int64;
 Int64Delta : int64;
 Int64Uploaded : int64;
 Url:string;
begin
  FreeOnTerminate:=False;

  if transfer.trackers.count=0 then exit;
  
  tracker:=transfer.trackers[trackerIndex];

  repeat   

  repeat
  i:=1;

  
try

 EnterCriticalSection(TrackerCriticalSection);
 try
  Bittick:=gettickcount;
  
if tracker.isudp then begin

 if tracker.socketUDP=INVALID_SOCKET then
 begin
   break;//exit;
 end;
end else begin
 if tracker.socket=nil then
 begin
   break;//exit;
 end;
end;

 case tracker.Status of

   bttrackerUDPConnecting:begin
    if not TCPSocket_canRead(tracker.socketUDP,0,er) then begin
     if Bittick-tracker.Tick>TIMEOUTTCPCONNECTIONTRACKER then begin
       tracker.visualStr:='UDP Error (Timeout ACK1)';
       TCPSocket_Free(tracker.socketUDP);
       //transfer.useNextTracker;
       //tracker.Status:=bttrackerReadyUpdate;
     end;
     break;//exit;
    end;

    len:=SizeOf(UDP_RemoteSin);

     len_recvd:=synsock.RecvFrom(tracker.socketUDP,UDP_Buffer,sizeof(UDP_buffer),0,@UDP_RemoteSin,len);
     if len_recvd<16 then begin
       tracker.visualStr:='UDP Error (Size Error1)';
       TCPSocket_Free(tracker.socketUDP);
       //transfer.useNextTracker;
       //tracker.Status:=bttrackerReadyUpdate;
      break;//exit;
     end;
     move(UDP_Buffer,action,4);
     if action<>0 then begin
       tracker.visualStr:='UDP Error (Action Mismatch1)';
       TCPSocket_Free(tracker.socketUDP);
       tracker.next_poll:=Bittick+TRACKERINTERVAL_WHENFAILED;
       //transfer.useNextTracker;
       //tracker.Status:=bttrackerReadyUpdate;
       break;//exit;
     end;
     move(UDP_Buffer[4],transactionID,4);
     if tracker.UDPtranscationID<>transactionID then begin
       tracker.visualStr:='UDP Error (ID Mismatch1)';
       TCPSocket_Free(tracker.socketUDP);
       //transfer.useNextTracker;
       //tracker.Status:=bttrackerReadyUpdate;
       break;//exit;
     end;
     move(UDP_Buffer[8],tracker.UDPconnectionID,8);

     tracker.Tick:=Bittick;
     tracker.Status:=bttrackerUDPReceiving;
     tracker.UDPtranscationID:=gettickcount;

     if ((transfer.isCompleted) and
        (not Tracker.AlreadyCompleted)) then begin
           tracker.UDPevent:=reverseorder(cardinal(1)); //completed
     end else
     if (not tracker.alreadyStarted) then begin
      tracker.UDPevent:=reverseorder(cardinal(2)); // started
     end else begin
       tracker.UDPevent:=0;  //nothing new
     end;

     //log('UDPevent: '+IntToStr(tracker.UDPevent));
     
     if (transfer.fsources.count>=BITTORRENT_DONTASKMORESOURCES) and (tracker.UDPevent=0) then begin
      tracker.isScraping:=true;
      outudpstr:=int_2_qword_string(tracker.UDPconnectionID)+
                 chr(0)+chr(0)+chr(0)+chr(2)+//scrape
                 int_2_dword_string(tracker.UDPtranscationID)+
                 transfer.fhashvalue;
      log('is Scraping '+tracker.URL+': '+outudpstr);
     end else begin
      tracker.isScraping:=false;

      Int64Downloaded := (transfer.fdownloaded);
      Int64Delta := (transfer.fsize-transfer.fdownloaded);
      Int64Uploaded := (transfer.fuploaded);

      outudpstr:=int_2_qword_string(tracker.UDPconnectionID)+
                 chr(0)+chr(0)+chr(0)+chr(1)+//announce
                 int_2_dword_string(tracker.UDPtranscationID)+
                 transfer.fhashvalue+
                 mypeerID+
                 int_2_qword_string(reverseorder(Int64Downloaded))+
                 int_2_qword_string(reverseorder(Int64Delta))+
                 int_2_qword_string(reverseorder(Int64Uploaded))+
                 int_2_dword_string(tracker.UDPevent)+
                 int_2_dword_string(0)+  //ip
                 int_2_dword_string(tracker.UDPKey)+
                 int_2_dword_string(cardinal(-1))+
                 int_2_word_string(vars_global.myport);
      log('Not is Scraping '+tracker.URL+': '+outudpstr);           
     end;

     FillChar(UDP_RemoteSin, Sizeof(UDP_RemoteSin), 0);
     UDP_RemoteSin.sin_family:=AF_INET;
     UDP_RemoteSin.sin_port:=tracker.portw;
     UDP_RemoteSin.sin_addr.s_addr:=tracker.ipC;
     len:=length(outudpstr);
     move(outudpstr[1],buffer,length(outudpstr));
     synsock.SendTo(tracker.socketUDP,buffer,len,0,@UDP_RemoteSin,SizeOf(UDP_RemoteSin));
   end;

   bttrackerUDPReceiving:begin
   if not TCPSocket_canRead(tracker.socketUDP,0,er) then begin
     if Bittick-tracker.Tick>TIMEOUTTCPCONNECTIONTRACKER then begin
       tracker.visualStr:='UDP Error (Timeout ACK2)';
       TCPSocket_Free(tracker.socketUDP);
       //transfer.useNextTracker;
       //tracker.Status:=bttrackerReadyUpdate;
     end;
     break;//exit;
    end;

    len:=SizeOf(UDP_RemoteSin);

    len_recvd:=synsock.RecvFrom(tracker.socketUDP,UDP_Buffer,sizeof(UDP_buffer),0,@UDP_RemoteSin,len);
    if len_recvd<8 then begin
       tracker.visualStr:='UDP Error (Size Error2)';
       TCPSocket_Free(tracker.socketUDP);
       //transfer.useNextTracker;
       //tracker.Status:=bttrackerReadyUpdate;
      break;//exit;
     end;
     move(UDP_Buffer[4],transactionID,4);
     if tracker.UDPtranscationID<>transactionID then begin
       tracker.visualStr:='UDP Error (ID Mismatch2)';
       TCPSocket_Free(tracker.socketUDP);
       //transfer.useNextTracker;
       //tracker.Status:=bttrackerReadyUpdate;
       break;//exit;
     end; 

     move(UDP_Buffer,action,4);
     if (UDP_Buffer[0]<>0) or
        (UDP_Buffer[1]<>0) or
        (UDP_Buffer[2]<>0) or
        ((UDP_Buffer[3]<>1) and (UDP_Buffer[3]<>2))  then begin

        if UDP_Buffer[3]=3 then begin    // Error
          setLength(tracker.FError,len_recvd-8);
          move(UDP_buffer[8],tracker.FError[1],length(tracker.Ferror));
          TCPSocket_Free(tracker.socketUDP);
           tracker.visualStr:=tracker.FError;
           tracker.next_poll:=Bittick+TRACKERINTERVAL_WHENFAILED;
           //transfer.useNextTracker;
           //tracker.Status:=bttrackerReadyUpdate;
           break;//exit;
        end;

       tracker.visualStr:='UDP Error (Action Mismatch2)';
       TCPSocket_Free(tracker.socketUDP);
       //transfer.useNextTracker;
       //tracker.Status:=bttrackerReadyUpdate;
       break;//exit;
     end;
     if (UDP_Buffer[3]=1) and (len_recvd<20) then begin
       tracker.visualStr:='UDP Error (Size Error2)';
       TCPSocket_Free(tracker.socketUDP);
       //transfer.useNextTracker;
       //tracker.Status:=bttrackerReadyUpdate;
       break;//exit;
     end;    

     if (tracker.UDPevent=reverseorder(cardinal(1))) and (transfer.isCompleted) then tracker.alreadyCompleted:=true else
     if tracker.UDPevent=reverseorder(cardinal(2)) then tracker.alreadyStarted:=true;

    if UDP_Buffer[3]=1 then begin  //announcing?
     move(UDP_Buffer[8],tracker.Interval,4);
      tracker.interval:=reverseorder(tracker.interval);
     move(UDP_Buffer[12],tracker.Leechers,4);
      tracker.leechers:=reverseorder(tracker.leechers);
     move(UDP_Buffer[16],tracker.Seeders,4);
      tracker.seeders:=reverseorder(tracker.seeders);

      indexread:=20;
      while (indexRead<len_recvd) do begin
       move(UDP_buffer[indexRead],ipC,4);
       move(UDP_buffer[indexRead+4],portW,2);
       transfer.addSource(ipC,reverseorder(portW),'','UDP');
       //ShowMessage('UDP: '+IntToStr(ipC));
       inc(indexRead,6);
      end;
      
     end else begin   //scraping?
       if len_recvd>=20 then begin
        move(UDP_Buffer[8],tracker.seeders,4);
        move(UDP_Buffer[16],tracker.leechers,4);
       end;
     end;

     TCPSocket_Free(tracker.socketUDP);
     tracker.next_poll:=Bittick+(tracker.interval*1000);
     tracker.visualStr:=getLangStringW(STR_OK);
     //transfer.useNextTracker;
     //tracker.Status:=bttrackerReadyUpdate;
     break;//exit;
   end;




   bttrackerConnecting:begin
      if Bittick-tracker.Tick>TIMEOUTTCPCONNECTIONTRACKER then begin
       tracker.socket.free;
       tracker.socket:=nil;
       tracker.next_poll:=Bittick+TRACKERINTERVAL_WHENFAILED;
       tracker.visualStr:='Socket Error (Timeout)';
       //transfer.useNextTracker;
       //tracker.Status:=bttrackerReadyUpdate;
       break;//exit;
      end;
      er:=TCPSocket_ISConnected(tracker.socket);
      if er=WSAEWOULDBLOCK then break;//exit;
      if ((er<>0) and (er<>WSAEWOULDBLOCK)) then begin
        tracker.socket.free;
        tracker.socket:=nil;
        tracker.next_poll:=Bittick+TRACKERINTERVAL_WHENFAILED;
        tracker.visualStr:='Socket Error ('+inttostr(er)+')';
        //transfer.useNextTracker;
        //tracker.Status:=bttrackerReadyUpdate;
        break;//exit;
      end;

      if tracker.port<>80 then trackerHost:=tracker.host+':'+inttostr(tracker.port)
       else trackerHost:=tracker.host;

   if tracker.isScraping then begin   

   if Pos('=',tracker.Url)>0 then
   OutStr:='GET '+GetScrapePathFromUrl(tracker.Url)+'&'+
           'info_hash='+fullUrlEncode(transfer.fhashvalue)+
           ' HTTP/1.1'+CRLF+
           'User-Agent: '+const_ares.AGENT_NAME+' '+versioneares+CRLF+
           'Connection: close'+CRLF+
           'Host: '+trackerHost+CRLF+
           'Accept: text/html, */*'+CRLF+CRLF
   else
   OutStr:='GET '+GetScrapePathFromUrl(tracker.Url)+'?'+
           'info_hash='+fullUrlEncode(transfer.fhashvalue)+
           ' HTTP/1.1'+CRLF+
           'User-Agent: '+const_ares.AGENT_NAME+' '+versioneares+CRLF+
           'Connection: close'+CRLF+
           'Host: '+trackerHost+CRLF+
           'Accept: text/html, */*'+CRLF+CRLF;
           //OutStr:=StringReplace(OutStr, '.php&', '.php?', [rfReplaceAll, rfIgnoreCase]);
           //OutStr:=StringReplace(OutStr, 'scrape&', 'scrape?', [rfReplaceAll, rfIgnoreCase]);

   end else begin

       NumWanted:=TRACKER_NUMPEER_REQUESTED;
       if ((transfer.isCompleted) and
           (not Tracker.AlreadyCompleted)) then begin
           tracker.CurrTrackerEvent:='&event=completed';
       end else
        if ((tracker.alreadyStarted) or
            (tracker.alreadyCompleted)) then tracker.CurrTrackerEvent:=''
         else
          tracker.CurrTrackerEvent:='&event=started';
         if transfer.fsources.count>=BITTORRENT_MAX_ALLOWED_SOURCES then NumWanted:=0;
         
      if tracker.trackerID<>'' then trackerIDStr:='&trackerid='+tracker.trackerID
       else trackerIDStr:='';  

       Url:=tracker.Url;
   if Pos('=',Url)>0 then
   OutStr:='GET '+GetPathFromUrl(Url)+'&'+
           'info_hash='+fullUrlEncode(transfer.fhashvalue)+
           '&peer_id='+thread_bittorrent.mypeerID+
           trackerIDStr+
           '&port='+inttostr(vars_global.myport)+
           '&uploaded='+inttostr(transfer.fuploaded)+
           '&downloaded='+inttostr(transfer.fdownloaded)+
           '&left='+inttostr(transfer.fsize-transfer.fdownloaded)+
           tracker.CurrTrackerEvent+
           '&numwant='+inttostr(NumWanted)+
           '&compact=1'+
           '&key='+thread_bittorrent.myrandkey+
           ' HTTP/1.1'+CRLF+
           'User-Agent: '+const_ares.AGENT_NAME+' '+versioneares+CRLF+
           'Connection: close'+CRLF+
           'Host: '+trackerHost+CRLF+
           'Accept: text/html, */*'+CRLF+CRLF
   else
   OutStr:='GET '+GetPathFromUrl(Url)+'?'+
           'info_hash='+fullUrlEncode(transfer.fhashvalue)+
           '&peer_id='+thread_bittorrent.mypeerID+
           trackerIDStr+
           '&port='+inttostr(vars_global.myport)+
           '&uploaded='+inttostr(transfer.fuploaded)+
           '&downloaded='+inttostr(transfer.fdownloaded)+
           '&left='+inttostr(transfer.fsize-transfer.fdownloaded)+
           tracker.CurrTrackerEvent+
           '&numwant='+inttostr(NumWanted)+
           '&compact=1'+
           '&key='+thread_bittorrent.myrandkey+
           ' HTTP/1.1'+CRLF+
           'User-Agent: '+const_ares.AGENT_NAME+' '+versioneares+CRLF+
           'Connection: close'+CRLF+
           'Host: '+trackerHost+CRLF+
           'Accept: text/html, */*'+CRLF+CRLF;
           //OutStr:=StringReplace(OutStr, '.php&', '.php?', [rfReplaceAll, rfIgnoreCase]);
           //OutStr:=StringReplace(OutStr, 'announce&', 'announce?', [rfReplaceAll, rfIgnoreCase]);
     end;
        


        TCPSocket_SendBuffer(tracker.socket.socket,pchar(OutStr),length(OutStr),er);
        if er=WSAEWOULDBLOCK then begin
         break;//exit;
        end;
        if er<>0 then begin
          tracker.socket.free;
          tracker.socket:=nil;
          tracker.next_poll:=Bittick+TRACKERINTERVAL_WHENFAILED;
          tracker.visualStr:='Socket Error ('+inttostr(er)+')';
          //transfer.useNextTracker;
          //tracker.Status:=bttrackerReadyUpdate;
          break;//exit;
        end;
      tracker.BufferReceive:='';
      tracker.Tick:=Bittick;
      tracker.Status:=bttrackerReceiving;
   end;

   bttrackerReceiving:begin
         if Bittick-tracker.Tick>TIMEOUTTCPRECEIVETRACKER then begin
          tracker.socket.free;
          tracker.socket:=nil;
          tracker.next_poll:=Bittick+TRACKERINTERVAL_WHENFAILED;
          tracker.visualStr:='Socket Error (Timeout)';
          //transfer.useNextTracker;
          //tracker.Status:=bttrackerReadyUpdate;
          break;//exit;
         end;
         if not TCPSocket_CanRead(tracker.socket.socket,0,er) then begin
           if ((er<>0) and (er<>WSAEWOULDBLOCK)) then begin
             tracker.socket.free;
             tracker.socket:=nil;
             tracker.next_poll:=Bittick+TRACKERINTERVAL_WHENFAILED;
             tracker.visualStr:='Socket Error ('+inttostr(er)+')';
             //transfer.useNextTracker;
             //tracker.Status:=bttrackerReadyUpdate;
           end;
           break;//exit;
         end;
         len:=TCPSocket_RecvBuffer(tracker.socket.socket,@buffer,sizeof(buffer),er);
          if er=WSAEWOULDBLOCK then break;//exit;
          if er<>0 then begin
             tracker.socket.free;
             tracker.socket:=nil;
             tracker.next_poll:=Bittick+TRACKERINTERVAL_WHENFAILED;
             tracker.visualStr:='Socket Error ('+inttostr(er)+')';
             //transfer.useNextTracker;
             //tracker.Status:=bttrackerReadyUpdate;
             break;//exit;
          end;
          if len=0 then begin
             tracker.socket.free;
             tracker.socket:=nil;
             tracker.next_poll:=Bittick+TRACKERINTERVAL_WHENFAILED;
             tracker.visualStr:='Socket Error';
             //transfer.useNextTracker;
             //tracker.Status:=bttrackerReadyUpdate;
             break;//exit;
          end;

         tracker.Tick:=Bittick;
         
         previous_len:=length(tracker.BufferReceive);
         Setlength(tracker.BufferReceive,previous_len+len);

         move(buffer,tracker.BufferReceive[previous_len+1],len);

         ind:=pos(CRLF+CRLF,tracker.BufferReceive);
         if ind>0 then begin
           headerHTTP:=copy(tracker.BufferReceive,1,ind-1);


           ind2:=pos('content-length:',lowercase(headerHTTP));
           if ind2>0 then begin   // do we have 'Content-Length:' ?
             contentLengthStr:=copy(headerHttp,ind2+15,length(headerHTTP));
             contentLengthStr:=trim(copy(contentLengthStr,1,pos(CRLF,contentLengthStr)-1));
             contentLength:=strtointDef(contentLengthStr,0);
               if contentLength+length(headerHttp)>length(tracker.BufferReceive) then begin// not enough
                 break;//exit;
               end;
           end;

           delete(tracker.BufferReceive,1,ind+3);
         end else begin

         if ((pos('HTTP',tracker.BufferReceive)=1) and (pos(' 200 OK'+chr(10),tracker.BufferReceive)>0)) then begin
          delete(tracker.BufferReceive,1,pos(chr(10)+chr(10),tracker.BufferReceive)+1);
         end;

         end;

       if length(tracker.BufferReceive)>0 then begin
         stream:=tmemorystream.create;
         try
          stream.Write(tracker.BufferReceive[1],length(tracker.BufferReceive));
          stream.position:=0;
          if not tracker.isScraping then tracker.Load(stream)
           else tracker.parseScrape(stream);
         finally
           stream.free;
         end;
       end;

       tracker.BufferReceive:='';
       tracker.socket.free;
       tracker.socket:=nil;

        if not tracker.isScraping then begin //it was a regular announce request
         if transfer.fsources.count>BITTORRENT_MAX_ALLOWED_SOURCES then DropOlderIdleSources(transfer);

         tracker.visualStr:=getLangStringW(STR_OK)+AddBoolString(' '+utf8strtowidestr(copy(tracker.WarningMessage,1,100)),length(tracker.WarningMessage)>0);
         tracker.next_poll:=Bittick+(tracker.interval*1000);
         
         if length(tracker.FError)>0 then begin
           tracker.visualStr:=tracker.FError;
           
           
          end else begin
            if tracker.CurrTrackerEvent='&event=started' then tracker.alreadyStarted:=true
             else
              if tracker.CurrTrackerEvent='&event=completed' then tracker.alreadyCompleted:=true;
            if ((tracker.seeders=0) and
                (tracker.leechers=0) and
                (tracker.SupportScrape)) then begin

                           tracker.isScraping:=true;
                           tracker.next_poll:=0;
                           end;

          end;
          //transfer.useNextTracker;
          //tracker.Status:=bttrackerReadyUpdate;
        end else begin  // was scraping....
         tracker.visualStr:=getLangStringW(STR_OK)+AddBoolString(' '+utf8strtowidestr(copy(tracker.WarningMessage,1,100)),length(tracker.WarningMessage)>0);
         tracker.isScraping:=false;
         tracker.next_poll:=Bittick+(tracker.interval*1000);
          if length(tracker.FError)>0 then tracker.visualStr:=tracker.FError;
         //transfer.useNextTracker;
         //tracker.Status:=bttrackerReadyUpdate;
        end;


   end;

 end;

 finally
   LeaveCriticalSection(TrackerCriticalSection);
 end;

 except
 end;

    until i=1;




try
if transfer.fstate=dlPaused then else//exit;
if transfer.trackers.count=0 then else//exit;

//tracker:=transfer.trackers[trackerIndex];
if Bittick<tracker.next_poll then else//exit;
begin
if not tracker.isudp then begin
     if tracker.socket<>nil then begin
  tracker.socket.free;
  tracker.socket:=nil;
 end;
end else begin
 if tracker.socketUDP<>INVALID_SOCKET then TCPSocket_free(tracker.socketUDP);
end;

if transfer.fErrorCode<>0 then else//exit;
if transfer.fstate=dlAllocating then else//exit;

   begin
tracker.ferror:='';
tracker.next_poll:=Bittick+(tracker.interval*1000)+(30000);

if tracker.isudp then begin
  EnterCriticalSection(TrackerCriticalSection);
  try
  tracker.UDPtranscationID:=gettickcount;

   FillChar(Sin, Sizeof(Sin), 0);
   Sin.sin_family:=AF_INET;
   Sin.sin_port:=0;
   Sin.sin_addr.s_addr:=0;
   tracker.socketUDP:=synsock.socket(PF_INET,integer(SOCK_DGRAM),IPPROTO_UDP);
   er:=synsock.Bind(tracker.socketUDP,@Sin,SizeOfVarSin(Sin));
   tracker.Status:=bttrackerUDPConnecting;

   tracker.UDPconnectionID:=0;//$41727101980;
   ByteBuffer[0]:=0;
   ByteBuffer[1]:=0;
   ByteBuffer[2]:=4;
   ByteBuffer[3]:=$17;
   ByteBuffer[4]:=$27;
   ByteBuffer[5]:=$10;
   ByteBuffer[6]:=$19;
   ByteBuffer[7]:=$80;
     action:=0;
    move(action,ByteBuffer[8],4);
    move(tracker.UDPtranscationID,ByteBuffer[12],4);
    FillChar(UDP_RemoteSin, Sizeof(UDP_RemoteSin), 0);
     UDP_RemoteSin.sin_family:=AF_INET;
     UDP_RemoteSin.sin_port:=synsock.htons(tracker.port);
     UDP_RemoteSin.sin_addr.s_addr:=synsock.inet_addr(PChar(tracker.host));
        if UDP_RemoteSin.sin_addr.s_addr=u_long(INADDR_NONE) then begin
          HostEnt:=synsock.GetHostByName(PChar(tracker.host));
          if HostEnt<>nil then begin
            UDP_RemoteSin.sin_addr.s_addr:=u_long(Pu_long(HostEnt^.h_addr_list^)^);
            tracker.host:=ipint_to_dotstring(UDP_RemoteSin.sin_addr.s_addr);
            
          end;
        end;
   tracker.portW:=UDP_RemoteSin.sin_port;
   tracker.ipC:=UDP_RemoteSin.sin_addr.s_addr;
   finally
     LeaveCriticalSection(TrackerCriticalSection);
   end;
   synsock.SendTo(tracker.socketUDP,ByteBuffer,16,0,@UDP_RemoteSin,SizeOf(UDP_RemoteSin));
   
end else begin
 EnterCriticalSection(TrackerCriticalSection);
 try
 tracker.socket:=ttcpblocksocket.create(true);
 tracker.socket.block(false);
 //assign_proxy_settings(tracker.socket);

 if vars_global.socks_type=SocTNone then begin
  tracker.socket.SocksIP:='';
  tracker.socket.SocksPort:='0';
 end else begin
  tracker.socket.FLastTime:=gettickcount; //per vari timeout in TCPSocket_connesso()
  tracker.socket.SocksIp:=vars_global.socks_ip;
  tracker.socket.SocksPort:=inttostr(vars_global.socks_port);
  if vars_global.socks_type=SocTSock5 then begin
    tracker.socket.SocksType:=ST_Socks5;
    tracker.socket.SocksUsername:=vars_global.socks_username;
    tracker.socket.SocksPassword:=vars_global.socks_password;
  end else tracker.socket.SocksType:=ST_Socks4;
  tracker.socket.FStatoConn:=PROXY_InConnessione;
 end;
 finally
   LeaveCriticalSection(TrackerCriticalSection);
 end;
 tracker.socket.Connect(tracker.host,inttostr(tracker.port));
 EnterCriticalSection(TrackerCriticalSection);
 try
 tracker.Status:=bttrackerConnecting;
 finally
   LeaveCriticalSection(TrackerCriticalSection);
 end;


end;

 EnterCriticalSection(TrackerCriticalSection);
 try
 Url:=tracker.url;
 tracker.visualStr:=widestrtoutf8str(AddBoolString(getLangStringW(STR_CONNECTING)+' ['+url+']',(not tracker.isScraping)))+
                    widestrtoutf8str(AddBoolString('Scraping ['+GetFullScrapeURL(url)+']',tracker.isScraping));
 finally
   LeaveCriticalSection(TrackerCriticalSection);
 end;


tracker.Tick:=Bittick;
tracker.FError:='';

   end;
   end;

   if not Terminated then
   Sleep(1000);

except
end;

  Until Terminated;
  //tracker.Free;
end;

procedure tthread_bitTorrent.TrackerDeal(transfer:tbittorrentTransfer);
var
er,len:integer;
buffer:array[0..1023] of char;
trackerHost,trackerIDStr:string;
stream:tmemorystream;
NumWanted,indexRead:integer;

ind,ind2,contentLength:integer;
contentLengthStr:string;
headerHTTP,OutStr:string;
previous_len:integer;
tracker:tbittorrentTracker;
UDP_buffer:array[0..16384] of byte;
len_recvd:integer;
action,transactionID,ipC:cardinal;
portW:word;
outudpstr:string;
begin
  //ShowMessage('TrackerDeal Started '+transfer.fname+'/'+transfer.fhashvalue);
try
//Form1.Memo2.Lines.Add('TrackerDeal '+IntToStr(transfer.trackerIndex));
// showmessage(IntToStr(transfer.trackers.count));
if transfer.trackers.count=0 then exit;
//ShowMessage('TrackerDeal Started22 '+transfer.fname+'/'+transfer.fhashvalue);
tracker:=transfer.trackers[transfer.trackerIndex];
//Form1.Memo2.Lines.Add('TrackerDeal '+IntToStr(transfer.trackerIndex));
if tracker.isudp then begin

 if tracker.socketUDP=INVALID_SOCKET then
 begin
   exit;
 end;
end else begin  
 if tracker.socket=nil then
 begin
   exit;
 end;
end;

 case tracker.Status of

   bttrackerUDPConnecting:begin
    if not TCPSocket_canRead(tracker.socketUDP,0,er) then begin
     if tick-tracker.Tick>TIMEOUTTCPCONNECTIONTRACKER then begin
       tracker.visualStr:='UDP Error (Timeout ACK1)';
       TCPSocket_Free(tracker.socketUDP);
       transfer.useNextTracker;
       tracker.Status:=bttrackerReadyUpdate;
     end;
     exit;
    end;

    len:=SizeOf(UDP_RemoteSin);

     len_recvd:=synsock.RecvFrom(tracker.socketUDP,UDP_Buffer,sizeof(UDP_buffer),0,@UDP_RemoteSin,len);
     if len_recvd<16 then begin
       tracker.visualStr:='UDP Error (Size Error1)';
       TCPSocket_Free(tracker.socketUDP);
       transfer.useNextTracker;
       tracker.Status:=bttrackerReadyUpdate;
      exit;
     end;
     move(UDP_Buffer,action,4);
     if action<>0 then begin
       tracker.visualStr:='UDP Error (Action Mismatch1)';
       TCPSocket_Free(tracker.socketUDP);
       tracker.next_poll:=tick+TRACKERINTERVAL_WHENFAILED;
       transfer.useNextTracker;
       tracker.Status:=bttrackerReadyUpdate;
       exit;
     end;
     move(UDP_Buffer[4],transactionID,4);
     if tracker.UDPtranscationID<>transactionID then begin
       tracker.visualStr:='UDP Error (ID Mismatch1)';
       TCPSocket_Free(tracker.socketUDP);
       transfer.useNextTracker;
       tracker.Status:=bttrackerReadyUpdate;
       exit;
     end;
     move(UDP_Buffer[8],tracker.UDPconnectionID,8);

     tracker.Tick:=tick;
     tracker.Status:=bttrackerUDPReceiving;
     tracker.UDPtranscationID:=gettickcount;

     if ((transfer.isCompleted) and
        (not Tracker.AlreadyCompleted)) then begin
           tracker.UDPevent:=reverseorder(cardinal(1)); //completed
     end else
     if (not tracker.alreadyStarted) then begin
      tracker.UDPevent:=reverseorder(cardinal(2)); // started
     end else begin
       tracker.UDPevent:=0;  //nothing new
     end;

     //ShowMessage('TrackerDeal Started3 '+transfer.fname);
     
     if (transfer.fsources.count>=BITTORRENT_DONTASKMORESOURCES) and (tracker.UDPevent=0) then begin
      tracker.isScraping:=true;
      outudpstr:=int_2_qword_string(tracker.UDPconnectionID)+
                 chr(0)+chr(0)+chr(0)+chr(2)+//scrape
                 int_2_dword_string(tracker.UDPtranscationID)+
                 transfer.fhashvalue;
      //log('is Scraping '+tracker.URL+': '+outudpstr);
     end else begin
      tracker.isScraping:=false;
      outudpstr:=int_2_qword_string(tracker.UDPconnectionID)+
                 chr(0)+chr(0)+chr(0)+chr(1)+//announce
                 int_2_dword_string(tracker.UDPtranscationID)+
                 transfer.fhashvalue+
                 mypeerID+
                 int_2_qword_string(reverseorder(int64(transfer.fdownloaded)))+
                 int_2_qword_string(reverseorder(int64(transfer.fsize-transfer.fdownloaded)))+
                 int_2_qword_string(reverseorder(int64(transfer.fuploaded)))+
                 int_2_dword_string(tracker.UDPevent)+
                 int_2_dword_string(0)+  //ip
                 int_2_dword_string(tracker.UDPKey)+
                 int_2_dword_string(cardinal(-1))+
                 int_2_word_string(vars_global.myport);
      //log('Not is Scraping '+tracker.URL+': '+outudpstr);
     end;

     FillChar(UDP_RemoteSin, Sizeof(UDP_RemoteSin), 0);
     UDP_RemoteSin.sin_family:=AF_INET;
     UDP_RemoteSin.sin_port:=tracker.portw;
     UDP_RemoteSin.sin_addr.s_addr:=tracker.ipC;
     len:=length(outudpstr);
     move(outudpstr[1],buffer,length(outudpstr));
     synsock.SendTo(tracker.socketUDP,buffer,len,0,@UDP_RemoteSin,SizeOf(UDP_RemoteSin));
   end;

   bttrackerUDPReceiving:begin
   if not TCPSocket_canRead(tracker.socketUDP,0,er) then begin
     if tick-tracker.Tick>TIMEOUTTCPCONNECTIONTRACKER then begin
       tracker.visualStr:='UDP Error (Timeout ACK2)';
       TCPSocket_Free(tracker.socketUDP);
       transfer.useNextTracker;
       tracker.Status:=bttrackerReadyUpdate;
     end;
     exit;
    end;

    len:=SizeOf(UDP_RemoteSin);

    len_recvd:=synsock.RecvFrom(tracker.socketUDP,UDP_Buffer,sizeof(UDP_buffer),0,@UDP_RemoteSin,len);
    if len_recvd<8 then begin
       tracker.visualStr:='UDP Error (Size Error2)';
       TCPSocket_Free(tracker.socketUDP);
       transfer.useNextTracker;
       tracker.Status:=bttrackerReadyUpdate;
      exit;
     end;
     move(UDP_Buffer[4],transactionID,4);
     if tracker.UDPtranscationID<>transactionID then begin
       tracker.visualStr:='UDP Error (ID Mismatch2)';
       TCPSocket_Free(tracker.socketUDP);
       transfer.useNextTracker;
       tracker.Status:=bttrackerReadyUpdate;
       exit;
     end;     

     move(UDP_Buffer,action,4);
     if (UDP_Buffer[0]<>0) or
        (UDP_Buffer[1]<>0) or
        (UDP_Buffer[2]<>0) or
        ((UDP_Buffer[3]<>1) and (UDP_Buffer[3]<>2))  then begin

        if UDP_Buffer[3]=3 then begin    // Error
          setLength(tracker.FError,len_recvd-8);
          move(UDP_buffer[8],tracker.FError[1],length(tracker.Ferror));
          TCPSocket_Free(tracker.socketUDP);
           tracker.visualStr:=tracker.FError;
           tracker.next_poll:=tick+TRACKERINTERVAL_WHENFAILED;
           transfer.useNextTracker;
           tracker.Status:=bttrackerReadyUpdate;
           exit;
        end;

       tracker.visualStr:='UDP Error (Action Mismatch2)';
       TCPSocket_Free(tracker.socketUDP);
       transfer.useNextTracker;
       tracker.Status:=bttrackerReadyUpdate;
       exit;
     end;
     if (UDP_Buffer[3]=1) and (len_recvd<20) then begin
       tracker.visualStr:='UDP Error (Size Error2)';
       TCPSocket_Free(tracker.socketUDP);
       transfer.useNextTracker;
       tracker.Status:=bttrackerReadyUpdate;
       exit;
     end;  

     if (tracker.UDPevent=reverseorder(cardinal(1))) and (transfer.isCompleted) then tracker.alreadyCompleted:=true else
     if tracker.UDPevent=reverseorder(cardinal(2)) then tracker.alreadyStarted:=true;

    if UDP_Buffer[3]=1 then begin  //announcing?
     move(UDP_Buffer[8],tracker.Interval,4);
      tracker.interval:=reverseorder(tracker.interval);
     move(UDP_Buffer[12],tracker.Leechers,4);
      tracker.leechers:=reverseorder(tracker.leechers);
     move(UDP_Buffer[16],tracker.Seeders,4);
      tracker.seeders:=reverseorder(tracker.seeders);

      indexread:=20;
      while (indexRead<len_recvd) do begin
       move(UDP_buffer[indexRead],ipC,4);
       move(UDP_buffer[indexRead+4],portW,2);
       transfer.addSource(ipC,reverseorder(portW),'','UDP');
       //ShowMessage('UDP: '+IntToStr(ipC));
       inc(indexRead,6);
      end;
      
     end else begin   //scraping?
       if len_recvd>=20 then begin
        move(UDP_Buffer[8],tracker.seeders,4);
        move(UDP_Buffer[16],tracker.leechers,4);
       end;
     end;

     TCPSocket_Free(tracker.socketUDP);
     tracker.next_poll:=tick+(tracker.interval*1000);
     tracker.visualStr:=getLangStringW(STR_OK);
     transfer.useNextTracker;
     tracker.Status:=bttrackerReadyUpdate;
     exit;
   end;




   bttrackerConnecting:begin
      if tick-tracker.Tick>TIMEOUTTCPCONNECTIONTRACKER then begin
       tracker.socket.free;
       tracker.socket:=nil;
       tracker.next_poll:=tick+TRACKERINTERVAL_WHENFAILED;
       tracker.visualStr:='Socket Error (Timeout)';
       transfer.useNextTracker;
       tracker.Status:=bttrackerReadyUpdate;
       exit;
      end;
      er:=TCPSocket_ISConnected(tracker.socket);
      if er=WSAEWOULDBLOCK then exit;
      if ((er<>0) and (er<>WSAEWOULDBLOCK)) then begin
        tracker.socket.free;
        tracker.socket:=nil;
        tracker.next_poll:=tick+TRACKERINTERVAL_WHENFAILED;
        tracker.visualStr:='Socket Error ('+inttostr(er)+')';
        transfer.useNextTracker;
        tracker.Status:=bttrackerReadyUpdate;
        exit;
      end;

      if tracker.port<>80 then trackerHost:=tracker.host+':'+inttostr(tracker.port)
       else trackerHost:=tracker.host;

   if tracker.isScraping then begin
   if Pos('=',tracker.Url)>0 then
   OutStr:='GET '+GetScrapePathFromUrl(tracker.Url)+'&'+
           'info_hash='+fullUrlEncode(transfer.fhashvalue)+
           ' HTTP/1.1'+CRLF+
           'User-Agent: '+const_ares.AGENT_NAME+' '+versioneares+CRLF+
           'Connection: close'+CRLF+
           'Host: '+trackerHost+CRLF+
           'Accept: text/html, */*'+CRLF+CRLF
   else
   OutStr:='GET '+GetScrapePathFromUrl(tracker.Url)+'?'+
           'info_hash='+fullUrlEncode(transfer.fhashvalue)+
           ' HTTP/1.1'+CRLF+
           'User-Agent: '+const_ares.AGENT_NAME+' '+versioneares+CRLF+
           'Connection: close'+CRLF+
           'Host: '+trackerHost+CRLF+
           'Accept: text/html, */*'+CRLF+CRLF;
           //OutStr:=StringReplace(OutStr, '.php&', '.php?', [rfReplaceAll, rfIgnoreCase]);
           //OutStr:=StringReplace(OutStr, 'scrape&', 'scrape?', [rfReplaceAll, rfIgnoreCase]);
   end else begin

       NumWanted:=TRACKER_NUMPEER_REQUESTED;
       if ((transfer.isCompleted) and
           (not Tracker.AlreadyCompleted)) then begin
           tracker.CurrTrackerEvent:='&event=completed';
       end else
        if ((tracker.alreadyStarted) or
            (tracker.alreadyCompleted)) then tracker.CurrTrackerEvent:=''
         else
          tracker.CurrTrackerEvent:='&event=started';
         if transfer.fsources.count>=BITTORRENT_MAX_ALLOWED_SOURCES then NumWanted:=0;
         
      if tracker.trackerID<>'' then trackerIDStr:='&trackerid='+tracker.trackerID
       else trackerIDStr:='';
   if Pos('=',tracker.Url)>0 then
   OutStr:='GET '+GetPathFromUrl(tracker.Url)+'&'+
           'info_hash='+fullUrlEncode(transfer.fhashvalue)+
           '&peer_id='+thread_bittorrent.mypeerID+
           trackerIDStr+
           '&port='+inttostr(vars_global.myport)+
           '&uploaded='+inttostr(transfer.fuploaded)+
           '&downloaded='+inttostr(transfer.fdownloaded)+
           '&left='+inttostr(transfer.fsize-transfer.fdownloaded)+
           tracker.CurrTrackerEvent+
           '&numwant='+inttostr(NumWanted)+
           '&compact=1'+
           '&key='+thread_bittorrent.myrandkey+
           ' HTTP/1.1'+CRLF+
           'User-Agent: '+const_ares.AGENT_NAME+' '+versioneares+CRLF+
           'Connection: close'+CRLF+
           'Host: '+trackerHost+CRLF+
           'Accept: text/html, */*'+CRLF+CRLF
   else
   OutStr:='GET '+GetPathFromUrl(tracker.Url)+'?'+
           'info_hash='+fullUrlEncode(transfer.fhashvalue)+
           '&peer_id='+thread_bittorrent.mypeerID+
           trackerIDStr+
           '&port='+inttostr(vars_global.myport)+
           '&uploaded='+inttostr(transfer.fuploaded)+
           '&downloaded='+inttostr(transfer.fdownloaded)+
           '&left='+inttostr(transfer.fsize-transfer.fdownloaded)+
           tracker.CurrTrackerEvent+
           '&numwant='+inttostr(NumWanted)+
           '&compact=1'+
           '&key='+thread_bittorrent.myrandkey+
           ' HTTP/1.1'+CRLF+
           'User-Agent: '+const_ares.AGENT_NAME+' '+versioneares+CRLF+
           'Connection: close'+CRLF+
           'Host: '+trackerHost+CRLF+
           'Accept: text/html, */*'+CRLF+CRLF;
           //OutStr:=StringReplace(OutStr, '.php&', '.php?', [rfReplaceAll, rfIgnoreCase]);
           //OutStr:=StringReplace(OutStr, 'announce&', 'announce?', [rfReplaceAll, rfIgnoreCase]);
     end;


        TCPSocket_SendBuffer(tracker.socket.socket,pchar(OutStr),length(OutStr),er);
        if er=WSAEWOULDBLOCK then begin
         exit;
        end;
        if er<>0 then begin
          tracker.socket.free;
          tracker.socket:=nil;
          tracker.next_poll:=tick+TRACKERINTERVAL_WHENFAILED;
          tracker.visualStr:='Socket Error ('+inttostr(er)+')';
          transfer.useNextTracker;
          tracker.Status:=bttrackerReadyUpdate;
          exit;
        end;
      tracker.BufferReceive:='';
      tracker.Tick:=tick;
      tracker.Status:=bttrackerReceiving;
   end;

   bttrackerReceiving:begin
         if tick-tracker.Tick>TIMEOUTTCPRECEIVETRACKER then begin
          tracker.socket.free;
          tracker.socket:=nil;
          tracker.next_poll:=tick+TRACKERINTERVAL_WHENFAILED;
          tracker.visualStr:='Socket Error (Timeout)';
          transfer.useNextTracker;
          tracker.Status:=bttrackerReadyUpdate;
          exit;
         end;
         if not TCPSocket_CanRead(tracker.socket.socket,0,er) then begin
           if ((er<>0) and (er<>WSAEWOULDBLOCK)) then begin
             tracker.socket.free;
             tracker.socket:=nil;
             tracker.next_poll:=tick+TRACKERINTERVAL_WHENFAILED;
             tracker.visualStr:='Socket Error ('+inttostr(er)+')';
             transfer.useNextTracker;
             tracker.Status:=bttrackerReadyUpdate;
           end;
           exit;
         end;
         len:=TCPSocket_RecvBuffer(tracker.socket.socket,@buffer,sizeof(buffer),er);
          if er=WSAEWOULDBLOCK then exit;
          if er<>0 then begin
             tracker.socket.free;
             tracker.socket:=nil;
             tracker.next_poll:=tick+TRACKERINTERVAL_WHENFAILED;
             tracker.visualStr:='Socket Error ('+inttostr(er)+')';
             transfer.useNextTracker;
             tracker.Status:=bttrackerReadyUpdate;
             exit;
          end;
          if len=0 then begin
             tracker.socket.free;
             tracker.socket:=nil;
             tracker.next_poll:=tick+TRACKERINTERVAL_WHENFAILED;
             tracker.visualStr:='Socket Error';
             transfer.useNextTracker;
             tracker.Status:=bttrackerReadyUpdate;
             exit;
          end;

         tracker.Tick:=tick;
         
         previous_len:=length(tracker.BufferReceive);
         Setlength(tracker.BufferReceive,previous_len+len);

         move(buffer,tracker.BufferReceive[previous_len+1],len);

         ind:=pos(CRLF+CRLF,tracker.BufferReceive);
         if ind>0 then begin
           headerHTTP:=copy(tracker.BufferReceive,1,ind-1);


           ind2:=pos('content-length:',lowercase(headerHTTP));
           if ind2>0 then begin   // do we have 'Content-Length:' ?
             contentLengthStr:=copy(headerHttp,ind2+15,length(headerHTTP));
             contentLengthStr:=trim(copy(contentLengthStr,1,pos(CRLF,contentLengthStr)-1));
             contentLength:=strtointDef(contentLengthStr,0);
               if contentLength+length(headerHttp)>length(tracker.BufferReceive) then begin// not enough
                 exit;
               end;
           end;

           delete(tracker.BufferReceive,1,ind+3);
         end else begin

         if ((pos('HTTP',tracker.BufferReceive)=1) and (pos(' 200 OK'+chr(10),tracker.BufferReceive)>0)) then begin
          delete(tracker.BufferReceive,1,pos(chr(10)+chr(10),tracker.BufferReceive)+1);
         end;

         end;

       if length(tracker.BufferReceive)>0 then begin
         stream:=tmemorystream.create;
          stream.Write(tracker.BufferReceive[1],length(tracker.BufferReceive));
          stream.position:=0;
          if not tracker.isScraping then tracker.Load(stream)
           else tracker.parseScrape(stream);
         stream.free;
       end;

       tracker.BufferReceive:='';
       tracker.socket.free;
       tracker.socket:=nil;

        if not tracker.isScraping then begin //it was a regular announce request
         if transfer.fsources.count>BITTORRENT_MAX_ALLOWED_SOURCES then DropOlderIdleSources(transfer);

         tracker.visualStr:=getLangStringW(STR_OK)+AddBoolString(' '+utf8strtowidestr(copy(tracker.WarningMessage,1,100)),length(tracker.WarningMessage)>0);
         tracker.next_poll:=tick+(tracker.interval*1000);         
         
         if length(tracker.FError)>0 then begin
           tracker.visualStr:=tracker.FError;
           
           
          end else begin
            if tracker.CurrTrackerEvent='&event=started' then tracker.alreadyStarted:=true
             else
              if tracker.CurrTrackerEvent='&event=completed' then tracker.alreadyCompleted:=true;
            if ((tracker.seeders=0) and
                (tracker.leechers=0) and
                (tracker.SupportScrape)) then begin

                           tracker.isScraping:=true;
                           tracker.next_poll:=0;
                           end;

          end;
          transfer.useNextTracker;
          tracker.Status:=bttrackerReadyUpdate;
        end else begin  // was scraping....
         tracker.visualStr:=getLangStringW(STR_OK)+AddBoolString(' '+utf8strtowidestr(copy(tracker.WarningMessage,1,100)),length(tracker.WarningMessage)>0);
         tracker.isScraping:=false;
         tracker.next_poll:=tick+(tracker.interval*1000);
          if length(tracker.FError)>0 then tracker.visualStr:=tracker.FError;
         transfer.useNextTracker;
         tracker.Status:=bttrackerReadyUpdate;
        end;


   end;

 end;

 except
 end;
end;

procedure DropOlderIdleSources(transfer:TBitTorrentTransfer);
var
i:integer;
source:TBitTorrentSource;
begin
transfer.fsources.sort(SortSourcesOlderFirst);

i:=0;


while ((i<transfer.fsources.count) and
       (transfer.fsources.count>BITTORRENT_MAX_ALLOWED_SOURCES)) do begin
 source:=transfer.fsources[i];

 if source.status<>btSourceIdle then begin
  inc(i);
  continue;
 end;

 if source.handshakeTick=0 then begin //leave room for newest sources
  inc(i);
  continue;
 end;

 source.status:=btSourceShouldRemove;

 inc(i);
end;

end;

///// *****************************************************************************************

procedure TThreadTracker.log(txt:string);
begin
outputdebugstring(pchar(formatdatetime('hh:nn:ss',now)+'> '+txt));
end;

procedure TThreadTransfer.log(txt:string);
begin
outputdebugstring(pchar(formatdatetime('hh:nn:ss',now)+'> '+txt));
end;

procedure tthread_bitTorrent.log(txt:string);
begin
outputdebugstring(pchar(formatdatetime('hh:nn:ss',now)+'> '+txt));
end;




end.
