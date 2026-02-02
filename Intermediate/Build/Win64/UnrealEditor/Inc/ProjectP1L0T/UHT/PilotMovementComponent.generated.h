// Copyright Epic Games, Inc. All Rights Reserved.
/*===========================================================================
	Generated code exported from UnrealHeaderTool.
	DO NOT modify this manually! Edit the corresponding .h files instead!
===========================================================================*/

// IWYU pragma: private, include "PilotMovementComponent.h"

#ifdef PROJECTP1L0T_PilotMovementComponent_generated_h
#error "PilotMovementComponent.generated.h already included, missing '#pragma once' in PilotMovementComponent.h"
#endif
#define PROJECTP1L0T_PilotMovementComponent_generated_h

#include "UObject/ObjectMacros.h"
#include "UObject/ScriptMacros.h"

PRAGMA_DISABLE_DEPRECATION_WARNINGS

// ********** Begin Class UPilotMovementComponent **************************************************
#define FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h_18_RPC_WRAPPERS_NO_PURE_DECLS \
	DECLARE_FUNCTION(execSetWantsSlide); \
	DECLARE_FUNCTION(execSetWantsSprint);


struct Z_Construct_UClass_UPilotMovementComponent_Statics;
PROJECTP1L0T_API UClass* Z_Construct_UClass_UPilotMovementComponent_NoRegister();

#define FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h_18_INCLASS_NO_PURE_DECLS \
private: \
	static void StaticRegisterNativesUPilotMovementComponent(); \
	friend struct ::Z_Construct_UClass_UPilotMovementComponent_Statics; \
	static UClass* GetPrivateStaticClass(); \
	friend PROJECTP1L0T_API UClass* ::Z_Construct_UClass_UPilotMovementComponent_NoRegister(); \
public: \
	DECLARE_CLASS2(UPilotMovementComponent, UCharacterMovementComponent, COMPILED_IN_FLAGS(0 | CLASS_Config), CASTCLASS_None, TEXT("/Script/ProjectP1L0T"), Z_Construct_UClass_UPilotMovementComponent_NoRegister) \
	DECLARE_SERIALIZER(UPilotMovementComponent)


#define FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h_18_ENHANCED_CONSTRUCTORS \
	/** Standard constructor, called after all reflected properties have been initialized */ \
	NO_API UPilotMovementComponent(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get()); \
	/** Deleted move- and copy-constructors, should never be used */ \
	UPilotMovementComponent(UPilotMovementComponent&&) = delete; \
	UPilotMovementComponent(const UPilotMovementComponent&) = delete; \
	DECLARE_VTABLE_PTR_HELPER_CTOR(NO_API, UPilotMovementComponent); \
	DEFINE_VTABLE_PTR_HELPER_CTOR_CALLER(UPilotMovementComponent); \
	DEFINE_DEFAULT_OBJECT_INITIALIZER_CONSTRUCTOR_CALL(UPilotMovementComponent) \
	NO_API virtual ~UPilotMovementComponent();


#define FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h_15_PROLOG
#define FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h_18_GENERATED_BODY \
PRAGMA_DISABLE_DEPRECATION_WARNINGS \
public: \
	FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h_18_RPC_WRAPPERS_NO_PURE_DECLS \
	FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h_18_INCLASS_NO_PURE_DECLS \
	FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h_18_ENHANCED_CONSTRUCTORS \
private: \
PRAGMA_ENABLE_DEPRECATION_WARNINGS


class UPilotMovementComponent;

// ********** End Class UPilotMovementComponent ****************************************************

#undef CURRENT_FILE_ID
#define CURRENT_FILE_ID FID_OneDrive_Documents_Unreal_Projects_ProjectP1L0T_Source_ProjectP1L0T_PilotMovementComponent_h

// ********** Begin Enum EPilotCustomMode **********************************************************
#define FOREACH_ENUM_EPILOTCUSTOMMODE(op) \
	op(EPilotCustomMode::None) \
	op(EPilotCustomMode::Slide) \
	op(EPilotCustomMode::WallRun) 

enum class EPilotCustomMode : uint8;
template<> struct TIsUEnumClass<EPilotCustomMode> { enum { Value = true }; };
template<> PROJECTP1L0T_NON_ATTRIBUTED_API UEnum* StaticEnum<EPilotCustomMode>();
// ********** End Enum EPilotCustomMode ************************************************************

PRAGMA_ENABLE_DEPRECATION_WARNINGS
