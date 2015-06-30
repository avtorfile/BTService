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
ip format/convert misc functions
}

unit helper_ipfunc;

interface

uses
 classes,classes2,helper_strings,sysutils,synsock,winsock,blcksock,
 helper_crypt,vars_global,class_cmdlist;

const
   LOW_IP_LIMIT=1;
   HIGH_IP_LIMIT=223;

function ip_firewalled(ipC:cardinal):boolean; overload;
function ip_firewalled(const ipS:string):boolean; overload;
function GetLocalIp:cardinal;
function ipint_to_dotstring(ip:cardinal):string;
function ipdotstring_to_anonnick(ip:string):string;
function ip_to_hex_str(ip:cardinal):string;
function inet_addr(cp: PChar): u_long; stdcall; {PInAddr;}  { TInAddr }
function inet_ntoa(inaddr: TInAddr): PChar; stdcall;
function headercrypt_to_aresip(str:string):string;
function is_ip(stringa:string):boolean;
function ip_int_to_dotted_reverse(ip:cardinal):string;
function resolve_name_to_ip(dns:string):string;
function ipint_to_anonick(ip:cardinal):string;
function is_banned_ip(ip:cardinal):boolean;
procedure add_ban(ip:cardinal);
function isAntiP2PIP(ip:cardinal):boolean;
function probable_fw(ipC:cardinal):boolean;
function serialize_myConDetails:string;

var
lista_banned_ip:tnapcmdlist;

implementation

uses
{ufrmmain,}mysupernodes,const_ares;

function inet_addr; external 'wsock32.dll' name 'inet_addr';
function inet_ntoa; external 'wsock32.dll' name 'inet_ntoa';

function serialize_mycondetails:string;
begin
// do not include supernodes' infos if reachable by others
if not vars_global.im_firewalled then
 result:=int_2_dword_string(vars_global.localipC)+
         int_2_word_string(vars_global.myport)+
         int_2_dword_string(vars_global.LanIPC)
else
 result:=int_2_dword_string(vars_global.localipC)+
         int_2_word_string(vars_global.myport)+
         int_2_dword_string(vars_global.LanIPC)+
         mysupernodes.mysupernodes_serialize;
end;

