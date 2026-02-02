// Copyright Epic Games, Inc. All Rights Reserved.
/*===========================================================================
	Generated code exported from UnrealHeaderTool.
	DO NOT modify this manually! Edit the corresponding .h files instead!
===========================================================================*/

#include "UObject/GeneratedCppIncludes.h"
#include "PilotCharacter.h"

PRAGMA_DISABLE_DEPRECATION_WARNINGS
static_assert(!UE_WITH_CONSTINIT_UOBJECT, "This generated code can only be compiled with !UE_WITH_CONSTINIT_OBJECT");
void EmptyLinkFunctionForGeneratedCodePilotCharacter() {}

// ********** Begin Cross Module References ********************************************************
ENGINE_API UClass* Z_Construct_UClass_ACharacter();
PROJECTP1L0T_API UClass* Z_Construct_UClass_APilotCharacter();
PROJECTP1L0T_API UClass* Z_Construct_UClass_APilotCharacter_NoRegister();
UPackage* Z_Construct_UPackage__Script_ProjectP1L0T();
// ********** End Cross Module References **********************************************************

// ********** Begin Class APilotCharacter **********************************************************
FClassRegistrationInfo Z_Registration_Info_UClass_APilotCharacter;
UClass* APilotCharacter::GetPrivateStaticClass()
{
	using TClass = APilotCharacter;
	if (!Z_Registration_Info_UClass_APilotCharacter.InnerSingleton)
	{
		GetPrivateStaticClassBody(
			TClass::StaticPackage(),
			TEXT("PilotCharacter"),
			Z_Registration_Info_UClass_APilotCharacter.InnerSingleton,
			StaticRegisterNativesAPilotCharacter,
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
	return Z_Registration_Info_UClass_APilotCharacter.InnerSingleton;
}
UClass* Z_Construct_UClass_APilotCharacter_NoRegister()
{
	return APilotCharacter::GetPrivateStaticClass();
}
struct Z_Construct_UClass_APilotCharacter_Statics
{
#if WITH_METADATA
	static constexpr UECodeGen_Private::FMetaDataPairParam Class_MetaDataParams[] = {
		{ "HideCategories", "Navigation" },
		{ "IncludePath", "PilotCharacter.h" },
		{ "ModuleRelativePath", "PilotCharacter.h" },
		{ "ObjectInitializerConstructorDeclared", "" },
	};
#endif // WITH_METADATA

// ********** Begin Class APilotCharacter constinit property declarations **************************
// ********** End Class APilotCharacter constinit property declarations ****************************
	static UObject* (*const DependentSingletons[])();
	static constexpr FCppClassTypeInfoStatic StaticCppClassTypeInfo = {
		TCppClassTypeTraits<APilotCharacter>::IsAbstract,
	};
	static const UECodeGen_Private::FClassParams ClassParams;
}; // struct Z_Construct_UClass_APilotCharacter_Statics
UObject* (*const Z_Construct_UClass_APilotCharacter_Statics::DependentSingletons[])() = {
	(UObject* (*)())Z_Construct_UClass_ACharacter,
	(UObject* (*)())Z_Construct_UPackage__Script_ProjectP1L0T,
};
static_assert(UE_ARRAY_COUNT(Z_Construct_UClass_APilotCharacter_Statics::DependentSingletons) < 16);
const UECodeGen_Private::FClassParams Z_Construct_UClass_APilotCharacter_Statics::ClassParams = {
	&APilotCharacter::StaticClass,
	"Game",
	&StaticCppClassTypeInfo,
	DependentSingletons,
	nullptr,
	nullptr,
	nullptr,
	UE_ARRAY_COUNT(DependentSingletons),
	0,
	0,
	0,
	0x009000A4u,
	METADATA_PARAMS(UE_ARRAY_COUNT(Z_Construct_UClass_APilotCharacter_Statics::Class_MetaDataParams), Z_Construct_UClass_APilotCharacter_Statics::Class_MetaDataParams)
};
void APilotCharacter::StaticRegisterNativesAPilotCharacter()
{
}
UClass* Z_Construct_UClass_APilotCharacter()
{
	if (!Z_Registration_Info_UClass_APilotCharacter.OuterSingleton)
	{
		UECodeGen_Private::ConstructUClass(Z_Registration_Info_UClass_APilotCharacter.OuterSingleton, Z_Construct_UClass_APilotCharacter_Statics::ClassParams);
	}
	return Z_Registration_Info_UClass_APilotCharacter.OuterSingleton;
}
DEFINE_VTABLE_PTR_HELPER_CTOR_NS(, APilotCharacter);
APilotCharacter::~APilotCharacter() {}
// ********** End Class APilotCharacter ************************************************************

// ********** Begin Registration *******************************************************************
struct Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotCharacter_h__Script_ProjectP1L0T_Statics
{
	static constexpr FClassRegisterCompiledInInfo ClassInfo[] = {
		{ Z_Construct_UClass_APilotCharacter, APilotCharacter::StaticClass, TEXT("APilotCharacter"), &Z_Registration_Info_UClass_APilotCharacter, CONSTRUCT_RELOAD_VERSION_INFO(FClassReloadVersionInfo, sizeof(APilotCharacter), 428692309U) },
	};
}; // Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotCharacter_h__Script_ProjectP1L0T_Statics 
static FRegisterCompiledInInfo Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotCharacter_h__Script_ProjectP1L0T_2884135248{
	TEXT("/Script/ProjectP1L0T"),
	Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotCharacter_h__Script_ProjectP1L0T_Statics::ClassInfo, UE_ARRAY_COUNT(Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotCharacter_h__Script_ProjectP1L0T_Statics::ClassInfo),
	nullptr, 0,
	nullptr, 0,
};
// ********** End Registration *********************************************************************

PRAGMA_ENABLE_DEPRECATION_WARNINGS
