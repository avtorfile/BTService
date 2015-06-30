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
everything related to registry save/load of settings
}

unit helper_registry;

interface

uses
 windows,classes,registry,const_ares,helper_strings,
 helper_unicode,sysutils,vars_global,forms,
 activex,blcksock,dht_int160,inifiles;

function reg_bannato(const ip:string):boolean;
function getDataPort(reg:tregistry):word;
function getmdhtPort(reg:tregistry):word;
function prendi_mynick(reg:tregistry):string;
function prendi_my_pgui(reg:tregistry):string;
procedure write_default_upload_height;
function get_default_upload_height(maxHeight:integer):integer;
function reg_get_avgUptime:integer;
function prendi_cant_supernode:boolean; //non possiamo, true se non possiamo
function prendi_reg_my_shared_folder(const data_path:widestring):widestring;
function regGetMyTorrentFolder(const sharedFolder:widestring):widestring;

procedure stats_maxspeed_write;
procedure stats_uptime_write(start_time:cardinal; totminuptime:cardinal);
procedure prendi_prefs_reg;
procedure set_reginteger(const vname:string; value:integer);
procedure set_regstring(const vname:string; const value:string);
procedure reg_toggle_autostart;
procedure mainGui_initprefpanel;
function get_reginteger(const vname:string; defaultv:integer):integer;
function get_regstring(const vname:string):string;

procedure reg_get_transpeed(reg:tregistry; var UpI:cardinal; var DnI:cardinal);
procedure reg_get_megasent(reg:tregistry; var MUp:integer; var MDn:integer);
procedure reg_get_totuptime(reg:tregistry; var tot:cardinal);
procedure reg_zero_avg_uptime;
procedure reg_get_first_rundate(reg:tregistry; var frdate:cardinal);
function reg_getever_configured_share:boolean;
function reg_ChatGetBindIp:string;
function reg_needs_fresh_HomePage:boolean;
function reg_wants_chatautofavorites:boolean;
procedure reg_save_chatfav_height;

procedure reg_SetDHT_ID;
procedure reg_GetDHT_ID;
procedure reg_GetMDHT_ID(id:pCU_INT160);
procedure reg_SetMDHT_ID(id:CU_INT160);

function reg_justInstalled:boolean;
function reg_first_load_chatroom:boolean;

implementation

uses
{ufrmmain,}helper_crypt,
helper_datetime,ares_types,
int128;

function reg_first_load_chatroom:boolean;
var
 reg:tregistry;
begin
result:=false;
reg:=Tregistry.create;
with reg do begin
 openkey(areskey,true);

 if not valueExists('General.ChatJustInstalled') then begin
  closekey;
  destroy;
  exit;
 end;

 result:=true;
 deleteValue('General.ChatJustInstalled');
 closekey;
 destroy;
end;

end;

function reg_justInstalled:boolean;
var
reg:TRegistry;
begin
result:=false;

reg:=Tregistry.create;
with reg do begin
 openkey(areskey,true);

 if not valueExists('General.JustInstalled') then begin
  closekey;
  destroy;
  exit;
 end;

 result:=true;
 deleteValue('General.JustInstalled');
 closekey;
 destroy;
end;

end;

procedure reg_GetDHT_ID;
var
reg:tregistry;
buffer:array[0..15] of byte;
s: TMemoryStream;
ini: TMemIniFile;
begin
if PortableApp then
begin
 s := TMemoryStream.Create;
 ini := TMemIniFile.Create(IniName);
 try 
   if ini.ReadBinaryStream('Network', 'DHTID', s) = 16 then begin
     s.ReadBuffer(buffer[0],16);
     CU_INT128_CopyFromBuffer(@buffer[0],@DHTMe128);
   end;
 finally
   s.Free;
   ini.UpdateFile;
   ini.Free;
 end;
end
else
begin
reg:=Tregistry.create;
 with reg do begin
   openkey(areskey,true);
   if not valueexists('Network.DHTID') then begin
    closekey;
    destroy;
    exit;
   end;
   if GetDataSize('Network.DHTID')<>16 then begin
    closekey;
    destroy;
    exit;
   end;

   if ReadBinaryData('Network.DHTID',buffer,sizeof(buffer))<>16 then begin
    closekey;
    destroy;
    exit;
   end;
   
   CU_INT128_CopyFromBuffer(@buffer[0],@DHTMe128);
   closekey;
   destroy;
 end;
end;
end;

procedure reg_GetMDHT_ID(id:pCU_INT160);
var
reg:tregistry;
buffer:array[0..19] of byte;
ini: TMemIniFile;
s: TMemoryStream;
begin
if PortableApp then
begin
 s := TMemoryStream.Create;
 ini:=TMemIniFile.Create(IniName);
 try 
   if ini.ReadBinaryStream('Network', 'MDHTID', s) = 20 then begin
     s.ReadBuffer(buffer[0],20);
     CU_INT160_CopyFromBuffer(@buffer[0],id);
   end;
 finally
   s.Free;
   ini.UpdateFile;
   ini.Free;
 end;
end
else
begin
reg:=Tregistry.create;
 with reg do begin
   openkey(areskey,true);
   if not valueexists('Network.MDHTID') then begin
    closekey;
    destroy;
    exit;
   end;
   if GetDataSize('Network.MDHTID')<>20 then begin
    closekey;
    destroy;
    exit;
   end;

   if ReadBinaryData('Network.MDHTID',buffer,sizeof(buffer))<>20 then begin
    closekey;
    destroy;
    exit;
   end;

   CU_INT160_CopyFromBuffer(@buffer[0],id);
   closekey;
   destroy;
 end;
end;
end;

procedure reg_SetMDHT_ID(id:CU_INT160);
var
reg:tregistry;
buffer:array[0..19] of byte;
s: TMemoryStream;
ini: TMemIniFile;
begin
dht_int160.CU_INT160_CopyToBuffer(@id,@buffer[0]);

if PortableApp then
begin
 s := TMemoryStream.Create;
 ini:=TMemIniFile.Create(IniName);
 try
   try
     s.WriteBuffer(buffer[0],sizeof(buffer));
     s.Position:=0;
     ini.WriteBinaryStream('Network', 'MDHTID', s);
   except
   end;
 finally
   s.Free;
   ini.UpdateFile;
   ini.Free;
 end;
end
else
begin
reg:=Tregistry.create;
 with reg do begin
   openkey(areskey,true);
   WriteBinaryData('Network.MDHTID',buffer,sizeof(buffer));
   closekey;
   destroy;
 end;
end; 
end;

procedure reg_SetDHT_ID;
var
reg:tregistry;
buffer:array[0..15] of byte;
s: TMemoryStream;
ini: TMemIniFile;
begin
int128.CU_INT128_CopyToBuffer(@DHTme128,@buffer[0]);

if PortableApp then
begin
 s := TMemoryStream.Create;
 ini:=TMemIniFile.Create(IniName);
 try
   try
     s.WriteBuffer(buffer[0],sizeof(buffer));
     s.Position:=0;
     ini.WriteBinaryStream('Network', 'DHTID', s);
   except
   end;
 finally
   s.Free;
   ini.UpdateFile;
   ini.Free;
 end;
end
else
begin
reg:=Tregistry.create;
 with reg do begin
   openkey(areskey,true);
   WriteBinaryData('Network.DHTID',buffer,sizeof(buffer));
   closekey;
   destroy;
 end;
end; 
end;

procedure reg_save_chatfav_height;
var
reg:tregistry;
begin
  reg:=tregistry.create;
  with reg do begin
   openkey(areskey,true);
   writeinteger('ChatRoom.PanelFavHeight',vars_global.chat_favorite_height);
   closekey;
   destroy;
  end;
end;

function reg_wants_chatautofavorites:boolean;
var
reg:tregistry;
begin
result:=false;

 reg:=tregistry.create;
 with reg do begin
  openkey(areskey,true);
  if valueexists('ChatRoom.AutoAddToFavorites') then result:=(readinteger('ChatRoom.AutoAddToFavorites')=1);
  closekey;
  destroy;
 end;
end;

