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

unit mysupernodes;

interface

uses
 classes,sysutils,blcksock,synsock;

 type
 precord_mysupernode=^record_mysupernode;
 record_mysupernode=record
  fip:cardinal;
  fport:word;
  fresultId:integer;
  fLastPing:cardinal;
  flastPong:cardinal;
  fsupportDirectChat:boolean;
 end;

procedure mysupernodes_create;
procedure mysupernodes_free;
procedure mysupernodes_clear;
procedure mysupernodes_add(ip:cardinal; port:word; resultid:integer; supportDirectChat:boolean=false);
procedure mysupernodes_remove(ip:cardinal);
function mysupernodes_serialize:string;
function GetDotServerStr:string;
function GetServerStrBinary_forChat:string;
procedure GetServerDetails(var ip:cardinal; var port:word);
function IsServerAvailable(ip:cardinal; port:word):boolean;
procedure mySupernodes_ping(Tick:cardinal; USocket:Hsocket);
procedure mySupernodes_pong(Tick:cardinal; ip:cardinal; port:word);
function mySupernodes_count:integer;
function IsSupernodeIP(ip:cardinal):boolean;

var
 fMySupernodes:TThreadList;
 fmysuplistcount:byte;

implementation

uses
 helper_strings,helper_ipfunc,const_timeouts,const_udpTransfer,
 windows;

function mySupernodes_count:integer;
begin
result:=fmysuplistcount;
end;

procedure mysupernodes_create;
begin
fmysuplistcount:=0;
fmySupernodes:=TThreadList.create;
end;

procedure mysupernodes_free;
begin
mysupernodes_clear;
fmySupernodes.free;
end;

function IsSupernodeIP(ip:cardinal):boolean;  
var
list:tlist;
sup:precord_mysupernode;
i:integer;
begin
result:=false;

list:=fmySupernodes.locklist;

 for i:=0 to list.count-1 do begin
  sup:=list[i];
  if sup^.fip=ip then begin
   result:=true;
   break;
  end;
 end;

fmySupernodes.unlocklist;
end;

procedure mysupernodes_clear;
var
list:tlist;
sup:precord_mysupernode;
begin
if fmysuplistcount=0 then exit;

list:=fmySupernodes.locklist;

 while (list.count>0) do begin
   sup:=list[list.count-1];
        list.delete(list.count-1);
   FreeMem(sup,sizeof(record_mysupernode));
 end;

fmySupernodes.unlocklist;

fmysuplistcount:=0;
end;

function IsServerAvailable(ip:cardinal; port:word):boolean;
var
list:tlist;
sup:precord_mysupernode;
i:integer;
begin
result:=false;
if fmysuplistcount=0 then exit;
if ((ip=0) or (port=0)) then exit;

list:=fmySupernodes.locklist;

for i:=0 to list.count-1 do begin
 sup:=list[i];
 if sup^.Fip=ip then
  if sup^.Fport=port then begin
   result:=true;
   break;
  end;
end;

fmySupernodes.Unlocklist;
end;

procedure GetServerDetails(var ip:cardinal; var port:word);
var
list:tlist;
sup:precord_mysupernode;
begin
if fmysuplistcount=0 then begin
 ip:=0;
 port:=0;
 exit;
end;

list:=fmySupernodes.locklist;
  sup:=list[list.count-1];
  ip:=sup^.fip;
  port:=sup^.fport;
fmySupernodes.Unlocklist;
end;

function GetDotServerStr:string;
var
list:tlist;
sup:precord_mysupernode;
begin
if fmysuplistcount=0 then begin
 result:=cAnyHost+':0';
 exit;
end;

list:=fmySupernodes.locklist;
  sup:=list[list.count-1];
  result:=ipint_to_dotstring(sup^.Fip)+':'+inttostr(sup^.fport);
fmySupernodes.Unlocklist;
end;

function GetServerStrBinary_forChat:string;
var
 list:tlist;
 sup:precord_mysupernode;
 i:integer;
begin
if fmysuplistcount=0 then begin
 result:=chr(0)+chr(0)+chr(0)+chr(0)+
         chr(0)+chr(0);
 exit;
end;

