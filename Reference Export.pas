{
  Exports Reference Objects with GUI selector to JSON
  Intended for Fallout 76
}
unit userscript;

var
frmMain: TForm;
cmbKeyword: TComboBox;

procedure ExportToFile;
var
  f, Keyword, e : IInterface;
  sl: TStringList;
  i: integer;
  keyname, fname, formid, sig, row: string;
begin
 keyname := cmbKeyword.Text;
 fname := ProgramPath +  keyname + '.json'; //Filepath and filename
 f := FileByIndex(0); //Main ESM
 Keyword := MainRecordByEditorID(GroupBySignature(f, 'KYWD'), keyname);
 sl := TStringList.Create;
 sl.Add('[');
 for i := 0 to ReferencedByCount(Keyword) - 1 do begin
	e := ReferencedByIndex(Keyword,i);
	formid := IntToHex(FixedFormID(e), 8);
	sig := Signature(e);
	row := '{"id":"'+formid+'","name":"'+GetElementEditValues(e, 'FULL - Name')+'",';
	row := row + '"edid":"'+GetElementEditValues(e, 'EDID')+'",';
	row := row + '"sig":"'+sig+'"}';
	if (i <> ReferencedByCount(Keyword)-1) then row := row + ','; //skip , on last record
	sl.Add(row);
 end;
 AddMessage('Found ' + IntToStr(ReferencedByCount(Keyword)) + ' List Items');
 sl.Add(']');
 sl.SaveToFile(fname);
 sl.Free;


end;

// resize event for main form
procedure frmMainFormResize(Sender: TObject);
var
  a: integer;
begin
 end;

//============================================================================
// activate event for main form
procedure frmMainFormActivate(Sender: TObject);
begin
end;
//============================================================================
function CreateLabel(aForm: TForm; aText: string; aLeft, aTop: integer): TLabel;
begin
  Result := TLabel.Create(aForm);
  Result.Parent := aForm;
  Result.Caption := aText;
  Result.Left := aLeft; Result.Top := aTop;
end;

//============================================================================
function CreateComboList(aForm: TForm; aLeft, aTop, aWidth: integer): TComboBox;
begin
  Result := TComboBox.Create(aForm);
  Result.Parent := aForm;
  Result.Style := csDropDownList; Result.DropDownCount := 20;
  Result.Left := aLeft; Result.Top := aTop; Result.Width := aWidth;
end;


procedure GUI;
var
  btn: TButton;
  i, j: integer;
  sl: TStringList;
  KYWDs, KYWD: IInterface;
begin
  frmMain := TForm.Create(nil);
  frmMain.Caption := wbAppName + 'Selector';
  frmMain.Width := 300;
  frmMain.Height := 150;
  frmMain.Position := poMainFormCenter;
  frmMain.PopupMode := pmAuto;
  frmMain.KeyPreview := True;
  frmMain.OnResize := frmMainFormResize;
  frmMain.OnActivate := frmMainFormActivate;

  CreateLabel(frmMain, 'Keywords', 16, 13);
  cmbKeyword := CreateComboList(frmMain, 16, 32, 228);
  cmbKeyword.AutoComplete := True;
  btn := TButton.Create(frmMain); btn.Parent := frmMain; btn.Left := 92; btn.Top := 74; btn.Width := 73;
  btn.Caption := 'Cancel'; btn.ModalResult := mrCancel;
  btn := TButton.Create(frmMain); btn.Parent := frmMain; btn.Left := 171; btn.Top := 74; btn.Width := 73;
  btn.Caption := 'OK'; btn.ModalResult := mrOk; btn.OnClick := ExportToFile;

  // filling list of worldspaces
  sl := TStringList.Create;
  try
    sl.Duplicates := dupIgnore;
    sl.Sorted := True;
    for i := Pred(FileCount) downto 0 do begin
      KYWDs := GroupBySignature(FileByIndex(i), 'KYWD');
      for j := 0 to Pred(ElementCount(KYWDs)) do begin
        KYWD := ElementByIndex(KYWDs, j);
        sl.AddObject(EditorID(KYWD), MasterOrSelf(KYWD));
      end;
    end;
    cmbKeyword.Items.Assign(sl);
  finally
    sl.Free;
  end;

end;

function Initializey: integer;
var
  sl: TStringList;
  f, Keyword, e : IInterface;
  fname, formid, sig, row: string;
  i: integer;
begin
 fname := ProgramPath + 'Keyword.json'; //Filepath and filename
 f := FileByIndex(0); //Main ESM
 Keyword := MainRecordByEditorID(GroupBySignature(f, 'KYWD'), 'ClothingTypeCostume');
 sl := TStringList.Create;
 sl.Add('[');
 for i := 0 to ReferencedByCount(Keyword) - 1 do begin
	e := ReferencedByIndex(Keyword,i);
	formid := IntToHex(FixedFormID(e), 8);
	sig := Signature(e);
	row := '{"id":"'+formid+'","name":"'+GetElementEditValues(e, 'FULL - Name')+'",';
	row := row + '"edid":"'+GetElementEditValues(e, 'EDID')+'",';
	row := row + '"sig":"'+sig+'"}';
	if (i <> ReferencedByCount(Keyword)-1) then row := row + ','; //skip , on last record
	sl.Add(row);
 end;
 AddMessage('Found ' + IntToStr(ReferencedByCount(Keyword)) + ' List Items');
 sl.Add(']');
 sl.SaveToFile(fname);
 sl.Free;
 Result := 1;
end;

function Initialize: integer;
begin
  try
    GUI;
    frmMain.ShowModal;
  finally
    frmMain.Free;
  end;
  Result := 1;
end;

end.