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
misc stuff 
}

unit BitTorrentUtils;

interface

uses
 classes,classes2,windows,sysutils,btcore,torrentParser,ares_objects, dialogs,
 uExtraData;

 type
 TBitTorrentTransferCreator=class(tthread)
  protected
   BitTorrentTransfer:tBittorrentTransfer;
   procedure execute; override;
   procedure start_thread;//sync
//   procedure AddVisualTransferReference;
  public
   path:widestring;
   id:widestring;
   progressive:Boolean;
 end;

 type
 TBitTorrentSeedingCreator=class(tthread)
  protected
   BitTorrentTransfer:tBittorrentTransfer;
   procedure execute; override;
   procedure start_thread;//sync
//   procedure AddVisualTransferReference;
  public
   path:widestring;
   id:widestring;
   progressive:Boolean;
 end;


//procedure parseMetaTorrent(info:TTorrentParser);
procedure start_thread_bittorrent;
procedure StartSeeding(torrentfilename:widestring;{filename:widestring;}idtorrent:widestring='');
procedure loadTorrent(filename:widestring;idtorrent:widestring='';pdl:boolean=false);
procedure check_bittorrentTransfers;
function BTRatioToEmotIndex(uploaded:int64; downloaded:int64):integer;
procedure hash_compute(const FileName: widestring; fsize:int64; var sha1:string; var hash_of_phash:string; var point_of_insertion:cardinal);
procedure loadmagnetTorrent(ahash:string; const suggestedName,trackerURL:string;ID:string='';pdl:boolean=false);
function bittorrentStatetoByte(state:TDownloadState):byte;
function BytetoBittorrentState(inb:byte):TDownloadState;

implementation

uses
 helper_diskio,ares_types,helper_unicode,
 {tntwindows,ufrmmain,}vars_global,helper_ICH,
 BitTorrentDlDb,thread_bittorrent,helper_strings,const_ares,
 {comettrees,}helper_urls,helper_base64_32,
 helper_mimetypes,dhtkeywords,helper_share_misc,secureHash;



procedure start_thread_bittorrent;
begin
vars_global.thread_bittorrent.resume;
end;

function bittorrentStatetoByte(state:TDownloadState):byte;
begin
 case state of
  dlprocessing,dldownloading:result:=0;
  dlPaused:result:=1;
  dlSeeding:result:=2
   else result:=0;
  end;

end;

function BytetoBittorrentState(inb:byte):TDownloadState;
begin
 case inb of
  0:result:=dlProcessing;
  1:result:=dlPaused;
  2:result:=dlSeeding;
 end;
end;

procedure loadmagnetTorrent(ahash:string; const suggestedName,trackerURL:string;ID:string='';pdl:boolean=false);
var
 BitTorrentTransfer:tBittorrentTransfer;
// node:pcmtvnode;
// dataNode:ares_types.precord_data_node;
// data:precord_displayed_bittorrentTransfer;
// afile:TBitTorrentFile;
// tracker:tbittorrentTracker;
begin
 if length(ahash)<>40 then begin
  ahash:=bytestr_to_hexstr(helper_base64_32.DecodeBase32(ahash));
  if length(ahash)<>40 then begin
   //ShowMessage('length(ahash)<>40: '+ahash);
   exit;
  end;
 end;

 //ShowMessage('id3: '+id);
 BitTorrentTransfer:=tBittorrentTransfer.create;
 BitTorrentTransfer.fid:=ID;
 BitTorrentTransfer.fprogressive:=pdl;
 BitTorrentTransfer.fhashvalue:=helper_strings.hexstr_to_bytestr(ahash);
 //ShowMessage('fhashvalue: '+BitTorrentTransfer.fhashvalue);
 BitTorrentTransfer.ffileS:=tmylist.create;
 if length(suggestedName)=0 then BitTorrentTransfer.fname:='Magnet URI:'+ahash
  else BitTorrentTransfer.fname:=suggestedName;

 if length(trackerURL)>0 then BittorrentTransfer.addTracker(trackerURL);

 bittorrentTransfer.fstate:=dlBittorrentMagnetDiscovery;
 //ShowMessage('Status dlBittorrentMagnetDiscovery: '+BitTorrentTransfer.fhashvalue);

 //Form1.Memo2.Lines.Add('ahash: '+ahash);
 //Form1.Memo2.Lines.Add('suggestedName: '+BitTorrentTransfer.fname);
 //Form1.Memo2.Lines.Add('trackerURL: '+trackerURL);

  /////////////////////////// VISUAL //////////////////////////////////////////
