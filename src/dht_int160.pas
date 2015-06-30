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
DHT special 128 bit integer functions
}


unit dht_int160;

interface

uses
 sysutils,windows,synsock;

type
CU_INT160=array[0..4] of cardinal;
pCU_INT160=^CU_INT160;
pbytearray=^tbytearray;
tbytearray=array[0..1023] of byte;

procedure CU_INT160_xor(inValue:pCu_INT160; value:pCu_INT160);
function CU_INT160_tohexstr(value:pCu_INT160; reversed:boolean = true ):string;
function CU_INT160_tohexbinstr(value:pCu_INT160; doreverse:boolean=true):string;

procedure CU_INT160_fill(inValue:pCu_INT160; value:pCu_INT160); overload;
procedure CU_Int160_fill(m_data:pCU_INT160; value:pCU_INT160; numBits:cardinal); overload;

function CU_INT160_Compare(Value1:pCu_INT160; value2:pCu_INT160):boolean;
function CU_INT160_compareTo(m_data:pCU_INT160; value:cardinal):integer; overload;
function CU_Int160_compareTo(m_data:pCU_Int160; other:pCU_INT160):integer; overload;

function CU_INT160_getBitNumber(m_data:pCU_INT160; bit:cardinal):cardinal;
procedure CU_Int160_setBitNumber(m_data:pCU_INT160; bit:cardinal; value:cardinal);
procedure CU_Int160_shiftLeft(m_data:pCU_INT160; bits:cardinal);
procedure CU_Int160_setValue(m_data:pCU_INT160; value:cardinal);
procedure CU_Int160_add(m_data:pCU_INT160; value:pCU_Int160); overload;
procedure CU_Int160_add(m_data:pCU_INT160; value:cardinal); overload;
function CU_INT160_MinorOf(m_data:pCU_INT160; value:cardinal):boolean; overload;
function CU_INT160_MinorOf(m_data:pCU_INT160; value:pCU_INT160):boolean; overload;
function CU_INT160_Majorof(m_data:pCU_INT160; value:pCU_INT160):boolean;
procedure CU_Int160_toBinaryString(m_data:pCU_INT160; var str:string; trim:boolean=false);
procedure CU_Int160_setValueBE(m_data:pCU_INT160; valueBE:pbytearray);
procedure CU_INT160_fillNXor(Destination:pCU_INT160; initialValue:pCU_INT160; xorvalue:pCU_INT160);
procedure CU_INT160_copytoBuffer(source:pCU_INT160; destination:pbytearray);
procedure CU_INT160_copyFromBuffer(source:pbytearray; destination:pCU_INT160);
procedure CU_INT160_copyFromBufferRev(source:pbytearray; destination:pCU_INT160);

var
m_data:CU_INT160;


implementation

uses
 helper_strings;



procedure CU_INT160_copyFromBuffer(source:pbytearray; destination:pCU_INT160);
begin
    move(source[0],destination[0],4);
    move(source[4],destination[1],4);
    move(source[8],destination[2],4);
    move(source[12],destination[3],4);
    move(source[16],destination[4],4);
end;

procedure CU_INT160_copyFromBufferRev(source:pbytearray; destination:pCU_INT160);
begin
    move(source[0],destination[0],4);
    move(source[4],destination[1],4);
    move(source[8],destination[2],4);
    move(source[12],destination[3],4);
    move(source[16],destination[4],4);
    destination[0]:=synsock.ntohl(destination[0]);
    destination[1]:=synsock.ntohl(destination[1]);
    destination[2]:=synsock.ntohl(destination[2]);
    destination[3]:=synsock.ntohl(destination[3]);
    destination[4]:=synsock.ntohl(destination[4]);
end;

procedure CU_INT160_copytoBuffer(source:pCU_INT160; destination:pbytearray);
begin
    move(source[0],destination[0],4);
    move(source[1],destination[4],4);
    move(source[2],destination[8],4);
    move(source[3],destination[12],4);
    move(source[4],destination[16],4);
end;

procedure CU_INT160_fillNXor(Destination:pCU_INT160; initialValue:pCU_INT160; xorvalue:pCU_INT160);
begin
 destination[0]:=initialValue[0] xor xorvalue[0];
 destination[1]:=initialValue[1] xor xorvalue[1];
 destination[2]:=initialValue[2] xor xorvalue[2];
 destination[3]:=initialValue[3] xor xorvalue[3];
 destination[4]:=initialValue[4] xor xorvalue[4];
