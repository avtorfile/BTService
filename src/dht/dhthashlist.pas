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
DHT hashlists used by dhtthread to store published files
}

unit dhthashlist;

interface


uses
 dhttypes,hashlist,classes,sysutils,helper_datetime;

 const
 DB_DHTHASH_ITEMS     = 1031;
 DB_DHTKEYFILES_ITEMS = 1031;
 DB_DHT_KEYWORD_ITEMS = 1031;
 DB_DHTHASHPARTIALSOURCES_ITEMS = 1031;
 DHT_EXPIRE_FILETIME  = 21600;// 6 hours (seconds)
 DHT_EXPIRE_PARTIALSOURCES = 3600; // 1 hour

 procedure DHT_CheckExpireHashFileList(hslst:THashList; TimeInterval:Cardinal);
 procedure DHT_FreeHashFileList(Firsthash:precord_dht_hash; hslt:THashList);
 procedure DHT_FreeHashFile(hash:precord_dht_hash; hlst:thashList);
 function DHT_findhashFileSource(hash:precord_dht_hash; ip:cardinal):precord_dht_source;
 function DHT_FindHashFile(hslt:THashList):precord_DHT_hash;
 procedure DHT_CheckExpireHashFile(hash:precord_dht_hash; nowt:cardinal; timeInterval:cardinal; hlst:thashlist);
 procedure DHT_FreeSource(source:precord_dht_source; hash:precord_dht_hash);
 procedure DHT_FreeLastSource(hash:precord_dht_hash);

 function DHT_FindKeywordFile:precord_dht_storedfile;
 procedure DHT_FreeKeyWordFile(pfile:precord_dht_storedfile);
 procedure DHT_FreeKeywordFileList(FirstKeywordFile:precord_dht_storedfile);
 procedure DHT_FreeFile_Keyword(keyword: PDHTKeyword; item: PDHTKeywordItem; share:precord_dht_storedfile);
 procedure DHT_CheckExpireKeywordFileList;

 function DHT_KWList_Findkey(keyword:pchar; lenkey:byte; crc:word): PDHTKeyword;
 function DHT_KWList_Addkey(keyword:pchar; lenkey:byte; crc:word): PDHTKeyword;
 function DHT_KWList_AddShare(keyword:PDHTKeyword; share:precord_dht_storedfile): PDHTKeywordItem;

 var
 db_DHT_hashFile:ThashList;
 db_DHT_hashPartialSources:THashList;
 db_DHT_keywordFile:THashList;
 db_DHT_keywords:THashlist;
 DHT_SharedFilesCount:integer;
 DHT_SharedHashCount:integer;
 DHT_SharedPartialSourcesCount:integer;

implementation

uses
 thread_dht,windows;


/////////////////////////////////////////// hash file sources /////////////////////////
procedure DHT_CheckExpireHashFileList(hslst:THashList; TimeInterval:Cardinal);
var
i:integer;
FirstHash,nextHash:precord_dht_hash;
nowt:cardinal;
begin
nowt:=time_now;

 for i:=0 to high(hslst.bkt) do begin
     if hslst.bkt[i]=nil then continue;

     FirstHash:=hslst.bkt[i];
     while (FirstHash<>nil) do begin
       nextHash:=FirstHash^.next;
       DHT_CheckExpireHashFile(firstHash,
                               nowt,
                               TimeInterval,
                               hslst);
       FirstHash:=nextHash;
     end;

 end;

end;

procedure DHT_CheckExpireHashFile(hash:precord_dht_hash; nowt:cardinal; timeInterval:cardinal; hlst:thashlist);
var
source,nextsource:precord_dht_source;
begin

       if nowt-hash^.lastSeen>timeInterval then begin   
        DHT_FreeHashFile(hash,hlst);
        exit;
       end;

        source:=Hash^.firstSource;
        while (source<>nil) do begin
         nextSource:=Source^.next;
          if nowt-source^.lastSeen>timeInterval then DHT_FreeSource(source,hash);
         source:=nextSource;
        end;

        if hash^.firstSource=nil then DHT_FreeHashFile(hash,hlst);
        //hash^.count=0
end;

procedure DHT_FreeLastSource(hash:precord_dht_hash);
var
source:precord_dht_source;
begin
  source:=Hash^.firstSource;
  while (source<>nil) do begin
    if source^.next=nil then begin
     DHT_FreeSource(source,hash);
     break;
    end;
    Source:=Source^.next;
  end;
end;

procedure DHT_FreeSource(source:precord_dht_source; hash:precord_dht_hash);
begin
 source^.raw:='';

 if source^.prev=nil then hash^.firstSource:=source^.next
 else source^.prev^.next:=source^.next;
 if source^.next<>nil then source^.next^.prev:=source^.prev;

 FreeMem(source,sizeof(record_dht_source));
 dec(hash^.count);
