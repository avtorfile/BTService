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

unit helper_ares_nodes;

interface

uses
 classes,classes2,windows,sysutils,registry,ares_objects,math,blcksock;

 const
 MAX_SAVED_NODES=400;
 MAX_SAVED_HARDFAILED_NODES=1000;
 MIN_SUPERNODE_RECONNECT_INTERVAL=1200;

 type
 precord_ipc=^record_IPc;
 record_IPc=record
  ip:cardinal;
 end;

  type
 tthread_check_supernode=class(tthread)
 protected
  procedure execute; override;
  function connect:boolean;
 end;

procedure aresnodes_savetodisk(nodes:tlist); overload;
procedure aresnodes_savetodisk(nodes:tthreadlist); overload;
procedure aresnodes_loadfromdisk(nodes:tthreadlist);   // load from registry
procedure get_bootstrap_nodes_from_reg(nodes:tthreadlist); //prendiamo ipdword+portword da reg
procedure aresnodes_addreported(hostS:string; portW:word; nodes:tthreadlist);
procedure aresnodes_purge_exceeding(nodes:tlist);
procedure aresnodes_putDisconnected(node:tares_node);
procedure aresnodes_putConnected(node:tares_node); overload;
procedure aresnodes_putConnected(ipS:string; portW:word; nodes:tthreadlist); overload;
function aresnodes_getsuitable(nodes:tthreadlist):tares_node;
procedure aresnodes_putFailed(node:tares_node);
procedure aresnodes_removenode(node:tares_node);
procedure aresnodes_loadaddresses(outlist:tmystringlist; max_count:integer);
procedure aresnodes_add_candidates(candidates:tmystringlist; nodes:tthreadlist); overload;
procedure aresnodes_add_candidates(tmpstr:string; nodes:tthreadlist); overload;
procedure aresnodes_add_candidate(ip_server:cardinal; port_server:word; nodes:tthreadlist);
procedure checkNeedRefreshSnodesChat;

procedure aresnodes_FreeList(nodes:tthreadList);

function isHardFailed(ip:cardinal):boolean;
procedure AddHardFailedIP(ip:cardinal);
procedure SaveHardFailedIPs;
procedure LoadHardFailedIPs;

var
db_nodes_oldest_last_seen:cardinal;
HardFailed:tmylist;

implementation

uses
 const_ares,helper_diskio,vars_global,helper_crypt,{tntwindows,}
 helper_strings,helper_ipfunc,helper_datetime,helper_sorting,
 helper_sockets,helper_registry;


procedure tthread_check_supernode.execute;
var
tries:byte;
begin
priority:=tpnormal;
freeonterminate:=false;//freeonterminate:=true;

tries:=0;
while not connect do begin
 inc(tries);
 if tries>=10 then break;
 sleep(10);
end;

end;

function tthread_check_supernode.connect:boolean;
var
 socket:ttcpblocksocket;
 er:integer;
 checktime:cardinal;

 nodes:Tlist;
 node:tares_node;
 ipC:cardinal;
 aportW:word;
 ipS:string;
begin
result:=false;

ipC:=0;
aportW:=0;
nodes:=ares_aval_nodes.Locklist;
try

   if nodes.count>1 then begin
    node:=nodes[random(nodes.count)];
    ipC:=inet_addr(pchar(node.host));
    ipS:=node.host;
    aportW:=node.port;
    inc(node.attempts);
   end;

except
end;
ares_aval_nodes.UnLocklist;

if ipC=0 then exit;
if aportW=0 then exit;

socket:=TTCPBlockSocket.create(true);
 socket.ip:=ipS;
 socket.port:=aportW;
 helper_sockets.assign_proxy_settings(socket);

 socket.Connect(socket.ip,inttostr(socket.port));

 checktime:=gettickcount;
 while (true) do begin

   if gettickcount-checktime>15000 then begin
    socket.free;
    exit;
   end;

   er:=TCPSocket_ISConnected(socket);

   if er=0 then begin
    aresnodes_putConnected(ipS,aportW,ares_aval_nodes);
    sleep(500);
    helper_ares_nodes.aresnodes_addreported(ipS,aportW,ares_aval_nodes); //keep lastseen up to date
    result:=true;
    break;
   end;

   sleep(30);
 end;

socket.free;
end;