//       node:=ares_frmmain.treeview_download.AddChild(nil);
//       dataNode:=ares_frmmain.treeview_download.getdata(Node);
//
//      dataNode^.m_type:=dnt_bittorrentMain;
//
//      data:=AllocMem(sizeof(record_displayed_bittorrentTransfer));
//      dataNode^.data:=Data;
//
//     bittorrentTransfer.visualNode:=node;
//     bittorrentTransfer.visualData:=data;
//     bittorrentTransfer.visualData^.handle_obj:=longint(bittorrentTransfer);
//     bittorrentTransfer.visualData^.FileName:=BitTorrentTransfer.fname;
//     bittorrentTransfer.visualData^.Size:=0;
//     bittorrentTransfer.visualData^.downloaded:=0;
//     bittorrentTransfer.visualData^.uploaded:=0;
//     bittorrentTransfer.visualData^.hash_sha1:=bittorrentTransfer.fhashvalue;
//     bittorrentTransfer.visualData^.crcsha1:=crcstring(bittorrentTransfer.fhashvalue);
//     bittorrentTransfer.visualData^.SpeedDl:=0;
//     bittorrentTransfer.visualData^.SpeedUl:=0;
//     bittorrentTransfer.visualData^.want_cancelled:=false;
//     bittorrentTransfer.visualData^.want_paused:=false;
//     bittorrentTransfer.visualData^.want_changeView:=false;
//     bittorrentTransfer.visualData^.want_cleared:=false;
//     bittorrentTransfer.visualData^.num_Sources:=0;
//     bittorrentTransfer.visualData^.ercode:=0;
//     bittorrentTransfer.visualData^.state:=bittorrentTransfer.fstate;
//     if bittorrentTransfer.trackers.count>0 then begin
//      tracker:=bittorrentTransfer.trackers[bittorrentTransfer.trackerIndex];
//      bittorrentTransfer.visualData^.trackerStr:=tracker.URL;
//     end else bittorrentTransfer.visualData^.trackerStr:='';
//     bittorrentTransfer.visualData^.Fpiecesize:=0;
//     bittorrentTransfer.visualData^.NumLeechers:=0;
//     bittorrentTransfer.visualData^.NumSeeders:=0;
//     if bittorrentTransfer.ffiles.count=1 then begin
//       afile:=bittorrentTransfer.ffiles[0];
//       bittorrentTransfer.visualData^.path:=afile.ffilename;
//     end else bittorrentTransfer.visualData^.path:=bittorrentTransfer.fname;
//     bittorrentTransfer.visualData^.NumConnectedSeeders:=0;
//     bittorrentTransfer.visualData^.NumConnectedLeechers:=0;
//    SetLength(bittorrentTransfer.visualData^.bitfield,length(bittorrentTransfer.FPieces));
//
//   btcore.CloneBitField(bittorrentTransfer);
   /////////////////////////////////////////////////////////////////////////////////////////

 if vars_global.BitTorrentTempList=nil then vars_global.BitTorrentTempList:=tmylist.create;
 if vars_global.bittorrent_Accepted_sockets=nil then vars_global.bittorrent_Accepted_sockets:=tmylist.create;

  if vars_global.thread_bittorrent=nil then begin
    vars_global.thread_bittorrent:=tthread_bitTorrent.create(true);
     vars_global.thread_bittorrent.BittorrentTransfers:=tmylist.create;
     vars_global.thread_bittorrent.TrackersThreadList:=TList.create;
     vars_global.thread_bittorrent.TransfersThreadList:=TList.create;
     vars_global.thread_bittorrent.resume;
     //ShowMessage('thread_bittorrent.resume: '+BitTorrentTransfer.fhashvalue);
  end;
  vars_global.BitTorrentTempList.add(BitTorrentTransfer);
  //ShowMessage('vars_global.BitTorrentTempList.add(BitTorrentTransfer): '+BitTorrentTransfer.fhashvalue);

// if ares_frmmain.tabs_pageview.activePage<>IDTAB_TRANSFER then ares_frmmain.tabs_pageview.activePage:=IDTAB_TRANSFER;

end;

function BTRatioToEmotIndex(uploaded:int64; downloaded:int64):integer;
begin
if ((uploaded>=downloaded) and (uploaded>0)) then result:=0
 else result:=9;
end;

procedure check_bittorrentTransfers;
var
 doserror:integer;
 dirinfo:ares_types.TSearchRecW;
 BitTorrentTransfer:tBittorrentTransfer;
 str:string;
 iterations:integer;
