#pragma once

#include "CoreMinimal.h"
#include "GameFramework/PlayerController.h"
#include "ProjectP1L0TPlayerController.generated.h"

class UInputMappingContext;
class UUserWidget;
class USoundClass;
class USoundMix;

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

	void HandlePauseResume();
	void HandlePauseOptions();
	void HandlePauseExit();

	void HandleOptionsBack();

	void SetMasterVolume(float Value);
	void SetMusicVolume(float Value);
	void SetSfxVolume(float Value);
	void SetGraphicsQuality(float Value);
	void SetFullscreenEnabled(bool bEnabled);

	float GetMasterVolume() const { return MasterVolume; }
	float GetMusicVolume() const { return MusicVolume; }
	float GetSfxVolume() const { return SfxVolume; }
	float GetGraphicsQuality() const { return GraphicsQuality; }
	bool IsFullscreenEnabled() const { return bFullscreenEnabled; }

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

	/** Pause menu widget to spawn */
	UPROPERTY(EditAnywhere, Category="UI")
	TSubclassOf<UUserWidget> PauseMenuWidgetClass;

	/** Pointer to the pause menu widget */
	UPROPERTY()
	TObjectPtr<UUserWidget> PauseMenuWidget;

	/** Options widget to spawn */
	UPROPERTY(EditAnywhere, Category="UI")
	TSubclassOf<UUserWidget> OptionsMenuWidgetClass;

	/** Pointer to the options widget */
	UPROPERTY()
	TObjectPtr<UUserWidget> OptionsMenuWidget;

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
	enum class EMenuContext : uint8
	{
		None,
		Title,
		Pause
	};

	EMenuContext ActiveMenuContext = EMenuContext::None;
	EMenuContext OptionsReturnContext = EMenuContext::None;

	UPROPERTY()
	TObjectPtr<USoundMix> OptionsSoundMix;

	UPROPERTY()
	TObjectPtr<USoundClass> MasterSoundClass;

	UPROPERTY()
	TObjectPtr<USoundClass> MusicSoundClass;

	UPROPERTY()
	TObjectPtr<USoundClass> SfxSoundClass;

	float MasterVolume = 0.8f;
	float MusicVolume = 0.7f;
	float SfxVolume = 0.85f;
	float GraphicsQuality = 0.5f;
	bool bFullscreenEnabled = true;

	void LoadAudioSettings();
	void SaveAudioSettings() const;
	void InitializeAudioMix();
	void ApplySoundMix();
	void SyncGraphicsSettings();

	void ShowTitleScreen();
	void HideTitleScreen();
	void ShowPauseMenu();
	void HidePauseMenu();
	void TogglePauseMenu();
	void ShowOptionsMenu();
	void HideOptionsMenu();
	void ReturnFromOptions();
	void RemoveTitleScreenWidget();
	void RemovePauseMenuWidget();
};
