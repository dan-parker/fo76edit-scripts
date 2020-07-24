{
  Exports Power Armor spawn data to JSON
  Intended for Fallout 76
  For faster processing, set filters as Record Sig: Cell, WRLD, REFR, Base Record EditorID: LPI_PowerArmor
}
unit userscript;

var
  sl: TStringList;

// Called before processing
// You can remove it if script doesn't require initialization code
function Initialize: integer;
begin
    //Let's override the workshop locations w/the workshop icon
    sl := TStringList.Create;
    sl.Add('[');
    sl.Sorted := True;
    Result := 0;
end;

function Process(e: IInterface): integer;
var 
	edid,row: string;
begin
  if Signature(e) = 'REFR' then begin

   edid := BaseName(e);
   if (pos('LPI_PowerArmorFurniture',edid)>0) then begin
	if (pos('\[00] SeventySix.esm\[70] Cell\',PathName(e))>0) then exit; //Skip Internal Cells
	Row := '{"id":"'+IntToHex(FixedFormID(e), 8)+'","name":"Power Armor",';
	Row := Row +  '"type":"PArmorMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;
   if (pos('LPI_Ammo_FusionCore',edid)>0) then begin
	if (pos('\[00] SeventySix.esm\[70] Cell\',PathName(e))>0) then exit; //Skip Internal Cells
	Row := '{"id":"'+IntToHex(FixedFormID(e), 8)+'","name":"Fusion Core",';
	Row := Row +  '"type":"FCoreMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;

  end
 else exit;
 Result := 0;
//STAT TreasureMarkerxx or ACTI TreasureMapActivatorxx
end;

function Finalize: integer;
var
  fname, Last: string;
  rowcount: integer;
begin
try
  fname := ProgramPath + 'PArmor.json';
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