{
procedure clear_nodes_db;
begin
try
helper_diskio.deletefileW(data_path+'\Data\SNodes.dat');
helper_diskio.deletefileW(data_path+'\Data\SNodes');
helper_diskio.deletefileW(app_path+'\Data\SNodes.dat');
helper_diskio.deletefileW(app_path+'\Data\SNodes');
helper_diskio.deletefileW(data_path+'\Data\FailedSNodes.dat');
helper_diskio.deletefileW(data_path+'\Data\FailedSNodes');
helper_diskio.deletefileW(app_path+'\Data\FailedSNodes.dat');
helper_diskio.deletefileW(app_path+'\Data\FailedSNodes');
except
end;
end; }

procedure aresnodes_FreeList(nodes:tthreadList);
var
 list:tlist;
 nodo_ares:tares_node;
begin
list:=nodes.locklist;
try
 while (list.count>0) do begin
  nodo_ares:=list[list.count-1];
             list.delete(list.count-1);
  nodo_ares.free;
 end;
except
end;
nodes.unlocklist;
nodes.free;
end;

procedure aresnodes_savetodisk(nodes:tlist);
var
 stream:thandlestream;
 i,saved:integer;
 nodo_ares:tares_node;
 str:string;
 buffer:array[0..511] of char;
begin

SaveHardFailedIPs;

saved:=0;
     stream:=MyFileOpen(data_path+'\Data\SNodes.dat',ARES_OVERWRITE_EXISTING);
     if stream=nil then exit;


    try
    nodes.sort(sort_aresnodes_bestrating);

    for i:=0 to nodes.count-1 do begin
     nodo_ares:=nodes[i];
     if nodo_ares.host='127.0.0.1' then continue;
     //if nodo_ares.connects=0 then continue;

       str:=nodo_ares.host+' '+
            inttostr(nodo_ares.port)+' '+
            inttostr(nodo_ares.reports)+' '+
            inttostr(nodo_ares.attempts)+' '+
            inttostr(nodo_ares.connects)+' '+
            inttostr(nodo_ares.first_seen)+' '+
            inttostr(nodo_ares.last_seen)+' '+
            inttostr(nodo_ares.last_attempt)+' '+
            CRLF;

     move(str[1],buffer[0],length(str));
     stream.write(buffer,length(str));
     inc(saved);
     if saved>=MAX_SAVED_NODES then break;
    end;
   except
   end;


    FreeHandleStream(stream);

    try
    helper_diskio.deletefileW(data_path+'\Data\SNodes');
    helper_diskio.deletefileW(app_path+'\Data\SNodes');
    helper_diskio.deletefileW(app_path+'\Data\SNodes.dat');
    except
    end;
end;

procedure aresnodes_savetodisk(nodes:tthreadlist);
var
 stream:thandlestream;
 i,saved:integer;
 nodo_ares:tares_node;
 str:string;
 buffer:array[0..511] of char;
 locknodes:tlist;
begin

SaveHardFailedIPs;

     saved:=0;
     stream:=MyFileOpen(data_path+'\Data\SNodes.dat',ARES_OVERWRITE_EXISTING);
     if stream=nil then exit;

  locknodes:=nodes.locklist;
  try
    locknodes.sort(sort_aresnodes_bestrating);

    for i:=0 to locknodes.count-1 do begin
     nodo_ares:=locknodes[i];
     if nodo_ares.host='127.0.0.1' then continue;
     //if nodo_ares.connects=0 then continue;

       str:=nodo_ares.host+' '+
            inttostr(nodo_ares.port)+' '+
            inttostr(nodo_ares.reports)+' '+
            inttostr(nodo_ares.attempts)+' '+
            inttostr(nodo_ares.connects)+' '+
            inttostr(nodo_ares.first_seen)+' '+
            inttostr(nodo_ares.last_seen)+' '+
            inttostr(nodo_ares.last_attempt)+' '+
            CRLF;

     move(str[1],buffer[0],length(str));
     stream.write(buffer,length(str));
     inc(saved);
     if saved>=MAX_SAVED_NODES then break;
    end;

   except
   end;
   nodes.unlocklist;


    FreeHandleStream(stream);

    try
    helper_diskio.deletefileW(data_path+'\Data\SNodes');
    helper_diskio.deletefileW(app_path+'\Data\SNodes');
    helper_diskio.deletefileW(app_path+'\Data\SNodes.dat');
    except
    end;
