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

unit dht_routingbin;

interface

uses
 classes,classes2,dht_int160,sysutils,windows,dht_consts;

type
TMDHTRoutingBin=class(TObject)
 m_entries:Tmylist;
 m_dontDeletecontacts:boolean;
 constructor create;
 destructor destroy; override;
 function getContact(id:pCU_INT160):tmdhtbucket;
 function add(contact:tmdhtbucket):boolean;
 function remove(contact:tmdhtbucket):boolean;
 procedure getEntries(list:tmylist; emptyFirst:boolean = false);
 function getOldest:tmdhtbucket;
 function getClosestTo(maxType:cardinal; target:pCU_INT160; maxRequired:cardinal;
  ContactMap:tmylist; emptyFirst:boolean=false; inUse:boolean=false):cardinal;
 procedure setAlive(ip:cardinal; port:word);
 procedure moveback(c:tmdhtbucket);
 function FindHost(ip:cardinal):tmdhtbucket;
end;

implementation

uses
 thread_bittorrent;

function TMDHTRoutingBin.FindHost(ip:cardinal):tmdhtbucket;
var
i:integer;
c:tmdhtbucket;
begin
result:=nil;
	if m_entries.count=0 then exit;

	for i:=0 to m_entries.count-1 do begin
   c:=m_entries[i];
		if ip=c.ipC then begin
     result:=c;
     exit;
    end;
  end;
end;

procedure TMDHTRoutingBin.getEntries(list:tmylist; emptyFirst:boolean = false);
var
i:integer;
con:tmdhtbucket;
begin

	if emptyFirst then list.clear;

	for i:=0 to m_entries.count-1 do begin
   con:=m_entries[i];
   list.add(con);
  end;

end;

function TMDHTRoutingBin.getContact(id:pCU_INT160):tmdhtbucket;
var
con:tmdhtbucket;
i:integer;
begin
	result:=nil;

	for i:=0 to m_entries.count-1 do begin
     con:=m_entries[i];
     if con.ID[0]<>id[0] then continue;
       if con.ID[1]<>id[1] then continue;
        if con.ID[2]<>id[2] then continue;
         if con.ID[3]<>id[3] then continue;
          if con.ID[4]<>id[4] then continue;

			result:=con;
			exit;

	end;

end;

procedure TMDHTRoutingBin.setAlive(ip:cardinal; port:word);
var
c:tmdhtbucket;
i:integer;
begin
	if m_entries.count=0 then exit;

	for i:=0 to m_entries.count-1 do begin
		c:=m_entries[i];
		if ip=c.ipC then
     if port=c.portW then begin

			c.updateType;
      
			break;
		 end;
 end;

end;

function TMDHTRoutingBin.getClosestTo(maxType:cardinal; target:pCU_INT160; maxRequired:cardinal;
 ContactMap:tmylist; emptyFirst:boolean=false; inUse:boolean=false):cardinal;
var
i:integer;
con:tmdhtbucket;
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

  thread_bittorrent.mdht_sortCloserContacts(ContactMap,target);  //@contact.me

  while (ContactMap.count>maxRequired) do begin
   if inUse then begin
    con:=ContactMap[ContactMap.count-1];
    dec(con.m_inuse);
   end;
   ContactMap.delete(ContactMap.count-1);  // delete extra results
  end;

	result:=ContactMap.count;
end;

function TMDHTRoutingBin.remove(contact:tmdhtbucket):boolean;
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

function TMDHTRoutingBin.add(contact:tmdhtbucket):boolean;
var
c:tmdhtbucket;
begin
result:=false;

	// If this is already in the entries list
	c:=getContact(@Contact.ID);
	if (c<>nil) then begin
		// Move to the end of the list
   moveback(c);
		result:=false;
    exit;
	end;
		// If not full, add to end of list

		if m_entries.count<MDHT_K8 then begin
			m_entries.add(contact);
			result:=true;
      //outputdebugstring(pchar(formatdatetime('hh:nn:ss.zzz',now)+'> Adding bucket:'+CU_INT160_tohexstr(@contact.id,false)));
		end else begin
			result:=false;  //bin full
      
		end;



end;

procedure TMDHTRoutingBin.moveback(c:tmdhtbucket);
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


function TMDHTRoutingBin.getOldest:tmdhtbucket;
begin
	if m_entries.count>0 then result:=m_entries[0]
   else result:=nil;
end;

constructor TMDHTRoutingBin.create;
begin
m_dontDeleteContacts:=false;
m_entries:=Tmylist.create;
end;

destructor TMDHTRoutingBin.destroy;
var
con:tmdhtbucket;
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
