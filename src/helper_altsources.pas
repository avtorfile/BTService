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
misc functions to handle alternate sources (download MESH) and hash_results_hits
}

unit helper_altsources;

interface

uses
ares_types,ares_objects,classes2,classes,windows,sysutils{,comettrees};

procedure parse_alternate_source(download:tdownload; const altStr:string);
function get_altsource_string(download:tdownload;risorsa:trisorsa_download; binary:boolean):string;
function get_serialized_altsources(download:tdownload):string;
procedure free_worst_source(download:tdownload);
procedure add_sources(download:tdownload; sources:string; newtype:boolean);
//procedure chatclient_add_source_download_frombrowse(pannello_browse:precord_pannello_browse_chat; presult_browse_globale:precord_file_library); //synch
//procedure chatclient_add_source_download_fromresult(presult_globale_search:precord_file_result_chat);//synch
//procedure gui_add_sources_ares(listview:tcomettree; download:tdownload; selected_node:pcmtvnode; datao:precord_search_result);
procedure add_child_chatsource_to_down(down:tdownload; datao:precord_file_result_chat);
//procedure add_source_download_browse(pfile:precord_file_library; pannello_browse:precord_pannello_browse_chat); //synch  chatserver
procedure parse_Binary_altsources(download:tdownload; altStr:string);
procedure add_source(download:tdownload; ip_server:cardinal; port_server:word; ip_user:cardinal; port_user:word);


implementation

uses
{ufrmmain,}helper_strings,helper_sorting,const_ares,
helper_ipfunc,vars_global;


{procedure add_source_download_browse(pfile:precord_file_library; pannello_browse:precord_pannello_browse_chat); //synch  chatserver
var
risorsa:trisorsa_download;
node:pCmtVnode;
dataNode:precord_data_node;
DnData:precord_displayed_download;
crcsha1:word;
fhandle_download:cardinal;
list:tlist;
begin      //ci manca id download
fhandle_download:=INVALID_HANDLE_VALUE;

try
crcsha1:=crcstring(pfile^.hash_sha1);

node:=ares_FrmMain.treeview_download.getfirst;
while (node<>nil) do begin

 dataNode:=ares_FrmMain.treeview_download.getdata(node);
 if dataNode^.m_type<>dnt_download then begin
  node:=ares_FrmMain.treeview_download.getnextsibling(node);
  continue;
 end;

 DnData:=dataNode^.data;
 if DnData^.handle_obj<>INVALID_HANDLE_VALUE then
  if DnData^.crcsha1=crcsha1 then
   if DnData^.hash_sha1=pfile^.hash_sha1 then
    if DnData^.hash_sha1<>'' then begin
      fhandle_download:=DnData^.handle_obj;
      break;
    end;

   node:=ares_FrmMain.treeview_download.getnextsibling(node);
end;

if fHandle_download=INVALID_HANDLE_VALUE then exit;


 risorsa:=trisorsa_download.create;
  with risorsa do begin
   InsertServer(pannello_browse^.ip_server,pannello_browse^.port_server);
   ip:=pannello_browse^.ip_user;
   porta:=pannello_browse^.port_user;
   handle_download:=fhandle_download;
   ip_interno:=pannello_browse^.ip_alt;

    if pos('@',pannello_browse^.nick)=0 then nickname:=pannello_browse^.nick+STR_UNKNOWNCLIENT
     else nickname:=pannello_browse^.nick; //contiene anche @agent nei nuovi servers

      tick_attivazione:=0;
      socket:=nil;
  end;
      list:=lista_risorse_temp.locklist;
       list.add(risorsa);
      lista_risorse_temp.unlocklist
except
end;
end;
}
procedure add_child_chatsource_to_down(down:tdownload; datao:precord_file_result_chat);
var
risorsa:trisorsa_download;
begin
 risorsa:=trisorsa_download.create;
 with risorsa do begin
  handle_download:=cardinal(down);
  nickname:=datao^.nickname;
  ip_interno:=datao^.ip_alt;
  ip:=datao^.ip_user;
  porta:=datao^.port_user;
  InsertServer(datao^.ip_server,datao^.port_server);
  download:=down;
  origfilename:=datao^.filename;
