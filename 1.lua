--[[
	*****************************************************
	*Author: PeaceBeUponYou               				*
	*Contact: 				              				*
	*	Discord: PeaceBeUponYou#0085  					*
	*	Patreon: https://www.patreon.com/peaceCheats	*
	*Only available on:                   				*
	*   https://guidedhacking.com/        				*
	*****************************************************
	Unreal Data Collector
	Current Supported Versions:
		*4.11 - 4.27
	This file has all the functions to connect and utilize the Unreal Pipe Server
]]
	-- 在脚本的最上方，建议加上这句来加载 bit 库，这样位运算更方便

local EFunctionFlags =
{
	FUNC_None			= 0x00000000,

	FUNC_Final			= 0x00000001,--	// Function is final (prebindable, non-overridable function).
	FUNC_RequiredAPI		= 0x00000002,--	// Indicates this function is DLL exported/imported.
	FUNC_BlueprintAuthorityOnly     = 0x00000004,--   // Function will only run if the object has network authority
	FUNC_BlueprintCosmetic	        = 0x00000008,--   // Function is cosmetic in nature and should not be invoked on dedicated servers
	-- FUNC_				= 0x00000010,   // unused.
	-- FUNC_				= 0x00000020,   // unused.
	FUNC_Net			= 0x00000040,--   // Function is network-replicated.
	FUNC_NetReliable		= 0x00000080,--   // Function should be sent reliably on the network.
	FUNC_NetRequest			= 0x00000100,--	// Function is sent to a net service
	FUNC_Exec			= 0x00000200,--	// Executable from command line.
	FUNC_Native			= 0x00000400,--	// Native function.
	FUNC_Event			= 0x00000800,--   // Event function.
	FUNC_NetResponse		= 0x00001000,--   // Function response from a net service
	FUNC_Static			= 0x00002000,--   // Static function.
	FUNC_NetMulticast		= 0x00004000,--	// Function is networked multicast Server -> All Clients
	FUNC_UbergraphFunction	        = 0x00008000,--   // Function is used as the merge 'ubergraph' for a blueprint, only assigned when using the persistent 'ubergraph' frame
	FUNC_MulticastDelegate	        = 0x00010000,--	// Function is a multi-cast delegate signature (also requires FUNC_Delegate to be set!)
	FUNC_Public			= 0x00020000,--	// Function is accessible in all classes (if overridden, parameters must remain unchanged).
	FUNC_Private			= 0x00040000,--	// Function is accessible only in the class it is defined in (cannot be overridden, but function name may be reused in subclasses.  IOW: if overridden, parameters don't need to match, and Super.Func() cannot be accessed since it's private.)
	FUNC_Protected			= 0x00080000,--	// Function is accessible only in the class it is defined in and subclasses (if overridden, parameters much remain unchanged).
	FUNC_Delegate			= 0x00100000,--	// Function is delegate signature (either single-cast or multi-cast, depending on whether FUNC_MulticastDelegate is set.)
	FUNC_NetServer			= 0x00200000,--	// Function is executed on servers (set by replication code if passes check)
	FUNC_HasOutParms		= 0x00400000,--	// function has out (pass by reference) parameters
	FUNC_HasDefaults		= 0x00800000,--	// function has structs that contain defaults
	FUNC_NetClient			= 0x01000000,--	// function is executed on clients
	FUNC_DLLImport			= 0x02000000,--	// function is imported from a DLL
	FUNC_BlueprintCallable	        = 0x04000000,--	// function can be called from blueprint code
	FUNC_BlueprintEvent		= 0x08000000,--	// function can be overridden/implemented from a blueprint
	FUNC_BlueprintPure		= 0x10000000,--	// function can be called from blueprint code, and is also pure (produces no side effects). If you set this, you should set FUNC_BlueprintCallable as well.
	FUNC_EditorOnly			= 0x20000000,--	// function can only be called from an editor scrippt.
	FUNC_Const			= 0x40000000,--	// function can be called from blueprint code, and only reads state (never writes state)
	FUNC_NetValidate		= 0x80000000,--	// function must supply a _Validate implementation

	FUNC_AllFlags		= 0xFFFFFFFF,
}
local EClassCastFlags = -- uint64 //property cast class flags
{
	CASTCLASS_None = 0x0000000000000000,
	CASTCLASS_UField = 0x0000000000000001,
	CASTCLASS_FInt8Property = 0x0000000000000002,
	CASTCLASS_UEnum = 0x0000000000000004,
	CASTCLASS_UStruct = 0x0000000000000008,
	CASTCLASS_UScriptStruct = 0x0000000000000010,
	CASTCLASS_UClass = 0x0000000000000020,
	CASTCLASS_FByteProperty = 0x0000000000000040,
	CASTCLASS_FIntProperty = 0x0000000000000080,
	CASTCLASS_FFloatProperty = 0x0000000000000100,
	CASTCLASS_FUInt64Property = 0x0000000000000200,
	CASTCLASS_FClassProperty = 0x0000000000000400,
	CASTCLASS_FUInt32Property = 0x0000000000000800,
	CASTCLASS_FInterfaceProperty = 0x0000000000001000,
	CASTCLASS_FNameProperty = 0x0000000000002000,
	CASTCLASS_FStrProperty = 0x0000000000004000,
	CASTCLASS_FProperty = 0x0000000000008000,
	CASTCLASS_FObjectProperty = 0x0000000000010000,
	CASTCLASS_FBoolProperty = 0x0000000000020000,
	CASTCLASS_FUInt16Property = 0x0000000000040000,
	CASTCLASS_UFunction = 0x0000000000080000,
	CASTCLASS_FStructProperty = 0x0000000000100000,
	CASTCLASS_FArrayProperty = 0x0000000000200000,
	CASTCLASS_FInt64Property = 0x0000000000400000,
	CASTCLASS_FDelegateProperty = 0x0000000000800000,
	CASTCLASS_FNumericProperty = 0x0000000001000000,
	CASTCLASS_FMulticastDelegateProperty = 0x0000000002000000,
	CASTCLASS_FObjectPropertyBase = 0x0000000004000000,
	CASTCLASS_FWeakObjectProperty = 0x0000000008000000,
	CASTCLASS_FLazyObjectProperty = 0x0000000010000000,
	CASTCLASS_FSoftObjectProperty = 0x0000000020000000,
	CASTCLASS_FTextProperty = 0x0000000040000000,
	CASTCLASS_FInt16Property = 0x0000000080000000,
	CASTCLASS_FDoubleProperty = 0x0000000100000000,
	CASTCLASS_FSoftClassProperty = 0x0000000200000000,
	CASTCLASS_UPackage = 0x0000000400000000,
	CASTCLASS_ULevel = 0x0000000800000000,
	CASTCLASS_AActor = 0x0000001000000000,
	CASTCLASS_APlayerController = 0x0000002000000000,
	CASTCLASS_APawn = 0x0000004000000000,
	CASTCLASS_USceneComponent = 0x0000008000000000,
	CASTCLASS_UPrimitiveComponent = 0x0000010000000000,
	CASTCLASS_USkinnedMeshComponent = 0x0000020000000000,
	CASTCLASS_USkeletalMeshComponent = 0x0000040000000000,
	CASTCLASS_UBlueprint = 0x0000080000000000,
	CASTCLASS_UDelegateFunction = 0x0000100000000000,
	CASTCLASS_UStaticMeshComponent = 0x0000200000000000,
	CASTCLASS_FMapProperty = 0x0000400000000000,
	CASTCLASS_FSetProperty = 0x0000800000000000,
	CASTCLASS_FEnumProperty = 0x0001000000000000,
	CASTCLASS_USparseDelegateFunction = 0x0002000000000000,
	CASTCLASS_FMulticastInlineDelegateProperty = 0x0004000000000000,
	CASTCLASS_FMulticastSparseDelegateProperty = 0x0008000000000000,
	CASTCLASS_FFieldPathProperty = 0x0010000000000000,
}
local EPropertyFlags= --uint64 //PropertyFlags
{
	CPF_None = 0,
	CPF_Edit = 0x0000000000000001,--  ///< Property is user-settable in the editor.
	CPF_ConstParm = 0x0000000000000002,--	///< This is a constant function parameter
	CPF_BlueprintVisible = 0x0000000000000004,--	///< This property can be read by blueprint code
	CPF_ExportObject = 0x0000000000000008,--	///< Object can be exported with actor.
	CPF_BlueprintReadOnly = 0x0000000000000010,--	///< This property cannot be modified by blueprint code
	CPF_Net = 0x0000000000000020,--	///< Property is relevant to network replication.
	CPF_EditFixedSize = 0x0000000000000040,--	///< Indicates that elements of an array can be modified, but its size cannot be changed.
	CPF_Parm = 0x0000000000000080,--	///< Function/When call parameter.
	CPF_OutParm = 0x0000000000000100,--	///< Value is copied out after function call.
	CPF_ZeroConstructor = 0x0000000000000200,--	///< memset is fine for construction
	CPF_ReturnParm = 0x0000000000000400,--	///< Return value.
	CPF_DisableEditOnTemplate = 0x0000000000000800,--	///< Disable editing of this property on an archetype/sub-blueprint
	--//CPF_      						= 0x0000000000001000,	///< 
	CPF_Transient = 0x0000000000002000,--	///< Property is transient: shouldn't be saved or loaded, except for Blueprint CDOs.
	CPF_Config = 0x0000000000004000,--	///< Property should be loaded/saved as permanent profile.
	--//CPF_								= 0x0000000000008000,	///< 
	CPF_DisableEditOnInstance = 0x0000000000010000,--	///< Disable editing on an instance of this class
	CPF_EditConst = 0x0000000000020000,--	///< Property is uneditable in the editor.
	CPF_GlobalConfig = 0x0000000000040000,--	///< Load config from base class, not subclass.
	CPF_InstancedReference = 0x0000000000080000,--	///< Property is a component references.
	--//CPF_								= 0x0000000000100000,	///<
	CPF_DuplicateTransient = 0x0000000000200000,--	///< Property should always be reset to the default value during any type of duplication (copy/paste, binary duplication, etc.)
	--//CPF_								= 0x0000000000400000,	///< 
	--//CPF_    							= 0x0000000000800000,	///< 
	CPF_SaveGame = 0x0000000001000000,--	///< Property should be serialized for save games, this is only checked for game-specific archives with ArIsSaveGame
	CPF_NoClear = 0x0000000002000000,--	///< Hide clear (and browse) button.
	--//CPF_  							= 0x0000000004000000,	///<
	CPF_ReferenceParm = 0x0000000008000000,--	///< Value is passed by reference; CPF_OutParam and CPF_Param should also be set.
	CPF_BlueprintAssignable = 0x0000000010000000,--	///< MC Delegates only.  Property should be exposed for assigning in blueprint code
	CPF_Deprecated = 0x0000000020000000,--	///< Property is deprecated.  Read it from an archive, but don't save it.
	CPF_IsPlainOldData = 0x0000000040000000,--	///< If this is set, then the property can be memcopied instead of CopyCompleteValue / CopySingleValue
	CPF_RepSkip = 0x0000000080000000,--	///< Not replicated. For non replicated properties in replicated structs 
	CPF_RepNotify = 0x0000000100000000,--	///< Notify actors when a property is replicated
	CPF_Interp = 0x0000000200000000,--	///< interpolatable property for use with matinee
	CPF_NonTransactional = 0x0000000400000000,--	///< Property isn't transacted
	CPF_EditorOnly = 0x0000000800000000,--	///< Property should only be loaded in the editor
	CPF_NoDestructor = 0x0000001000000000,--	///< No destructor
	--//CPF_								= 0x0000002000000000,	///<
	CPF_AutoWeak = 0x0000004000000000,--	///< Only used for weak pointers, means the export type is autoweak
	CPF_ContainsInstancedReference = 0x0000008000000000,--	///< Property contains component references.
	CPF_AssetRegistrySearchable = 0x0000010000000000,--	///< asset instances will add properties with this flag to the asset registry automatically
	CPF_SimpleDisplay = 0x0000020000000000,--	///< The property is visible by default in the editor details view
	CPF_AdvancedDisplay = 0x0000040000000000,--	///< The property is advanced and not visible by default in the editor details view
	CPF_Protected = 0x0000080000000000,--	///< property is protected from the perspective of script
	CPF_BlueprintCallable = 0x0000100000000000,--	///< MC Delegates only.  Property should be exposed for calling in blueprint code
	CPF_BlueprintAuthorityOnly = 0x0000200000000000,--	///< MC Delegates only.  This delegate accepts (only in blueprint) only events with BlueprintAuthorityOnly.
	CPF_TextExportTransient = 0x0000400000000000,--	///< Property shouldn't be exported to text format (e.g. copy/paste)
	CPF_NonPIEDuplicateTransient = 0x0000800000000000,--	///< Property should only be copied in PIE
	CPF_ExposeOnSpawn = 0x0001000000000000,--	///< Property is exposed on spawn
	CPF_PersistentInstance = 0x0002000000000000,--	///< A object referenced by the property is duplicated like a component. (Each actor should have an own instance.)
	CPF_UObjectWrapper = 0x0004000000000000,--	///< Property was parsed as a wrapper class like TSubclassOf<T>, FScriptInterface etc., rather than a USomething*
	CPF_HasGetValueTypeHash = 0x0008000000000000,--	///< This property can generate a meaningful hash value.
	CPF_NativeAccessSpecifierPublic = 0x0010000000000000,--	///< Public native access specifier
	CPF_NativeAccessSpecifierProtected = 0x0020000000000000,--	///< Protected native access specifier
	CPF_NativeAccessSpecifierPrivate = 0x0040000000000000,--	///< Private native access specifier
	CPF_SkipSerialization = 0x0080000000000000--	///< Property shouldn't be serialized, can still be exported to text
};
local EClassFlags = --uint32
{
	--/** No Flags */
	CLASS_None = 0x00000000,
	--/** Class is abstract and can't be instantiated directly. */
	CLASS_Abstract = 0x00000001,
	--/** Save object configuration only to Default INIs, never to local INIs. Must be combined with CLASS_Config */
	CLASS_DefaultConfig = 0x00000002,
	--/** Load object configuration at construction time. */
	CLASS_Config = 0x00000004,
	--/** This object type can't be saved; null it out at save time. */
	CLASS_Transient = 0x00000008,
	--/** Successfully parsed. */
	CLASS_Parsed = 0x00000010,
	--/** */
	CLASS_MatchedSerializers = 0x00000020,
	--/** Indicates that the config settings for this class will be saved to Project/User*.ini (similar to CLASS_GlobalUserConfig) */
	CLASS_ProjectUserConfig = 0x00000040,
	--/** Class is a native class - native interfaces will have CLASS_Native set, but not RF_MarkAsNative */
	CLASS_Native = 0x00000080,
	--/** Don't export to C++ header. */
	CLASS_NoExport = 0x00000100,
	--/** Do not allow users to create in the editor. */
	CLASS_NotPlaceable = 0x00000200,
	--/** Handle object configuration on a per-object basis, rather than per-class. */
	CLASS_PerObjectConfig = 0x00000400,

	--/** Whether SetUpRuntimeReplicationData still needs to be called for this class */
	CLASS_ReplicationDataIsSetUp = 0x00000800,

	--/** Class can be constructed from editinline New button. */
	CLASS_EditInlineNew = 0x00001000,
	--/** Display properties in the editor without using categories. */
	CLASS_CollapseCategories = 0x00002000,
	--/** Class is an interface **/
	CLASS_Interface = 0x00004000,
	--/**  Do not export a constructor for this class, assuming it is in the cpptext **/
	CLASS_CustomConstructor = 0x00008000,
	--/** all properties and functions in this class are const and should be exported as const */
	CLASS_Const = 0x00010000,

	--/** Class flag indicating the class is having its layout changed, and therefore is not ready for a CDO to be created */
	CLASS_LayoutChanging = 0x00020000,

	--/** Indicates that the class was created from blueprint source material */
	CLASS_CompiledFromBlueprint = 0x00040000,

	--/** Indicates that only the bare minimum bits of this class should be DLL exported/imported */
	CLASS_MinimalAPI = 0x00080000,

	--/** Indicates this class must be DLL exported/imported (along with all of it's members) */
	CLASS_RequiredAPI = 0x00100000,

	--/** Indicates that references to this class default to instanced. Used to be subclasses of UComponent, but now can be any UObject */
	CLASS_DefaultToInstanced = 0x00200000,

	--/** Indicates that the parent token stream has been merged with ours. */
	CLASS_TokenStreamAssembled = 0x00400000,
	--/** Class has component properties. */
	CLASS_HasInstancedReference = 0x00800000,
	--/** Don't show this class in the editor class browser or edit inline new menus. */
	CLASS_Hidden = 0x01000000,
	--/** Don't save objects of this class when serializing */
	CLASS_Deprecated = 0x02000000,
	--/** Class not shown in editor drop down for class selection */
	CLASS_HideDropDown = 0x04000000,
	--/** Class settings are saved to <AppData>/..../Blah.ini (as opposed to CLASS_DefaultConfig) */
	CLASS_GlobalUserConfig = 0x08000000,
	--/** Class was declared directly in C++ and has no boilerplate generated by UnrealHeaderTool */
	CLASS_Intrinsic = 0x10000000,
	--/** Class has already been constructed (maybe in a previous DLL version before hot-reload). */
	CLASS_Constructed = 0x20000000,
	--/** Indicates that object configuration will not check against ini base/defaults when serialized */
	CLASS_ConfigDoNotCheckDefaults = 0x40000000,
	--/** Class has been consigned to oblivion as part of a blueprint recompile, and a newer version currently exists. */
	CLASS_NewerVersionExists = 0x80000000,
};


