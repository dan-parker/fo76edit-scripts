{
  Build a list of interior cell items in csv format
}
unit ListInteriorCells;

var
  slCells: TStringList;

function Initialize: integer;
var
  f, Blocks, Block, SubBlock, Cell, CellItems, e, Linke : IInterface;
  i, j, k, z : integer;
  LocName, CellID, Sig, Sig2: String;
begin
  slCells := TStringList.Create;
  slCells.Add('FormID,Name,Signature,BaseSignature,Location,Position-X,Position-Y,Position-Z,Rotation-X,Rotation-Y,Rotation-Z,Bounds-X1,Bounds-Y1,Bounds-Z1,Bounds-X2,Bounds-Y2,Bounds-Z2');

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
					CellItems := FindChildGroup(ChildGroup(Cell),9,Cell);
					for z := 0 to ElementCount(CellItems) -1 do begin
						e := ElementByIndex(CellItems,z);
						Linke := LinksTo(ElementByName(e,'NAME - Base'));
						sig := Signature(e);
						sig2 := Signature(Linke);
						If (sig2 <> 'LIGH') AND (sig <> 'NAVM') AND (sig2 <> 'SOUN') AND (sig <> 'PHZD') AND (sig2 <> 'IDLM')
						 AND (pos('Debug',LocName)=0) AND (pos('Babylon',LocName)=0) AND (pos('Test',LocName)=0) AND (pos('CUT_',LocName)=0)
						 AND (pos('76CharGen',LocName)=0) AND (pos('76TrailerLocation',LocName)=0) AND (pos('LeveledItemSpawnLocation',LocName)=0) AND (pos('Holding',LocName)=0) then begin //Let's filter some items out
						slCells.Add(Format('"%s","%s",%s,%s,"%s",%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s', [
						  IntToHex(FormID(e), 8),
						  StringReplace(Name(Linke),'"','""',[rfReplaceAll]),
						  sig,
						  sig2,
						  LocName,
						  GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'X')),
						  GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Y')),
						  GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Position'),'Z')),
						  GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Rotation'),'X')),
						  GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Rotation'),'Y')),
						  GetEditValue(ElementByName(ElementByName(ElementByName(e,'DATA - Position/Rotation'),'Rotation'),'Z')),
						  GetEditValue(ElementByName(ElementByName(Linke,'OBND - Object Bounds'),'X1')),
						  GetEditValue(ElementByName(ElementByName(Linke,'OBND - Object Bounds'),'Y1')),
						  GetEditValue(ElementByName(ElementByName(Linke,'OBND - Object Bounds'),'Z1')),
						  GetEditValue(ElementByName(ElementByName(Linke,'OBND - Object Bounds'),'X2')),
						  GetEditValue(ElementByName(ElementByName(Linke,'OBND - Object Bounds'),'Y2')),
						  GetEditValue(ElementByName(ElementByName(Linke,'OBND - Object Bounds'),'Z2'))
      						]));
						end;
					 // if (z > 200) then break; //Shorten run for testing
					end;
				






					
				end;
			end;
		end; //End SubBlock
	end; //End Block
  end; //End Blocks
end;

function Finalize: integer;
var
  fname: string;
begin
  if slCells.Count > 1 then begin
    fname := ProgramPath + 'Cells.csv';
    AddMessage('Saving report to ' + fname);
    slCells.SaveToFile(fname);
  end else
    AddMessage('No cells found in selection.');

  slCells.Free;
end;


end.