end;

procedure get_bootstrap_nodes_from_reg(nodes:tthreadlist); //prendiamo ipdword+portword da reg
var
 reg:tregistry;
 i:integer;
 stringa:string;
 lun_to,lun_got:integer;
 buffer:array[0..599] of byte; // 20 max
 host:string;
 nodo_ares:tares_node;
 locklist:tlist;
begin


 reg:=tregistry.create;
with reg do begin

  try
 if not openkey(areskey+getdatastr,false) then begin
  destroy;
  exit;
 end;


    if not valueexists(GetAresNet2) then begin
     closekey;
     destroy;
     exit;
    end;

     lun_to:=GetDataSize(GetAresNet2);
     if lun_to=0 then begin
      closekey;
      destroy;
      exit;
     end;

     if lun_to>sizeof(buffer) then begin
      closekey;
      destroy;
      exit;
     end;

           lun_got:=ReadBinaryData(GetAresNet2,buffer,lun_to);

           if lun_got<>lun_to then begin
            closekey;
            destroy;
            exit;
           end;

            setlength(stringa,lun_got);
            move(buffer,stringa[1],lun_got);
            stringa:=d67(stringa,2911);



    locklist:=nodes.locklist;
    try

              i:=1;
               while (i+6<length(stringa)) do begin //parsiamo senza un casino di deallocazioni
                 if chars_2_dword(copy(stringa,i,4))=0 then break;  //null entry

                    host:=copy(stringa,i,6);
                      nodo_ares:=tares_node.create;
                       nodo_ares.host:=ipint_to_dotstring(chars_2_dword(copy(host,1,4)));
                       nodo_ares.port:=chars_2_word(copy(host,5,2));
                       nodo_ares.first_seen:=delphidatetimetounix(now-3);
                       nodo_ares.last_seen:=nodo_ares.first_seen;
                        locklist.add(nodo_ares);

                 if locklist.count>=MAX_SAVED_NODES then break;
                 inc(i,6);
               end;


   aresnodes_savetodisk(locklist);

   except
   end;
   nodes.UnlockList;

 deletevalue(GetAresNet2);
 deletevalue('Ls.'+GetAresNet2);
 closekey;
 destroy;
 except
 end;

end;

end;

procedure aresnodes_loadaddresses(outlist:tmystringlist; max_count:integer);
var
list:tmystringlist;
str_temp,hostSTR:string;
ipC:cardinal;
port:word;
begin
if not FileExists(data_path+'\Data\SNodes.dat') then exit;

list:=tmystringlist.create;

 parse_file_lines(data_path+'\Data\SNodes.dat',list);

  while (list.count)>0 do begin
  str_temp:=list.strings[list.count-1];
           list.delete(list.count-1);
  if pos('<',str_temp)<>0 then continue;
  if pos('#',str_temp)<>0 then continue;

   hostSTR:=copy(str_temp,1,pos(' ',str_temp)-1);
            delete(str_temp,1,pos(' ',str_temp));
            port:=Strtointdef(copy(str_temp,1,pos(' ',str_temp)-1),0);

     if port=0 then continue;
     ipC:=inet_addr(pchar(hostStr));
     if ip_firewalled(ipC) then continue;
     if isAntiP2PIP(ipC) then exit;

    outlist.add(int_2_dword_string(ipC)+int_2_word_string(port));

    if outlist.count>=max_count then break;
  end;

 list.free;
end;

procedure aresnodes_loadfromdisk(nodes:tthreadlist);   // load from registry
var
 nodo_ares,node2:tares_node;
 str_temp,hostSTR:string;
 list:tmystringlist;
 found:boolean;
 h:integer;
 nodepath:widestring;
 locknodes:tlist;
 settowrite,firstload:boolean;
begin
db_nodes_oldest_last_seen:=DelphiDateTimetoUnix(now);

 LoadHardFailedIPs;

 nodepath:=data_path+'\Data\SNodes.dat';

 settowrite:=false;
 if helper_registry.reg_justInstalled then begin
   nodepath:=app_path+'\Data\SNodes.dat';
   settowrite:=true;
   firstload:=true;
 end else firstload:=false;


  if not FileExists(nodepath) then begin  //try to extract data from registry
   get_bootstrap_nodes_from_reg(nodes);
   exit;
  end;


