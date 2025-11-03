--[[
	*****************************************************
	*Author: PeaceBeUponYou               				*
	*Contact: 				              				*
	*	Discord: PeaceBeUponYou#0085  					*
	*	Patreon: https://www.patreon.com/peaceCheats	*
	*Only available on:                   				*
	*   https://guidedhacking.com/        				*
	*****************************************************
	
This file adds UE Menu in the main Menu
--Credits:
	Special thanks to Dark Byte @ https://www.cheatengine.org/ for some of the functions to
	adjust the form.
--]]

function fu(str,num)
  if type(str)~='number' then printf('"fu" only formats numbers not %s',type(str)) return end
  if num then
  local stringx = string.gsub("('%.NUMX'):format(str)",'NUM',num)
  stringx = string.gsub(stringx,'str',str)
  local f = loadstring('return '..stringx)
  --print(stringx)
   return f()
  end
  --print(string.gsub("('%.NUMX'):format(str)",'NUM',num))
  return ('%X'):format(str)
end
registerLuaFunctionHighlight('fu')


local caption = "GH Unreal Engine 4"
local subMenus = {
	{caption = 'Init Unreal Engine Tool',	name = 'miUnrealEngineCollector'},
	{caption = 'Launch Data Collector',	name = 'miDataCollectorForm'},
	{caption = 'Enable Structure Dissect',	name = 'miUEStructDissect'}
}
local mm = getMainForm().Menu
local menuItem = mm.mnUnrealEngine4
if not(mm.mnUnrealEngine4) then
	menuItem = createMenuItem(mm)
	menuItem.Caption = caption
	menuItem.Name = 'mnUnrealEngine4'
	mm.Items.add(menuItem)
end
if not(menuItem) then print('somthing went wrong in creating "GH Unreal Engine 4" menu') return end

--print(menuItem.Caption)
for i=1,#subMenus do
	local chk = createMenuItem(menuItem)
	chk.Caption = subMenus[i].caption
	chk.Name = subMenus[i].name
	menuItem.add(chk)
end

OpenedProcessID=0
miActivateUnrealEngine = function(sender)
	if not(sender) then sender = menuItem.miUnrealEngineCollector end
	if not(sender.Checked) or not(UnrealPipe) or not(UnrealPipe.Connected) or not(getAddressSafe('UnrealDataCollector64.dll')) or not(readPointer('UnrealDataCollector64.dll')) then
		if (UnrealPipe) then UnrealPipe.destroy() UnrealPipe=nil end
		getLuaEngine().mOutput.clear()
		--UnrealScanner()
		local time = os.time()
		if (LaunchUEDataCollector()~=1) then showMessage("Failure to launch Unreal Data Collector") error() end
		printf('Time taken to launch data collector: %d seconds',os.time()-time)
		UnrealScanner()
		InitUE()
		sender.Checked = true
		OpenedProcessID = getOpenedProcessID()
	elseif (sender.Checked) then
		UE_EjectDllAndFree()
		unregisterSymbol('GEngine')
		unregisterSymbol('GObjects')
		unregisterSymbol('FUNames')
		unregisterSymbol('Actor::ProcessEvent')
		unregisterSymbol('Object::ProcessEvent')
		sender.Checked = false
		if (menuItem.miUEStructDissect.Checked) then
			menuItem.miUEStructDissect.OnClick(menuItem.miUEStructDissect)
		end
	end
end
menuItem.OnClick = function()
	menuItem.miUnrealEngineCollector.Checked = UnrealPipe~=nil and OpenedProcessID==getOpenedProcessID()
