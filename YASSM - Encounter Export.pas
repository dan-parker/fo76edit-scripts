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
    sl.Sorted := True;
    Result := 0;
end;

function Process(e: IInterface): integer;
var 
	edid,row: string;
	id: integer;
begin
  if Signature(e) = 'ACHR' then begin

   edid := BaseName(e);
   if (pos('P01C_Bucket_Loot_Corpse',edid)>0) then begin
	id := FixedFormID(e);
	Row := '{"id":"'+IntToHex(id, 8)+'","name":"Camera",';
	Row := Row +  '"type":"CameraMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;

   if (pos('MoMMistressCorpse ',edid)>0) then begin
	Row := '{"id":"'+IntToHex(FixedFormID(e), 8)+'","name":"Mysterious Body",';
	Row := Row +  '"type":"MistressMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;

  end
 else if Signature(e) = 'REFR' then begin

   edid := BaseName(e);
   if (pos('RETriggerObject',edid)>0) then begin
	Row := '{"id":"'+IntToHex(FixedFormID(e), 8)+'","name":"Object Encounter",';
	Row := Row +  '"type":"ObjectEncounterMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;

   if (pos('RETriggerScene',edid)>0) then begin
	Row := '{"id":"'+IntToHex(FixedFormID(e), 8)+'","name":"Scene Encounter",';
	Row := Row +  '"type":"SceneEncounterMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;

   if (pos('RETriggerTravel',edid)>0) then begin
	Row := '{"id":"'+IntToHex(FixedFormID(e), 8)+'","name":"Travel Encounter",';
	Row := Row +  '"type":"TravelEncounterMarker",';
	Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
	Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
	sl.Add(row);
   end;
   if (pos('RETriggerCamp',edid)>0) then begin
	Row := '{"id":"'+IntToHex(FixedFormID(e), 8)+'","name":"Camp Encounter",';
	Row := Row +  '"type":"CampEncounterMarker",';
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
  fname := ProgramPath + 'Encounters.json';
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