end;

procedure CU_Int160_setValue(m_data:pCU_INT160; value:cardinal);
begin
	m_data[0]:=0;
	m_data[1]:=0;
	m_data[2]:=0;
  m_data[3]:=0;
	m_data[4]:=value;
end;

procedure CU_Int160_setValueBE(m_data:pCU_INT160; valueBE:pbytearray);
var
i:integer;
begin
	m_data[0]:=0;
	m_data[1]:=0;
	m_data[2]:=0;
	m_data[3]:=0;
  m_data[4]:=0;

	for i:=0 to 19 do
  m_data[i div 4]:=m_data[i div 4] or (cardinal(valueBE[i]) shl (8*(3-(i mod 4))));

end;

procedure CU_Int160_shiftLeft(m_data:pCU_INT160; bits:cardinal);
var
temp:CU_INT160;
indexShift,i:integer;
bit64Value,shifted:int64;
begin
   if ((bits=0) or
       ( ((m_data[0]=0) and
          (m_data[1]=0) and
          (m_data[2]=0) and
          (m_data[3]=0) and
          (m_data[4]=0))
       )
       ) then exit;

	if bits>159 then begin
		CU_Int160_setValue(m_data,0);
    exit;
	end;

  temp[0]:=0;
  temp[1]:=0;
  temp[2]:=0;
  temp[3]:=0;
  temp[4]:=0;

	indexShift:=integer(bits) div 32;
	shifted:=0;

  i:=4;
  while (i>=indexShift) do begin
    bit64Value:=int64(m_data[i]);
		shifted:=shifted+(bit64Value shl int64(bits mod 32));
		temp[i-indexShift]:=cardinal(shifted);
		shifted:=shifted shr 32;
    dec(i);
	end;

	for i:=0 to 4 do m_data[i]:=temp[i];

end;

procedure CU_Int160_add(m_data:pCU_INT160; value:pCU_Int160);
var
sum:int64;
i:integer;
begin
	if CU_INT160_compareTo(value,0)=0 then exit;

	sum:=0;
	for i:=4 downto 0 do begin
		sum:=sum+m_data[i];
		sum:=sum+value[i];
		m_data[i]:=cardinal(sum);
		sum:=sum shr 32;
	end;

end;

procedure CU_Int160_add(m_data:pCU_INT160; value:cardinal);
var
temp:CU_INT160;
begin
	if value=0 then exit;

	CU_Int160_SetValue(@temp,value);
	CU_Int160_add(m_data,@temp);
end;


function CU_INT160_getBitNumber(m_data:pCU_INT160; bit:cardinal):cardinal;
var
uLongNum,shift:integer;
begin
  result:=0;
	if (bit>159) then exit;

  ulongNum:=bit div 32;
	shift:=31-(bit mod 32);
	result:= ((m_data[ulongNum] shr shift) and 1);
end;

procedure CU_Int160_setBitNumber(m_data:pCU_INT160; bit:cardinal; value:cardinal);
var
ulongNum,shift:integer;
begin
	ulongNum:=bit div 32;
	shift:=31-(bit mod 32);
	m_data[ulongNum]:=m_data[ulongNum] or (1 shl shift);
	if value=0 then m_data[ulongNum]:=m_data[ulongNum] xor (1 shl shift);
end;

function CU_INT160_compareTo(m_data:pCU_INT160; value:cardinal):integer;
begin
	if ((m_data[0]>0) or
      (m_data[1]>0) or
      (m_data[2]>0) or
      (m_data[3]>0) or
      (m_data[4]>value)) then begin
		result:=1;
    exit;
  end;

	if m_data[4]<value then begin
		result:=-1;
    exit;
  end;

	result:=0;
end;

function CU_INT160_Compare(Value1:pCu_INT160; value2:pCu_INT160):boolean;
begin
 result:=((Value1[0]=Value2[0]) and
          (Value1[1]=Value2[1]) and
          (Value1[2]=Value2[2]) and
          (Value1[3]=Value2[3]) and
          (Value1[4]=Value2[4]));
end;

