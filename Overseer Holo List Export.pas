{
  Exports OverSeer Holotape List formids to JSON
  Intended for Fallout 76
}
unit userscript;

function Initialize: integer;
var
  sl: TStringList;
  f, list, listitems, e : IInterface;
  fname, formid, row: string;
  i: integer;
begin
 fname := ProgramPath + 'OverseerHoloIDs.json'; //Filepath and filename
 f := FileByIndex(0); //Main ESM
 list := MainRecordByEditorID(GroupBySignature(f, 'FLST'), 'MQ_Overseer_HolotapesList');
 listitems := ElementByName(list,'FormIDs');
 sl := TStringList.Create;
 sl.Add('[');
 for i := 0 to ElementCount(listitems) - 1 do begin
	e := ElementByIndex(listitems,i);
	formid := IntToHex(FixedFormID(LinksTo(e)), 8);
	row := '{"id":"'+formid+'","name":"'+GetElementEditValues(LinksTo(e), 'FULL - Name')+'"}';
	if (i <> ElementCount(listitems)-1) then row := row + ','; //skip , on last record
	sl.Add(row);
 end;
 AddMessage('Found ' + IntToStr(ElementCount(listitems)) + ' List Items');
 sl.Add(']');
 sl.SaveToFile(fname);
 sl.Free;
 Result := 1;
end;


end.