{
  Exports Radio data to JSON
  Intended for Fallout 76
}
unit userscript;

var
  sl: TStringList;

procedure GetMarkers;
var
  RadioQuest, currReference,SceneActions,Action, SongID, DialogID, DialogID2, IntroIDs, OuttroIDs: IInterface;
  i,j,k,id,rowcount: integer;
  Song, Row, Intros, Outtros, Last: string;
begin
   RadioQuest := RecordByFormID(FileByIndex(0), $001948B4, False);
   AddMessage('Items Referencing Radio Quest '+IntToStr(ReferencedByCount(RadioQuest)));
   for i := 0 to ReferencedByCount(RadioQuest)-1 do begin
	currReference := ReferencedByIndex(RadioQuest,i); 
	if (Signature(currReference) = 'SCEN') then begin
		SceneActions := ElementByPath(currReference, 'Actions');
		Song := '';
		Intros := '';
		Outtros := '';
		//Typically the Song is action 1, intro 2, outtro 3
		If (ElementCount(SceneActions)=3) then begin
			SongID := LinksTo(ElementByPath(ElementByIndex(SceneActions,0), 'HTID\Play Sound')); //Song
			DialogID := LinksTo(ElementByPath(ElementByIndex(SceneActions,1), 'DATA - Topic'));  //Intro
			DialogID2 := LinksTo(ElementByPath(ElementByIndex(SceneActions,2), 'DATA - Topic'));  //Outtro
			Song := StringReplace(GetEditValue(ElementByPath(SongID,'Sounds\Sound Files\ANAM')),'.wav','.mp3',[rfReplaceAll]);	
			IntroIDs := ChildGroup(DialogID);
			OuttroIDs := ChildGroup(DialogID2);
			Intros := '"Intros":[';
			for k := 0 to ElementCount(IntroIDs)-1 do begin
				Intros := Intros + '"' + IntToHex(FixedFormID(ElementByIndex(IntroIDs,k)),8) + '_1.mp3",';
			end;
			If (ElementCount(IntroIDs) > 0) then begin
				Delete(Intros, Length(Intros), Length(Intros) -1); //Trim off last character the trailing ,
			end;
			Outtros := '"Outtros":[';
			for k := 0 to ElementCount(OuttroIDs)-1 do begin
				Outtros := Outtros + '"' + IntToHex(FixedFormID(ElementByIndex(OuttroIDs,k)),8) + '_1.mp3",';
			end;
			If (ElementCount(OuttroIDs) > 0) then begin
				Delete(Outtros, Length(Outtros), Length(Outtros) -1); //Trim off last character the trailing ,
			end;
		end
		else If (ElementCount(SceneActions)=1) then begin //Likely a julie message
			DialogID := LinksTo(ElementByPath(ElementByIndex(SceneActions,0), 'DATA - Topic'));
			IntroIDs := ChildGroup(DialogID);
			Intros := '"Intros":[';
			for k := 0 to ElementCount(IntroIDs)-1 do begin
				Intros := Intros + '"' + IntToHex(FixedFormID(ElementByIndex(IntroIDs,k)),8) + '_1.mp3",';
			end;
			If (ElementCount(IntroIDs) > 0) then begin
				Delete(Intros, Length(Intros), Length(Intros) -1); //Trim off last character the trailing ,
			end;
			Outtros := '"Outtros":[';
		end 
		else begin //Station messages
			Intros := '"Intros":[';
			Outtros := '"Outtros":[';
			for j := 0 to ElementCount(SceneActions)-1 do begin
				DialogID := LinksTo(ElementByPath(ElementByIndex(SceneActions,j), 'DATA - Topic'));
				IntroIDs := ChildGroup(DialogID);
				for k := 0 to ElementCount(IntroIDs)-1 do begin
					Intros := Intros + '"' + IntToHex(FixedFormID(ElementByIndex(IntroIDs,k)),8) + '_1.mp3",';
				end;	
			end;
			If (ElementCount(IntroIDs) > 0) then begin
				Delete(Intros, Length(Intros), Length(Intros) -1); //Trim off last character the trailing ,
			end;
		end;
		
		Intros := Intros + ']';
		Outtros := Outtros + ']';
		id := FixedFormID(currReference);
		Row := '{"id":"'+IntToHex(id, 8)+'",';
		Row := Row + '"song":"' + Song + '",';
		Row := Row + Intros + ',';
		Row := Row + Outtros + '';
		Row := Row + '},';
		If (pos('DELETE',BaseName(currReference))=0) then sl.Add(row); //Some records are incomplete and named DELETE, so let's ignore those
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
  fname := ProgramPath + 'Radio.json';
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