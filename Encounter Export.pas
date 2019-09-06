{
  Exports Encounter data to JSON
  Intended for Fallout 76
}
unit userscript;

var
  sl: TStringList;

procedure GetEncounters;
var
  wrlds, wrld, wrldgrup, block, subblock, cell, e: IInterface;
  i,x,counter,blockidx,subblockidx,cellidx: integer;
  row: string;
begin
    //Let's try to filter to the specific worldspace so we don't have to search through more stuff...
    if wbGameMode = gmFNV then
      wrld := RecordByFormID(FileByIndex(0), $000DA726, False)
    else if wbGameMode = gmFO76 then
      wrld := RecordByFormID(FileByIndex(0), $00050B2C, False)
    else
      wrld := RecordByFormID(FileByIndex(0), $0000003C, False);

    wrldgrup := ChildGroup(wrld);
     for i := 0 to ElementCount(wrldgrup) - 1 do begin
	cell := ElementByIndex(wrldgrup,i);
	//Only do Persistent items
	if GroupType(cell) = 8 then begin
                AddMessage('Total items in world:'+ IntToStr(ElementCount(cell)));
		counter := 0;
		for x := 0 to ElementCount(cell) - 1 do begin
			e := ElementByIndex(cell,x);
             		if Signature(e) = 'ACHR' then begin
	     			AddMessage(IntToStr(FixedFormID(e))+' '+EditorID(e));
				counter := counter + 1;
			end;
		end;
		AddMessage('Exported records:'+ IntToStr(counter));
	end;
     end;
end;


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
	edid,row,info: string;
	id: integer;
begin
  if Signature(e) = 'ACHR' then begin

   edid := BaseName(e);
   if (pos('P01C_Bucket_Loot_Corpse',edid)>0) then begin
	id := FixedFormID(e);
	case (id) of
		4686767: info := '1';
		4686772: info := '2';
		4686762: info := '3';
		4686763: info := '4';
		4686764: info := '5';
		4686765: info := '6';
		4686773: info := '7';
		4686769: info := '8';
		4686768: info := '9';
		4686771: info := '10';
		4686770: info := '11';
		4686774: info := '12';
		4686766: info := '13';
	end;
	Row := '{"id":'+IntToStr(id)+',"name":"Camera",';
	Row := Row +  '"type":"CameraMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+',';
	Row := Row +  '"misc":"'+info+'"},';
	sl.Add(row);
   end;

   if (pos('MoMMistressCorpse ',edid)>0) then begin
	Row := '{"id":'+IntToStr(FixedFormID(e))+',"name":"Mysterious Body",';
	Row := Row +  '"type":"MistressMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;




  end
 else if Signature(e) = 'REFR' then begin

   edid := BaseName(e);
   if (pos('RETriggerObject',edid)>0) then begin
	Row := '{"id":'+IntToStr(FixedFormID(e))+',"name":"Object Encounter",';
	Row := Row +  '"type":"EncounterMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;

   if (pos('RETriggerScene',edid)>0) then begin
	Row := '{"id":'+IntToStr(FixedFormID(e))+',"name":"Scene Encounter",';
	Row := Row +  '"type":"EncounterMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;

   if (pos('RETriggerTravel',edid)>0) then begin
	Row := '{"id":'+IntToStr(FixedFormID(e))+',"name":"Travel Encounter",';
	Row := Row +  '"type":"EncounterMarker",';
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
  fname := ProgramPath + 'Encounters.json';
  //Dummy record for trailing comma
  sl.Add('{"id":9999999,"name":"","type":"","x":0,"y":0}');
  sl.Add(']');
  sl.SaveToFile(fname);
  sl.Free;
  Result := 1;
end;


end.