function reg_needs_fresh_HomePage:boolean;
var
reg:tregistry;
begin
result:=true;

  reg:=tregistry.create;
  with reg do begin
   openkey(areskey,true);
   if valueexists('Browser.LastHomePage') then begin
     if DelphiDateTimeToUnix(now)-readinteger('Browser.LastHomePage')<604800 then result:=false;
   end;
   closekey;
   destroy;
  end;

end;

function reg_ChatGetBindIp:string;
var
reg:tregistry;
begin
result:=cAnyHost;

 reg:=tregistry.create;
 with reg do begin
  openkey(areskey,true);
    if valueexists('ChatRoom.BindAddr') then
     result:=readstring('ChatRoom.BindAddr');
  closekey;
  destroy;
 end;

end;

function reg_getever_configured_share:boolean;
var
reg:tregistry;
begin
result:=false;

reg:=tregistry.create;
 with reg do begin
  openkey(areskey,true);
  if valueexists('Share.EverConfigured') then result:=(readinteger('Share.EverConfigured')=1);
  closekey;
  destroy;
 end;

end;

function get_reginteger(const vname:string; defaultv:integer):integer;
var
reg:tregistry;
begin

result:=defaultv;

reg:=tregistry.create;
with reg do begin
 openkey(areskey,true);

 if valueexists(vname) then result:=readinteger(vname);

 closekey;
 destroy;
end;

end;

function get_regstring(const vname:string):string;
var
reg:tregistry;
begin
result:='';


reg:=tregistry.create;
with reg do begin
 openkey(areskey,true);

 if valueexists(vname) then result:=readstring(vname);

 closekey;
 destroy;
end;

end;

procedure mainGui_initprefpanel;
var
reg:tregistry;
//temp_port:integer;
ini: TMemIniFile;
begin  
//GENERAL////////////////////////////////
reg:=tregistry.create;

with reg do begin
  rootkey:=HKEY_CURRENT_USER;
  openkey(areskey,true);
 //with ares_frmmain do
 begin     
  if valueexists('General.AutoStartUP') then begin
   if PortableApp then
   begin
    ini:=TMemIniFile.Create(IniName);
    try
      vars_global.check_opt_gen_autostart_checked := Ini.ReadBool('General','AutoStartUp', true);
    finally
      ini.UpdateFile;
      ini.Free;
    end;
   end
   else
   vars_global.check_opt_gen_autostart_checked:=(readinteger('General.AutoStartUp')=1);
  end else vars_global.check_opt_gen_autostart_checked:=true;

  {if valueexists('General.AutoConnect') then begin
   vars_global.check_opt_gen_autoconnect_checked:=(readinteger('General.AutoConnect')=1);
  end else vars_global.check_opt_gen_autoconnect_checked:=true;

  if valueexists('General.MSNSongNotif') then begin
   vars_global.check_opt_gen_msnsong_checked:=(readinteger('General.MSNSongNotif')=1);
  end else vars_global.check_opt_gen_msnsong_checked:=true;

  if reg.valueexists('General.CloseOnQuery') then begin
   vars_global.check_opt_gen_gclose_checked:=(reg.readinteger('General.CloseOnQuery')=1);
  end else vars_global.check_opt_gen_gclose_checked:=false;

  if reg.valueExists('Extra.WarnOnCancelDL') then begin
   vars_global.check_opt_tran_warncanc_checked:=(reg.readinteger('Extra.WarnOnCancelDL')<>0);
  end else vars_global.check_opt_tran_warncanc_checked:=false;


  if reg.valueexists('Extra.ShowActiveCaption') then begin
   vars_global.check_opt_gen_capt_checked:=(reg.readinteger('Extra.ShowActiveCaption')=1);
  end else vars_global.check_opt_gen_capt_checked:=false;

  if reg.valueexists('Extra.ShowTransferPercent') then begin
   vars_global.check_opt_tran_perc_checked:=(reg.readinteger('Extra.ShowTransferPercent')=1);
  end else vars_global.check_opt_tran_perc_checked:=false;

  if reg.valueExists('Extra.PauseVideoOnLeave') then begin
   vars_global.check_opt_gen_pausevid_checked:=(reg.readinteger('Extra.PauseVideoOnLeave')=1);
  end else vars_global.check_opt_gen_pausevid_checked:=false;

  if reg.valueexists('Extra.BlockHints') then begin
   vars_global.check_opt_gen_nohint_checked:=(reg.readinteger('Extra.BlockHints')=1);
  end else vars_global.check_opt_gen_nohint_checked:=false;


  if reg.valueexists('Transfer.MaximizeUpBandOnIdle') then begin
   vars_global.check_opt_tran_inconidle_checked:=(reg.readinteger('Transfer.MaximizeUpBandOnIdle')<>0);
  end else vars_global.check_opt_tran_inconidle_checked:=true;



  //chatroom ->chat
  //CHAT//////////////////////////////////////////

  if valueexists('ChatRoom.ShowTimeLog') then begin
   vars_global.Check_opt_chat_time_checked:=(readinteger('ChatRoom.ShowTimeLog')=1);
  end else vars_global.Check_opt_chat_time_checked:=false;

  if valueexists('ChatRoom.AutoAddToFavorites') then begin
   vars_global.Check_opt_chat_autoadd_checked:=(readinteger('ChatRoom.AutoAddToFavorites')=1);
  end else vars_global.Check_opt_chat_autoadd_checked:=true;

  if valueexists('ChatRoom.ShowJP') then begin //channel join part
   vars_global.check_opt_chat_joinpart_checked:=(readinteger('ChatRoom.ShowJP')=1);
  end else vars_global.check_opt_chat_joinpart_checked:=true;

  if valueExists('ChatRoom.ShowTaskBtn') then begin
   vars_global.check_opt_chat_taskbtn_checked:=(readinteger('ChatRoom.ShowTaskBtn')=1);
  end else vars_global.check_opt_chat_taskbtn_checked:=true;


  
  //chat->pvt
  if reg.valueexists('PrivateMessage.BlockAll') then begin
   vars_global.Check_opt_chat_nopm_checked:=(reg.readinteger('PrivateMessage.BlockAll')=1);
  end else vars_global.Check_opt_chat_nopm_checked:=false;

  if reg.valueexists('ChatRoom.BlockPM') then begin
   vars_global.Check_opt_chatRoom_nopm_checked:=(reg.readinteger('ChatRoom.BlockPM')=1);
  end else vars_global.Check_opt_chatRoom_nopm_checked:=false;

  if reg.valueexists('ChatRoom.BlockEmotes') then begin
   vars_global.check_opt_chat_noemotes_checked:=(reg.readinteger('ChatRoom.BlockEmotes')=1);
  end else vars_global.check_opt_chat_noemotes_checked:=false;

  if reg.valueexists('PrivateMessage.AllowBrowse') then begin
   vars_global.check_opt_chat_browsable_checked:=(reg.readinteger('PrivateMessage.AllowBrowse')=1);
  end else vars_global.check_opt_chat_browsable_checked:=true;

  if reg.valueexists('Privacy.SendRegularPath') then begin
   vars_global.check_opt_chat_realbrowse_checked:=(reg.readinteger('Privacy.SendRegularPath')<>0)
  end else vars_global.check_opt_chat_realbrowse_checked:=true;//di default ok


  if reg.valueExists('PrivateMessage.SetAway') then begin
   vars_global.check_opt_chat_isaway_checked:=(reg.readinteger('PrivateMessage.SetAway')=1);
  end else vars_global.check_opt_chat_isaway_checked:=false;


  vars_global.memo_opt_chat_away_text:=utf8strtowidestr(hexstr_to_bytestr(readstring('PrivateMessage.AwayMessage')));
  if length(vars_global.memo_opt_chat_away_text)<1 then vars_global.memo_opt_chat_away_text:=STR_DEFAULT_AWAYMSG;


  //network
  if valueexists('Network.NoSupernode') then begin
   vars_global.check_opt_net_nosprnode_checked:=(readinteger('Network.NoSupernode')=1);
  end else vars_global.check_opt_net_nosprnode_checked:=false;

  //search
  if valueexists('Search.BlockExe') then begin
   vars_global.Check_opt_hlink_filterexe_checked:=(readinteger('Search.BlockExe')=1);
  end else vars_global.Check_opt_hlink_filterexe_checked:=false;}

 end; //with ares_frmmain

