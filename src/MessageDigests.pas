unit MessageDigests;

(*$J-*) { Don't need modifiable typed constants. }

(*$IFDEF Ver80*)
  (*$DEFINE PreDelphi4*)
  (*$DEFINE PreDelphi3*)
(*$ENDIF*)
(*$IFDEF Ver90*)
  (*$DEFINE PreDelphi4*)
  (*$DEFINE PreDelphi3*)
(*$ENDIF*)
(*$IFDEF Ver100*)
  (*$DEFINE PreDelphi4*)
(*$ENDIF*)

interface

uses Classes, SysUtils;

const
  BitsPerByte = 8;
  
type
  PDWORD = ^DWORD;
  DWORD = (*$IFDEF PreDelphi4*) Longint (*$ELSE*) Longword (*$ENDIF*) ;
  
{
  Copyright (c) 1998-1999 Dave Shapiro, Professional Software, Inc.
  Use and modify freely.
  
                    MessageDigests class hierarchy:


                            TMessageDigest
                              (abstract)
                                  |
           ----------------------------------------
           |                                      |
         TMD2                                 TMD4Family
      (16-byte)                               (abstract)
                                                  |
                             -------------------------------------------
                             |             |             |             |
                            TMD4         TMD5          TSHA1       TRIPEMD160
                         (16-byte)    (16-byte)      (20-byte)      (20-byte)
}


type
  TMessageDigest = class(TObject)
  protected
    PDigest: Pointer;
    PLastBlock: Pointer;
    NumLastBlockBytes: Integer;
    FBlockSize: Integer;
    FDigestSize: Integer;
    FBlocksDigested: Longint;
    FCompleted: Boolean;
    constructor CreateInternal(const BlockSize, DigestSize: Integer);
    procedure TransformBlocks(const Blocks;
                              const BlockCount: Longint); virtual;
    procedure RequireCompletion;
    procedure RequireIncompletion;
  public
    constructor Create; virtual; abstract;
    destructor Destroy; override;
    procedure Transform(const M; NumBytes: Longint);
    procedure TransformStream(const Stream: TStream);
    procedure TransformString(const S: string);
    procedure Complete; virtual;
    procedure Clear; virtual;
    function HashValue: string;
    function HashValueBytes: Pointer;
    function NumBytesDigested: Longint;
    class function AsString: string; virtual; abstract;
    property BlockSize: Integer read FBlockSize;
    property DigestSize: Integer read FDigestSize;
    property BlocksDigested: Longint read FBlocksDigested;
    property Completed: Boolean read FCompleted;
  end;

  TMessageDigestClass = class of TMessageDigest;

type
  PMD2Block = ^TMD2Block;
  TMD2Block = array [0..15] of Byte;
  TMD2Buffer = array [1..48] of Byte;
  TMD2Digest = array [1..16] of Byte;

const
  MD2BlockSize = SizeOf(TMD2Block);
  MD2DigestSize = SizeOf(TMD2Digest);

type
  TMD2 = class(TMessageDigest)
  private
    Checksum: TMD2Block;
    ChecksumL: Byte;
    Buffer: TMD2Buffer;
  protected
    procedure TransformBlocks(const Blocks; const BlockCount: Longint); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Complete; override;
    procedure Clear; override;
    class function AsString: string; override;
  end;

  TMD2Class = class of TMD2;
  
type
  TChainingVar = DWORD;

type
  TMD4Family = class(TMessageDigest)
  protected
    PInitialChainingValues: Pointer;
    PChainingVars: Pointer;
    FIsBigEndian: Boolean;
    constructor CreateInternal(const BlockSize, DigestSize: Integer;
                               const InitialChainingValues;
                               const IsBigEndian: Boolean); 
  public
    destructor Destroy; override;
    procedure Complete; override;
    procedure Clear; override;
  end;

  TMD4FamilyClass = class of TMD4Family;

type
  TMDxChainingVarRange = (mdA, mdB, mdC, mdD);
  PMD4ChainingVarArray = ^TMD4ChainingVarArray;
  TMD4ChainingVarArray = array [TMDxChainingVarRange] of TChainingVar;
  TMD4Digest = array [1..4] of DWORD;
  PMD4Block = ^TMD4Block;
  TMD4Block = array [0..15] of DWORD;

const
  MD4BlockSize = SizeOf(TMD4Block);
  MD4DigestSize = SizeOf(TMD4Digest);

type
  TMD4 = class(TMD4Family)
  private
  protected
    procedure TransformBlocks(const Blocks; const BlockCount: Longint); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    class function AsString: string; override;
  end;

  TMD4Class = class of TMD4;

type
  PMD5ChainingVarArray = ^TMD5ChainingVarArray;
  TMD5ChainingVarArray = array [TMDxChainingVarRange] of TChainingVar;
  TMD5Digest = array [1..4] of DWORD;
  PMD5Block = ^TMD5Block;
  TMD5Block = array [0..15] of DWORD;

const
  MD5BlockSize = SizeOf(TMD5Block);
  MD5DigestSize = SizeOf(TMD5Digest);

type
  TMD5 = class(TMD4Family)
  private
  protected
    procedure TransformBlocks(const Blocks; const BlockCount: Longint); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    class function AsString: string; override;
  end;

  TMD5Class = class of TMD5;

type
  TSHAChainingVarRange = (shaA, shaB, shaC, shaD, shaE);
  PSHAChainingVarArray = ^TSHAChainingVarArray;
  TSHAChainingVarArray = array [TSHAChainingVarRange] of TChainingVar;
  TSHADigest = array [1..5] of DWORD;
  PSHABlock = ^TSHABlock;
  TSHABlock = array [0..15] of DWORD;

const
  SHABlockSize = SizeOf(TSHABlock);
  SHADigestSize = SizeOf(TSHADigest);

type
  TSHA1 = class(TMD4Family)
  private
  protected
    procedure TransformBlocks(const Blocks; const BlockCount: Longint); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    class function AsString: string; override;
  end;

  TSHA1Class = class of TSHA1;

type
  TRIPEMD160ChainingVarRange = (ripA, ripB, ripC, ripD, ripE);
  PRIPEMD160ChainingVarArray = ^TRIPEMD160ChainingVarArray;
  TRIPEMD160ChainingVarArray = array [TRIPEMD160ChainingVarRange] of TChainingVar;
  TRIPEMD160Digest = array [1..5] of DWORD;
  PRIPEMD160Block = ^TRIPEMD160Block;
  TRIPEMD160Block = array [0..15] of DWORD;

const
  RIPEMD160BlockSize = SizeOf(TRIPEMD160Block);
  RIPEMD160DigestSize = SizeOf(TRIPEMD160Digest);

type
  TRIPEMD160 = class(TMD4Family)
  private
  protected
    procedure TransformBlocks(const Blocks; const BlockCount: Longint); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    class function AsString: string; override;
  end;

  TRIPEMD160Class = class of TRIPEMD160;
  

implementation

type
  TDoubleDWORD = record
    L, H: DWORD;
  end;
  TFourByte = packed record
    B1, B2, B3, B4: Byte;
  end;

function CircularSHL(const X: DWORD; const Amount: Byte): DWORD;
{
  Pre: Amount < BitsInX.
  Post: Result is an unsigned circular left shift of X by Amount bytes.
}
const
  BitsInX = SizeOf(X) * BitsPerByte;
begin
  Result := X shl Amount or X shr (BitsInX - Amount);
end;

{--------------------------TMessageDigest--------------------------------------}


constructor TMessageDigest.CreateInternal(const BlockSize, DigestSize: Integer);
{
  Pre: BlockSize > 0 and DigestSize > 0.
  Post: Self.FBlockSize = BlockSize and Self.FDigestSize = DigestSize.
        Returns a message digest with LastBlock and Digest space allocated.
}
begin
  (*$IFNDEF PreDelphi3*)
    Assert(BlockSize > 0, 'TMessageDigest.CreateInternal: BlockSize <= 0.');
    Assert(DigestSize > 0, 'TMessageDigest.CreateInternal: DigestSize <= 0.');
  (*$ENDIF*)
  inherited Create;
  FBlockSize := BlockSize;
  PLastBlock := nil;
  FDigestSize := DigestSize;
  PDigest := nil;
  Clear;
end;

destructor TMessageDigest.Destroy;
begin
  if Assigned(PDigest) then FreeMem(PDigest);
  if Assigned(PLastBlock) then FreeMem(PLastBlock);
  inherited;
end;

procedure TMessageDigest.Complete;
begin
  FCompleted := True;
end;

procedure TMessageDigest.Clear;
begin
  if not Assigned(PLastBlock) then GetMem(PLastBlock, FBlockSize);
  if not Assigned(PDigest) then GetMem(PDigest, FDigestSize);
  FillChar(PLastBlock^, FBlockSize, 0);
  FillChar(PDigest^, FDigestSize, 0);
  NumLastBlockBytes := 0;
  FBlocksDigested := 0;
  FCompleted := False;
end;

procedure TMessageDigest.Transform(const M; NumBytes: Longint);
{
  Pre: Addr(M) <> nil and NumBytes >= 0.
  Post: Instance's state will be updated to include the contents of M in
        the message digest. If not enough bytes are given to fill a block,
        no calculations are made, but the bytes are saved for future
        transformations.
}
var
  NumBlocks: Longint;
  P, PLB: ^Byte;
  NumBytesNeeded: Integer;
begin
  RequireIncompletion;
  P := Addr(M);
  (*$IFNDEF PreDelphi3*)
    Assert(Assigned(P), 'Transform: M not assigned.');
  (*$ENDIF*)
  if NumLastBlockBytes > 0 then begin
    PLB := PLastBlock;
    Inc(PLB, NumLastBlockBytes);
    NumBytesNeeded := FBlockSize - NumLastBlockBytes;
    if NumBytes < NumBytesNeeded then begin
      Move(M, PLB^, NumBytes);
      Inc(NumLastBlockBytes, NumBytes);
      Exit;
    end;
    Move(M, PLB^, NumBytesNeeded);
    Dec(NumBytes, NumBytesNeeded);
    Inc(P, NumBytesNeeded);
    TransformBlocks(PLastBlock^, 1);
  end;
  NumBlocks := NumBytes div FBlockSize;
  TransformBlocks(P^, NumBlocks);
  NumLastBlockBytes := NumBytes mod FBlockSize;
  Inc(P, NumBytes - NumLastBlockBytes);
  Move(P^, PLastBlock^, NumLastBlockBytes);
end;

procedure TMessageDigest.TransformStream(const Stream: TStream);
{
  Pre: Stream <> nil
  Post: Instance's state will be updated to include the contents of Stream
        in the message digest. This routine starts at Stream.Position and
        goes to the end of the stream. The Stream's position will be at the
        end upon termination of this routine, i.e.
        Stream.Position = Stream.Size.
}
var
  Buffer: array [1..1024] of Byte;
  NumBytes: Longint;
begin
  (*$IFNDEF PreDelphi3*)
    Assert(Assigned(Stream), 'TransformStream: Stream not assigned.');
  (*$ENDIF*)
  repeat
    NumBytes := Stream.Read(Buffer, SizeOf(Buffer));
    Transform(Buffer, NumBytes);
  until NumBytes < SizeOf(Buffer);
end;

procedure TMessageDigest.TransformString(const S: string);
{
  Pre: None.
  Post: Instance's state will be updated to include the contents of S
        in the message digest. This routine starts at S[1] and goes to
        the end of the string.
}
begin
  Transform(S[1], Length(S));
end;

procedure TMessageDigest.TransformBlocks(const Blocks;
                                         const BlockCount: Longint);
begin
  Inc(FBlocksDigested, BlockCount);
end;

function TMessageDigest.HashValueBytes: Pointer;
begin
  RequireCompletion;
  Result := PDigest;
end;

function TMessageDigest.HashValue: string;
{
  Pre: Technically, none. However, the digest is meaningless until Complete
       has been called on the instance, and thus this function will return
       a blank string unless it has been completed.
  Post: A string of 2 * FDigestSize bytes representing the hex value of the
        message digest. The left-most two characters of the resulting string
        represent the first byte of the message digest, and the right-most
        two characters of the resulting string represent the last byte of the
        message digest.
}
const
  DigitToHex: array [0..$0F] of Char = (
   '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
   'a', 'b', 'c', 'd', 'e', 'f'
  );
var
  I: Integer;
  PD: ^Byte;
  PR: ^Char;
begin
  RequireCompletion;
  SetLength(Result, 2 * FDigestSize);
  PD := PDigest;
  PR := Addr(Result[1]);
  for I := 1 to FDigestSize do begin
    PR^ := DigitToHex[PD^ shr 4];
    Inc(PR);
    PR^ := DigitToHex[PD^ and $0F];
    Inc(PR);
    Inc(PD);
  end;
end;

function TMessageDigest.NumBytesDigested: Longint;
begin
  Result := FBlocksDigested * FBlockSize;
end;

procedure TMessageDigest.RequireCompletion;
begin
  if not Completed then raise Exception.Create('Message digest not complete.');
end;

procedure TMessageDigest.RequireIncompletion;
begin
  if Completed then raise Exception.Create('Message digest already complete.');
end;


{----------------------------------TMD2----------------------------------------}


constructor TMD2.Create;
{
  Pre: None.
  Post: Returns an instance of class TMD2, capable of computing message
        digests using the MD2 algorithm.
}
begin
  inherited CreateInternal(MD2BlockSize, MD2DigestSize);
end;

destructor TMD2.Destroy;
begin
  inherited;
end;

procedure TMD2.Clear;
begin
  inherited;
  FillChar(Checksum, SizeOf(Checksum), 0);
  FillChar(Buffer, SizeOf(Buffer), 0);
end;

const
  MD2Permutation: array [Byte] of Byte = (
    41,  46,  67, 201, 162, 216, 124,   1,  61,  54,  84, 161, 236, 240,   6,
    19,  98, 167,   5, 243, 192, 199, 115, 140, 152, 147,  43, 217, 188,  76,
   130, 202,  30, 155,  87,  60, 253, 212, 224,  22, 103,  66, 111,  24, 138,
    23, 229,  18, 190,  78, 196, 214, 218, 158, 222,  73, 160, 251, 245, 142,
   187,  47, 238, 122, 169, 104, 121, 145,  21, 178,   7,  63, 148, 194,  16,
   137,  11,  34,  95,  33, 128, 127,  93, 154,  90, 144,  50,  39,  53,  62,
   204, 231, 191, 247, 151,   3, 255,  25,  48, 179,  72, 165, 181, 209, 215,
    94, 146,  42, 172,  86, 170, 198,  79, 184,  56, 210, 150, 164, 125, 182,
   118, 252, 107, 226, 156, 116,   4, 241,  69, 157, 112,  89, 100, 113, 135,
    32, 134,  91, 207, 101, 230,  45, 168,   2,  27,  96,  37, 173, 174, 176,
   185, 246,  28,  70,  97, 105,  52,  64, 126,  15,  85,  71, 163,  35, 221,
    81, 175,  58, 195,  92, 249, 206, 186, 197, 234,  38,  44,  83,  13, 110,
   133,  40, 132,   9, 211, 223, 205, 244,  65, 129,  77,  82, 106, 220,  55,
   200, 108, 193, 171, 250,  36, 225, 123,   8,  12, 189, 177,  74, 120, 136,
   149, 139, 227,  99, 232, 109, 233, 203, 213, 254,  59,   0,  29,  57, 242,
   239, 183,  14, 102,  88, 208, 228, 166, 119, 114, 248, 235, 117,  75,  10,
    49,  68,  80, 180, 143, 237,  31,  26, 219, 153, 141,  51, 159,  17, 131,
    20
  );

procedure TMD2.TransformBlocks(const Blocks; const BlockCount: Longint);
{
  Pre: Addr(Blocks) <> nil and Blocks is an exact integral number of blocks
       of size MD2BlockSize and BlockCount represents the number of blocks
       in Blocks.
  Post: Self will update its state to reflect the message digest after
        processing Blocks with the MD2 algorithm. This includes updating the
        checksum so that when Complete is called, the digest can be correctly
        computed.
}
const
  NumRounds = 18;
var
  I: Longint;
  J, T, K: Byte;
  PBlock: PMD2Block;
  PC, PJ, PX, PX16, PX32: ^Byte;
begin
  PBlock := Addr(Blocks);
  (*$IFNDEF PreDelphi3*)
    Assert(Assigned(PBlock), 'TMD2.TransformBlocks: Addr(Blocks) = nil.');
    {
    Assert(BlockCount mod MD2BlockSize = 0,
           'TMD2.TransformBlocks: BlockCount mod MD2BlockSize <> 0.');
    }
  (*$ENDIF*)
  for I := 1 to BlockCount do begin
    { Checksum Ith block. }
    PJ := Pointer(PBlock);
    PC := Addr(Checksum);
    for J := Low(Checksum) to High(CheckSum) do begin
      ChecksumL := PC^ xor MD2Permutation[PJ^ xor ChecksumL];
      PC^ := ChecksumL;
      Inc(PJ); Inc(PC);
    end;
    { Copy Ith block into X. }
    PJ := Pointer(PBlock);
    PX := Addr(Buffer);
    PX16 := PX; Inc(PX16, 16);
    PX32 := PX; Inc(PX32, 32);
    for J := 0 to 15 do begin
      PX16^ := PJ^;
      PX32^ := PX16^ xor PX^;
      Inc(PJ); Inc(PX); Inc(PX16); Inc(PX32);
    end;
    { Do 18 rounds. }
    T := 0;
    for J := 0 to Pred(NumRounds) do begin
      PX := Addr(Buffer);
      for K := Low(Buffer) to High(Buffer) do begin
        T := PX^ xor MD2Permutation[T];
        PX^ := T;
        Inc(PX);
      end;
      Inc(T, J);
    end;
    { Advance pointer to next block. }
    Inc(PBlock);
  end;
  Move(Buffer, PDigest^, FDigestSize);
  inherited;
end;

procedure TMD2.Complete;
{
  Pre: None.
  Post: This will complete the digestion of the data. Any remaining bytes
        (i.e. left over from an impartial block) will be padded in accordance
        with the MD2 standard and transformed. Finally, the checksum will be
        transformed. The property HashValue will represent the 16-byte digest
        of the data that have been input since creation of this instance.
}
var
  NumBytesNeeded: Integer;
  P: ^Byte;
begin
  RequireIncompletion;
  NumBytesNeeded := FBlockSize - NumLastBlockBytes;
  P := PLastBlock;
  Inc(P, NumLastBlockBytes);
  FillChar(P^, NumBytesNeeded, NumBytesNeeded);
  TransformBlocks(PLastBlock^, 1);
  Move(Checksum, PLastBlock^, SizeOf(Checksum));
  TransformBlocks(PLastBlock^, 1);
  inherited;
end;

class function TMD2.AsString: string;
begin
  Result := 'MD2';
end;

{--------------------------------TMD4Family------------------------------------}


constructor TMD4Family.CreateInternal(const BlockSize, DigestSize: Integer;
                                      const InitialChainingValues;
                                      const IsBigEndian: Boolean);
{
  Pre: InitialChainingValues <> nil and
       number of bytes in InitialChainingValues = FDigestSize.
  Post: Self.FInitialChainingValues = InitialChainingValues by value, but
        not by address.
        Returns an instance of class TMD4Family, capable of computing message
        digests using one of algorithms in the MD4 family.
}
begin
  (*$IFNDEF PreDelphi3*)
  Assert(Assigned(Addr(InitialChainingValues)),
         'TMD4Family.InitializeChainingValues: InitialChainingValues = nil.');
  (*$ENDIF*)
  GetMem(PInitialChainingValues, DigestSize);
  Move(InitialChainingValues, PInitialChainingValues^, DigestSize);
  inherited CreateInternal(BlockSize, DigestSize);
  FIsBigEndian := IsBigEndian;
end;

destructor TMD4Family.Destroy;
begin
  FreeMem(PChainingVars);
  FreeMem(PInitialChainingValues);
  inherited;
end;

procedure TMD4Family.Clear;
begin
  inherited;
  if not Assigned(PChainingVars) then GetMem(PChainingVars, DigestSize);
  Move(PInitialChainingValues^, PChainingVars^, DigestSize);
end;

procedure TMD4Family.Complete;
{
  Pre: None.
  Post: This will complete the digestion of the data. Any remaining bytes
        (i.e. left over from an impartial block) will be padded in accordance
        with the MD4 family standard and transformed. The property HashValue
        will represent the message digest of the data that have been input.
}
var
  NumBytesNeeded: Integer;
  MessageLength: Int64;
  P: ^Byte;
  T: DWORD;
  PD: ^TChainingVar;
  I: Integer;
begin
  RequireIncompletion;
  MessageLength := BitsPerByte * (FBlockSize * FBlocksDigested + NumLastBlockBytes);
  P := PLastBlock;
  Inc(P, NumLastBlockBytes);
  P^ := $80; { Set the high bit. }
  Inc(P);
  Inc(NumLastBlockBytes);
  {
   # bytes needed = Block size - # bytes we already have -
                    8 bytes for the message length.
  }
  NumBytesNeeded := FBlockSize - NumLastBlockBytes - SizeOf(MessageLength);
  if NumBytesNeeded < 0 then begin
    { Not enough space to put the message length in this block. }
    FillChar(P^, FBlockSize - NumLastBlockBytes, 0);
    TransformBlocks(PLastBlock^, 1);
    { Put it in the next one. }
    NumBytesNeeded := FBlockSize - SizeOf(MessageLength);
    P := PLastBlock;
  end;
  FillChar(P^, NumBytesNeeded, 0);
  Inc(P, NumBytesNeeded);
  if FIsBigEndian then with TDoubleDWORD(MessageLength) do begin
    { Swap the bytes in MessageLength. }
    with TFourByte(L) do begin
      T := B1; B1 := B4; B4 := T;
      T := B2; B2 := B3; B3 := T;
    end;
    with TFourByte(H) do begin
      T := B1; B1 := B4; B4 := T;
      T := B2; B2 := B3; B3 := T;
    end;
    { Swap the DWORDs in MessageLength. }
    T := L;
    L := H;
    H := T;
  end;
  Move(MessageLength, P^, SizeOf(MessageLength));
  TransformBlocks(PLastBlock^, 1);
  Move(PChainingVars^, PDigest^, FDigestSize);
  if FIsBigEndian then begin
    { Swap 'em again. }
    PD := PDigest;
    for I := 1 to FDigestSize div SizeOf(PD^) do begin
      with TFourByte(PD^) do begin
        T := B1; B1 := B4; B4 := T;
        T := B2; B2 := B3; B3 := T;
      end;
      Inc(PD);
    end;
  end;
  inherited;
end;


{-----------------------------------TMD4---------------------------------------}


const
  MD4Z: array [0..47] of Byte = (
    0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
    0,  4,  8, 12,  1,  5,  9, 13,  2,  6, 10, 14,  3,  7, 11, 15,
    0,  8,  4, 12,  2, 10,  6, 14,  1,  9,  5, 13,  3, 11,  7, 15
  );

  MD4S: array [0..47] of Byte = (
    3,  7, 11, 19,  3,  7, 11, 19,  3,  7, 11, 19,  3,  7, 11, 19,
    3,  5,  9, 13,  3,  5,  9, 13,  3,  5,  9, 13,  3,  5,  9, 13,
    3,  9, 11, 15,  3,  9, 11, 15,  3,  9, 11, 15,  3,  9, 11, 15
  );

  MD4InitialChainingValues: TMD4ChainingVarArray = (
   $67452301, $efcdab89, $98badcfe, $10325476
  );

constructor TMD4.Create;
{
  Pre: None.
  Post: Returns an instance of class TMD4, capable of computing message
        digests using the MD4 algorithm.
}
begin
  inherited CreateInternal(MD4BlockSize, MD4DigestSize,
                           MD4InitialChainingValues, False);
end;

destructor TMD4.Destroy;
begin
  inherited;
end;

procedure TMD4.TransformBlocks(const Blocks; const BlockCount: Longint);
{
  Pre: Addr(Blocks) <> nil and Blocks is an exact integral number of blocks
       of size MD4BlockSize and BlockCount represents the number of blocks
       in Blocks.
  Post: Self will update its state to reflect the message digest after
        processing Blocks with the MD4 algorithm.
}
var
  I, J: Integer;
  T: TChainingVar;
  P: PMD4Block;
  A, B, C, D: TChainingVar;
begin
  P := Addr(Blocks);
  (*$IFNDEF PreDelphi3*)
    Assert(Assigned(P), 'TMD4.TransformBlocks: Addr(Blocks) = nil.');
    {
    Assert(BlockCount mod MD4BlockSize = 0,
           'TMD4.TransformBlocks: BlockCount mod MD4BlockSize <> 0.');
    }
  (*$ENDIF*)
  for I := 1 to BlockCount do begin
    { Initialize working variables. }
    A := PMD4ChainingVarArray(PChainingVars)^[mdA];
    B := PMD4ChainingVarArray(PChainingVars)^[mdB];
    C := PMD4ChainingVarArray(PChainingVars)^[mdC];
    D := PMD4ChainingVarArray(PChainingVars)^[mdD];
    { Round 1. }
    for J := 0 to 15 do begin
      T := A + ((B and C) or (not B and D)) + P^(.MD4Z[J].);
      A := D;
      D := C;
      C := B;
      B := CircularSHL(T, MD4S[J]);
    end;
    { Round 2. }
    for J := 16 to 31 do begin
      T := A + ((B and C) or (B and D) or (C and D)) + P^(.MD4Z[J].) + $5a827999;
      A := D;
      D := C;
      C := B;
      B := CircularSHL(T, MD4S[J]);
    end;
    { Round 3. }
    for J := 32 to 47 do begin
      T := A + (B xor C xor D) + P^(.MD4Z[J].) + $6ed9eba1;
      A := D;
      D := C;
      C := B;
      B := CircularSHL(T, MD4S[J]);
    end;
    Inc(P);
    { Update chaining values. }
    Inc(PMD4ChainingVarArray(PChainingVars)^[mdA], A);
    Inc(PMD4ChainingVarArray(PChainingVars)^[mdB], B);
    Inc(PMD4ChainingVarArray(PChainingVars)^[mdC], C);
    Inc(PMD4ChainingVarArray(PChainingVars)^[mdD], D);
  end;
  inherited;
end;

class function TMD4.AsString: string;
begin
  Result := 'MD4';
end;


{----------------------------------TMD5----------------------------------------}


const
  MD5Y: array [0..63] of DWORD = (
   { Round 1. }
   $d76aa478, $e8c7b756, $242070db, $c1bdceee, $f57c0faf, $4787c62a,
   $a8304613, $fd469501, $698098d8, $8b44f7af, $ffff5bb1, $895cd7be,
   $6b901122, $fd987193, $a679438e, $49b40821,
   { Round 2. }
   $f61e2562, $c040b340, $265e5a51, $e9b6c7aa, $d62f105d, $02441453,
   $d8a1e681, $e7d3fbc8, $21e1cde6, $c33707d6, $f4d50d87, $455a14ed,
   $a9e3e905, $fcefa3f8, $676f02d9, $8d2a4c8a,
   { Round 3. }
   $fffa3942, $8771f681, $6d9d6122, $fde5380c, $a4beea44, $4bdecfa9,
   $f6bb4b60, $bebfbc70, $289b7ec6, $eaa127fa, $d4ef3085, $04881d05,
   $d9d4d039, $e6db99e5, $1fa27cf8, $c4ac5665,
   { Round 4. }
   $f4292244, $432aff97, $ab9423a7, $fc93a039, $655b59c3, $8f0ccc92,
   $ffeff47d, $85845dd1, $6fa87e4f, $fe2ce6e0, $a3014314, $4e0811a1,
   $f7537e82, $bd3af235, $2ad7d2bb, $eb86d391
  );

  MD5Z: array [0..63] of Byte = (
    0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
    1,  6, 11,  0,  5, 10, 15,  4,  9, 14,  3,  8, 13,  2,  7, 12,
    5,  8, 11, 14,  1,  4,  7, 10, 13,  0,  3,  6,  9, 12, 15,  2,
    0,  7, 14,  5, 12,  3, 10,  1,  8, 15,  6, 13,  4, 11,  2,  9
  );

  MD5S: array [0..63] of Byte = (
    7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
    5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
    4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
    6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21
  );

  MD5InitialChainingValues: TMD5ChainingVarArray = (
   $01234567, $89abcdef, $fedcba98, $76543210
  );

constructor TMD5.Create;
{
  Pre: None.
  Post: Returns an instance of class TMD5, capable of computing message
        digests using the MD5 algorithm.
}
begin
  inherited CreateInternal(MD5BlockSize, MD5DigestSize,
                           MD4InitialChainingValues, False);
end;

destructor TMD5.Destroy;
begin
  inherited;
end;

procedure TMD5.TransformBlocks(const Blocks; const BlockCount: Longint);
{
  Pre: Addr(Blocks) <> nil and Blocks is an exact integral number of blocks
       of size MD5BlockSize and BlockCount represents the number of blocks
       in Blocks.
  Post: Self will update its state to reflect the message digest after
        processing Blocks with the MD5 algorithm.
}
var
  I, J: Integer;
  T: TChainingVar;
  P: PMD5Block;
  A, B, C, D: TChainingVar;
begin
  P := Addr(Blocks);
  (*$IFNDEF PreDelphi3*)
    Assert(Assigned(P), 'TMD5.TransformBlocks: Addr(Blocks) = nil.');
    {
    Assert(BlockCount mod MD5BlockSize = 0,
           'TMD5.TransformBlocks: BlockCount mod MD5BlockSize <> 0.');
    }
  (*$ENDIF*)
  for I := 1 to BlockCount do begin
    { Initialize working variables. }
    A := PMD5ChainingVarArray(PChainingVars)^[mdA];
    B := PMD5ChainingVarArray(PChainingVars)^[mdB];
    C := PMD5ChainingVarArray(PChainingVars)^[mdC];
    D := PMD5ChainingVarArray(PChainingVars)^[mdD];
    { Round 1. }
    for J := 0 to 15 do begin
      T := A + ((B and C) or (not B and D)) + P^(.MD5Z[J].) + MD5Y[J];
      A := D;
      D := C;
      C := B;
      Inc(B, CircularSHL(T, MD5S[J]));
    end;
    { Round 2. }
    for J := 16 to 31 do begin
      T := A + ((B and D) or (C and not D)) + P^(.MD5Z[J].) + MD5Y[J];
      A := D;
      D := C;
      C := B;
      Inc(B, CircularSHL(T, MD5S[J]));
    end;
    { Round 3. }
    for J := 32 to 47 do begin
      T := A + (B xor C xor D) + P^(.MD5Z[J].) + MD5Y[J];
      A := D;
      D := C;
      C := B;
      Inc(B, CircularSHL(T, MD5S[J]));
    end;
    { Round 4. }
    for J := 48 to 63 do begin
      T := A + (C xor (B or not D)) + P^(.MD5Z[J].) + MD5Y[J];
      A := D;
      D := C;
      C := B;
      Inc(B, CircularSHL(T, MD5S[J]));
    end;
    Inc(P);
    { Update chaining values. }
    Inc(PMD5ChainingVarArray(PChainingVars)^[mdA], A);
    Inc(PMD5ChainingVarArray(PChainingVars)^[mdB], B);
    Inc(PMD5ChainingVarArray(PChainingVars)^[mdC], C);
    Inc(PMD5ChainingVarArray(PChainingVars)^[mdD], D);
  end;
  inherited;
end;

class function TMD5.AsString: string;
begin
  Result := 'MD5';
end;

{----------------------------------TSHA1---------------------------------------}


const
  SHAInitialChainingValues: TSHAChainingVarArray = (
   $67452301, $efcdab89, $98badcfe, $10325476, $c3d2e1f0
  );


constructor TSHA1.Create;
{
  Pre: None.
  Post: Returns an instance of class TSHA1, capable of computing message
        digests using the SHA-1 algorithm.
}
begin
  inherited CreateInternal(SHABlockSize, SHADigestSize,
                           SHAInitialChainingValues, True);
end;

destructor TSHA1.Destroy;
begin
  inherited;
end;

procedure TSHA1.TransformBlocks(const Blocks; const BlockCount: Longint);
{
  Pre: Addr(Blocks) <> nil and Blocks is an exact integral number of blocks
       of size SHABlockSize and BlockCount represents the number of blocks
       in Blocks and Blocks represents little-endian data. (This routine will
       swap bytes so that they are big-endian, in compliance with the SHA-1
       standard.) 
  Post: Self will update its state to reflect the message digest after
        processing Blocks with the SHA-1 algorithm.
}
type
  PSHAExpandedBlock = ^TSHABlock;
  TSHAExpandedBlock = array [0..79] of DWORD;
var
  I, J: Integer;
  T: TChainingVar;
  P: PSHABlock;
  A, B, C, D, E: TChainingVar;
  X: TSHAExpandedBlock;
begin
  P := Addr(Blocks);
  (*$IFNDEF PreDelphi3*)
    Assert(Assigned(P), 'TSHA1.TransformBlocks: Addr(Blocks) = nil.');
    {
    Assert(BlockCount mod SHABlockSize = 0,
           'TSHA1.TransformBlocks: BlockCount mod SHABlockSize <> 0.');
    }
  (*$ENDIF*)
  for I := 1 to BlockCount do begin
    Move(P^, X, SizeOf(P^));
    for J := Low(TSHABlock) to High(TSHABlock) do begin
      {
       The SHA-1 standard is big-endian. Intel machines are little-endian.
       We have to swap the bytes in the incoming stream, and swap them again
       when we output to the hash value.
      }
      with TFourByte(X[J]) do begin
        T := B1; B1 := B4; B4 := T;
        T := B2; B2 := B3; B3 := T;
      end;
    end;
    for J := 16 to 79 do begin
      X[J] := CircularSHL(X[J - 3] xor X[J - 8] xor X[J - 14] xor X[J - 16], 1);
    end;
    { Initialize working variables. }
    A := PSHAChainingVarArray(PChainingVars)^[shaA];
    B := PSHAChainingVarArray(PChainingVars)^[shaB];
    C := PSHAChainingVarArray(PChainingVars)^[shaC];
    D := PSHAChainingVarArray(PChainingVars)^[shaD];
    E := PSHAChainingVarArray(PChainingVars)^[shaE];
    { Round 1. }
    for J := 0 to 19 do begin
      T := CircularSHL(A, 5) + ((B and C) or (not B and D)) + E + X[J] + $5a827999;
      E := D;
      D := C;
      C := CircularSHL(B, 30);
      B := A;
      A := T;
    end;
    { Round 2. }
    for J := 20 to 39 do begin
      T := CircularSHL(A, 5) + (B xor C xor D) + E + X[J] + $6ed9eba1;
      E := D;
      D := C;
      C := CircularSHL(B, 30);
      B := A;
      A := T;
    end;
    { Round 3. }
    for J := 40 to 59 do begin
      T := CircularSHL(A, 5) + (B and C or B and D or C and D) +
           E + X[J] + $8f1bbcdc;
      E := D;
      D := C;
      C := CircularSHL(B, 30);
      B := A;
      A := T;
    end;
    { Round 4. }
    for J := 60 to 79 do begin
      T := CircularSHL(A, 5) + (B xor C xor D) + E + X[J] + $ca62c1d6;
      E := D;
      D := C;
      C := CircularSHL(B, 30);
      B := A;
      A := T;
    end;
    Inc(P);
    { Update chaining values. }
    Inc(PSHAChainingVarArray(PChainingVars)^[shaA], A);
    Inc(PSHAChainingVarArray(PChainingVars)^[shaB], B);
    Inc(PSHAChainingVarArray(PChainingVars)^[shaC], C);
    Inc(PSHAChainingVarArray(PChainingVars)^[shaD], D);
    Inc(PSHAChainingVarArray(PChainingVars)^[shaE], E);
  end;
  inherited;
end;

class function TSHA1.AsString: string;
begin
  Result := 'SHA-1';
end;

{-------------------------------TRIPEMD160-------------------------------------}


const
  RIPEMD160InitialChainingValues: TRIPEMD160ChainingVarArray = (
   $67452301, $efcdab89, $98badcfe, $10325476, $c3d2e1f0
  );

  { Compression. }
  RIPEMD160ZL: array [0..79] of Byte = (
    0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
    7,  4, 13,  1, 10,  6, 15,  3, 12,  0,  9,  5,  2, 14, 11,  8,
    3, 10, 14,  4,  9, 15,  8,  1,  2,  7,  0,  6, 13, 11,  5, 12,
    1,  9, 11, 10,  0,  8, 12,  4, 13,  3,  7, 15, 14,  5,  6,  2,
    4,  0,  5,  9,  7, 12,  2, 10, 14,  1,  3,  8, 11,  6, 15, 13
  );

  RIPEMD160ZR: array [0..79] of Byte = (
    5, 14,  7,  0,  9,  2, 11,  4, 13,  6, 15,  8,  1, 10,  3, 12,
    6, 11,  3,  7,  0, 13,  5, 10, 14, 15,  8, 12,  4,  9,  1,  2,
   15,  5,  1,  3,  7, 14,  6,  9, 11,  8, 12,  2, 10,  0,  4, 13,
    8,  6,  4,  1,  3, 11, 15,  0,  5, 12,  2, 13,  9,  7, 10, 14,
   12, 15, 10,  4,  1,  5,  8,  7,  6,  2, 13, 14,  0,  3,  9, 11
  );

  { Word access. }
  RIPEMD160SL: array [0..79] of Byte = (
   11, 14, 15, 12,  5,  8,  7,  9, 11, 13, 14, 15,  6,  7,  9,  8,
    7,  6,  8, 13, 11,  9,  7, 15,  7, 12, 15,  9, 11,  7, 13, 12,
   11, 13,  6,  7, 14,  9, 13, 15, 14,  8, 13,  6,  5, 12,  7,  5,
   11, 12, 14, 15, 14, 15,  9,  8,  9, 14,  5,  6,  8,  6,  5, 12,
    9, 15,  5, 11,  6,  8, 13, 12,  5, 12, 13, 14, 11,  8,  5,  6
  );

  RIPEMD160SR: array [0..79] of Byte = (
    8,  9,  9, 11, 13, 15, 15,  5,  7,  7,  8, 11, 14, 14, 12,  6,
    9, 13, 15,  7, 12,  8,  9, 11,  7,  7, 12,  7,  6, 15, 13, 11,
    9,  7, 15, 11,  8,  6,  6, 14, 12, 13,  5, 14, 13, 13,  7,  5,
   15,  5,  8, 11, 14, 14,  6, 14,  6,  9, 12,  9, 12,  5, 15,  8,
    8,  5, 12,  9, 12,  5, 14,  6,  8, 13,  6,  5, 15, 13, 11, 11
  );

constructor TRIPEMD160.Create;
{
  Pre: None.
  Post: Returns an instance of class TRIPEMD160, capable of computing message
        digests using the RIPEMD-160 algorithm.
}
begin
  inherited CreateInternal(RIPEMD160BlockSize, RIPEMD160DigestSize,
                           RIPEMD160InitialChainingValues, False);
end;

destructor TRIPEMD160.Destroy;
begin
  inherited;
end;

procedure TRIPEMD160.TransformBlocks(const Blocks; const BlockCount: Longint);
{
  Pre: Addr(Blocks) <> nil and Blocks is an exact integral number of blocks
       of size SHABlockSize and BlockCount represents the number of blocks
       in Blocks and Blocks represents little-endian data. (This routine will
       swap bytes so that they are big-endian, in compliance with the SHA-1
       standard.)
  Post: Self will update its state to reflect the message digest after
        processing Blocks with the SHA-1 algorithm.
}
var
  I, J: Integer;
  T: TChainingVar;
  P: PRIPEMD160Block;
  AL, BL, CL, DL, EL: TChainingVar;
  AR, BR, CR, DR, ER: TChainingVar;
begin
  P := Addr(Blocks);
  (*$IFNDEF PreDelphi3*)
    Assert(Assigned(P), 'TSHA1.TransformBlocks: Addr(Blocks) = nil.');
    {
    Assert(BlockCount mod SHABlockSize = 0,
           'TSHA1.TransformBlocks: BlockCount mod SHABlockSize <> 0.');
    }
  (*$ENDIF*)
  for I := 1 to BlockCount do begin
    { Initialize working variables. }
    AL := PRIPEMD160ChainingVarArray(PChainingVars)^[ripA];
    BL := PRIPEMD160ChainingVarArray(PChainingVars)^[ripB];
    CL := PRIPEMD160ChainingVarArray(PChainingVars)^[ripC];
    DL := PRIPEMD160ChainingVarArray(PChainingVars)^[ripD];
    EL := PRIPEMD160ChainingVarArray(PChainingVars)^[ripE];
    AR := AL;
    BR := BL;
    CR := CL;
    DR := DL;
    ER := EL;
    { LEFT LINE. }
    { Round 1.}
    for J := 0 to 15 do begin
      { Left side. }
      T := EL + CircularSHL(AL + (BL xor CL xor DL) + P^(.RIPEMD160ZL[J].) +
                            $00000000, RIPEMD160SL[J]);
      AL := EL;
      EL := DL;
      DL := CircularSHL(CL, 10);
      CL := BL;
      BL := T;
      { Right side. }
      T := ER + CircularSHL(AR + (BR xor (CR or not DR)) + P^(.RIPEMD160ZR[J].) +
                            $50a28be6, RIPEMD160SR[J]);
      AR := ER;
      ER := DR;
      DR := CircularSHL(CR, 10);
      CR := BR;
      BR := T;
    end;
    { Round 2.}
    for J := 16 to 31 do begin
      { Left side. }
      T := EL + CircularSHL(AL + ((BL and CL) or (not BL and DL)) +
                            P^(.RIPEMD160ZL[J].) + $5a827999, RIPEMD160SL[J]);
      AL := EL;
      EL := DL;
      DL := CircularSHL(CL, 10);
      CL := BL;
      BL := T;
      { Right side. }
      T := ER + CircularSHL(AR + (BR and DR or CR and not DR) +
                            P^(.RIPEMD160ZR[J].) + $5c4dd124, RIPEMD160SR[J]);
      AR := ER;
      ER := DR;
      DR := CircularSHL(CR, 10);
      CR := BR;
      BR := T;
    end;
    { Round 3.}
    for J := 32 to 47 do begin
      { Left side. }
      T := EL + CircularSHL(AL + ((BL or not CL) xor DL) + P^(.RIPEMD160ZL[J].) +
                            $6ed9eba1, RIPEMD160SL[J]);
      AL := EL;
      EL := DL;
      DL := CircularSHL(CL, 10);
      CL := BL;
      BL := T;
      { Right side. }
      T := ER + CircularSHL(AR + ((BR or not CR) xor DR) + P^(.RIPEMD160ZR[J].) +
                            $6d703ef3, RIPEMD160SR[J]);
      AR := ER;
      ER := DR;
      DR := CircularSHL(CR, 10);
      CR := BR;
      BR := T;
    end;
    { Round 4.}
    for J := 48 to 63 do begin
      { Left side. }
      T := EL + CircularSHL(AL + (BL and DL or CL and not DL) +
                            P^(.RIPEMD160ZL[J].) + $8f1bbcdc, RIPEMD160SL[J]);
      AL := EL;
      EL := DL;
      DL := CircularSHL(CL, 10);
      CL := BL;
      BL := T;
      { Right side. }
      T := ER + CircularSHL(AR + (BR and CR or not BR and DR) +
                            P^(.RIPEMD160ZR[J].) + $7a6d76e9, RIPEMD160SR[J]);
      AR := ER;
      ER := DR;
      DR := CircularSHL(CR, 10);
      CR := BR;
      BR := T;
    end;
    { Round 5.}
    for J := 64 to 79 do begin
      { Left side. }
      T := EL + CircularSHL(AL + (BL xor (CL or not DL)) + P^(.RIPEMD160ZL[J].) +
                            $a953fd4e, RIPEMD160SL[J]);
      AL := EL;
      EL := DL;
      DL := CircularSHL(CL, 10);
      CL := BL;
      BL := T;
      { Right side. }
      T := ER + CircularSHL(AR + (BR xor CR xor DR) + P^(.RIPEMD160ZR[J].) +
                            $00000000, RIPEMD160SR[J]);
      AR := ER;
      ER := DR;
      DR := CircularSHL(CR, 10);
      CR := BR;
      BR := T;
    end;
    { Update chaining values. }
    T := PRIPEMD160ChainingVarArray(PChainingVars)^[ripB] + CL + DR;
    PRIPEMD160ChainingVarArray(PChainingVars)^[ripB] :=
     PRIPEMD160ChainingVarArray(PChainingVars)^[ripC] + DL + ER;
    PRIPEMD160ChainingVarArray(PChainingVars)^[ripC] :=
     PRIPEMD160ChainingVarArray(PChainingVars)^[ripD] + EL + AR;
    PRIPEMD160ChainingVarArray(PChainingVars)^[ripD] :=
     PRIPEMD160ChainingVarArray(PChainingVars)^[ripE] + AL + BR;
    PRIPEMD160ChainingVarArray(PChainingVars)^[ripE] :=
     PRIPEMD160ChainingVarArray(PChainingVars)^[ripA] + BL + CR;
    PRIPEMD160ChainingVarArray(PChainingVars)^[ripA] := T;
    Inc(P);
  end;
  inherited;
end;

class function TRIPEMD160.AsString: string;
begin
  Result := 'RIPEMD-160';
end;

end.
