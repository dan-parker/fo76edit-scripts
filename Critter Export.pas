{
  Exports Critter Spawn data to JSON
  Intended for Fallout 76
}
unit userscript;

var
  sl,CritterList: TStringList;


procedure GetMarkers;
var
  wrld, wrldgrup, block, subblock, cell, e: IInterface;
  i,w,x,y,z,counter: integer;
  row, Name: string;
begin
    //Let's try to filter to the specific worldspace so we don't have to search through more stuff...
    if wbGameMode = gmFNV then
      wrld := RecordByFormID(FileByIndex(0), $000DA726, False)
    else if wbGameMode = gmFO76 then
      wrld := RecordByFormID(FileByIndex(0), 2480661, False)
    else
      wrld := RecordByFormID(FileByIndex(0), $0000003C, False);

    wrldgrup := ChildGroup(wrld);
     for i := 0 to ElementCount(wrldgrup) - 1 do begin
	block := ElementByIndex(wrldgrup,i);
	//AddMessage('Block '+BaseName(Block));
	for x := 0 to ElementCount(block) -1 do begin
	   subblock := ElementByIndex(block,x);
	  //AddMessage('Block '+BaseName(block) +' SubBlock '+BaseName(subblock));
	   	for y := 0 to ElementCount(subblock) -1 do begin
			//We only want to look through Temp items
			cell := FindChildGroup(ChildGroup(ElementByIndex(subblock,y)),9,ElementByIndex(subblock,y));
			for z := 0 to ElementCount(cell) -1 do begin
				e := ElementByIndex(cell,z);
				Name := GetEditValue(ElementByName(e,'NAME - Base'));
				If (wbStringListInString(CritterList,Name) <> -1) then begin
					Row := '{"id":"'+IntToHex(FixedFormID(e), 8)+'","name":"'+StringReplace(Name,'LvlCritter','',[rfReplaceAll])+'",';
					Row := Row +  '"type":"CritterMarker",';
					Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
					Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
					sl.Add(row);
				end;
			end;
		end;
	end;
     end;
end;


// Called before processing
// You can remove it if script doesn't require initialization code
function Initialize: integer;
begin
    CritterList := TStringList.Create;
    CritterList.Add('LvlCritterCat');
    CritterList.Add('LvlCritterRabbit');
    CritterList.Add('LvlCritterOwlet');
    CritterList.Add('LvlCritterSquirrel');
    CritterList.Add('LvlCritterFrog');
    CritterList.Add('LvlCritterFirefly');
    CritterList.Add('LvlCritterFox');
    CritterList.Add('LvlCritterBeaver');
    CritterList.Add('LvlCritterChicken');
    CritterList.Add('LvlCritterOpossum');

    sl := TStringList.Create;
    sl.Add('[');
    GetMarkers;
    Result := 0;
end;

function Finalize: integer;
var
  fname: string;
begin
  fname := ProgramPath + 'Critter.json';
  //Dummy record for trailing comma
  sl.Add('{"id":9999999,"name":"","type":"","x":0,"y":0}');
  sl.Add(']');
  sl.SaveToFile(fname);
  sl.Free;
  Result := 1;
end;


end.