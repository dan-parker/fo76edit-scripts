{
  Exports Safe data to JSON
  Intended for Fallout 76
}
unit userscript;

var
  sl,ItemList: TStringList;


procedure GetMarkers;
var
  wrld, wrldgrup, block, subblock, cell, e: IInterface;
  i,w,x,y,z,counter: integer;
  row, Name, LockLevel: string;
begin
try
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
				If (wbStringListInString(ItemList,Name) <> -1) then begin
					LockLevel := GetEditValue(ElementByName(ElementByName(e,'XLOC - Lock Data'),'Level'));
					If (LockLevel <> '') then begin
						Row := '{"id":"'+IntToHex(FixedFormID(e), 8)+'","name":"'+StringReplace(Name,'LootPriorityPreWar_','',[rfReplaceAll])+'",';
						Row := Row +  '"type":"SafeMarker",';
						Row := Row +  '"Lock":"'+GetEditValue(ElementByName(ElementByName(e,'XLOC - Lock Data'),'Level'))+'",';
						Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
						Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+',';
						Row := Row +  '"z":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Z'))+'},';
						sl.Add(row);
					end;
				end;
			end;
		end;
	end;
     end;
except
  sl.Free; //Make sure we free memory if this pukes..
end;
end;


// Called before processing
// You can remove it if script doesn't require initialization code
function Initialize: integer;
begin
    ItemList := TStringList.Create;
    ItemList.Add('TERM:');
    sl := TStringList.Create;
    sl.Add('[');
    sl.Sorted := True;
    GetMarkers;
    Result := 0;
end;

function Finalize: integer;
var
  fname, Last: string;
  rowcount: integer;
begin
try
  fname := ProgramPath + 'Terminal.json';
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
finally
  sl.Free; //Make sure we free memory if this pukes..
end;
  Result := 1;
end;


end.