// Copyright Epic Games, Inc. All Rights Reserved.
/*===========================================================================
	Generated code exported from UnrealHeaderTool.
	DO NOT modify this manually! Edit the corresponding .h files instead!
===========================================================================*/

#include "UObject/GeneratedCppIncludes.h"
#include "PilotMovementComponent.h"

PRAGMA_DISABLE_DEPRECATION_WARNINGS
static_assert(!UE_WITH_CONSTINIT_UOBJECT, "This generated code can only be compiled with !UE_WITH_CONSTINIT_OBJECT");
void EmptyLinkFunctionForGeneratedCodePilotMovementComponent() {}

// ********** Begin Cross Module References ********************************************************
ENGINE_API UClass* Z_Construct_UClass_UCharacterMovementComponent();
PROJECTP1L0T_API UClass* Z_Construct_UClass_UPilotMovementComponent();
PROJECTP1L0T_API UClass* Z_Construct_UClass_UPilotMovementComponent_NoRegister();
PROJECTP1L0T_API UEnum* Z_Construct_UEnum_ProjectP1L0T_EPilotCustomMode();
UPackage* Z_Construct_UPackage__Script_ProjectP1L0T();
// ********** End Cross Module References **********************************************************

// ********** Begin Enum EPilotCustomMode **********************************************************
static FEnumRegistrationInfo Z_Registration_Info_UEnum_EPilotCustomMode;
static UEnum* EPilotCustomMode_StaticEnum()
{
	if (!Z_Registration_Info_UEnum_EPilotCustomMode.OuterSingleton)
	{
		Z_Registration_Info_UEnum_EPilotCustomMode.OuterSingleton = GetStaticEnum(Z_Construct_UEnum_ProjectP1L0T_EPilotCustomMode, (UObject*)Z_Construct_UPackage__Script_ProjectP1L0T(), TEXT("EPilotCustomMode"));
	}
	return Z_Registration_Info_UEnum_EPilotCustomMode.OuterSingleton;
}
template<> PROJECTP1L0T_NON_ATTRIBUTED_API UEnum* StaticEnum<EPilotCustomMode>()
{
	return EPilotCustomMode_StaticEnum();
}
struct Z_Construct_UEnum_ProjectP1L0T_EPilotCustomMode_Statics
{
#if WITH_METADATA
	static constexpr UECodeGen_Private::FMetaDataPairParam Enum_MetaDataParams[] = {
		{ "BlueprintType", "true" },
		{ "ModuleRelativePath", "PilotMovementComponent.h" },
		{ "None.DisplayName", "None" },
		{ "None.Name", "EPilotCustomMode::None" },
		{ "Slide.DisplayName", "Slide" },
		{ "Slide.Name", "EPilotCustomMode::Slide" },
		{ "WallRun.DisplayName", "WallRun" },
		{ "WallRun.Name", "EPilotCustomMode::WallRun" },
	};
#endif // WITH_METADATA
	static constexpr UECodeGen_Private::FEnumeratorParam Enumerators[] = {
		{ "EPilotCustomMode::None", (int64)EPilotCustomMode::None },
		{ "EPilotCustomMode::Slide", (int64)EPilotCustomMode::Slide },
		{ "EPilotCustomMode::WallRun", (int64)EPilotCustomMode::WallRun },
	};
	static const UECodeGen_Private::FEnumParams EnumParams;
}; // struct Z_Construct_UEnum_ProjectP1L0T_EPilotCustomMode_Statics 
const UECodeGen_Private::FEnumParams Z_Construct_UEnum_ProjectP1L0T_EPilotCustomMode_Statics::EnumParams = {
	(UObject*(*)())Z_Construct_UPackage__Script_ProjectP1L0T,
	nullptr,
	"EPilotCustomMode",
	"EPilotCustomMode",
	Z_Construct_UEnum_ProjectP1L0T_EPilotCustomMode_Statics::Enumerators,
	RF_Public|RF_Transient|RF_MarkAsNative,
	UE_ARRAY_COUNT(Z_Construct_UEnum_ProjectP1L0T_EPilotCustomMode_Statics::Enumerators),
	EEnumFlags::None,
	(uint8)UEnum::ECppForm::EnumClass,
	METADATA_PARAMS(UE_ARRAY_COUNT(Z_Construct_UEnum_ProjectP1L0T_EPilotCustomMode_Statics::Enum_MetaDataParams), Z_Construct_UEnum_ProjectP1L0T_EPilotCustomMode_Statics::Enum_MetaDataParams)
};
UEnum* Z_Construct_UEnum_ProjectP1L0T_EPilotCustomMode()
{
	if (!Z_Registration_Info_UEnum_EPilotCustomMode.InnerSingleton)
	{
		UECodeGen_Private::ConstructUEnum(Z_Registration_Info_UEnum_EPilotCustomMode.InnerSingleton, Z_Construct_UEnum_ProjectP1L0T_EPilotCustomMode_Statics::EnumParams);
	}
	return Z_Registration_Info_UEnum_EPilotCustomMode.InnerSingleton;
}
// ********** End Enum EPilotCustomMode ************************************************************

