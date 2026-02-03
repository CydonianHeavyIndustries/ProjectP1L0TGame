// Copyright Epic Games, Inc. All Rights Reserved.


#include "ProjectP1L0TPlayerController.h"
#include "EnhancedInputSubsystems.h"
#include "Engine/LocalPlayer.h"
#include "InputMappingContext.h"
#include "ProjectP1L0TCameraManager.h"
#include "Blueprint/UserWidget.h"
#include "ProjectP1L0T.h"
#include "UI/TitleScreenWidget.h"
#include "UI/PauseMenuWidget.h"
#include "UI/OptionsMenuWidget.h"
#include "Widgets/Input/SVirtualJoystick.h"
#include "Kismet/KismetSystemLibrary.h"
#include "Kismet/GameplayStatics.h"
#include "Sound/SoundClass.h"
#include "Sound/SoundMix.h"
#include "GameFramework/GameUserSettings.h"
#include "Misc/ConfigCacheIni.h"

AProjectP1L0TPlayerController::AProjectP1L0TPlayerController()
{
	// set the player camera manager class
	PlayerCameraManagerClass = AProjectP1L0TCameraManager::StaticClass();
}

void AProjectP1L0TPlayerController::BeginPlay()
{
	Super::BeginPlay();

	UE_LOG(LogProjectP1L0T, Display, TEXT("ProjectP1L0TPlayerController BeginPlay"));

	LoadAudioSettings();
	InitializeAudioMix();
	SyncGraphicsSettings();

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

		if (InputComponent)
		{
			FInputActionBinding& MenuBinding = InputComponent->BindAction("Menu", IE_Pressed, this, &AProjectP1L0TPlayerController::TogglePauseMenu);
			MenuBinding.bExecuteWhenPaused = true;
		}
	}
	
}

bool AProjectP1L0TPlayerController::ShouldUseTouchControls() const
{
	// are we on a mobile platform? Should we force touch?
	return SVirtualJoystick::ShouldDisplayTouchInterface() || bForceTouchControls;
}

void AProjectP1L0TPlayerController::InitializeAudioMix()
{
	if (OptionsSoundMix)
	{
		return;
	}

	OptionsSoundMix = NewObject<USoundMix>(this);
	MasterSoundClass = LoadObject<USoundClass>(nullptr, TEXT("/Engine/EngineSounds/Master.Master"));
	if (!MasterSoundClass)
	{
		MasterSoundClass = NewObject<USoundClass>(this);
	}

	MusicSoundClass = NewObject<USoundClass>(this);
	SfxSoundClass = NewObject<USoundClass>(this);
	MusicSoundClass->ParentClass = MasterSoundClass;
	SfxSoundClass->ParentClass = MasterSoundClass;

	ApplySoundMix();
}

void AProjectP1L0TPlayerController::LoadAudioSettings()
{
	if (!GConfig)
	{
		return;
	}

	static const TCHAR* Section = TEXT("ProjectP1L0T.Audio");
	GConfig->GetFloat(Section, TEXT("MasterVolume"), MasterVolume, GGameUserSettingsIni);
	GConfig->GetFloat(Section, TEXT("MusicVolume"), MusicVolume, GGameUserSettingsIni);
	GConfig->GetFloat(Section, TEXT("SfxVolume"), SfxVolume, GGameUserSettingsIni);
}

void AProjectP1L0TPlayerController::SaveAudioSettings() const
{
	if (!GConfig)
	{
		return;
	}

	static const TCHAR* Section = TEXT("ProjectP1L0T.Audio");
	GConfig->SetFloat(Section, TEXT("MasterVolume"), MasterVolume, GGameUserSettingsIni);
	GConfig->SetFloat(Section, TEXT("MusicVolume"), MusicVolume, GGameUserSettingsIni);
	GConfig->SetFloat(Section, TEXT("SfxVolume"), SfxVolume, GGameUserSettingsIni);
	GConfig->Flush(false, GGameUserSettingsIni);
}

void AProjectP1L0TPlayerController::ApplySoundMix()
{
	if (!OptionsSoundMix || !MasterSoundClass)
	{
		return;
	}

	UGameplayStatics::SetSoundMixClassOverride(this, OptionsSoundMix, MasterSoundClass, MasterVolume, 1.0f, 0.0f, true);
	UGameplayStatics::SetSoundMixClassOverride(this, OptionsSoundMix, MusicSoundClass, MusicVolume, 1.0f, 0.0f, true);
	UGameplayStatics::SetSoundMixClassOverride(this, OptionsSoundMix, SfxSoundClass, SfxVolume, 1.0f, 0.0f, true);
	UGameplayStatics::PushSoundMixModifier(this, OptionsSoundMix);
}