list:=fmySupernodes.locklist;

  for i:=0 to list.count-1 do begin  //for chat try to send the best choice for contacting us
   sup:=list[i];                     // a supernode that supports directchat relaying
   if not sup^.fsupportDirectChat then continue;
     result:=int_2_dword_string(sup^.Fip)+
             int_2_word_string(sup^.Fport);
       fmySupernodes.Unlocklist;
       exit;
   end;

   sup:=list[list.count-1];

   result:=int_2_dword_string(sup^.Fip)+
             int_2_word_string(sup^.Fport);
fmySupernodes.Unlocklist;
end;

function mysupernodes_serialize:string;
var
list:tlist;
i:integer;
sup:precord_mysupernode;
begin
result:='';
if fmysuplistcount=0 then exit;

list:=fmySupernodes.locklist;

  for i:=list.count-1 downto 0 do begin
   sup:=list[i];
   result:=result+int_2_dword_string(sup^.Fip)+
                 int_2_word_string(sup^.FPort);
   if length(result)=30 then break;
  end;

fmySupernodes.Unlocklist;
end;

procedure mysupernodes_remove(ip:cardinal);
var
list:tlist;
i:integer;
sup:precord_mysupernode;
begin
list:=fmySupernodes.locklist;

 for i:=0 to list.count-1 do begin
   sup:=list[i];
   if sup^.fip=ip then begin
    list.delete(i);
    FreeMem(sup,sizeof(record_mysupernode));
    fmysuplistcount:=list.count;
    break;
   end;
 end;

fmySupernodes.Unlocklist;

end;

procedure mysupernodes_add(ip:cardinal; port:word; resultid:integer; supportDirectChat:boolean=false);
var
 list:tlist;
 i:integer;
 sup:precord_mysupernode;
begin
list:=fmySupernodes.locklist;

 for i:=0 to list.count-1 do begin
   sup:=list[i];
   if sup^.fip=ip then begin
    sup^.fresultid:=resultid;   //update resultid
    fmySupernodes.unlocklist;
    exit;
   end;
 end;

 sup:=AllocMem(sizeof(record_mysupernode));
  with sup^ do begin
   fip:=ip;
   fport:=port;
   fresultId:=resultid;
   fLastPing:=0;
   FlastPong:=0;
   FsupportDirectChat:=supportDirectChat;
  end;
 list.add(sup);
 fmysuplistcount:=list.count;

fmySupernodes.unlocklist;

end;



//keep NAT Transfer session alive (called by thread_upload once every 15 seconds)
procedure mySupernodes_ping(Tick:cardinal; USocket:Hsocket);
var
list:Tlist;
i:integer;
sup:precord_mysupernode;
resid:word;
RemoteSin:TVarSin;
buffer:array[0..2] of byte;
begin
if USocket=INVALID_SOCKET then exit;
if fmysuplistcount=0 then exit;

list:=fmySupernodes.locklist;
try

 for i:=0 to list.count-1 do begin
  sup:=list[i];
  if sup^.fresultId=-1 then continue;  
  if tick-sup^.FLastPing>UDPTRANSFER_PINGTIMEOUT then begin
   resid:=sup^.fresultID; // copy to word value

     buffer[0]:=CMD_UDPTRANSFER_PING;
     move(resId,buffer[1],2);
     
     FillChar(RemoteSin, Sizeof(RemoteSin), 0);
     RemoteSin.sin_family:=AF_INET;
     RemoteSin.sin_port:=synsock.htons(sup^.Fport);
     RemoteSin.sin_addr.s_addr:=sup^.Fip;
     synsock.SendTo(Usocket,buffer,3,0,@RemoteSin,sizeof(RemoteSin));

     sup^.FLastPing:=tick;

  end;

 end;

except
end;
fmySupernodes.unlocklist;
end;


// pong arrived from remove thread (in thread_upload)
procedure mySupernodes_pong(Tick:cardinal; ip:cardinal; port:word);
var
list:tlist;
i:integer;
sup:precord_mysupernode;
begin
if fmysuplistcount=0 then exit;

list:=fmySupernodes.locklist;

 for i:=0 to list.count-1 do begin
  sup:=list[i];

  if sup^.Fip=ip then
   if sup^.FPort=port then begin
    sup^.FLastPong:=Tick;
    break;
   end;
 end;

fmySupernodes.unlocklist;
end;


end.