//  addVisualReference;
 end;
   down.lista_risorse.add(risorsa);
end;

{procedure gui_add_sources_ares(listview:tcomettree; download:tdownload; selected_node:pcmtvnode; datao:precord_search_result);
var
risorsa:trisorsa_download;
node:pcmtvnode;
datachild:precord_search_result;
begin

if selected_node.childcount>0 then begin

 node:=listview.getfirstchild(selected_node);
 while (node<>nil) do begin

     datachild:=listview.getdata(node);

       risorsa:=trisorsa_download.create;
       risorsa.handle_download:=cardinal(download);
       risorsa.download:=download;

        with risorsa do begin
          InsertServer(datachild^.ip_server,datachild^.port_server);
          ip:=datachild^.ip_user;
          porta:=datachild^.port_user;
          ip_interno:=datachild^.ip_alt;
          origfilename:=datachild^.filenameS;
          nickname:=datachild^.nickname;
          tick_attivazione:=0;
          socket:=nil;
          AddVisualReference;
        end;
         download.lista_risorse.add(risorsa);
  node:=listview.getnextsibling(node);
  end;
 exit;
end;




      risorsa:=trisorsa_download.create;
       risorsa.handle_download:=cardinal(download);
       risorsa.download:=download;
        with risorsa do begin
          InsertServer(datao^.ip_server,datao^.port_server);
          ip:=datao^.ip_user;
          porta:=datao^.port_user;
          ip_interno:=datao^.ip_alt;
          origfilename:=datao^.filenameS;
          nickname:=datao^.nickname;
          tick_attivazione:=0;
          socket:=nil;
          AddVisualReference;
         end;

    download.lista_risorse.add(risorsa);

end;}

