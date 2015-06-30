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

*****************************************************************
 The following delphi code is based on Emule (0.46.2.26) Kad's implementation http://emule.sourceforge.net
 and KadC library http://kadc.sourceforge.net/
*****************************************************************
 }

{
Description:
DHT types
}

unit dhttypes;

interface

uses
 classes,classes2,sysutils,windows,keywfunc,blcksock;

 type
 precord_DHT_keywordFilePublishReq=^record_DHT_keywordFilePublishReq;
 record_DHT_keywordFilePublishReq=record
  keyW:string;
  crc:word;  // last two bytes of 20 byte sha1
  fileHashes:tmystringlist;
 end;

 type
 precord_dht_source=^record_dht_source;
 record_dht_source=record
  ip:cardinal;
  raw:string;
  lastSeen:cardinal;
  prev,next:precord_dht_source;
 end;

 type
 precord_dht_outpacket=^record_dht_outpacket;
 record_dht_outpacket=record
  destIP:cardinal;
  destPort:word;
  buffer:string;
 end;

 type
 precord_DHT_firewallcheck=^record_DHT_firewallcheck;
 record_DHT_firewallcheck=record
  RemoteIp:cardinal;
  RemoteUDPPort:word;
  RemoteTCPPort:word;
  started:cardinal;
  sockt:HSocket;
 end;


 type
 precord_DHT_hash=^record_dht_hash;
 record_dht_hash=record
  hashValue:array[0..19] of byte;
  crc:word;
  count:word; // number of items
  lastSeen:cardinal;
  firstSource:precord_dht_source;
  prev,next:precord_dht_hash;
 end;

 type
 precord_DHT_hashfile=^record_DHT_hashfile;
 record_DHT_hashfile=record
  HashValue:array[0..19] of byte;
 end;

 type
 precord_dht_storedfile=^record_dht_storedfile;
 record_dht_storedfile=record

  hashValue:array[0..19] of byte;
  crc:word;

  amime:byte;
  ip:cardinal; //last publish source is available immediately
  port:word;

  count:word;
  lastSeen:cardinal;

   fsize:int64;
   param1,param3:cardinal;
   info:string;

   numKeywords:byte;
   keywords:PWordsArray;

  prev,next:precord_dht_storedfile;
 end;

 type
 PDHTKeyWordItem=^TDHTKeyWordItem;
 TDHTKeywordItem = packed record
   share       : precord_dht_storedfile;
   prev, next  : PDHTKeywordItem;
 end;
 PDHTKeyword = ^TDHTKeyword;
 TDHTKeyword = packed record // structure that manages one keyword
   keyword     : array of char; // keyword
   count       : cardinal;
   crc         : word;
   firstitem   : PDHTKeywordItem; // pointer to first full item
   prev, next  : PDHTKeyword; // pointer to previous and next PKeyword items in global list
 end;

type
tdhtsearchtype=(
               UNDEFINED,
               NODE,
		           NODECOMPLETE,
		           KEYWORD,
		           STOREFILE,
		           STOREKEYWORD,
		           FINDSOURCE
	            );


implementation



end.