closekey;
destroy;
end;

end;


procedure reg_toggle_autostart;
var
reg:tregistry;
ini:TMemIniFile;
begin
  reg:=tregistry.create;


with reg do begin
 

  if PortableApp then
  begin
   ini:=TMemIniFile.Create(IniName);
   try
     try
       Ini.WriteInteger('General','AutoStartUp', integer(vars_global.check_opt_gen_autostart_checked))
     except
     end;
   finally
     ini.UpdateFile;
     ini.Free;
   end;
  end
  else
  begin
   openkey(areskey,true);
   writeinteger('General.AutoStartUp',integer(vars_global.check_opt_gen_autostart_checked));
   closekey;
  end;
  



if vars_global.check_opt_gen_autostart_checked then begin
 openkey('Software\Microsoft\Windows\CurrentVersion\Run',true);
 writestring(lowercase(appname),'"'+application.exename+'" -h');
 CloseKey;
end else begin
 try
 rootkey:=HKEY_LOCAL_MACHINE;   //rimuoviamo anche root, per utenti di prima
  if openkey('Software\Microsoft\Windows\CurrentVersion\Run',false) then begin
    try
     deletevalue(lowercase(appname));
    except
    end;
   CloseKey;
  end;
 except
 end;

 try
 rootkey:=HKEY_CURRENT_USER;
 openkey('Software\Microsoft\Windows\CurrentVersion\Run',true);
  deletevalue(lowercase(appname));
 CloseKey;
 except
 end;
 
end;

destroy;
end;

end;

procedure set_regstring(const vname:string; const value:string);
var
reg:tregistry;
begin
 reg:=tregistry.create;
 with reg do begin
  openkey(areskey,true);
  writestring(vname,value);
  closekey;
  destroy;
 end;
end;

procedure set_reginteger(const vname:string; value:integer);
var
reg:tregistry;
begin
 reg:=tregistry.create;
 with reg do begin
 try
  openkey(areskey,true);
  writeinteger(vname,value);
  closekey;
 except
 end;
  destroy;
 end;
end;




procedure prendi_prefs_reg;
var
reg:tregistry;
ini:TMemIniFile;
valueexist:Boolean;
begin


muptime:=reg_get_avgUptime;

reg:=tregistry.create;

//check_hashlink_associations(reg);
//check_bittorrent_association(reg);
//check_pls_association(reg);
try

reg.rootkey:=HKEY_CURRENT_USER;


if PortableApp then
begin
 ini:=TMemIniFile.Create(IniName);
 try
   try
   if Ini.valueexists('General','AutoStartUp') then begin
   if Ini.ReadInteger('General','AutoStartUp', 0)=1 then
   begin
     reg.openkey('Software\Microsoft\Windows\CurrentVersion\Run',true);
     reg.writestring(lowercase(appname),'"'+application.exename+'" -h');
     reg.CloseKey;
     reg.openkey(areskey,true);
   end;
   end else begin 
    reg.openkey('Software\Microsoft\Windows\CurrentVersion\Run',true);
    reg.writestring(lowercase(appname),'"'+application.exename+'" -h');
    reg.CloseKey;
    reg.openkey(areskey,true);
   end;   
   except
   end;
 finally
   ini.UpdateFile;
   ini.Free;
 end;
end
else
begin
with reg do begin
 openkey(areskey,true);


if valueexists('General.AutoStartUp') then begin //autostartup?
 if readinteger('General.AutoStartUp')=1 then begin
  closekey;
  openkey('Software\Microsoft\Windows\CurrentVersion\Run',true);
  writestring(lowercase(appname),'"'+application.exename+'" -h');
  CloseKey;
  openkey(areskey,true);
 end;
end else begin
 closekey;
 openkey('Software\Microsoft\Windows\CurrentVersion\Run',true);
 writestring(lowercase(appname),'"'+application.exename+'" -h');
 CloseKey;
 openkey(areskey,true);
end;
end;
end;

//check_magnet_association(reg);

with reg do begin

 if valueexists('Proxy.Protocol') then begin
  if readinteger('Proxy.Protocol')=5 then socks_type:=SoctSock5 else
  if readinteger('Proxy.Protocol')=4 then socks_type:=SoctSock4 else
  socks_type:=SoctNone;
 end else socks_type:=SoctNone;

 socks_username:=hexstr_to_bytestr(readstring('Proxy.Username'));
 socks_password:=hexstr_to_bytestr(readstring('Proxy.Password'));

 socks_ip:=readstring('Proxy.Addr');

 if valueexists('Proxy.Port') then begin
   socks_port:=readinteger('Proxy.Port');
 end else socks_port:=1080;

 {if valueexists('Upload.AutoClearIdle') then begin //default autoclear Idle=true
  ares_frmmain.clearidle1.checked:=(readinteger('Upload.AutoClearIdle')=1);
 end else ares_frmmain.clearidle1.checked:=true;}

 //writeinteger('Stats.HasLQCa',0); //sblocco eventuale richiesta di un cache root...
 //writeinteger('Stats.LstCaQueryInt',MIN_INTERVAL_QUERY_CACHE_ROOT); //minimum amount of time between queries
 //writeinteger('Stats.LstCaQuery',0);//reset antiflood on gwebcache


 {if valueexists('Playlist.Repeat') then begin
  ares_frmmain.playlist_Continuosplay1.checked:=(readinteger('Playlist.Repeat')=1);
 end else ares_frmmain.playlist_Continuosplay1.checked:=false;

 if valueexists('Playlist.Shuffle') then begin
 ares_frmmain.playlist_Randomplay1.checked:=(readinteger('Playlist.Shuffle')=1);
 end else ares_frmmain.playlist_Randomplay1.checked:=false;


 if valueexists('General.LastLibraryMode') then begin
    if readinteger('General.LastLibraryMode')=1 then begin
      ares_frmmain.btn_lib_regular_view.down:=true;
      ares_frmmain.btn_lib_virtual_view.down:=false;
     end else begin
      ares_frmmain.btn_lib_regular_view.down:=false;
      ares_frmmain.btn_lib_virtual_view.down:=true;
     end;
 end else begin
     ares_frmmain.btn_lib_regular_view.down:=false;
     ares_frmmain.btn_lib_virtual_view.down:=true;
    end;}

    if valueexists('Connections.MaxDlOutgoing') then MAX_OUTCONNECTIONS:=reg.readinteger('Connections.MaxDlOutgoing')
     else MAX_OUTCONNECTIONS:=4;

 if valueexists('Hashing.Priority') then hash_throttle:=readinteger('Hashing.Priority')
  else hash_throttle:=1;//default highest -1
 //ares_frmmain.hash_pri_trx.position:=5-hash_throttle;
end;

//hash_update_GUIpry;


if PortableApp then
begin
 ini:=TMemIniFile.Create(IniName);
 try
    if Ini.valueexists('Transfer','QueueFirstInFirstOut') then begin
     queue_firstinfirstout:= (Ini.ReadInteger('Transfer','QueueFirstInFirstOut', 0)=1);
    end else queue_firstinfirstout:=false;

    if Ini.valueexists('Transfer','MaxDLCount') then begin
     max_dl_allowed:= Ini.ReadInteger('Transfer','MaxDLCount', 100);
     if max_dl_allowed=0 then max_dl_allowed:=100;//MAXNUM_ACTIVE_DOWNLOADS;
     if max_dl_allowed>MAXNUM_ACTIVE_DOWNLOADS then max_dl_allowed:=MAXNUM_ACTIVE_DOWNLOADS;
    end else max_dl_allowed:=100;

    if Ini.valueexists('Transfer','AllowedUpBand') then up_band_allow:=Ini.readinteger('Transfer','AllowedUpBand',0);
    if Ini.valueexists('Transfer','AllowedDownBand') then down_band_allow:=Ini.readinteger('Transfer','AllowedDownBand',0);
    if up_band_allow>65535 then up_band_allow:=0;
    if down_band_allow>65535 then down_band_allow:=0;

    //reg_get_transpeed(reg,velocita_up,velocita_down);
    //reg_get_megasent(reg,mega_uploaded,mega_downloaded);

    if Ini.valueexists('Transfer','MaxUpPerUser') then begin
     max_ul_per_ip:=Ini.ReadInteger('Transfer','MaxUpPerUser',10);
     if max_ul_per_ip>50 then max_ul_per_ip:=50;
    end else max_ul_per_ip:=6;


    if Ini.valueexists('Transfer','MaxUpCount') then begin
     limite_upload:=Ini.ReadInteger('Transfer','MaxUpCount',50);
     if limite_upload>100 then limite_upload:=100;
    end else limite_upload:=10;

    if Ini.valueexists('Transfer','MaximizeUpBandOnIdle') then begin
      vars_global.check_opt_tran_inconidle_checked:=(Ini.readinteger('Transfer','MaximizeUpBandOnIdle',1)<>0);
    end else vars_global.check_opt_tran_inconidle_checked:=true;

 finally
   ini.UpdateFile;
   ini.Free;
 end;
