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
application structures are listed here
}

unit ares_types;

interface

uses
 Windows, Classes, SysUtils, blcksock, Graphics,
 classes2,
// comettrees,TntMenus,tntforms,WinSplit,xpbutton,
// tntcomctrls,tntstdctrls,tntbuttons,tntextctrls,comettopicpnl,cometPageView,
 DirectDraw,ares_objects, extctrls;


  type
  tdatanodetype=(dnt_Null,
                 dnt_download,
                 dnt_PartialUpload,
                 dnt_PartialDownload,
                 dnt_downloadSource,
                 dnt_upload,
                 dnt_bittorrentMain,
                 dnt_bittorrentSource);
  type
  precord_data_node=^record_data_node;
  record_data_node=record
   m_type:tdatanodetype;
   data:pointer;
  end;
  
  type
  targuments=array of string;

  type
  precord_relayed_chat_form=^record_relayed_chat_form;
  record_relayed_chat_form=record
   frm:pointer;
   supernode:pointer;
   id:cardinal;
   packetsout:tmystringlist;
   packetin:tmystringlist;
   disconnected:boolean;
   windowclosed:boolean;
   hasnotifyclose_toremotepeer:boolean;
  end;

  type
  precord_httpheader_item=^record_httpheader_item;
  record_httpheader_item=record
  key:string;
  value:string;
  end;

  type  //GUI tab status
  tstato_tab_gui=(GUI_Web,
                  GUI_Library,
                  GUI_Screen,
                  GUI_Search,
                  GUI_Transfer,
                  GUI_Chat,
                  GUI_Options);


  type  // string structure for library categs
precord_string=^record_string;
record_string=record
 str:string;
 counter:integer;
 crc:word;
 len:byte;