// ********** Begin Class UPilotMovementComponent Function SetWantsSlide ***************************
struct Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide_Statics
{
	struct PilotMovementComponent_eventSetWantsSlide_Parms
	{
		bool bNew;
	};
#if WITH_METADATA
	static constexpr UECodeGen_Private::FMetaDataPairParam Function_MetaDataParams[] = {
		{ "Category", "Pilot|Input" },
		{ "ModuleRelativePath", "PilotMovementComponent.h" },
	};
#endif // WITH_METADATA

// ********** Begin Function SetWantsSlide constinit property declarations *************************
	static void NewProp_bNew_SetBit(void* Obj);
	static const UECodeGen_Private::FBoolPropertyParams NewProp_bNew;
	static const UECodeGen_Private::FPropertyParamsBase* const PropPointers[];
// ********** End Function SetWantsSlide constinit property declarations ***************************
	static const UECodeGen_Private::FFunctionParams FuncParams;
};

// ********** Begin Function SetWantsSlide Property Definitions ************************************
void Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide_Statics::NewProp_bNew_SetBit(void* Obj)
{
	((PilotMovementComponent_eventSetWantsSlide_Parms*)Obj)->bNew = 1;
}
const UECodeGen_Private::FBoolPropertyParams Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide_Statics::NewProp_bNew = { "bNew", nullptr, (EPropertyFlags)0x0010000000000080, UECodeGen_Private::EPropertyGenFlags::Bool | UECodeGen_Private::EPropertyGenFlags::NativeBool, RF_Public|RF_Transient|RF_MarkAsNative, nullptr, nullptr, 1, sizeof(bool), sizeof(PilotMovementComponent_eventSetWantsSlide_Parms), &Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide_Statics::NewProp_bNew_SetBit, METADATA_PARAMS(0, nullptr) };
const UECodeGen_Private::FPropertyParamsBase* const Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide_Statics::PropPointers[] = {
	(const UECodeGen_Private::FPropertyParamsBase*)&Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide_Statics::NewProp_bNew,
};
static_assert(UE_ARRAY_COUNT(Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide_Statics::PropPointers) < 2048);
// ********** End Function SetWantsSlide Property Definitions **************************************
const UECodeGen_Private::FFunctionParams Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide_Statics::FuncParams = { { (UObject*(*)())Z_Construct_UClass_UPilotMovementComponent, nullptr, "SetWantsSlide", 	Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide_Statics::PropPointers, 
	UE_ARRAY_COUNT(Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide_Statics::PropPointers), 
sizeof(Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide_Statics::PilotMovementComponent_eventSetWantsSlide_Parms),
RF_Public|RF_Transient|RF_MarkAsNative, (EFunctionFlags)0x04020401, 0, 0, METADATA_PARAMS(UE_ARRAY_COUNT(Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide_Statics::Function_MetaDataParams), Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide_Statics::Function_MetaDataParams)},  };
static_assert(sizeof(Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide_Statics::PilotMovementComponent_eventSetWantsSlide_Parms) < MAX_uint16);
UFunction* Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide()
{
	static UFunction* ReturnFunction = nullptr;
	if (!ReturnFunction)
	{
		UECodeGen_Private::ConstructUFunction(&ReturnFunction, Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide_Statics::FuncParams);
	}
	return ReturnFunction;
}
DEFINE_FUNCTION(UPilotMovementComponent::execSetWantsSlide)
{
	P_GET_UBOOL(Z_Param_bNew);
	P_FINISH;
	P_NATIVE_BEGIN;
	P_THIS->SetWantsSlide(Z_Param_bNew);
	P_NATIVE_END;
}
// ********** End Class UPilotMovementComponent Function SetWantsSlide *****************************