end
menuItem.miUnrealEngineCollector.OnClick = miActivateUnrealEngine
local structDissectorEn = [[
local ueToCETypes = {
  ['BoolProperty']=vtByte,
  ['ByteProperty']=vtByte,
  ['Int8Property']=vtByte,
  ['Int16Property']=vtWord,
  ['IntProperty']=vtDword,
  ['Int64Property']=vtQword,
  ['UInt16Property']=vtWord,
  ['UInt32Property']=vtDword,
  ['UInt64Property']=vtQword,
  ['FloatProperty']=vtSingle,
  ['DoubleProperty']=vtDouble,

  --['StructProperty']=vtDword,
  --['EnumProperty']=vtDword,
  --['NameProperty']=vtQword,
---[[
  --['WeakObjectProperty']=vtQword, --size=0x08 ; int ObjectIndex, int ObjectSerialNumber
  --['LazyObjectProperty']=vtQword, --size=0x1C ; WeakObjectProperty WeakPtr,int32 TagAtLastTest,TObjectID ObjectID (struct {int A,int B,int C,int D});
  --['SoftObjectProperty']=vtQword, --size=0x24 ; WeakObjectProperty WeakPtr,int32 TagAtLastTest,TObjectID ObjectID (struct {FName AssetPathName, FString SubPathString});
  --['SoftClassProperty']=vtQword, --size=0x24 ; WeakObjectProperty WeakPtr,int32 TagAtLastTest,TObjectID ObjectID (struct {FName AssetPathName, FString SubPathString});
  --['IntefaceProperty']=vtPointer --size=0x10 ; UObject*	ObjectPointer,void* InterfacePointer;
  --['StrProperty']=vtPointer --size=0x10 ; void*	AllocatorInstance, int ArrayNum, int ArrayMax;
  --['SetProperty'] is probably same as MapProperty
  --['DelegateProperty'] = vtPointer --size=0x10 ; WeakObjectProperty Object, FName FunctionName;
  --['MulticastSparseDelegateProperty'] = vtByte --size=0x1 ; BOOL bIsBound;
  --['MulticastInlineDelegateProperty'] = vtPointer --size=0x10 ; WeakObjectProperty Object, FName FunctionName; (it is used in ue 4.27)
  --['TextProperty'] = vtPointer --size=0xC ; ITextData(pointer) TextData.Object, FReferenceControllerBase(pointer) TextData.SharedReferenceCount.ReferenceController, int Flags;

  --vtPointer = ObjectProperty,ClassProperty
  }
local OuterTypes = {}
  OuterTypes.None = 1
  OuterTypes.Struct = 2
  OuterTypes.Array = 3
  OuterTypes.Map = 4
  OuterTypes.Set = 5
local enumPropSizes = {}
  enumPropSizes[1] = vtByte
  enumPropSizes[2] = vtWord
  enumPropSizes[3] = vtWord
  enumPropSizes[4] = vtDword
  enumPropSizes[5] = vtDword
  enumPropSizes[6] = vtDword
  enumPropSizes[7] = vtDword
  enumPropSizes[8] = vtQword
local propertyTypes = {}
	propertyTypes.Unknown = 0
	propertyTypes.BoolProperty = 1
	propertyTypes.ObjectProperty = 2
	propertyTypes.StructProperty = 3
	propertyTypes.EnumProperty = 4
	propertyTypes.ArrayProperty = 5
	propertyTypes.MapProperty = 6
	propertyTypes.ClassProperty = 7
	propertyTypes.SetProperty = 8
	propertyTypes.ScriptStruct = 8
	propertyTypes.Class = 9
	--Depreciated:
	propertyTypes.IntefaceProperty = 10
	propertyTypes.StrProperty = 11
	propertyTypes.TextProperty = 12
	propertyTypes.DelegateProperty = 13
	propertyTypes.MulticastDelegateProperty = 14
	propertyTypes.MulticastSparseDelegateProperty = 15
	propertyTypes.WeakObjectProperty = 16
	propertyTypes.LazyObjectProperty = 17
	propertyTypes.SoftObjectProperty = 18

local function GetObjectBaseOfAddress(address)
  local kls,adr = nil,nil
  local object = UE_CheckAddressAsObject(address)
  if object and object~=0 then
	local data = UE_GetObjectData(object)
	return data.ClassName,data.UObject
  end
  return nil--kls,adr
end

local function sizeToVarType(size)
  if(size<=0)then return 0 end
  local t = {}
    t[1]=vtByte
    t[2]=vtWord
    t[4]=vtDword
    t[8]=vtPointer
  for i=1,#t do
     if size==i then return t[i] end
  end
  return vtPointer
end
local function enumSizeToVarType(size)
  if(size<=0)then return 0 end
  local t = {}
    t[1]=vtByte
    t[2]=vtWord
    t[4]=vtDword
    t[8]=vtQointer
  for i=1,#t do
     if size==i then return t[i] end
  end
  return vtQointer
end

local function GetCEType(klass)
	if (ueToCETypes[klass]) then return ueToCETypes[klass]
	else return vtPointer
	end
end

local FIELD_INCLUDING = messageDialog("Dissector Selection: ","Should include fields of parent classes?",mtInformation,mbNo,mbYes)==mrYes and 1 or 0
local MAX_ALLOWED_SUBFIELDS = 20
function DissectOverride(structure,baseaddress)
      --if 1 then return false end
	local time = os.time()
	if (structure.Name:match('Autocreated from')=='Autocreated from') then return false end
	local kls,adr=GetObjectBaseOfAddress(baseaddress)
	--print(baseaddress,kls,adr)
	if adr~=baseaddress then
	  return false
	end --shit what happened???
	local data = UE_GetObjectData(baseaddress)
	print("\n------------------------ClassName: ", data.ClassName, '-------------------------------')
	local fields = UE_GetFieldsOfObject(baseaddress,FIELD_INCLUDING)
	if not(fields) then return false end
	table.sort(fields, function(a, b)
							  if (a.offset == b.offset) then
								 return a.FieldMask < b.FieldMask
							  end
							  return a.offset < b.offset
							 end)
	structure = structure and structure or createStructure("")
	structure.beginUpdate()
	local function nameConcat(preConcat,name,postConcat)
              --print(name)
		preConcat = preConcat and preConcat or ''
		postConcat = postConcat and postConcat or ''
		return preConcat..name..postConcat
	end

	local function addStructElement(structure,
					v,
					Address,
					mainOuterType, --OuterTypes
					preConcat, --name to concate previous to current name (used by nameConcat function)
					postConcat,--name to concate after the current name (used by nameConcat function)
					strTable,--if outer type is an array or map, it is a table of {stringToFind, stringToReplace}
					addOffset --next Offset to start (if array or map)
					)
          addOffset = addOffset and addOffset or 0
	local function MapSetDrawExtra()
                local mainName = nameConcat(preConcat,v.name,postConcat)
				local mainOffset = v.offset+addOffset
                local mapStruct = {}
                mapStruct['Elements.AllocationFlags.AllocatorInstance.InlineData[0]'] = {offset=0x10,size=4}  --ForElementType<uint32>
                mapStruct['Elements.AllocationFlags.AllocatorInstance.InlineData[1]'] = {offset=0x14,size=4}
                mapStruct['Elements.AllocationFlags.AllocatorInstance.InlineData[2]'] = {offset=0x18,size=4}
                mapStruct['Elements.AllocationFlags.AllocatorInstance.InlineData[3]'] = {offset=0x1C,size=4}
                mapStruct['Elements.AllocationFlags.AllocatorInstance.SecondaryData.Data'] = {offset=0x20,size=8}
                mapStruct['Elements.AllocationFlags.NumBits'] = {offset=0x28,size=4}
                mapStruct['Elements.AllocationFlags.MaxBits'] = {offset=0x2C,size=4}
                mapStruct['Elements.FirstFreeIndex'] = {offset=0x30,size=4} --usually==0xFFFFFFFF
                mapStruct['Elements.NumFreeIndices'] = {offset=0x34,size=4}
                mapStruct['Hash.InlineData[0]'] = {offset=0x38,size=4} --ForElementType<FSetElementId>
                mapStruct['-'] = {offset=0x3C,size=4} --padding
                mapStruct['Hash.SecondaryData.Data'] = {offset=0x40,size=8}
                mapStruct['HashSize'] = {offset=0x48,size=4}
                for kk,vv in pairs(mapStruct) do
                  local newElement = structure.addElement()
                  newElement.Name = mainName..'['..kk..']'
                  newElement.Offset = mainOffset+vv.offset
                  newElement.Vartype = sizeToVarType(vv.size)
                end
          end
          local function AddWeakObject()
            local element = structure.addElement()
            element.Name = nameConcat(preConcat,v.name..".ObjectIndex",postConcat)
            element.Vartype = vtDword
            element.Offset = v.offset+addOffset
            element = structure.addElement()
            element.Name = nameConcat(preConcat,v.name..".ObjectSerialNumber",postConcat)
            element.Vartype = vtDword
            element.Offset = v.offset+4+addOffset
          end
          local function AddSoftObjectPtr()
            AddWeakObject()
            local element = structure.addElement()
            element.Name = nameConcat(preConcat,v.name..".TagAtLastTest",postConcat)
            element.Vartype = vtDword
            element.Offset = v.offset+addOffset+0x8
            element = structure.addElement()
            element.Name = nameConcat(preConcat,v.name..".ObjectID.AssetPathName",postConcat)
            element.Vartype = vtQword
            element.Offset = v.offset+addOffset+0x10 --aligned
            element = structure.addElement()
            local mainName = nameConcat(preConcat,v.name..".ObjectID.SubPathString",postConcat)
            element.Offset = v.offset+addOffset+0x18
            element.Vartype = vtPointer
            element.Name = mainName..'[AllocatorInstance]'
            local newElement = structure.addElement()
            newElement.Name = mainName..'[ArrayNum]'
            newElement.Offset = element.Offset+8
            newElement.Vartype = vtDword
            newElement = structure.addElement()
            newElement.Name = mainName..'[ArrayMax]'
            newElement.Offset = element.Offset+12
            newElement.Vartype = vtDword
            element.ChildStruct=createStructure("")
            element.setChildStructStart(0)
            --Now just add a unicodestring element
            element = element.ChildStruct.addElement()
            element.Name = "Data"
            element.Vartype = vtUnicodeString
            element.Bytesize = 1000
          end
		if (v.PropertyType == propertyTypes.BoolProperty) then
			local element = structure.addElement()
			element.Name = nameConcat(preConcat,v.name..'['..v.FieldMask..']',postConcat)
			element.Vartype = GetCEType(v.class)
			element.Offset = v.offset+addOffset

		elseif (v.PropertyType == propertyTypes.ObjectProperty) then
			local element = structure.addElement()
			element.Name = nameConcat(preConcat,(mainOuterType==OuterTypes.None and v.name or v.SpecialName),postConcat)
			element.Vartype = GetCEType(v.class)
			element.Offset = v.offset+addOffset
			element.setChildStructStart(0)

		elseif (v.PropertyType == propertyTypes.StructProperty) then
			if (v.class == 'ScriptStruct') then --a "propertyTypes.StructProperty" can be a UScriptStruct or UStructProperty
			else
                            --preConcat = preConcat and preConcat..v.name or v.name
				if #v.SubFields > 0 then
					for kk,vv in pairs(v.SubFields) do
						addStructElement(structure,vv,Address,OuterTypes.Struct,preConcat,postConcat,strTable,addOffset)--,v.SpecialName..'.')
					end
				else
					local element = structure.addElement()
					element.Name = nameConcat(preConcat,v.name,postConcat)..'(struct '..v.SpecialName..')'
					element.Vartype = vtDword
					element.Offset = v.offset+addOffset
				end
			end

		elseif (v.PropertyType == propertyTypes.EnumProperty) then
			local element = structure.addElement()
			element.Name = nameConcat(preConcat,v.name,postConcat)
			element.Vartype = enumPropSizes[v.InnerSize] --GetCEType(v.class)
			element.Vartype = element.Vartype and element.Vartype or vtDword --if nil
			element.Offset = v.offset+addOffset

		elseif (v.PropertyType == propertyTypes.ArrayProperty) then
			local element = structure.addElement()
			local mainName = nameConcat(preConcat,v.name,postConcat)
			local mainOffset = v.offset+addOffset
			element.Name = mainName..'[AllocatorInstance]'
                        element.Offset = mainOffset
                        element.Vartype = vtPointer
			element.ChildStruct=createStructure("")
			element.setChildStructStart(0)
			local newElement = structure.addElement()
			newElement.Name = mainName..'[ArrayNum]'
			newElement.Offset = mainOffset+8
			newElement.Vartype = vtDword
			newElement = structure.addElement()
			newElement.Name = mainName..'[ArrayMax]'
			newElement.Offset = mainOffset+12
			newElement.Vartype = vtDword
			local count = readInteger(Address+mainOffset+0x8)
			print('Items: '..count, 'Allowed: '..MAX_ALLOWED_SUBFIELDS)
			count = count <= MAX_ALLOWED_SUBFIELDS and count or MAX_ALLOWED_SUBFIELDS
			for i=0,count-1 do
				local preConcat = string.format('[%d]%s<',i,v.name)
				addStructElement(element.ChildStruct,v.SubFields[1],readPointer(Address+mainOffset),OuterTypes.Array,preConcat,">",nil,i*v.InnerSize)--,v.SpecialName..'.')
			end
		elseif (v.PropertyType == propertyTypes.MapProperty) then
		   --print(fu(Address))
		   local element = structure.addElement()
			local mainName = nameConcat(preConcat,v.name,postConcat)
			local mainOffset = v.offset+addOffset
			element.Name = mainName..'[Elements.Data.AllocatorInstance]'
			element.Offset = mainOffset
			element.Vartype = vtPointer
			element.ChildStruct=createStructure("")
			element.setChildStructStart(0)
			local newElement = structure.addElement()
			newElement.Name = mainName..'[Elements.Data.ArrayNum]'
			newElement.Offset = mainOffset+8
			newElement.Vartype = vtDword
			newElement = structure.addElement()
			newElement.Name = mainName..'[Elements.Data.ArrayMax]'
			newElement.Offset = mainOffset+12
			newElement.Vartype = vtDword
			--addStructElement(structure,v.SubFields[1],OuterTypes.Struct)
                        local fld = v.SubFields[1]
                        fld.name = fld.SpecialName=="" and fld.class:gsub('Property','') or fld.SpecialName
                        fld = v.SubFields[2]
                        fld.name = fld.SpecialName=="" and fld.class:gsub('Property','') or fld.SpecialName
			local count = readInteger(Address+mainOffset+0x8)
			print('Items: '..count, 'Allowed: '..MAX_ALLOWED_SUBFIELDS)
			count = count <= MAX_ALLOWED_SUBFIELDS and count or MAX_ALLOWED_SUBFIELDS
			for i=0,count-1 do
			    local preConcat = string.format('[%d]%s.Key<',i,v.name)
			    addStructElement(element.ChildStruct,v.SubFields[1],readPointer(Address+mainOffset),OuterTypes.Map,preConcat,">",nil,i*v.MapData.size)--,v.SpecialName..'.')
				preConcat = string.format('[%d]%s.Value<',i,v.name)
				addStructElement(element.ChildStruct,v.SubFields[2],readPointer(Address+mainOffset),OuterTypes.Map,preConcat,">",nil,i*v.MapData.size)
			end
			MapSetDrawExtra()
		elseif (v.PropertyType == propertyTypes.SetProperty) or (v.class == 'SetProperty') then
		   local element = structure.addElement()
			local mainName = nameConcat(preConcat,v.name,postConcat)
			local mainOffset = v.offset+addOffset
			element.Name = mainName..'[Elements.Data.AllocatorInstance]'
			element.Offset = mainOffset
			element.Vartype = vtPointer
			element.ChildStruct=createStructure("")
			element.setChildStructStart(0)
			local newElement = structure.addElement()
			newElement.Name = mainName..'[Elements.Data.ArrayNum]'
			newElement.Offset = mainOffset+8
			newElement.Vartype = vtDword
			newElement = structure.addElement()
			newElement.Name = mainName..'[Elements.Data.ArrayMax]'
			newElement.Offset = mainOffset+12
			newElement.Vartype = vtDword
			--addStructElement(structure,v.SubFields[1],OuterTypes.Struct)
			local fld = v.SubFields[1]
			fld.name = fld.SpecialName=="" and fld.class:gsub('Property','') or fld.SpecialName
			local count = readInteger(Address+mainOffset+0x8)
			print('Items: '..count, 'Allowed: '..MAX_ALLOWED_SUBFIELDS)
			count = count <= MAX_ALLOWED_SUBFIELDS and count or MAX_ALLOWED_SUBFIELDS
			for i=0,count-1 do
			    local preConcat = string.format('[%d]%s<',i,v.name)
			    addStructElement(element.ChildStruct,v.SubFields[1],readPointer(Address+mainOffset),OuterTypes.Set,preConcat,">",nil,i*v.MapData.size)--,v.SpecialName..'.')
                        end
                        MapSetDrawExtra()
		elseif (v.PropertyType == propertyTypes.ClassProperty) then
			if (v.class == 'Class') then --a "propertyTypes.ClassProperty" can be a UClass or UClassProperty
			  local element = structure.addElement()
			  element.Name = nameConcat(preConcat,v.name,postConcat)
			  element.Vartype = vtPointer
			  element.Offset = v.offset+addOffset
                        elseif(v.class == 'SoftClassProperty') then --size=0x1C ; WeakObjectProperty WeakPtr,int32 TagAtLastTest,TObjectID ObjectID (struct {FName AssetPathName, FString SubPathString});
                          AddSoftObjectPtr()
                        else--if(v.class == 'ClassProperty')
			end
		elseif (v.class == 'StrProperty') then
                       --similar to array
			local element = structure.addElement()
			local mainName = nameConcat(preConcat,v.name,postConcat)
			local mainOffset = v.offset+addOffset --+addOffset
			element.Name = mainName..'[AllocatorInstance]'
                        element.Offset = mainOffset
                        element.Vartype = vtPointer
			local newElement = structure.addElement()
			newElement.Name = mainName..'[ArrayNum]'
			newElement.Offset = mainOffset+8
			newElement.Vartype = vtDword
			newElement = structure.addElement()
			newElement.Name = mainName..'[ArrayMax]'
			newElement.Offset = mainOffset+12
			newElement.Vartype = vtDword
			element.ChildStruct=createStructure("")
			element.setChildStructStart(0)
			--Now just add a unicodestring element
			element = element.ChildStruct.addElement()
			element.Name = "Data"
			element.Vartype = vtUnicodeString
			element.Bytesize = 1000

		elseif (v.class == 'NameProperty') then
                        local element = structure.addElement()
			element.Name = nameConcat(preConcat,v.name,postConcat)
			element.Vartype = vtQword
			element.Offset = v.offset+addOffset
		elseif (v.class == 'TextProperty') then
		  --size=0xC ; ITextData(pointer) TextData.Object, FReferenceControllerBase(pointer) TextData.SharedReferenceCount.ReferenceController, int Flags;
			local element = structure.addElement()
			element.Name = nameConcat(preConcat,v.name..".TextData.Object",postConcat)
			element.Vartype = vtPointer
			element.Offset = v.offset+addOffset
			local ptr = readPointer(Address+element.Offset)
			print('Ptr: ',fu(ptr))
			local innerOffset = readPointer(readPointer(ptr+0x28)) and 0x28 or 0x88
			innerOffset = (innerOffset==0x88 and readPointer(readPointer(ptr+0x88))) and 0x88 or 0x28 --if 0x88 is valid pointer then choose 0x88 else 0x28
			--element = structure.addElement()
			local chldStr = createStructure("")--element.ChildStruct
			local inelement = chldStr.addElement() --inner Child
			inelement.Name = "DisplayString[AllocatorInstance]"
			inelement.Vartype = vtPointer
			inelement.Offset = innerOffset  --0x88
			inelement.ChildStruct=createStructure("")
			inelement.setChildStructStart(0)
			inelement = inelement.ChildStruct.addElement()
			inelement.Name = "Data"
			inelement.Vartype = vtUnicodeString
			inelement.Bytesize = 1000

			inelement = chldStr.addElement()
			inelement.Name = "DisplayString[ArrayNum]"
			inelement.Vartype = vtDword
			inelement.Offset = innerOffset+8
			inelement = chldStr.addElement()
			inelement.Name = "DisplayString[ArrayMax]"
			inelement.Vartype = vtDword
			inelement.Offset = innerOffset+0xC
			element.ChildStruct=chldStr--createStructure("")
			element.setChildStructStart(0)

			element = structure.addElement()
			element.Name = nameConcat(preConcat,v.name..".TextData.SharedReferenceCount.ReferenceController",postConcat)
			element.Vartype = vtPointer
			element.Offset = v.offset+addOffset+8
			element = structure.addElement()
			element.Name = nameConcat(preConcat,v.name..".Flags",postConcat)
			element.Vartype = vtDword
			element.Offset = v.offset+addOffset+0x10
		elseif (v.class == 'WeakObjectProperty') then
                       --size=0x08 ; int ObjectIndex, int ObjectSerialNumber
                       AddWeakObject()
		elseif (v.class == 'LazyObjectProperty') then
                       --size=0x1C ; WeakObjectProperty WeakPtr,int32 TagAtLastTest,TObjectID ObjectID (struct {int A,int B,int C,int D});
                       AddWeakObject()
                       local element = structure.addElement()
                        element.Name = nameConcat(preConcat,v.name..".TagAtLastTest",postConcat)
                        element.Vartype = vtDword
                        element.Offset = v.offset+addOffset+0x8
                        element = structure.addElement()
                        element.Name = nameConcat(preConcat,v.name..".ObjectID.Guid.A",postConcat)
                        element.Vartype = vtDword
                        element.Offset = v.offset+addOffset+0xC
                        element = structure.addElement()
                        element.Name = nameConcat(preConcat,v.name..".ObjectID.Guid.B",postConcat)
                        element.Vartype = vtDword
                        element.Offset = v.offset+addOffset+0x10
                        element = structure.addElement()
                        element.Name = nameConcat(preConcat,v.name..".ObjectID.Guid.C",postConcat)
                        element.Vartype = vtDword
                        element.Offset = v.offset+addOffset+0x14
                        element = structure.addElement()
                        element.Name = nameConcat(preConcat,v.name..".ObjectID.Guid.D",postConcat)
                        element.Vartype = vtDword
                        element.Offset = v.offset+addOffset+0x18
		elseif (v.class == 'SoftObjectProperty') then
						--size=0x24 ; WeakObjectProperty WeakPtr,int32 TagAtLastTest,TObjectID ObjectID (struct {FName AssetPathName, FString SubPathString});
						AddSoftObjectPtr()
		elseif (v.class == 'DelegateProperty') or (v.class == 'MulticastDelegateProperty') or (v.class == 'MulticastInlineDelegateProperty') then
			--size=0x10 ; WeakObjectProperty Object, FName FunctionName;
			local element = structure.addElement()
			element.Name = nameConcat(preConcat,v.name..".ObjectIndex",postConcat)
			element.Vartype = vtDword
			element.Offset = v.offset+addOffset
                        element = structure.addElement()
			element.Name = nameConcat(preConcat,v.name..".ObjectSerialNumber",postConcat)
			element.Vartype = vtDword
			element.Offset = v.offset+4+addOffset
                        element = structure.addElement()
			element.Name = nameConcat(preConcat,v.name..".Name",postConcat)
			element.Vartype = vtQword
			element.Offset = v.offset+8+addOffset
		elseif (v.class == 'MulticastSparseDelegateProperty') or (v.class == 'ByteProperty')then
			local element = structure.addElement()
			element.Name = nameConcat(preConcat,v.name,postConcat)
			element.Vartype = vtByte
			element.Offset = v.offset+addOffset
		elseif (v.class == 'IntefaceProperty') then
			--size=0x10 ; UObject*	ObjectPointer,void* InterfacePointer;
			local element = structure.addElement()
			element.Name = nameConcat(preConcat,v.name..'.ObjectPointer',postConcat)
			element.Vartype = vtPointer
			element.Offset = v.offset+addOffset
			element = structure.addElement()
			element.Name = nameConcat(preConcat,v.name..'.InterfacePointer',postConcat)
			element.Vartype = vtPointer
			element.Offset = v.offset+addOffset
		else
            local element = structure.addElement()
			element.Name = nameConcat(preConcat,v.name,postConcat)
			element.Vartype = GetCEType(v.class)
			element.Offset = v.offset+addOffset

		end

	end
	for k,v in pairs(fields) do
          print('('..v.class..')', v.name)
	  addStructElement(structure,v,baseaddress,OuterTypes.None)
	end
	structure.endUpdate()
	getLuaEngine().close()
	return true
