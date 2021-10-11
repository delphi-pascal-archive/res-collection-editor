unit ThResCol;

{ TThResCollection = collection dynamique de ressources
  dernière modification :  5 novembre 2009
  auteur : ThWilliam }

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics;

type

  TThResCollection = class;

  TThResItem = class(TCollectionItem)
  private
    FCollection: TThResCollection;
    FResName: string;
    FTag: integer;
    FResString: string;
    FResType: word;
    FResBitmap: TBitmap;
    FResStream: TMemoryStream;
    function GetResStream: TMemoryStream;
    procedure SetResName(AResName: string);
  public
    constructor Create(Collection : TCollection); override;
    destructor Destroy; override;
    property ResName: string read FResName write SetResName;
    property Tag: integer read FTag write FTag;
    property ResString: string read FResString write FResString;
    property ResBitmap: TBitmap read FResBitmap;
    property ResType: word read FResType;
    property ResStream: TMemoryStream read GetResStream;
    procedure SetResBitmap(ABitmap: TBitmap); overload;
    procedure SetResBitmap(const FileName: string); overload;
    procedure SetResStream(AResType: word; S: TStream); overload;
    procedure SetResStream(AResType: word; const FileName: string); overload;
    function HasBitmap: boolean;
    function HasStream: boolean;
    procedure ClearResourceData;
  end;

  TThResCollection = class(TCollection)
  private
    function GetItem(Index: Integer): TThResItem;
    procedure SetItem(Index: Integer; Value: TThResItem);
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: Integer]: TThResItem read GetItem write SetItem; default;
    function FindRes(AResName: string): integer; overload;
    function FindRes(ATag: integer): integer; overload;
    function LoadRes(AResName: string): TThResItem;
    function AddRes(const AResName: string): TThResItem;
    procedure DeleteRes(Index: integer);
    procedure SaveToFile(AFileName: string);
    procedure LoadFromFile(AFileName: string);
  end;

const
  RES_NO = 0;
  RES_BITMAP = 1;
  RES_JPEG = 2;
  RES_ICON = 3;
  RES_TEXT = 4;
  RES_FORMATEDTEXT = 5;
  RES_WAVE = 6;
  // en ajouter d'autres ici --> 99
  // adapter en cas d'ajout la founction ResTypeDescription
  RES_USER = 100;

function ResTypeDescription(AResType: word): string;


implementation

type

  TExFileStream = class(TFileStream)
  private
  public
     procedure WriteString(const S: string);
     function ReadString: string;
     procedure WriteWord(I: Word);
     function ReadWord: word;
     procedure WriteInteger(I: integer);
     function ReadInteger: integer;
     procedure WriteInt64(I: Int64);
     function ReadInt64: Int64;
     procedure WriteStream(S: TStream);
     procedure ReadStream(S: TStream);
     procedure WriteBitmap(ABitmap: TBitmap);
     procedure ReadBitmap(ABitmap: TBitmap);
  end;

const
  FILEHEADER: string = '$RESCOL$'; // header du fichier

resourcestring
  E_NOFILE = 'Le fichier "%s" est introuvable';
  E_BADFILE = 'Le fichier "%s" n''est pas un fichier ressources correct';
  E_READFILE = 'Erreur de lecture du fichier "%s"';
  E_WRITEFILE = 'Erreur d''écriture du fichier "%s"';
  E_BADBITMAP = 'Fichier Bitmap incorrect : "%s"';
  E_NORES = 'Ressource "%s" non trouvée';

function ResTypeDescription(AResType: word): string;
begin
  case AResType of
    RES_NO: Result:= 'Aucune ressource';
    RES_BITMAP: Result:= 'Bitmap';
    RES_JPEG: Result:= 'Image Jpeg';
    RES_ICON: Result:= 'Icône';
    RES_TEXT: Result:= 'Texte brut';
    RES_FORMATEDTEXT: Result:= 'Texte formaté';
    RES_WAVE: Result:= 'Son wave';
    else Result:= IntToStr(AResType) + ' : non défini';
  end;
end;

{TExFileStream}

procedure TExFileStream.WriteString(const S: string);
var
  L: Integer;
begin
  L := Length(S);
  Write(L, SizeOf(integer));
  if L > 0 then
    WriteBuffer(S[1], L);
end;

function TExFileStream.ReadString: string;
var
  L: Integer;
