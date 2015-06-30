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
commands used in private chat communications
}

unit const_commands_privatechat;

interface

const
 CMD_PRIVCHAT_MESSAGE        = 1;  //text message
 CMD_PRIVCHAT_FILEREQUEST    = 2; //request to initiate file transfer
 CMD_PRIVCHAT_FILEACK        = 3; //file session accepted->start transfer
 CMD_PRIVCHAT_FILEDENY       = 4;  // remote user(receiver) denied file transfer session
 CMD_PRIVCHAT_FILECHUNK      = 5;  // another block of data arrived
 CMD_PRIVCHAT_AVATAR         = 6;  //remote user sends avatar
 CMD_PRIVCHAT_PING           = 10; // ping request

 CMD_PRIVCHAT_PONG           = 11; // pong message
 CMD_PRIVCHAT_PONGNEW        = 30;

 CMD_PRIVCHAT_INTERNALIP     = 12; //remote user sends details about his/her internal IP
 CMD_PRIVCHAT_BROWSEGRANTED  = 15; // remote user accepts browse requests
 CMD_PRIVCHAT_BROWSEREQ      = 17; // incoming browse request
 CMD_PRIVCHAT_BROWSEITEM     = 18; // new browse entry
 CMD_PRIVCHAT_BROWSEENDOF    = 19; // browse ended
 CMD_PRIVCHAT_BROWSESTART    = 20; // start of browse
 CMD_PRIVCHAT_USERIP         = 25; // remote user sends complete connection/supernode details
 CMD_PRIVCHAT_USERIPNEW      = 29; // remote user sends complete connection/supernode details
 CMD_PRIVCHAT_USERNICK       = 26; // remote user sends his/her nickname
 CMD_PRIVCHAT_BROWSE_REALFOLDER = 28; // browse real folder listing (real subfolder path on remote user's pc)

implementation

end.
