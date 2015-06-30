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
main bittorrent string functions
}

unit BittorrentStringfunc;

interface

uses
 classes,sysutils,windows,btcore;

 function chars_2_wordRev(const stringa:string):cardinal;
 function chars_2_dwordRev(const stringa:string):cardinal;
 function bool2verbose(value:boolean):string;
 function GetHostFromUrl(value:string):string;
 function GetPortFromUrl(value:string):word;
 function GetPathFromUrl(value:string):string;
 function GetScrapePathFromUrl(const value:string):string;
 function GetFullScrapeURL(const value:string):string;

 function fullUrlEncode(value:string):string;
 function GetrandomAsciiChars(howmany:integer):string;
 function GetrandomChars(howmany:integer):string;
 function int_2_dword_stringRev(const numero:cardinal):string;
 function int_2_word_stringRev(const numero:word):string;
 function BTSourceStatusToStringW(status:tbittorrentSourceStatus):widestring;
 function stripChar(inString:string; character:string):string;
 function BTIDtoClientName(const value:string):string;
 function BTBitStatustoString(data:precord_Displayed_source):widestring;
 function GetSerialized4CharVersionNumber:string;
 function BTSourceStatusToByte(status:tbittorrentSourceStatus):byte;
 function BTProgressToFamiltyStrName(progress:integer):widestring;
 function AddBoolString(const value:widestring; ShouldAdd:boolean):widestring;
 function AzAdvancedCommand_to_BittorrentCommand(const inValue:string):byte;

implementation

uses
 vars_global,vars_localiz,const_ares,bittorrentConst;


function AzAdvancedCommand_to_BittorrentCommand(const inValue:string):byte;
begin
if inValue='REQUEST' then result:=CMD_BITTORRENT_REQUEST
 else
if inValue='PIECE' then result:=CMD_BITTORRENT_PIECE
 else
if inValue='HAVE' then result:=CMD_BITTORRENT_HAVE
 else
if inValue='CANCEL' then result:=CMD_BITTORRENT_CANCEL
 else
if inValue='CHOKE' then result:=CMD_BITTORRENT_CHOKE
 else
if inValue='UNCHOKE' then result:=CMD_BITTORRENT_UNCHOKE
 else
if inValue='INTERESTED' then result:=CMD_BITTORRENT_INTERESTED
 else
if inValue='UNINTERESTED' then result:=CMD_BITTORRENT_NOTINTERESTED
 else
if inValue='KEEP_ALIVE' then result:=CMD_BITTORRENT_KEEPALIVE
 else
if inValue='BITFIELD' then result:=CMD_BITTORRENT_BITFIELD
 else
  result:=CMD_BITTORRENT_UNKNOWN;
end;

function GetSerialized4CharVersionNumber:string;
var
lastnum:string;
begin        // 2.1.4.3038 -> 2148
if length(versioneAres)<>10 then versioneAres:=ARES_VERS;
result:=stripChar(versioneAres,'.');
lastnum:=result[length(result)];

delete(result,4,length(result));
result:=result+lastnum;
if length(result)<>4 then result:='2148';
end;

function AddBoolString(const value:widestring; ShouldAdd:boolean):widestring;
begin
if ShouldAdd then result:=value
 else result:='';
end;

function BTBitStatustoString(data:precord_Displayed_source):widestring;
begin


  result:=GetLangStringW(STR_UPLOAD)+': '+
           AddBoolString(GetLangStringW(STR_IDLE),(not data^.choked) and (not data^.interested))+
           AddBoolString(GetLangStringW(STR_TORRENT_CHOKED),data^.choked)+
           AddBoolString(GetLangStringW(STR_TORRENT_OPTUNCHOKE),(data^.isOptimistic) and (not data^.choked))+
           AddBoolString(', ',(((data^.choked) or (data^.isOptimistic)) and data^.interested))+
           AddBoolString(GetLangStringW(STR_TORRENT_INTERESTED),data^.interested)+'  -  '+
          GetLangStringW(STR_DOWNLOAD)+': '+
           AddBoolString(GetLangStringW(STR_IDLE),(not data^.weArechoked) and (not data^.weAreinterested))+
           AddBoolString(GetLangStringW(STR_TORRENT_CHOKED),data^.weAreChoked)+
           AddBoolString(', ',(data^.weArechoked and data^.weAreinterested))+
           AddBoolString(GetLangStringW(STR_TORRENT_INTERESTED),data^.weAreInterested);

