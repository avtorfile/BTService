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
global variables, some related to threads
}

unit vars_global;

interface

uses
 classes2,thread_terminator,{DSPack,ufrmhint,}classes,windows,graphics,
 ares_types,{comettrees,tntmenus,}thread_upload,thread_download,
 {thread_client,}thread_supernode,thread_share,int128,ares_objects,
 helper_autoscan,thread_dht,blcksock,synsock,dhtzones,
 thread_bittorrent,{tntforms,}forms;

var
  COLOR_DL_COMPLETED,
  COLOR_UL_COMPLETED,
  COLOR_UL_CANCELLED,
  COLOR_PROGRESS_DOWN,
  COLOR_PROGRESS_UP,
  COLOR_OVERLAY_UPLOAD,
  COLORE_ALTERNATE_ROW,
  COLORE_LISTVIEW_HOT,
  COLORE_TRANALTERNATE_ROW,
  COLORE_HINT_BG,
  COLORE_HINT_FONT,
  COLORE_GRAPH_BG,
  COLORE_GRAPH_GRID,
  COLORE_PLAYER_BG,
  COLORE_PLAYER_FONT,
  COLORE_LISTVIEWS_BG,
  COLORE_LISTVIEWS_FONT,
  COLORE_LISTVIEWS_FONTALT1,
  COLORE_LISTVIEWS_FONTALT2,
  COLORE_LISTVIEWS_GRIDLINES,
  COLORE_LISTVIEWS_TREELINES,
  COLORE_PARTIAL_UPLOAD,
  COLORE_PARTIAL_DOWNLOAD,
  COLORE_GRAPH_INK,
  COLORE_SEARCH_PANEL,
  COLORE_LIBDETAILS_PANEL,
  COLORE_FONT_SEARCHPNL,
  COLORE_FONT_LIBDET,
  COLORE_PANELS_SEPARATOR,
  COLORE_PANELS_BG,
  COLORE_PANELS_FONT,
  COLORE_LISTVIEWS_HEADERBK,
  COLORE_LISTVIEWS_HEADERFONT,
  COLORE_LISTVIEWS_HEADERBORDER,
  COLOR_MISSING_CHUNK,
  COLOR_CHUNK_COMPLETED,
  COLOR_PARTIAL_CHUNK,
  COLORE_DLSOURCE,
  COLORE_PHASH_VERIFY,
  COLORE_TOOLBAR_BG,
  COLORE_TOOLBAR_FONT,
  COLORE_ULSOURCE_CHUNK:tcolor;
  VARS_SCREEN_LOGO:widestring;
  SETTING_3D_PROGBAR,
  VARS_THEMED_BUTTONS,
  VARS_THEMED_HEADERS,
  VARS_THEMED_PANELS:boolean;
  COLORE_CHAT_FONT,
  COLORE_CHAT_BG,
  COLORE_CHAT_NICK,
  COLORE_CHATPVTNICK,
  COLORE_PUBLIC,
  COLORE_JOIN,
  COLORE_PART,
  COLORE_EMOTE,
  COLORE_NOTIFICATION,
  COLORE_ERROR:byte;

  glob_shared_mem:ares_objects.tsharedmemory;
  initialized:boolean;
  app_minimized:boolean;
  mute_on:boolean;
  closing:boolean;
  last_shown_SRCtab:byte;
  InternetConnectionOK:boolean;
  trayinternetswitch:boolean;
  client_has_relayed_chats:boolean;
  maxScoreChannellist:word;
  thread_up:tthread_upload;
  thread_down:tthread_download;
//  client:tthread_client;
  hash_server:tthread_supernode;   
  share:tthread_share;
  relayed_direct_chats:tthreadlist;     
  search_dir:tthread_search_dir;
  IDEIsRunning:boolean;
  chat_favorite_height:integer;
  typed_lines_chat:tmystringlist;
  typed_lines_chat_index:integer;
  num_seconds:byte;
  isvideoplaying:boolean;
  StopAskingChatServers:boolean;
  last_chat_req:cardinal;
  last_mem_check:cardinal;
  image_less_top,image_more_top,image_back_top:integer;
  allow_regular_paths_browse:boolean;
  browse_type:byte;
  ip_user_granted:cardinal;
  port_user_granted:word;
  ip_alt_granted:cardinal;
  list_chatchan_visual:tmylist;
  chat_chanlist_backup:tmylist;
  lista_pushed_chatrequest:tmylist;
  fresh_downloaded_files:tmylist;
  terminator:tthread_terminator;
  queue_firstinfirstout:boolean;
  src_panel_list:tmylist;
//  filtro2:TFilterGraph;
//  formhint:tfrmhint;
  MAX_OUTCONNECTIONS:integer;//sp2 limit download outgoing sources
  block_pm,block_pvt_chat:boolean;
  max_dl_allowed:byte;
  up_band_allow,down_band_allow:cardinal;
  numero_upload,numero_download,numero_queued,numTorrentDownloads,
  numTorrentUploads,speedTorrentDownloads,speedTorrentUploads:cardinal;
  downloadedBytes,BitTorrentDownloadedBytes,BitTorrentUploadedBytes:int64;

  loc_speedDownloads,loc_SpeedUploads:cardinal;
  loc_downloadedBytes,loc_UploadedBytes:int64;

  lista_shared:tmylist;
  should_show_prompt_nick:boolean;
  MAX_SIZE_NO_QUEUE:cardinal;
   app_path:widestring;
   data_path:widestring;
  versioneares:string;
  mega_uploaded,mega_downloaded:integer;
  hashing:boolean;
  lista_down_temp:tmylist;
  cambiato_search:boolean;
  program_totminuptime,program_start_time,program_first_day:cardinal;
  my_shared_count:integer;
  im_firewalled:boolean;
  logon_time:cardinal;
  velocita_att_upload,velocita_att_download:cardinal;
  LanIPC:cardinal;
  LanIPS:string;
  prev_cursorpos:tpoint;
  minutes_idle:cardinal;
  socks_type:Tsocks_type;
  socks_password,socks_username,socks_ip:string;
  socks_port:word;
  global_supernode_port:word;
  isSortingPerAvatar:boolean;

  stopped_by_user:boolean;
  font_chat:tfont;
  ares_aval_nodes:tthreadList;
  should_send_channel_list:boolean;
  need_rescan:boolean;
  scan_start_time:cardinal;
  queue_length:byte;
  mypgui:string;