end
else
begin
with reg do begin

{ if valueexists('Libray.ShowDetails') then begin
  ares_frmmain.btn_lib_toggle_details.down:=(readinteger('Libray.ShowDetails')=1); //should show details in library?
 end else begin
  ares_frmmain.btn_lib_toggle_details.down:=false;
 end;}

 if valueexists('Transfer.QueueFirstInFirstOut') then begin
  queue_firstinfirstout:=(readinteger('Transfer.QueueFirstInFirstOut')=1);
 end else queue_firstinfirstout:=false;

 if valueexists('Transfer.MaxDLCount') then begin
  max_dl_allowed:=readinteger('Transfer.MaxDLCount');
  if max_dl_allowed=0 then max_dl_allowed:=100;//MAXNUM_ACTIVE_DOWNLOADS;
  if max_dl_allowed>MAXNUM_ACTIVE_DOWNLOADS then max_dl_allowed:=MAXNUM_ACTIVE_DOWNLOADS;
 end else max_dl_allowed:=100;


 {if valueexists('GUI.FoldersWidth') then panel6sizedefault:=readinteger('GUI.FoldersWidth');
 if panel6sizedefault<50 then panel6sizedefault:=50;

 if valueexists('GUI.ChatRoomWidth') then default_width_chat:=readinteger('GUI.ChatRoomWidth');
 if default_width_chat<100 then default_width_chat:=100;}


 if valueexists('Transfer.AllowedUpBand') then up_band_allow:=readinteger('Transfer.AllowedUpBand');
 if valueexists('Transfer.AllowedDownBand') then down_band_allow:=readinteger('Transfer.AllowedDownBand');
 if up_band_allow>65535 then up_band_allow:=0;
 if down_band_allow>65535 then down_band_allow:=0;

 {if valueexists('General.AutoConnect') then begin
   if readinteger('General.AutoConnect')=0 then begin
    ares_frmmain.btn_opt_connect.down:=false;
    ares_frmmain.btn_opt_disconnect.down:=true;
    ares_frmmain.lbl_opt_statusconn.caption:=' '+GetLangStringW(STR_NOT_CONNECTED);
   end else begin
    ares_frmmain.btn_opt_disconnect.down:=false;
    ares_frmmain.btn_opt_connect.down:=true;
    ares_frmmain.lbl_opt_statusconn.caption:=' '+GetLangStringW(STR_CONNECTING_TO_NETWORK);
   end;
 end else begin
    ares_frmmain.btn_opt_disconnect.down:=false;
    ares_frmmain.btn_opt_connect.down:=true;
    ares_frmmain.lbl_opt_statusconn.caption:=' '+GetLangStringW(STR_CONNECTING_TO_NETWORK);
 end;}

 reg_get_transpeed(reg,velocita_up,velocita_down);

 reg_get_megasent(reg,mega_uploaded,mega_downloaded);



end;

with reg do begin
 if valueexists('Transfer.MaxUpPerUser') then begin
  max_ul_per_ip:=ReadInteger('Transfer.MaxUpPerUser');
  if max_ul_per_ip>50 then max_ul_per_ip:=50;
 end else max_ul_per_ip:=6;


 if valueexists('Transfer.MaxUpCount') then begin
  limite_upload:=ReadInteger('Transfer.MaxUpCount');
  if limite_upload>100 then limite_upload:=100;
 end else limite_upload:=10;

 if reg.valueexists('Transfer.MaximizeUpBandOnIdle') then begin
   vars_global.check_opt_tran_inconidle_checked:=(reg.readinteger('Transfer.MaximizeUpBandOnIdle')<>0);
  end else vars_global.check_opt_tran_inconidle_checked:=true;

 {if valueExists('Personal.Sex') then begin
   vars_global.user_sex:=readInteger('Personal.Sex');
   if vars_global.user_sex>2 then vars_global.user_sex:=0;
 end else vars_global.user_sex:=0;

 if valueExists('Personal.Country') then begin
   vars_global.user_country:=readInteger('Personal.Country');
   if vars_global.user_country>high(country_strings) then vars_global.user_country:=0;
 end else vars_global.user_country:=0;

 if valueExists('Personal.StateCity') then begin
  vars_global.user_stateCity:=trim(readString('Personal.StateCity'));
 end else vars_global.user_stateCity:='';

  if valueExists('Personal.Age') then begin
   vars_global.user_age:=readInteger('Personal.Age');
   if vars_global.user_age>99 then vars_global.user_age:=0;
 end else vars_global.user_age:=0;

  if valueExists('Personal.CustomMessage') then begin
   vars_global.user_personalMessage:=trim(readstring('Personal.CustomMessage'));
  end else vars_global.user_personalMessage:='';}

end;
end;

 mypgui:=prendi_my_pgui(reg);

 mynick:=prendi_mynick(reg);

 myport:=getDataPort(reg);
 if myport=0 then myport:=random(60000)+5000;
 my_mdht_port:=getmdhtPort(reg);
 if my_mdht_port=0 then my_mdht_port:=random(60000)+5000;

with reg do begin
   deletekey('banned');//per chat

   reg_get_totuptime(reg,program_totminuptime);
   reg_get_first_rundate(reg,program_first_day);

     if program_totminuptime*59>delphidatetimetounix(now)-program_first_day then begin
      program_totminuptime:=0;
     end;

     valueexist:=False;
    if PortableApp then
      begin
       ini := TMemIniFile.Create(IniName);
       try
         try
           valueexist := ini.valueexists('Stats', 'CAvgTime');
         except
         end;
       finally
         ini.UpdateFile;
         ini.Free;
       end;
      end
      else valueexist := valueexists(REG_STR_STATS_AVGUPTIME);
           
     if not valueexist then reg_zero_avg_uptime;



 {writestring('GUI.LastLibrary','');
 writestring('GUI.LastSearch','');
 writestring('GUI.LastPMBrowse','');
 writestring('GUI.LastChatRoomBrowse','');}

   closekey;
end;


except
end;
reg.destroy;

end;

procedure reg_get_first_rundate(reg:tregistry; var frdate:cardinal);
var
str:string;
num:cardinal;
lenred:integer;
buffer:array[0..10] of char;
s : TMemoryStream;
 ini:TMemIniFile;
begin
 if PortableApp then