local SET_UNREAL_VERSION = 0
local SET_UNREAL_OBJECTS_NAMES_ENGINE = 1
local UE_GETOBJECTSCOUNT = 2
local UE_INITALLOBJECTS = 3
local UE_LISTMODULES = 9
local UE_OBJECTAT = 4
local UE_END = 5
local UE_ENUM_FIELDS_FROM_OBJECT = 6
local UE_ENUM_FIELDS_FROM_CLASS = 7
local UE_ENUM_FUNCTIONS_FROM_OBJECT = 8
local UE_ENUM_FUNCTIONS_FROM_CLASS = 9
local GET_UNREAL_VERSION = 10
local GET_UNREAL_POINTERS = 11
local UE_GET_CLASS_INHERITANCE = 12
local UE_GET_ALL_OBJECTS_OF_CLASS = 13
local UE_GET_FUNCTION_PARAMETERS = 14
local UE_GET_OBJECT_DATA = 16
local UE_FNAME_TO_STRING = 17
local UE_GET_FUNCTION_DATA = 18
local UE_GET_OBJECT_AND_DATA = 19
local UE_GET_CURRENT_THREAD_ID = 21
local UE_GET_THREAD_TEB_ADDRESS = 22
local UE_PRINTOFFSETS = 31
local UE_AOB_SCAN = 32
local UE_GET_ALL_SUBOBJECTS_OF_CLASS = 33
local UE_SET_CONSOLE_FUNC = 34
local UE_GET_PROC_MAIN_THREAD = 35
local UE_THREAD_SAFE_INVOKE = 36
local UE_ISCLASS = 37
local UE_ISCLASSFAST = 38
local UE_DUMP_OBJECTS=100
local UE_DUMP_NAMES = 101
local UE_ENUM_ALL_CLASSES = 102
local UE_DUMP_INHERITANCE = 103
local UE_DUMP_CONSOLE_FUNCTIONS = 104
local UE_LAUNCH_DEBUG_CONSOLE = 200
local UE_CLOSE_DEBUG_CONSOLE = 201
local UE_ADJUST_OFFSET = 202
local UE_INVOKE_ACTOREVENT = 150
local UE_INVOKE_OBJECTEVENT = 151
szByte = 1
szWord = 2
szDword = 3
szFloat = 4
szQword = 5
szDouble = 6
szPointer = 7

