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
these threads work perform the initial handshake tasks, used by thread_upload->acceptor and to ask for a puash chat request
}

unit helper_private_chat;

interface

uses
 blcksock,classes,sysutils,windows;

type
  tthread_handshaker_incoming_pvt=class(tthread)
  protected
  procedure execute; override;
   procedure get_vars;//sync
//   procedure crea_form;//synch
   procedure dec_pvt_open;//synch
  public
   socket:ttcpblocksocket;
   str:string;
  end;

tthread_chat_push_connector = class(TThread)
protected
str:string;
socket:ttcpblocksocket;
procedure execute; override;
procedure get_vars;//synch
procedure dec_pvt_open;
//procedure crea_form;//synch


 public
 random_str:string;
 his_rem_ip:cardinal;
 his_rem_port:word;
 his_rem_ip_alt:cardinal;
end;

//procedure chat_with_user( ipi:string; porti:word; alt_ipi:cardinal; ip_serveri:cardinal; port_serveri:word; nicknames:string);

implementation

uses
 vars_global,helper_strings,winsock,helper_ipfunc,helper_sockets,
 helper_datetime,{ufrmpvt,ufrmmain,}const_ares,const_commands_privatechat,
 helper_download_misc;

{procedure chat_with_user( ipi:string; porti:word; alt_ipi:cardinal; ip_serveri:cardinal; port_serveri:word; nicknames:string);
var
frmpvt:tfrmpvt;
begin


frmpvt:=tfrmpvt.create(application);
 with frmpvt do begin
  remoteIP:=inet_addr(pchar(ipi));
  RemotePort:=porti;
  nick:=nicknames;
  RemotePort_server:=port_serveri;
  RemoteIP_server:=ip_serveri;
  RemoteIP_alt:=alt_ipi;
  socket:=nil;
  gothroughserver:=vars_global.im_firewalled;
  Show;
  postmessage(handle,WM_PRIVATECHAT_EVENT,14,14); // attiva reader.... modalità connessione
 end;
end;}

procedure tthread_chat_push_connector.get_vars;//synch
var
 strTemp:string;
begin
          str:='|01:0.0.0.0:0|'+vars_global.localip+':'+inttostr(vars_global.myport)+chr(10)+
               '|02:'+vars_global.mynick+chr(10)+
               '|03:'+vars_global.versioneares+chr(10);


                //send xareip digital?

              strTemp:=helpeR_ipfunc.serialize_myConDetails;
              str:=str+CHRNULL+
                       chr(length(strTemp))+CHRNULL+
                       chr(CMD_PRIVCHAT_USERIPNEW)+
                       strTemp;

              //send mynick here?
              str:=str+CHRNULL+
                   chr(length(vars_global.mynick)+1)+CHRNULL+  //here my fip_alt
                   chr(CMD_PRIVCHAT_USERNICK)+
                   vars_global.mynick+CHRNULL;

              //send ip alt?
          str:=str+CHRNULL+
                   chr(5)+CHRNULL+
                   chr(CMD_PRIVCHAT_INTERNALIP)+  //here my fip_alt
                   int_2_dword_string(vars_global.LanIPC)+
                   chr(1);  //2951 int64capable marker


              //send you can browse me?
             if vars_global.check_opt_chat_browsable_checked then begin
               str:=str+CHRNULL+
                        CHRNULL+CHRNULL+
                        chr(CMD_PRIVCHAT_BROWSEGRANTED);    //accetto browse diretto
             end;
end;

procedure tthread_chat_push_connector.dec_pvt_open;//synch
begin
if vars_global.numero_pvt_open>0 then dec(numero_pvt_open);
end;

procedure tthread_chat_push_connector.execute;
var

tempo:cardinal;
er,len:integer;
to_recv,previous_len:integer;
buffer:array[0..20] of char;
connesso:boolean;
begin
freeonterminate:=false;//freeonterminate:=true;
priority:=tplower;

socket:=ttcpblocksocket.create(true);
  socket.SocksIP:='';
  socket.SocksPort:='0';
  socket.ip:=ipint_to_dotstring(his_rem_ip_alt);
  socket.port:=his_rem_port;
 socket.Connect(socket.ip,inttostr(his_rem_port));