end
--
--local BP_PlayerCharacter_Tutorial_C = 0x2B026044720
--local stru = createStructure('SSA')
--DissectOverride(stru,BP_PlayerCharacter_Tutorial_C)
--stru.addToGlobalStructureList()

structureDissectOverrideID=registerStructureDissectOverride(DissectOverride)
StructureNameLookupID=registerStructureNameLookup(GetObjectBaseOfAddress)

]]
local structDissectorDis = [[
unregisterStructureDissectOverride(structureDissectOverrideID)
structureDissectOverrideID=nil

unregisterStructureNameLookup(StructureNameLookupID)
StructureNameLookupID=nil
]]
menuItem.miUEStructDissect.OnClick = function(sender)
	if not(sender.Checked) then
		sender.Checked = true
		loadstring(structDissectorEn)()
	else
		sender.Checked = false
		loadstring(structDissectorDis)()
	end
end
menuItem.miDataCollectorForm.OnClick = function(sender)
	if not(UEForm) then
	   if (frmUEDataCollector) then frmUEDataCollector.destroy() end
	   local formPath = getCheatEngineDir()..[[\autorun\forms\GH_UE_Dumper.frm]]
	   UEForm = createFormFromFile(formPath)
	   UEForm.Name = 'frmUEDataCollector'
	   UEForm.Caption = 'Guided Hacking Unreal Engine Dumper'
	end
    UEForm.show()
	local function clearAllMethodsAndFields(form)
	  form.lvFields.Items.clear()
	  form.lvMethods.Items.clear()
	  form.gbClassInformation.Caption='Class Information'
	  form.comboFieldBaseAddress.Items.clear()
	  form.comboFieldBaseAddress.ItemIndex = -1
	  form.comboFieldBaseAddress.Text = ""
	end
	local function InstallFieldsAndMethods(form,fields,functions)
		local propertyTypes = {}
			propertyTypes.Unknown = 0
			propertyTypes.BoolProperty = 1
			propertyTypes.ObjectProperty = 2
			propertyTypes.StructProperty = 3
			propertyTypes.EnumProperty = 4
			propertyTypes.ArrayProperty = 5
			propertyTypes.MapProperty = 6
			propertyTypes.ClassProperty = 7
	  if not(form) then form = frmUEDataCollector end
	  clearAllMethodsAndFields(form)
	  if (fields and type(fields)=='table') then
		 table.sort(fields, function(a, b)
							  if (a.offset == b.offset) then
								 return a.FieldMask < b.FieldMask
							  end
							  return a.offset < b.offset
							 end)
		 form.lvFields.beginUpdate()
		 local function AddItem(form,v)
			 if (v.PropertyType == propertyTypes.StructProperty and #v.SubFields>0) then
				for i=1,#v.SubFields do
					AddItem(form,v.SubFields[i])
				end
			 else
			   local itm = form.lvFields.Items.add()
			   itm.Data = k
			   itm.Caption = string.format('%.3X',v.offset)
			   local name = v.name
				if (v.FieldMask~=-1) then
				   name = name..'['..v.FieldMask..']'
				end
				local objName = v.class
				if (objName:find('Object')) then
					objName = objName..'('..v.SpecialName..')'
				end
				if (v.PropertyType==propertyTypes.ArrayProperty and #v.SubFields > 0) then
					local inName = v.SubFields[1].PropertyType==propertyTypes.ObjectProperty and v.SubFields[1].SpecialName or v.SubFields[1].class:gsub('Property','')
					objName = objName..'<'..inName..'>'
				end
			   itm.SubItems.add(name)
			   itm.SubItems.add(objName) --property type
			   --itm.SubItems.add('')
			 end
		 end
		 for k,v in pairs(fields) do
			  AddItem(form,v)
		 end
		 form.lvFields.endUpdate()
	  end
	  if (functions and type(functions)=='table') then
		 table.sort(functions, function(a, b) return a.name:upper() < b.name:upper() end)
		 form.lvMethods.beginUpdate()
		 for k,v in pairs(functions) do
			 local itm = form.lvMethods.Items.add()
			 itm.Data = v.execFunc
			 itm.Caption = v.name
			 itm.SubItems.add(v.owner) --Owner
			 local returnType = ""
			 local fields = UE_GetFunctionParameters(v.ufunction)
			 if type(fields)=='table' then
				 local param = '('
				 for i=1,#fields do
					 local modeType;
					 if fields[i].PropertyType == propertyTypes.ObjectProperty and fields[i].SpecialName~="" then --ObjectProperty
						modeType = fields[i].SpecialName..'['..fields[i].class:gsub('Property','')..']'
					 elseif fields[i].PropertyType == propertyTypes.ClassProperty and fields[i].SpecialName~="" then --ClassProperty
						modeType = fields[i].SpecialName..'['..fields[i].class:gsub('Property','')..']'
					 elseif fields[i].PropertyType == propertyTypes.StructProperty and fields[i].SpecialName~="" then --StructProperty
						modeType = fields[i].SpecialName..'['..fields[i].class:gsub('Property','')..']'
					 elseif fields[i].PropertyType == propertyTypes.EnumProperty and fields[i].SpecialName~="" and fields[i].InnerSize~=-1 then --EnumProperty
						modeType = fields[i].SpecialName..'['..fields[i].class:gsub('Property','')..(fields[i].InnerSize*8)..']'
					 elseif fields[i].PropertyType == propertyTypes.ArrayProperty and #fields[i].SubFields > 0 then
						local inName = fields[i].SubFields[1].PropertyType==propertyTypes.ObjectProperty and fields[i].SubFields[1].SpecialName or fields[i].SubFields[1].class:gsub('Property','')
						modeType = fields[i].class:gsub('Property','')..'<'..inName..'>'
					 else
						modeType = fields[i].class:gsub('Property','')
					 end
					 if (fields[i].name:find('ReturnValue')) then
					   returnType = modeType..' '
					 else
					   param = param..modeType..' '..fields[i].name
					 end
					 --print(param)
					 if i<#fields and not(fields[i+1].name:find('ReturnValue')) then param = param..', ' end
				 end
				 param = returnType..param..')'
				 itm.SubItems.add(param) --Parameters
				 itm.SubItems.add(fu(v.ufunction))  --UFunction
			 else
				 itm.SubItems.add('-') --Parameters
				 itm.SubItems.add(fu(v.ufunction))  --UFunction
			 end
		 end
		 form.lvMethods.endUpdate()
	  end
	end

	local function InheritanceResize(gbInheritance, now)
	  --print('resize called')
	  if delayedResize==nil then
		local f=function()
		--print('inner resize called')
		  local i,x,y
		  local width=gbInheritance.ClientWidth

		  x=0
		  y=0

		  for i=0 , gbInheritance.ControlCount-1 do
			local c=gbInheritance.Control[i]
			if (x~=0) and (x+c.Width>width) then
			  x=0
			  y=y+c.height
			end

			c.Left=2+x
			c.Top=y


			x=x+c.Width+1
		  end
		  delayedResize=nil
		end

		if now then
		  f()
		else
		  delayedResize=createTimer(100,f)
		end
	  else
		--reset timer
		delayedResize.Enabled=false
		delayedResize.Enabled=true
	  end
	end
	local function InstallInheritance(Inherit)
	 --delete previous controls
	  while frmUEDataCollector.gbInheritance.ControlCount>0 do
		frmUEDataCollector.gbInheritance.Control[0].destroy()
	  end
	  local ClassList = {}
	  for i=1,#Inherit do
		  ClassList[i]=Inherit[i]
	  end
	  if (ClassList and #ClassList>0) then
		 for i=1,#ClassList do
			l=createLabel(frmUEDataCollector.gbInheritance)
			local fullname=ClassList[i].name
			l.Caption=fullname
			ClassList[i].Label=l

			if i==1 then
			  l.Font.Style="[fsBold]"
			else
			  l.Font.Style="[fsUnderline]"
			  l.Font.Color=clBlue
			end
			l.Cursor=crHandPoint
			InheritanceResize(frmUEDataCollector.gbInheritance, true)
			l.OnMouseDown=function(s)
			  local j
			  for j=1,#ClassList do
				if j==i then
				  ClassList[j].Label.Font.Color=clWindowText
				  ClassList[j].Label.Font.Style="[fsBold]"
				  if (ClassList[j].klass) then
					clearAllMethodsAndFields(frmUEDataCollector)
					local fields = UE_GetFieldsOfClass(ClassList[j].name,1)
					local functions = UE_GetFunctionsOfClass(ClassList[j].name,1)
					InstallFieldsAndMethods(frmUEDataCollector,fields,functions)
					local klss = UEForm.lbClasses
					local itemm = klss.Items[klss.getItemIndex()]
					if itemm then
					   UEForm.gbClassInformation.Caption = itemm
					else
						UEForm.gbClassInformation.Caption = ClassList[j].name
					end
				  end
				else
				  ClassList[j].Label.Font.Style="[fsUnderline]"
				  ClassList[j].Label.Font.Color=clBlue
				end
			  end
			  InheritanceResize(frmUEDataCollector.gbInheritance, true)
			end

			if i~=#ClassList then --not the last item
			  l=createLabel(frmUEDataCollector.gbInheritance)
			  l.Caption="->"
			end
		  end
	  end
	  --create new controls
	end
	local function GetArrangedTable(MainTable)
	  local tTable = {}
	  for k,v in pairs(MainTable) do
		tTable[#tTable+1] = k
	  end
	  table.sort(tTable, function(a, b) return a:upper() < b:upper() end)
	  return tTable
	end


	local function ReadStringFromPipe()
	  local retStr = ""
	  local strc = UnrealPipe.readWord()
	  retStr = UnrealPipe.readString(strc);
	  return retStr
	end
	local function InitUE4Loud(form, progressbar)
	  if (type(frmUEDataCollector)~='userdata') then return end
	  OBJECTS_STORE = {}
	  UNIQUE_CLASSES = {}
	  local count = 0
	  local klscount = 0
	  local prog = progressbar
	  form.ScanButton.Enabled = false
	  --print(Total)
	  Total = UE_CountObjects()
	  prog.setMin(0)
	  prog.setMax(Total-1)
	  for i=0x0,Total-1 do
		  UnrealPipe.lock()
		  UnrealPipe.writeByte(4) --ObjectAtIndex
		  UnrealPipe.writeDword(i)
		  if (UnrealPipe.readByte()==1) then
			if (UnrealPipe.readByte()==1) then
				local objectx = {}
				objectx.address = UnrealPipe.readQword()
				objectx.classAddress = UnrealPipe.readQword()
				objectx.size = UnrealPipe.readDword()
				objectx.class = ReadStringFromPipe()
				OBJECTS_STORE[#OBJECTS_STORE+1]=objectx
				if not(UNIQUE_CLASSES[objectx.class]) then
				  UNIQUE_CLASSES[objectx.class] = objectx
				  klscount = klscount+1
				end
				count = count+1
			end
		  end
		  UnrealPipe.unlock()
		  prog.stepBy(1)
	  end
	  prog.setPosition(0)
	  form.lblObjCount.Caption = 'Total Objects: '..count
	  form.lblClasses.Caption = 'Total Classes: '..klscount
	  form.ScanButton.Enabled = true
	end

	local function frmUEDataCollector_ScanButtonClick(sender)
	  if (type(InitUE4Loud)~= 'function') then print('Please enable the \"Unreal Engine Initialize\" first!') return end
	  frmUEDataCollector.btnClassList.Caption= 'Init Class List'
	  frmUEDataCollector.lblObjCount.Caption = 'Total Objects: '..0
	  frmUEDataCollector.lblClasses.Caption = 'Total Classes: '..0
	  InitUE4Loud(frmUEDataCollector, frmUEDataCollector.scanProgress)
	end

	local function frmUEDataCollector_btnClassListClick(sender)
	  if (sender.Caption=='Init Class List') then
		  local arrangedClasses = GetArrangedTable(UNIQUE_CLASSES)
		  sender.Caption = 'Clear Class List'
		  UEForm.lbClasses.clear()
		  local txtBx = UEForm.edtClassFilter
		  local all = txtBx.Text==""
		  local klssTextBox = UEForm.lbClasses
		  for k,v in pairs(arrangedClasses) do
			  if not(all) and (v:lower():find(txtBx.Text:lower(),1,true)) then
				 klssTextBox.Items.Add(v)
			  elseif (all) then
				  klssTextBox.Items.Add(v)
			  end
		  end
	  else
		  sender.Caption = 'Init Class List'
		  UEForm.lbClasses.clear()
	  end
	end

	local function frmUEDataCollector_lbClassesSelectionChange(sender, user)
	  local items = frmUEDataCollector.lbClasses.Items
	  local item = items[sender.ItemIndex]
	  local bool1 = (UNIQUE_CLASSES[item]) and UNIQUE_CLASSES[item].classAddress and UNIQUE_CLASSES[item].classAddress~=0
	  clearAllMethodsAndFields(frmUEDataCollector)
	  if (sender.ItemIndex > -1) and (bool1) then
		--print(item,UNIQUE_CLASSES[item].classAddress)
		 local inheritance = UE_GetClassInheritance(UNIQUE_CLASSES[item].class)
		 InstallInheritance(inheritance)
		  local fields = UE_GetFieldsOfClass(UNIQUE_CLASSES[item].class,1)
		  local functions = UE_GetFunctionsOfClass(UNIQUE_CLASSES[item].class,1)
		 InstallFieldsAndMethods(frmUEDataCollector,fields,functions)
		 frmUEDataCollector.gbClassInformation.Caption=item
	  end
	end

	local function frmUEDataCollector_edtClassFilterChange(sender)
	  local klssTextBox = frmUEDataCollector.lbClasses
	  if frmUEDataCollector.btnClassList.Caption == 'Init Class List' then
		 klssTextBox.Items.clear()
		 return
	  end
	  klssTextBox.clear()
	  local arrangedClasses = GetArrangedTable(UNIQUE_CLASSES)
	  local all = sender.Text==""
	  for k,v in pairs(arrangedClasses) do
		  if not(all) and (v:lower():find(sender.Text:lower(),1,true)) then
			 klssTextBox.Items.Add(v)
		  elseif (all) then
			  klssTextBox.Items.Add(v)
		  end
	  end
	end

	local function frmUEDataCollector_lvMethodsDblClick(sender)
	  if (sender.Selected.Data) and readPointer(sender.Selected.Data) then
		 local str = sender.Selected.SubItems[1]
		 local retType = str:match('.- %(')
		 retType = retType and retType:gsub('%(',''):gsub(' ','') or ""
		 local fields = str:match('%(.*%)')
		 fields = fields and fields:gsub('%(',''):gsub('%)','') or ""
		 --print(retType)print(fields)
		 local syml = getMainSymbolList()
		 local regName = sender.Selected.SubItems[0]..':'..sender.Selected.Caption
		 if not(syml.getSymbolFromString(regName)) then
			syml.addSymbol("UE4",regName,getAddressSafe(sender.Selected.Data),1,false,{returntype="",parameters=""})
		 end
		 getMemoryViewForm().DisassemblerView.SelectedAddress = getAddressSafe(sender.Selected.Data)
		 getMemoryViewForm().show()
	  end
	end

	local function frmUEDataCollector_ResetBtnClick(sender)
	  clearAllMethodsAndFields(frmUEDataCollector)
	  while frmUEDataCollector.gbInheritance.ControlCount>0 do
		frmUEDataCollector.gbInheritance.Control[0].destroy()
	  end
	  frmUEDataCollector.btnClassList.Caption= 'Init Class List'
	  frmUEDataCollector.lblObjCount.Caption = 'Total Objects: '..0
	  frmUEDataCollector.lblClasses.Caption = 'Total Classes: '..0
	  frmUEDataCollector.lbClasses.clear()
	  frmUEDataCollector.edtClassFilter.Text = ""
	  UEForm.ScanButton.Enabled = true
	end

	local function frmUEDataCollector_btnLoadAllObjectsClick(sender)
	  --print('clicked')
	  local name = frmUEDataCollector.gbClassInformation.Caption
	  if (name=='Class Information') then return end
	  frmUEDataCollector.comboFieldBaseAddress.Items.clear()
	  local objects = UE_GetAllObjectsOfClass(name)
	  local comboItems = frmUEDataCollector.comboFieldBaseAddress.Items
	  for i=1,#objects do
		 if (readPointer(objects[i].obj)) then
		   local itm = comboItems.Add(fu(objects[i].obj)..'\t'..objects[i].name)
		   frmUEDataCollector.comboFieldBaseAddress.Items.setData(itm,(objects[i].obj))
		   --print(frmUEDataCollector.comboFieldBaseAddress.Items.getData(itm))
		 else
		   printf('%s was a null object.',objects[i].name)
		 end
		 --print(itm,type(itm))
	  end
	end

	local function frmUEDataCollector_miBrowseFieldClick(sender)
	  local addr = frmUEDataCollector.comboFieldBaseAddress.Text:match('%x*\t')
	  if not(addr) or addr=="" or not(getAddressSafe(addr)) then return end
	  local offset = 0
	  offset = frmUEDataCollector.lvFields.Selected and tonumber(frmUEDataCollector.lvFields.Selected.Caption,16) or offset
	  getMemoryViewForm().HexadecimalView.Address = getAddressSafe(addr)+offset
	  getMemoryViewForm().show()
	end

	local function frmUEDataCollector_miGoToExecFuncClick(sender)
	  frmUEDataCollector_lvMethodsDblClick(UEForm.lvMethods)
	end

	local function frmUEDataCollector_miCopyFuncClick(sender)
	 local sel = UEForm.lvMethods.Selected
	 if not(sel) then writeToClipboard(0) return end
	 writeToClipboard(sel.SubItems[2]) --UFunction
	end

	local function frmUEDataCollector_miCopyClassClick(sender)
	  if (UEForm.lbClasses.ItemIndex==-1) then return end
	  local classes = UEForm.lbClasses
	  local txt = classes.Items[classes.ItemIndex]
	  writeToClipboard(txt)
	  --print(sender.Selected)
	end
	local function frmUEDataCollector_miCopyFieldDataClick(sender)
	  if not(UEForm.lvFields.Selected) then return end
	  local fields = UEForm.lvFields
	  local txt = fields.Selected.Caption..' - '..fields.Selected.SubItems[0]..' - '..fields.Selected.SubItems[1]--..' - '..  ..' - '..
	  writeToClipboard(txt)
	end
	local function frmUEDataCollector_miCopyFuncNameClick(sender)
	  if not(UEForm.lvMethods.Selected) then return end
	  writeToClipboard(UEForm.lvMethods.Selected.Caption)
	end
	local function frmUEDataCollector_miCopyFuncClassClick(sender)
	  if not(UEForm.lvMethods.Selected) then return end
	  writeToClipboard(UEForm.lvMethods.Selected.SubItems[0])
	end
	local function frmUEDataCollector_miCopyParamsClick(sender)
	  if not(UEForm.lvMethods.Selected) then return end
	  writeToClipboard(UEForm.lvMethods.Selected.SubItems[1])
	end

	UEForm.ScanButton.OnClick = function(sender)
	   frmUEDataCollector_ScanButtonClick(sender)
	end
	UEForm.btnClassList.OnClick = function(sender)
	   frmUEDataCollector_btnClassListClick(sender)
	end
	UEForm.ResetBtn.OnClick = function(sender)
	   frmUEDataCollector_ResetBtnClick(sender)
	end
	UEForm.btnLoadAllObjects.OnClick = function(sender)
	   frmUEDataCollector_btnLoadAllObjectsClick(sender)
	end
	UEForm.lbClasses.OnSelectionChange = function(sender,user)
	   LaunchUEDataCollector()
	   InitUE()
	   frmUEDataCollector_lbClassesSelectionChange(sender,user)
	end
	UEForm.edtClassFilter.OnChange = function(sender)
	   frmUEDataCollector_edtClassFilterChange(sender)
	end
	UEForm.lvMethods.OnDblClick = function(sender)
	   frmUEDataCollector_lvMethodsDblClick(sender)
	end
	UEForm.miBrowseField.OnClick = function(sender)
	   frmUEDataCollector_miBrowseFieldClick(sender)
	end
	UEForm.miGoToExecFunc.OnClick = function(sender)
	   frmUEDataCollector_miGoToExecFuncClick(sender)
	end
	UEForm.btnDumpObjects.OnClick = function(sender)
	  UE_DumpObjects()
	  --print('Object Successfully Dumped')
	end
	UEForm.lblAbout.OnMouseEnter = function(sender)
	  sender.Color = clSkyBlue
	end
	UEForm.lblAbout.OnMouseLeave = function(sender)
	  sender.Color = clDefault
	end
	UEForm.lblAbout.OnMouseDown = function(sender)
	  shellExecute('https://guidedhacking.com/resources/guided-hacking-unreal-engine-dumper-cheat-engine-plugin.763/')
	end
	UEForm.ghLogo.OnClick = function(sender)
	 shellExecute('https://guidedhacking.com/')
	end
	UEForm.miCopyFunc.OnClick = function(sender)
		frmUEDataCollector_miCopyFuncClick(sender)
	end
	UEForm.miCopyClass.OnClick = function(sender)
		frmUEDataCollector_miCopyClassClick(sender)
	end
	UEForm.miCopyFieldData.OnClick = function(sender)
		frmUEDataCollector_miCopyFieldDataClick(sender)
	end
	UEForm.miCopyFuncName.OnClick = function(sender)
		frmUEDataCollector_miCopyFuncNameClick(sender)
	end
	UEForm.miCopyFuncClass.OnClick = function(sender)
		frmUEDataCollector_miCopyFuncClassClick(sender)
	end
	UEForm.miCopyParams.OnClick = function(sender)
		frmUEDataCollector_miCopyParamsClick(sender)
	end
	UEForm.btnDumpNames.OnClick = function(sender)
		UE_DumpNames()
	end
end


