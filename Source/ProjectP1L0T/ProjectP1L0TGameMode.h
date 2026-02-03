#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "ProjectP1L0TGameMode.generated.h"

UCLASS()
class PROJECTP1L0T_API AProjectP1L0TGameMode : public AGameModeBase
{
	GENERATED_BODY()

public:
	AProjectP1L0TGameMode();

	virtual void InitGame(const FString& MapName, const FString& Options, FString& ErrorMessage) override;
};