end;

function BTIDtoClientName(const value:string):string;
var
clientPrefix,version:string;
i,ind:integer;
isShareaza:boolean;
begin
result:='';

 if length(value)<20 then begin
  result:='Unknown';
  exit;
 end;

if ((value[1]='-') and (value[2]<>'-')) then begin //Azureus style  -AGxxxx {-xxxx...}
 clientprefix:=copy(value,2,2);
 version:=copy(value,4,4);
 for i:=1 to length(version) do result:=result+version[i]+'.';
 delete(result,length(result),1);
 version:=result;
 result:='';

 if clientPrefix='AG' then result:='Ares'
  else
 if clientPrefix='A~' then result:='Ares' 
  else
 if clientPrefix='AR' then result:='Arctic Torrent'
  else
 if clientPrefix='AV' then result:='Avicora'
  else
 if clientPrefix='AZ' then result:='Azureus'
  else
 if clientPrefix='AX' then result:='BitPump'
  else
 if clientPrefix='BB' then result:='BitBuddy'
  else
 if clientPrefix='BE' then result:='BitTorrent SDK'
  else
 if clientPrefix='BO' then begin
  if copy(value,4,4)='WA0C' then version:='1.03'
   else
   if copy(value,4,4)='WA0B' then version:='1.02'
    else version:='';
  result:='BitsOnWheels';
 end else
 if clientPrefix='BC' then result:='BitComet'
  else
 if clientPrefix='BG' then result:='BTGetit'
  else
 if clientPrefix='BP' then result:='BitTorrent Pro'
  else
 if clientPrefix='BR' then result:='BitRocket'
  else
 if clientPrefix='BF' then result:='Bitflu'
  else
 if clientPrefix='bk' then result:='BitKitten (libtorrent)'
  else
 if clientPrefix='BR' then result:='BitRocket'
  else
 if clientPrefix='BS' then result:='BTSlave' //BitSpirit
  else
 if clientPrefix='BT' then result:='BitTornado' //BitSpirit
  else
 if clientPrefix='BX' then result:='BittorrentX'
  else
 if clientPrefix='CD' then result:='Enhanced CTorrent'
  else
 if clientPrefix='CT' then result:='CTorrent'
  else
 if clientPrefix='DE' then result:='DelugeTorrent' // ??
  else
  if clientPrefix='DP' then result:='Propagate Data' // ??
  else
 if clientPrefix='EB' then result:='EBit'
  else
 if clientPrefix='ES' then result:='Electric sheep'
  else
 if clientPrefix='eX' then result:='EXeem'
  else
 if clientPrefix='FC' then result:='FileCroc'
  else
 if clientPrefix='FG' then result:='FlashGet'
  else
  if clientPrefix='FT' then result:='FoxTorrent'
  else
   if clientPrefix='GS' then result:='GSTorrent'
  else
 if clientPrefix='G3' then begin
  result:='G3 Torrent';
  version:='';
 end
  else
 if clientPrefix='HL' then result:='Halite'
  else
  if clientPrefix='HN' then result:='Hydranode'
  else
  if clientPrefix='KG' then result:='KGet'
  else
 if clientPrefix='KT' then result:='KTorrent'
  else
  if clientPrefix='LH' then result:='LH-ABC'
  else                                        //-JB0300-??
 if clientPrefix='LP' then result:='Lphant'
  else
 if clientPrefix='LT' then result:='libTorrent (Rasterbar)'
  else
 if clientPrefix='lt' then result:='libTorrent (Rakshasa)'
  else
 if clientPrefix='lt' then result:='libtorrent'
  else
 if clientPrefix='lt' then result:='Limewire'
  else
 if clientPrefix='LW' then result:='Limewire'
  else
 if clientPrefix='ML' then begin
  result:='MLDonkey';
  version:=copy(value,4,5);
 end
  else
 if clientPrefix='MO' then result:='MonoTorrent'
  else
 if clientPrefix='MP' then result:='MooPolice'
  else
  if clientPrefix='MR' then result:='Miro'
  else
 if clientPrefix='MT' then result:='MoonlightTorrent'
  else
  if clientPrefix='NX' then result:='Net Transport'
  else
 if clientPrefix='OP' then result:='Opera'
  else
 if clientPrefix='PC' then result:='CacheLogic'
  else
  if clientPrefix='PD' then result:='Pando'
  else
 if clientPrefix='qB' then result:='qBittorrent'
  else
  if clientPrefix='QD' then result:='QQDownload'
  else
 if clientPrefix='QT' then result:='Qt4 Torrent'
  else
 if clientPrefix='RC' then result:='RC' //???
  else
 if clientPrefix='RT' then result:='Retriever'
  else
 if clientPrefix='SB' then result:='Swiftbit'
  else
 if clientPrefix='SD' then result:='Xunlei'  //http://dl.xunlei.com/)
  else
 if clientPrefix='SN' then result:='ShareNET'
  else
 if clientPrefix='SP' then result:='BitSpirit'
  else
 if clientPrefix='BS' then result:='BitSpirit'
  else
 if clientPrefix='SS' then result:='SwarmScope'
  else
 if clientPrefix='ST' then result:='SymTorrent'
  else
  if clientPrefix='st' then result:='SharkTorrent'
  else
 if clientPrefix='SZ' then result:='Shareaza'
  else
 if clientPrefix='S~' then result:='Shareaza beta'  //shareaza 2.2.3.0 ?
  else
 if clientPrefix='TN' then result:='Torrent.NET'
  else
 if clientPrefix='TR' then result:='Transmission'
  else
 if clientPrefix='TS' then result:='TorrentStorm'
  else
 if clientPrefix='UL' then result:='uLeecher!'
  else
 if clientPrefix='UM' then result:='µTorrent Mac'
  else
 if clientPrefix='UT' then result:='µTorrent'
  else
  if clientPrefix='VG' then result:='Vagaa'
  else
 if clientPrefix='ZT' then result:='ZipTorrent'
  else
 if clientPrefix='WT' then result:='BitLet'
  else
  if clientPrefix='WY' then result:='FireTorrent'
  else
  if clientPrefix='XL' then result:='Xunlei'
  else
 if clientPrefix='XT' then result:='XanTorrent'
  else
 if clientPrefix='XX' then result:='XTorrent'
  else begin
   result:='Unknown ('+clientPrefix+' '+version+')';
   exit;
  end;
   result:=result+' '+version;
   exit;