//  previous_hint_node:pcmtvnode;
  handle_obj_GraphHint:cardinal;
  graphIsDownload,graphIsUpload:boolean;
  max_ul_per_ip:byte;
  shufflying_playlist:boolean;
  buildno:cardinal;
  FSomeFolderChecked:boolean;
  changed_download_hashes:boolean;
  ShareScans:cardinal;
  update_my_nick:boolean;
  playlist_visible:boolean;
  velocita_up:cardinal;
  velocita_down:dword;
  oldhintposx,oldhintposy:integer;
  limite_upload:byte;
  hash_select_in_library:string;
  user_sex:byte;
  user_age:byte;
  user_country:word;
  user_statecity:string;
  defLangEnglish:boolean;
  myport:word;
  mynick:string;
  file_visione_da_copiatore,caption_player:widestring;
  panel6sizedefault,panelUploadHeight,default_width_chat:integer;
  ending_session:boolean;
  blendPlaylistForm:tform;
  localip:string;
  localipC:cardinal;
  myshared_folder,my_torrentFolder:widestring;
  last_index_icona_details_library:byte;
  client_h_global:integer;
  bytes_sent:int64;
  muptime:cardinal;
  lista_socket_accept_down:tmylist;
  lista_risorse_temp:tthreadlist;
  lista_risorsepartial_temp:tthreadlist;
  lista_socket_temp_proxy:tmylist;
  lista_push_nostri:tmylist;
  ever_pressed_chat_list:boolean;
  hash_throttle:byte;
  chat_buttons_wantbg:boolean;
  numero_pvt_open:word;
  cambiato_manual_folder_share,cambiato_setting_autoscan,want_stop_autoscan:boolean;
  partialUploadSent:int64;
  speedUploadPartial:cardinal;
  was_on_src_tab:boolean; //for unbolding of search results
  user_personalMessage:string;
  need_chatroom_update_message:boolean;
  should_update_chatroom_avatar:boolean;

  threadDHT:tthread_dht;
  DHT_socket:hsocket;
  DHT_RemoteSin:TVarSin;
  DHT_buffer:array[0..9999] of byte;

  DHT_len_recvd,DHT_len_tosend:integer;
  DHT_routingZone:TRoutingZone;
  DHT_m_Publish:boolean; //autopubblish of own key
  DHT_m_nextID:cardinal;
  DHT_events:Tmylist;
  DHT_Searches:Tmylist;
  DHTme128:CU_INT128;
  DHT_availableContacts:integer;
  DHT_AliveContacts:integer;
  DHT_possibleBootstrapClientIP:cardinal;
  DHT_possibleBootstrapClientPort:word;
  DHT_hashFiles:tthreadList;
  DHT_KeywordFiles:tthreadList;
  DHT_LastPublishKeyFiles:cardinal; //milliseconds 
  DHT_LastPublishHashFiles:cardinal; //milliseconds

  my_mdht_port:word;
  
  BitTorrentTempList:TMyList;
  bittorrent_Accepted_sockets:TMylist;
  thread_bittorrent:tthread_bitTorrent;

  chatTabs:Tmylist;  //taskbar buttons

  
  check_opt_gen_autostart_checked:boolean;
  check_opt_gen_autoconnect_checked:boolean;
  check_opt_gen_msnsong_checked:boolean;
  check_opt_gen_gclose_checked:boolean;
  check_opt_tran_warncanc_checked:boolean;
  check_opt_gen_capt_checked:boolean;
  check_opt_tran_perc_checked:boolean;
  check_opt_gen_pausevid_checked:boolean;
  check_opt_gen_nohint_checked:boolean;
  check_opt_tran_inconidle_checked:boolean;
  Check_opt_chat_time_checked:boolean;
  Check_opt_chat_autoadd_checked:boolean;
  check_opt_chat_joinpart_checked:boolean;
  check_opt_chat_taskbtn_checked:boolean;
  Check_opt_chat_nopm_checked:boolean;
  Check_opt_chatRoom_nopm_checked:boolean;
  check_opt_chat_noemotes_checked:boolean;
  check_opt_chat_browsable_checked:boolean;
  check_opt_chat_realbrowse_checked:boolean;
  check_opt_chat_isaway_checked:boolean;
  memo_opt_chat_away_text:widestring;
  check_opt_net_nosprnode_checked:boolean;
  Check_opt_hlink_filterexe_checked:boolean;
  check_opt_hlink_magnet_checked:boolean;
  check_opt_hlink_pls_checked:boolean;
  check_opt_torrent_assoc_checked:boolean;
  lbl_opt_skin_title_caption,
  lbl_opt_skin_author_caption,
  lbl_opt_skin_url_caption,
  lbl_opt_skin_version_caption,
  lbl_opt_skin_date_caption,
  lbl_opt_skin_comments_caption:widestring;

  MainFormHandle: THandle;
  PortableApp: Boolean;
  PluginName: string;
  IniName: string;
  BTServicePath: string;
  ProgressiveDL: Boolean;
  

implementation

end.
