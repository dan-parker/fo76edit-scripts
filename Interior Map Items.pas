{
  Build a list of interior cell temporary items in json format
}
unit ListInteriorCells;

var
  slCells,NameList, LocFilter, CellFilter: TStringList;

function Initialize: integer;
var
  f, Blocks, Block, SubBlock, Cell, CellItems, e, Linke : IInterface;
  i, j, k, z : integer;
  LocName, CellID, CellName, ItemName, Sig, Sig2, row, LockLevel, MarkerType: String;
begin
    NameList := TStringList.Create; //List of Names to look through
    NameList.Add('LPI_Loot_Magazines');
    NameList.Add('LPI_Loot_Bobbleheads');
    NameList.Add('LPI_Loot_CapsStash_Tin');
    NameList.Add('LPI_Drink_NukaCola');
    NameList.Add('LPI_PowerArmorFurniture');
    NameList.Add('LPI_Ammo_FusionCore');
    NameList.Add('Workbench');
    NameList.Add('LootPriorityPrewar_Safe');
    LocFilter := TStringList.Create; //Ignore these locations
    LocFilter.Add('Debug');
    LocFilter.Add('Babylon');
    LocFilter.Add('Test');
    LocFilter.Add('CUT_');
    LocFilter.Add('76CharGen');
    LocFilter.Add('76TrailerLocation');
    LocFilter.Add('LeveledItemSpawnLocation');
    LocFilter.Add('Holding');
    CellFilter := TStringList.Create; //Ignore these cells
    CellFilter.Add('Test'); 

  slCells := TStringList.Create;
  slCells.Add('[');
  slCells.Sorted := True;
  f := FileByIndex(0); //Main ESM
  Blocks := GroupBySignature(f, 'CELL');
//  addmessage('Found Cell Blocks: '+IntToStr(ElementCount(Blocks)));

  for i := 0 to ElementCount(Blocks) -1 do begin
 	Block := ElementByIndex(Blocks,i);
//	addmessage('Found SubBlocks: '+IntToStr(ElementCount(Block)));
 	for j := 0 to ElementCount(Block) -1 do begin
	 	SubBlock := ElementByIndex(Block,j);