begin
  Read(L, SizeOf(integer));
  SetLength(Result, L);
  if L > 0 then
    ReadBuffer(Result[1], L);
end;

procedure TExFileStream.WriteWord(I: Word);
begin
  WriteBuffer(I, SizeOf(Word));
end;

function TExFileStream.ReadWord: word;
begin
  ReadBuffer(Result, SizeOf(Word));
end;

procedure TExFileStream.WriteInteger(I: integer);
begin
  WriteBuffer(I, SizeOf(integer));
end;

function TExFileStream.ReadInteger: integer;
begin
  ReadBuffer(Result, SizeOf(integer));
end;

procedure TExFileStream.WriteInt64(I: Int64);
begin
  WriteBuffer(I, SizeOf(Int64));
end;

function TExFileStream.ReadInt64: Int64;
begin
  ReadBuffer(Result, SizeOf(Int64));
end;

procedure TExFileStream.WriteStream(S: TStream);
var
  Buffer: int64;
begin
  Buffer:= S.Size;
  WriteInt64(Buffer);
  if Buffer > 0 then
  begin
    S.Position:= 0;
    CopyFrom(S, Buffer);
  end;
end;

procedure TExFileStream.ReadStream(S: TStream);
var
  Buffer: int64;
begin
  Buffer:= ReadInt64;
  if Buffer > 0 then
  begin
     S.Position:= 0;
     S.CopyFrom(Self, Buffer);
  end;
end;

procedure TExFileStream.WriteBitmap(ABitmap: TBitmap);
var
  S: TMemoryStream;
  Buffer: int64;
begin
   S:= TMemoryStream.Create;
   try
     ABitmap.SaveToStream(S);
     Buffer:= S.Size;
     WriteInt64(Buffer);
     if Buffer > 0 then
     begin
        S.Position:= 0;
        CopyFrom(S, Buffer);
     end;
   finally
     FreeAndNil(S);
   end;
end;

procedure TExFileStream.ReadBitmap(ABitmap: TBitmap);
var
  S: TMemoryStream;
  Buffer: int64;
begin
   Buffer:= ReadInt64;
   if Buffer > 0 then
   begin
      S:= TMemoryStream.Create;
      try
         S.CopyFrom(self, Buffer);
         S.Position:= 0;
         ABitmap.LoadFromStream(S);
      finally
         FreeAndNil(S);
      end;
   end;
end;

{TThResItem}

constructor TThResItem.Create(Collection : TCollection);
begin
  inherited Create(Collection);
  FCollection:= Collection as TThResCollection;
  FResName:= '';
  FTag:= -1;
  FResString:= '';
  FResType:= RES_NO;
  FResBitmap:= nil;
  FResStream:= nil;
end;

destructor TThResItem.Destroy;
begin
  ClearResourceData;
  inherited Destroy;
end;

procedure TThResItem.ClearResourceData;
begin
  if FResBitmap <> nil then FreeAndNil(FResBitmap);
  if FResStream <> nil then FreeAndNil(FResStream);
  FResType:= RES_NO;
end;

procedure TThResItem.SetResName(AResName: string);
begin
  FResName:= AnsiUpperCase(AResName);
end;

procedure TThResItem.SetResBitmap(ABitmap: TBitmap);
begin
  ClearResourceData;
  FResBitmap:= TBitmap.Create;
  FResBitmap.Assign(ABitmap);
  FResType:= RES_BITMAP;
end;

procedure TThResItem.SetResBitmap(const FileName: string);
begin
  ClearResourceData;
  FResBitmap:= TBitmap.Create;
  try
     FResBitmap.LoadFromFile(FileName);
     FResType:= RES_BITMAP;
  except
     FResType:= RES_NO;
     FreeAndNil(FResBitmap);
     raise Exception.Create(Format(E_BADBITMAP, [FileName]));
  end;
end;

function TThResItem.GetResStream: TMemoryStream;
begin
  if FResStream <> nil then
  begin
    FResStream.Position:= 0;
    Result:= FResStream;
  end
  else Result:= nil;
end;

procedure TThResItem.SetResStream(AResType: word; S: TStream);
begin
   if S.Size > 0 then
   begin
     ClearResourceData;
     FResType:= AResType;
     FResStream:= TMemoryStream.Create;
     FResStream.LoadFromStream(S);
   end;
end;

procedure TThResItem.SetResStream(AResType: word; const FileName: string);
var
  FS: TFileStream;
