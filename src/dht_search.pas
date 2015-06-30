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
DHT low level search code
}

unit dht_search;

interface

uses
 dht_int160,classes,classes2,math,dht_consts,windows,
 sysutils;



type
TmDHTsearch=class(Tobject)
  m_type:Tmdhtsearchtype;
	m_stoping:boolean;
	m_created,
  m_answers:cardinal; //Used for gui reasons.. May not be needed later..
  m_lastResponse:cardinal;

	m_target:CU_INT160;

	m_possible,
  m_tried,
  m_responded,
  m_best,
  m_delete,
  m_inUse:tmylist;

  constructor create;
  destructor destroy; override;
  
  function StartIDSearch:boolean;
  procedure sendFindID(ip:cardinal; port:word);
  procedure sendGetPEERS(ip:cardinal; port:word);
  function Find_Replying_Contact(IP:Cardinal;Port:word):Tmdhtbucket;
 	procedure processResponse(fromIP:cardinal; fromPort:word; results:tmylist);
	procedure expire;
  procedure CheckExpire;
  function has_contacts_withID(list:tmylist; id:pCU_INT160):boolean;
end;

implementation

uses
 helper_datetime,thread_bittorrent,
 dht_socket,helper_strings;

constructor TmDHTsearch.create;
begin
	m_created:=time_now;
	m_type:=UNDEFINED;
	m_answers:=0;
	m_stoping:=false;
	m_lastResponse:=m_created;

  m_possible:=tmylist.create;
  m_tried:=tmylist.create;
  m_responded:=tmylist.create;
  m_best:=tmylist.create;
  m_delete:=tmylist.create;
  m_inUse:=tmylist.create;
end;

destructor TmDHTsearch.destroy;
var
c:Tmdhtbucket;
begin


while (m_delete.count>0) do begin
   c:=m_delete[m_delete.count-1];
      m_delete.delete(m_delete.count-1);
   c.free;
end;

  m_possible.free;
  m_tried.free;
  m_responded.free;
  m_best.free;
  m_delete.free;
  m_inUse.free;

inherited;
end;

procedure TmDHTSearch.CheckExpire;   //every second
var
 count,donecount:integer;
 bucket:tmdhtbucket;
 distanceFromTarget:cu_int160;
begin

	if m_possible.count=0 then begin
      if m_type<>NODE then begin
        if ((m_created+SEC(10)<time_now)) then begin
	      	expire;
	      	exit;
        end;
      end else begin
       expire;
       exit;
      end;
	end;

  if m_lastResponse+SEC(3)>time_now then exit;

  // if m_type=dht_consts.FINDSOURCE then
  // outputdebugstring(pchar('3 seconds of inactivity go on with possible count:'+inttostr(m_possible.count)));

    thread_bittorrent.mdht_sortCloserContacts(m_possible,@m_target);
    
    donecount:=0;
    count:=4;
  	while ((m_possible.count>0) and (donecount<count)) do begin
	    bucket:=m_possible[0];
              m_possible.delete(0);

      if has_contacts_withid(m_tried,@bucket.ID) then continue;

		   // Move to tried
	    	m_tried.add(bucket);

            if (m_type=dht_consts.FINDSOURCE) and (bucket.ID[0] xor m_target[0] < MDHT_SEARCH_TOLERANCE) then begin
               CU_Int160_FillNXor(@distanceFromTarget,@bucket.id,@m_target);
              // outputdebugstring(pchar('FINDPEER:'+CU_INT160_tohexstr(@bucket.id,true)+' Distance:'+CU_INT160_tohexstr(@distanceFromTarget,true)));
               sendGetPeers(bucket.ipC, bucket.portW);
            end else begin
            // if (m_type=dht_consts.FINDSOURCE) and
             //   (bucket.ID[0] xor m_target[0] >= SEARCH_TOLERANCE) then outputdebugstring(pchar('Search tolerance too big'));
             sendFindID( bucket.ipC, bucket.portW);
            end;


	    	if m_type=NODE then break;
        inc(donecount);
	  end;

end;




function TmDHTSearch.has_contacts_withID(list:tmylist; id:pCU_INT160):boolean;
var
i:integer;
c:tmdhtbucket;
begin

result:=false;

 for i:=0 to list.count-1 do begin
  c:=list[i];

  if CU_INT160_compare(id,@c.id) then begin
   result:=true;
   exit;
  end;

 end;

end;

function TmDHTSearch.Find_Replying_Contact(IP:Cardinal; Port:word):Tmdhtbucket;
var
h:integer;
begin
result:=nil;