//		addmessage('Found Cells: '+IntToStr(ElementCount(SubBlock)));
		for k := 0 to ElementCount(SubBlock) -1 do begin
			Cell := ElementByIndex(SubBlock,k);
		//	AddMessage('CellGroup Count '+IntToStr(ElementCount(Cell)));
			if GetElementNativeValues(Cell, 'DATA') and 1 > 0 then begin
				LocName: = EditorID(LinksTo(ElementBySignature(Cell, 'XLCN')));
				If (LocName <> '') then begin //Only include items with External Locations
					CellID : = IntToHex(FixedFormID(Cell), 8);
					CellName := DisplayName(Cell);	
					CellItems := FindChildGroup(ChildGroup(Cell),9,Cell);
					for z := 0 to ElementCount(CellItems) -1 do begin
						e := ElementByIndex(CellItems,z);
						Linke := LinksTo(ElementByName(e,'NAME - Base'));
						ItemName := StringReplace(Name(Linke),'\','\\',[rfReplaceAll]);
						ItemName := StringReplace(ItemName,'"','\"',[rfReplaceAll]);
						ItemName := StringReplace(ItemName,'''','\''',[rfReplaceAll]);
						sig := Signature(e);
						sig2 := Signature(Linke);
						
						If ((wbStringListInString(NameList,ItemName) <> -1) AND (wbStringListInString(LocFilter,LocName) = -1) AND (wbStringListInString(CellFilter,CellName) = -1)) then begin  //Let's filter some items out

  MarkerType := 'Marker'; //We only care about special ones
  if (pos('LPI_Loot_Magazines',ItemName)>0) then begin ItemName:= 'Magazine';MarkerType:= 'MagazineMarker'; end;					
  if (pos('LPI_Loot_Bobbleheads',ItemName)>0) then begin ItemName:= 'Bobblehead';MarkerType:= 'BobbleMarker'; end;
  if (pos('LPI_Loot_CapsStash_Tin',ItemName)>0) then begin ItemName:= 'Cap Stash';MarkerType:= 'CapStashMarker'; end;
  if (pos('LPI_Loot_Magazines',ItemName)>0) then begin ItemName:= 'Magazine';MarkerType:= 'MagazineMarker'; end;
  if (pos('LPI_Drink_NukaCola',ItemName)>0) then begin
		if (pos('Quantum',ItemName)>0) then ItemName:= 'Quantum'
		else if	(pos('Grape',ItemName)>0) then ItemName:= 'Grape'
		else if	(pos('Wild',ItemName)>0) then ItemName:= 'Wild'
		else if (pos('Dark',ItemName)>0) then ItemName:= 'Dark'
		else if	(pos('Orange',ItemName)>0) then ItemName:= 'Orange'
		else if (pos('Cherry',ItemName)>0) then ItemName:= 'Cherry';
		If (pos('LPI',ItemName)=0) then MarkerType := 'NukaCola'+ItemName+'Marker';
  end;

		//Get Lock info for Safes/etc
		LockLevel := GetEditValue(ElementByName(ElementByName(e,'XLOC - Lock Data'),'Level'));
		if (pos('Novice',LockLevel)>0) then LockLevel := '0'
		else if	(pos('Advanced',LockLevel)>0) then LockLevel := '1'
		else if	(pos('Expert',LockLevel)>0) then LockLevel := '2'
		else if (pos('Master',LockLevel)>0) then LockLevel := '3'
		else if (pos('Key',LockLevel)>0) then LockLevel := 'Key';
		if (pos('LootPriorityPrewar_Safe',ItemName)>0) then MarkerType:= 'SafeMarker_Lvl_'+LockLevel;

		if (pos('workbenchWeapons',ItemName)>0) then begin ItemName:= 'Weapons Workbench';MarkerType:= 'WeaponWorkbenchMarker'; end
		else if	(pos('WorkbenchTinkers',ItemName)>0) then begin ItemName:= 'Tinker`s Workbench';MarkerType:= 'TinkerWorkbenchMarker'; end
		else if	(pos('WorkbenchArmor',ItemName)>0) then begin ItemName:= 'Armor Workbench';MarkerType:= 'ArmorWorkbenchMarker'; end
		else if (pos('WorkbenchCooking',ItemName)>0) then begin ItemName:= 'Cooking Station';MarkerType:= 'CookWorkbenchMarker'; end
		else if	(pos('WorkbenchPowerArmor',ItemName)>0) then begin ItemName:= 'Power Armor Station';MarkerType:= 'PAWorkbenchMarker'; end
		else if (pos('WorkbenchChemistry',ItemName)>0) then begin ItemName:= 'Chemistry Station';MarkerType:= 'ChemistryWorkbenchMarker'; end;

   if (pos('LPI_PowerArmorFurniture',ItemName)>0) then begin ItemName:= 'Power Armor';MarkerType:= 'PArmorMarker'; end;
   if (pos('LPI_Ammo_FusionCore',ItemName)>0) then begin ItemName:= 'Fusion Core';MarkerType:= 'FCoreMarker'; end;



					Row := '{"id":"'+IntToHex(FixedFormID(e), 8)+'","name":"'+ ItemName +'",';
					Row := Row +  '"type":"'+MarkerType+'",';
					Row := Row +  '"location":"'+LocName+'",';
					Row := Row +  '"cell":"'+CellName+'",';
					Row := Row +  '"x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X'))+',';
					Row := Row +  '"y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y'))+',';
					Row := Row +  '"z":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Z'))+',';
					Row := Row +  '"rotation-x":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Rotation'),'X'))+',';
					Row := Row +  '"rotation-y":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Rotation'),'Y'))+',';
					Row := Row +  '"rotation-z":'+GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Rotation'),'Z'))+',';
					Row := Row +  '"bounds-x1":'+GetEditValue(ElementByName(ElementByName(Linke,'OBND - Object Bounds'),'X1'))+',';
					Row := Row +  '"bounds-y1":'+GetEditValue(ElementByName(ElementByName(Linke,'OBND - Object Bounds'),'Y1'))+',';
					Row := Row +  '"bounds-z1":'+GetEditValue(ElementByName(ElementByName(Linke,'OBND - Object Bounds'),'Z1'))+',';
					Row := Row +  '"bounds-x2":'+GetEditValue(ElementByName(ElementByName(Linke,'OBND - Object Bounds'),'X2'))+',';
					Row := Row +  '"bounds-y2":'+GetEditValue(ElementByName(ElementByName(Linke,'OBND - Object Bounds'),'Y2'))+',';
					Row := Row +  '"bounds-z2":'+GetEditValue(ElementByName(ElementByName(Linke,'OBND - Object Bounds'),'Z2'))+'},';
					if (MarkerType <> 'Marker') then slCells.Add(row);
						end;
					  if (z > 200) then break; //Shorten run for testing
					end;
				






					
				end;
			end;
		end; //End SubBlock
	end; //End Block
  end; //End Blocks
end;

function Finalize: integer;
var
  fname, Last: string;
  rowcount: integer;
begin
try
    fname := ProgramPath + 'InteriorItems.json';
  //Lets have proper JSON and remove the last record's comma
 If (slCells.Count > 1) then begin //Let's only do if there are rows...
	rowcount := slCells.count-1; //0 Index, so let's remove one
	Last := slCells[rowcount]; //Get the Last row
	slCells.Delete(rowcount); //Remove last line from the list
	Delete(Last, Length(Last), Length(Last) -1); //Trim off last character the trailing ,
	slCells.Add(Last); //Add the last line back
  end;
  slCells.Sorted := False;
  slCells.Add(']');
  slCells.SaveToFile(fname);
finally
  slCells.Free; //Make sure we free memory if this pukes..
end;
  Result := 1;
end;


end.