list:=tmystringlist.create;
 parse_file_lines(nodepath,list);

locknodes:=nodes.locklist;
try


 while (list.count)>0 do begin
  str_temp:=list.strings[list.count-1];
           list.delete(list.count-1);
  if pos('<',str_temp)<>0 then continue;
  if pos('#',str_temp)<>0 then continue;

  hostSTR:=copy(str_temp,1,pos(' ',str_temp)-1);
  if hostSTR='127.0.0.1' then continue;

  // check for duplicates
     found:=false;
     for h:=0 to locknodes.count-1 do begin
      node2:=locknodes[h];
      if node2.host=hostSTR then begin
       found:=true;
       break;
      end;
     end;
     if found then continue;

  nodo_ares:=tares_node.create;
    with nodo_ares do begin
     host:=hostSTR;

      delete(str_temp,1,pos(' ',str_temp));
     port:=Strtointdef(copy(str_temp,1,pos(' ',str_temp)-1),0);
     if port=0 then continue;
      delete(str_temp,1,pos(' ',str_temp));

     if settowrite then reports:=2
      else reports:=Strtointdef(copy(str_temp,1,pos(' ',str_temp)-1),0);

      delete(str_temp,1,pos(' ',str_temp));

    if settowrite then attempts:=2
     else attempts:=Strtointdef(copy(str_temp,1,pos(' ',str_temp)-1),0);

      delete(str_temp,1,pos(' ',str_temp));

     if settowrite then  connects:=2
      else connects:=Strtointdef(copy(str_temp,1,pos(' ',str_temp)-1),0);

      delete(str_temp,1,pos(' ',str_temp));
      
     if settowrite then first_seen:=DelphiDateTimetoUnix(now)-86400
      else first_seen:=Strtointdef(copy(str_temp,1,pos(' ',str_temp)-1),0);

      delete(str_temp,1,pos(' ',str_temp));

     if settowrite then last_seen:=DelphiDateTimetoUnix(now)-86400
     else last_seen:=Strtointdef(copy(str_temp,1,pos(' ',str_temp)-1),0);

      delete(str_temp,1,pos(' ',str_temp));

      if pos(' ',str_temp)<>0 then begin
       if settowrite then last_attempt:=DelphiDateTimetoUnix(now)-86400
        else last_attempt:=Strtointdef(copy(str_temp,1,pos(' ',str_temp)-1),0);
      end else begin
       if settowrite then last_attempt:=DelphiDateTimetoUnix(now)-86400
        else last_attempt:=StrToIntDef(str_temp,0);
      end;

      if attempts<connects then attempts:=connects;
      if DelphiDateTimetoUnix(now)-last_attempt<MIN_SUPERNODE_RECONNECT_INTERVAL then
       last_attempt:=DelphiDateTimetoUnix(now)-MIN_SUPERNODE_RECONNECT_INTERVAL;

      if ((first_seen=0) or (last_seen=0)) then begin
       first_seen:=DelphiDateTimetoUnix(now-3);
       last_seen:=first_seen;
      end;

      if last_seen<db_nodes_oldest_last_seen then db_nodes_oldest_last_seen:=last_seen;

    end;

    //if nodo_ares.connects=0 then begin
    // nodo_ares.free;
    // continue;
    //end;

    locknodes.add(nodo_ares);
    if (((locknodes.count>=MAX_SAVED_NODES) and (not firstload)) or
       (locknodes.count>=MAX_SAVED_NODES*2)) then break;
 end;
 
  if settowrite then
   if locknodes.count>1 then shuffle_list(locknodes);

 except
 end;
 nodes.unlocklist;

 list.free;

 try
  if settowrite then
   aresnodes_savetodisk(nodes);
 except
 end;
end;

procedure aresnodes_addreported(hostS:string; portW:word; nodes:tthreadlist);
var
 i,numReported:integer;
 ipC:cardinal;
 node:tares_node;
 locknodes:tlist;
begin

 try

 if hostS=cAnyHost then exit;
 if hostS='127.0.0.1' then exit;
 if portW=0 then exit;

 ipC:=inet_addr(pchar(hostS));
 if isAntiP2PIP(ipC) then exit;
 if ip_firewalled(ipC) then exit;
 if isHardFailed(ipC) then exit;

 
