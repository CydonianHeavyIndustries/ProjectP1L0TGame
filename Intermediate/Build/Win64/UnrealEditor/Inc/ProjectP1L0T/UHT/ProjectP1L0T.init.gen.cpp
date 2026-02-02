// Copyright Epic Games, Inc. All Rights Reserved.
/*===========================================================================
	Generated code exported from UnrealHeaderTool.
	DO NOT modify this manually! Edit the corresponding .h files instead!
===========================================================================*/

#include "UObject/GeneratedCppIncludes.h"
PRAGMA_DISABLE_DEPRECATION_WARNINGS
void EmptyLinkFunctionForGeneratedCodeProjectP1L0T_init() {}
static_assert(!UE_WITH_CONSTINIT_UOBJECT, "This generated code can only be compiled with !UE_WITH_CONSTINIT_OBJECT");	PROJECTP1L0T_API UFunction* Z_Construct_UDelegateFunction_ProjectP1L0T_BulletCountUpdatedDelegate__DelegateSignature();
	PROJECTP1L0T_API UFunction* Z_Construct_UDelegateFunction_ProjectP1L0T_DamagedDelegate__DelegateSignature();
	PROJECTP1L0T_API UFunction* Z_Construct_UDelegateFunction_ProjectP1L0T_PawnDeathDelegate__DelegateSignature();
	PROJECTP1L0T_API UFunction* Z_Construct_UDelegateFunction_ProjectP1L0T_SprintStateChangedDelegate__DelegateSignature();
	PROJECTP1L0T_API UFunction* Z_Construct_UDelegateFunction_ProjectP1L0T_UpdateSprintMeterDelegate__DelegateSignature();
	static FPackageRegistrationInfo Z_Registration_Info_UPackage__Script_ProjectP1L0T;
	FORCENOINLINE UPackage* Z_Construct_UPackage__Script_ProjectP1L0T()
	{
		if (!Z_Registration_Info_UPackage__Script_ProjectP1L0T.OuterSingleton)
		{
		static UObject* (*const SingletonFuncArray[])() = {
			(UObject* (*)())Z_Construct_UDelegateFunction_ProjectP1L0T_BulletCountUpdatedDelegate__DelegateSignature,
			(UObject* (*)())Z_Construct_UDelegateFunction_ProjectP1L0T_DamagedDelegate__DelegateSignature,
			(UObject* (*)())Z_Construct_UDelegateFunction_ProjectP1L0T_PawnDeathDelegate__DelegateSignature,
			(UObject* (*)())Z_Construct_UDelegateFunction_ProjectP1L0T_SprintStateChangedDelegate__DelegateSignature,
			(UObject* (*)())Z_Construct_UDelegateFunction_ProjectP1L0T_UpdateSprintMeterDelegate__DelegateSignature,
		};
		static const UECodeGen_Private::FPackageParams PackageParams = {
			"/Script/ProjectP1L0T",
			SingletonFuncArray,
			UE_ARRAY_COUNT(SingletonFuncArray),
			PKG_CompiledIn | 0x00000000,
			0x02257188,
			0x712EF2B9,
			METADATA_PARAMS(0, nullptr)
		};
		UECodeGen_Private::ConstructUPackage(Z_Registration_Info_UPackage__Script_ProjectP1L0T.OuterSingleton, PackageParams);
	}
	return Z_Registration_Info_UPackage__Script_ProjectP1L0T.OuterSingleton;
}
static FRegisterCompiledInInfo Z_CompiledInDeferPackage_UPackage__Script_ProjectP1L0T(Z_Construct_UPackage__Script_ProjectP1L0T, TEXT("/Script/ProjectP1L0T"), Z_Registration_Info_UPackage__Script_ProjectP1L0T, CONSTRUCT_RELOAD_VERSION_INFO(FPackageReloadVersionInfo, 0x02257188, 0x712EF2B9));
PRAGMA_ENABLE_DEPRECATION_WARNINGS
