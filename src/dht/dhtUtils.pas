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
misc fuctions
}

unit dhtUtils;

interface

uses
 classes;


 procedure log_memo(txt:string);




implementation

uses
 sysutils,windows;


procedure log_memo(txt:string);
//var
//str:string;
begin
outputdebugstring(pchar(formatdatetime('hh:nn:ss',now)+' '+txt));

//str:=formatdatetime('hh:nn:ss',now)+' '+txt;
//form1.Memo1.lines.add(str);
//writeln(log_file,str);
end;




end.