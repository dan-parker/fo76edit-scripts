{
  Exports Treasure Map data to JSON
  Intended for Fallout 76
  For faster processing, set filters as Record Sig: Cell, WRLD, ACTI, Base Record EditorID: TreasureMapActivator
}
unit userscript;

var
  sl: TStringList;

// Called before processing
// You can remove it if script doesn't require initialization code
function Initialize: integer;
begin
    sl := TStringList.Create;
    sl.Add('[');
    Result := 0;
end;

function Process(e: IInterface): integer;
var 
	edid,row,name: string;
 	id: integer;
begin
  if Signature(e) = 'REFR' then begin

   edid := BaseName(e);
   if (pos('TreasureMapMoundActivator',edid)>0) then begin
	id := FixedFormID(e);
	case (id) of
		3715880: name := 'Forest (Map 1)';
		3715666: name := 'Forest (Map 2)';
		3715616: name := 'Forest (Map 3)';
		3715546: name := 'Forest (Map 4)';
		3715568: name := 'Forest (Map 5)';
		3715480: name := 'Forest (Map 6)';
		3715446: name := 'Forest (Map 7)';
		3715414: name := 'Forest (Map 8)';
		3715405: name := 'Forest (Map 9)';
		3715337: name := 'Forest (Map 10)';
		3715417: name := 'Toxic Valley (Map 1)';
		3715399: name := 'Toxic Valley (Map 2)';
		3715290: name := 'Toxic Valley (Map 3)';
		3714973: name := 'Toxic Valley (Map 4)';
		3715570: name := 'Ash Heap (Map 1)';
		3715543: name := 'Ash Heap (Map 2)';
		3715293: name := 'Savage Divide (Map 1)';
		3715178: name := 'Savage Divide (Map 2)';
		3714956: name := 'Savage Divide (Map 3)';
		3714918: name := 'Savage Divide (Map 4)';
		3714916: name := 'Savage Divide (Map 5)';
		3714892: name := 'Savage Divide (Map 6)';
		3714637: name := 'Savage Divide (Map 7)';
		3714524: name := 'Savage Divide (Map 8)';
		3714519: name := 'Savage Divide (Map 9)';
		3714401: name := 'Savage Divide (Map 10)';
		3714466: name := 'The Mire (Map 1)';
		3714462: name := 'The Mire (Map 2)';
		3714381: name := 'The Mire (Map 3)';
		3714378: name := 'The Mire (Map 4)';
		3714330: name := 'The Mire (Map 5)';
		3714475: name := 'Cranberry Bog (Map 1)';
		3714384: name := 'Cranberry Bog (Map 2)';
		3714375: name := 'Cranberry Bog (Map 3)';
		3714237: name := 'Cranberry Bog (Map 4)';
	end;
	Row := '{"id":"'+IntToHex(id, 8)+'","name":"'+name+'",';
	Row := Row +  '"type":"TreasureMarker",';
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
  fname: string;
begin
  fname := ProgramPath + 'Treasure.json';
  //Dummy record for trailing comma
  sl.Add('{"id":9999999,"name":"","type":"","x":0,"y":0}');
  sl.Add(']');
  sl.SaveToFile(fname);
  sl.Free;
  Result := 1;
end;


end.