connesso:=falsE;
 tempo:=gettickcount;
 while true do begin
  if gettickcount-tempo>TIMOUT_SOCKET_CONNECTION then begin
   socket.free;
   break;
  end;
  er:=TCPSocket_ISConnected(socket);
  if er=0 then begin
  connesso:=true;
  break;
  end;
  if er<>WSAEWOULDBLOCK then begin
   socket.free;
   break;
  end;
  sleep(10);
 end;

 if not connesso then begin
    socket:=ttcpblocksocket.create(true);
     assign_proxy_settings(socket);
     socket.ip:=ipint_to_dotstring(his_rem_ip);
     socket.port:=his_rem_port;

     socket.Connect(socket.ip,inttostr(his_rem_port));

     connesso:=falsE;
     tempo:=gettickcount;
      while true do begin
       if gettickcount-tempo>TIMOUT_SOCKET_CONNECTION then begin
        socket.free;
        synchronize(dec_pvt_open);
        exit;
       end;
       er:=TCPSocket_ISConnected(socket);
       if er=0 then break;
       if er<>WSAEWOULDBLOCK then begin
        socket.free;
        synchronize(dec_pvt_open);
        break;
       end;
       sleep(10);
      end;
 end;

 //str:='CHAT PUSH/1.0 '+bytestr_to_hexstr(random_Str)+chr(10)+chr(10);
 str:=helper_download_misc.get_out_privchat_pushreq(random_str);  //2962+

 tempo:=gettickcount;
 while true do begin
   if gettickcount-tempo>TIMOUT_SOCKET_CONNECTION then begin
     socket.free;
     socket:=nil;
     exit;
   end;
    TCPSocket_SendBuffer(socket.socket, @str[1], length(str), er );
    if er=0 then break else
    if er<>WSAEWOULDBLOCK then begin
     socket.free;
     synchronize(dec_pvt_open);
     exit;
    end;
  sleep(10);
 end;

  tempo:=gettickcount;
 while (true) do begin

   if gettickcount-tempo>25*SECOND then begin
     socket.free;
     synchronize(dec_pvt_open);
     exit;
    end;

  if not TCPSocket_CanRead(socket.socket,0,er) then begin
    if ((er<>0) and (er<>WSAEWOULDBLOCK)) then begin
     socket.free;
     synchronize(dec_pvt_open);
     exit;
    end;
    sleep(10);
    continue;
  end;

     previous_len:=length(socket.buffstr);
     to_recv:=3-previous_len;
      len:=TCPSocket_RecvBuffer(socket.socket,@buffer,to_recv,er);
    if er=WSAEWOULDBLOCK then begin
     sleep(10);
     continue;
    end;

    if er<>0 then begin
     socket.free;
     synchronize(dec_pvt_open);
     exit;
    end;

    if len<1 then begin
     sleep(10);
     continue;
    end;

    setlength(socket.buffstr,previous_len+len);
    move(buffer,socket.buffstr[previous_len+1],len);

     if length(socket.buffstr)<3 then begin
     sleep(10);
     continue;
    end;

        if pos('OK'+chr(10),socket.buffstr)=1 then begin
         socket.buffstr:='';
         break;
        end else begin
         socket.free;
         synchronize(dec_pvt_open);
          exit;
        end;

  sleep(10);
end;

     synchronize(get_vars);

 tempo:=gettickcount;
 while (true) do begin

   if gettickcount-tempo>TIMOUT_SOCKET_CONNECTION then begin
     socket.free;
     synchronize(dec_pvt_open);
     exit;
    end;

       TCPSocket_SendBuffer(socket.socket,@str[1],length(str),er);
       if er=WSAEWOULDBLOCK then begin
        sleep(10);
        continue;
       end;
       if er<>0 then begin
          socket.free;
         synchronize(dec_pvt_open);
         exit;
       end else break;
   end;

//   synchronize(crea_form);
end;

{procedure tthread_chat_push_connector.crea_form;//synch
var
 frmpvt:tfrmpvt;
begin
       frmpvt:=tfrmpvt.create(application);
        frmpvt.socket:=socket;
        frmpvt.RemoteIP:=inet_addr(pchar(socket.ip));
        with frmpvt do begin
         nick:=helper_ipfunc.ipdotstring_to_anonnick(socket.ip);
         RemotePort:=his_rem_port;
         RemoteIP_alt:=his_rem_ip_alt;
         randoms:='';
         Sendmessage(handle,WM_PRIVATECHAT_EVENT,0,0);
        end;
end;}

{procedure tthread_handshaker_incoming_pvt.crea_form;//synch
var
 frmpvt:tfrmpvt;
begin
       frmpvt:=tfrmpvt.create(application);
        frmpvt.socket:=socket;  //<---globale messo in receive accepted handshake
        frmpvt.RemoteIP:=inet_addr(pchar(socket.ip)); //???
        frmpvt.nick:=helper_ipfunc.ipdotstring_to_anonnick(socket.ip);
        inc(vars_global.numero_pvt_open);

    Sendmessage(frmpvt.handle,WM_PRIVATECHAT_EVENT,0,0);
end;}

procedure tthread_handshaker_incoming_pvt.dec_pvt_open;//synch
begin
 if vars_global.numero_pvt_open>0 then
  dec(vars_global.numero_pvt_open);