end;
  
 type  // private chat, connect to user's supernode and ask for a reverse (push) connection back to us
 precord_pushed_chat_request=^record_pushed_chat_request;
 record_pushed_chat_request=record
  randoms:string;
  issued:cardinal;
  socket:ttcpblocksocket;
 end;

    type //helper visual headers
  Tcolumn_type=(COLUMN_TITLE,
                COLUMN_ARTIST,
                COLUMN_CATEGORY,
                COLUMN_ALBUM,
                COLUMN_TYPE,
                COLUMN_SIZE,
                COLUMN_DATE,
                COLUMN_LANGUAGE,
                COLUMN_VERSION,
                COLUMN_QUALITY,
                COLUMN_COLORS,
                COLUMN_LENGTH,
                COLUMN_RESOLUTION,
                COLUMN_STATUS,
                COLUMN_FILENAME,
                COLUMN_INPROGRESS,
                COLUMN_NULL,
                COLUMN_YOUR_LIBRARY,
                COLUMN_MEDIATYPE,
                COLUMN_FORMAT,
                COLUMN_FILETYPE,
                COLUMN_USER,
                COLUMN_FILEDATE);

 type  //helper visual headers
  tstato_search_header=array[0..10] of tcolumn_type;
  tstato_library_header=array[0..10] of tcolumn_type;
  tstato_header_chat=array[0..9] of tcolumn_type;






  //thread client, structure for HASH source/resume search
  precord_download_hash=^record_download_hash;
   record_download_hash=record
    hash:string;
    crchash:word;
    handle_download:cardinal;
   end;

   type  //thread_client avoid some dead loop while adding/removing hosts in discovery
   precord_nodo_provato=^record_nodo_provato;
   record_nodo_provato=record
    host:string;
    when:cardinal;
    isBad:boolean;
   end;
   
    type
  Tsocks_type=(SoctNone,
               SoctSock4,
               SoctSock5);

  type  //thread_upload don't accept too many chat request from single ips
  precord_ip_accepted_chat=^record_ip_accepted_chat;
  record_ip_accepted_chat=record
   ip:cardinal;
   last:cardinal;
   volte:byte;
  end;

  type //GUI manual folder share configuration
  precord_mfolder=^record_mfolder;
  record_mfolder=record
   drivetype:cardinal;
   path:string;
   crcpath:word;//per velocizzare
   stato:integer;
  end;

   type   //cache/ultranode/thread_upload structure to prevent some accept flooding
 precord_ip_antiflood=^record_ip_antiflood;
 record_ip_antiflood=record
  ip,logtime:cardinal;
  polled:boolean;
 end;

  type
  POpenFilenameW = ^TOpenFilenameW;
  POpenFilename = POpenFilenameW;
  {$EXTERNALSYM tagOFNW}
  tagOFNW = packed record
    lStructSize: DWORD;
    hWndOwner: HWND;
    hInstance: HINST;
    lpstrFilter: PWideChar;
    lpstrCustomFilter: PWideChar;
    nMaxCustFilter: DWORD;
    nFilterIndex: DWORD;
    lpstrFile: PWideChar;
    nMaxFile: DWORD;
    lpstrFileTitle: PWideChar;
    nMaxFileTitle: DWORD;
    lpstrInitialDir: PWideChar;
    lpstrTitle: PWideChar;
    Flags: DWORD;
    nFileOffset: Word;
    nFileExtension: Word;
    lpstrDefExt: PWideChar;
    lCustData: LPARAM;
    lpfnHook: function(Wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): UINT stdcall;
    lpTemplateName: PWideChar;
  end;
  {$EXTERNALSYM tagOFN}
  tagOFN = tagOFNW;
  TOpenFilenameW = tagOFNW;
  TOpenFilename = TOpenFilenameW;
  {$EXTERNALSYM OPENFILENAMEW}
  OPENFILENAMEW = tagOFNW;
  {$EXTERNALSYM OPENFILENAME}
  OPENFILENAME = OPENFILENAMEW;
  
  type  //playlist file structure
  precord_file_playlist=^record_file_playlist;
  record_file_playlist=record
   numero:integer;
   displayName,filename:string;
   crcfilename:word;
   amime:byte;
   length:cardinal;
  end;

  type //upload, user granted of upload slot
  precord_user_granted=^record_user_granted;
  record_user_granted=record
   ip_user:cardinal;
   port_user:word;
   ip_alt:cardinal;
  end;

  type  //helper diskio search structure
  TSearchRecW = record
    Time: Integer;
    Size: Integer;
    Attr: Integer;
    Name: WideString;
    ExcludeAttr: Integer;
    FindHandle: THandle;
    FindData: TWin32FindDataW;
  end;


  type //private chat file transfer structure
   precord_file_chat_send=^record_file_chat_send;
   record_file_chat_send=record
    filenameA,folderA:string;
    tipoW:widestring;
    remaining,size,bytesprima,progress,speed:int64;
    num,num_referrer,randomsenu:integer;
    stream:thandlestream;
    transferring,waiting_for_activation,upload,accepted,completed,should_stop:boolean;
    last_data:cardinal;
  end;

  type  // try also
  precord_keyword_genre_item=^record_keyword_genre_item;
  record_keyword_genre_item=record
   artist:string;
   crc:word;
   len:byte;
   times:cardinal;
   prev,next:precord_keyword_genre_item;
  end;

  type // try also
  precord_keyword_genre=^record_keyword_genre;
  record_keyword_genre=record
   genre:string;
   crc:word;
   len:byte;
   firstitem:precord_keyword_genre_item;
  end;

 type   // directshow
  TDSMediaInfo = record
    SurfaceDesc: TDDSurfaceDesc;
    Pitch: integer;
    PixelFormat: TPixelFormat;
    MediaLength: Int64;
    AvgTimePerFrame: Int64;
    FrameCount: integer;
    Width: integer;
    Height: integer;
    FileSize: Int64;
  end;

   type
    LongRec = packed record
    Lo, Hi: Word;
  end;

  u_char = Char;
   u_short = Word;
       u_long = Longint;
    u_int = Integer;
     TSocket = u_int;
  SunB = packed record
    s_b1, s_b2, s_b3, s_b4: u_char;
  end;
    SunW = packed record
    s_w1, s_w2: u_short;
  end;

   PInAddr = ^TInAddr;
  {$EXTERNALSYM in_addr}
  in_addr = record
    case integer of
      0: (S_un_b: SunB);
      1: (S_un_w: SunW);
      2: (S_addr: u_long);
  end;
  TInAddr = in_addr;


   const
    INVALID_SOCKET		= TSocket(NOT(0));

   type
    TWMActivate = record
    Msg: Cardinal;
    Active: Word; { WA_INACTIVE, WA_ACTIVE, WA_CLICKACTIVE }
    Minimized: WordBool;
    ActiveWindow: HWND;
    Result: Longint;
  end;

  type
    TWMDropFiles = record
    Msg: Cardinal;
    Drop: THANDLE;
    Unused: Longint;
    Result: Longint;
  end;
  
   type
    TWMKey = record
    Msg: Cardinal;
    CharCode: Word;
    Unused: Word;
    KeyData: Longint;
    Result: Longint;
  end;

  type
    TMessage = record
    Msg: Cardinal;
    case Integer of
      0: (
        WParam: Longint;
        LParam: Longint;
        Result: Longint);
      1: (
        WParamLo: Word;
        WParamHi: Word;
        LParamLo: Word;
        LParamHi: Word;
        ResultLo: Word;
        ResultHi: Word);
  end;

  // params
  TWMCopyData = packed record
    Msg: Cardinal;
    From: HWND;
    CopyDataStruct: PCopyDataStruct;
    Result: Longint;
  end;

 type //secure hash
 TID = Array[0..4] of integer;
 TBD = Array[0..19] of Byte;