end;

ind:=pos('----',value);
if ((ind>=5) and (ind<7)) then begin  //bittornado may be at pos 6 tornado style
   clientPrefix:=copy(value,1,1);
   version:=copy(value,2,ind-2);
   for i:=1 to length(version) do result:=result+version[i]+'.';
   delete(result,length(result),1);
   version:=result;
   result:='';

  if clientprefix='A' then result:='ABC'
   else
  if clientprefix='O' then result:='Osprey Permaseed'
   else
  if clientprefix='Q' then result:='BTQueue'
   else
  if clientprefix='R' then result:='Tribler'
   else
  if clientprefix='S' then result:='Shadown'
   else
  if clientprefix='T' then result:='BitTornado'
   else
  if clientprefix='U' then result:='UPnP NAT'
   else begin
     result:='Unknown ('+value+')';
     exit;
   end;
   result:=result+' '+version;
   exit;
end;

if copy(value,1,8)='AZ2500BT' then begin
 result:='BitTyrant';
 exit;
end;

if copy(value,1,1)='M' then begin //Bram's
   version:=stripChar(copy(value,2,7),'-');
   for i:=1 to length(version) do result:=result+version[i]+'.';
   delete(result,length(result),1);
   version:=result;
   result:='BitTorrent '+version;
 exit;