{procedure chatclient_add_source_download_fromresult(presult_globale_search:precord_file_result_chat);//synch
var
risorsa:trisorsa_download;
node:pCmtVnode;
dataNode:precord_data_node;
DnData:precord_displayed_download;
crcsha1:word;
list:tlist;
begin     
try

crcsha1:=crcstring(presult_globale_search^.hash_sha1);

node:=ares_FrmMain.treeview_download.getfirst;
while (node<>nil) do begin

     dataNode:=ares_FrmMain.treeview_download.getdata(node);
     if dataNOde^.m_type<>dnt_download then begin
      node:=ares_FrmMain.treeview_download.getnextsibling(node);
      continue;
     end;

     DnData:=dataNode^.data;
     if DnData^.handle_obj<>INVALID_HANDLE_VALUE then
      if DnData^.crcsha1=crcsha1 then
       if DnData^.hash_sha1=presult_globale_search^.hash_sha1 then
        if DnData^.hash_sha1<>'' then begin
             risorsa:=trisorsa_download.create;
             with risorsa do begin
              InsertServer(presult_globale_search^.ip_server,presult_globale_search^.port_server);
              ip:=presult_globale_search^.ip_user;
              porta:=presult_globale_search^.port_user;
              handle_download:=DnData^.handle_obj;
              ip_interno:=presult_globale_search^.ip_alt;
              origfilename:=presult_globale_search^.filename;
                if pos('@',presult_globale_search^.nickname)=0 then nickname:=presult_globale_search^.nickname+STR_UNKNOWNCLIENT else
              nickname:=presult_globale_search^.nickname; //contiene anche @agent nei nuovi servers
              tick_attivazione:=0;
              socket:=nil;
             end;
             list:=vars_global.lista_risorse_temp.locklist;
              list.add(risorsa);
             vars_global.lista_risorse_temp.unlocklist;
          break;
        end;
    node:=ares_FrmMain.treeview_download.getnextsibling(node);
end;


except
end;
end;
}
{procedure chatclient_add_source_download_frombrowse(pannello_browse:precord_pannello_browse_chat; presult_browse_globale:precord_file_library); //synch
var
risorsa:trisorsa_download;
node:pCmtVnode;
dataNode:precord_data_node;
DnData:precord_displayed_download;
crcsha1:word;
list:tlist;
begin     
try

crcsha1:=crcstring(presult_browse_globale^.hash_sha1);

node:=ares_FrmMain.treeview_download.getfirst;
while (node<>nil) do begin
     dataNode:=ares_FrmMain.treeview_download.getdata(node);

     if dataNode^.m_type<>dnt_download then begin
      node:=ares_FrmMain.treeview_download.getnextsibling(node);
      continue;
     end;

     DnData:=datanode^.data;
     if DnData^.handle_obj<>INVALID_HANDLE_VALUE then
      if DnData^.crcsha1=crcsha1 then
       if DnData^.hash_sha1=presult_browse_globale^.hash_sha1 then
        if DnData^.hash_sha1<>'' then begin
           risorsa:=trisorsa_download.create;
             with risorsa do begin
              InsertServer(pannello_browse^.ip_server,pannello_browse^.port_server);
              ip:=pannello_browse^.ip_user;
              porta:=pannello_browse^.port_user;
              handle_download:=DnData^.handle_obj;
              ip_interno:=pannello_browse^.ip_alt;
              if pos('@',pannello_browse^.nick)=0 then nickname:=pannello_browse^.nick+STR_UNKNOWNCLIENT
                else nickname:=pannello_browse^.nick; //contiene anche @agent nei nuovi servers
              tick_attivazione:=0;
              socket:=nil;
             end;
             list:=vars_global.lista_risorse_temp.locklist;
              list.add(risorsa);
             vars_global.lista_risorse_temp.unlocklist;
            break;
         end;
         
  node:=ares_FrmMain.treeview_download.getnextsibling(node);
end;


except
end;
end;
}
procedure add_sources(download:tdownload; sources:string; newtype:boolean);
var
ip,ip_server,ip_alt:cardinal;
port,port_server:word;
risorsa:trisorsa_download;
addedcount:integer;
begin
addedcount:=0;

 while true do begin

    if newtype then if length(sources)<17 then exit;
    if not newtype then if length(sources)<12 then exit;

     ip:=chars_2_dword(copy(sources,1,4));
     port:=chars_2_word(copy(sources,5,2));

     ip_server:=chars_2_dword(copy(sources,7,4));
     port_server:=chars_2_word(copy(sources,11,2));

    if newtype then begin
     ip_alt:=chars_2_dword(copy(sources,13,4));
     delete(sources,1,17);
    end else begin
     ip_alt:=0;
     delete(sources,1,12);
    end;

    if ip=0 then continue;
    if port=0 then continue;

    if isAntiP2PIP(ip) then continue;
    if isAntiP2PIP(ip_server) then continue;

      risorsa:=trisorsa_download.create;
      if download.state=dlPaused then risorsa.state:=srs_paused;


     risorsa.handle_download:=cardinal(download);
     risorsa.nickname:=copy(STR_ANON,1,length(STR_ANON))+inttohex(random(255),2)+inttohex(random(255),2)+copy(STR_UNKNOWNCLIENT,1,length(STR_UNKNOWNCLIENT));
     risorsa.ip:=ip;
     risorsa.porta:=port;
     risorsa.InsertServer(ip_server,port_server);
      risorsa.ip_interno:=ip_alt;
     risorsa.download:=download;
//     vars_global.thread_down.synchronize(vars_global.thread_down,risorsa.AddVisualReference);
      download.listA_risorse.add(risorsa);
      inc(addedcount);
      if addedcount>=MAX_NUM_SOURCES then break;
       sleep(3);
 end;
end;