end;

procedure tthread_handshaker_incoming_pvt.execute;  //se handshake è ok, prende pars e apre form14 in synch
var
previous_len:integer;
len,to_recv:integer;
er:integer;
atttime:cardinal;
buffer:array[0..20] of char;
begin
freeonterminate:=false;//freeonterminate:=true;
priority:=tplower;

 atttime:=gettickcount;
 repeat
   if gettickcount-atttime>TIMOUT_SOCKET_CONNECTION then begin   //timeout
     socket.free;
     synchronize(dec_pvt_open);
     exit;
   end;
     str:='CHAT/0.1 200 OK'+CRLF+CRLF; //str è globale
     TCPSocket_SendBuffer(socket.socket,@str[1],length(str),er);
     if er=WSAEWOULDBLOCK then begin
      sleep(10);
      continue;
     end;
     if er<>0 then begin
      socket.free;
      synchronize(dec_pvt_open);
      exit;
     end else break;
   until (not true);

       synchronize(get_vars);

     //send convenevoli!
    atttime:=gettickcount;
  repeat
   if gettickcount-atttime>TIMOUT_SOCKET_CONNECTION then begin   //timeout
     socket.free;
     synchronize(dec_pvt_open);
     exit;
   end;
     TCPSocket_SendBuffer(socket.socket,@str[1],length(str),er);
    if er=WSAEWOULDBLOCK then begin
      sleep(10);
      continue;
     end;
     if er<>0 then begin
      socket.free;
      synchronize(dec_pvt_open);
      exit;
     end else break;
   until (not true);



   //riceviamo suo chat 200 ok
atttime:=gettickcount;
socket.buffstr:='';

  repeat

    if gettickcount-atttime>TIMOUT_SOCKET_CONNECTION then begin   //timeout
     socket.free;
     synchronize(dec_pvt_open);
     exit;
   end;



    if not TCPSocket_CanRead(socket.socket,0,er) then begin
     if ((er<>0) and (er<>WSAEWOULDBLOCK)) then begin
       socket.free; //termina tutto
       synchronize(dec_pvt_open);
       exit;
     end else begin
      sleep(10);
      continue;
     end;
    end;

    previous_len:=length(socket.buffstr);
    to_recv:=19-previous_len;
   len:=TCPSocket_RecvBuffer(socket.socket,@buffer,to_recv,er);  //riceviamo solo 19 bytes di reply, in modo da facilitarci con altro parse
    if er=WSAEWOULDBLOCK then begin
     sleep(10);
     continue;
    end else
    if er<>0 then begin // minchione...
      socket.free;   //termina tutto
      synchronize(dec_pvt_open);
      exit;
   end;
   if len<1 then begin
    sleep(10);
    continue;
   end;

   setlength(socket.buffstr,previous_len+len);
   move(buffer,socket.buffstr[previous_len+1],len);
     if length(socket.buffstr)<19 then begin
      sleep(10);
      continue;
     end;

        if pos('CHAT/0.1 200 OK'+CRLF+CRLF,socket.buffstr)=1 then begin //bingo
           socket.buffstr:='';//free text
           break;
        end else begin
         socket.free;   //termina tutto
         synchronize(dec_pvt_open);
         exit;
        end;


until (not true);



//synchronize(crea_form); // connection established


end;

procedure tthread_handshaker_incoming_pvt.get_vars;//synch
var
strTemp:string;
begin
          str:='|01:0.0.0.0:0|'+vars_global.localip+':'+inttostr(vars_global.myport)+chr(10)+
               '|02:'+vars_global.mynick+chr(10)+
               '|03:'+vars_global.versioneares+chr(10);

                //send xareip digital?
              strTemp:=helpeR_ipfunc.serialize_myConDetails;
              str:=str+CHRNULL+
                       chr(length(strTemp))+CHRNULL+
                       chr(CMD_PRIVCHAT_USERIPNEW)+
                       strTemp;

              //send mynick here?
              str:=str+CHRNULL+
                   chr(length(vars_global.mynick)+1)+CHRNULL+  //here my fip_alt
                   chr(CMD_PRIVCHAT_USERNICK)+
                   vars_global.mynick+CHRNULL;

              //send ip alt?
          str:=str+CHRNULL+
                   chr(5)+CHRNULL+
                   chr(CMD_PRIVCHAT_INTERNALIP)+  //here my fip_alt
                   int_2_dword_string(vars_global.LanIPC)+
                   chr(1); //2951+ marker int64capab



              //send you can browse me?
             if vars_global.check_opt_chat_browsable_checked then begin
               str:=str+CHRNULL+
                        CHRNULL+CHRNULL+
                        chr(CMD_PRIVCHAT_BROWSEGRANTED);    //accetto browse diretto
             end;
end;


end.