type  //channellist structure, preparsed topic to speed up draw of coloured topics
precord_displayed_channel=^record_displayed_channel;
record_displayed_channel=record
 ip:cardinal;//ip interno fastweb
 port,status:word;
 name,
 topic:string;
 language:string;
 locrc:word;
 stripped_topic:widestring;
 has_colors_intopic:boolean;
 buildNo:word;
end;

type
precord_chat_favorite=^record_chat_favorite;
record_chat_favorite=record
 ip,last_joined:cardinal;//ip interno fastweb
 port:word;
 name,
 topic:string;
 locrc:word;
 stripped_topic:widestring;
 has_colors_intopic,
 autoJoin:boolean; // per visual più che altro
end;


type  // library regular folder structure
precord_cartella_share=^record_cartella_share;
record_cartella_share=record
 items:word;
 items_shared:word;
 path:widestring;
 crcpath:word;
 path_utf8,
 display_path:string;
 id:word;
 prev,next,first_child,parent:precord_cartella_share;
end;

 type  // file meta exchange structure
  precord_audioinfo=^record_audioinfo;
  record_audioinfo=record
   bitrate,
   frequency,
   duration:integer;
   codec:string;
  end;

 type  // thread upload, local list of queued users (used also by treeview_queue)
  precord_queued=^record_queued;
  record_queued=record
   total_tries,    // how many time has he tried
   polltime,      // next poll expected
   retry_interval, // how often it comes
   queue_start:cardinal; // when we first seen it
   nomefile,user:string;
   crcnomefile:word;
   pollmax,pollmin,
   posizione:cardinal;
   ip,ip_alt,server_ip:cardinal;
   port,server_port:word;
   disconnect,banned:boolean;
   size:int64;
   his_speedDL:cardinal;//2957+ mostra sua velocità in luogo di age download
   importance,his_progress,num_available:byte;
   his_shared,his_upcount,his_downcount:integer;
   his_agent:string;
  end;


type  // string parse helper structure
precord_title_album_artist=^record_title_album_artist;
record_title_album_artist=record
 artist,
 album,
 title:widestring;
end;


type    // from client to upload (client receive it from supernode, then upload perform connection to deliver push)
 precord_push_to_go=^record_push_to_go;
 record_push_to_go=record
  filename:string;
  ip:cardinal;
  port:word;
 end;



type   // thread upload , data structure for listview_upload component
precord_displayed_upload=^record_displayed_upload;
record_displayed_upload=record
 handle_obj:cardinal;
 isUDP:boolean;
 nomefile,nickname:string;
 crcnick,crcfilename:word;
 should_stop,should_ban:boolean;
 progress,size,filesize_reale,continued_from,start_point:int64;
 upload:tupload;
 continued,completed:boolean;
 ip,ip_server,ip_alt:cardinal; // per ban veloci
 port,port_server:word;
 his_speedDL:cardinal;
 his_shared,his_upcount,his_downcount,velocita:integer;
 num_available,his_progress:byte;
 his_agent:string;
