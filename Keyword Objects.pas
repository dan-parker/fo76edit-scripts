{
  Exports Objects with specific keyword to JSON
  Intended for Fallout 76
}
unit userscript;

function Initialize: integer;
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


end.