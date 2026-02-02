// Copyright Epic Games, Inc. All Rights Reserved.
/*===========================================================================
	Generated code exported from UnrealHeaderTool.
	DO NOT modify this manually! Edit the corresponding .h files instead!
===========================================================================*/

#include "UObject/GeneratedCppIncludes.h"
#include "ProjectP1L0TGameMode.h"

PRAGMA_DISABLE_DEPRECATION_WARNINGS
static_assert(!UE_WITH_CONSTINIT_UOBJECT, "This generated code can only be compiled with !UE_WITH_CONSTINIT_OBJECT");
void EmptyLinkFunctionForGeneratedCodeProjectP1L0TGameMode() {}

// ********** Begin Cross Module References ********************************************************
ENGINE_API UClass* Z_Construct_UClass_AGameModeBase();
PROJECTP1L0T_API UClass* Z_Construct_UClass_AProjectP1L0TGameMode();
PROJECTP1L0T_API UClass* Z_Construct_UClass_AProjectP1L0TGameMode_NoRegister();
UPackage* Z_Construct_UPackage__Script_ProjectP1L0T();
// ********** End Cross Module References **********************************************************

// ********** Begin Class AProjectP1L0TGameMode ****************************************************
FClassRegistrationInfo Z_Registration_Info_UClass_AProjectP1L0TGameMode;
UClass* AProjectP1L0TGameMode::GetPrivateStaticClass()
{
	using TClass = AProjectP1L0TGameMode;
	if (!Z_Registration_Info_UClass_AProjectP1L0TGameMode.InnerSingleton)
	{
		GetPrivateStaticClassBody(
			TClass::StaticPackage(),
			TEXT("ProjectP1L0TGameMode"),
			Z_Registration_Info_UClass_AProjectP1L0TGameMode.InnerSingleton,
			StaticRegisterNativesAProjectP1L0TGameMode,
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
	return Z_Registration_Info_UClass_AProjectP1L0TGameMode.InnerSingleton;
}
UClass* Z_Construct_UClass_AProjectP1L0TGameMode_NoRegister()
{
	return AProjectP1L0TGameMode::GetPrivateStaticClass();
}
struct Z_Construct_UClass_AProjectP1L0TGameMode_Statics
{
#if WITH_METADATA
	static constexpr UECodeGen_Private::FMetaDataPairParam Class_MetaDataParams[] = {
		{ "HideCategories", "Info Rendering MovementReplication Replication Actor Input Movement Collision Rendering HLOD WorldPartition DataLayers Transformation" },
		{ "IncludePath", "ProjectP1L0TGameMode.h" },
		{ "ModuleRelativePath", "ProjectP1L0TGameMode.h" },
		{ "ShowCategories", "Input|MouseInput Input|TouchInput" },
	};
#endif // WITH_METADATA

// ********** Begin Class AProjectP1L0TGameMode constinit property declarations ********************
// ********** End Class AProjectP1L0TGameMode constinit property declarations **********************
	static UObject* (*const DependentSingletons[])();
	static constexpr FCppClassTypeInfoStatic StaticCppClassTypeInfo = {
		TCppClassTypeTraits<AProjectP1L0TGameMode>::IsAbstract,
	};
	static const UECodeGen_Private::FClassParams ClassParams;
}; // struct Z_Construct_UClass_AProjectP1L0TGameMode_Statics
UObject* (*const Z_Construct_UClass_AProjectP1L0TGameMode_Statics::DependentSingletons[])() = {
	(UObject* (*)())Z_Construct_UClass_AGameModeBase,
	(UObject* (*)())Z_Construct_UPackage__Script_ProjectP1L0T,
};
static_assert(UE_ARRAY_COUNT(Z_Construct_UClass_AProjectP1L0TGameMode_Statics::DependentSingletons) < 16);
const UECodeGen_Private::FClassParams Z_Construct_UClass_AProjectP1L0TGameMode_Statics::ClassParams = {
	&AProjectP1L0TGameMode::StaticClass,
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
	0x009002ACu,
	METADATA_PARAMS(UE_ARRAY_COUNT(Z_Construct_UClass_AProjectP1L0TGameMode_Statics::Class_MetaDataParams), Z_Construct_UClass_AProjectP1L0TGameMode_Statics::Class_MetaDataParams)
};
void AProjectP1L0TGameMode::StaticRegisterNativesAProjectP1L0TGameMode()
{
}
UClass* Z_Construct_UClass_AProjectP1L0TGameMode()
{
	if (!Z_Registration_Info_UClass_AProjectP1L0TGameMode.OuterSingleton)
	{
		UECodeGen_Private::ConstructUClass(Z_Registration_Info_UClass_AProjectP1L0TGameMode.OuterSingleton, Z_Construct_UClass_AProjectP1L0TGameMode_Statics::ClassParams);
	}
	return Z_Registration_Info_UClass_AProjectP1L0TGameMode.OuterSingleton;
}
DEFINE_VTABLE_PTR_HELPER_CTOR_NS(, AProjectP1L0TGameMode);
AProjectP1L0TGameMode::~AProjectP1L0TGameMode() {}
// ********** End Class AProjectP1L0TGameMode ******************************************************

// ********** Begin Registration *******************************************************************
struct Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_ProjectP1L0TGameMode_h__Script_ProjectP1L0T_Statics
{
	static constexpr FClassRegisterCompiledInInfo ClassInfo[] = {
		{ Z_Construct_UClass_AProjectP1L0TGameMode, AProjectP1L0TGameMode::StaticClass, TEXT("AProjectP1L0TGameMode"), &Z_Registration_Info_UClass_AProjectP1L0TGameMode, CONSTRUCT_RELOAD_VERSION_INFO(FClassReloadVersionInfo, sizeof(AProjectP1L0TGameMode), 1604592509U) },
	};
}; // Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_ProjectP1L0TGameMode_h__Script_ProjectP1L0T_Statics 
static FRegisterCompiledInInfo Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_ProjectP1L0TGameMode_h__Script_ProjectP1L0T_3951496762{
	TEXT("/Script/ProjectP1L0T"),
	Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_ProjectP1L0TGameMode_h__Script_ProjectP1L0T_Statics::ClassInfo, UE_ARRAY_COUNT(Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_ProjectP1L0TGameMode_h__Script_ProjectP1L0T_Statics::ClassInfo),
	nullptr, 0,
	nullptr, 0,
};
// ********** End Registration *********************************************************************

PRAGMA_ENABLE_DEPRECATION_WARNINGS