UEVersion=0
local function ReadStringFromPipe()
  local retStr = ""
  local strc = UnrealPipe.readWord()
  retStr = UnrealPipe.readString(strc);
  return retStr
end
function UE_SigScan(moduleBaseAddress, moduleSize, scanType)
 UnrealPipe.lock()
 UnrealPipe.writeByte(UE_AOB_SCAN)
 UnrealPipe.writeQword(moduleBaseAddress)
 UnrealPipe.writeDword(moduleSize)
 UnrealPipe.writeDword(scanType)
 UnrealPipe.unlock()
 --return address
end
function UnrealScanner(customVersion,customModules)
	customModules = customModules and customModules or {}
	local function readFile(Path)
		local file,err = io.open(Path, 'r')
		assert(file,err)
		local sss = file:read("*all")
		file:close()
		return sss
	end
    local _time = os.time()
	local gameModule={}
	local modules = enumModules()
	--adding all modules with Shipping name
	gameModule[1] = modules[1]
	for i=2,#modules do
	  --print(modules[i].Name)
	  local v = modules[i]
	  if v.Name:find('Shipping') then
		 gameModule[#gameModule+1] = v
	  end
	  for kk,vv in pairs(customModules) do
		if v.Name:find(vv) then
			gameModule[#gameModule+1] = v
		end
	  end
	end

	if gameModule == nil or #gameModule==0 then
	 print('Shipping module not found! Trying the first Module instead')
	 gameModule[#gameModule+1] = modules[1]
	end
	print('Game Module(s):')
	for i,o in pairs(gameModule) do print('\t'..o.Name) end

-- =================================================================
-- ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
-- 【终极修复版 - 直接初始化】
print("AOB 扫描逻辑已被完全禁用，正在使用手动地址直接初始化...")

-- 1. 配置你的游戏模块名和准确的 RVA
local moduleName = "Mir4G.exe" 
local GObjects_RVA = 0x81259A0
local GNames_RVA   = 0x80E9300
local GEngine_RVA  = 0x8270D48 -- GEngine 通常就是 UWorld
-- 如果你知道其他地址的 RVA 也可以填上，不知道就留 0
local ActorEvent_RVA = 0x0 
local ObjectEvent_RVA = 0x0

-- 2. 计算基地址
local imageBase = getAddress(moduleName)
if imageBase == 0 then
  error("错误：找不到模块 '"..moduleName.."'，请检查模块名！")
end

-- 3. 定义一个辅助函数，用于计算并注册最终地址
local function RegisterFinalAddress(symbolName, rva)
  if not symbolName or not rva or rva == 0 then return 0 end
  
  local ptrAddress = imageBase + rva
  local finalAddress = readPointer(ptrAddress)
  
  if finalAddress and finalAddress > 0 then
    unregisterSymbol(symbolName)
    registerSymbol(symbolName, finalAddress, true)
    return finalAddress
  else
    print("警告: 无法读取 "..symbolName.." 的指针, RVA: " .. string.format("%X", rva))
    return 0
  end
end

-- 4. 直接注册所有需要的最终地址
RegisterFinalAddress('GObjects', GObjects_RVA)
RegisterFinalAddress('FUNames', GNames_RVA)
RegisterFinalAddress('GEngine', GEngine_RVA)
RegisterFinalAddress('Actor::ProcessEvent', ActorEvent_RVA)
RegisterFinalAddress('Object::ProcessEvent', ObjectEvent_RVA)


-- 5. 检查核心地址是否有效，然后直接调用初始化
if getAddressSafe('GObjects') > 0 and getAddressSafe('FUNames') > 0 then
  print("核心地址已成功注册，准备调用 InitUE().")
  InitUE()
  print('GEngine: ',fu(getAddressSafe('GEngine')))
  print('GObjects: ',fu(getAddressSafe('GObjects')))
  print('FUNames: ',fu(getAddressSafe('FUNames')))
  print('Actor::ProcessEvent: ',fu(getAddressSafe('Actor::ProcessEvent')))
  print('Object::ProcessEvent: ',fu(getAddressSafe('Object::ProcessEvent')))
  printf('Time taken by Manual Init: %d seconds',os.time()-_time)
else
  error("错误：GObjects 或 FUNames 地址计算失败，请检查 RVA！")
end

-- ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
-- =================================================================
end
function LaunchUEDataCollector()
  local time = os.time()
 if not(getAddressSafe('UnrealDataCollector64.dll')) or not(readPointer('UnrealDataCollector64.dll')) then
  local skipsymbols=getOperatingSystem()==1
  local dllPath = getAutorunPath()..'dlls\\UnrealDataCollector64.dll'
  local dllPathAlt = 'E:\\CE Plugins\\UnrealDataCollector64\\x64\\Release\\UnrealDataCollector64.dll'
  local function doesExist(path)
	  local f = io.open(path,'r')
	  if f~=nil then io.close(f) return true else return false end
  end
  if not(doesExist(dllPath)) then print('\"UnrealDataCollector64.dll\" is missing from \"autorun\\dlls\" folder!\nAre you sure you placed it there?') return end
    local injectResult, injectError=injectLibrary(dllPath, skipsymbols)
    if not injectResult then
      if injectError then
        print(translate("Failure injecting the UEDatacollector64 library"..":"..injectError))
		return
      else
        print(translate("Failure injecting the UEDatacollector64 library. No error given"))
		return
      end
    else
     waitForExports()
    end
   end
  if not(UnrealPipe) or not(UnrealPipe.Connected) then
	UnrealPipe = connectToPipe('ceUnrealPipe_proc'..getOpenedProcessID(),1000)
	--print('ceUnrealPipe_proc'..getOpenedProcessID())
	UnrealPipe.OnTimeout = function(pipe)
		print('UnrealPipe timeout')
		local oldpipe = UnrealPipe
		UnrealPipe = nil
		if (pipe) and (oldpipe) then 
			oldpipe.unlock()
			oldpipe.destroy()
		end
	end
	UnrealPipe.OnError = function(pipe)
		UnrealPipe.OnTimeout(pipe)
	end
  end
  if UnrealPipe==nil and readInteger('SERVER_PIPE')~=0 then
     writeBytes('FORCE_REINIT',01)
     UnrealPipe = connectToPipe('ceUnrealPipe_proc'..getOpenedProcessID(),1000)
  end

	waitforsymbols(true)
	waitForExports()
  return 1
end

function CloseUEDataCollector()
  UnrealPipe.destroy()
  UnrealPipe=nil
end

function UE_IsClass(obj,name)
  if UE_CheckAddressAsObject(obj)==0 then return false end
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_ISCLASS)
  UnrealPipe.writeQword(obj)
  UnrealPipe.writeWord(#name)
  UnrealPipe.writeString(name)
  local status = UnrealPipe.readDword()
  UnrealPipe.unlock()
  return status==1
end
function UE_IsClassQuick(object,klass)
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_ISCLASSFAST)
  UnrealPipe.writeQword(object)
  UnrealPipe.writeQword(klass)
  local retv = UnrealPipe.readDword()
  UnrealPipe.unlock()
  return retv
end

function UE_SetUnrealVersion(version)
  version = not(version) and 0 or version
  if UnrealPipe==nil then error('UnrealPipe is nil') print('UnrealPipe is nil') end
  UnrealPipe.lock()
  UnrealPipe.writeByte(SET_UNREAL_VERSION)
  UnrealPipe.writeDword(version)
  UnrealPipe.unlock()
end
function UE_SetGObjectAndNamePool(GUObjectArr,FNamePool,Gengine,ActorEvent,ObjectEvent)
  Gengine = Gengine and Gengine or 0
  ActorEvent = ActorEvent and ActorEvent or 0
  ObjectEvent = ObjectEvent and ObjectEvent or 0
  if not(GUObjectArr) or not(readPointer(GUObjectArr)) then print('some error in GUObjectArr') return end
  if not(FNamePool) or not(readPointer(FNamePool)) then print('some error in FNamePool') return end
  UnrealPipe.lock()
  UnrealPipe.writeByte(SET_UNREAL_OBJECTS_NAMES_ENGINE)
  UnrealPipe.writeQword(GUObjectArr)
  UnrealPipe.writeQword(FNamePool)
  UnrealPipe.writeQword(Gengine)
  UnrealPipe.writeQword(ActorEvent)
  UnrealPipe.writeQword(ObjectEvent)
  UnrealPipe.unlock()
end

function UE_GetUEVersion()
  UnrealPipe.writeByte(GET_UNREAL_VERSION)
  local ver = UnrealPipe.readDword()
  --print(ver/100)
  return ver
end
function UE_BasicPointers()
  UnrealPipe.writeByte(GET_UNREAL_POINTERS)
  local objectPool = UnrealPipe.readQword()
  local namePool = UnrealPipe.readQword()
  local gEngine = UnrealPipe.readQword()
  --print(objectPool)
  return objectPool,namePool,gEngine
end

function InitUE()
  if (UE_GetUEVersion()~=UEVersion) or UE_BasicPointers()~=getAddressSafe('GObjects') then
    UE_SetUnrealVersion(UEVersion)
    UE_SetGObjectAndNamePool(getAddressSafe('GObjects'),getAddressSafe('FUNames'),getAddressSafe('GEngine'),getAddressSafe('Actor::ProcessEvent'),getAddressSafe('Object::ProcessEvent'))
  end
end

function UE_CountObjects()
  if UnrealPipe==nil then error('UnrealPipe is nil') print('UnrealPipe is nil') end
  InitUE()
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_GETOBJECTSCOUNT)
  local totalCount = UnrealPipe.readDword()
  local availableCount = UnrealPipe.readDword()
  UnrealPipe.unlock()
  return totalCount,availableCount
end
function UE_EjectDllAndFree()
  UE_CloseConsole()
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_END)
  UnrealPipe.unlock()
  UnrealPipe = nil