end;


if copy(value,6,7)='Azureus' then begin
 result:='Azureus 2.0.3.2';
 exit;
end;

if copy(value,1,6)='A310--' then begin
 result:='ABC 3.1';
 exit;
end;

if copy(value,1,2)='OP' then begin
  version:=copy(value,3,4);
  for i:=1 to length(version) do result:=result+version[i]+'.';
  delete(result,length(result),1);
  version:=result;
  result:='Opera '+version;
  exit;
end;

if copy(value,2,3)='BOW' then begin
 result:='BitsOnWheels '+copy(value,4,3);
 exit;
end;

if copy(value,1,2)='eX' then begin
 result:='eXeem ['+copy(value,3,18)+']';
 exit;
end;

if copy(value,1,7)='martini' then begin
 result:='Martini Man';
 exit;
end;

if copy(value,1,5)='oernu' then begin
 result:='BTugaXP';
 exit;
end;

if copy(value,1,6)='BTDWV-' then begin
 result:='Deadman Walking';
 exit;
end;

if copy(value,1,8)='PRC.P---' then begin
 result:='BitTorrent Plus! II';
 exit;
end;

if copy(value,1,8)='P87.P---' then begin
 result:='BitTorrent Plus!';
 exit;
end;

if copy(value,1,8)='S587Plus' then begin
 result:='BitTorrent Plus!';
 exit;
end;

if copy(value,5,6)='btfans' then begin
 result:='SimpleBT';
 exit;
end;

if lowercase(copy(value,1,5))='btuga' then begin
 result:='BTugaXP';
 exit;
end;

if copy(value,1,10)='DansClient' then begin
 result:='XanTorrent';
 exit;
end;

if copy(value,1,16)='Deadman Walking-' then begin
 result:='Deadman';
 exit;
end;


if copy(value,1,4)='LIME' then begin
  result:='Limewire';
  exit;
end;

if copy(value,1,5)='Mbrst' then begin
  version:=value[6]+'.'+value[8]+'.'+value[10];
  result:='Burst '+version;
 exit;
end;

if copy(value,1,7)='turbobt' then begin
  result:='TurboBT '+copy(value,8,5);
  exit;
end;

if copy(value,1,4)='btpd' then begin
 result:='BT Protocol Daemon '+copy(value,5,3);
 exit;
end;

if copy(value,1,4)='Plus' then begin
 result:='Plus! '+value[5]+'.'+value[6]+'.'+value[7];
 exit;
end;

if copy(value,1,3)='XBT' then begin
 result:='XBT '+value[4]+'.'+value[5]+'.'+value[6];
 exit;
end;

if copy(value,3,2)='RS' then begin
  result:='Rufus '+inttostr(ord(value[1]))+'.'+
                   inttostr(ord(value[2]) div 10)+'.'+
                   inttostr(ord(value[2]) mod 10);
  exit;
end;

