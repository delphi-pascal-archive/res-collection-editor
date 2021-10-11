unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, jpeg, Grids, Menus,
  mmSystem, ThresCol;


type
  TMainForm = class(TForm)
    OpenDialog1: TOpenDialog;
    AddResBtn: TButton;
    ResGrid: TDrawGrid;
    DeleteResBtn: TButton;
    ModifyResBtn: TButton;
    MoveBtn: TButton;
    MainMenu1: TMainMenu;
    Fichier1: TMenuItem;
    MIOpenResFile: TMenuItem;
    MISaveResFile: TMenuItem;
    MIQuit: TMenuItem;
    GroupBox1: TGroupBox;
    Image1: TImage;
    RichEdit1: TRichEdit;
    StopSoundBtn: TButton;
    SaveDialog1: TSaveDialog;
    MINewFile: TMenuItem;
    N1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AddResBtnClick(Sender: TObject);
    procedure ResGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure DeleteResBtnClick(Sender: TObject);
    procedure ModifyResBtnClick(Sender: TObject);
    procedure MoveBtnClick(Sender: TObject);
    procedure MIOpenResFileClick(Sender: TObject);
    procedure MISaveResFileClick(Sender: TObject);
    procedure MIQuitClick(Sender: TObject);
    procedure StopSoundBtnClick(Sender: TObject);
    procedure ResGridDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MINewFileClick(Sender: TObject);
  private
    { Déclarations privées }
    ResFileName: string;
    procedure SetResFileName(S: string);
    procedure AdjustGridRows;
    function ReturnResId(var I: integer): boolean;
    procedure SaveResMessage;
  public
    { Déclarations publiques }
  end;

var
  MainForm: TMainForm;
  ResCol: TThResCollection;
  Modified: boolean;

implementation

uses EditFrm;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
   ResCol:= TThResCollection.Create;
   Modified:= false;
   SetResFileName('');
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   ResCol.Free;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   SaveResMessage;
end;

procedure TMainForm.SetResFileName(S: string);
begin
  ResFileName:= S;
  if ResFileName = '' then
     Caption:= 'Editeur ResCollection : nouveau fichier'
  else
     Caption:= 'Editeur ResCollection : ' + ExtractFileName(ResFileName);
end;

procedure TMainForm.AdjustGridRows;
begin
  with ResGrid do
    begin
      if ResCol.Count = 0 then RowCount:= FixedRows + 1
      else
         RowCount:= ResCol.Count + FixedRows;
      Refresh;
    end;
end;

function TMainForm.ReturnResId(var I: integer): boolean;
begin
   I:= Resgrid.Row - ResGrid.FixedRows;
   Result:= ((I >= 0) and (I < ResCol.Count));
end;