function isAntiP2PIP(ip:cardinal):boolean;
var
buff:array[0..3] of byte;
begin
 result:=false;

 move(ip,buff[0],4);

  //torrent
  case buff[0] of
   38:result:=(((buff[1]=118) and (buff[2]=11)) or
               ( (buff[1]=100) and ((buff[2]>=24) and (buff[2]<=27)) or ((buff[2]>=134) and (buff[2]<=135)) ) ); // cogent

   208:result:=((buff[1]=10) and (buff[2]>=23) and (buff[2]<=29));   // sprint
  end;
  if result then exit;

  // DHT
  case buff[0] of
   38:result:=((buff[1]=99) and ((buff[2]=253) or (buff[2]=254))) or // 38.99.253.XX  Performance Systems International Inc.
              (buff[1]=102);  // Performance systems 38.102.xx.xx
   62:result:=((buff[1]=241) and (buff[2]=52));  // 62.241.52.0 - 62.241.52.255  Planetwebhost
  end;
  if result then exit;

  // first type
  case buff[0] of
    8:result:=((buff[1]=3) and (buff[2]=210)); //   8.3.210.xx level3  spammer
    38:result:=((buff[1]=99) and (buff[2]=252)) or // 38.99.252.XX  Performance Systems International Inc.
                ((buff[1]=107) and ((buff[2]=162) or (buff[2]=161)) );  // 38.99.252.XX  Performance Systems International Inc.
    64:result:=((buff[1]=62) and (buff[2]>=128)); // 64.62.128.0 - 64.62.255.255 Hurricane Electric
    65:result:=((buff[1]=49) and (buff[2]=32)) or
               ((buff[1]=99) and (buff[2]=204)) or // 65.99.204.0 - 65.99.204.255 Crucial Paradigm
               ((buff[1]=19) and (buff[2]>=128) and (buff[2]<=191)); // 65.19.128.0 - 65.19.191.255 Hurrican Electric
    66:result:=(((buff[1]>=166) and (buff[1]<=167))) or // Covad  66.166.0.0 - 66.167.255.255 
               ( (buff[1]=160) and (buff[2]>=128) and (buff[2]<=207) ) or // 66.160.128.0 - 66.160.207.255 Hurricane Electric
               ( (buff[1]=180) and (buff[2]=205) ) or  //66.180.205.xx  Cyberverse Online Spammer
               ( (buff[1]=186) and (buff[2]>=192) and (buff[2]<=223) ) or // WV FIBER LLC  66.186.192.0 - 66.186.223.255
               ( (buff[1]=198) and (buff[2]=35) ) or  // 66.198.35.104-107-110 TeleGlobe Montreal Spammer
               ( (buff[1]=45) and (buff[2]>=224)) or  // 66.45.224.0 - 66.45.255.255 Interserver SMPLAYER
               ( (buff[1]=117) and (buff[2]<=15) ); //  66.117.5.xx Corporate Colocation Inc  66.117.0.0 - 66.117.15.255
    67:result:=((buff[1]>=100) and (buff[1]<=103)) or  // Covad Communications 67.100.0.0 - 67.103.255.255
               ((buff[1]=159) and (buff[2]<=63)) or    // FDCservers.net 67.159.0.0 - 67.159.63.255
               ((buff[1]=215) and (buff[2]>=224)); // Secured Private Network 67.215.224.0 - 67.215.255.255
    70:result:=(buff[1]=42); // FSH Network Services 70.42.0.0 - 70.42.255.255
    72:result:=(buff[1]=5) or  // FSH Networks / Internap 72.5.0.0 - 72.5.255.255
               ((buff[1]=232) and (buff[2]=105)) or
               ((buff[1]=172) and (buff[2]=92)) or  // Net2Ez
               ((buff[1]=172) and (buff[2]=90)) or
               ((buff[1]=232) and (buff[2]=94));  //  Layered Technologies, Inc. 72.232.0.0 - 72.232.255.255
    74:result:=((buff[1]=206) and (buff[2]>=160) and (buff[2]<=191));   //MOJOHOST 74.206.160.0 - 74.206.191.25
    78:result:=((buff[1]=129) and (buff[2]=150));
    81:result:=((buff[1]=179) and (buff[2]=88) and (buff[3]=79)); // Pipex Dyn 81.179.88.79  ****
    83:result:=((buff[1]=142) and (buff[2]>=224) and (buff[2]<=231)); // 83.142.224.0 - 83.142.231.255 Rapidswitch
    87:result:=((buff[1]=239) and (buff[2]>=48) and (buff[2]<=55)) or  // Server Shed Limited  87.239.48.0 - 87.239.55.255
               ((buff[1]=117) and (buff[2]=230) and (buff[3]>=128)) or  // Rapidswitch  87.117.230.128 - 87.117.230.255
               ((buff[1]=117) and (buff[2]=231));           // Rapidswitch  87.117.231.0 - 87.117.231.255
    99:result:=((buff[1]=192) and (buff[2]>=128)); // MOJOHOST Canada  99.192.128.0 - 99.192.255.255
    168:result:=(buff[1]=151);  // Intelligence Network, Inc. 168.151.0.0 - 168.151.255.255
    174:result:=((buff[1]=36) or (buff[1]=37));  //SoftLayer Technologies Inc. 174.36.0.0 - 174.37.255.255
    184:result:=((buff[1]=72) or (buff[1]=73)); //AMAZON hosts 184.72.0.0 - 184.73.255.255
    189:result:=((buff[1]=43) and ((buff[2]=25) or (buff[2]=26))); //Embratel BR 189.43.25.0/26
    202:result:=((buff[1]=167) and (buff[2]>=224)); // EQUINIXAP-NET 202.167.224.0 - 202.167.255.255
    204:begin
         if buff[1]=193 then begin
           result:=((buff[2]>=128) and (buff[2]<=159)); //GLOBIXBLK4 USA  204.193.128.0 - 204.193.159.255

         end else
         if buff[1]=236 then begin  // Amazon Web Services  204.236.128.0 - 204.236.255.255
          result:=(buff[2]>=128);
         end;
    end;
    205:result:=((buff[1]=134) and ((buff[2]=238) or (buff[2]=239)));   // xeex  205.134.238.0 - 205.134.239.255
    207:result:=((buff[1]=7) and (buff[2]=136)) or
                ((buff[1]=171) and ((buff[2]>=61) or (buff[2]<=62))) or  // Regard Systems Integrators  207.171.61.0 - 207.171.61.255
                ((buff[1]=212) and (buff[2]=26));    // PacificNet  207.212.26.0 - 207.212.26.255
    209:begin
        result:=(buff[1]=10) or   // GLOBIXBLK3 USA  209.10.0.0 - 209.10.255.255
                ((buff[1]=195) and (buff[2]<=63)) or// 209.195.0.0 - 209.195.63.255 ( Macrovision Corporation )
                ((buff[1]=51) and (buff[2]>=160) and (buff[2]<=191)); // 209.51.160.0 - 209.51.191.255 Hurrican Electric
        end;
    212:begin
        if buff[1]=71 then begin
          result:=(buff[2]>=224);  // Globix it   212.71.224.0 - 212.71.255.255
        end;
     end;
     213:begin
           if buff[1]=219 then begin
             if buff[2]=9 then begin
               result:=(buff[3]>=192);  // X Works  213.219.9.192 - 213.219.9.255
             end;
           end;
         end;
     216:begin
           result:=((buff[1]=58) and (buff[2]<=127)) or //216.58.0.0 - 216.58.127.255   Information Gateway Services
                   ((buff[1]=18) and (buff[2]=228) and (buff[3]<=95)) or  //216.18.228.0 - 216.18.228.95 PROTONSOLUTION-1
                   ((buff[1]=58) and (buff[2]=193)) or // 216.58.193.xx Fox Communications

                   ((buff[1]=66) and (buff[2]<=95)) or // 216.66.0.0 - 216.66.95.255 Hurrican Electric
                   ((buff[1]=218) and (buff[2]>=128)); // 216.218.128.0 - 216.218.255.255   Hurrican Electric

         end;


  end;
 if result then exit;

 // second type
 case buff[0] of
   24:result:=((buff[1]=76) and (buff[2]=251)); // SHAW Ottawa  24.76.251.x   *****
   63:begin
       result:= ((buff[1]>=216) and (buff[1]<=223)) or // Beyond the net 63.216.0.0 - 63.223.255.255
                ((buff[1]>=236) and (buff[1]<=239));  // QWEST COMUNICATION 63.236.0.0 - 63.239.255.255
      end;
   64:begin
        if buff[1]=70 then result:=(buff[2]<=111); //  Savvis  64.70.0.0 - 64.70.111.255
   end;
   66:result:=( (buff[1]=172) or                       // Fastserve Network 66.172.0.0 - 66.172.63.255
                ((buff[1]=110) and (buff[2]<=127)) or  // TeleGlobe 66.110.0.0 - 66.110.127.255
                ((buff[1]=25) and (buff[2]=7)) );   // RR Houston TX   66.25.7.237 ****

   69:begin
        if buff[1]=26 then begin
           result:=((buff[2]>=160) and (buff[2]<=191)); // Net Sentry Corp   69.26.160.0 - 69.26.191.255
        end;
    end;
   72:begin
     if buff[1]=35 then begin
       result:=((buff[2]>=224) and (buff[2]<=239)); // FUZION COLO NV    72.35.224.0 - 72.35.239.255
     end;
   end;
   142:result:=(buff[1]=162); // Stentor National 142.162.0.0 - 142.162.255.255 
   154:result:=(buff[1]=37);   // PERFORMANCE SYSTEM 154.37.0.0 - 154.37.255.255
   204:begin
         if buff[1]=11 then begin
          result:=((buff[2]>=16) and (buff[2]<=19)); //Your OneStop Network, Inc  204.11.16.0 - 204.11.19.255
         end;
      end;
   205:result:=((buff[1]=177) or // Beyond The net  205.177.0.0 - 205.177.255.255
                (buff[1]=252)); // Beyond The Network America, Inc  205.252.0.0 - 205.252.255.255
   206:result:=(buff[1]=161); // Beyond The Network America 206.161.0.0 - 206.161.255.255
   207:result:=(buff[1]=226); // Beyond The Network America  207.226.0.0 - 207.226.255.255
   208:result:=((buff[1]>=48) and (buff[1]<=50));// Global Crossing  208.48.224.0 - 208.50.127.255

   216:begin

       if buff[1]=8 then begin
         result:=(buff[2]>=192);   //  Cosmex Media      216.8.192.0 - 216.8.255.255
       end else
       if buff[1]=9 then begin
         result:=((buff[2]>=160) and (buff[2]<=175)) or // Western PA Internet Access, Inc.  216.9.160.0 - 216.9.175.255
                 ((buff[2]>=192) and (buff[2]<=207)); // ASI comunication 216.9.192.0 - 216.9.207.255
       end else
       if buff[1]=151 then begin
         result:=((buff[2]>=128) and (buff[2]<=159));// xeen.net  216.151.128.0 - 216.151.159.255
       end else
        result:=(buff[1]=156); //XO Communications 216.156.0.0 - 216.156.255.255
   end;
   220:result:=(buff[1]=255); // SingNet Pte Ltd 220.255.0.0 - 220.255.255.255
   221:result:=(buff[1]=189);// NTT Communications Corporation 221.184.0.0 - 221.191.255.255  ****
 end;