begin
 s := TMemoryStream.Create;
 ini:=TMemIniFile.Create(IniName);
 try
   {try
     s.WriteBuffer(buffer[0],sizeof(buffer));
     s.Position:=0;
     ini.WriteBinaryStream('Network', 'MDHTID', s);
   except
   end;}
   try
 with reg do begin

     if not ini.valueexists('Stats','CFRTime') then begin  //missing
        num:=delphidatetimetounix(now);
        str:=chr(random(255))+
             int_2_dword_string(num)+
             CHRNULL+
             chr(random(255))+
             int_2_word_string(wh(int_2_dword_string(num))+12);

       str:=e64(e67(str,7193)+CHRNULL,24884);
        move(str[1],buffer,length(str));
        //writebinarydata(REG_STR_STATS_FIRSTDAY,buffer,length(str));   //update average uptime

        s.WriteBuffer(buffer[0],length(str));
        s.Position:=0;
        ini.WriteBinaryStream('Stats', 'CFRTime', s);

       frdate:=delphidatetimetounix(now);
     end else begin
       //lenred:=readbinarydata(REG_STR_STATS_FIRSTDAY,buffer,10);
       lenred:=ini.ReadBinaryStream('Stats', 'CFRTime', s);
       s.ReadBuffer(buffer[0],lenred);

       if lenred=10 then begin
        setlength(str,lenred);
        move(buffer,str[1],lenred);
        str:=d67(d64(str,24884),7193);
         delete(str,1,1);    //remove random char 2047+
          if ((str[5]=CHRNULL) and (chars_2_word(copy(str,7,2))=word(wh(copy(str,1,4))+12))) then begin
           frdate:=chars_2_dword(copy(str,1,4));

          end else begin
           frdate:=0;

         end;
       end else frdate:=0;

         if ((frdate>delphidatetimetounix(now)) or (frdate=0)) then begin  //crack
          frdate:=delphidatetimetounix(now);
          str:=chr(random(255))+
               int_2_dword_string(frdate)+
               CHRNULL+
               chr(random(255))+
               int_2_word_string(wh(int_2_dword_string(frdate))+12);
          str:=e64(e67(str,7193)+CHRNULL,24884);
          move(str[1],buffer,length(str));
          //writebinarydata(REG_STR_STATS_FIRSTDAY,buffer,length(str));   //update average uptime
          s.WriteBuffer(buffer[0],length(str));
          s.Position:=0;
          ini.WriteBinaryStream('Stats', 'CFRTime', s);
        end;

     end;

end;

except
 frdate:=delphidatetimetounix(now);
end;
 finally
   s.Free;
   ini.UpdateFile;
   ini.Free;
 end;
end
else
 begin
 try
 with reg do begin

     if not valueexists(REG_STR_STATS_FIRSTDAY) then begin  //missing
        num:=delphidatetimetounix(now);
        str:=chr(random(255))+
             int_2_dword_string(num)+
             CHRNULL+
             chr(random(255))+
             int_2_word_string(wh(int_2_dword_string(num))+12);

       str:=e64(e67(str,7193)+CHRNULL,24884);
        move(str[1],buffer,length(str));
        writebinarydata(REG_STR_STATS_FIRSTDAY,buffer,length(str));   //update average uptime

       frdate:=delphidatetimetounix(now);
     end else begin
       lenred:=readbinarydata(REG_STR_STATS_FIRSTDAY,buffer,10);
       if lenred=10 then begin
        setlength(str,lenred);
        move(buffer,str[1],lenred);
        str:=d67(d64(str,24884),7193);
         delete(str,1,1);    //remove random char 2047+
          if ((str[5]=CHRNULL) and (chars_2_word(copy(str,7,2))=word(wh(copy(str,1,4))+12))) then begin
           frdate:=chars_2_dword(copy(str,1,4));

          end else begin
           frdate:=0;

         end;
       end else frdate:=0;

         if ((frdate>delphidatetimetounix(now)) or (frdate=0)) then begin  //crack
          frdate:=delphidatetimetounix(now);
          str:=chr(random(255))+
               int_2_dword_string(frdate)+
               CHRNULL+
               chr(random(255))+
               int_2_word_string(wh(int_2_dword_string(frdate))+12);
          str:=e64(e67(str,7193)+CHRNULL,24884);
          move(str[1],buffer,length(str));
          writebinarydata(REG_STR_STATS_FIRSTDAY,buffer,length(str));   //update average uptime
        end;

     end;

end;

except
 frdate:=delphidatetimetounix(now);
end;
end;


end;

procedure reg_get_totuptime(reg:tregistry; var tot:cardinal);
var
str:string;
lenred:integer;
buffer:array[0..10] of char;
begin
try

 with reg do begin
     if valueexists(REG_STR_STATS_TOTUPTIME) then begin
      lenred:=readbinarydata(REG_STR_STATS_TOTUPTIME,buffer,10);
      if lenred=10 then begin
       setlength(str,lenred);
       move(buffer,str[1],lenred);
       str:=d67(d64(str,65284),16793);
       delete(str,1,1);    //remove random char 2047+
        if ((str[5]=CHRNULL) and (chars_2_word(copy(str,7,2))=word(wh(copy(str,1,4))+14))) then begin
         tot:=chars_2_dword(copy(str,1,4));

        end else begin
         tot:=0;

        end;
       end else tot:=0;
    end else tot:=0;
 end;

 except
 tot:=0;
 end;
end;

procedure reg_zero_avg_uptime;
var
str:string;
buffer:array[0..10] of char;
s : TMemoryStream;
ini:TMemIniFile;
reg:TRegistry;
begin
  reg:=tregistry.create;
  reg.rootkey:=HKEY_CURRENT_USER;

     str:=chr(random(255))+
         int_2_dword_string(0)+
         CHRNULL+
         chr(random(255))+
         int_2_word_string(wh(int_2_dword_string(0))+17);

      str:=e64(e67(str,6793)+CHRNULL,44284);
      move(str[1],buffer,length(str));

      if PortableApp then
      begin
       s := TMemoryStream.Create;
       ini:=TMemIniFile.Create(IniName);
       try
         try
           s.WriteBuffer(buffer[0],sizeof(buffer));
           s.Position:=0;
           ini.WriteBinaryStream('Stats', 'CAvgTime', s);
         except
         end;
       finally
         s.Free;
         ini.UpdateFile;
         ini.Free;
       end;
      end
      else
      reg.writebinarydata(REG_STR_STATS_AVGUPTIME,buffer,length(str));   //update average uptime

end;

procedure stats_uptime_write(start_time:cardinal; totminuptime:cardinal);
var
reg:tregistry;
minutes_this_session,actual_average:integer;
num:cardinal;
str:string;
lenred:integer;
buffer:array[0..10] of char;
s : TMemoryStream;
ini : TMemIniFile;
valueexist:Boolean;
begin
reg:=tregistry.create;
with reg do begin
try
 openkey(areskey,true);
  minutes_this_session:=(gettickcount-start_time) div 60000;

    valueexist:=False;
    if PortableApp then
      begin
       ini := TMemIniFile.Create(IniName);
       try
         try
           valueexist := ini.valueexists('Stats', 'CAvgTime');
         except
         end;
       finally  
         ini.UpdateFile;
         ini.Free;
       end;
      end
      else valueexist := valueexists(REG_STR_STATS_AVGUPTIME);

    if valueexist then begin    //get average uptime

      if PortableApp then
      begin
       s := TMemoryStream.Create;
       ini := TMemIniFile.Create(IniName);
       try
         try
           lenred := ini.ReadBinaryStream('Stats', 'CAvgTime', s);
         except
         end;
       finally
         s.Free;
         ini.UpdateFile;
         ini.Free;
       end;
      end
      else
      lenred := readbinarydata(REG_STR_STATS_AVGUPTIME,buffer,10);
      
      if lenred=10 then begin
       setlength(str,lenred);
       move(buffer,str[1],lenred);
       str:=d67(d64(str,44284),6793);
       delete(str,1,1);    //remove random char 2047+
        if ((str[5]=CHRNULL) and (chars_2_word(copy(str,7,2))=word(wh(copy(str,1,4))+17))) then begin
         actual_average:=chars_2_dword(copy(str,1,4));
         
        end else begin
         actual_average:=0;

        end;
       end else actual_average:=0;
    end else actual_average:=0;

    num:=((actual_average div 5)*4)+(minutes_this_session div 5); //smoth

     str:=chr(random(255))+
         int_2_dword_string(num)+
         CHRNULL+
         chr(random(255))+
         int_2_word_string(wh(int_2_dword_string(num))+17);

      str:=e64(e67(str,6793)+CHRNULL,44284);
      move(str[1],buffer,length(str));

      if PortableApp then
      begin
       s := TMemoryStream.Create;
       ini:=TMemIniFile.Create(IniName);
       try
         try
           s.WriteBuffer(buffer[0],sizeof(buffer));
           s.Position:=0;
           ini.WriteBinaryStream('Stats', 'CAvgTime', s);
         except
         end;
       finally
         s.Free;
         ini.UpdateFile;
         ini.Free;
       end;
      end
      else
      writebinarydata(REG_STR_STATS_AVGUPTIME,buffer,length(str));   //update average uptime




     num:=totminuptime + minutes_this_session;      //write minutes online!
      str:=chr(random(255))+          //now store to registry
           int_2_dword_string(num)+
           CHRNULL+
           chr(random(255))+
           int_2_word_string(wh(int_2_dword_string(num))+14);

      str:=e64(e67(str,16793)+CHRNULL,65284);
      move(str[1],buffer,length(str));

       if PortableApp then
      begin
       s := TMemoryStream.Create;
       ini:=TMemIniFile.Create(IniName);
       try
         try
           s.WriteBuffer(buffer[0],sizeof(buffer));
           s.Position:=0;
           ini.WriteBinaryStream('Stats', 'CTtUptime', s);
         except
         end;
       finally
         s.Free;
         ini.UpdateFile;
         ini.Free;
       end;
      end
      else
      writebinarydata(REG_STR_STATS_TOTUPTIME,buffer,length(str));

 closekey;