begin
  FS:= TFileStream.Create(FileName, fmOpenRead);
  try
     SetResStream(AResType, FS);
  finally
     FreeAndNil(FS);
  end;
end;

function TThResItem.HasBitmap: boolean;
begin
  Result:= ((FResBitmap <> nil) and (FResBitmap.Width > 0) and (FResBitmap.Height > 0));
end;

function TThResItem.HasStream: boolean;
begin
  Result:= ((FResStream <> nil) and (FResStream.Size > 0));
end;


{TThResCollection}

constructor TThResCollection.Create;
begin
   inherited Create(TThResItem);
end;

destructor TThResCollection.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TThResCollection.GetItem(Index: Integer): TThResItem;
begin
  Result := TThResItem(inherited GetItem(Index));
end;

procedure TThResCollection.SetItem(Index: Integer; Value: TThResItem);
begin
  inherited SetItem(Index, Value);
end;

function TThResCollection.FindRes(AResName: string): integer;
var
  I: integer;
begin
  Result:= -1;
  AResName:= AnsiUpperCase(AResName);
  for I:= 0 to Count - 1 do
    if GetItem(I).ResName = AResName then
    begin
       Result:= I;
       Break;
    end;
end;

function TThResCollection.FindRes(ATag: integer): integer;
var
  I: integer;
begin
  Result:= -1;
  for I:= 0 to Count - 1 do
    if GetItem(I).Tag = ATag then
    begin
       Result:= I;
       Break;
    end;
end;

function TThResCollection.LoadRes(AResName: string): TThResItem;
var
  I: integer;
begin
  I:= FindRes(AResName);
  if I >= 0 then Result:= GetItem(I)
  else
    raise Exception.Create(Format(E_NORES, [AResName]));
end;

function TThResCollection.AddRes(const AResName: string): TThResItem;
begin
  Result:= inherited Add as TThResItem;
  Result.ResName:= AResName;
end;

procedure TThResCollection.DeleteRes(Index: integer);
begin
  if (Index >= 0) and (Index < Count) then
    inherited Delete(Index);
end;

procedure TThResCollection.SaveToFile(AFileName: string);
var
  FS: TExFileStream;
  I: integer;
begin
  FS:= TExFileStream.Create(AFileName, fmCreate or fmOpenWrite);
  try
     FS.Write(FILEHEADER[1], Length(FILEHEADER));
     for I:= 0 to Count - 1 do
        with GetItem(I) do
        begin
          FS.WriteString(ResName);
          FS.WriteInteger(Tag);
          FS.WriteString(ResString);
          FS.WriteWord(ResType);
          if HasBitmap then
             FS.WriteBitmap(ResBitmap)
          else if HasStream then
             FS.WriteStream(ResStream);
        end;
     FS.Free;
  except
     FS.Free;
     raise Exception.Create(Format(E_WRITEFILE, [AFileName]));
  end;
end;

procedure TThResCollection.LoadFromFile(AFileName: string);
var
  FS: TExFileStream;
  FSSize: int64;
  FHeader: string;
begin
   Clear;
   try
     FS:= TExFileStream.Create(AFileName, fmOpenRead);
   except
     raise Exception.Create(Format(E_NOFILE, [AFileName]));
   end;
   FSSize:= FS.Size;
   SetLength(FHeader, Length(FILEHEADER));
   FS.Read(FHeader[1], Length(FILEHEADER));
   if FHeader <> FILEHEADER then
   begin
     FreeAndNil(FS);
     raise Exception.Create(Format(E_BADFILE, [AFileName]));
   end;
   try
      while FS.Position < FSSize do
      begin
         with inherited Add as TThResItem do
         begin
            ResName:= FS.ReadString;
            Tag:= FS.ReadInteger;
            ResString:= FS.ReadString;
            FResType:= FS.ReadWord;
            if ResType = RES_BITMAP then
            begin
               if FResBitmap = nil then FResBitmap:= TBitmap.Create;
               FS.ReadBitmap(FResBitmap);
            end
            else
            if ResType > RES_NO then
            begin
               if FResStream = nil then FResStream:= TMemoryStream.Create;
               FS.ReadStream(FResStream);
            end;
         end;
      end;
      FreeAndNil(FS);
   except
      Clear;
      FreeAndNil(FS);
      raise Exception.Create(Format(E_READFILE, [AFileName]));
   end;
end;

end.
