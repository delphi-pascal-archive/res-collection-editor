unit EditFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TEditForm = class(TForm)
    EditName: TEdit;
    Label1: TLabel;
    EditResString: TEdit;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    OpenDialog1: TOpenDialog;
    CancelBtn: TButton;
    ComboBox1: TComboBox;
    Label4: TLabel;
    OkWithResBtn: TButton;
    OkWithOutResBtn: TButton;
    Label3: TLabel;
    EditTag: TEdit;
    Label5: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OkWithOutResBtnClick(Sender: TObject);
    procedure OkWithResBtnClick(Sender: TObject);
    procedure EditTagExit(Sender: TObject);
  private
    { Déclarations privées }
    function OkResName: boolean;
  public
    { Déclarations publiques }
    CurrentRes: integer;
  end;


var
  EditForm: TEditForm;

implementation

uses MainFrm, ThResCol;


{$R *.dfm}

function TEditForm.OkResName: boolean;
var
  I: integer;
begin
   if EditName.Text = '' then raise Exception.Create('Le nom de la ressource ne peut être vide');
   I:= ResCol.FindRes(EditName.Text);
   if not((I <0) or (I = CurrentRes)) then
     raise Exception.Create('Le nom de la ressource existe déjà');
   Result:= true;
end;

procedure TEditForm.FormCreate(Sender: TObject);
var
  I: integer;
begin
   for I:= 0 to 999 do
     ComboBox1.Items.Add(ResTypeDescription(I));
end;

procedure TEditForm.FormShow(Sender: TObject);
begin
   if CurrentRes = -1 then // mode ajout
   begin
     ComboBox1.ItemIndex:= RES_NO;
     EditName.Text:= '';
     EditTag.Text:= '-1';
     EditResString.Text:= '';
     OkWithOutResBtn.Caption:= 'Pour ne pas ajouter de ressource, cliquer ici';
   end
   else   // mode modification
   with ResCol[CurrentRes] do
   begin
     EditName.text:= ResName;
     EditTag.Text:= IntToStr(Tag);
     EditResString.Text:= ResString;
     ComboBox1.ItemIndex:= ResType;
     OkWithOutResBtn.Caption:= 'Pour ne pas modifier la ressource existante, cliquer ici';
   end;
end;

procedure TEditForm.OkWithOutResBtnClick(Sender: TObject);
var
  Res: TThResItem;
begin
  if not OkResName then Exit;
  if CurrentRes >= 0 then
  begin
     Res:= ResCol[CurrentRes];
     Res.ResName:= EditName.Text;
  end
  else Res:= ResCol.AddRes(EditName.Text);
  Res.Tag:= StrToInt(EditTag.Text);
  Res.ResString:= EditResString.Text;
  Modified:= true;
  ModalResult:= mrOk;
end;

procedure TEditForm.OkWithResBtnClick(Sender: TObject);
var
  Res: TThResItem;
begin
  if not OkResName then Exit;
  if CurrentRes >= 0 then
  begin
     Res:= ResCol[CurrentRes];
     Res.ResName:= EditName.Text;
  end
  else Res:= ResCol.AddRes(EditName.Text);
  Res.Tag:= StrToInt(EditTag.Text);
  Res.ResString:= EditResString.Text;
  Modified:= true;
  if ComBoBox1.ItemIndex = RES_NO then
     Res.ClearResourceData
  else
  with OpenDialog1 do
     if Execute then
     begin
        if ComboBox1.ItemIndex = RES_BITMAP then
          Res.SetResBitmap(FileName)
        else Res.SetResStream(ComboBox1.ItemIndex, FileName);
     end;
  ModalResult:= mrOk;
end;

procedure TEditForm.EditTagExit(Sender: TObject);
begin
   try
     StrToInt(EditTag.Text);
   except
     raise Exception.Create('Tag : valeur numérique incorrecte.');
   end;  
end;

end.