// ********** Begin Class UPilotMovementComponent Function SetWantsSprint **************************
struct Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint_Statics
{
	struct PilotMovementComponent_eventSetWantsSprint_Parms
	{
		bool bNew;
	};
#if WITH_METADATA
	static constexpr UECodeGen_Private::FMetaDataPairParam Function_MetaDataParams[] = {
		{ "Category", "Pilot|Input" },
#if !UE_BUILD_SHIPPING
		{ "Comment", "// Called by Character input\n" },
#endif
		{ "ModuleRelativePath", "PilotMovementComponent.h" },
#if !UE_BUILD_SHIPPING
		{ "ToolTip", "Called by Character input" },
#endif
	};
#endif // WITH_METADATA

// ********** Begin Function SetWantsSprint constinit property declarations ************************
	static void NewProp_bNew_SetBit(void* Obj);
	static const UECodeGen_Private::FBoolPropertyParams NewProp_bNew;
	static const UECodeGen_Private::FPropertyParamsBase* const PropPointers[];
// ********** End Function SetWantsSprint constinit property declarations **************************
	static const UECodeGen_Private::FFunctionParams FuncParams;
};

// ********** Begin Function SetWantsSprint Property Definitions ***********************************
void Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint_Statics::NewProp_bNew_SetBit(void* Obj)
{
	((PilotMovementComponent_eventSetWantsSprint_Parms*)Obj)->bNew = 1;
}
const UECodeGen_Private::FBoolPropertyParams Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint_Statics::NewProp_bNew = { "bNew", nullptr, (EPropertyFlags)0x0010000000000080, UECodeGen_Private::EPropertyGenFlags::Bool | UECodeGen_Private::EPropertyGenFlags::NativeBool, RF_Public|RF_Transient|RF_MarkAsNative, nullptr, nullptr, 1, sizeof(bool), sizeof(PilotMovementComponent_eventSetWantsSprint_Parms), &Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint_Statics::NewProp_bNew_SetBit, METADATA_PARAMS(0, nullptr) };
const UECodeGen_Private::FPropertyParamsBase* const Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint_Statics::PropPointers[] = {
	(const UECodeGen_Private::FPropertyParamsBase*)&Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint_Statics::NewProp_bNew,
};
static_assert(UE_ARRAY_COUNT(Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint_Statics::PropPointers) < 2048);
// ********** End Function SetWantsSprint Property Definitions *************************************
const UECodeGen_Private::FFunctionParams Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint_Statics::FuncParams = { { (UObject*(*)())Z_Construct_UClass_UPilotMovementComponent, nullptr, "SetWantsSprint", 	Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint_Statics::PropPointers, 
	UE_ARRAY_COUNT(Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint_Statics::PropPointers), 
sizeof(Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint_Statics::PilotMovementComponent_eventSetWantsSprint_Parms),
RF_Public|RF_Transient|RF_MarkAsNative, (EFunctionFlags)0x04020401, 0, 0, METADATA_PARAMS(UE_ARRAY_COUNT(Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint_Statics::Function_MetaDataParams), Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint_Statics::Function_MetaDataParams)},  };
static_assert(sizeof(Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint_Statics::PilotMovementComponent_eventSetWantsSprint_Parms) < MAX_uint16);
UFunction* Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint()
{
	static UFunction* ReturnFunction = nullptr;
	if (!ReturnFunction)
	{
		UECodeGen_Private::ConstructUFunction(&ReturnFunction, Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint_Statics::FuncParams);
	}
	return ReturnFunction;
}
DEFINE_FUNCTION(UPilotMovementComponent::execSetWantsSprint)
{
	P_GET_UBOOL(Z_Param_bNew);
	P_FINISH;
	P_NATIVE_BEGIN;
	P_THIS->SetWantsSprint(Z_Param_bNew);
	P_NATIVE_END;
}
// ********** End Class UPilotMovementComponent Function SetWantsSprint ****************************