if ((copy(value,1,4)='exbc') or
    (copy(value,1,4)='FUTB') or
    (copy(value,1,4)='xUTB')) then begin

  if copy(value,7,4)='LORD' then begin
   if value[5]=CHRNULL then version:=inttostr(ord(value[5]))+'.'+
                                     inttostr(ord(value[6]) div 10)+
                                     inttostr(ord(value[6]) mod 10)
                                     else
                            version:=inttostr(ord(value[5]))+'.'+
                                     inttostr(ord(value[6]) mod 10);
   result:='BitLord '+version;
   exit;
  end;

   version:=inttostr(ord(value[5]))+'.'+
            inttostr(ord(value[6]) div 10)+
            inttostr(ord(value[6]) mod 10);

  if copy(value,1,4)='FUTB' then result:='BitComet Mod1 '+version
   else
    if copy(value,1,4)='xUTB' then result:='BitComet Mod2 '+version
     else
      result:='BitComet '+version;
  exit;
end;

if copy(value,3,2)='BS' then begin
  version:='v'+inttostr(ord(value[2]));
  result:='BitSpirit '+version;
  exit;
end;

if copy(value,1,4)='346-' then begin
  result:='TorrentTopia';
  exit;
end;

if copy(value,1,4)='271-' then begin
 result:='GreedBT 2.7.1';
 exit;
end;

if copy(value,11,2)='BG' then begin
 result:='BTGetit';
 exit;
end;

if copy(value,1,7)='a00---0' then begin
 result:='Swarmy';
 exit;
end;

if copy(value,1,7)='a02---0' then begin
 result:='Swarmy';
 exit;
end;

if copy(value,1,7)='T00---0' then begin
 result:='Teeweety';
 exit;
end;

if copy(value,1,9)='10-------' then begin
 result:='JVTorrent';
 exit;
end;



if copy(value,1,8)=CHRNULL+CHRNULL+CHRNULL+CHRNULL+CHRNULL+CHRNULL+CHRNULL+CHRNULL then begin
  if copy(value,17,4)='UDP0' then result:='BitComet UDP'
   else
    if copy(value,15,6)='HTTPBT' then result:='BitComet HTTP';
    exit;
end;

if value[1]='S' then begin
    if value[9]=chr(0) then begin
      result:='Shad0w '+inttostr(ord(value[2]))+'.'+inttostr(ord(value[3]));
    end else result:='Unknown ('+value+')';
    exit;
end;

if value[1]<>chr(0) then begin
   isShareaza:=true;
      for i:=2 to 16 do begin
       if value[i]=chr(0) then begin
        isShareaza:=false;
        break;
       end;
      end;
          if isShareaza then begin
            for i:=17 to 20 do begin
             if ord(value[i])<>ord(value[(i mod 17)+1]) xor ord(value[16-(i mod 17)]) then begin
              isShareaza:=false;
              break;
             end;
            end;
          end;
              if isShareaza then begin
               result:='Shareaza';
               exit;
              end;
end;

   result:='Unknown ('+value+')';


end;

function stripChar(inString:string; character:string):string;
begin
result:=inString;

while (pos(character,result)<>0) do
 result:=copy(result,1,pos(character,result)-1) +
         copy(result,pos(character,result)+length(character),length(result));

end;


function BTSourceStatusToStringW(status:tbittorrentSourceStatus):widestring;
begin
 case status of
  btSourceIdle:result:=GetLangStringW(STR_IDLE);
  btSourceConnecting:result:=GetLangStringW(STR_CONNECTING);
  btSourceReceivingHandshake:result:=GetLangStringW(STR_REQUESTING);
  btSourceweMustSendHandshake:result:=GetLangStringW(STR_REQUESTING);
  btSourceShouldDisconnect:result:='Disconnecting';
  btSourceShouldRemove:result:='Removing';
  btSourceConnected:result:=GetLangStringW(STR_CONNECTED);
 end;
end;

function BTProgressToFamiltyStrName(progress:integer):widestring;
begin
if progress=100 then result:='Seed'
 else result:='Leecher';
end;

function BTSourceStatusToByte(status:tbittorrentSourceStatus):byte;
begin
 case status of
  btSourceShouldRemove:result:=0;
  btSourceShouldDisconnect:result:=1;
  btSourceIdle:result:=2;
  btSourceConnecting:result:=3;
  btSourceReceivingHandshake:result:=4;
  btSourceweMustSendHandshake:result:=5;
  btSourceConnected:result:=6
   else result:=0;
 end;