end
function UE_GetNameFromFName(fname)
  LaunchUEDataCollector()
  if not(UnrealPipe) then error("Pipe not connected!") return end
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_FNAME_TO_STRING)
  UnrealPipe.writeQword(fname)
  local name = ReadStringFromPipe()
  UnrealPipe.unlock()
  return name
end
function UE_GetAllObjects()
  LaunchUEDataCollector()
  if not(UnrealPipe) then error("Pipe not connected!") return end
  InitUE()
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_INITALLOBJECTS)
  local OBJECTS_STORE = {}
  local flag = UnrealPipe.readByte()
  local flag2
  if (flag==0) then
     local currCount = UnrealPipe.readDword()
     --print(currCount)
     for i=1,currCount+1 do
         flag2 = UnrealPipe.readByte()
         if flag2==1 then
           local ind = #OBJECTS_STORE+1
           OBJECTS_STORE[ind] = {}
           OBJECTS_STORE[ind].address = UnrealPipe.readQword()
           OBJECTS_STORE[ind].class = UnrealPipe.readQword()
           OBJECTS_STORE[ind].size = UnrealPipe.readDword()
           local namelen = UnrealPipe.readWord()
           OBJECTS_STORE[ind].classname = UnrealPipe.readString(namelen)
         --print(uobjects[ind].classname)
         else
           --print('null object at: ',i)
         end
     end
     --print('done')
  elseif (flag==0xFF) then
    print('GUObjects are not initialized!')
  elseif (flag==0xFE) then
    print('required offset is missing, but why????')
  end
  --print(flag,flag2)
  UnrealPipe.unlock()
  return OBJECTS_STORE