end;



{type    // chat client/server GUI structure  for each visual chatroom
precord_canale_chat_visual=^record_canale_chat_visual;
record_canale_chat_visual=record
 name,topic,language:string;
 ModLevel,should_exit,just_created,support_pvt,support_files:boolean; //th_client, connettiti
  containerPageview:tcometPageView;
  containerPnl:TPanel;
  pnl:TCometPagePanel;
  edit_chat:ttntedit;
  panel_edit_chat:ttntpanel;
  topicpnl:TCometTopicPnl;
  pannello:ttntpanel;
  splitter:tsplitter;
  buttonToggleTask:TXPButton;
  memo:TjvRichEdit;
  frmTab:ttntform;
  listview:tcomettree;
  urlPanel:TCometPlayerPanel;
 lista_pvt,lista_pannelli_result,lista_pannelli_browse:tmylist;
 out_text:tmystringlist;
 ip,alt_ip:cardinal;//ip interno fastweb
 port:word;
end;

type   // chat client/server structure for private messages (tabs)
precord_pvt_chat_visual=^record_pvt_chat_visual;
record_pvt_chat_visual=record
 nickname:string;
 pnl:TCometPagePanel;
 crcnickname:word;
 memo:TjvRichEdit;
 edit_chat:ttntedit;
 frmTab:ttntform;
 buttonToggleTask:TXPButton;
 panel_edit_chat:ttntpanel;
 containerPanel:tpanel;
 canale:precord_canale_chat_visual;
 has_sent_away_msg:boolean;
end;

type   //chat server/client GUI structure objects
precord_pannello_browse_chat=^record_pannello_browse_chat;
record_pannello_browse_chat=record
 randomstr,nick:string;
 ip_user,ip_server,ip_alt:cardinal;
 port_user,port_server:word;
 canale:precord_canale_chat_visual;
 num_files:word;
 lista_files:tmylist;
  treeview:tcomettree;
  treeview2:tcomettree;//per regular folders
  panel_left:tcomettopicPnl;
  btn_virtual_view:TXPButton;
  btn_regular_view:TXPButton;
  listview:tcomettree;
  containerPanel:tpanel;
  pnl:TCometPagePanel;
  stato_header_library:tstato_library_header;
  splitter2:tsplitter;
end; }

type
precord_panel_search=^record_panel_search;
record_panel_search=record
 started:cardinal;
 lbl_src_status_caption:widestring;
 searchID:word;
 backup_results:tmylist;
 search_string:string;
// listview:tcomettree;
 stato_header:tstato_search_header;
 containerPanel:Tpanel;
// pnl:TCometPagePanel;
 numresults,numhits:word;
 mime_search:byte;
 is_advanced,is_updating:boolean;
  combo_search_text,comboalbsearch_text,comboautsearch_text,combo_lang_search_text,
  combodatesearch_text,combotitsearch_text,combocatsearch_text:widestring;
  combo_sel_duration_index,combo_sel_quality_index,
  combo_sel_size_index,combo_wanted_duration_index,combo_wanted_quality_index,
  combo_wanted_size_index:integer;
end;
{
type    // chat server/client GUI
precord_pannello_result_chat=^record_pannello_result_chat;
record_pannello_result_chat=record
 randomstr:string;
 listview:tcomettree;
 stato_header:tstato_header_chat;
 tiporicerca:byte; //per ricordarsi di come visualizzare header su arrivo primi results
 is_adding_result:boolean;
 containerPanel:tpanel;
 pnl:TCometPagePanel;
 canale:precord_canale_chat_visual;
 countresult:word;
end;}

type    // chat server/client GUI structure for result panel
precord_file_result_chat=^record_file_result_chat;
record_file_result_chat=record
 ip_user,ip_server,ip_alt:cardinal;
 port_user,port_server:word;
 amime:byte;
 fsize:int64;
 nickname,client,hash_sha1:string;
 crcsha1:word;
 up_count,up_limit,queued,imageindex:byte;
 title,artist,album,category,language,comments,url,data,vidinfo,keyword_genre,filename:string;
 param1,param2,param3:cardinal;
 downloaded,already_in_lib,being_downloaded:boolean;
