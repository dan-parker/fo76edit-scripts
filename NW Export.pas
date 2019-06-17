{
  Exports Nuclear Winter spawn data to JSON
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
   if (pos('LPI_Babylon_Loot_Magazines',edid)>0) then begin
	if (pos('\[00] SeventySix.esm\[70] Cell\',PathName(e))>0) then exit; //Skip Internal Cells
	Row := '{"id":'+IntToStr(FixedFormID(e))+',"name":"Magazine",';
	Row := Row +  '"type":"MagazineMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;
   if (pos('LPI_Babylon_Loot_Bobbleheads',edid)>0) then begin
	if (pos('\[00] SeventySix.esm\[70] Cell\',PathName(e))>0) then exit; //Skip Internal Cells
	Row := '{"id":'+IntToStr(FixedFormID(e))+',"name":"Bobblehead",';
	Row := Row +  '"type":"BobbleMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;
   if (pos('Babylon_Loot_Terminal',edid)>0) then begin
	if (pos('\[00] SeventySix.esm\[70] Cell\',PathName(e))>0) then exit; //Skip Internal Cells
	Row := '{"id":'+IntToStr(FixedFormID(e))+',"name":"Terminal",';
	Row := Row +  '"type":"TerminalMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;
   if (pos('LPI_Babylon_NukeBriefcase',edid)>0) then begin
	if (FixedFormID(e) = 5145111) then exit; //Skip offmap item
	if (pos('\[00] SeventySix.esm\[70] Cell\',PathName(e))>0) then exit; //Skip Internal Cells
	Row := '{"id":'+IntToStr(FixedFormID(e))+',"name":"Nuke Briefcase",';
	Row := Row +  '"type":"BriefcaseMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;
   if (pos('LPI_Babylon_RadiationBarrels',edid)>0) then begin
	if (FixedFormID(e) = 5145111) then exit; //Skip offmap item
	if (pos('\[00] SeventySix.esm\[70] Cell\',PathName(e))>0) then exit; //Skip Internal Cells
	Row := '{"id":'+IntToStr(FixedFormID(e))+',"name":"Radiation Barrel",';
	Row := Row +  '"type":"BarrelMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;
   if (pos('LPI_Loot_Babylon',edid)>0) then begin
	if (pos('\[00] SeventySix.esm\[70] Cell\',PathName(e))>0) then exit; //Skip Internal Cells
		if (pos('Low',edid)>0) then name:= 'Low'
		else if	(pos('Med',edid)>0) then name:= 'Medium'
		else if	(pos('High',edid)>0) then name:= 'High'
		else exit; //We only care about special ones
	Row := '{"id":'+IntToStr(FixedFormID(e))+',"name":"'+name+'",';
	Row := Row +  '"type":"LootMarker",';
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
  fname := ProgramPath + 'NW.json';
  //Dummy record for trailing comma
  sl.Add('{"id":9999999,"name":"","type":"","x":0,"y":0}');
  sl.Add(']');
  sl.SaveToFile(fname);
  sl.Free;
  Result := 1;
end;


end.