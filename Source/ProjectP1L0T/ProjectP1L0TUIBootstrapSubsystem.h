#pragma once

#include "CoreMinimal.h"
#include "Subsystems/GameInstanceSubsystem.h"
#include "ProjectP1L0TUIBootstrapSubsystem.generated.h"

class UUserWidget;
class UInputComponent;
class APlayerController;
class UWorld;

UCLASS()
class PROJECTP1L0T_API UProjectP1L0TUIBootstrapSubsystem : public UGameInstanceSubsystem
{
	GENERATED_BODY()

public:
	virtual void Initialize(FSubsystemCollectionBase& Collection) override;
	virtual void Deinitialize() override;

private:
	void HandlePostLoadMap(UWorld* World);
	void EnsureFallbackInput(APlayerController* PC);
	void HandleFallbackMenuPressed();
	void ShowFallbackPauseMenu(APlayerController* PC);
	void HideFallbackPauseMenu(APlayerController* PC);

	UPROPERTY()
	TObjectPtr<UUserWidget> TitleScreenWidget;

	UPROPERTY()
	TObjectPtr<UUserWidget> PauseMenuWidget;

	UPROPERTY()
	TObjectPtr<UInputComponent> FallbackInputComponent;

	TWeakObjectPtr<APlayerController> FallbackPlayerController;
};
