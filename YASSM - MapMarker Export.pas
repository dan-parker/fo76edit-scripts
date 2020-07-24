{
  Exports Map Marker data to JSON
  Intended for Fallout 76
}
unit userscript;

var
  sl: TStringList;

procedure GetMarkers;
var
  wrlds, wrld, wrldgrup, cell, e, ref, keywords: IInterface;
  i,j,k,x,counter: integer;
  row, LocName, Markername, xLocName: string;
begin
    //Let's try to filter to the specific worldspace so we don't have to search through more stuff...
    if wbGameMode = gmFNV then
      wrld := RecordByFormID(FileByIndex(0), $000DA726, False)
    else if wbGameMode = gmFO76 then
      wrld := RecordByFormID(FileByIndex(0), $00050B2C, False)
    else
      wrld := RecordByFormID(FileByIndex(0), $0000003C, False);

    wrldgrup := ChildGroup(wrld);
   // AddMessage('Found world cell items:'+ IntToStr(ElementCount(wrldgrup)));
     for i := 0 to ElementCount(wrldgrup) - 1 do begin
	cell := ElementByIndex(wrldgrup,i);
	//Only do Persistent items
	if GroupType(cell) = 8 then begin
              //  AddMessage('Total items in world:'+ IntToStr(ElementCount(cell)));
		counter := 0;
		for x := 0 to ElementCount(cell) - 1 do begin
			e := ElementByIndex(cell,x);
             		if ElementExists(e,'Map Marker') then begin
				 for j := 0 to ReferencedByCount(e) - 1 do begin
					ref := ReferencedByIndex(e,j);
					if (Signature(ref) = 'LCTN') then begin
					  LocName := GetEditValue(ElementByName(ref,'FULL - Name'));
					  XLocName := EditorID(ref);
					  Keywords := ElementByName(ElementByName(ref,'Keywords'),'KWDA - Keywords');
					end;
				end;
			//Most locations use the LCTN name, but not all, usually workshops
			If (GetEditValue(ElementByName(ElementByName(ElementByName(e,'Map Marker'),'FNAM - Map Flags'),'Use Location Name')) = '') then begin
				LocName := GetEditValue(ElementByName(ElementByName(e,'Map Marker'),'FULL - Name'));
			end;
			//Overwrite individual with workshop icons, like on in-game map, and set main faction icon.
			MarkerName := GetEditValue(ElementByName(ElementByName(ElementByName(e,'Map Marker'),'TNAM - TNAM'),'Type'));
			for k := 0 to ElementCount(Keywords) -1 do begin
			  if ((MarkerName = 'DoorMarker') or (MarkerName = 'QuestMarker') or (MarkerName = 'PublicWorkshopMarker')) then begin
			  	if (pos('LocEncMainBloodEagles',GetEditValue(ElementByIndex(Keywords,k)))>0) then MarkerName := 'BloodEaglesMarker';
			  	if (pos('LocEncMainCultist',GetEditValue(ElementByIndex(Keywords,k)))>0) then MarkerName := 'CultistMarker';
			  	if (pos('LocEncMainRaider',GetEditValue(ElementByIndex(Keywords,k)))>0) then MarkerName := 'RaiderMarker';
			  end;


			  if (pos('LocSettlementFoundation',GetEditValue(ElementByIndex(Keywords,k)))>0) then MarkerName := 'SettlerMarker';
			  if (pos('LocSettlementCrater',GetEditValue(ElementByIndex(Keywords,k)))>0) then MarkerName := 'CraterMarker';
			  if (pos('LocTypeWorkshop',GetEditValue(ElementByIndex(Keywords,k)))>0) then MarkerName := 'WorkshopMarker';
			end;

			if (LocName = 'Vault 79') then MarkerName := 'Vault79Marker';
			if (LocName = 'The Rusty Pick') then MarkerName := 'LegendaryPurveyorMarker'; //Patch20, no keyword to identify, ESM has PlayerLocMarker, so hardcode
			//Bloody Franks Location name changed to Berkeley Springs, so we should use the map marker name, even though Use Location Name is flagged.. BethBug
			if (IntToHex(FixedFormID(e), 8) = '0059D06D') then LocName := GetEditValue(ElementByName(ElementByName(e,'Map Marker'),'FULL - Name'));


				Row := '{"id":"'+IntToHex(FixedFormID(e), 8)+'","name":"'+ LocName +'",';
				Row := Row +  '"location":"'+XLocName+'",';
				Row := Row +  '"type":"'+MarkerName+'",';
				Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
				Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+'},';
				Row := StringReplace(row,'\','\\',[rfReplaceAll]);
				Row := StringReplace(row,'/','\/',[rfReplaceAll]);
				Row := StringReplace(row,#13#10,'',[rfReplaceAll]);
				sl.Add(row);
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
  fname := ProgramPath + 'MapMarkers.json';
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