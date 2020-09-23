{
  Exports Magazine spawn data to JSON
  Intended for Fallout 76
  For faster processing, set filters as Record Sig: Cell, WRLD, REFR, Base Record EditorID: LPI_Loot_Magazines
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
	edid,row,name,markername: string;
begin
  if Signature(e) = 'REFR' then begin

   edid := BaseName(e);
   if (pos('Workbench',edid)>0) then begin
	if (pos('\[00] SeventySix.esm\[70] Cell\',PathName(e))>0) then exit; //Skip Internal Cells
		if (pos('workbenchWeapons',edid)>0) then begin name:= 'Weapons Workbench';markername:= 'Weapon'; end
		else if	(pos('WorkbenchTinkers',edid)>0) then begin name:= 'Tinker`s Workbench';markername:= 'Tinker'; end
		else if	(pos('WorkbenchArmor',edid)>0) then begin name:= 'Armor Workbench';markername:= 'Armor'; end
		else if (pos('WorkbenchCooking',edid)>0) then begin name:= 'Cooking Station';markername:= 'Cook'; end
		else if	(pos('WorkbenchPowerArmor',edid)>0) then begin name:= 'Power Armor Station';markername:= 'PA'; end
		else if (pos('WorkbenchChemistry',edid)>0) then begin name:= 'Chemistry Station';markername:= 'Chemistry'; end
		else if (pos('WorkbenchBrewing',edid)>0) then begin name:= 'Brewing Station';markername:= 'Brewing'; end
		else exit; //We only care about special ones
	Row := '{"id":"'+IntToHex(FixedFormID(e), 8)+'","name":"'+name+'",';
	Row := Row +  '"type":"'+markername+'WorkbenchMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;
  end
 else exit;
 Result := 0;
end;

function Finalize: integer;
var
  fname, Last: string;
  rowcount: integer;
begin
try
  fname := ProgramPath + 'Workbench.json';
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