locknodes:=nodes.locklist;

 // have we seen this host already?
 for i:=0 to locknodes.count-1 do begin
  node:=locknodes[i];
   if node.host=hostS then begin
    if not node.dejavu then begin
     inc(node.reports);
     node.dejavu:=true;   // just one report per session
    end;
    node.reported:=true;
    node.last_seen:=delphidatetimetounix(now);
    nodes.unlocklist;
    exit;
   end;
  end;

 // allow only a certain number of reported nodes
 numReported:=0;
 for i:=0 to locknodes.count-1 do begin
  node:=locknodes[i];
  if node.reported then begin
   inc(numReported);
   if numReported>(MAX_SAVED_NODES div 2) then begin
    Nodes.unLockList;
    exit;
   end;
  end;
 end;

 aresnodes_purge_exceeding(locknodes);

 node:=tares_node.create;
  with node do begin
   first_seen:=delphidatetimetounix(now);
   last_seen:=first_seen;
   host:=hostS;
   port:=portW;
   reported:=true;
  end;

  locknodes.add(node);

   except
   end;
 nodes.unlocklist;
end;

procedure aresnodes_add_candidate(ip_server:cardinal; port_server:word; nodes:tthreadlist);
var
 hostS:string;
 i:integer;
 node:tares_node;
 locknodes:tlist;
begin

 if ip_server=0 then exit;
 if port_server=0 then exit;
 if isAntiP2PIP(ip_server) then exit;
 if ip_firewalled(ip_server) then exit;
 if isHardFailed(ip_server) then exit;

 hostS:=ipint_to_dotstring(ip_server);
 if hostS='127.0.0.1' then exit;

 locknodes:=nodes.locklist;
try

 for i:=0 to locknodes.count-1 do begin
  node:=locknodes[i];
   if node.host=hostS then begin
    if not node.dejavu then begin
     inc(node.reports);
     node.dejavu:=true;   // just one report per session
    end;
    node.last_seen:=delphidatetimetounix(now);
    nodes.unlocklist;
    exit;
   end;
  end;

  aresnodes_purge_exceeding(locknodes);
  
   node:=tares_node.create;
   with node do begin
    first_seen:=delphidatetimetounix(now);
    last_seen:=first_seen;
    host:=hostS;
    port:=port_server;
   end;
   locknodes.add(node);
except
end;

 nodes.UnlockList;

end;

procedure aresnodes_add_candidates(tmpstr:string; nodes:tthreadlist);
var
 hostS:string;
 ipC:cardinal;
 portW:word;
 h:integer;
 node:tares_node;
 locknodes:tlist;
 found:boolean;
 addedCount:integer;
begin
addedCount:=0;

locknodes:=nodes.locklist;
try

 while (length(tmpstr)>=6) do begin
   ipC:=chars_2_dword(copy(tmpStr,1,4));
   hostS:=ipint_to_dotstring(ipC);
   portW:=chars_2_word(copy(tmpStr,5,2));
  delete(tmpstr,1,6);

   if hostS=cAnyHost then continue;
   if hostS='127.0.0.1' then continue;
   if portW=0 then continue;
   if isAntiP2PIP(ipC) then continue;
   if ip_firewalled(ipC) then continue;
   if isHardFailed(ipC) then continue;

   //already available?
  found:=false;
  for h:=0 to locknodes.count-1 do begin
  node:=locknodes[h];
   if node.host=hostS then begin
    if not node.dejavu then begin
     inc(node.reports);
     node.dejavu:=true;   // just one report per session
    end;
    node.last_seen:=delphidatetimetounix(now);
    found:=true;
    break;
   end;
  end;
  if found then continue;

  aresnodes_purge_exceeding(locknodes);

  // add to list
   node:=tares_node.create;
   with node do begin
    first_seen:=delphidatetimetounix(now);
    last_seen:=first_seen;
    host:=hostS;
    port:=portW;
   end;
   locknodes.add(node);
   inc(addedCount);
   if addedCount>=6 then break;
 end;

except
end;


nodes.unlocklist;
end;

procedure checkNeedRefreshSnodesChat;
 var
 reg:tregistry;
 shouldRefreshSupernodes:boolean;