except
end;
destroy;
end;
end;

procedure reg_get_megasent(reg:tregistry; var MUp:integer; var MDn:integer);
var
lenred:integer;
str:string;
buffer:array[0..10] of char;
begin
with reg do begin

 //if valueexists('Stats.TMBUpload') then deletevalue('Stats.TMBUpload');
 //if valueexists('Stats.TMBDownload') then deletevalue('Stats.TMBDownload');

 try
 if valueexists(REG_STR_STATSUPHIST) then begin
    try
    lenred:=readbinarydata(REG_STR_STATSUPHIST,buffer,10);
      if lenred=10 then begin
      setlength(str,lenred);
      move(buffer,str[1],lenred);
      str:=d67(d64(str,59812),1451);
       delete(str,1,1);    //remove random char 2047+
        if ((str[5]=CHRNULL) and (chars_2_word(copy(str,7,2))=word(wh(copy(str,1,4))+32))) then begin
         MUp:=chars_2_dword(copy(str,1,4));

        end else begin

         MUp:=0;

        end;
       end else MUp:=0;
    except
     MUp:=0;
    end;
 end else MUp:=0;


 if valueexists(REG_STR_STATSDNHIST) then begin
     try
     lenred:=readbinarydata(REG_STR_STATSDNHIST,buffer,10);
      if lenred=10 then begin
      setlength(str,lenred);
      move(buffer,str[1],lenred);
     str:=d67(d64(str,52812),1481);
      delete(str,1,1);  //remove random char 2047+
        if ((str[5]=CHRNULL) and (chars_2_word(copy(str,7,2))=word(wh(copy(str,1,4))+31))) then begin
         MDn:=chars_2_dword(copy(str,1,4));

        end else begin
         MDn:=0;

        end;
      end else MDn:=0;
     except
      MDn:=0;
     end;
 end else MDn:=0;

 except
 end;

end;
end;



procedure reg_get_transpeed(reg:tregistry; var UpI:cardinal; var DnI:cardinal);
var
lenred:integer;
str:string;
buffer:array[0..10] of char;
ini:TMemIniFile;
s : TMemoryStream;
begin
if PortableApp then
begin
 s := TMemoryStream.Create;
 ini:=TMemIniFile.Create(IniName);
 try
   try
  if ini.valueexists('Stats','CUpSpeed') then begin  //encrypted since 2947+  22/12/2004
   //lenred:=ini.readbinarydata(REG_STR_STATS_UPSPEED,buffer,10);

   lenred:=ini.ReadBinaryStream('Stats', 'CUpSpeed', s);
   s.ReadBuffer(buffer[0],lenred);

   if lenred=10 then begin
     setlength(str,lenred);
     move(buffer,str[1],lenred);
      str:=d67(d64(str,51812),6451);
     delete(str,1,1);    //remove random char 2047+
        if ((str[5]=CHRNULL) and (chars_2_word(copy(str,7,2))=word(wh(copy(str,1,4))+14))) then begin
         UpI:=chars_2_dword(copy(str,1,4));

        end else begin
         UpI:=0;

        end;
   end else UpI:=0;
  end else UpI:=0; // 33 k di default

  if ini.valueexists('Stats','CDnSpeed') then begin
   //lenred:=readbinarydata(REG_STR_STATS_DNSPEED,buffer,10);

   lenred:=ini.ReadBinaryStream('Stats','CDnSpeed', s);
   s.ReadBuffer(buffer[0],lenred);

   if lenred=10 then begin
     setlength(str,lenred);
     move(buffer,str[1],lenred);
      str:=d67(d64(str,31942),7451);
     delete(str,1,1);    //remove random char 2047+
        if ((str[5]=CHRNULL) and (chars_2_word(copy(str,7,2))=word(wh(copy(str,1,4))+15))) then begin
         DnI:=chars_2_dword(copy(str,1,4));

        end else begin
         DnI:=0;

        end;
   end else DnI:=0;
  end else DnI:=0; // 33 k di default
  except
  end;
   {if ini.ReadBinaryStream('Network', 'MDHTID', s) = 20 then begin
     s.ReadBuffer(buffer[0],20);
     CU_INT160_CopyFromBuffer(@buffer[0],id);
   end;}
 finally
   s.Free;
   ini.UpdateFile;
   ini.Free;
 end;
end
else
with reg do begin
 try
  if valueexists(REG_STR_STATS_UPSPEED) then begin  //encrypted since 2947+  22/12/2004
   lenred:=readbinarydata(REG_STR_STATS_UPSPEED,buffer,10);
   if lenred=10 then begin
     setlength(str,lenred);
     move(buffer,str[1],lenred);
      str:=d67(d64(str,51812),6451);
     delete(str,1,1);    //remove random char 2047+
        if ((str[5]=CHRNULL) and (chars_2_word(copy(str,7,2))=word(wh(copy(str,1,4))+14))) then begin
         UpI:=chars_2_dword(copy(str,1,4));

        end else begin
         UpI:=0;

        end;
   end else UpI:=0;
  end else UpI:=0; // 33 k di default

  if valueexists(REG_STR_STATS_DNSPEED) then begin
   lenred:=readbinarydata(REG_STR_STATS_DNSPEED,buffer,10);
   if lenred=10 then begin
     setlength(str,lenred);
     move(buffer,str[1],lenred);
      str:=d67(d64(str,31942),7451);
     delete(str,1,1);    //remove random char 2047+
        if ((str[5]=CHRNULL) and (chars_2_word(copy(str,7,2))=word(wh(copy(str,1,4))+15))) then begin
         DnI:=chars_2_dword(copy(str,1,4));

        end else begin
         DnI:=0;

        end;
   end else DnI:=0;
  end else DnI:=0; // 33 k di default
  except
  end;
 end;
end;




