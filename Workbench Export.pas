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
    Result := 0;
end;

function Process(e: IInterface): integer;
var 
	edid,row,name: string;
begin
  if Signature(e) = 'REFR' then begin

   edid := BaseName(e);
   if (pos('Workbench',edid)>0) then begin
	if (pos('\[00] SeventySix.esm\[70] Cell\',PathName(e))>0) then exit; //Skip Internal Cells
		if (pos('Weapons',edid)>0) then name:= 'Weapons Workbench'
		else if	(pos('Tinkers',edid)>0) then name:= 'Tinker`s Workbench'
		else if	(pos('Armor',edid)>0) then name:= 'Armor Workbench'
		else if (pos('Cooking',edid)>0) then name:= 'Cooking Station'
		else if	(pos('PowerArmor',edid)>0) then name:= 'Power Armor Station'
		else if (pos('Chemistry',edid)>0) then name:= 'Chemistry Station'
		else exit; //We only care about special ones
	Row := '{"id":'+IntToStr(FixedFormID(e))+',"name":"'+name+'",';
	Row := Row +  '"type":"WorkbenchMarker",';
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
  fname: string;
begin
  fname := ProgramPath + 'Workbench.json';
  //Dummy record for trailing comma
  sl.Add('{"id":9999999,"name":"","type":"","x":0,"y":0}');
  sl.Add(']');
  sl.SaveToFile(fname);
  sl.Free;
  Result := 1;
end;


end.