end;

procedure add_ban(ip:cardinal);
begin
if lista_banned_ip=nil then lista_banned_ip:=tnapcmdlist.create;

if lista_banned_ip.FindById(ip)<>-1 then exit;
lista_banned_ip.addcmd(ip,'');
end;

function is_banned_ip(ip:cardinal):boolean;
begin
try
if lista_banned_ip=nil then begin
 result:=false;
 exit;
end;

result:=(lista_banned_ip.FindById(ip)<>-1);
except
result:=false;
end;
end;


function resolve_name_to_ip(dns:string):string;
var
lista:tmystringlist;
begin
result:='';
   lista:=tmystringlist.create;  //otteniamo ip reale per cript decript
  ResolveNameToIP(dns,lista);
  if lista.count<1 then begin
   lista.free;
   exit;
  end;
  result:=lista.strings[0];
 lista.free;
end;

function ip_int_to_dotted_reverse(ip:cardinal):string;
var   ia:     in_addr;
ipi:integer;
str:string;
begin
str:=int_2_dword_string(ip);
str:=reverse_order(str);
ipi:=chars_2_dword(str);
ia.S_addr := ipi;
  result := inet_ntoa(ia);
end;

function is_ip(stringa:string):boolean;
var
i:integer;
puntini:byte;
begin
puntini:=0;