end;

procedure DHT_FreeHashFile(hash:precord_dht_hash; hlst:ThashList);
var
source,nextsource:precord_dht_source;
begin

       source:=Hash^.firstSource;
        while (source<>nil) do begin
         nextSource:=Source^.next;
          DHT_FreeSource(source,hash);
         source:=nextSource;
        end;

      if hash^.prev=nil then hlst.bkt[hash^.crc mod DB_DHTHASH_ITEMS]:=hash^.next
      else hash^.prev^.next:=hash^.next;
      if hash^.next<>nil then hash^.next^.prev:=hash^.prev;

    FreeMem(Hash,sizeof(recorD_dht_hash));

   if hlst=db_DHT_hashFile then begin
     if DHT_SharedHashCount>0 then dec(DHT_SharedHashCount);
   end else begin
    if DHT_SharedPartialSourcesCount>0 then dec(DHT_SharedPartialSourcesCount);
   end;

end;

procedure DHT_FreeHashFileList(Firsthash:precord_dht_hash; hslt:THashList);
var
nextHash:precord_dht_hash;
begin
if firstHash=nil then exit;

  while (FirstHash<>nil) do begin
   nextHash:=FirstHash^.next;
    DHT_FreeHashFile(firstHash,hslt);
   FirstHash:=nextHash;
 end;

end;

function DHT_FindHashFile(hslt:THashList):precord_DHT_hash;
begin

 if hslt.bkt[DHT_crcsha1_global mod DB_DHTHASH_ITEMS]=nil then begin
  result:=nil;
  exit;
 end;

 result:=hslt.bkt[(DHT_crcsha1_global mod DB_DHTHASH_ITEMS)];
   while (result<>nil) do begin
     if result^.crc=DHT_crcsha1_global then
       if comparemem(@result^.hashValue[0],@DHT_hash_sha1_global[0],20) then exit;
     result:=result^.next;
   end;
end;

function DHT_findhashFileSource(hash:precord_dht_hash; ip:cardinal):precord_dht_source;
begin
 result:=hash^.firstSource;
  while (result<>nil) do begin
   if result^.ip=ip then exit;
   result:=result^.next;
  end;
end;
////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////// keyword file db //////////////////////////////////////////
function DHT_FindKeywordFile:precord_dht_storedfile;
begin

 if db_DHT_keywordFile.bkt[(DHT_crcsha1_global mod DB_DHTKEYFILES_ITEMS)]=nil then begin
  result:=nil;
  exit;
 end;

   result:=db_DHT_keywordFile.bkt[(DHT_crcsha1_global mod DB_DHTKEYFILES_ITEMS)];
   while (result<>nil) do begin
     if result^.crc=DHT_crcsha1_global then
       if comparemem(@result^.hashValue[0],@DHT_hash_sha1_global[0],20) then exit;
     result:=result^.next;
   end;

end;


procedure DHT_FreeKeywordFileList(FirstKeywordFile:precord_dht_storedfile);
var
nextKeywordFile:precord_dht_storedfile;
begin
if firstKeyWordFile=nil then exit;

  while (firstKeyWordFile<>nil) do begin
   nextKeywordFile:=firstKeyWordFile^.next;

    DHT_FreeKeyWordFile(firstKeyWordFile);

   firstKeyWordFile:=nextKeywordFile;
 end;

end;

procedure DHT_FreeFile_Keyword(keyword: PDHTKeyword; item: PDHTKeywordItem; share:precord_dht_storedfile);

 procedure DHT_FreeKeyWord(keyword: PDHTKeyword);
 begin
  if db_DHT_keywords.bkt[keyword^.crc mod DB_DHT_KEYWORD_ITEMS]=nil then exit;

  if keyword^.prev=nil then db_DHT_keywords.bkt[keyword^.crc mod DB_DHT_KEYWORD_ITEMS]:=keyword^.next
  else keyword^.prev^.next:=keyword^.next;
  if keyword^.next<>nil then keyword^.next^.prev:=keyword^.prev;

  setlength(keyword^.keyword,0);
  FreeMem(keyword,sizeof(TDHTKeyword));
 end;

begin

 if item=nil then exit;// already cleared keyword for this item, this happens with files having duplicated keywords

 if item^.prev=nil then keyword^.firstitem:=item^.next
 else item^.prev^.next:=item^.next;
 if item^.next<>nil then item^.next^.prev:=item^.prev;

 FreeMem(item,sizeof(TDHTKeywordItem));
 dec(keyword^.count);

 if keyword^.firstitem=nil then DHT_FreeKeyWord(keyword);