end;

function int_2_dword_stringRev(const numero:cardinal):string;
var
buff:array[0..3] of char;
begin

  move(numero,buff,4);

  setlength(result,4);
  result[1]:=buff[3];
  result[2]:=buff[2];
  result[3]:=buff[1];
  result[4]:=buff[0];
end;

function int_2_word_stringRev(const numero:word):string;
var
buff:array[0..1] of char;
begin
  move(numero,buff,2);

  setlength(result,2);
  result[1]:=buff[1];
  result[2]:=buff[0];
end;

function GetrandomAsciiChars(howmany:integer):string;
const
 ALPHABET='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
var
i:integer;
begin

for i:=1 to howmany do begin
 result:=result+alphabet[random(length(alphabet))+1];
end;

end;

function GetrandomChars(howmany:integer):string;
var
i:integer;
begin

for i:=1 to howmany do begin
 result:=result+chr(random(255));
end;

end;

function fullUrlEncode(value:string):string;
var
i:integer;
begin
result:='';

for i:=1 to length(value) do result:=result+'%'+inttohex(ord(value[i]),2);
end;

function GetPathFromUrl(value:string):string;
var
ind:integer;
begin
result:='';

ind:=pos('http://',lowercase(value));
if ind<>0 then delete(value,1,ind+6);

ind:=pos('/',value);
if ind<>0 then begin
 delete(value,1,ind-1);
 result:=value;
end;

end;

function GetFullScrapeURL(const value:string):string;
begin
result:=value;
result:=copy(result,1,pos('/announce',lowercase(result)))+
       'scrape'+
       copy(result,pos('/announce',lowercase(result))+9,length(result));
end;

function GetScrapePathFromUrl(const value:string):string;
begin
result:=GetPathFromUrl(value);
result:=copy(result,1,pos('/announce',lowercase(result)))+
       'scrape'+
       copy(result,pos('/announce',lowercase(result))+9,length(result));
end;

function GetHostFromUrl(value:string):string;
var
ind:integer;
lovalue:string;
begin    // http://www.host.com:81/index.html   --> www.host.com
lovalue:=lowercase(value);

ind:=pos('://',lovalue);
if (ind<>0) then delete(lovalue,1,ind+2);

ind:=pos('/',lovalue);
if (ind<>0) then delete(lovalue,ind,length(lovalue));

ind:=pos(':',lovalue);
if (ind<>0) then delete(lovalue,ind,length(lovalue));

result:=lovalue;

end;

function GetPortFromUrl(value:string):word;
var
ind:integer;
lovalue:string;
begin    // http://www.host.com:81/index.html   --> 81

lovalue:=lowercase(value);

ind:=pos('://',lovalue);
if ind<>0 then delete(lovalue,1,ind+2);

ind:=pos('/',lovalue);
if ind<>0 then delete(lovalue,ind,length(lovalue));

ind:=pos(':',lovalue);
if ind<>0 then delete(lovalue,1,ind);

result:=strtointdef(lovalue,80);
end;

function bool2verbose(value:boolean):string;
begin
if value then result:='Yes' else result:='No';
end;

function chars_2_dwordRev(const stringa:string):cardinal;
begin
if length(stringa)>=4 then begin
result:=ord(stringa[1]);
result:=result shl 8;
result:=result + ord(stringa[2]);
result:=result shl 8;
result:=result + ord(stringa[3]);
result:=result shl 8;
result:=result + ord(stringa[4]);
end else result:=0;
end;

function chars_2_wordRev(const stringa:string):cardinal;
begin
if length(stringa)>=2 then begin
result:=ord(stringa[1]);
result:=result shl 8;
result:=result + ord(stringa[2]);
end else result:=0;
end;

end.