procedure stats_maxspeed_write;
var
reg:tregistry;
media:int64;
str:string;
buffer:array[0..10] of char;
lenred:integer;
s : TMemoryStream;
ini:TMemIniFile;
begin
if PortableApp then
begin
 s := TMemoryStream.Create;
 ini:=TMemIniFile.Create(IniName);
 try
   {try
     s.WriteBuffer(buffer[0],sizeof(buffer));
     s.Position:=0;
     ini.WriteBinaryStream('Network', 'MDHTID', s);
   except
   end;}

   try
 if not ini.valueexists('Stats','CUpSpeed') then begin

    str:=chr(random(255))+
         int_2_dword_string(velocita_up)+
         CHRNULL+
         chr(random(255))+
         int_2_word_string(wh(int_2_dword_string(velocita_up))+14);

      str:=e64(e67(str,6451)+CHRNULL,51812);
      move(str[1],buffer,length(str));
    //reg.writebinarydata(REG_STR_STATS_UPSPEED,buffer,length(str));

     s.WriteBuffer(buffer[0],sizeof(buffer));
     s.Position:=0;
     ini.WriteBinaryStream('Stats', 'CUpSpeed', s);

 end else begin

   //lenred:=readbinarydata(REG_STR_STATS_UPSPEED,buffer,10); //retrieve old value
   lenred:=ini.ReadBinaryStream('Stats','CUpSpeed', s);
   s.ReadBuffer(buffer[0],lenred);

   if lenred=10 then begin
     setlength(str,lenred);
     move(buffer,str[1],lenred);
      str:=d67(d64(str,51812),6451);
     delete(str,1,1);    //remove random char 2047+
        if ((str[5]=CHRNULL) and (chars_2_word(copy(str,7,2))=word(wh(copy(str,1,4))+14))) then begin
         media:=chars_2_dword(copy(str,1,4));

        end else begin
         media:=0;

        end;
    end else media:=0;
    if media>0 then begin     //calculate average sum
      if velocita_up=media then velocita_up:=((media div 10)*9) else
      velocita_up:=((media div 10)*9)+(velocita_up div 10);
    end;

     str:=chr(random(255))+          //now store to registry
          int_2_dword_string(velocita_up)+
          CHRNULL+
          chr(random(255))+
          int_2_word_string(wh(int_2_dword_string(velocita_up))+14);

      str:=e64(e67(str,6451)+CHRNULL,51812);
      move(str[1],buffer,length(str));
    //reg.writebinarydata(REG_STR_STATS_UPSPEED,buffer,length(str));

    s.WriteBuffer(buffer[0],sizeof(buffer));
    s.Position:=0;
    ini.WriteBinaryStream('Stats','CUpSpeed',s);
 end;
 except
 end;



  try
 if not ini.valueexists('Stats','CDnSpeed') then begin

    str:=chr(random(255))+
         int_2_dword_string(velocita_down)+
         CHRNULL+
         chr(random(255))+
         int_2_word_string(wh(int_2_dword_string(velocita_down))+15);

      str:=e64(e67(str,7451)+CHRNULL,31942);
      move(str[1],buffer,length(str));
    //reg.writebinarydata(REG_STR_STATS_DNSPEED,buffer,length(str));

      s.WriteBuffer(buffer[0],sizeof(buffer));
      s.Position:=0;
      ini.WriteBinaryStream('Stats','CDnSpeed',s);
 end else begin

   //lenred:=readbinarydata(REG_STR_STATS_DNSPEED,buffer,10); //retrieve old value
   lenred:=ini.ReadBinaryStream('Stats','CDnSpeed', s);
   s.ReadBuffer(buffer[0],lenred);

   if lenred=10 then begin
     setlength(str,lenred);
     move(buffer,str[1],lenred);
      str:=d67(d64(str,31942),7451);
     delete(str,1,1);    //remove random char 2047+
        if ((str[5]=CHRNULL) and (chars_2_word(copy(str,7,2))=word(wh(copy(str,1,4))+15))) then begin
         media:=chars_2_dword(copy(str,1,4));

        end else begin
         media:=0;

        end;
    end else media:=0;
    if media>0 then begin     //calculate average sum
      if velocita_down=media then velocita_down:=((media div 10)*9) else
      velocita_down:=((media div 10)*9)+(velocita_down div 10);
    end;

     str:=chr(random(255))+          //now store to registry
          int_2_dword_string(velocita_down)+
          CHRNULL+
          chr(random(255))+
          int_2_word_string(wh(int_2_dword_string(velocita_down))+15);

      str:=e64(e67(str,7451)+CHRNULL,31942);
      move(str[1],buffer,length(str));
    //reg.writebinarydata(REG_STR_STATS_DNSPEED,buffer,length(str));

    s.WriteBuffer(buffer[0],sizeof(buffer));
    s.Position:=0;
    ini.WriteBinaryStream('Stats','CDnSpeed',s);
 end;



except
end;

 finally
   ini.UpdateFile;    
   ini.Free;
   s.Free;
 end;
end
else
begin
reg:=tregistry.create;
with reg do begin
 openkey(areskey,true);

 try
 if not valueexists(REG_STR_STATS_UPSPEED) then begin

    str:=chr(random(255))+
         int_2_dword_string(velocita_up)+
         CHRNULL+
         chr(random(255))+
         int_2_word_string(wh(int_2_dword_string(velocita_up))+14);

      str:=e64(e67(str,6451)+CHRNULL,51812);
      move(str[1],buffer,length(str));
    reg.writebinarydata(REG_STR_STATS_UPSPEED,buffer,length(str));
 end else begin

   lenred:=readbinarydata(REG_STR_STATS_UPSPEED,buffer,10); //retrieve old value


   if lenred=10 then begin
     setlength(str,lenred);
     move(buffer,str[1],lenred);
      str:=d67(d64(str,51812),6451);
     delete(str,1,1);    //remove random char 2047+
        if ((str[5]=CHRNULL) and (chars_2_word(copy(str,7,2))=word(wh(copy(str,1,4))+14))) then begin
         media:=chars_2_dword(copy(str,1,4));

        end else begin
         media:=0;

        end;
    end else media:=0;
    if media>0 then begin     //calculate average sum
      if velocita_up=media then velocita_up:=((media div 10)*9) else
      velocita_up:=((media div 10)*9)+(velocita_up div 10);
    end;

     str:=chr(random(255))+          //now store to registry
          int_2_dword_string(velocita_up)+
          CHRNULL+
          chr(random(255))+
          int_2_word_string(wh(int_2_dword_string(velocita_up))+14);

      str:=e64(e67(str,6451)+CHRNULL,51812);
      move(str[1],buffer,length(str));
    reg.writebinarydata(REG_STR_STATS_UPSPEED,buffer,length(str));
 end;
 except
 end;



  try
 if not valueexists(REG_STR_STATS_DNSPEED) then begin

    str:=chr(random(255))+
         int_2_dword_string(velocita_down)+
         CHRNULL+
         chr(random(255))+
         int_2_word_string(wh(int_2_dword_string(velocita_down))+15);

      str:=e64(e67(str,7451)+CHRNULL,31942);
      move(str[1],buffer,length(str));
    reg.writebinarydata(REG_STR_STATS_DNSPEED,buffer,length(str));
 end else begin

   lenred:=readbinarydata(REG_STR_STATS_DNSPEED,buffer,10); //retrieve old value
   if lenred=10 then begin
     setlength(str,lenred);
     move(buffer,str[1],lenred);
      str:=d67(d64(str,31942),7451);
     delete(str,1,1);    //remove random char 2047+
        if ((str[5]=CHRNULL) and (chars_2_word(copy(str,7,2))=word(wh(copy(str,1,4))+15))) then begin
         media:=chars_2_dword(copy(str,1,4));

        end else begin
         media:=0;

        end;
    end else media:=0;
    if media>0 then begin     //calculate average sum
      if velocita_down=media then velocita_down:=((media div 10)*9) else
      velocita_down:=((media div 10)*9)+(velocita_down div 10);
    end;

     str:=chr(random(255))+          //now store to registry
          int_2_dword_string(velocita_down)+
          CHRNULL+
          chr(random(255))+
          int_2_word_string(wh(int_2_dword_string(velocita_down))+15);

      str:=e64(e67(str,7451)+CHRNULL,31942);
      move(str[1],buffer,length(str));
    reg.writebinarydata(REG_STR_STATS_DNSPEED,buffer,length(str));
 end;



except
end;
 closekey;
 destroy;
end;
end;

end;

function regGetMyTorrentFolder(const sharedFolder:widestring):widestring;
var
reg:tregistry;
str:string;
begin
 reg:=tregistry.create;
 with reg do begin
 try
  if openkey(areskey,false) then begin
   str:=hexstr_to_bytestr(readstring('Torrents.Folder'));
   closekey;
  end;
 except
 end;
 destroy;
 end;

 if length(str)>2 then begin
  result:=utf8strtowidestr(str);
 end else begin
  result:=sharedFolder;
 end;
end;

function prendi_reg_my_shared_folder(const data_path:widestring):widestring;
var
reg:tregistry;
str:string;
begin
 reg:=tregistry.create;
 with reg do begin
 try
  if openkey(areskey,false) then begin
   str:=hexstr_to_bytestr(readstring('Download.Folder'));
   closekey;
  end;
 except
 end;
 destroy;
 end;

 if length(str)>2 then begin
  result:=utf8strtowidestr(str);
 end else begin
  result:=data_path+'\'+STR_MYSHAREDFOLDER;
 end;
end;