void AProjectP1L0TPlayerController::SyncGraphicsSettings()
{
	if (UGameUserSettings* Settings = GEngine ? GEngine->GetGameUserSettings() : nullptr)
	{
		const int32 QualityLevel = Settings->GetOverallScalabilityLevel();
		GraphicsQuality = FMath::Clamp(QualityLevel / 3.0f, 0.0f, 1.0f);
		bFullscreenEnabled = Settings->GetFullscreenMode() != EWindowMode::Windowed;
	}
}

void AProjectP1L0TPlayerController::SetMasterVolume(float Value)
{
	MasterVolume = FMath::Clamp(Value, 0.0f, 1.0f);
	ApplySoundMix();
	SaveAudioSettings();
}

void AProjectP1L0TPlayerController::SetMusicVolume(float Value)
{
	MusicVolume = FMath::Clamp(Value, 0.0f, 1.0f);
	ApplySoundMix();
	SaveAudioSettings();
}

void AProjectP1L0TPlayerController::SetSfxVolume(float Value)
{
	SfxVolume = FMath::Clamp(Value, 0.0f, 1.0f);
	ApplySoundMix();
	SaveAudioSettings();
}

void AProjectP1L0TPlayerController::SetGraphicsQuality(float Value)
{
	GraphicsQuality = FMath::Clamp(Value, 0.0f, 1.0f);
	const int32 QualityLevel = FMath::RoundToInt(GraphicsQuality * 3.0f);

	if (UGameUserSettings* Settings = GEngine ? GEngine->GetGameUserSettings() : nullptr)
	{
		Settings->SetOverallScalabilityLevel(QualityLevel);
		Settings->ApplySettings(false);
		Settings->SaveSettings();
	}
}

void AProjectP1L0TPlayerController::SetFullscreenEnabled(bool bEnabled)
{
	bFullscreenEnabled = bEnabled;
	if (UGameUserSettings* Settings = GEngine ? GEngine->GetGameUserSettings() : nullptr)
	{
		Settings->SetFullscreenMode(bEnabled ? EWindowMode::Fullscreen : EWindowMode::Windowed);
		Settings->ApplySettings(false);
		Settings->SaveSettings();
	}
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
	ActiveMenuContext = EMenuContext::Title;

	FInputModeUIOnly InputMode;
	InputMode.SetLockMouseToViewportBehavior(EMouseLockMode::DoNotLock);
	InputMode.SetWidgetToFocus(TitleScreenWidget->TakeWidget());
	SetInputMode(InputMode);
	bShowMouseCursor = true;
	bEnableClickEvents = true;
	bEnableMouseOverEvents = true;
	SetIgnoreMoveInput(true);
	SetIgnoreLookInput(true);
}

void AProjectP1L0TPlayerController::RemoveTitleScreenWidget()
{
	if (TitleScreenWidget)
	{
		TitleScreenWidget->RemoveFromParent();
		TitleScreenWidget = nullptr;
	}
}

void AProjectP1L0TPlayerController::HideTitleScreen()
{
	RemoveTitleScreenWidget();
	ActiveMenuContext = EMenuContext::None;

	FInputModeGameOnly InputMode;
	SetInputMode(InputMode);
	bShowMouseCursor = false;
	bEnableClickEvents = false;
	bEnableMouseOverEvents = false;
	SetIgnoreMoveInput(false);
	SetIgnoreLookInput(false);
	SetPause(false);
}

void AProjectP1L0TPlayerController::ShowPauseMenu()
{
	if (!IsLocalPlayerController() || PauseMenuWidget)
	{
		return;
	}

	TSubclassOf<UUserWidget> WidgetClass = PauseMenuWidgetClass;
	if (!WidgetClass)
	{
		WidgetClass = UPauseMenuWidget::StaticClass();
	}

	PauseMenuWidget = CreateWidget<UUserWidget>(this, WidgetClass);
	if (!PauseMenuWidget)
	{
		UE_LOG(LogProjectP1L0T, Error, TEXT("Could not spawn pause menu widget."));
		return;
	}

	PauseMenuWidget->AddToViewport(0);
	ActiveMenuContext = EMenuContext::Pause;

	FInputModeGameAndUI InputMode;
	InputMode.SetLockMouseToViewportBehavior(EMouseLockMode::DoNotLock);
	InputMode.SetWidgetToFocus(PauseMenuWidget->TakeWidget());
	SetInputMode(InputMode);
	bShowMouseCursor = true;
	bEnableClickEvents = true;
	bEnableMouseOverEvents = true;
	SetPause(true);
}