// ********** Begin Class UPilotMovementComponent **************************************************
FClassRegistrationInfo Z_Registration_Info_UClass_UPilotMovementComponent;
UClass* UPilotMovementComponent::GetPrivateStaticClass()
{
	using TClass = UPilotMovementComponent;
	if (!Z_Registration_Info_UClass_UPilotMovementComponent.InnerSingleton)
	{
		GetPrivateStaticClassBody(
			TClass::StaticPackage(),
			TEXT("PilotMovementComponent"),
			Z_Registration_Info_UClass_UPilotMovementComponent.InnerSingleton,
			StaticRegisterNativesUPilotMovementComponent,
			sizeof(TClass),
			alignof(TClass),
			TClass::StaticClassFlags,
			TClass::StaticClassCastFlags(),
			TClass::StaticConfigName(),
			(UClass::ClassConstructorType)InternalConstructor<TClass>,
			(UClass::ClassVTableHelperCtorCallerType)InternalVTableHelperCtorCaller<TClass>,
			UOBJECT_CPPCLASS_STATICFUNCTIONS_FORCLASS(TClass),
			&TClass::Super::StaticClass,
			&TClass::WithinClass::StaticClass
		);
	}
	return Z_Registration_Info_UClass_UPilotMovementComponent.InnerSingleton;
}
UClass* Z_Construct_UClass_UPilotMovementComponent_NoRegister()
{
	return UPilotMovementComponent::GetPrivateStaticClass();
}
struct Z_Construct_UClass_UPilotMovementComponent_Statics
{
#if WITH_METADATA
	static constexpr UECodeGen_Private::FMetaDataPairParam Class_MetaDataParams[] = {
		{ "IncludePath", "PilotMovementComponent.h" },
		{ "ModuleRelativePath", "PilotMovementComponent.h" },
	};
	static constexpr UECodeGen_Private::FMetaDataPairParam NewProp_SprintSpeed_MetaData[] = {
		{ "Category", "Pilot|Sprint" },
#if !UE_BUILD_SHIPPING
		{ "Comment", "// --- Tunables (start TF2-ish) ---\n" },
#endif
		{ "ModuleRelativePath", "PilotMovementComponent.h" },
#if !UE_BUILD_SHIPPING
		{ "ToolTip", "--- Tunables (start TF2-ish) ---" },
#endif
	};
	static constexpr UECodeGen_Private::FMetaDataPairParam NewProp_SlideEnterSpeed_MetaData[] = {
		{ "Category", "Pilot|Slide" },
		{ "ModuleRelativePath", "PilotMovementComponent.h" },
	};
	static constexpr UECodeGen_Private::FMetaDataPairParam NewProp_SlideMinSpeed_MetaData[] = {
		{ "Category", "Pilot|Slide" },
		{ "ModuleRelativePath", "PilotMovementComponent.h" },
	};
	static constexpr UECodeGen_Private::FMetaDataPairParam NewProp_SlideFriction_MetaData[] = {
		{ "Category", "Pilot|Slide" },
		{ "ModuleRelativePath", "PilotMovementComponent.h" },
	};
	static constexpr UECodeGen_Private::FMetaDataPairParam NewProp_WallRunMinSpeed_MetaData[] = {
		{ "Category", "Pilot|WallRun" },
		{ "ModuleRelativePath", "PilotMovementComponent.h" },
	};
	static constexpr UECodeGen_Private::FMetaDataPairParam NewProp_WallRunGravityScale_MetaData[] = {
		{ "Category", "Pilot|WallRun" },
		{ "ModuleRelativePath", "PilotMovementComponent.h" },
	};
	static constexpr UECodeGen_Private::FMetaDataPairParam NewProp_WallTraceDistance_MetaData[] = {
		{ "Category", "Pilot|WallRun" },
		{ "ModuleRelativePath", "PilotMovementComponent.h" },
	};
#endif // WITH_METADATA

// ********** Begin Class UPilotMovementComponent constinit property declarations ******************
	static const UECodeGen_Private::FFloatPropertyParams NewProp_SprintSpeed;
	static const UECodeGen_Private::FFloatPropertyParams NewProp_SlideEnterSpeed;
	static const UECodeGen_Private::FFloatPropertyParams NewProp_SlideMinSpeed;
	static const UECodeGen_Private::FFloatPropertyParams NewProp_SlideFriction;
	static const UECodeGen_Private::FFloatPropertyParams NewProp_WallRunMinSpeed;
	static const UECodeGen_Private::FFloatPropertyParams NewProp_WallRunGravityScale;
	static const UECodeGen_Private::FFloatPropertyParams NewProp_WallTraceDistance;
	static const UECodeGen_Private::FPropertyParamsBase* const PropPointers[];
// ********** End Class UPilotMovementComponent constinit property declarations ********************
	static constexpr UE::CodeGen::FClassNativeFunction Funcs[] = {
		{ .NameUTF8 = UTF8TEXT("SetWantsSlide"), .Pointer = &UPilotMovementComponent::execSetWantsSlide },
		{ .NameUTF8 = UTF8TEXT("SetWantsSprint"), .Pointer = &UPilotMovementComponent::execSetWantsSprint },
	};
	static UObject* (*const DependentSingletons[])();
	static constexpr FClassFunctionLinkInfo FuncInfo[] = {
		{ &Z_Construct_UFunction_UPilotMovementComponent_SetWantsSlide, "SetWantsSlide" }, // 239724810
		{ &Z_Construct_UFunction_UPilotMovementComponent_SetWantsSprint, "SetWantsSprint" }, // 85492378
	};
	static_assert(UE_ARRAY_COUNT(FuncInfo) < 2048);
	static constexpr FCppClassTypeInfoStatic StaticCppClassTypeInfo = {
		TCppClassTypeTraits<UPilotMovementComponent>::IsAbstract,
	};
	static const UECodeGen_Private::FClassParams ClassParams;
}; // struct Z_Construct_UClass_UPilotMovementComponent_Statics