begin

   iterations:=0;
   dosError:=helper_diskio.FindFirstW(vars_global.data_Path+'\Data\TempDl\PBTHash_*.dat', faAnyfile, dirInfo);
   while (DosError=0) do begin
       if (((dirinfo.Attr and faDirectory)>0) or
            (dirinfo.name='.') or
            (dirinfo.name='..')) then begin
              DosError:=helper_diskio.FindNextW(dirinfo);
              continue;
       end;

       str:=dirinfo.name;
       delete(str,1,8);
       delete(str,length(str)-3,4);

       if length(str)=40 then begin

          BitTorrentTransfer:=tBitTorrentTransfer.create;
          BitTorrentTransfer.fhashvalue:=helper_strings.hexstr_to_bytestr(str);

          BitTorrentDlDb.BitTorrentDb_load(BitTorrentTransfer);

          if ((BitTorrentTransfer.ferrorCode>0) and
              (BitTorrentTransfer.ferrorCode<BT_DBERROR_FILES_LOCKED)) then begin
            BitTorrentTransfer.free;
            DosError:=helper_diskio.FindNextW(dirinfo);
            continue;
          end;

          
          if vars_global.bittorrent_Accepted_sockets=nil then vars_global.bittorrent_Accepted_sockets:=tmylist.create;
          if vars_global.thread_bittorrent=nil then begin
           vars_global.thread_bittorrent:=tthread_bitTorrent.create(true);
           vars_global.thread_bittorrent.BittorrentTransfers:=tmylist.create;
           vars_global.thread_bittorrent.TrackersThreadList:=TList.create;
           vars_global.thread_bittorrent.TransfersThreadList:=TList.create;
          end;
          vars_global.thread_bittorrent.BittorrentTransfers.add(BitTorrentTransfer);
       end;

       DosError:=helper_diskio.FindNextW(dirinfo);

       inc(iterations);
       if iterations>500 then break;
   end;


   helper_diskio.FindCloseW(dirinfo);

  if (vars_global.thread_bittorrent<>nil)
  and assigned(vars_global.thread_bittorrent) then
  begin
    vars_global.thread_bittorrent.resume;
  end;     
end;

{procedure parseMetaTorrent(info:TTorrentParser);
var
 i:integer;
 maxSize:int64;
 ThisFile:TTorrentSubFile;
 thefilename:string;
begin
maxSize:=0;
 for i:=0 to info.Files.count-1 do begin
  thisfile:=(info.Files[i] as TTorrentSubFile);

   thisfile.Name:=StripIllegalFileChars(thisfile.Name);
   if length(thisfile.Name)>200 then thisfile.name:=copy(thisfile.name,1,200);
    if thisfile.Length>maxSize then begin
     maxSize:=thisfile.Length;
     thefilename:=thisfile.name;
    end;
  end;


end; }

function Tnt_CreateDirectoryW(lpPathName: PWideChar;
  lpSecurityAttributes: PSecurityAttributes): BOOL;
var Win32PlatformIsUnicode : boolean;
begin
Win32PlatformIsUnicode := (Win32Platform = VER_PLATFORM_WIN32_NT);
  if Win32PlatformIsUnicode then
    Result := CreateDirectoryW{TNT-ALLOW CreateDirectoryW}(lpPathName, lpSecurityAttributes)
  else
    Result := CreateDirectoryA{TNT-ALLOW CreateDirectoryA}(PAnsiChar(AnsiString(lpPathName)), lpSecurityAttributes);
end;



procedure TBitTorrentTransferCreator.execute;
var
stream:thandlestream;
Parser:TTorrentParser;
//SL:TStringList;
torrentName,tmpPath:string;
buffer:array[0..2] of byte;
i:integer;
ffile:TBittorrentFile;
begin
priority:=tpnormal;
freeonterminate:=false; //freeonterminate:=true;

//showmessage('BitTorrentTransferCreator');
//showmessage('path: '+path);
stream:=MyFileOpen(path,ARES_READONLY_BUT_SEQUENTIAL);
if stream=nil then
begin
//ShowMessage('stream = nil');
//Form1.Memo2.Text:='stream = nil';
exit;
end;