end
function UE_DumpObjects()
  LaunchUEDataCollector()
  InitUE()
  local Path = 'C:\\Users\\'..os.getenv('USERNAME')..'\\Desktop\\'
  local filename= string.format('[%s] Objects Dump.txt',process:gsub('.exe',''))
  filename = Path..filename
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_DUMP_OBJECTS)
  UnrealPipe.writeWord(#filename)
  UnrealPipe.writeString(filename)
  UnrealPipe.unlock()
end
function UE_DumpConsoleFunctions()
  LaunchUEDataCollector()
  InitUE()
  local Path = 'C:\\Users\\'..os.getenv('USERNAME')..'\\Desktop\\'
  local filename= string.format('[%s] Console Functions.txt',process:gsub('.exe',''))
  filename = Path..filename
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_DUMP_CONSOLE_FUNCTIONS)
  UnrealPipe.writeWord(#filename)
  UnrealPipe.writeString(filename)
  UnrealPipe.unlock()
end
function UE_DumpNames()
  LaunchUEDataCollector()
  InitUE()
  local Path = 'C:\\Users\\'..os.getenv('USERNAME')..'\\Desktop\\'
  local filename= string.format('[%s] Names Dump.txt',process:gsub('.exe',''))
  filename = Path..filename
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_DUMP_NAMES)
  UnrealPipe.writeWord(#filename)
  UnrealPipe.writeString(filename)
  UnrealPipe.unlock()
end
function UE_DumpInheritancedClassOf(klassName)
  LaunchUEDataCollector()
  InitUE()
  local Path = 'C:\\Users\\'..os.getenv('USERNAME')..'\\Desktop\\'
  local filename= string.format('[%s] %s Dump.txt',process:gsub('.exe',''),klassName)
  filename = Path..filename
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_DUMP_INHERITANCE)
  UnrealPipe.writeWord(#filename)
  UnrealPipe.writeString(filename)
  UnrealPipe.writeWord(#klassName)
  UnrealPipe.writeString(klassName)
  UnrealPipe.unlock()
end

--************
--Enum Fields & Functions:
--************
local function SubFieldData(ntable,field_types,fType,realOwner, incStruct)
  local function DataWriter(field,field_types,realOwner,incStruct)
	field.offset = UnrealPipe.readDword()
    field.PropertyFlags = UnrealPipe.readQword()
	field.ClassFlags = UnrealPipe.readDword()
	field.ClassCastFlags = UnrealPipe.readQword()
	field.size = UnrealPipe.readDword()
	field.owner = ReadStringFromPipe()
	field.name = ReadStringFromPipe()
	field.class = ReadStringFromPipe()
	local fType = UnrealPipe.readDword()
	field.PropertyType = fType
	field.FieldMask = -1 --BoolProperty
	field.SpecialName = "" --ObjectProperty
	field.SubFields = {} --StructProperty,ArrayProperty,EnumProperty
	field.InnerSize = -1 --EnumProperty
	field.MapData = {}
	--print(fu(ntable.SubFields[j].offset),ntable.SubFields[j].name)
	SubFieldData(field,field_types,fType,realOwner,incStruct)
  end
  local field_types = {}
    field_types["Unknown"] = 0
    field_types["BoolProperty"] = 1
    field_types["ObjectProperty"] = 2
    field_types["StructProperty"] = 3
    field_types["EnumProperty"] = 4
    field_types["ArrayProperty"] = 5
    field_types["MapProperty"] = 6
    field_types["ClassProperty"] = 7
    field_types["SetProperty"] = 8
  if (fType==field_types["BoolProperty"]) then
	ntable.FieldMask = UnrealPipe.readByte()
  elseif(fType==field_types["ObjectProperty"]) then
    if (UnrealPipe.readByte()==1) then
       ntable.SpecialName = ReadStringFromPipe()
    end
  elseif(fType==field_types["StructProperty"]) and incStruct then
    if (UnrealPipe.readByte()==1) then
		ntable.SpecialName = ReadStringFromPipe()
        local stCount = UnrealPipe.readDword()
        --print(stCount)
        for j=1, stCount do
            ntable.SubFields[j] = {}
			DataWriter(ntable.SubFields[j],field_types,realOwner,incStruct)
            ntable.SubFields[j].owner = realOwner
        end
    end
  elseif(fType==field_types["EnumProperty"]) then
	if (UnrealPipe.readByte()==1) then
		ntable.InnerSize = UnrealPipe.readDword()
		if (UnrealPipe.readByte()==1) then
			ntable.SpecialName = ReadStringFromPipe()
		end
		if (UnrealPipe.readByte()==1) then --valid Enum_AllocInstance
			if (UnrealPipe.readByte()==1) then --Enum_ArrayMax < Enum_ArrayNum
				local count = UnrealPipe.readDword()
				for i=1,count do
					local container = {}
					container.value = UnrealPipe.readQword()
					container.name = ReadStringFromPipe()
					ntable.SubFields[#ntable.SubFields+1] = container
				end
			end
		end
	end
  elseif(fType==field_types["ArrayProperty"]) then
	if (UnrealPipe.readWord()==1) then
	    --print('array',ntable.name)
		ntable.InnerSize = UnrealPipe.readDword()
		ntable.SubFields[1] = {}
		DataWriter(ntable.SubFields[1],field_types,realOwner,incStruct)
	end
  elseif(fType==field_types["MapProperty"]) then
	if (UnrealPipe.readWord()==1) then
	    --print('array',ntable.name)
		ntable.MapData.alignment = UnrealPipe.readDword()
		ntable.MapData.size = UnrealPipe.readDword()
		ntable.SubFields[1] = {}
		ntable.SubFields[2] = {}
		DataWriter(ntable.SubFields[1],field_types,realOwner,incStruct)
		DataWriter(ntable.SubFields[2],field_types,realOwner,incStruct)
	end--]]
   elseif(fType==field_types["SetProperty"]) then
	if (UnrealPipe.readWord()==1) then
	    --print('array',ntable.name)
		ntable.MapData.alignment = UnrealPipe.readDword()
		ntable.MapData.size = UnrealPipe.readDword()
		ntable.SubFields[1] = {}
		DataWriter(ntable.SubFields[1],field_types,realOwner,incStruct)
	end--]]
   elseif(fType==field_types["ClassProperty"]) then
		if (UnrealPipe.readByte()==1) then
			ntable.SpecialName = ReadStringFromPipe()
		end
  end
end

local function EnumFieldsMain()
  local fields = {}
  if (UnrealPipe.readByte()==1) then
     if (UnrealPipe.readByte()==0) then
        print("Could not load dynamic offsets!")
		--print("ChildProperties: ",UnrealPipe.readDword())
		--print("PropertiesSize: ",UnrealPipe.readDword())
		--print("SuperStruct: ",UnrealPipe.readDword())
		--print("NextUField: ",UnrealPipe.readDword())
        return
     end
     local count = UnrealPipe.readDword()
     --print("Total fields found: ",count)
     for i=1,count do
         fields[i] = {}
         fields[i].offset = UnrealPipe.readDword()
         fields[i].PropertyFlags = UnrealPipe.readQword()
         fields[i].ClassFlags = UnrealPipe.readDword()
         fields[i].ClassCastFlags = UnrealPipe.readQword()
         fields[i].size = UnrealPipe.readDword()
         --print(fields[i].offset)
         fields[i].owner = ReadStringFromPipe()
         fields[i].name = ReadStringFromPipe()
         fields[i].class = ReadStringFromPipe()
         local fType = UnrealPipe.readDword()
         fields[i].PropertyType = fType
         fields[i].FieldMask = -1 --BoolProperty
         fields[i].SpecialName = "" --ObjectProperty,ClassProperty
         fields[i].SubFields = {} --StructProperty,ArrayProperty
		 fields[i].InnerSize = -1 --EnumProperty
		 fields[i].MapData = {}
         SubFieldData(fields[i],field_types,fType,fields[i].owner, true)
     end
  else
   print("object was invalid!!");
  end
  return fields
end
local function EnumFunctionsMain()
  local functions = {}
  if (UnrealPipe.readByte()==1) then--valid pointer
    if (UnrealPipe.readByte()==1) then--offsets successfully fetched!
       local count = UnrealPipe.readDword()
       for i=1,count do
           functions[i] = {}
           functions[i].ufunction = UnrealPipe.readQword()
           functions[i].name = ReadStringFromPipe()
           functions[i].fullname = ReadStringFromPipe()
           functions[i].defname = ReadStringFromPipe()
           functions[i].owner = ReadStringFromPipe()
		   functions[i].functionFlags = UnrealPipe.readDword()
           functions[i].execFunc = UnrealPipe.readQword()
           functions[i].ParamsCount = UnrealPipe.readWord()
           functions[i].ParamsSize = UnrealPipe.readWord()
       end
    end
    else
      print("Object was null!")
  end
  return functions
