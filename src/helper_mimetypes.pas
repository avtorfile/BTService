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
related to mime types handling
}

unit helper_mimetypes;

interface

uses
sysutils,helper_unicode,vars_localiz,const_ares;

const
SHARED_AUDIO_EXT='.mp3 .vqf .wav .voc .mod .ra .ram .mid .au .ogg .mp2 .mpc .ape .flac .shn .wma .mmf .m4p .m4a';
SHARED_VIDEO_EXT='.3gp .avi .asf .divx .fli .flc .flv .lsf .m1v .mkv .mov .mpa .mpe .mpeg .mpg .ogm .qt .rm .ts .viv .vivo .wm .wmv';
SHARED_IMAGE_EXT='.bmp .gif .jpeg .jpg .png .psd .psp .tga .tif .tiff';
SHARED_DOCUMENT_EXT='.book .doc .hlp .lit .pdf .pps .ppt .ps .rtf .txt .wri';
SHARED_OTHER_EXT='.ace .ashdisc .arescol .b5i .bin .bwi .c2d .cab .cdi .cif .cue .cif .daa .dxf .dwg .fla .fcd .gz .hqx .img .iso '+
                 '.lcd .md5 .mdf .mds .msi .ncd .nes .nrg .p01 .pdi .pxi .rar .ratdvd .rip .rmp .rv .sit .swf .tar .torrent .vcd .zip .wsz';
SHARED_SOFTWARE_EXT='.bat .com .exe .msi .pif  .scr .vbs';
STR_EXE_EXTENS='.asf .dll .exe .ocx .gz .doc .sit .tar .jpg .js .lnk .msi .wmv  .reg .wma .wm .vbs .com .rar .zip'; //dangerous when in generic search

function mediatype_to_str(tipo:byte):string;
function mediatype_to_widestr(tipo:byte):widestring;
function DocumentToContentType(FileName : wideString) : String;
function extstr_to_mediatype(estensione:String):byte;
function clienttype_to_shareservertype(tipo:byte):byte;
function clienttype_to_searchservertype(tipo:byte):byte;
function amime_to_imgindexsmall(amime:byte):byte;
function serversharetype_to_clienttype(tipo:byte):byte;   //tipo 8 è passato per intendere solo other


implementation

function clienttype_to_searchservertype(tipo:byte):byte;   //tipo 8 è passato per intendere solo other
begin
case tipo of
 ARES_MIME_MP3:result:=1;
 ARES_MIME_AUDIOOTHER1:result:=1;
 ARES_MIME_SOFTWARE:result:=2; //soft
 ARES_MIME_AUDIOOTHER2:result:=1;
 ARES_MIME_VIDEO:result:=3; //video
 ARES_MIME_DOCUMENT:result:=4; //doc
 ARES_MIME_IMAGE:result:=5;    //image
 ARES_MIMESRC_OTHER:result:=ARES_MIME_OTHER else    //other clientSRC 8->0 serverType
 result:=ARES_MIMESRC_ALL255;
end;
end;

function serversharetype_to_clienttype(tipo:byte):byte;   //tipo 8 è passato per intendere solo other
begin
 case tipo of
  1:result:=ARES_MIME_MP3;
  2:result:=ARES_MIME_SOFTWARE; //soft
  3:result:=ARES_MIME_VIDEO; //video
  4:result:=ARES_MIME_DOCUMENT; //doc
  5:result:=ARES_MIME_IMAGE;    //image
   else result:=ARES_MIME_OTHER;
 end;
end;

function clienttype_to_shareservertype(tipo:byte):byte;
begin
case tipo of
 ARES_MIME_MP3:result:=1;
 ARES_MIME_AUDIOOTHER1:result:=1;
 ARES_MIME_SOFTWARE:result:=2; //soft
 ARES_MIME_AUDIOOTHER2:result:=1;
 ARES_MIME_VIDEO:result:=3; //video
 ARES_MIME_DOCUMENT:result:=4; //doc
 ARES_MIME_IMAGE:result:=5 else    //image
  result:=ARES_MIME_OTHER; // 0 servertype
 end;
end;

function amime_to_imgindexsmall(amime:byte):byte;
begin
 case amime of
  ARES_MIME_MP3,ARES_MIME_AUDIOOTHER1,ARES_MIME_AUDIOOTHER2:result:=3;
  ARES_MIME_VIDEO:result:=4;
  ARES_MIME_DOCUMENT:result:=7;
  ARES_MIME_SOFTWARE:result:=6;
  ARES_MIME_IMAGE:result:=5
   else result:=2;
 end;
end;

