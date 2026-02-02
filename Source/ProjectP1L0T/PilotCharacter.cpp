#include "PilotCharacter.h"
#include "PilotMovementComponent.h"

APilotCharacter::APilotCharacter(const FObjectInitializer& ObjectInitializer)
	: Super(ObjectInitializer.SetDefaultSubobjectClass<UPilotMovementComponent>(ACharacter::CharacterMovementComponentName))
{
	PrimaryActorTick.bCanEverTick = true;
}

void APilotCharacter::Tick(float DeltaSeconds)
{
	Super::Tick(DeltaSeconds);

	// Auto-enter slide when conditions are met
	UPilotMovementComponent* Move = Cast<UPilotMovementComponent>(GetCharacterMovement());
	if (!Move) return;

	// Try to enter slide if we're not already in a custom mode
	if (Move->MovementMode != MOVE_Custom)
	{
		Move->TryEnterSlide();
		Move->TryEnterWallRun();
	}
}