// ********** Begin Class UPilotMovementComponent Property Definitions *****************************
const UECodeGen_Private::FFloatPropertyParams Z_Construct_UClass_UPilotMovementComponent_Statics::NewProp_SprintSpeed = { "SprintSpeed", nullptr, (EPropertyFlags)0x0010000000000005, UECodeGen_Private::EPropertyGenFlags::Float, RF_Public|RF_Transient|RF_MarkAsNative, nullptr, nullptr, 1, STRUCT_OFFSET(UPilotMovementComponent, SprintSpeed), METADATA_PARAMS(UE_ARRAY_COUNT(NewProp_SprintSpeed_MetaData), NewProp_SprintSpeed_MetaData) };
const UECodeGen_Private::FFloatPropertyParams Z_Construct_UClass_UPilotMovementComponent_Statics::NewProp_SlideEnterSpeed = { "SlideEnterSpeed", nullptr, (EPropertyFlags)0x0010000000000005, UECodeGen_Private::EPropertyGenFlags::Float, RF_Public|RF_Transient|RF_MarkAsNative, nullptr, nullptr, 1, STRUCT_OFFSET(UPilotMovementComponent, SlideEnterSpeed), METADATA_PARAMS(UE_ARRAY_COUNT(NewProp_SlideEnterSpeed_MetaData), NewProp_SlideEnterSpeed_MetaData) };
const UECodeGen_Private::FFloatPropertyParams Z_Construct_UClass_UPilotMovementComponent_Statics::NewProp_SlideMinSpeed = { "SlideMinSpeed", nullptr, (EPropertyFlags)0x0010000000000005, UECodeGen_Private::EPropertyGenFlags::Float, RF_Public|RF_Transient|RF_MarkAsNative, nullptr, nullptr, 1, STRUCT_OFFSET(UPilotMovementComponent, SlideMinSpeed), METADATA_PARAMS(UE_ARRAY_COUNT(NewProp_SlideMinSpeed_MetaData), NewProp_SlideMinSpeed_MetaData) };
const UECodeGen_Private::FFloatPropertyParams Z_Construct_UClass_UPilotMovementComponent_Statics::NewProp_SlideFriction = { "SlideFriction", nullptr, (EPropertyFlags)0x0010000000000005, UECodeGen_Private::EPropertyGenFlags::Float, RF_Public|RF_Transient|RF_MarkAsNative, nullptr, nullptr, 1, STRUCT_OFFSET(UPilotMovementComponent, SlideFriction), METADATA_PARAMS(UE_ARRAY_COUNT(NewProp_SlideFriction_MetaData), NewProp_SlideFriction_MetaData) };
const UECodeGen_Private::FFloatPropertyParams Z_Construct_UClass_UPilotMovementComponent_Statics::NewProp_WallRunMinSpeed = { "WallRunMinSpeed", nullptr, (EPropertyFlags)0x0010000000000005, UECodeGen_Private::EPropertyGenFlags::Float, RF_Public|RF_Transient|RF_MarkAsNative, nullptr, nullptr, 1, STRUCT_OFFSET(UPilotMovementComponent, WallRunMinSpeed), METADATA_PARAMS(UE_ARRAY_COUNT(NewProp_WallRunMinSpeed_MetaData), NewProp_WallRunMinSpeed_MetaData) };
const UECodeGen_Private::FFloatPropertyParams Z_Construct_UClass_UPilotMovementComponent_Statics::NewProp_WallRunGravityScale = { "WallRunGravityScale", nullptr, (EPropertyFlags)0x0010000000000005, UECodeGen_Private::EPropertyGenFlags::Float, RF_Public|RF_Transient|RF_MarkAsNative, nullptr, nullptr, 1, STRUCT_OFFSET(UPilotMovementComponent, WallRunGravityScale), METADATA_PARAMS(UE_ARRAY_COUNT(NewProp_WallRunGravityScale_MetaData), NewProp_WallRunGravityScale_MetaData) };
const UECodeGen_Private::FFloatPropertyParams Z_Construct_UClass_UPilotMovementComponent_Statics::NewProp_WallTraceDistance = { "WallTraceDistance", nullptr, (EPropertyFlags)0x0010000000000005, UECodeGen_Private::EPropertyGenFlags::Float, RF_Public|RF_Transient|RF_MarkAsNative, nullptr, nullptr, 1, STRUCT_OFFSET(UPilotMovementComponent, WallTraceDistance), METADATA_PARAMS(UE_ARRAY_COUNT(NewProp_WallTraceDistance_MetaData), NewProp_WallTraceDistance_MetaData) };
const UECodeGen_Private::FPropertyParamsBase* const Z_Construct_UClass_UPilotMovementComponent_Statics::PropPointers[] = {
	(const UECodeGen_Private::FPropertyParamsBase*)&Z_Construct_UClass_UPilotMovementComponent_Statics::NewProp_SprintSpeed,
	(const UECodeGen_Private::FPropertyParamsBase*)&Z_Construct_UClass_UPilotMovementComponent_Statics::NewProp_SlideEnterSpeed,
	(const UECodeGen_Private::FPropertyParamsBase*)&Z_Construct_UClass_UPilotMovementComponent_Statics::NewProp_SlideMinSpeed,
	(const UECodeGen_Private::FPropertyParamsBase*)&Z_Construct_UClass_UPilotMovementComponent_Statics::NewProp_SlideFriction,
	(const UECodeGen_Private::FPropertyParamsBase*)&Z_Construct_UClass_UPilotMovementComponent_Statics::NewProp_WallRunMinSpeed,
	(const UECodeGen_Private::FPropertyParamsBase*)&Z_Construct_UClass_UPilotMovementComponent_Statics::NewProp_WallRunGravityScale,
	(const UECodeGen_Private::FPropertyParamsBase*)&Z_Construct_UClass_UPilotMovementComponent_Statics::NewProp_WallTraceDistance,
};
static_assert(UE_ARRAY_COUNT(Z_Construct_UClass_UPilotMovementComponent_Statics::PropPointers) < 2048);
// ********** End Class UPilotMovementComponent Property Definitions *******************************
UObject* (*const Z_Construct_UClass_UPilotMovementComponent_Statics::DependentSingletons[])() = {
	(UObject* (*)())Z_Construct_UClass_UCharacterMovementComponent,
	(UObject* (*)())Z_Construct_UPackage__Script_ProjectP1L0T,
};
static_assert(UE_ARRAY_COUNT(Z_Construct_UClass_UPilotMovementComponent_Statics::DependentSingletons) < 16);
const UECodeGen_Private::FClassParams Z_Construct_UClass_UPilotMovementComponent_Statics::ClassParams = {
	&UPilotMovementComponent::StaticClass,
	"Engine",
	&StaticCppClassTypeInfo,
	DependentSingletons,
	FuncInfo,
	Z_Construct_UClass_UPilotMovementComponent_Statics::PropPointers,
	nullptr,
	UE_ARRAY_COUNT(DependentSingletons),
	UE_ARRAY_COUNT(FuncInfo),
	UE_ARRAY_COUNT(Z_Construct_UClass_UPilotMovementComponent_Statics::PropPointers),
	0,
	0x00B000A4u,
	METADATA_PARAMS(UE_ARRAY_COUNT(Z_Construct_UClass_UPilotMovementComponent_Statics::Class_MetaDataParams), Z_Construct_UClass_UPilotMovementComponent_Statics::Class_MetaDataParams)
};
void UPilotMovementComponent::StaticRegisterNativesUPilotMovementComponent()
{
	UClass* Class = UPilotMovementComponent::StaticClass();
	FNativeFunctionRegistrar::RegisterFunctions(Class, MakeConstArrayView(Z_Construct_UClass_UPilotMovementComponent_Statics::Funcs));
}
UClass* Z_Construct_UClass_UPilotMovementComponent()
{
	if (!Z_Registration_Info_UClass_UPilotMovementComponent.OuterSingleton)
	{
		UECodeGen_Private::ConstructUClass(Z_Registration_Info_UClass_UPilotMovementComponent.OuterSingleton, Z_Construct_UClass_UPilotMovementComponent_Statics::ClassParams);
	}
	return Z_Registration_Info_UClass_UPilotMovementComponent.OuterSingleton;
}
UPilotMovementComponent::UPilotMovementComponent(const FObjectInitializer& ObjectInitializer) : Super(ObjectInitializer) {}
DEFINE_VTABLE_PTR_HELPER_CTOR_NS(, UPilotMovementComponent);
UPilotMovementComponent::~UPilotMovementComponent() {}
// ********** End Class UPilotMovementComponent ****************************************************