end;


procedure DHT_FreeKeyWordFile(pfile:precord_dht_storedfile);
var
i:integer;
begin

 pfile^.info:='';

  // remove file keyword items, and whole keyword if needed
  for i:=0 to pfile^.numkeywords-1 do DHT_FreeFile_Keyword(pfile^.keywords[i*3],pfile^.keywords[(i*3)+1],pfile);
  FreeMem(pfile^.keywords, pfile^.numkeywords * 3 * SizeOf(Pointer));

  // detach file from list
 if pfile^.prev=nil then db_DHT_keywordFile.bkt[(pfile^.crc mod DB_DHTKEYFILES_ITEMS)]:=pfile^.next
 else pfile^.prev^.next:=pfile^.next;
 if pfile^.next<>nil then pfile^.next^.prev:=pfile^.prev;

 FreeMem(pfile,sizeof(record_dht_storedfile));

 if DHT_SharedFilesCount>0 then dec(DHT_SharedFilesCount);
end;


procedure DHT_CheckExpireKeywordFileList; // once every 60 minutes
var
i:integer;
FirstKeywordFile,nextKeywordFile:precord_dht_storedfile;
nowt:cardinal;
begin
nowt:=time_now;

 for i:=0 to high(db_DHT_keywordFile.bkt) do begin
     if db_DHT_keywordFile.bkt[i]=nil then continue;

     FirstKeywordFile:=db_DHT_keywordFile.bkt[i];
     while (FirstKeywordFile<>nil) do begin
       nextKeywordFile:=FirstKeywordFile^.next;

       if nowt-FirstKeywordFile^.lastSeen>DHT_EXPIRE_FILETIME then DHT_FreeKeyWordFile(FirstKeywordFile)
        else begin
         if FirstKeywordFile^.count>30 then FirstKeywordFile^.count:=30;
        end;

       FirstKeywordFile:=nextKeywordFile;
     end;

 end;
 

end;

/////////////////////////////////////////////////////////////////////////////7



/////////////////////////7 KEYWORDS /////////////////////////////////////////

function DHT_KWList_Findkey(keyword:pchar; lenkey:byte; crc:word): PDHTKeyword;
begin
    if db_DHT_keywords.bkt[(crc mod DB_DHT_KEYWORD_ITEMS)]=nil then begin
     result:=nil;
     exit;
    end;

    result:=db_DHT_keywords.bkt[(crc mod DB_DHT_KEYWORD_ITEMS)];
    while (result<>nil) do begin
        if length(result^.keyword)=lenkey then
         if comparemem(@result^.keyword[0],keyword,lenkey) then exit;
       result:=result^.next;
    end;
end;

function writestringfrombuffer(buff:pointer; len:integer):string;
begin
setlength(result,len);
move(buff^,result[1],len);
end;

function DHT_KWList_Addkey(keyword:pchar; lenkey:byte; crc:word): PDHTKeyword;
   var
   first:PDHTKeyword;
begin
    result:=AllocMem(sizeof(TDHTKeyword));

    setlength(result^.keyword,lenkey);
    move(keyword^,result^.keyword[0],lenkey);

    result^.firstitem:=nil;
    result^.count:=0;
    result^.crc:=crc;

    first:=db_DHT_keywords.bkt[(crc mod DB_DHT_KEYWORD_ITEMS)];
    result^.next:=first;
    if first<>nil then first^.prev:=result;
    result^.prev:=nil;
    db_DHT_keywords.bkt[(crc mod DB_DHT_KEYWORD_ITEMS)]:=result;
end;



function DHT_KWList_AddShare(keyword:PDHTKeyword; share:precord_dht_storedfile): PDHTKeywordItem;

    function DHT_KWList_ShareExists(keyword:PDHTKeyword; share:precord_DHT_storedfile):boolean;
    begin
     if keyword^.firstitem=nil then begin
      result:=false;
      exit;
    end;
    result:=(keyword^.firstItem^.share=share);  // can be only the first item
    end;
    
begin
//we seen already this keyword for this file, eg keyword contained in both title and artist field,
//the first keyword instance gets a valid 'item' pointer, the second one a nil pointer...
if DHT_KWList_ShareExists(keyword,share) then begin
 result:=nil;
 exit;
end;

result:=AllocMem(sizeof(TDHTKeywordItem));

 result^.next:=keyword^.firstitem;
 if keyword^.firstitem<>nil then keyword^.firstitem^.prev:=result;
 result^.prev:=nil;
 keyword^.firstitem:=result;  
 result^.share:=share;

inc(keyword^.count);
end;





end.