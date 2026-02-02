#pragma once

#include "CoreMinimal.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "PilotMovementComponent.generated.h"

UENUM(BlueprintType)
enum class EPilotCustomMode : uint8
{
	None    UMETA(DisplayName="None"),
	Slide   UMETA(DisplayName="Slide"),
	WallRun UMETA(DisplayName="WallRun")
};

UCLASS()
class PROJECTP1LOT_API UPilotMovementComponent : public UCharacterMovementComponent
{
	GENERATED_BODY()

public:
	// Intent flags (set by input; replicated via SavedMove prediction)
	uint8 bWantsSprint : 1;
	uint8 bWantsSlide  : 1;

	// --- Tunables (start TF2-ish) ---
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pilot|Sprint")
	float SprintSpeed = 1150.f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pilot|Slide")
	float SlideEnterSpeed = 700.f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pilot|Slide")
	float SlideMinSpeed = 450.f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pilot|Slide")
	float SlideFriction = 0.15f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pilot|WallRun")
	float WallRunMinSpeed = 650.f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pilot|WallRun")
	float WallRunGravityScale = 0.35f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pilot|WallRun")
	float WallTraceDistance = 90.f;

public:
	virtual float GetMaxSpeed() const override;
	virtual void PhysCustom(float DeltaTime, int32 Iterations) override;

	// Called by Character input
	UFUNCTION(BlueprintCallable, Category="Pilot|Input")
	void SetWantsSprint(bool bNew) { bWantsSprint = bNew; }

	UFUNCTION(BlueprintCallable, Category="Pilot|Input")
	void SetWantsSlide(bool bNew) { bWantsSlide = bNew; }

protected:
	void PhysSlide(float DeltaTime, int32 Iterations);
	void PhysWallRun(float DeltaTime, int32 Iterations);

	bool TryEnterSlide();
	bool TryEnterWallRun();

	void ExitCustomMode();

	bool TraceWall(FHitResult& OutHit, float SideSign) const; // SideSign: -1 left, +1 right
};
