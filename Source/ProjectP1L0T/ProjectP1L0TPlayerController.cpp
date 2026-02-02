// Copyright Epic Games, Inc. All Rights Reserved.


#include "ProjectP1L0TPlayerController.h"
#include "EnhancedInputSubsystems.h"
#include "Engine/LocalPlayer.h"
#include "InputMappingContext.h"
#include "ProjectP1L0TCameraManager.h"
#include "Blueprint/UserWidget.h"
#include "ProjectP1L0T.h"
#include "UI/TitleScreenWidget.h"
#include "Widgets/Input/SVirtualJoystick.h"
#include "Kismet/KismetSystemLibrary.h"

AProjectP1L0TPlayerController::AProjectP1L0TPlayerController()
{
	// set the player camera manager class
	PlayerCameraManagerClass = AProjectP1L0TCameraManager::StaticClass();
}

void AProjectP1L0TPlayerController::BeginPlay()
{
	Super::BeginPlay();

	if (bShowTitleScreenOnStart)
	{
		ShowTitleScreen();
	}

	// only spawn touch controls on local player controllers
	if (ShouldUseTouchControls() && IsLocalPlayerController())
	{
		// spawn the mobile controls widget
		MobileControlsWidget = CreateWidget<UUserWidget>(this, MobileControlsWidgetClass);

		if (MobileControlsWidget)
		{
			// add the controls to the player screen
			MobileControlsWidget->AddToPlayerScreen(0);

		} else {

			UE_LOG(LogProjectP1L0T, Error, TEXT("Could not spawn mobile controls widget."));

		}

	}
}

void AProjectP1L0TPlayerController::SetupInputComponent()
{
	Super::SetupInputComponent();

	// only add IMCs for local player controllers
	if (IsLocalPlayerController())
	{
		// Add Input Mapping Context
		if (UEnhancedInputLocalPlayerSubsystem* Subsystem = ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(GetLocalPlayer()))
		{
			for (UInputMappingContext* CurrentContext : DefaultMappingContexts)
			{
				Subsystem->AddMappingContext(CurrentContext, 0);
			}

			// only add these IMCs if we're not using mobile touch input
			if (!ShouldUseTouchControls())
			{
				for (UInputMappingContext* CurrentContext : MobileExcludedMappingContexts)
				{
					Subsystem->AddMappingContext(CurrentContext, 0);
				}
			}
		}
	}
	
}

bool AProjectP1L0TPlayerController::ShouldUseTouchControls() const
{
	// are we on a mobile platform? Should we force touch?
	return SVirtualJoystick::ShouldDisplayTouchInterface() || bForceTouchControls;
}

void AProjectP1L0TPlayerController::ShowTitleScreen()
{
	if (!IsLocalPlayerController() || TitleScreenWidget)
	{
		return;
	}

	TSubclassOf<UUserWidget> WidgetClass = TitleScreenWidgetClass;
	if (!WidgetClass)
	{
		WidgetClass = UTitleScreenWidget::StaticClass();
	}

	TitleScreenWidget = CreateWidget<UUserWidget>(this, WidgetClass);
	if (!TitleScreenWidget)
	{
		UE_LOG(LogProjectP1L0T, Error, TEXT("Could not spawn title screen widget."));
		return;
	}

	TitleScreenWidget->AddToViewport(0);

	FInputModeUIOnly InputMode;
	InputMode.SetLockMouseToViewportBehavior(EMouseLockMode::DoNotLock);
	InputMode.SetWidgetToFocus(TitleScreenWidget->TakeWidget());
	SetInputMode(InputMode);
	bShowMouseCursor = true;
	bEnableClickEvents = true;
	bEnableMouseOverEvents = true;
	SetPause(true);
}

void AProjectP1L0TPlayerController::HideTitleScreen()
{
	if (TitleScreenWidget)
	{
		TitleScreenWidget->RemoveFromParent();
		TitleScreenWidget = nullptr;
	}

	FInputModeGameOnly InputMode;
	SetInputMode(InputMode);
	bShowMouseCursor = false;
	bEnableClickEvents = false;
	bEnableMouseOverEvents = false;
	SetPause(false);
}

void AProjectP1L0TPlayerController::HandleTitlePlay()
{
	HideTitleScreen();
}

void AProjectP1L0TPlayerController::HandleTitleOptions()
{
	UE_LOG(LogProjectP1L0T, Log, TEXT("Options selected (placeholder)."));
}

void AProjectP1L0TPlayerController::HandleTitleExit()
{
	UKismetSystemLibrary::QuitGame(this, this, EQuitPreference::Quit, false);
}