void AProjectP1L0TPlayerController::RemovePauseMenuWidget()
{
	if (PauseMenuWidget)
	{
		PauseMenuWidget->RemoveFromParent();
		PauseMenuWidget = nullptr;
	}
}

void AProjectP1L0TPlayerController::HidePauseMenu()
{
	RemovePauseMenuWidget();
	ActiveMenuContext = EMenuContext::None;

	FInputModeGameOnly InputMode;
	SetInputMode(InputMode);
	bShowMouseCursor = false;
	bEnableClickEvents = false;
	bEnableMouseOverEvents = false;
	SetPause(false);
}

void AProjectP1L0TPlayerController::ShowOptionsMenu()
{
	if (!IsLocalPlayerController() || OptionsMenuWidget)
	{
		return;
	}

	OptionsReturnContext = ActiveMenuContext;
	RemoveTitleScreenWidget();
	RemovePauseMenuWidget();

	TSubclassOf<UUserWidget> WidgetClass = OptionsMenuWidgetClass;
	if (!WidgetClass)
	{
		WidgetClass = UOptionsMenuWidget::StaticClass();
	}

	OptionsMenuWidget = CreateWidget<UUserWidget>(this, WidgetClass);
	if (!OptionsMenuWidget)
	{
		UE_LOG(LogProjectP1L0T, Error, TEXT("Could not spawn options widget."));
		return;
	}

	OptionsMenuWidget->AddToViewport(1);

	FInputModeUIOnly InputMode;
	InputMode.SetLockMouseToViewportBehavior(EMouseLockMode::DoNotLock);
	InputMode.SetWidgetToFocus(OptionsMenuWidget->TakeWidget());
	SetInputMode(InputMode);
	bShowMouseCursor = true;
	bEnableClickEvents = true;
	bEnableMouseOverEvents = true;
	SetPause(true);
}

void AProjectP1L0TPlayerController::HideOptionsMenu()
{
	if (OptionsMenuWidget)
	{
		OptionsMenuWidget->RemoveFromParent();
		OptionsMenuWidget = nullptr;
	}
}

void AProjectP1L0TPlayerController::ReturnFromOptions()
{
	HideOptionsMenu();

	if (OptionsReturnContext == EMenuContext::Title)
	{
		ShowTitleScreen();
		return;
	}

	if (OptionsReturnContext == EMenuContext::Pause)
	{
		ShowPauseMenu();
		return;
	}

	FInputModeGameOnly InputMode;
	SetInputMode(InputMode);
	bShowMouseCursor = false;
	bEnableClickEvents = false;
	bEnableMouseOverEvents = false;
	SetPause(false);
}

void AProjectP1L0TPlayerController::TogglePauseMenu()
{
	if (TitleScreenWidget)
	{
		HideTitleScreen();
		return;
	}

	if (OptionsMenuWidget)
	{
		ReturnFromOptions();
		return;
	}

	if (PauseMenuWidget)
	{
		HidePauseMenu();
	}
	else
	{
		ShowPauseMenu();
	}
}

void AProjectP1L0TPlayerController::HandleTitlePlay()
{
	HideTitleScreen();
}

void AProjectP1L0TPlayerController::HandleTitleOptions()
{
	ShowOptionsMenu();
}

void AProjectP1L0TPlayerController::HandleTitleExit()
{
	UKismetSystemLibrary::QuitGame(this, this, EQuitPreference::Quit, false);
}

void AProjectP1L0TPlayerController::HandlePauseResume()
{
	HidePauseMenu();
}

void AProjectP1L0TPlayerController::HandlePauseOptions()
{
	ShowOptionsMenu();
}

void AProjectP1L0TPlayerController::HandlePauseExit()
{
	UKismetSystemLibrary::QuitGame(this, this, EQuitPreference::Quit, false);
}

void AProjectP1L0TPlayerController::HandleOptionsBack()
{
	ReturnFromOptions();
}