function get_serialized_altsources(download:tdownload):string;
var
i,addedcount:integer;
risorsa:trisorsa_download;
begin
result:='';

   download.lista_risorse.sort(ordina_risorse_peggiore_prima);  //registriamo le prime più funzionanti  e solo la metà(35)

   addedcount:=0;

   for i:=download.lista_risorse.count-1 downto 0 do begin
    risorsa:=download.lista_risorse[i];
     if risorsa.ICH_failed then continue;
      if risorsa.ip=0 then continue;

    with risorsa do
     result:=result+int_2_dword_string(ip)+
                    int_2_word_string(porta)+
                    GetFirstBinaryServerStr+
                    int_2_dword_string(ip_interno)+
                    CHRNULL; //spazio libero...

                    inc(addedcount);
                    if (addedcount>=MAX_NUM_SOURCES div 2) then break;
   end;

end;

function get_altsource_string(download:tdownload; risorsa:trisorsa_download; binary:boolean):string;
var

i:integer;
source:trisorsa_download;
begin
result:='';

try
if download.lista_risorse.count>6 then shuffle_mylist(download.lista_risorse,0);


for i:=0 to download.lista_risorse.count-1 do begin
 source:=download.lista_risorse[i];
 if source=risorsa then continue;
 if not source.ICH_passed then continue;

  result:=result+source.GetFirstBinaryServerStr+
                 int_2_dword_string(source.ip)+int_2_word_string(source.porta);


  if length(result)=60 then break;
end;


except
end;
end;

procedure parse_Binary_altsources(download:tdownload; altStr:string);
var
ip_server,ip_user:cardinal;
port_server,port_user:cardinal;
begin

while (length(altStr)>=12) do begin
 ip_server:=chars_2_dword(copy(altStr,1,4));
 port_serveR:=chars_2_word(copy(altStr,5,2));
 ip_user:=chars_2_dword(copy(altStr,7,4));
 port_user:=chars_2_word(copy(altStr,11,2));
  Delete(altStr,1,12);
 helper_altsources.add_source(download,ip_server,port_server,ip_user,port_user);
end;

end;

procedure parse_alternate_source(download:tdownload; const altStr:string);
var
ip_server,ips,strtemp:string;
ipsi,ipi:cardinal; // int ip server
port_server,port_user:word;
begin

try

strtemp:=copy(altStr,pos('|',altStr)+1,length(altStr));
 ips:=copy(strtemp,1,pos(':',strtemp)-1);
delete(strtemp,1,pos(':',strtemp));
 port_user:=strtointdef( strtemp ,0);

strtemp:=copy(altStr,1,pos('|',altStr)-1);
 ip_server:=copy(strtemp,1,pos(':',strtemp)-1);
delete(strtemp,1,pos(':',strtemp));
 port_server:=strtointdef( strtemp ,0);

 if not is_ip(ips) then exit;
 if ips=localip then exit;

ipi:=inet_addr(pchar(ips));
ipsi:=inet_addr(pchar(ip_server));

helper_altsources.add_source(download,ipsi,port_server,ipi,port_user);
except
end;

end;

procedure add_source(download:tdownload; ip_server:cardinal; port_server:word; ip_user:cardinal; port_user:word);
var
i:integer;
risorsaz:trisorsA_download;
begin
try

 if port_server=0 then exit;
  if port_user=0 then exit;
   if ip_firewalled(ip_user) then exit;
    if ip_firewalled(ip_server) then exit;
     if isAntiP2PIP(ip_user) then exit;
      if isAntiP2PIP(ip_server) then exit;

 if download.isBannedIp(ip_user) then exit;

 for i:=0 to download.lista_risorse.count-1 do begin
 risorsaz:=download.lista_risorse[i];
   if risorsaz.ip<>ip_user then continue;
      if ((risorsaz.queued_position=0) and
          (risorsaz.state<>srs_receiving)) then risorsaz.InsertServer(ip_server,port_server);
     exit;
 end;

  if download.tipo=ARES_MIME_VIDEO then begin
   if download.listA_risorse.count>=(MAX_NUM_SOURCES*2) then free_worst_source(download);
  end else begin
   if download.listA_risorse.count>=MAX_NUM_SOURCES then free_worst_source(download);
  end;

  risorsaz:=trisorsa_download.create;

   if download.state=dlPaused then risorsaz.state:=srs_paused;
  risorsaz.handle_download:=cardinal(download);
  risorsaz.nickname:='mesh'+lowercase(inttohex(random(255),2)+inttohex(random(255),2))+STR_UNKNOWNCLIENT;
  risorsaz.ip:=ip_user;
  risorsaz.porta:=port_user;
  risorsaz.InsertServer(ip_server,port_server);
  risorsaz.download:=download;
