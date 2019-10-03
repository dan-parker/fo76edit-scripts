{
  Build a list of interior cell persistent items in csv format
}
unit ListInteriorCells;

var
  slCells: TStringList;

function Initialize: integer;
var
  f, Blocks, Block, SubBlock, Cell, CellItems, e, Linke : IInterface;
  i, j, k, z : integer;
  LocName, CellID, CellName, ItemName, Sig, Sig2: String;
begin
  slCells := TStringList.Create;
  slCells.Add('FormID,Name,Signature,BaseSignature,CellID,CellName,Location,Position-X,Position-Y,Position-Z,Rotation-X,Rotation-Y,Rotation-Z,Bounds-X1,Bounds-Y1,Bounds-Z1,Bounds-X2,Bounds-Y2,Bounds-Z2');

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

					CellID : = IntToHex(FixedFormID(Cell), 8);
					CellName := DisplayName(Cell);	
					CellItems := FindChildGroup(ChildGroup(Cell),8,Cell);
					for z := 0 to ElementCount(CellItems) -1 do begin
						e := ElementByIndex(CellItems,z);
						Linke := LinksTo(ElementByName(e,'NAME - Base'));
						ItemName := StringReplace(Name(Linke),'"','""',[rfReplaceAll]);
						sig := Signature(e);
						sig2 := Signature(Linke);
						If (sig = 'REFR') then begin //Let's filter some items out
						slCells.Add(Format('"%s","%s",%s,%s,"%s","%s","%s",%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s', [
						  IntToHex(FormID(e), 8),
						  ItemName,
						  sig,
						  sig2,
						  CellID,
						  CellName,
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
					  //if (z > 200) then break; //Shorten run for testing
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
  if slCells.Count > 1 then begin
    fname := ProgramPath + 'Cells-Persist.csv';
    AddMessage('Saving report to ' + fname);
    slCells.SaveToFile(fname);
  end else
    AddMessage('No cells found in selection.');

  slCells.Free;
end;


end.