end
local function fromClassSyncPipe()
	local count = UnrealPipe.readDword()
	local n = 0
	--print(fu(count))
	for i=0,count do
		--n=n+1
		if (UnrealPipe.readByte()==1) then
			if (UnrealPipe.readByte()==1) then
				--print('n is: '..n)
				return;
			end
		end
	end
end
function UE_GetFieldsOfObject(Object,includeParents)
  includeParents = includeParents and includeParents or 0
  InitUE()
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_ENUM_FIELDS_FROM_OBJECT)
  UnrealPipe.writeQword(Object)
  UnrealPipe.writeByte(includeParents)
  local fields = EnumFieldsMain()
  UnrealPipe.unlock()
  return fields
end
function UE_GetFieldsOfClass(class,includeParents)
  includeParents = includeParents and includeParents or 0
  InitUE()
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_ENUM_FIELDS_FROM_CLASS)
  UnrealPipe.writeWord(#class)
  UnrealPipe.writeString(class)
  UnrealPipe.writeByte(includeParents)
  fromClassSyncPipe()
  local fields = {}
  if (UnrealPipe.readByte()==1) then
     fields = EnumFieldsMain()
  else
     print('Class \"'..class..'\" does not exist.')
  end
  UnrealPipe.unlock()
  return fields
end

function UE_GetFunctionsOfObject(Object,includeParents)
  includeParents = includeParents and includeParents or 0
  InitUE()
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_ENUM_FUNCTIONS_FROM_OBJECT)
  UnrealPipe.writeQword(Object)
  UnrealPipe.writeByte(includeParents)
  local functions = EnumFunctionsMain()
  UnrealPipe.unlock()
  return functions
end
function UE_GetFunctionsOfClass(class,includeParents)
  includeParents = includeParents and includeParents or 0
  InitUE()
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_ENUM_FUNCTIONS_FROM_CLASS)
  UnrealPipe.writeWord(#class)
  UnrealPipe.writeString(class)
  UnrealPipe.writeByte(includeParents)
  fromClassSyncPipe()
  local functions = {}
  if (UnrealPipe.readByte()==1) then
     functions = EnumFunctionsMain()
  else
     print('Class \"'..class..'\" does not exist.')
  end
  UnrealPipe.unlock()
  return functions
end
function UE_GetFunctionParameters(ufunction)
  local fields = {}
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_GET_FUNCTION_PARAMETERS)
  UnrealPipe.writeQword(ufunction)
  fields = EnumFieldsMain()
  UnrealPipe.unlock()
  return fields
end
function UE_GetObjectData(uobj) --new
  LaunchUEDataCollector()
  InitUE()
  uobj = UE_CheckAddressAsObject(uobj)
  if (uobj==0) then 
	return {"The address is not a UObject"}
  end
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_GET_OBJECT_DATA)
  UnrealPipe.writeQword(uobj)
  local data = {}
  if (UnrealPipe.readByte()==1) then
     data.UObject = UnrealPipe.readQword()
     data.Name = ReadStringFromPipe()
     data.ObjectName = ReadStringFromPipe()
     data.FullName = ReadStringFromPipe()
     data.ClassSize = UnrealPipe.readDword()
	 data.PropertyFlags = UnrealPipe.readQword() --PropertyFlags
     data.ClassFlags = UnrealPipe.readDword() --EClassFlags
     data.ClassCastFlags = UnrealPipe.readQword() --EClassCastFlags
     data.ClassName = ReadStringFromPipe()
	 
	 local fType = UnrealPipe.readDword()
	 data.PropertyType = fType
	 data.FieldMask = -1 --BoolProperty
	 data.SpecialName = "" --ObjectProperty,ClassProperty
	 data.SubFields = {} --StructProperty,ArrayProperty,EnumProperty
	 data.InnerSize = -1 --EnumProperty
	 data.MapData = {} --MapProperty / SetProperty
	 SubFieldData(data,field_types,fType,data.ClassName, true)
  end
  UnrealPipe.unlock()
  return data
end
function UE_GetFunctionData(uobj) --new
  LaunchUEDataCollector()
  InitUE()
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_GET_FUNCTION_DATA)
  UnrealPipe.writeQword(uobj)
  local data = {}
  if (UnrealPipe.readByte()==1) then
	data.UObject = UnrealPipe.readQword()
	data.Name = ReadStringFromPipe()
	--data.ClassName = ReadStringFromPipe()
	data.ObjectName = ReadStringFromPipe()
	data.FullName = ReadStringFromPipe()
	data.ClassSize = UnrealPipe.readDword()
	data.PropertyFlags = UnrealPipe.readQword() --PropertyFlags
	data.ClassFlags = UnrealPipe.readDword() --EClassFlags
	data.ClassCastFlags = UnrealPipe.readQword() --EClassCastFlags
	data.ClassName = ReadStringFromPipe()

	data.FunctionFlags = UnrealPipe.readDword()
	data.NumParms = UnrealPipe.readWord()
	data.ParmsSize = UnrealPipe.readWord()
	data.ReturnValueOffset = UnrealPipe.readDword()
	data.uFunc = UnrealPipe.readQword()
  end
  UnrealPipe.unlock()
  return data
end
function UE_RegisterAllFunctions()
 local allUfunctions = UE_GetAllObjectsOfClass("Function")
 local syml = createSymbolList()
 for k,v in pairs(allUfunctions) do
     if readPointer(v.obj) then
        local funcData = UE_GetFunctionData(v.obj)
        if readPointer(funcData.uFunc) then
           --print(fu(funcData.uFunc),funcData.ObjectName)
           if not(syml.getSymbolFromString(funcData.ObjectName)) then
	      syml.addSymbol("UE4",funcData.ObjectName,getAddressSafe(funcData.uFunc),1,false,{returntype="",parameters=""})
	   end
        end
     end
 end
 syml.register()
