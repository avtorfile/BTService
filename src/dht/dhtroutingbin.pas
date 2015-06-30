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
DHT routing bin, each routingzone may have up to 10 contacts in its routing bin
}

unit dhtroutingbin;

interface

uses
 classes,classes2,int128,dhtcontact,sysutils,windows;

type
TRoutingBin=class(TObject)
 m_entries:Tmylist;
 m_dontDeletecontacts:boolean;
 constructor create;
 destructor destroy; override;
 function getContact(id:pCU_INT128):TContact;
 function add(contact:TContact):boolean;
 function remove(contact:TContact):boolean;
 procedure getEntries(list:tmylist; emptyFirst:boolean = false);
 function getOldest:TContact;
 function getClosestTo(maxType:cardinal; target:pCU_INT128; maxRequired:cardinal;
  ContactMap:tmylist; emptyFirst:boolean=false; inUse:boolean=false):cardinal;
 procedure setAlive(ip:cardinal; port:word; setroundtrip:boolean=false);
 procedure dumpContents;
 procedure moveback(c:TContact);
 function FindHost(ip:cardinal):TContact;
end;

implementation

uses
 dhtconsts,helpeR_ipfunc,DHTutils;

function TRoutingBin.FindHost(ip:cardinal):TContact;
var
i:integer;
c:TContact;
begin
result:=nil;
	if m_entries.count=0 then exit;

	for i:=0 to m_entries.count-1 do begin
   c:=m_entries[i];
		if ip=c.m_ip then begin
     result:=c;
     exit;
    end;
  end;
end;

procedure TRoutingBin.dumpContents;
var
line,hex,ipStr,distance:string;
c:TContact;
i:integer;
begin
	for i:=0 to m_entries.count-1 do begin
    c:=m_entries[i];
		hex:=CU_INT128_tohexstr(@c.m_clientID);
		ipStr:=ipint_to_dotstring(c.m_ip);
    distance:=CU_INT128_tohexstr(@c.m_distance);
		//CU_Int128_toBinaryString(@c.m_distance,distance);
    line:=chr(VK_TAB)+hex+chr(VK_TAB)+ipStr+' ('+inttostr(c.m_udpPort)+')'+chr(VK_TAB)+'Distance: '+distance;
    log_memo(line);
  end;
end;

procedure TRoutingBin.getEntries(list:tmylist; emptyFirst:boolean = false);
var
i:integer;
con:TContact;
begin

	if emptyFirst then list.clear;

	for i:=0 to m_entries.count-1 do begin
   con:=m_entries[i];
   list.add(con);
  end;

end;

function TRoutingBin.getContact(id:pCU_INT128):TContact;
var
con:TContact;
i:integer;
begin
	result:=nil;

	for i:=0 to m_entries.count-1 do begin
     con:=m_entries[i];
     if con.m_clientID[0]<>id[0] then continue;
       if con.m_clientID[1]<>id[1] then continue;
        if con.m_clientID[2]<>id[2] then continue;
         if con.m_clientID[3]<>id[3] then continue;

			result:=con;
			exit;

	end;

end;

procedure TRoutingBin.setAlive(ip:cardinal; port:word; setroundtrip:boolean=false);
var
c:TContact;
i:integer;
begin
	if m_entries.count=0 then exit;

	for i:=0 to m_entries.count-1 do begin
		c:=m_entries[i];
		if ip=c.m_ip then
     if port=c.m_udpport then begin

     if setroundtrip then begin
        if c.m_outHelloTime<>0 then begin
         c.m_rtt:=gettickcount-c.m_outHelloTime;
        
       end;
     end;

			c.updateType;
			break;
		 end;
 end;

end;

function TRoutingBin.getClosestTo(maxType:cardinal; target:pCU_INT128; maxRequired:cardinal;
 ContactMap:tmylist; emptyFirst:boolean=false; inUse:boolean=false):cardinal;
var
i:integer;
con:TContact;
begin
  result:=0;
	if m_entries.count=0 then exit;

	if emptyFirst then ContactMap.clear;

	//Put results in sort order for target.
	for i:=0 to m_entries.count-1 do begin
   con:=m_entries[i];
		if con.m_type>maxType then continue;

      ContactMap.add(con);
			if inUse then inc(con.m_inUse);

	end;

  sortCloserContacts(ContactMap,target);  //@contact.me

  while (ContactMap.count>maxRequired) do begin
   if inUse then begin
    con:=ContactMap[ContactMap.count-1];
    dec(con.m_inuse);
   end;
   ContactMap.delete(ContactMap.count-1);  // delete extra results
  end;

	result:=ContactMap.count;
end;

function TRoutingBin.remove(contact:TContact):boolean;
var
ind:integer;
begin
result:=false;

ind:=m_entries.indexof(contact);
if ind<>-1 then begin
 m_entries.delete(ind);
 result:=true;
end;

end;

function TRoutingBin.add(contact:TContact):boolean;
var
c:TContact;
begin
result:=false;

	// If this is already in the entries list
	c:=getContact(@Contact.m_clientID);
	if (c<>nil) then begin
		// Move to the end of the list
   moveback(c);
		result:=false;
    exit;
	end;
		// If not full, add to end of list

		if m_entries.count<K10 then begin
			m_entries.add(contact);
			result:=true;
		end else begin
			result:=false;  //bin full
		end;



end;

procedure tRoutingBin.moveback(c:TContact);
var
 ind:integer;
begin
ind:=m_entries.indexof(c);

if ind<>-1 then
 if ind<>m_entries.count-1 then begin
  m_entries.delete(ind);
  m_entries.add(c);
 end;

end;


function TRoutingBin.getOldest:TContact;
begin
	if m_entries.count>0 then result:=m_entries[0]
   else result:=nil;
end;

constructor TRoutingBin.create;
begin
m_dontDeleteContacts:=false;
m_entries:=Tmylist.create;
end;

destructor TRoutingBin.destroy;
var
con:TContact;
begin

		if not m_dontDeleteContacts then
			while (m_entries.count>0) do begin
            con:=m_entries[m_entries.count-1];
                m_entries.delete(m_entries.count-1);
            con.free;
		  end;

		m_entries.free;

inherited;
end;

end.
