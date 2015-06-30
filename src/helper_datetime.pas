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
related to datetime, used by many units to visually display formatted time eg: 00:00:00
}

unit helper_datetime;

interface

uses
 sysutils,windows;

const
 UnixStartDate : tdatetime = 25569.0;

 TENTHOFSEC=100;
 SECOND=1000;
 MINUTE=60000;
 HOUR=3600000;
 DAY=86400000;
 SECONDSPERDAY=86400;

function UnixToDelphiDateTime(USec:longint):TDateTime;
function DelphiDateTimeToUnix(ConvDate:TdateTime):longint;
function format_time(secs:integer):string;
function DelphiDateTimeSince1900(ConvDate:TdateTime):longint;
function time_now:cardinal;
function HR2S(hours:single):cardinal;
function SEC(seconds:integer):cardinal;
function MIN2S(minutes:single):cardinal;

function DateTimeToUnixTime(const DateTime: TDateTime): cardinal;
function UnixTimeToDateTime(const UnixTime: cardinal): TDateTime;

implementation

function DateTimeToUnixTime(const DateTime:TDateTime): cardinal;
var
 FileTime:TFileTime;
 SystemTime:TSystemTime;
 I:Int64;
begin
 // first convert datetime to Win32 file time
 DateTimeToSystemTime(DateTime, SystemTime);
 SystemTimeToFileTime(SystemTime, FileTime);

 // simple maths to go from Win32 time to Unix time
 I:=Int64(FileTime.dwHighDateTime) shl 32 + FileTime.dwLowDateTime;
 Result:=(I - 116444736000000000) div Int64(10000000);
end;

function UnixTimeToDateTime(const UnixTime: cardinal): TDateTime;
var
  FileTime:TFileTime;
  SystemTime:TSystemTime;
  I:Int64;
begin
  // first convert unix time to a Win32 file time
  I:=Int64(UnixTime) * Int64(10000000) + 116444736000000000;
  FileTime.dwLowDateTime:=DWORD(I);
  FileTime.dwHighDateTime:=I shr 32;

  // now convert to system time
  FileTimeToSystemTime(FileTime,SystemTime);

  // and finally convert the system time to TDateTime
  Result:=SystemTimeToDateTime(SystemTime);
end;

function format_time(secs:integer):string;
var
ore,minuti,secondi,variabile:integer;
begin
if secs>0 then begin

if secs<60 then begin
 ore:=0;
 minuti:=0;
 secondi:=secs;
end
 else if secs<3600 then begin
  ore:=0;
  minuti:=(secs div 60);
  secondi:=(secs-((secs div 60)*60));
 end
  else begin
   ore:=(secs div 3600);
   variabile:=(secs-((secs div 3600)*3600)); //minuti avanzati
   minuti:=variabile div 60;
   secondi:=variabile-((minuti )* 60);
  end;

 if ore=0 then result:='' else result:=inttostr(ore)+':';

 if ((minuti=0) and (ore=0)) then result:='0:' else begin
   if minuti<10 then begin
     if ore=0 then result:=inttostr(minuti)+':'
      else result:=result+'0'+inttostr(minuti)+':';
   end else result:=result+inttostr(minuti)+':';
 end;

 if secondi<10 then result:=result+'0'+inttostr(secondi)
  else result:=result+inttostr(secondi);

end else result:='0:00';  // fake tempo se non ho niente nella var

end;

function DelphiDateTimeToUnix(ConvDate:TdateTime):longint;
   // Converts Delphi TDateTime to Unix seconds,
   //  ConvDate = the Date and Time that you want to convert
   //  example:   UnixSeconds:=DelphiDateTimeToUnix(Now);
begin
  Result:=round((ConvDate-UnixStartDate)*SECONDSPERDAY);
end;

function UnixToDelphiDateTime(USec:longint):TDateTime;
{Converts Unix seconds to Delphi TDateTime,
   USec = the Unix Date Time that you want to convert
   example:  DelphiTimeDate:=UnixToDelphiTimeDate(693596);}
begin
  Result:=(Usec/SECONDSPERDAY)+UnixStartDate;
end;

function time_now:cardinal;
begin
 result:=DelphiDateTimeSince1900(now);
end;

function HR2S(hours:single):cardinal;
begin
result:=MIN2S(hours*60);
end;

function SEC(seconds:integer):cardinal;
begin
result:=seconds;
end;

function MIN2S(minutes:single):cardinal;
begin
result:=round(minutes  * 60);
end;

function DelphiDateTimeSince1900(ConvDate:TdateTime):longint;
   // Converts Delphi TDateTime to Unix seconds,
   //  ConvDate = the Date and Time that you want to convert
   //  example:   UnixSeconds:=DelphiDateTimeToUnix(Now);
begin
  Result:=round((ConvDate-1.5)*86400);
end;

end.