//   vars_global.thread_down.synchronize(vars_global.thread_down,risorsaz.addVisualReference);
   download.lista_risorse.add(risorsaz);


except
end;

end;

procedure free_worst_source(download:tdownload);
var
h:integer;
risorsa:trisorsa_download;
begin
try

 download.lista_risorse.sort(ordina_risorse_peggiore_prima);

 for h:=0 to download.lista_risorse.count-1 do begin //ora proviamo risorsa in attesa
  risorsa:=download.lista_risorse[h];
  if risorsa.state<>srs_idle then continue;
  if risorsa.queued_position<>0 then continue;
  download.lista_risorse.delete(h);
  risorsa.free;
  exit;
 end;

 for h:=0 to download.lista_risorse.count-1 do begin //ora proviamo waiting for push
  risorsa:=download.lista_risorse[h];
   if risorsa.state<>srs_waitingPush then continue;
  download.lista_risorse.delete(h);
  risorsa.free;
  exit;
 end;

  for h:=0 to download.lista_risorse.count-1 do begin //ora proviamo firewalled
   risorsa:=download.lista_risorse[h];
    if risorsa.state<>srs_waitingIcomingConnection then continue;
  download.lista_risorse.delete(h);
  risorsa.free;
  exit;
 end;

 except
 end;
end;


procedure partial_add_mesh_source(strin:string; download:tdownload);  //qui ricevo un xtreeroot, vedo se l'ho già e lo aggiungo a lista xtree root di download
var
ip,ip_server:cardinal;
port,port_server:word;
risorsaz:trisorsa_download;
add:boolean;
ips:string;
i:integer;
begin //qui estraiamo sorgenti alt ma in formato nuovo
exit;
try

while (length(strin)>=12) do begin

ip_server:=chars_2_dword(copy(strin,1,4));
port_server:=chars_2_word(copy(strin,5,2));
ip:=chars_2_dword(copy(strin,7,4));
port:=chars_2_word(copy(strin,11,2));
 delete(strin,1,12);

if isAntiP2PIP(ip) then continue;
if isAntiP2PIP(ip_server) then continue;

 ips:=ipint_to_dotstring(ip);
 if ips=localip then continue;
 if ip_firewalled(ips) then continue;

//if add then
add:=(not download.isBannedIp(ip));

if add then
for i:=0 to download.lista_risorse.count-1 do begin
 risorsaz:=download.lista_risorse[i];
   if risorsaz.ip<>ip then continue; //controllo brutale, evitiamo duplicati subito
      if ((risorsaz.queued_position=0) and
          (risorsaz.state<>srs_receiving)) then risorsaz.InsertServer(ip_server,port_server);
     add:=false;
     break;
end;

 if download.listA_risorse.count>=MAX_NUM_SOURCES then add:=False;

 if add then begin   // ce ne freghiamo e prolunghiamo vita a systemtime della risorsa?? o parsiamo systemtime...mmh
    risorsaz:=trisorsa_download.create;
     if download.state=dlPaused then risorsaz.state:=srs_paused;
    risorsaz.handle_download:=cardinal(download);
    risorsaz.nickname:=ipdotstring_to_anonnick(ipint_to_dotstring(ip))+STR_UNKNOWNCLIENT;
    risorsaz.ip:=ip;
    risorsaz.porta:=port;
    risorsaz.InsertServer(ip_server,port_server);
    risorsaz.download:=download;
     download.listA_risorse.add(risorsaz);

     sleep(3);
 end;

end;

except
end;
end;

end.