end;




type  //avoid creation of tcpblocksockets objects
precord_socket=^record_socket;
record_socket=record
 ip,buffstr:string;
 port:word;
 socket:integer;
 connesso:boolean;
 tag:cardinal;
end;



type  //chat server user shown on the channel's userlist
precord_displayed_chat_user=^record_displayed_chat_user;
record_displayed_chat_user=record
 nick:string;
 id:word;
 crcnick,files:word;
 speed:integer;
 ip,ip_alt,ip_server:cardinal;//ip interno fastweb?
 port,port_server:word;
 should_kill,ignored,support_files:boolean;
 ModLevel:byte;
 user_age:byte;
 user_sex:byte;
 user_country:byte;
 user_statecity:string;
 avatar:graphics.tbitmap;
 personalMessage:string;
 //user:precord_server_chat_user;
end;




  type  //thread_share, used while scanning library
  precord_file_scan=^record_file_scan;
  record_file_scan=record
   fname:widestring;
   Amime:byte;
   ext:string;
   fsize:int64;
  end;


  type  //GUI p2p search result listview structure
  precord_search_result=^record_search_result;
  record_search_result=record
    search_id:word;
    title,artist,album,filenameS,nickname,keyword_genre,category,comments,language,url,year:string;
    hash_sha1,hash_of_phash:string;
    crcsha1:word;
    fsize:int64;
    ImageIndex:integer;
    param1,param2,param3:cardinal;
    amime:byte;
    already_in_lib,being_downloaded,downloaded:boolean;
    ip_alt,ip_user,ip_server:cardinal;
    port_user,port_server:word;
    bold_font:boolean;
    DHTload:byte;
  end;

  //client, helps while parsing result  attenzione deve essere allineato così
 precord_user_resultcl=^record_user_resultcl; //per riempimento header result client veloce
 recorD_user_resultcl=packed record
  serverip:cardinal;
  serverport:word;
  userip:cardinal;
  userport:word;
  spchar:byte;
 end;



  type   //upload, helper with the alt source excange
  precord_hash_holder_alternate=^record_hash_holder_alternate;
  record_hash_holder_alternate=record
   next:precord_hash_holder_alternate;
   first_alt:precord_alternate;
   hash_sha1:array[0..19] of byte;
   crcsha1:word;
   num:cardinal;
  end;


type  //per facilitare in thread share costruzione di indexs phashes
 precord_phash_index=^record_phash_index;
 record_phash_index=record
 db_point_on_disk:cardinal;
 len_on_disk:cardinal;
 hash_sha1:string;
 crcsha1:word;
 next:precord_phash_index;
end;

  type   //library local/remote(browse)
  precord_file_library=^record_file_library;
  record_file_library = record
   downloaded,being_downloaded,already_in_lib:boolean;//pvt browse
   guid_search:tguid; //compare result private chat
   hash_sha1:string;   //sha1 20 bytes
   hash_of_phash:string;
   crcsha1:word;
   ext:string;
   filedate:tdatetime; //per assegniare orario ingresso in library
   title,album,artist,category,mediatype,vidinfo,comment,language,path,url,year,keywords_genre:string;
   param1,param2,param3:integer;
   folder_id:word;
   fsize:int64;
   imageindex:integer;
   amime:byte;
   shared,corrupt,write_to_disk,previewing:boolean;
   phash_index:cardinal;//punto in db_hash per veloce ritrovamento in thread upload
   next:precord_file_library;//per facilitare library scan
 end;

 type
 precord_file_trusted=^record_file_trusted;
 record_file_trusted= record
  hash_sha1:string;
  crcsha1:word;
  title,album,artist,category,mediatype,vidinfo,comment,language,path,url,year,keywords_genre:string;
  corrupt,shared:boolean;
  filedate:tdatetime; //per assegniare orario ingresso in library
  next:precord_file_trusted;
 end;

 type
 precord_ip=^record_ip;
 record_ip=record
  ip:cardinal;
 end;

implementation



end.