function extstr_to_mediatype(estensione:String):byte;
begin
  if pos(estensione,SHARED_AUDIO_EXT)>0 then result:=ARES_MIME_MP3 else  // video
  if pos(estensione,SHARED_VIDEO_EXT)>0 then result:=ARES_MIME_VIDEO else
  if pos(estensione,SHARED_IMAGE_EXT)>0 then result:=ARES_MIME_IMAGE else
  if pos(estensione,SHARED_DOCUMENT_EXT)>0 then result:=ARES_MIME_DOCUMENT else
  if pos(estensione,SHARED_SOFTWARE_EXT)>0 then result:=ARES_MIME_SOFTWARE else result:=ARES_MIME_OTHER;
end;

function DocumentToContentType(FileName : wideString) : String;
var
    Ext : String;
begin
    Ext := LowerCase(ExtractFileExt(widestrtoutf8str(FileName)));
    if (ext='.aif') or (ext='.aiff') or (ext='.aifc') then result:='audio/x-aiff' else
    if ((Ext = '.asf') or (ext='.asx')) then Result := 'video/x-ms-asf' else
    if (ext='.au') or (ext='.snd') then result:='audio/basic' else
    if ext='.avi' then result:='video/x-msvideo' else
    if ext='.book' then result:='application/book' else
    if ext='.bmp' then result:='image/x-MS-bmp' else
    if Ext = '.doc' then Result := 'application/msword' else
    if (ext='.exe') or (ext='.bin') then result:='application/octet-stream' else
    if Ext = '.gif' then Result := 'image/gif' else
    if ext='.gz' then result:='application/x-gzip' else
    if Ext = '.hlp' then Result := 'application/winhlp' else
    if (Ext = '.htm') or (Ext = '.html') or (ext ='.mdl') then Result := 'text/html' else
    if (ext='.jpg') or (ext='.jpeg') then result:='image/jpeg' else
    if ((ext='.mid') or (ext='.midi')) then result:='audio/midi' else
    if ((ext='.mov') or (ext='.qt')) then result:='video/quicktime' else
    if ext='.mp3' then result:='audio/x-mpeg' else
    if (ext='.mpeg') or (ext='.mpg') or (result='.mpe') then result:='video/mpeg' else
    if ext='.pdf' then result:='application/pdf' else
    if (ext='.qt') or (ext='.mov') then result:='video/quicktime' else
    if ext='.rm' then result:='audio/x-pn-realaudio-plugin' else
    if ext='.rtf' then result:='application/rtf' else
    if ext='.sit' then result:='application/x-stuffit' else
    if ext='.swf' then result:='application/x-shockwave-flash' else
    if ext='.tar' then result:='application/x-tar' else
    if (ext='.tiff') or (ext='.tif') then result:='image/tiff' else
    if Ext = '.txt' then Result := 'text/plain' else
    if ext='.zip' then result:='application/x-zip-compressed' else
    if ext='.wav' then result:='audio/x-wav' else

        Result := 'application/octet-stream';
end;

function mediatype_to_str(tipo:byte):string;
 begin
    case tipo of
     ARES_MIME_OTHER:result:=GetLangStringA(STR_OTHERMIME);
     ARES_MIME_MP3,ARES_MIME_AUDIOOTHER1,ARES_MIME_AUDIOOTHER2:result:=GetLangStringA(STR_AUDIOMIME);
     ARES_MIME_SOFTWARE:result:=GetLangStringA(STR_SOFTWAREMIME);
     ARES_MIME_VIDEO:result:=GetLangStringA(STR_VIDEOMIME);
     ARES_MIME_DOCUMENT:result:=GetLangStringA(STR_DOCUMENTMIME);
     ARES_MIME_IMAGE:result:=GetLangStringA(STR_IMAGEMIME) else
     result:=GetLangStringA(STR_OTHERMIME);
    end;
  end;

 function mediatype_to_widestr(tipo:byte):widestring;
 begin
   case tipo of
     ARES_MIME_OTHER:result:=GetLangStringW(STR_OTHERMIME);
     ARES_MIME_MP3,ARES_MIME_AUDIOOTHER1,ARES_MIME_AUDIOOTHER2:result:=GetLangStringW(STR_AUDIOMIME);
     ARES_MIME_SOFTWARE:result:=GetLangStringW(STR_SOFTWAREMIME);
     ARES_MIME_VIDEO:result:=GetLangStringW(STR_VIDEOMIME);
     ARES_MIME_DOCUMENT:result:=GetLangStringW(STR_DOCUMENTMIME);
     ARES_MIME_IMAGE:result:=GetLangStringW(STR_IMAGEMIME) else
      result:=GetLangStringW(STR_OTHERMIME);
     end;
  end;

end.
