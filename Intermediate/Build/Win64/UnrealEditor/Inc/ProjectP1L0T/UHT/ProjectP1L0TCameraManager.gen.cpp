// Copyright Epic Games, Inc. All Rights Reserved.
/*===========================================================================
	Generated code exported from UnrealHeaderTool.
	DO NOT modify this manually! Edit the corresponding .h files instead!
===========================================================================*/

#include "UObject/GeneratedCppIncludes.h"
#include "ProjectP1L0TCameraManager.h"

PRAGMA_DISABLE_DEPRECATION_WARNINGS
static_assert(!UE_WITH_CONSTINIT_UOBJECT, "This generated code can only be compiled with !UE_WITH_CONSTINIT_OBJECT");
void EmptyLinkFunctionForGeneratedCodeProjectP1L0TCameraManager() {}

// ********** Begin Cross Module References ********************************************************
ENGINE_API UClass* Z_Construct_UClass_APlayerCameraManager();
PROJECTP1L0T_API UClass* Z_Construct_UClass_AProjectP1L0TCameraManager();
PROJECTP1L0T_API UClass* Z_Construct_UClass_AProjectP1L0TCameraManager_NoRegister();
UPackage* Z_Construct_UPackage__Script_ProjectP1L0T();
// ********** End Cross Module References **********************************************************

// ********** Begin Class AProjectP1L0TCameraManager ***********************************************
FClassRegistrationInfo Z_Registration_Info_UClass_AProjectP1L0TCameraManager;
UClass* AProjectP1L0TCameraManager::GetPrivateStaticClass()
{
	using TClass = AProjectP1L0TCameraManager;
	if (!Z_Registration_Info_UClass_AProjectP1L0TCameraManager.InnerSingleton)
	{
		GetPrivateStaticClassBody(
			TClass::StaticPackage(),
			TEXT("ProjectP1L0TCameraManager"),
			Z_Registration_Info_UClass_AProjectP1L0TCameraManager.InnerSingleton,
			StaticRegisterNativesAProjectP1L0TCameraManager,
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
	return Z_Registration_Info_UClass_AProjectP1L0TCameraManager.InnerSingleton;
}
UClass* Z_Construct_UClass_AProjectP1L0TCameraManager_NoRegister()
{
	return AProjectP1L0TCameraManager::GetPrivateStaticClass();
}
struct Z_Construct_UClass_AProjectP1L0TCameraManager_Statics
{
#if WITH_METADATA
	static constexpr UECodeGen_Private::FMetaDataPairParam Class_MetaDataParams[] = {
#if !UE_BUILD_SHIPPING
		{ "Comment", "/**\n *  Basic First Person camera manager.\n *  Limits min/max look pitch.\n */" },
#endif
		{ "IncludePath", "ProjectP1L0TCameraManager.h" },
		{ "ModuleRelativePath", "ProjectP1L0TCameraManager.h" },
#if !UE_BUILD_SHIPPING
		{ "ToolTip", "Basic First Person camera manager.\nLimits min/max look pitch." },
#endif
	};
#endif // WITH_METADATA

// ********** Begin Class AProjectP1L0TCameraManager constinit property declarations ***************
// ********** End Class AProjectP1L0TCameraManager constinit property declarations *****************
	static UObject* (*const DependentSingletons[])();
	static constexpr FCppClassTypeInfoStatic StaticCppClassTypeInfo = {
		TCppClassTypeTraits<AProjectP1L0TCameraManager>::IsAbstract,
	};
	static const UECodeGen_Private::FClassParams ClassParams;
}; // struct Z_Construct_UClass_AProjectP1L0TCameraManager_Statics
UObject* (*const Z_Construct_UClass_AProjectP1L0TCameraManager_Statics::DependentSingletons[])() = {
	(UObject* (*)())Z_Construct_UClass_APlayerCameraManager,
	(UObject* (*)())Z_Construct_UPackage__Script_ProjectP1L0T,
};
static_assert(UE_ARRAY_COUNT(Z_Construct_UClass_AProjectP1L0TCameraManager_Statics::DependentSingletons) < 16);
const UECodeGen_Private::FClassParams Z_Construct_UClass_AProjectP1L0TCameraManager_Statics::ClassParams = {
	&AProjectP1L0TCameraManager::StaticClass,
	"Engine",
	&StaticCppClassTypeInfo,
	DependentSingletons,
	nullptr,
	nullptr,
	nullptr,
	UE_ARRAY_COUNT(DependentSingletons),
	0,
	0,
	0,
	0x008002ACu,
	METADATA_PARAMS(UE_ARRAY_COUNT(Z_Construct_UClass_AProjectP1L0TCameraManager_Statics::Class_MetaDataParams), Z_Construct_UClass_AProjectP1L0TCameraManager_Statics::Class_MetaDataParams)
};
void AProjectP1L0TCameraManager::StaticRegisterNativesAProjectP1L0TCameraManager()
{
}
UClass* Z_Construct_UClass_AProjectP1L0TCameraManager()
{
	if (!Z_Registration_Info_UClass_AProjectP1L0TCameraManager.OuterSingleton)
	{
		UECodeGen_Private::ConstructUClass(Z_Registration_Info_UClass_AProjectP1L0TCameraManager.OuterSingleton, Z_Construct_UClass_AProjectP1L0TCameraManager_Statics::ClassParams);
	}
	return Z_Registration_Info_UClass_AProjectP1L0TCameraManager.OuterSingleton;
}
DEFINE_VTABLE_PTR_HELPER_CTOR_NS(, AProjectP1L0TCameraManager);
AProjectP1L0TCameraManager::~AProjectP1L0TCameraManager() {}
// ********** End Class AProjectP1L0TCameraManager *************************************************

// ********** Begin Registration *******************************************************************
struct Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_ProjectP1L0TCameraManager_h__Script_ProjectP1L0T_Statics
{
	static constexpr FClassRegisterCompiledInInfo ClassInfo[] = {
		{ Z_Construct_UClass_AProjectP1L0TCameraManager, AProjectP1L0TCameraManager::StaticClass, TEXT("AProjectP1L0TCameraManager"), &Z_Registration_Info_UClass_AProjectP1L0TCameraManager, CONSTRUCT_RELOAD_VERSION_INFO(FClassReloadVersionInfo, sizeof(AProjectP1L0TCameraManager), 3953362161U) },
	};
}; // Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_ProjectP1L0TCameraManager_h__Script_ProjectP1L0T_Statics 
static FRegisterCompiledInInfo Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_ProjectP1L0TCameraManager_h__Script_ProjectP1L0T_892193408{
	TEXT("/Script/ProjectP1L0T"),
	Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_ProjectP1L0TCameraManager_h__Script_ProjectP1L0T_Statics::ClassInfo, UE_ARRAY_COUNT(Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_ProjectP1L0TCameraManager_h__Script_ProjectP1L0T_Statics::ClassInfo),
	nullptr, 0,
	nullptr, 0,
};
// ********** End Registration *********************************************************************

PRAGMA_ENABLE_DEPRECATION_WARNINGS