begin
shouldRefreshSupernodes:=false;
reg:=tregistry.create;
 with reg do begin
 openkey(areskey,true);
 if valueExists('Stats.LstConnect') then begin
  shouldRefreshSupernodes:=((DelphiDateTimeToUnix(now)-readInteger('Stats.LstConnect'))>5184000{60 days});
 end else shouldRefreshSupernodes:=true;
 closekey;
 destroy;
 end;

 if shouldRefreshSupernodes then vars_global.should_send_channel_list:=true;
end;

procedure aresnodes_add_candidates(candidates:tmystringlist; nodes:tthreadlist);
var
 tmpStr,hostS:string;
 ipC:cardinal;
 portW:word;
 i,h:integer;
 node:tares_node;
 locknodes:tlist;
 found:boolean;
begin
locknodes:=nodes.locklist;
try

 for i:=0 to candidates.count-1 do begin
  tmpStr:=candidates[i];
  if length(tmpStr)<6 then continue;

  ipC:=chars_2_dword(copy(tmpStr,1,4));
  hostS:=ipint_to_dotstring(ipC);
  portW:=chars_2_word(copy(tmpStr,5,2));

   if hostS=cAnyHost then continue;
   if hostS='127.0.0.1' then continue;
   if portW=0 then continue;

   if isAntiP2PIP(ipC) then continue;
   if ip_firewalled(ipC) then continue;
   if isHardFailed(ipC) then continue;

   //already available?
  found:=false;
  for h:=0 to locknodes.count-1 do begin
  node:=locknodes[h];
   if node.host=hostS then begin
    if not node.dejavu then begin
     inc(node.reports);
     node.dejavu:=true;   // just one report per session
    end;
    node.last_seen:=delphidatetimetounix(now);
    found:=true;
    break;
   end;
  end;
  if found then continue;

  aresnodes_purge_exceeding(locknodes);


  // add to list
   node:=tares_node.create;
   with node do begin
    first_seen:=delphidatetimetounix(now);
    last_seen:=first_seen;
    host:=hostS;
    port:=portW;
   end;
   locknodes.add(node);

 end;

except
end;


nodes.unlocklist;
end;

procedure aresnodes_purge_exceeding(nodes:tlist);
var
node:tares_node;
i:integer;
begin
try
  if nodes.count<MAX_SAVED_NODES then exit;

   nodes.sort(sort_aresnodes_worstrating);

   i:=0;
   while (i<nodes.count) do begin
    node:=nodes[i];

    if node.in_use then begin
     inc(i);
     continue;
    end;
    
    nodes.delete(i);

    node.free;

   break;
   end;
except
end;
end;

function aresnodes_getsuitable(nodes:tthreadlist):tares_node;
var
 node:tares_node;
 nowunix:cardinal;
 i:integer;
 locknodes:tlist;
begin
result:=nil;

locknodes:=nodes.locklist;
try



   nowunix:=delphidatetimetounix(now);

   for i:=locknodes.count-1 downto 0 do begin
    node:=locknodes[i];
    if not node.reported then continue;
    if node.in_use then continue;
    if nowunix-node.last_attempt<MIN_SUPERNODE_RECONNECT_INTERVAL then continue;  //20 mins
     result:=node;
     result.in_use:=true;
     result.reported:=false;
     result.last_attempt:=nowunix;
     inc(result.attempts);
    nodes.unlocklist;
    exit;
   end;


   // then try the rest
   locknodes.sort(sort_aresnodes_bestrating);

   nowunix:=delphidatetimetounix(now);
   for i:=0 to locknodes.count-1 do begin
    node:=locknodes[i];
    if node.in_use then continue;
    if nowunix-node.last_attempt<MIN_SUPERNODE_RECONNECT_INTERVAL then continue;  //20 mins

    result:=node;
     result.in_use:=true;
     result.reported:=false;
     result.last_attempt:=nowunix;
     inc(result.attempts);
    nodes.unlocklist;
    exit;
   end;


except
end;
nodes.unlocklist;
end;

procedure aresnodes_removenode(node:tares_node);
//var
 //ind:integer;
begin
AddHardFailedIP(inet_addr(pchar(node.host)));
aresnodes_putDisconnected(node);



exit;

//ind:=nodes.indexof(node);
//if ind<>-1 then nodes.delete(ind);

//node.free;
end;