procedure CU_INT160_xor(inValue:pCu_INT160; value:pCu_INT160);
begin
	inValue[0]:=inValue[0] xor value[1];
  inValue[1]:=inValue[1] xor value[1];
  inValue[2]:=inValue[2] xor value[2];
  inValue[3]:=inValue[3] xor value[3];
  inValue[4]:=inValue[4] xor value[4];
end;

procedure CU_INT160_fill(inValue:pCu_INT160; value:pCu_INT160);
begin
	inValue[0]:=value[0];
  inValue[1]:=value[1];
  inValue[2]:=value[2];
  inValue[3]:=value[3];
  inValue[4]:=value[4];
end;

procedure CU_Int160_fill(m_data:pCU_INT160; value:pCU_INT160; numBits:cardinal);
var
i:integer;
numULONGs:cardinal;
begin
	// Copy the whole ULONGs
	numULONGs:=numBits div 32;
	for i:=0 to numULONGs-1 do begin
   m_data[i]:=value[i];
  end;

	// Copy the remaining bits
	for i:=(32*numULONGs) to numBits-1 do CU_INT160_setBitNumber(m_data,i, CU_INT160_getBitNumber(value,i));
	// Pad with random bytes (Not seeding based on time to allow multiple different ones to be created in quick succession)
	for i:=numBits to 159 do CU_INT160_setBitNumber(m_data,i, (random(2)));
end;

procedure CU_Int160_toBinaryString(m_data:pCU_INT160; var str:string; trim:boolean=false);
var
b,i:integer;
begin
	str:='';

	for i:=0 to 159 do begin
		b:=CU_Int160_getBitNumber(m_data,i);
		if ((not trim) or (b<>0)) then begin
			str:=str+Format('%d',[b]);
			trim:=false;
		end;
	end;
	if length(str)=0 then str:='0';

end;

function CU_INT160_tohexbinstr(value:pCu_INT160; doreverse:boolean=true):string;
var
 num:cardinal;
begin
setLength(result,20);
if doreverse then begin
 num:=synsock.htonl(value[0]);
 move(num,result[1],4);
   num:=synsock.htonl(value[1]);
 move(num,result[5],4);
   num:=synsock.htonl(value[2]);
 move(num,result[9],4);
   num:=synsock.htonl(value[3]);
 move(num,result[13],4);
   num:=synsock.htonl(value[4]);
 move(num,result[17],4);
end else begin

 move(value[1],result[5],4);
 move(value[2],result[9],4);
 move(value[3],result[13],4);
 move(value[4],result[17],4);
end;

//result:=result;
end;

function CU_INT160_tohexstr(value:pCu_INT160; reversed:boolean = true):string;
var
num:cardinal;
begin
setLength(result,20);

if reversed then begin
 num:=synsock.ntohl(value[0]);
move(num,result[1],4);
 num:=synsock.ntohl(value[1]);
move(num,result[5],4);
 num:=synsock.ntohl(value[2]);
move(num,result[9],4);
 num:=synsock.ntohl(value[3]);
move(num,result[13],4);
 num:=synsock.ntohl(value[4]);
move(num,result[17],4);
end else begin
 move(value[0],result[1],4);
 move(value[1],result[5],4);
 move(value[2],result[9],4);
 move(value[3],result[13],4);
 move(value[4],result[17],4);
end;

result:=bytestr_to_hexstr(result);
end;

function CU_INT160_MinorOf(m_data:pCU_INT160; value:cardinal):boolean;
begin
result:=(CU_INT160_compareTo(m_data,value)<0);
end;

function CU_INT160_MinorOf(m_data:pCU_INT160; value:pCU_INT160):boolean; overload;
begin
result:=(CU_INT160_compareTo(m_data,value)<0);
end;

function CU_INT160_Majorof(m_data:pCU_INT160; value:pCU_INT160):boolean; overload;
begin
result:=(CU_INT160_compareTo(m_data,value)>0);
end;

function CU_Int160_compareTo(m_data:pCU_Int160; other:pCU_INT160):integer;
var
i:integer;
begin
result:=0;

	for i:=0 to 4 do begin
	    if m_data[i]<other[i] then begin
       result:=-1;
       exit;
      end;
	    if m_data[i]>other[i] then begin
       result:=1;
       exit;
      end;
	end;
end;

end.