function prendi_cant_supernode:boolean; //non possiamo, true se non possiamo
var reg:tregistry;
begin
reg:=tregistry.create;
with reg do begin
 try
 openkey(areskey,true);

 if valueexists('Network.NoSupernode') then begin
  result:=(readinteger('Network.NoSupernode')=1);
 end else result:=false;

 closekey;
 except
 result:=true;
 end;
 destroy;
end;
end;

function reg_get_avgUptime:integer;
var
reg:tregistry;
lenred:integer;
str:string;
buffer:array[0..10] of char;
valueexist:Boolean;
ini : TMemIniFile;
s : TMemoryStream;
begin
result:=0;

reg:=tregistry.create;
with reg do begin
 try
  openkey(areskey,true);

     valueexist:=False;
    if PortableApp then
      begin
       ini := TMemIniFile.Create(IniName);
       try
         try
           valueexist := ini.valueexists('Stats', 'CAvgTime');
         except
         end;
       finally  
         ini.UpdateFile;
         ini.Free;
       end;
      end
      else valueexist := valueexists(REG_STR_STATS_AVGUPTIME);

     if valueexist then begin    //get average uptime

      if PortableApp then
      begin
       s := TMemoryStream.Create;
       ini := TMemIniFile.Create(IniName);
       try
         try
           lenred := ini.ReadBinaryStream('Stats', 'CAvgTime', s);
         except
         end;
       finally
         s.Free;
         ini.UpdateFile;
         ini.Free;
       end;
      end
      else
      lenred:=readbinarydata(REG_STR_STATS_AVGUPTIME,buffer,10);

      if lenred=10 then begin
       setlength(str,lenred);
       move(buffer,str[1],lenred);
       str:=d67(d64(str,44284),6793);
       delete(str,1,1);    //remove random char 2047+
        if ((str[5]=CHRNULL) and (chars_2_word(copy(str,7,2))=word(wh(copy(str,1,4))+17))) then begin
         result:=chars_2_dword(copy(str,1,4));

        end else begin
         result:=0;

        end;
       end else result:=0;
    end else result:=0;

  closekey;
 except
 end;
 destroy;
end;
end;

function get_default_upload_height(maxHeight:integer):integer;
var
reg:tregistry;
begin
  result:=120;
  reg:=tregistry.create;
  with reg do begin
  try
  openkey(areskey,true);

   if valueexists('GUI.UpHeight') then begin
    result:=readinteger('GUI.UpHeight');
    deletevalue('GUI.UpHeight');
    closekey;
    openkey(areskey+'\Bounds',true);
    writeinteger('UpHeight',result);
   end else begin
    closekey;
    openkey(areskey+'\Bounds',true);
    if valueExists('UpHeight') then result:=readinteger('UpHeight')
     else result:=120;
   end;

  closekey;
  except
  end;
  destroy;
  end;

if result<20 then result:=20 else
if result>maxHeight then result:=maxHeight;
end;

procedure write_default_upload_height;
var
reg:tregistry;
begin
reg:=tregistry.create;
with reg do begin
 try
 openkey(areskey+'\Bounds',true);
 writeinteger('UpHeight',vars_global.panelUploadHeight);
 closekey;
 except
 end;
 destroy;
end;
end;

function prendi_my_pgui(reg:tregistry):string;
var
guid:tguid;
str:string;
ini:TMemIniFile;
begin
if PortableApp then
begin
 ini:=TMemIniFile.Create(IniName);
 try
   try
     str:=ini.ReadString('Personal','GUID','');
     if length(str)<>32 then ini.writestring('Personal','GUID','')
     else result:=hexstr_to_bytestr(ini.readstring('Personal','GUID',''));

     if length(result)<>16 then
     begin
       fillchar(guid,sizeof(tguid),0);
       CoInitialize(nil);
       cocreateguid(guid);
       CounInitialize;
       setlength(result,16);
       move(guid,result[1],sizeof(tguid));
       ini.writestring('Personal','GUID',bytestr_to_hexstr(result));
     end;
   except
   end;
 finally
   ini.UpdateFile;
   ini.Free;
 end;
end
else
begin
try
with reg do begin
str:=readstring('Personal.GUID');
   if length(str)<>32 then writestring('Personal.GUID','')
   else result:=hexstr_to_bytestr(readstring('Personal.GUID'));

 if length(result)<>16 then begin
  fillchar(guid,sizeof(tguid),0);
  CoInitialize(nil);
  cocreateguid(guid);
  CounInitialize;
  setlength(result,16);
  move(guid,result[1],sizeof(tguid)); 
  writestring('Personal.GUID',bytestr_to_hexstr(result));
 end;
end;

except
end;
end;
end;

function prendi_mynick(reg:tregistry):string;
var
str:string;
begin
 str:=hexstr_to_bytestr(reg.readstring('Personal.Nickname'));
 str:=copy(str,1,20);
 result:=widestrtoutf8str( strippa_fastidiosi( utf8strtowidestr(str),'_'));
end;

function getDataPort(reg:tregistry):word;
var
s : TMemoryStream;
 ini:TMemIniFile;
begin
if PortableApp then
begin
 s := TMemoryStream.Create;
 ini:=TMemIniFile.Create(IniName);
 try
   {try
     s.WriteBuffer(buffer[0],sizeof(buffer));
     s.Position:=0;
     ini.WriteBinaryStream('Network', 'MDHTID', s);
   except
   end;}
   try
with reg do begin
 if Ini.valueexists('Transfer','ServerPort') then
 begin
   //result:=readinteger('Transfer.ServerPort');
   result:= Ini.ReadInteger('Transfer','ServerPort', random(50000)+1024)
 end
 else begin
    repeat
      result:=random(50000)+1024;
       if result=1214 then continue else
        if result=6346 then continue else
         if result=8888 then continue else
          if result=3306 then continue;
      break;
    until (not true);
   //writeinteger('Transfer.ServerPort',result);
   ini.WriteInteger('Transfer','ServerPort', result);
 end;
end;

 except
  result:=80;
 end;
 finally
   s.Free;
   ini.UpdateFile;
   ini.Free;
 end;
end
else
begin
 try
with reg do begin
 if valueexists('Transfer.ServerPort') then result:=readinteger('Transfer.ServerPort') else begin
    repeat
      result:=random(50000)+1024;
       if result=1214 then continue else
        if result=6346 then continue else
         if result=8888 then continue else
          if result=3306 then continue;
      break;
    until (not true);
   writeinteger('Transfer.ServerPort',result);
 end;
end;

 except
  result:=80;
 end;
end;
end;

function getmdhtPort(reg:tregistry):word;
var valueexist:Boolean;
ini: TMemIniFile;
begin
 try
with reg do begin

 valueexist := False;
 if PortableApp then
 begin
  ini:=TMemIniFile.Create(IniName);
  try
    //ini.WriteString('ini_section','parameter1','value');
    //ini.WriteInteger('ini_section','parameter2', 100);
    valueexist := Ini.valueexists('Torrent','mdhtPort');
  finally
    ini.UpdateFile;
    ini.Free;
  end;
 end
 else valueexist := valueexists('Torrent.mdhtPort');

 if valueexist then
 begin
 if PortableApp then
 begin
  ini:=TMemIniFile.Create(IniName);
  try
    result := Ini.readinteger('Torrent','mdhtPort',0);
  finally
    ini.UpdateFile;
    ini.Free;
  end;
 end
 else
 result:=readinteger('Torrent.mdhtPort');
 end
 else begin
    repeat
      result:=random(50000)+1024;
       if result=1214 then continue else
        if result=6346 then continue else
         if result=8888 then continue else
          if result=3306 then continue;
      break;
    until (not true);

   if PortableApp then
   begin
    ini:=TMemIniFile.Create(IniName);
    try
      Ini.WriteInteger('Torrent','mdhtPort',result);
    finally
      ini.UpdateFile;
      ini.Free;
    end;
   end
   else
   writeinteger('Torrent.mdhtPort',result);
 end;
end;

 except
  result:=80;
 end;
end;

function reg_bannato(const ip:string):boolean;
var
reg:tregistry;
begin
result:=false;

reg:=tregistry.create;
with reg do begin
 try
 openkey(areskey+'banned',true);
  result:=ValueExists(ip);
 closekey;
 except
 end;
 destroy;
end;

end;

end.