end
function UE_GetPropertyFlagNames(PropertyFlags) --returns one table with names
	local propflags = {}
	for k,v in pairs(EPropertyFlags) do
		if (bAnd(PropertyFlags,v)~=0) then
			propflags[#propflags+1] = k
		end
	end
	return propflags
end
function UE_GetClassFlagNames(ClassFlags) --returns 2 tables with names
	local retClassFlags = {}
	for k,v in pairs(EClassFlags) do
		if (bAnd(ClassFlags,v)~=0) then
			retClassFlags[#retClassFlags+1] = k
		end
	end
	
	return retClassFlags
end
function UE_GetClassCastFlagNames(ClassCastFlags)
	local retClassCastFlags = {}
	for k,v in pairs(EClassCastFlags) do
		if (bAnd(ClassCastFlags,v)~=0) then
			retClassCastFlags[#retClassCastFlags+1] = k
		end
	end
	return retClassCastFlags
end
function UE_GetFunctionFlagNames(FunctionFlags)
	local str = {}
	for k,v in pairs(EFunctionFlags) do
		if (bAnd(FunctionFlags,v)~=0 and k ~= 'FUNC_AllFlags') then
		   str[#str+1] = k
		end
	end
	if FunctionFlags==EFunctionFlags.FUNC_AllFlags then str[#str+1] = 'FUNC_AllFlags' end
	return str
end
function UE_MakeFunctionConsoleCallable(ufunction)
  if (UE_CheckAddressAsObject(ufunction)==0)then return end
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_SET_CONSOLE_FUNC)
  UnrealPipe.writeQword(ufunction)
  UnrealPipe.unlock()
end
--***********
--Others
--***********
function UE_GetClassInheritance(klassName)
  InitUE()
  UnrealPipe.writeByte(UE_GET_CLASS_INHERITANCE)
  UnrealPipe.writeWord(#klassName)
  UnrealPipe.writeString(klassName)
  fromClassSyncPipe()
  local inh = {}
  local byt = UnrealPipe.readByte()
  if (byt==1) then --is Valid
     local count = UnrealPipe.readDword()
	 --print(count)
     for i=1,count do
		inh[i] = {}
		inh[i].klass = UnrealPipe.readQword()
		inh[i].name = ReadStringFromPipe()
         --print(inh[i].name)
     end
  else
     print('Class not found!',byt)
  end
  return inh
end
function UE_GetAllObjectsOfClass(klassName)
  InitUE()
  UnrealPipe.writeByte(UE_GET_ALL_OBJECTS_OF_CLASS)
  UnrealPipe.writeWord(#klassName)
  UnrealPipe.writeString(klassName)
  local threads = UnrealPipe.readDword()
  --print(threads)
  for i=1,threads do
      UnrealPipe.readByte()
  end
  local count = UnrealPipe.readDword()
  --print(count)
  local objs = {}
  for i=0,count-1 do
      objs[#objs+1] = {}
	  objs[#objs].obj = UnrealPipe.readQword()
	  objs[#objs].name = ReadStringFromPipe()
  end
  UnrealPipe.unlock()
  return objs
end
function UE_GetAllSubObjectsOfClass(klassName)
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_GET_ALL_SUBOBJECTS_OF_CLASS)
  UnrealPipe.writeWord(#klassName)
  UnrealPipe.writeString(klassName)
  fromClassSyncPipe()
  local objs = {}
  if (UnrealPipe.readByte()==1) then
    local threads = UnrealPipe.readDword()
    --print(threads)
    for i=1,threads do
      UnrealPipe.readByte()
    end
	local count = UnrealPipe.readDword()
	for i=0,count-1 do
	  objs[#objs+1] = UnrealPipe.readQword()
	end
  else
	print("Invalid class name")
  end
  UnrealPipe.unlock()
  return objs
end
function UE_CheckAddressAsObject(address)
  if not(address) then return 0 end
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_GET_OBJECT_AND_DATA)
  UnrealPipe.writeQword(address)
  local threads = UnrealPipe.readDword()
  for i=0, threads-1 do
      if (UnrealPipe.readByte()==1) then
         break;
      end
  end
  local adrs = UnrealPipe.readQword()
  UnrealPipe.unlock()
  return adrs
end
function UE_EnumAllClasses()
  InitUE()
  local classes = {}
  UnrealPipe.writeByte(UE_ENUM_ALL_CLASSES)
  local count = UnrealPipe.readDword()
  for i=1,count+1 do
      if (UnrealPipe.readByte()==1) then
        local name = ReadStringFromPipe()
        if not(classes[name]) then classes[name] = name end
      end
  end
  return classes
end
function UE_GetObjectAt(index)
  InitUE()
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_OBJECTAT)
  UnrealPipe.writeDword(index)
  local object = {}
  if (UnrealPipe.readByte()==1) then
	if (UnrealPipe.readByte()==1) then
		object.address = UnrealPipe.readQword()
		object.classAddress = UnrealPipe.readQword()
		object.size = UnrealPipe.readDword()
		object.class = ReadStringFromPipe()
	end
  end
  UnrealPipe.unlock()
  return object
end
function UE_GetMainThreadID() --1.2
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_GET_PROC_MAIN_THREAD)
  local val = UnrealPipe.readDword()
  UnrealPipe.unlock()
  return val
end
--***********
--Debug Console (Is not present in public release)
--***********
function UE_LaunchConsole()
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_LAUNCH_DEBUG_CONSOLE)
  UnrealPipe.unlock()
end
function UE_CloseConsole()
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_CLOSE_DEBUG_CONSOLE)
  UnrealPipe.unlock()
end
function UE_PrintOffsets()
	UnrealPipe.lock()
	UnrealPipe.writeByte(UE_PRINTOFFSETS)
	UnrealPipe.unlock()
end
function UE_AdjustOffset(offsetName,value)
  if type(value) ~="number" or type(offsetName) ~="string" then return end
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_ADJUST_OFFSET)
  UnrealPipe.writeDword(value)
  UnrealPipe.writeWord(#offsetName)
  UnrealPipe.writeString(offsetName)
  UnrealPipe.unlock()
end
--***********
--ProcessEvent Event Invoker
--***********
local function typeToSize(ueType)
  local store = {
        1,
        2,
        4,
        4,
        8,
        8,
        8
  }
  local ret = store[ueType]
  ret = ret and ret or 8
  return ret
end
local MAIN_THREAD_ID = 0
local LAST_PIPE_HANDLE = 0
function UE_GetThreadTEBAddress()
  UnrealPipe.writeByte(UE_GET_THREAD_TEB_ADDRESS)
  return UnrealPipe.readQword()
end
local function UE_GetCurrentThreadID()
  UnrealPipe.writeByte(UE_GET_CURRENT_THREAD_ID)
  return UnrealPipe.readDword()
end
local function getSetThreadId(mode,value)
  if mode==0 then --get
     return readInteger('GGameThreadID')
  else--set
   if not(value) then return end
   writeInteger('GGameThreadID',value)
  end
end
local function makeThreadSafe()
	--Use it at ur own risk. Not a reliable way.
	if not(MAIN_THREAD_ID) or MAIN_THREAD_ID==0 or not(LAST_PIPE_HANDLE) or LAST_PIPE_HANDLE~=UnrealPipe.Handle then --if main thread id is not set or pipe handles do not match, just do the code
		LAST_PIPE_HANDLE=UnrealPipe.Handle
		local currentID = readInteger(UE_GetThreadTEBAddress()+0x48) --Read_Current_Thread_ID
		local mainID = getSetThreadId(0)
		if mainID == nil then print('Cannot find "GGameThreadID". Cannot invoke in safe mode') UnrealPipe.destroy() UnrealPipe=nil return end
		if mainID==currentID and (MAIN_THREAD_ID) and MAIN_THREAD_ID~=0 then --if ids are already the same and MAIN_THREAD_ID is not 0
			writeInteger(UE_GetThreadTEBAddress()+0x48,MAIN_THREAD_ID) --Set the server's thread id to whatever we have
		end
		MAIN_THREAD_ID = readInteger(UE_GetThreadTEBAddress()+0x48) --read the original id
	end
	local mainID = getSetThreadId(0)
	if mainID == nil then print('Cannot find "GGameThreadID". Cannot invoke in safe mode') UnrealPipe.destroy() UnrealPipe=nil return end
	writeInteger(UE_GetThreadTEBAddress()+0x48,mainID) --write the new id
	return MAIN_THREAD_ID
end
local function resetServerThreadID()
	if (MAIN_THREAD_ID) and (MAIN_THREAD_ID>0) then
		writeInteger(UE_GetThreadTEBAddress()+0x48,MAIN_THREAD_ID)
	end
end
local function GetOffsetsAndPadBytes(tab)
 local nextaddress = 0
 local currentaddress = 1
 local currentOffset = 0
 local pad = 0
 local t = {}
 for i=1,#tab do
     currentaddress = nextaddress
     local siz = tab[i].size
     pad = nextaddress%siz
     pad = pad==0 and siz or pad
     currentOffset = currentaddress+siz-pad
     local paddedbytes = currentOffset-nextaddress
     nextaddress = currentOffset+siz
     t[i] = {currentOffset = currentOffset, paddedbytes = paddedbytes}
 end
 return t
end
local function argsToByteArray(args)
  if #args==0 then return {}--[[{0,0,0,0,0,0,0,0}--]] end
	for i=1,#args do
	 local siz = typeToSize(args[i].type)
	 --print(args[i].size,siz)
	 if (args[i].size~=siz) then
		--print('Argument size and type mismatch..correcting size according to type') --this was included to match the size of the field/bytes
		args[i].size=siz
	 end
	end
  if args[#args].size < 8 then args[#args+1] = {name="Dummy",type=szQword,size=8,val=0} end --add an extra arg if not alligned at 0x8 bytes
  local totalSize = 0
  local bytes = {}
  local write = GetOffsetsAndPadBytes(args)

  for i=1, #args do
      local v = args[i]
      totalSize = totalSize+v.size
      for j=1,write[i].paddedbytes do
          bytes[#bytes+1] = 0
      end
      if (v.type==szByte) then
         table.insert(bytes,v.value)
      elseif(v.type==szWord) then
         for kk,vv in pairs(wordToByteTable(v.value)) do
           table.insert(bytes,vv)
         end
      elseif(v.type==szDword) then
         for kk,vv in pairs(dwordToByteTable(v.value)) do
           table.insert(bytes,vv)
         end
      elseif(v.type==szFloat) then
         for kk,vv in pairs(floatToByteTable(v.value)) do
           table.insert(bytes,vv)
         end
      elseif(v.type==szQword) then
         for kk,vv in pairs(qwordToByteTable(v.value)) do
           table.insert(bytes,vv)
         end
      elseif(v.type==szDouble) then
         for kk,vv in pairs(doubleToByteTable(v.value)) do
           table.insert(bytes,vv)
         end
      else --szPointer
         for kk,vv in pairs(qwordToByteTable(v.value)) do
           table.insert(bytes,vv)
         end
      end
  end
  --print('\n',totalSize,#bytes)
  return bytes
end
local function CommonInvoker(Actor,Function,bytes,ArgsCarrier)
  UnrealPipe.writeQword(Actor)
  UnrealPipe.writeQword(Function)
  UnrealPipe.writeDword(#bytes)
  for i=1,#bytes do
      UnrealPipe.writeByte(bytes[i])
  end
  UnrealPipe.writeQword(ArgsCarrier)
  local retVal = {}
  if (UnrealPipe.readByte()==1) then
	if (UnrealPipe.readByte()==1) then
	  local size = UnrealPipe.readDword()
	  for i=1,size do
		  retVal[i] = UnrealPipe.readByte()
	  end
	end
  end
  return retVal
end
function UE_InvokeActorEvent(Actor,Function,Args,ArgsCarrier)
  ArgsCarrier = ArgsCarrier and ArgsCarrier or 0
  if not(readPointer("Actor::ProcessEvent")) then print("\"Actor::ProcessEvent\" is null. Cannot invoke nullptr") return end
  if type(Args)~= 'table' then print('args was nil') return end
  local bytes = argsToByteArray(Args)
  if type(bytes)~= 'table' then print('args was nil') return end
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_INVOKE_ACTOREVENT)
  local retVal = CommonInvoker(Actor,Function,bytes,ArgsCarrier)
  UnrealPipe.unlock()
  return retVal
end
function UE_InvokeObjectEvent(Object,Function,Args,ArgsCarrier)
  ArgsCarrier = ArgsCarrier and ArgsCarrier or 0
  --print(ArgsCarrier)
  if (trySafe) then  end
  if not(readPointer("Object::ProcessEvent")) then print("\"Object::ProcessEvent\" is null. Cannot invoke nullptr") return end
  if type(Args)~= 'table' then print('args was nil') return end
  local bytes = argsToByteArray(Args)
  if type(bytes)~= 'table' then print('args was nil') return end
  UnrealPipe.lock()
  UnrealPipe.writeByte(UE_INVOKE_OBJECTEVENT)
  local retVal = CommonInvoker(Object,Function,bytes,ArgsCarrier)
  UnrealPipe.unlock()
  return retVal
end
function UE_InvokeObjectEventSafe(Actor,Function,Args,ArgsCarrier)
  ArgsCarrier = ArgsCarrier and ArgsCarrier or 0
  UnrealPipe.lock()
  local bytes = argsToByteArray(Args)
  if type(bytes)~= 'table' then print('args was nil') return end
  UnrealPipe.writeByte(UE_THREAD_SAFE_INVOKE)
  UnrealPipe.writeQword(Actor)
  UnrealPipe.writeQword(Function)
  UnrealPipe.writeDword(#bytes)
  for i=1,#bytes do
      UnrealPipe.writeByte(bytes[i])
  end
  UnrealPipe.writeQword(ArgsCarrier)
  local retVal = {}
  local _time = 2000
  if (UnrealPipe.readByte()==1) then --valid all basic parameters
    if (UnrealPipe.readByte()==1) then --valid thread handle
		if (UnrealPipe.readByte()==1) then --valid thread context
			while(UnrealPipe.readByte()~=1 and _time > 0) do
			  _time = _time-1
			end
			local size = UnrealPipe.readDword()
			for i=1,size do
				retVal[i] = UnrealPipe.readByte()
			end
			--print(size,#retVal)
		end
    end
  end
  UnrealPipe.unlock()
  return retVal
end

---------新增代码
-- =========================================================================
-- ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
-- 【真·最终完美版 - 纯数学实现】

-- =========================================================================
-- ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
-- 【最终严谨修复版 - 适配UE4.27】
-- 修复依据：UEDumper C++ 源码, 已验证的易语言代码, 以及实际输出反推

function GetNameByID_Final(id)
    -- 0. ID有效性检查
    if not id or id < 0 then return "[Invalid ID]" end
    if id == 0 then return "None" end -- ID 0 永远是 "None"

    -- 1. 获取 GNames 基地址
    local imageBase = getAddress("Mir4G.exe") -- 确保游戏进程名正确
    if not imageBase or imageBase == 0 then return "[Error: Game module not found]" end

    local GNames_RVA = 0x80E9300 -- 这是你提供的RVA
    local FUNames_Addr = imageBase + GNames_RVA
    if FUNames_Addr == 0 then return "[Error: FUNames address not found]" end

    -- 2. 计算分块索引和块内索引 (逻辑正确)
    local chunkIndex = math.floor(id / 65536)
    local withinChunkIndex = id % 65536

    -- 3. 【严谨修正】读取块地址，严格遵循 C++ 和易语言逻辑
    -- 公式: GNames_Base + (ChunkIndex + 2) * 8
    local chunkPtrAddr = FUNames_Addr + (chunkIndex + 2) * 8
    local chunkAddr = readPointer(chunkPtrAddr)
    if chunkAddr == 0 then
        return "" -- 分块未加载是正常现象
    end

    -- 4. 计算名字条目地址 (逻辑正确)
    -- 公式: Chunk_Base + WithinChunkIndex * 2
    local nameEntryAddr = chunkAddr + (withinChunkIndex * 2)

    -- 5. 读取16位头部信息 (Header)
    local header_signed = readSmallInteger(nameEntryAddr)
    if not header_signed then return "[Invalid Header Read]" end

    -- 将其转换为无符号数进行位运算
    local header_unsigned = header_signed
    if header_signed < 0 then
        header_unsigned = header_signed + 65536
    end

    -- 6. 【核心解码】根据UE4.27源码，精确解码Header
    -- 最低位 (bit 0) 决定是否为宽字节
    local isWide = (header_unsigned % 2) == 1

    -- 右移6位 (除以64) 获取字符串长度
    local length = math.floor(header_unsigned / 64)

    -- 7. 验证长度并读取字符串
    if length <= 0 or length > 1024 then -- 安全检查
        return "" -- 空字符串或无效长度
    end

    -- 从Header之后(+2字节)的位置开始读取字符串
    local nameString = readString(nameEntryAddr + 2, length, isWide)

    return nameString
end

-- ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
-- =========================================================================

-- ==================
-- 【最终版验证测试】
-- ==================
print("正在测试【最终严谨修复版】GetNameByID_Final 函数...")


--[[

-- 打印你给出的完美结果列表中的ID
local testIDs = {0, 3, 10, 17, 24, 32, 40, 47, 56, 64, 72, 97, 104, 111, 121, 135, 145, 155, 171, 179, 186, 194, 202, 210}
for _, id in ipairs(testIDs) do
    local name = GetNameByID_Final(id)
    print(string.format("[%05d] %s", id, name))
end

-- 也测试一下之前出错的ID
print("\n测试之前出错的ID:")
print("ID 1234: " .. GetNameByID_Final(1234))
print("ID 56789: " .. GetNameByID_Final(56789))

-- ==================
-- 【如何测试】
-- ==================
-- 你可以在 CE 的 Lua 引擎里执行下面的代码来测试这个函数
-- 找几个你知道的ID，或者随便试试
-- print("正在测试 GetNameByID_UE427 函数...")
-- print("ID 1: " .. GetNameByID_UE427(1))
-- print("ID 10: " .. GetNameByID_UE427(10))
-- print("ID 1234: " .. GetNameByID_UE427(1234))
-- print("ID 56789: " .. GetNameByID_UE427(56789))
-- ====================================


]]