for h:=0 to m_tried.count-1 do begin
		result:=m_tried[h];

		if ((result.ipC=IP) and
        (result.portW=Port)) then exit;
end;

result:=nil;
end;




procedure tmDHTsearch.processResponse(fromIP:cardinal; fromPort:word; results:tmylist);
var
 i:integer;
 c,from,worstcontact:tmdhtbucket;
 distanceFromTarget:CU_INT160;
 sendquery:boolean;
begin

	m_lastResponse:=time_now;

	// Remember the contacts to be deleted when finished
  for i:=0 to results.count-1 do begin
   c:=results[i];
   m_delete.add(c);
  end;

	// Not interested in responses for FIND_NODE, will be added to contacts by thread_bittorent
	if m_type=dht_consts.NODE then begin
		inc(m_answers);
		m_possible.clear;
		results.clear;
		exit;
	end;


    from:=Find_Replying_contact(FromIp,FromPort);
    if from=nil then begin
     exit;
    end;
    //CU_INT160_fillNXor(@fromDistance,@from.m_clientid,@m_target);

		// Add to list of people who responded
    m_responded.add(from);

   if m_type=dht_consts.NODE then begin
    CU_Int160_FillNXor(@distanceFromTarget,@from.id,@m_target);
    outputdebugstring(pchar('Response from:'+CU_INT160_tohexstr(@from.id,true)+' Distance:'+CU_INT160_tohexstr(@distanceFromTarget,true)));
    //thread_bittorrent.mdht_sortCloserContacts(results,@target);
   // for i:=0 to results.count-1 do begin
   //  c:=results[i];
    //  CU_Int160_FillNXor(@distanceFromTarget,@c.id,@m_target);
     // outputdebugstring(pchar('Host:'+CU_INT160_tohexstr(@c.id,true)+' Distance:'+CU_INT160_tohexstr(@distanceFromTarget,true)));
   // end;
   end;


		// Loop through their responses
    for i:=0 to results.count-1 do begin
			c:=results[i];

      // Ignore this contact if already know him
      if has_contacts_withid(m_possible,@c.ID) then continue;
      if has_contacts_withid(m_tried,@c.ID) then continue;

      // Add to possible
      m_possible.add(c);

      //CU_INT160_FillNXor(@distance,@c.m_clientID,@m_target);
     // outputdebugstring(pchar('Result ID:'+CU_INT160_tohexstr(@c.id,true)));
      if c.ID[0] xor m_target[0]>from.ID[0] xor m_target[0] then begin
       //outputdebugstring(pchar('ecc 1'));
       continue; // has better hosts then himself?
      end;

        sendquery:=false;
        if m_best.count<MDHT_ALPHA_QUERY then begin  //add it without any comparison
         m_best.add(c);
          thread_bittorrent.mdht_sortCloserContacts(m_best,@m_target);
         sendquery:=true;
        end else begin      // add him only if he's better then the worst one

             thread_bittorrent.mdht_sortCloserContacts(m_best,@m_target);
             worstContact:=m_best[m_best.count-1];

             if c.ID[0] xor m_target[0] < worstContact.ID[0] xor m_target[0] then begin

              m_best.delete(m_best.count-1);  // delete previous worst result
              m_best.add(c);
               thread_bittorrent.mdht_sortCloserContacts(m_best,@m_target);
              sendquery:=true;

             end else begin
             // outputdebugstring(pchar('ecc 2'));
             end;

				end;

        if sendquery then begin
            m_tried.add(c);

            if (m_type=dht_consts.FINDSOURCE) and (c.ID[0] xor m_target[0] < MDHT_SEARCH_TOLERANCE) then begin
              // CU_Int160_FillNXor(@distanceFromTarget,@c.id,@m_target);
              // outputdebugstring(pchar('FINDPEER:'+CU_INT160_tohexstr(@c.id,true)+' Distance:'+CU_INT160_tohexstr(@distanceFromTarget,true)));
              sendGetPeers(c.ipC, c.portW);
            end else begin
             if m_type=dht_consts.NODE then begin
              CU_Int160_FillNXor(@distanceFromTarget,@c.id,@m_target);
              outputdebugstring(pchar('Search on node:'+CU_INT160_tohexstr(@c.id,true)+' Distance:'+CU_INT160_tohexstr(@distanceFromTarget,true)));
             end;
             sendFindID( c.ipC, c.portW);
            end;
            
        end;


      end; //for results loop

				if m_type=NODECOMPLETE then begin
					inc(m_answers);
				end;
     
	results.clear;
