program ResCollectionEditor;

uses
  Forms,
  MainFrm in 'MainFrm.pas' {MainForm},
  EditFrm in 'EditFrm.pas' {EditForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TEditForm, EditForm);
  Application.Run;
end.
