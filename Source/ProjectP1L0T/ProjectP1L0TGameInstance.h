#pragma once

#include "CoreMinimal.h"
#include "Engine/GameInstance.h"
#include "ProjectP1L0TGameInstance.generated.h"

class UUserWidget;
class UInputComponent;
class APlayerController;

UCLASS()
class PROJECTP1L0T_API UProjectP1L0TGameInstance : public UGameInstance
{
	GENERATED_BODY()

public:
	virtual void Init() override;

private:
	void HandlePostLoadMap(UWorld* World);
	void HandleFallbackMenuPressed();
	void EnsureFallbackInput(APlayerController* PC);
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
