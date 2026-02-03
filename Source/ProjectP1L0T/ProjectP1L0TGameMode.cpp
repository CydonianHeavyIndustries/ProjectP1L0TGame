// Copyright Epic Games, Inc. All Rights Reserved.

#include "ProjectP1L0TGameMode.h"
#include "PilotCharacter.h"
#include "ProjectP1L0TPlayerController.h"

AProjectP1L0TGameMode::AProjectP1L0TGameMode()
{
	DefaultPawnClass = APilotCharacter::StaticClass();
	PlayerControllerClass = AProjectP1L0TPlayerController::StaticClass();
}

void AProjectP1L0TGameMode::InitGame(const FString& MapName, const FString& Options, FString& ErrorMessage)
{
	Super::InitGame(MapName, Options, ErrorMessage);

	DefaultPawnClass = APilotCharacter::StaticClass();
	PlayerControllerClass = AProjectP1L0TPlayerController::StaticClass();
}