for i:=1 to length(stringa) do begin
if ((stringa[i]<>'0') and (stringa[i]<>'1') and
(stringa[i]<>'2') and (stringa[i]<>'3') and
(stringa[i]<>'4') and (stringa[i]<>'5') and
(stringa[i]<>'6') and (stringa[i]<>'7') and
(stringa[i]<>'8') and (stringa[i]<>'9') and
(stringa[i]<>'.')) then begin
result:=false;
exit;
end else if stringa[i]='.' then inc(puntini);
end;

result:=(puntini=3);
end;

function headercrypt_to_aresip(str:string):string;
var
ip,ip_server:integer;
port,port_server:word;
begin
if length(str)<>12 then begin
 result:='';
 exit;
end;

str:=hexstr_to_bytestr(str);
str:=d54(str,3617);
               ip_server:=chars_2_dword(copy(str,1,4));
               port_server:=chars_2_word(copy(str,5,2));
               ip:=chars_2_dword(copy(str,7,4));
               port:=chars_2_word(copy(str,11,2));
result:=ipint_to_dotstring(ip_server)+':'+inttostr(port_server)+'|'+
        ipint_to_dotstring(ip)+':'+inttostr(port);
end;

function ip_to_hex_str(ip:cardinal):string;
var i:integer;
str:string;
begin
try
str:=int_2_dword_string(ip);
result:='';
for i:=1 to length(str) do result:=result+inttohex(ord(str[i]),2);
result:=lowercase(result);
except
end;
end;

function ipdotstring_to_anonnick(ip:string):string;
var
ipi:integer;
begin
ipi:=inet_addr(pchar(ip));
result:=STR_ANON+ip_to_hex_str(ipi);
end;

function ipint_to_anonick(ip:cardinal):string;
begin
result:=STR_ANON+ip_to_hex_str(ip);
end;

function ipint_to_dotstring(ip:cardinal):string;
var   ia:     in_addr;
begin
ia.S_addr := ip;
  result := inet_ntoa(ia);
end;

function GetLocalIp:cardinal;
{type
  sockaddr_in = record
    case Integer of
      0: (sin_family: u_short;
          sin_port: u_short;
          sin_addr: TInAddr;
          sin_zero: array[0..7] of Char);
      1: (sa_family: u_short;
          sa_data: array[0..13] of Char)
  end;}
var
  s:string;
  hname:string;
  lista:tmystringlist;
begin


  Result:=0;
  setlength(s, 255);
  synsock.GetHostName(pchar(s), Length(s) - 1);
   hname := Pchar(s);
 if hname = '' then Result := 0 else begin
     lista:=tmystringlist.create;
     ResolveNameToIP(hname,lista);
     if lista.count>0 then result:=inet_addr(pchar(lista.strings[0])) else Result := 0;
     lista.free;
  end;


end;

function probable_fw(ipC:cardinal):boolean;
var
buffer:array[0..3] of byte;
begin
result:=false;

move(ipC,buffer[0],4);

 case buffer[0] of
   1,
   2,
   5,
   14,
   23,
   37,
   39,
   41,
   42:result:=true;
 end;

end;

function ip_firewalled(ipC:cardinal):boolean;
var
buffer:array[0..3] of byte;
begin
result:=false;

move(ipC,buffer[0],4);

if buffer[0]>HIGH_IP_LIMIT then begin
 result:=true;
 exit;
end;
if buffer[0]<LOW_IP_LIMIT then begin
 result:=True;
 exit;
end;

 case buffer[0] of
  10:result:=true;
  127:result:=((buffer[1]=0) and (buffer[2]=0) and (buffer[3]=1));
  192:result:=(buffer[1]=168);
  172:result:=((buffer[1]>=16) and (buffer[1]<=32));
  end;


end;

function ip_firewalled(const ipS:string):boolean;
begin
result:=ip_firewalled(inet_addr(pchar(ipS)));
end;

end.