end;

function TmDHTsearch.StartIDSearch:boolean;
var
i:integer;
count,donecount:integeR;
strtarget:string;
bucket:tmdhtbucket;
added,numstart:integer;
distanceFromMe,distanceFromTarget:CU_int160;
begin
  result:=false;
	// Start with a lot of possible contacts, this is a fallback in case search stalls due to dead contacts
	if m_possible.count=0 then begin

		CU_Int160_FillNXor(@distanceFromMe,@DHTme160,@m_target);
		MDHT_routingZone.getClosestTo(3, @m_target, @distanceFromMe, 50, m_possible, true, true);
	end;


  if m_possible.count=0 then begin
   //if m_type=dht_consts.NODECOMPLETE then outputdebugstring(pchar('no sources found!'));
   exit;
  end;

  result:=true;

	//Lets keep our contact list entries in mind to dec the inUse flag.
  for i:=0 to m_possible.count-1 do begin
   bucket:=m_possible[i];
   m_inuse.add(bucket);
  end;

	// Take top 3 possible
	count:=min(3, m_possible.count);
  donecount:=0;

	while ((m_possible.count>0) and (donecount<count)) do begin
	 bucket:=m_possible[0];
      m_possible.delete(0);

   //if m_type=dht_consts.NODECOMPLETE then begin
   // CU_Int160_FillNXor(@distanceFromTarget,@bucket.id,@m_target);
   // outputdebugstring(pchar('Starting findmyself search:'+CU_INT160_tohexstr(@bucket.id,true)+' Distance:'+CU_INT160_tohexstr(@distanceFromTarget,true)));
  // end;

		// Move to tried
		m_tried.add(bucket);

     sendFindID( bucket.ipC, bucket.portW);

		if m_type=NODE then break;
    inc(donecount);
	end;

end;

procedure tmDHTsearch.Expire;
var
baseTime:cardinal;
begin
	if m_stoping then exit;

	baseTime:=0;

	case m_type of

	   dht_consts.NODE,
		 dht_consts.NODECOMPLETE:baseTime:=dht_consts.MDHT_SEARCHNODE_LIFETIME;

		dht_consts.FINDSOURCE:baseTime:=dht_consts.MDHT_SEARCHFINDSOURCE_LIFETIME
     else baseTime:=dht_consts.MDHT_SEARCH_LIFETIME;
	end;
	m_created:=time_now-baseTime+SEC(15);
	m_stoping:=true;
end;

procedure TmDHTsearch.sendFindID(ip:cardinal; port:word);
var
 target,me160,outstr:String;
begin
		if m_stoping then exit;

    target:=CU_INT160_tohexbinstr(@m_target,true);
    me160:=CU_INT160_tohexbinstr(@DHTme160);

    //d1:ad2:id20:abcdefghij01234567896:target20:mnopqrstuvwxyz123456e1:q9:find_node1:t2:aa1:y1:qe
    outstr:='d'+
             '1:a'+
              'd'+
               '2:id20:'+me160+
               '6:target20:'+target+
              'e'+
             '1:q9:find_node'+
             '1:t2:'+int_2_word_string(mdht_currentOutpacketIndex)+
             '1:y1:q'+
            'e';


MDHT_len_tosend:=length(outstr);
move(outstr[1],MDHT_buffer,length(outstr));

dht_socket.mdht_send(ip,port,dht_socket.query_findnode,self);

end;

procedure TmDHTsearch.sendGetPEERS(ip:cardinal; port:word);
var
 target,me160,outstr:String;
begin
		if m_stoping then exit;

    target:=CU_INT160_tohexbinstr(@m_target,true);
    me160:=CU_INT160_tohexbinstr(@DHTme160);

    //d1:ad2:id20:abcdefghij01234567896:target20:mnopqrstuvwxyz123456e1:q9:find_node1:t2:aa1:y1:qe
    outstr:='d'+
             '1:a'+
              'd'+
               '2:id20:'+me160+
               '9:info_hash20:'+target+
              'e'+
             '1:q9:get_peers'+
             '1:t2:'+int_2_word_string(mdht_currentOutpacketIndex)+
             '1:y1:q'+
            'e';



MDHT_len_tosend:=length(outstr);
move(outstr[1],MDHT_buffer,length(outstr));

dht_socket.mdht_send(ip,port,dht_socket.query_getpeer,self);

end;


end.