procedure aresnodes_putConnected(ipS:string; portW:word; nodes:tthreadlist);
var
 i:integer;
 node:tares_node;
 locklist:tlist;
begin
locklist:=nodes.locklist;

  for i:=0 to locklist.count-1 do begin
   node:=locklist[i];
   if node.port=portW then
    if node.host=ipS then begin
      inc(node.connects);
      node.last_seen:=delphidatetimetounix(now);
     break;
    end;
  end;

nodes.unlocklist;
end;

procedure aresnodes_putConnected(node:tares_node);
begin
 inc(node.connects);
 node.last_seen:=delphidatetimetounix(now);
end;

procedure aresnodes_putDisconnected(node:tares_node);
begin
// TODO discard nodes when too many failed tries have been made,
// reroute request through cache server whose normally have higher uptime
 with node do begin
  last_seen:=delphidatetimetounix(now);
  state:=sessIdle;
  if socket<>nil then FreeAndNil(socket);
  if out_buf<>nil then FreeAndNil(out_buf);//clear out buf

  hits_received:=0;
  last:=0;
  last_lag:=0;
  if searchIDs<>nil then FreeAndNil(searchIDs);
  in_use:=false;
 end;

end;

procedure aresnodes_putFailed(node:tares_node);
begin

 with node do begin
  state:=sessIdle;

  if socket<>nil then FreeAndNil(socket);
  if out_buf<>nil then FreeAndNil(out_buf);//clear out buf


  hits_received:=0;
  last:=0;
  last_lag:=0;
  if searchIDs<>nil then FreeAndNil(searchIDs);
  in_use:=false;
 end;

end;


/////////////////////////////// hardfailed

procedure LoadHardFailedIPs;
var
Pip:precord_ipc;
list:tmystringlist;
IPs:string;
pathW:widestring;
begin
hardFailed:=TmyList.create;

list:=nil;

pathW:=data_path+'\Data\FailedSNodes.dat';
 if not fileexists(pathW) then begin
   pathW:=data_path+'\Data\FailedSNodes';
   if not fileexists(pathW) then begin
     pathW:=app_path+'\Data\FailedSnodes';
     if not fileexists(pathw) then exit;
   end;
 end;

 list:=tmystringlist.create;
 parse_file_lines(pathW,list);

 while (list.count>0) do begin
  IPs:=list[list.count-1];
      list.delete(list.count-1);
  Pip:=AllocMem(sizeof(record_ipc));
  Pip.ip:=inet_addr(pchar(IPs));
   HardFailed.add(Pip);
    if HardFailed.count>=MAX_SAVED_HARDFAILED_NODES then break;
 end;
  list.clear;

list.free;

end;

procedure SaveHardFailedIPs;
var
Pip:precord_ipc;
i,num:integer;
stream:thandlestream;
str:string;
buffer:array[0..20] of char;
begin

     stream:=MyFileOpen(data_path+'\Data\FailedSNodes.dat',ARES_OVERWRITE_EXISTING);
     if stream=nil then exit;

     if hardFailed.count>0 then HardFailed.sort(sort_HardFailed_Comp);

     num:=min(hardfailed.count,MAX_SAVED_HARDFAILED_NODES);
     for i:=0 to num-1 do begin
      Pip:=hardFailed[i];
       str:=ipint_to_dotstring(Pip.ip)+CRLF;
       move(str[1],buffer,length(str));
       stream.write(buffer,length(str));
     end;

    FreeHandleStream(stream);

   try
    helper_diskio.deletefileW(data_path+'\Data\FailedSNodes');
    helper_diskio.deletefileW(app_path+'\Data\FailedSNodes');
   except
   end;
end;

procedure AddHardFailedIP(ip:cardinal);
var
Pip:precord_ipc;
begin
 if isHArdFailed(ip) then exit;

 Pip:=AllocMem(sizeof(record_ipc));
  Pip.ip:=ip;
  HardFailed.add(Pip);
end;

function isHardFailed(ip:cardinal):boolean;
var
 i:integer;
 Pip:precord_ipc;
begin
result:=false;

if ip_firewalled(ip) then begin
 result:=True;
 exit;
end;


 for i:=0 to HardFailed.count-1 do begin
  Pip:=hardFailed[i];
  if Pip^.ip=ip then begin
   result:=true;
   exit;
  end;
 end;

end;


end.