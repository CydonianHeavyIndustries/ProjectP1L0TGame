// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/PlayerController.h"
#include "ProjectP1L0TPlayerController.generated.h"

class UInputMappingContext;
class UUserWidget;

/**
 *  Simple first person Player Controller
 *  Manages the input mapping context.
 *  Overrides the Player Camera Manager class.
 */
UCLASS(abstract, config="Game")
class PROJECTP1L0T_API AProjectP1L0TPlayerController : public APlayerController
{
	GENERATED_BODY()
	
public:

	/** Constructor */
	AProjectP1L0TPlayerController();

	void HandleTitlePlay();
	void HandleTitleOptions();
	void HandleTitleExit();

protected:

	/** Input Mapping Contexts */
	UPROPERTY(EditAnywhere, Category="Input|Input Mappings")
	TArray<UInputMappingContext*> DefaultMappingContexts;

	/** Input Mapping Contexts */
	UPROPERTY(EditAnywhere, Category="Input|Input Mappings")
	TArray<UInputMappingContext*> MobileExcludedMappingContexts;

	/** Mobile controls widget to spawn */
	UPROPERTY(EditAnywhere, Category="Input|Touch Controls")
	TSubclassOf<UUserWidget> MobileControlsWidgetClass;

	/** Pointer to the mobile controls widget */
	UPROPERTY()
	TObjectPtr<UUserWidget> MobileControlsWidget;

	/** Title screen widget to spawn */
	UPROPERTY(EditAnywhere, Category="UI")
	TSubclassOf<UUserWidget> TitleScreenWidgetClass;

	/** Pointer to the title screen widget */
	UPROPERTY()
	TObjectPtr<UUserWidget> TitleScreenWidget;

	/** If true, the player will use UMG touch controls even if not playing on mobile platforms */
	UPROPERTY(EditAnywhere, Config, Category = "Input|Touch Controls")
	bool bForceTouchControls = false;

	/** If true, the title screen will show on begin play */
	UPROPERTY(EditAnywhere, Category = "UI")
	bool bShowTitleScreenOnStart = true;

	/** Gameplay initialization */
	virtual void BeginPlay() override;

	/** Input mapping context setup */
	virtual void SetupInputComponent() override;

	/** Returns true if the player should use UMG touch controls */
	bool ShouldUseTouchControls() const;

private:
	void ShowTitleScreen();
	void HideTitleScreen();
};