// ********** Begin Registration *******************************************************************
struct Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h__Script_ProjectP1L0T_Statics
{
	static constexpr FEnumRegisterCompiledInInfo EnumInfo[] = {
		{ EPilotCustomMode_StaticEnum, TEXT("EPilotCustomMode"), &Z_Registration_Info_UEnum_EPilotCustomMode, CONSTRUCT_RELOAD_VERSION_INFO(FEnumReloadVersionInfo, 1992851581U) },
	};
	static constexpr FClassRegisterCompiledInInfo ClassInfo[] = {
		{ Z_Construct_UClass_UPilotMovementComponent, UPilotMovementComponent::StaticClass, TEXT("UPilotMovementComponent"), &Z_Registration_Info_UClass_UPilotMovementComponent, CONSTRUCT_RELOAD_VERSION_INFO(FClassReloadVersionInfo, sizeof(UPilotMovementComponent), 3741830393U) },
	};
}; // Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h__Script_ProjectP1L0T_Statics 
static FRegisterCompiledInInfo Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h__Script_ProjectP1L0T_335733285{
	TEXT("/Script/ProjectP1L0T"),
	Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h__Script_ProjectP1L0T_Statics::ClassInfo, UE_ARRAY_COUNT(Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h__Script_ProjectP1L0T_Statics::ClassInfo),
	nullptr, 0,
	Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h__Script_ProjectP1L0T_Statics::EnumInfo, UE_ARRAY_COUNT(Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h__Script_ProjectP1L0T_Statics::EnumInfo),
};
// ********** End Registration *********************************************************************

PRAGMA_ENABLE_DEPRECATION_WARNINGS
