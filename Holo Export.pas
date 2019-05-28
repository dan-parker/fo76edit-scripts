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
   if (pos('OverseerPersonal_',edid)>0) then begin
	id := FixedFormID(e);
	
	Row := '{"id":'+IntToStr(id)+',"name":"'+GetEditValue(ElementByName(e,'FULL - Name'))+'",';
	Row := Row +  '"type":"HoloMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;
   if (pos('MQ_Overseer_',edid)>0) then begin
	id := FixedFormID(e);
	
	Row := '{"id":'+IntToStr(id)+',"name":"'+GetEditValue(ElementByName(e,'FULL - Name'))+'",';
	Row := Row +  '"type":"HoloMarker",';
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
  fname := ProgramPath + 'Holo.json';
  //Dummy record for trailing comma
  sl.Add('{"id":9999999,"name":"","type":"","x":0,"y":0}');
  sl.Add(']');
  sl.SaveToFile(fname);
  sl.Free;
  Result := 1;
end;


end.