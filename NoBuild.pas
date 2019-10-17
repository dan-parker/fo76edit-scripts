{
  Exports No Build Area data to JSON
  Intended for Fallout 76
}
unit userscript;

var
  sl: TStringList;

procedure GetMarkers;
var
  f, Target, e: IInterface;
  i: integer;
  sig, row: string;
begin
 f := FileByIndex(0); //Main ESM
 Target := MainRecordByEditorID(GroupBySignature(f, 'ACTI'),'NoCampAllowedTrigger');

			for i := 0 to ReferencedByCount(Target) -1 do begin
				e := ReferencedByIndex(Target,i);
				sig := Signature(e);
				if (sig = 'REFR') then begin
					Row := '{"id":"'+IntToHex(FixedFormID(e), 8)+'",';
					Row := Row +  '"type":"NoBuild",';
					Row := Row +  '"bounds-x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'XPRM - Primitive'),'Bounds'),'X'))+',';
					Row := Row +  '"bounds-y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'XPRM - Primitive'),'Bounds'),'Y'))+',';
					Row := Row +  '"bounds-z":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'XPRM - Primitive'),'Bounds'),'Z'))+',';
					Row := Row +  '"bounds-type":"'+GetEditValue(ElementByName(ElementByName(e,'XPRM - Primitive'),'Type'))+'",';
					Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
					Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+',';
					Row := Row +  '"z":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Z'))+'},';
					sl.Add(row);
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
  fname := ProgramPath + 'NoBuild.json';
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
  If (sl.Count < 3) then AddMessage('No Records Found')
   else sl.SaveToFile(fname);
finally
  sl.Free; //Make sure we free memory if this pukes..
end;
  Result := 1;
end;


end.