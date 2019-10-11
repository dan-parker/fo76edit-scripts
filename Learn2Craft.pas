{
  Exports Armor and Weapon crafting unlock info to JSON
  Intended for Fallout 76
}
unit userscript;

function Initialize: integer;
var
  sl: TStringList;
  f, Items, e, ObjID, ObjID2, ChanceID : IInterface;
  fname, formid, sig, ChanceLevel, LearnMethod, LearnFrom, LearnPerc, row, Last: string;
  i, rowcount: integer;
begin
 fname := ProgramPath + 'Learn.json'; //Filepath and filename
 f := FileByIndex(0); //Main ESM
 Items := GroupBySignature(f, 'COBJ');
 sl := TStringList.Create;
 sl.Add('[');
 sl.Sorted := True;
 for i := 0 to ElementCount(Items) - 1 do begin
	e := ElementByIndex(Items,i);
	formid := IntToHex(FixedFormID(e), 8);
	ChanceID := LinksTo(ElementByName(e, 'LRNC - Learn Chance'));
	LearnPerc := GetElementEditValues(ChanceID, 'FLTV - Value');
	ChanceLevel := GetElementEditValues(ChanceID, 'EDID');
	if (pos('High',ChanceLevel)>0) then ChanceLevel:= 'High'
		else if	(pos('Medium',ChanceLevel)>0) then ChanceLevel:= 'Medium'
		else if	(pos('Low',ChanceLevel)>0) then ChanceLevel:= 'Low'
		else if (pos('VeryLow',ChanceLevel)>0) then ChanceLevel:= 'Very Low'
	        else if (pos('Guaranteed',ChanceLevel)>0) then ChanceLevel:= 'Guaranteed'
	        else if (pos('Zero',ChanceLevel)>0) then ChanceLevel:= 'Never';

	LearnMethod := GetElementEditValues(e, 'LRNM - Learn Method');
	if (pos('Learned from plan',LearnMethod)>0) then LearnMethod:= 'Plan'
		else if	(pos('Learned by scrapping',LearnMethod)>0) then LearnMethod:= 'Scrap'
		else if	(pos('Learned when picked up or by script',LearnMethod)>0) then LearnMethod:= 'Pickup/Script'
		else if (pos('Known by default or when conditions are met',LearnMethod)>0) then LearnMethod:= 'Default/Conditional';

	ObjID := LinksTo(ElementByName(e, 'CNAM - Created Object'));
        ObjID2 := LinksTo(ElementByName(e, 'GNAM - Learn Recipe from'));
	LearnFrom := GetElementEditValues(ObjID2,'Full - NAME');
	If (LearnFrom = '') then LearnFrom := GetElementEditValues(ObjID2, 'EDID');
	If ((LearnMethod = 'Plan') OR (LearnMethod = 'Default/Conditional')) then begin //Plans always work
		LearnPerc := '100.000000';
		ChanceLevel:= 'Guaranteed';
	end;
	sig := Signature(ObjID);

	row := '{"id":"'+formid+'",';
	row := row + '"edid":"'+GetElementEditValues(e, 'EDID')+'",';
	row := row + '"CreatedObjectID":"'+IntToHex(FixedFormID(ObjID), 8)+'",';
	row := row + '"CreatedObject":"'+GetElementEditValues(ObjID,'Full - NAME')+'",';
	row := row + '"LearnMethod":"'+LearnMethod+'",';
	row := row + '"LearnFrom":"'+LearnFrom+'",';
	row := row + '"LearnChance":"'+ChanceLevel+'",';
	row := row + '"ChancePercent":'+LearnPerc+'},';
	//if ((LearnMethod = 'Scrap')  AND (ChanceLevel <> '')) then sl.Add(row);
        if ((ObjID <> 0) AND ((sig = 'ARMO') OR (sig = 'WEAP') OR (sig = 'OMOD'))) then sl.Add(row); //Don't include items not fully implimented, or non-weap/armor
 end;
 AddMessage('Found ' + IntToStr(sl.count) + ' List Items');
  //Lets have proper JSON and remove the last record's comma
 If (sl.Count > 1) then begin //Let's only do if there are rows...
	rowcount := sl.count-1; //0 Index, so let's remove one
	Last := sl[rowcount]; //Get the Last row
	sl.Delete(rowcount); //Remove last line from the list
	Delete(Last, Length(Last), Length(Last) -1); //Trim off last character the trailing ,
	sl.Add(Last); //Add the last line back
  end;
 sl.Sorted := False;
 sl.Add(']');
 sl.SaveToFile(fname);
 sl.Free;
 Result := 1;
end;


end.