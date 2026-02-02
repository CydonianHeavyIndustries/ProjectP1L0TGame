// Copyright Epic Games, Inc. All Rights Reserved.

#include "ProjectP1L0TGameMode.h"
#include "PilotCharacter.h"

AProjectP1L0TGameMode::AProjectP1L0TGameMode()
{
	DefaultPawnClass = APilotCharacter::StaticClass();
}