procedure TMainForm.SaveResMessage;
begin
  if Modified then
  begin
    if MessageDlg('Voulez-vous sauvegarder les modifications ?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        MISaveResFileClick(nil)
    else Modified:= false;
  end;      
end;

procedure TMainForm.AddResBtnClick(Sender: TObject);
begin
  with EditForm do
  begin
    CurrentRes:= -1;
    ShowModal;
    if ModalResult = mrOk then Modified:= true;
    AdjustGridRows;
  end;
end;

procedure TMainForm.ResGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  S: string;
  I: integer;
begin
   Rect.Left:= Rect.Left + 5;
   if ARow < ResGrid.FixedRows then  // ligne fixe
   begin
     case ACol of
       0: S:= 'Id';
       1: S:= 'Nom';
       2: S:= 'Tag';
       3: S:= 'ResourceString';
       4: S:= 'Type ressource'
     end;
      Drawtext(ResGrid.Canvas.Handle, PChar(S), -1, Rect, DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
      Exit;
   end;
   try
     if ResCol.Count > 0 then
     begin
       I:= ARow - ResGrid.FixedRows;
       case ACol of
         0: S:= IntToStr(ResCol[I].Index);
         1: S:= ResCol[I].ResName;
         2: S:= IntToStr(ResCol[I].Tag);
         3: S:= ResCol[I].ResString;
         4: begin
               S:= ResTypeDescription(ResCol[I].ResType);
               if S = '' then S:= 'Non définie: ' + IntToStr(ResCol[I].ResType);
             end;
       end;
       Drawtext(ResGrid.Canvas.Handle, PChar(S), -1, Rect, DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
     end;
   except
   end;
end;

procedure TMainForm.DeleteResBtnClick(Sender: TObject);
var
  I: integer;
begin
  if not(ReturnResId(I)) then Exit;
  if MessageDlg('Voulez-vous supprimer la ressource "' + ResCol[I].ResName + '" ?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    ResCol.DeleteRes(I);
    Modified:= true;
    AdjustGridRows;
  end;
end;

procedure TMainForm.ModifyResBtnClick(Sender: TObject);
var
  I: integer;
begin
  if not(ReturnResId(I)) then Exit;
  with EditForm do
  begin
    CurrentRes:= I;
    ShowModal;
    if ModalResult = mrOk then Modified:= true;
    AdjustGridRows;
  end;
end;

procedure TMainForm.MoveBtnClick(Sender: TObject);
 var
  NewValue: string;
  Id, I: integer;
begin
  if not(ReturnResId(I)) then Exit;
  NewValue := '';
  if InputQuery('Déplacement ressource ' + IntToStr(I), 'Déplacer à l''index : ', NewValue) then
  try
     Id:= StrToInt(NewValue);
     if Id < 0 then Id:= 0
       else if Id >= ResCol.Count then Id:= ResCol.Count - 1;
     ResCol[I].Index:= Id;
     AdjustGridRows;
     Modified:= true;
  except
     raise;
  end;
end;

procedure TMainForm.MIOpenResFileClick(Sender: TObject);
begin
  SaveResMessage;
  with OpenDialog1 do
    if Execute then
    begin
      ResCol.Clear;
      Modified:= false;
      SetResFileName(FileName);
      try
        ResCol.LoadFromFile(FileName);
      finally
        AdjustGridRows;
      end;
    end;
end;

procedure TMainForm.MISaveResFileClick(Sender: TObject);
begin
   with SaveDialog1 do
   begin
     FileName:= ResFileName;
     if Execute then
     try
       ResCol.SaveToFile(FileName);
       Modified:= false;
       SetResFileName(FileName);
     except
       raise;
     end;
   end;
end;

procedure TMainForm.MINewFileClick(Sender: TObject);
begin
   SaveResMessage;
   ResCol.Clear;
   SetResFileName('');
   AdjustGridRows;
end;

procedure TMainForm.MIQuitClick(Sender: TObject);
begin
   Close;
end;

procedure TMainForm.StopSoundBtnClick(Sender: TObject);
begin
  PlaySound('', 0, SND_MEMORY or SND_PURGE);
  StopSoundBtn.Visible:= false;
end;

procedure TMainForm.ResGridDblClick(Sender: TObject);
var
  I: integer;
  Jpg: TJpegImage;
begin
  if not(ReturnResId(I)) then Exit;
  RichEdit1.Visible:= false;
  RichEdit1.Clear;
  Image1.Visible:= false;
  StopSoundBtn.Visible:= false;
  case ResCol[I].ResType of
    RES_BITMAP : with ResCol[I] do
                   if HasBitmap then
                   begin
                      Image1.Stretch:= ((ResBitmap.Width > Image1.Width) or (ResBitmap.Height > Image1.Height));
                      Image1.Picture.Bitmap.Assign(ResBitmap);
                      Image1.Visible:= true;
                   end;
    RES_JPEG : if ResCol[I].HasStream then
               begin
                  Jpg:= TJpegImage.Create;
                  try
                     Jpg.LoadFromStream(ResCol[I].ResStream);
                     Image1.Stretch:= ((Jpg.Width > Image1.Width) or (Jpg.Height > Image1.Height));
                     Image1.Picture.Assign(Jpg);
                     Image1.Visible:= true;
                  finally
                     Jpg.Free;
                  end;
               end;
    RES_TEXT, RES_FORMATEDTEXT : with ResCol[I] do
                                   if HasStream then
                                   begin
                                      RichEdit1.Lines.LoadFromStream(ResStream);
                                      RichEdit1.Visible:= true;
                                   end;
    RES_WAVE : with ResCol[I] do
                 if HasStream then
                 begin
                    StopSoundBtn.Visible:= true;
                    PlaySound(ResStream.Memory, 0, SND_MEMORY or SND_ASYNC);
                 end;
    RES_ICON : with ResCol[I] do
                 if HasStream then
                 begin
                    Image1.Picture.Icon.LoadFromStream(ResStream);
                    Image1.Stretch:= false;
                    Image1.Visible:= true;
                 end;
    end;
                 
end;


end.
