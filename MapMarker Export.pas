{
  Exports Map Marker data to JSON
  Intended for Fallout 76
}
unit userscript;

var
  sl,Workshops: TStringList;

procedure GetMarkers;
var
  wrlds, wrld, wrldgrup, cell, e: IInterface;
  i,x,counter: integer;
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
   // AddMessage('Found world cell items:'+ IntToStr(ElementCount(wrldgrup)));
     for i := 0 to ElementCount(wrldgrup) - 1 do begin
	cell := ElementByIndex(wrldgrup,i);
	//Only do Persistent items
	if GroupType(cell) = 8 then begin
                AddMessage('Total items in world:'+ IntToStr(ElementCount(cell)));
		counter := 0;
		for x := 0 to ElementCount(cell) - 1 do begin
			e := ElementByIndex(cell,x);
             		if ElementExists(e,'Map Marker') then begin
	     			//AddMessage(ElementByName(e,'FULL - Name'));
				//Bug in gamedata, fullname field is blank, so let's work around it...
//3837135 Prime
				If (FixedFormID(e) = 4016968) then
					Row := '{"id":'+IntToStr(FixedFormID(e))+',"name":"Monongah Power Plan Yard",'
				else
					Row := '{"id":'+IntToStr(FixedFormID(e))+',"name":"'+StringReplace(GetEditValue(ElementByName(ElementByName(e,'Map Marker'),'FULL - Name')),'Fast Travel Point: ','',[rfReplaceAll])+'",';
				//Overwrite individual with workshop icons, like on in-game map.
				If (wbStringListInString(Workshops,IntToStr(FixedFormID(e))) <> -1) then
					Row := Row +  '"type":"WorkshopMarker",'
				else 
					Row := Row +  '"type":"'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'Map Marker'),'TNAM - TNAM'),'Type'))+'",';
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
    //Let's override the workshop locations w/the workshop icon
    Workshops := TStringList.Create;
    Workshops.Add('408960');
    Workshops.Add('3007870');
    Workshops.Add('591398');
    Workshops.Add('585138');
    Workshops.Add('1100973');
    Workshops.Add('381740');
    Workshops.Add('605129');
    Workshops.Add('3315503');
    Workshops.Add('1101032');
    Workshops.Add('2856530');
    Workshops.Add('3658197');
    Workshops.Add('4425105');
    Workshops.Add('1088813');
    Workshops.Add('2913845');
    Workshops.Add('16722');
    Workshops.Add('1089240');
    Workshops.Add('396488');
    Workshops.Add('2536968');
    Workshops.Add('4016918');
    Workshops.Add('630835');
    Workshops.Add('1089188');
    Workshops.Add('4016968');

    sl := TStringList.Create;
    sl.Add('[');
    GetMarkers;
    Result := 0;
end;

function Finalize: integer;
var
  fname: string;
begin
  fname := ProgramPath + 'MapMarkers.json';
  //Dummy record for trailing comma
  sl.Add('{"id":9999999,"name":"","type":"","x":0,"y":0}');
  sl.Add(']');
  sl.SaveToFile(fname);
  sl.Free;
  Result := 1;
end;


end.