//showmessage('TTorrentParser.Create');
Parser:=TTorrentParser.Create;

 if not Parser.Load(stream) then begin
  parser.free;
  FreeHandleStream(Stream);
  exit;
 end
 else
 begin
 {SL:=TStringList.Create;
 SL.Text:='_Announce: '+parser._Announce;
 SL.Add('torrentName: '+parser.name);
 SL.Add('torrentComment: '+parser.Comment);
 SL.Add('torrentHashValue: '+parser.HashValue);
 SL.Add('torrentSize: '+IntToStr(parser.Size));    
 SL.SaveToFile('e:\Downloads\Test\Test.txt');
 SL.Free;}
 end;     

 parser.id:=id;
 parser.Progressive:=progressive;
 torrentName:=parser.name;

 TorrentName:=StripIllegalFileChars(TorrentName);
 if length(TorrentName)>200 then delete(TorrentName,200,length(TorrentName));

   if length(torrentName)=0 then begin
     tmpPath:=widestrtoutf8str(path);
     for i:=length(tmpPath) downto 1 do if tmpPath[i]='\' then break;
     if i>1 then delete(TmpPath,1,i);
     torrentName:=tmpPath;
     for i:=length(torrentName) downto 1 do
      if torrentName[i]='.' then begin  // remove .torrent ext
       delete(TorrentName,i,length(TorrentName));
       break;
      end;
   end;

   
 {Torrent name already in download?}
   if direxistsW(vars_global.my_torrentFolder+'\'+utf8strtowidestr(torrentName)) then begin
     if FileExists(vars_global.data_Path+'\Data\TempDl\PBTHash_'+bytestr_to_hexstr(parser.hashValue)+'.dat') then begin
       parser.free;
       FreeHandleStream(Stream);
       exit;
     end;

   torrentName:=torrentName+inttohex(random($ff),2)+inttohex(random($ff),2);
   end;
   while direxistsW(vars_global.my_torrentFolder+'\'+utf8strtowidestr(torrentName)) do
    torrentName:=copy(torrentName,1,length(torrentName)-4)+inttohex(random($ff),2)+inttohex(random($ff),2);
  //////////////////////////////////////////

 tnt_createdirectoryW(pwidechar(vars_global.my_torrentFolder),nil);
 if parser.Files.count>1 then tnt_createdirectoryW(pwidechar(vars_global.my_torrentFolder+'\'+utf8strtowidestr(torrentName)),nil);

 BitTorrentTransfer:=tBittorrentTransfer.create;
 BitTorrentTransfer.fseeding:=False;
 BitTorrentTransfer.init(widestrtoutf8str(vars_global.my_torrentFolder)+'\'+torrentName,
                                          Parser);

//parseMetaTorrent(parser);
parser.free;
FreeHandleStream(Stream);


 if ((BitTorrentTransfer.ferrorCode>0) and
     (BitTorrentTransfer.ferrorCode<BT_DBERROR_FILES_LOCKED)) then begin
     BitTorrentTransfer.free;
     exit;
 end;



buffer[0]:=0;

//synchronize(AddVisualTransferReference);

// let thread_bittorrent know when file is ready for writing
for i:=0 to bittorrentTransfer.ffiles.count-1 do begin
 ffile:=bittorrentTransfer.ffiles[i];

 FreeHandleStream(ffile.fstream);
 while true do begin
 ffile.fstream:=MyFileOpen(utf8strtowidestr(ffile.ffilename),ARES_WRITE_EXISTING);
 if ffile.fstream<>nil then break else sleep(10);
 end;
{
 if ffile.fstream.size>0 then begin
  helper_diskio.MyFileSeek(ffile.fstream,ffile.fsize-1,ord(soFromBeginning));
    while (true) do begin
     if helper_diskio.MyFileSeek(ffile.fstream,0,ord(soCurrent))<>ffile.fsize-1 then begin
      helper_diskio.MyFileSeek(ffile.fstream,ffile.fsize-1,ord(soFromBeginning));
      sleep(50);
      continue;
     end else break;
    end;

    ffile.fstream.Write(buffer,1);
  end; }


 end;


//end;

bittorrentTransfer.fstate:=dlProcessing;



EnterCriticalSection(ServiceSection);
try
{synchronize}(start_thread);
finally
LeaveCriticalSection(ServiceSection);
end;

end;

procedure TBitTorrentSeedingCreator.execute;
var
stream:thandlestream;
Parser:TTorrentParser;
//SL:TStringList;
torrentName,tmpPath:string;
buffer:array[0..2] of byte;
i:integer;
ffile:TBittorrentFile;
begin
priority:=tpnormal;
freeonterminate:=false; //freeonterminate:=true;    

//showmessage('BitTorrentTransferCreator');
//showmessage('path: '+path);
stream:=MyFileOpen(path,ARES_READONLY_BUT_SEQUENTIAL);
if stream=nil then
begin
//ShowMessage('stream = nil');
//Form1.Memo2.Text:='stream = nil';
exit;
end;

//showmessage('TTorrentParser.Create');
Parser:=TTorrentParser.Create;
 if not Parser.Load(stream) then begin
  parser.free;
  FreeHandleStream(Stream);
  exit;
 end
 else
 begin
 //showmessage('Parser loaded');
 //showmessage('torrentName: '+parser.name);
 //showmessage('torrentComment: '+parser.Comment);
 //showmessage('torrentHashValue: '+parser.HashValue);
 //showmessage('torrentSize: '+IntToStr(parser.Size));
 {SL:=TStringList.Create;
 SL.Text:='_Announce: '+parser._Announce;
 SL.Add('torrentName: '+parser.name);
 SL.Add('torrentComment: '+parser.Comment);
 SL.Add('torrentHashValue: '+parser.HashValue);
 SL.Add('torrentSize: '+IntToStr(parser.Size));    
 SL.SaveToFile('e:\Downloads\Test\Test.txt');
 SL.Free;}
 end;     
 
 parser.id:=id;
 parser.Progressive:=progressive;
 torrentName:=parser.name;

 TorrentName:=StripIllegalFileChars(TorrentName);
 if length(TorrentName)>200 then delete(TorrentName,200,length(TorrentName));

   if length(torrentName)=0 then begin
     tmpPath:=widestrtoutf8str(path);
     for i:=length(tmpPath) downto 1 do if tmpPath[i]='\' then break;
     if i>1 then delete(TmpPath,1,i);
     torrentName:=tmpPath;
     for i:=length(torrentName) downto 1 do
      if torrentName[i]='.' then begin  // remove .torrent ext
       delete(TorrentName,i,length(TorrentName));
       break;
      end;
   end;

   
 {Torrent name already in download?}
   if direxistsW(vars_global.my_torrentFolder+'\'+utf8strtowidestr(torrentName)) then begin
     if FileExists(vars_global.data_Path+'\Data\TempDl\PBTHash_'+bytestr_to_hexstr(parser.hashValue)+'.dat') then begin
       parser.free;
       FreeHandleStream(Stream);
       exit;
     end;

   //torrentName:=torrentName+inttohex(random($ff),2)+inttohex(random($ff),2);
   end;
   //while direxistsW(vars_global.my_torrentFolder+'\'+utf8strtowidestr(torrentName)) do
   // torrentName:=copy(torrentName,1,length(torrentName)-4)+inttohex(random($ff),2)+inttohex(random($ff),2);
  //////////////////////////////////////////

 tnt_createdirectoryW(pwidechar(vars_global.my_torrentFolder),nil);
 if parser.Files.count>1 then tnt_createdirectoryW(pwidechar(vars_global.my_torrentFolder+'\'+utf8strtowidestr(torrentName)),nil);

 BitTorrentTransfer:=tBittorrentTransfer.create;
 BitTorrentTransfer.fseeding:=True;
 BitTorrentTransfer.init(widestrtoutf8str(vars_global.my_torrentFolder)+'\'+(torrentName),
                                          Parser);

//parseMetaTorrent(parser);
parser.free;
FreeHandleStream(Stream);


 if ((BitTorrentTransfer.ferrorCode>0) and
     (BitTorrentTransfer.ferrorCode<BT_DBERROR_FILES_LOCKED)) then begin
     BitTorrentTransfer.free;
     exit;
 end;



buffer[0]:=0;

//synchronize(AddVisualTransferReference);

// let thread_bittorrent know when file is ready for writing
for i:=0 to bittorrentTransfer.ffiles.count-1 do begin
 ffile:=bittorrentTransfer.ffiles[i];

 FreeHandleStream(ffile.fstream);
 while true do begin
 ffile.fstream:=MyFileOpen(utf8strtowidestr(ffile.ffilename),ARES_WRITE_EXISTING);
 if ffile.fstream<>nil then break else sleep(10);
 end;
{
 if ffile.fstream.size>0 then begin
  helper_diskio.MyFileSeek(ffile.fstream,ffile.fsize-1,ord(soFromBeginning));
    while (true) do begin
     if helper_diskio.MyFileSeek(ffile.fstream,0,ord(soCurrent))<>ffile.fsize-1 then begin
      helper_diskio.MyFileSeek(ffile.fstream,ffile.fsize-1,ord(soFromBeginning));
      sleep(50);
      continue;
     end else break;
    end;

    ffile.fstream.Write(buffer,1);
  end; }


 end;


//end;

//bittorrentTransfer.fstate:=dlProcessing;



EnterCriticalSection(ServiceSection);
try
{synchronize}(start_thread);
finally
LeaveCriticalSection(ServiceSection);
end;

end;


procedure tBittorrentTransferCreator.start_thread;//sync
begin

if vars_global.BitTorrentTempList=nil then vars_global.BitTorrentTempList:=tmylist.create;
if vars_global.bittorrent_Accepted_sockets=nil then vars_global.bittorrent_Accepted_sockets:=tmylist.create;

  if vars_global.thread_bittorrent=nil then begin
    vars_global.thread_bittorrent:=tthread_bitTorrent.create(true);
    vars_global.thread_bittorrent.BittorrentTransfers:=tmylist.create;
    vars_global.thread_bittorrent.TrackersThreadList:=TList.create;
    vars_global.thread_bittorrent.TransfersThreadList:=TList.create;
 //    vars_global.thread_bittorrent.BittorrentTransfers.add(bittorrentTransfer);
    vars_global.thread_bittorrent.resume;
  end;
  vars_global.BitTorrentTempList.add(bittorrentTransfer);

//if ares_frmmain.tabs_pageview.activePage<>IDTAB_TRANSFER then ares_frmmain.tabs_pageview.activePage:=IDTAB_TRANSFER;
end;

procedure TBitTorrentSeedingCreator.start_thread;//sync
begin

if vars_global.BitTorrentTempList=nil then vars_global.BitTorrentTempList:=tmylist.create;
if vars_global.bittorrent_Accepted_sockets=nil then vars_global.bittorrent_Accepted_sockets:=tmylist.create;

  if vars_global.thread_bittorrent=nil then begin
    vars_global.thread_bittorrent:=tthread_bitTorrent.create(true);
    vars_global.thread_bittorrent.BittorrentTransfers:=tmylist.create;
    vars_global.thread_bittorrent.TrackersThreadList:=TList.create;
    vars_global.thread_bittorrent.TransfersThreadList:=TList.create;
 //    vars_global.thread_bittorrent.BittorrentTransfers.add(bittorrentTransfer);
    vars_global.thread_bittorrent.resume;
  end;
  vars_global.BitTorrentTempList.add(bittorrentTransfer);

//if ares_frmmain.tabs_pageview.activePage<>IDTAB_TRANSFER then ares_frmmain.tabs_pageview.activePage:=IDTAB_TRANSFER;
end;
{
procedure tBittorrentTransferCreator.AddVisualTransferReference;
var
 dataNode:ares_types.precord_data_node;
 node:PCMtVNode;
 data:precord_displayed_bittorrentTransfer;
 afile:TBitTorrentFile;
 tracker:tbittorrentTracker;
begin

     if bittorrentTransfer.UploadTreeview then begin
       node:=ares_frmmain.treeview_upload.AddChild(nil);
       dataNode:=ares_frmmain.treeview_upload.getdata(Node);
     end else begin
       node:=ares_frmmain.treeview_download.AddChild(nil);
       dataNode:=ares_frmmain.treeview_download.getdata(Node);
      end;
      dataNode^.m_type:=dnt_bittorrentMain;

      data:=AllocMem(sizeof(record_displayed_bittorrentTransfer));
      dataNode^.data:=Data;

     bittorrentTransfer.visualNode:=node;
     bittorrentTransfer.visualData:=data;
     bittorrentTransfer.visualData^.handle_obj:=longint(bittorrentTransfer);
     bittorrentTransfer.visualData^.FileName:=widestrtoutf8str(helper_urls.extract_fnameW(utf8strtowidestr(bittorrentTransfer.fname)));
     bittorrentTransfer.visualData^.Size:=bittorrentTransfer.fsize;
     bittorrentTransfer.visualData^.downloaded:=bittorrentTransfer.fdownloaded;
     bittorrentTransfer.visualData^.uploaded:=bittorrentTransfer.fuploaded;
     bittorrentTransfer.visualData^.hash_sha1:=bittorrentTransfer.fhashvalue;
     bittorrentTransfer.visualData^.crcsha1:=crcstring(bittorrentTransfer.fhashvalue);
     bittorrentTransfer.visualData^.SpeedDl:=0;
     bittorrentTransfer.visualData^.SpeedUl:=0;
     bittorrentTransfer.visualData^.want_cancelled:=false;
     bittorrentTransfer.visualData^.want_paused:=false;
     bittorrentTransfer.visualData^.want_changeView:=false;
     bittorrentTransfer.visualData^.want_cleared:=false;
     bittorrentTransfer.visualData^.uploaded:=bittorrentTransfer.fuploaded;
     bittorrentTransfer.visualData^.downloaded:=bittorrentTransfer.fdownloaded;
     bittorrentTransfer.visualData^.num_Sources:=0;
     bittorrentTransfer.visualData^.ercode:=0;
     bittorrentTransfer.visualData^.state:=bittorrentTransfer.fstate;
     if bittorrentTransfer.trackers.count>0 then begin
      tracker:=bittorrentTransfer.trackers[bittorrentTransfer.trackerIndex];
      bittorrentTransfer.visualData^.trackerStr:=tracker.URL;
     end else bittorrentTransfer.visualData^.trackerStr:='';
     bittorrentTransfer.visualData^.Fpiecesize:=bittorrentTransfer.fpieceLength;
     bittorrentTransfer.visualData^.NumLeechers:=0;
     bittorrentTransfer.visualData^.NumSeeders:=0;
     if bittorrentTransfer.ffiles.count=1 then begin
       afile:=bittorrentTransfer.ffiles[0];
       bittorrentTransfer.visualData^.path:=afile.ffilename;
     end else bittorrentTransfer.visualData^.path:=bittorrentTransfer.fname;
     bittorrentTransfer.visualData^.NumConnectedSeeders:=bittorrentTransfer.NumConnectedSeeders;
     bittorrentTransfer.visualData^.NumConnectedLeechers:=bittorrentTransfer.NumConnectedLeechers;
    SetLength(bittorrentTransfer.visualData^.bitfield,length(bittorrentTransfer.FPieces));

   btcore.CloneBitField(bittorrentTransfer);
end;
}

procedure StartSeeding(torrentfilename:widestring;{filename:widestring;}idtorrent:widestring);
var
 hash_sha1,hash_of_phash:string;
 pfilez:precord_file_library;
 fsize:int64;
 point_of_insertion:cardinal;
 crcsha1:word;
 theName:widestring;
 StrTheName:string;
 StrTorrentfilename:string;
begin
if not FileExists(torrentfilename) then
begin
//ShowMessage('FileExists: '+torrentfilename);
exit;
end;

with TBitTorrentSeedingCreator.Create(true) do begin
 path:=torrentfilename;
 id:=idtorrent;
 resume;
end;

try
 StrTorrentfilename:=widestrtoutf8str(torrentfilename);
 StrTheName:=extractfilename(StrTorrentfilename);
 thename:=utf8strtowidestr(StrTheName);
 //thename:=extractfilename({widestrtoutf8str}(torrentfilename));

 if FileExists(myshared_folder+{utf8strtowidestr}(thename)) then exit;
 if copyFile({pwidechar}pchar(torrentfilename),{pwidechar}pchar(myshared_folder+{utf8strtowidestr}(thename)),true) then
 //if FileExists(TorrentFolder+utf8strtowidestr(thename)) then exit;
 //if copyFile(pchar(filename),pchar(TorrentFolder+utf8strtowidestr(thename)),true) then
 begin
   //Form1.Memo2.Lines.Add('Копирование файла из '+filename+' в '+myshared_folder+thename+' успешно завершено.');
 end else
 begin
   //Form1.Memo2.Lines.Add('Копирование файла из '+filename+' в '+myshared_folder+thename+' завершилось неудачей.');
 end;

 fsize:=getHugeFileSize(torrentfilename);
 torrentfilename:=myshared_folder+{utf8strtowidestr}(thename);
 //filename:=TorrentFolder+utf8strtowidestr(thename);


 hash_compute(torrentfilename,fsize,hash_sha1,hash_of_phash,point_of_insertion);
 if length(hash_sha1)<>20 then exit;
 crcsha1:=crcstring(hash_sha1);


 pfilez:=AllocMem(sizeof(record_file_library));
  pfilez^.hash_of_phash:=hash_of_phash;
  pfilez^.hash_sha1:=hash_sha1;
  pfilez^.crcsha1:=crcsha1;
  pfilez^.path:=widestrtoutf8str(torrentfilename);
  pfilez^.ext:='.torrent';
  pfilez^.amime:=ARES_MIME_OTHER;
  pfilez^.corrupt:=false;

  pfilez^.title:=trim({widestrtoutf8str}(extract_fnameW(torrentfilename)));
  delete(pfilez^.title,length(pfilez^.title)-7,8);
  pfilez^.artist:='';
  pfilez^.album:='';
  pfilez^.category:='';
  pfilez^.year:='';
  pfilez^.language:='';
  pfilez^.comment:='';
  pfilez^.url:='';
  pfilez^.keywords_genre:='';
  pfilez^.fsize:=fsize;
  pfilez^.param1:=0;
  pfilez^.param2:=0;
  pfilez^.param3:=0;
  pfilez^.filedate:=now;
  pfilez^.vidinfo:='';
  pfilez^.mediatype:=mediatype_to_str(ARES_MIME_OTHER);
  pfilez^.shared:=true;
  pfilez^.write_to_disk:=true;
  pfilez^.phash_index:=point_of_insertion;//2956+

  dhtkeywords.DHT_addFileOntheFly(pfilez);
  vars_global.lista_shared.add(pfilez);
  inc(vars_global.my_shared_count);
  helper_share_misc.addfile_tofresh_downloads(pfilez);
except
end;
end;

procedure loadTorrent(filename:widestring;idtorrent:widestring;pdl:boolean);
var
 theName,hash_sha1,hash_of_phash:string;
 pfilez:precord_file_library;
 fsize:int64;
 point_of_insertion:cardinal;
 crcsha1:word;
begin

if not FileExists(filename) then exit;
if GetHugeFileSize(filename)<20 then exit;

with TBitTorrentTransferCreator.Create(true) do begin
 path:=filename;
 id:=idtorrent;
 progressive:=pdl;
 resume;
end;

try
 thename:=extractfilename({widestrtoutf8str}(filename));

 if FileExists(myshared_folder+{utf8strtowidestr}(thename)) then exit;
 if copyFile({pwidechar}pchar(filename),{pwidechar}pchar(myshared_folder+{utf8strtowidestr}(thename)),true) then
 //if FileExists(TorrentFolder+utf8strtowidestr(thename)) then exit;
 //if copyFile(pchar(filename),pchar(TorrentFolder+utf8strtowidestr(thename)),true) then
 begin
   //Form1.Memo2.Lines.Add('Копирование файла из '+filename+' в '+myshared_folder+thename+' успешно завершено.');
 end else
 begin
   //Form1.Memo2.Lines.Add('Копирование файла из '+filename+' в '+myshared_folder+thename+' завершилось неудачей.');
 end;

 fsize:=getHugeFileSize(filename);
 filename:=myshared_folder+{utf8strtowidestr}(thename);
 //filename:=TorrentFolder+utf8strtowidestr(thename);


 hash_compute(filename,fsize,hash_sha1,hash_of_phash,point_of_insertion);
 if length(hash_sha1)<>20 then exit;
 crcsha1:=crcstring(hash_sha1);


 pfilez:=AllocMem(sizeof(record_file_library));
  pfilez^.hash_of_phash:=hash_of_phash;
  pfilez^.hash_sha1:=hash_sha1;
  pfilez^.crcsha1:=crcsha1;
  pfilez^.path:=widestrtoutf8str(filename);
  pfilez^.ext:='.torrent';
  pfilez^.amime:=ARES_MIME_OTHER;
  pfilez^.corrupt:=false;

  pfilez^.title:=trim({widestrtoutf8str}(extract_fnameW(filename)));
  delete(pfilez^.title,length(pfilez^.title)-7,8);
  pfilez^.artist:='';
  pfilez^.album:='';
  pfilez^.category:='';
  pfilez^.year:='';
  pfilez^.language:='';
  pfilez^.comment:='';
  pfilez^.url:='';
  pfilez^.keywords_genre:='';
  pfilez^.fsize:=fsize;
  pfilez^.param1:=0;
  pfilez^.param2:=0;
  pfilez^.param3:=0;
  pfilez^.filedate:=now;
  pfilez^.vidinfo:='';
  pfilez^.mediatype:=mediatype_to_str(ARES_MIME_OTHER);
  pfilez^.shared:=true;
  pfilez^.write_to_disk:=true;
  pfilez^.phash_index:=point_of_insertion;//2956+

  dhtkeywords.DHT_addFileOntheFly(pfilez);
  vars_global.lista_shared.add(pfilez);
  inc(vars_global.my_shared_count);
  helper_share_misc.addfile_tofresh_downloads(pfilez);
except
end;
end;

procedure hash_compute(const FileName: widestring; fsize:int64; var sha1:string; var hash_of_phash:string; var point_of_insertion:cardinal);
var
  stream:thandlestream;
  NumBytes:integer;
  buffer:array[1..1024] of char;
  csha1:tsha1;

  i:integer;
  last_sync:cardinal;
  divisore:integer;
//  attesa:word;

  phash_value:string;
  buffer_phash:array[0..19] of char;
  phash_sha1:tsha1;
  stream_phash:thandlestream;
  phash_chunk_size:cardinal;
  bytes_processed_phash:cardinal;
begin


    stream:=MyFileOpen(FileName,ARES_READONLY_BUT_SEQUENTIAL);
    if stream=nil then exit;

    if stream.size<fsize then begin
      FreeHandleStream(Stream);
    exit;
    end;



   i:=0;
   divisore:=25;
    last_sync:=gettickcount;

   cSHA1:=TSHA1.Create;

   bytes_processed_phash:=0;

    if fsize>ICH_MIN_FILESIZE then begin
     phash_chunk_size:=ICH_calc_chunk_size(fsize);
     phash_sha1:=tsha1.create;

      stream_phash:=MyFileOpen(data_path+'\Data\TempPHash.dat',ARES_CREATE_ALWAYSAND_WRITETHROUGH);
      if stream_phash=nil then begin
        FreeHandleStream(stream);
       exit;
      end;
    end else begin
     phash_chunk_size:=0;
     stream_phash:=nil;
     phash_sha1:=nil;
    end;


  repeat


        NumBytes :=stream.read(Buffer, SizeOf(Buffer));

        cSHA1.Transform(Buffer, NumBytes);

        if phash_sha1<>nil then begin

         phash_sha1.Transform(buffer, NumBytes);

         inc(bytes_processed_phash,NumBytes);
         if bytes_processed_phash=phash_chunk_size then begin
              phash_sha1.Complete;
                phash_value:=phash_sha1.HashValue;
                move(phash_value[1],buffer_phash,20*SizeOf(Char));
                stream_phash.write(buffer_phash,20*SizeOf(Char));
              phash_sha1.free;
              phash_sha1:=Tsha1.create;
              bytes_processed_phash:=0;
         end;
        end;


      until (numbytes<>length(buffer)*SizeOf(Char));

   FreeHandleStream(Stream);
   
  cSHA1.Complete;
   sha1:=cSHA1.HashValue;
  cSHA1.Free;

  if phash_sha1<>nil then begin
   if bytes_processed_phash>0 then begin
     phash_sha1.Complete;
      phash_value:=phash_sha1.HashValue;
      move(phash_value[1],buffer_phash,20*SizeOf(Char));
      stream_phash.write(buffer_phash,20*SizeOf(Char));
                //FlushFileBuffers(stream.handle);
   end;

    phash_sha1.free;
    FreeHandleStream(stream_phash);

   hash_of_phash:=ICH_get_hash_of_phash(sha1);
   point_of_insertion:=ICH_copy_temp_to_tmp_db(sha1);
  end;

end;

end.