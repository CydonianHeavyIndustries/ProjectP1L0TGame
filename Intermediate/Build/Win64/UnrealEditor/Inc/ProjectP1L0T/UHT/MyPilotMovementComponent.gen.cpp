// Copyright Epic Games, Inc. All Rights Reserved.
/*===========================================================================
	Generated code exported from UnrealHeaderTool.
	DO NOT modify this manually! Edit the corresponding .h files instead!
===========================================================================*/

#include "UObject/GeneratedCppIncludes.h"
#include "MyPilotMovementComponent.h"

PRAGMA_DISABLE_DEPRECATION_WARNINGS
static_assert(!UE_WITH_CONSTINIT_UOBJECT, "This generated code can only be compiled with !UE_WITH_CONSTINIT_OBJECT");
void EmptyLinkFunctionForGeneratedCodeMyPilotMovementComponent() {}

// ********** Begin Cross Module References ********************************************************
ENGINE_API UClass* Z_Construct_UClass_UCharacterMovementComponent();
PROJECTP1L0T_API UClass* Z_Construct_UClass_UMyPilotMovementComponent();
PROJECTP1L0T_API UClass* Z_Construct_UClass_UMyPilotMovementComponent_NoRegister();
UPackage* Z_Construct_UPackage__Script_ProjectP1L0T();
// ********** End Cross Module References **********************************************************

// ********** Begin Class UMyPilotMovementComponent ************************************************
FClassRegistrationInfo Z_Registration_Info_UClass_UMyPilotMovementComponent;
UClass* UMyPilotMovementComponent::GetPrivateStaticClass()
{
	using TClass = UMyPilotMovementComponent;
	if (!Z_Registration_Info_UClass_UMyPilotMovementComponent.InnerSingleton)
	{
		GetPrivateStaticClassBody(
			TClass::StaticPackage(),
			TEXT("MyPilotMovementComponent"),
			Z_Registration_Info_UClass_UMyPilotMovementComponent.InnerSingleton,
			StaticRegisterNativesUMyPilotMovementComponent,
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
	return Z_Registration_Info_UClass_UMyPilotMovementComponent.InnerSingleton;
}
UClass* Z_Construct_UClass_UMyPilotMovementComponent_NoRegister()
{
	return UMyPilotMovementComponent::GetPrivateStaticClass();
}
struct Z_Construct_UClass_UMyPilotMovementComponent_Statics
{
#if WITH_METADATA
	static constexpr UECodeGen_Private::FMetaDataPairParam Class_MetaDataParams[] = {
#if !UE_BUILD_SHIPPING
		{ "Comment", "/**\n * \n */" },
#endif
		{ "IncludePath", "MyPilotMovementComponent.h" },
		{ "ModuleRelativePath", "MyPilotMovementComponent.h" },
	};
#endif // WITH_METADATA

// ********** Begin Class UMyPilotMovementComponent constinit property declarations ****************
// ********** End Class UMyPilotMovementComponent constinit property declarations ******************
	static UObject* (*const DependentSingletons[])();
	static constexpr FCppClassTypeInfoStatic StaticCppClassTypeInfo = {
		TCppClassTypeTraits<UMyPilotMovementComponent>::IsAbstract,
	};
	static const UECodeGen_Private::FClassParams ClassParams;
}; // struct Z_Construct_UClass_UMyPilotMovementComponent_Statics
UObject* (*const Z_Construct_UClass_UMyPilotMovementComponent_Statics::DependentSingletons[])() = {
	(UObject* (*)())Z_Construct_UClass_UCharacterMovementComponent,
	(UObject* (*)())Z_Construct_UPackage__Script_ProjectP1L0T,
};
static_assert(UE_ARRAY_COUNT(Z_Construct_UClass_UMyPilotMovementComponent_Statics::DependentSingletons) < 16);
const UECodeGen_Private::FClassParams Z_Construct_UClass_UMyPilotMovementComponent_Statics::ClassParams = {
	&UMyPilotMovementComponent::StaticClass,
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
	0x00B000A4u,
	METADATA_PARAMS(UE_ARRAY_COUNT(Z_Construct_UClass_UMyPilotMovementComponent_Statics::Class_MetaDataParams), Z_Construct_UClass_UMyPilotMovementComponent_Statics::Class_MetaDataParams)
};
void UMyPilotMovementComponent::StaticRegisterNativesUMyPilotMovementComponent()
{
}
UClass* Z_Construct_UClass_UMyPilotMovementComponent()
{
	if (!Z_Registration_Info_UClass_UMyPilotMovementComponent.OuterSingleton)
	{
		UECodeGen_Private::ConstructUClass(Z_Registration_Info_UClass_UMyPilotMovementComponent.OuterSingleton, Z_Construct_UClass_UMyPilotMovementComponent_Statics::ClassParams);
	}
	return Z_Registration_Info_UClass_UMyPilotMovementComponent.OuterSingleton;
}
UMyPilotMovementComponent::UMyPilotMovementComponent(const FObjectInitializer& ObjectInitializer) : Super(ObjectInitializer) {}
DEFINE_VTABLE_PTR_HELPER_CTOR_NS(, UMyPilotMovementComponent);
UMyPilotMovementComponent::~UMyPilotMovementComponent() {}
// ********** End Class UMyPilotMovementComponent **************************************************

// ********** Begin Registration *******************************************************************
struct Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_MyPilotMovementComponent_h__Script_ProjectP1L0T_Statics
{
	static constexpr FClassRegisterCompiledInInfo ClassInfo[] = {
		{ Z_Construct_UClass_UMyPilotMovementComponent, UMyPilotMovementComponent::StaticClass, TEXT("UMyPilotMovementComponent"), &Z_Registration_Info_UClass_UMyPilotMovementComponent, CONSTRUCT_RELOAD_VERSION_INFO(FClassReloadVersionInfo, sizeof(UMyPilotMovementComponent), 821746410U) },
	};
}; // Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_MyPilotMovementComponent_h__Script_ProjectP1L0T_Statics 
static FRegisterCompiledInInfo Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_MyPilotMovementComponent_h__Script_ProjectP1L0T_3186148005{
	TEXT("/Script/ProjectP1L0T"),
	Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_MyPilotMovementComponent_h__Script_ProjectP1L0T_Statics::ClassInfo, UE_ARRAY_COUNT(Z_CompiledInDeferFile_FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_MyPilotMovementComponent_h__Script_ProjectP1L0T_Statics::ClassInfo),
	nullptr, 0,
	nullptr, 0,
};
// ********** End Registration *********************************************************************

PRAGMA_ENABLE_DEPRECATION_WARNINGS
