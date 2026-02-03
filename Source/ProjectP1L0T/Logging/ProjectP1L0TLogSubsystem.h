#pragma once

#include "CoreMinimal.h"
#include "Subsystems/GameInstanceSubsystem.h"
#include "ProjectP1L0TLogSubsystem.generated.h"

class ULogOverlayWidget;
class UUserWidget;

UCLASS()
class PROJECTP1L0T_API UProjectP1L0TLogSubsystem : public UGameInstanceSubsystem
{
	GENERATED_BODY()

public:
	virtual void Initialize(FSubsystemCollectionBase& Collection) override;
	virtual void Deinitialize() override;

	void ToggleOverlay();

private:
	void HandleLogLine(const FString& Line);
	void RefreshOverlayText();

	FCriticalSection LinesMutex;
	TArray<FString> Lines;
	int32 MaxLines = 200;

	TWeakObjectPtr<ULogOverlayWidget> OverlayWidget;
	bool bOverlayVisible = false;

	class FProjectP1L0TLogDevice* LogDevice = nullptr;
};
