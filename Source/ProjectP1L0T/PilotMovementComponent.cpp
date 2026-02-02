#include "PilotMovementComponent.h"
#include "GameFramework/Character.h"
#include "Components/CapsuleComponent.h"
#include "DrawDebugHelpers.h"

float UPilotMovementComponent::GetMaxSpeed() const
{
	float Speed = Super::GetMaxSpeed();

	// Sprint only on ground (TF2 feel)
	if (bWantsSprint && IsMovingOnGround())
	{
		Speed = SprintSpeed;
	}

	return Speed;
}

void UPilotMovementComponent::PhysCustom(float DeltaTime, int32 Iterations)
{
	switch ((EPilotCustomMode)CustomMovementMode)
	{
	case EPilotCustomMode::Slide:
		PhysSlide(DeltaTime, Iterations);
		return;
	case EPilotCustomMode::WallRun:
		PhysWallRun(DeltaTime, Iterations);
		return;
	default:
		break;
	}

	Super::PhysCustom(DeltaTime, Iterations);
}

bool UPilotMovementComponent::TryEnterSlide()
{
	if (!IsMovingOnGround()) return false;
	if (!bWantsSlide) return false;

	const float Speed2D = Velocity.Size2D();
	if (Speed2D < SlideEnterSpeed) return false;

	// Enter custom slide
	SetMovementMode(MOVE_Custom, (uint8)EPilotCustomMode::Slide);
	return true;
}

void UPilotMovementComponent::ExitCustomMode()
{
	SetMovementMode(MOVE_Walking);
}

void UPilotMovementComponent::PhysSlide(float DeltaTime, int32 Iterations)
{
	// If slide intent released, or too slow, exit
	const float Speed2D = Velocity.Size2D();
	if (!bWantsSlide || Speed2D < SlideMinSpeed || !IsMovingOnGround())
	{
		ExitCustomMode();
		return;
	}

	// Lower friction style slide: dampen horizontal velocity slightly
	const float Drag = FMath::Clamp(SlideFriction, 0.f, 1.f);
	Velocity.X *= FMath::Pow(1.f - Drag, DeltaTime * 60.f);
	Velocity.Y *= FMath::Pow(1.f - Drag, DeltaTime * 60.f);

	// Let base walking solver handle ground interaction
	PhysWalking(DeltaTime, Iterations);
}

bool UPilotMovementComponent::TraceWall(FHitResult& OutHit, float SideSign) const
{
	const ACharacter* Char = CharacterOwner;
	if (!Char) return false;

	const UCapsuleComponent* Cap = Char->GetCapsuleComponent();
	if (!Cap) return false;

	const FVector Start = Char->GetActorLocation();
	const FVector Right = Char->GetActorRightVector() * SideSign;

	const float Radius = Cap->GetScaledCapsuleRadius();
	const FVector End = Start + Right * (Radius + WallTraceDistance);

	FCollisionQueryParams Params(SCENE_QUERY_STAT(PilotWallTrace), false, Char);
	return GetWorld()->LineTraceSingleByChannel(OutHit, Start, End, ECC_Visibility, Params);
}

bool UPilotMovementComponent::TryEnterWallRun()
{
	if (IsMovingOnGround()) return false;
	if (Velocity.Size2D() < WallRunMinSpeed) return false;

	FHitResult HitL, HitR;
	const bool bHitL = TraceWall(HitL, -1.f);
	const bool bHitR = TraceWall(HitR, +1.f);

	const FHitResult* UseHit = nullptr;
	if (bHitL) UseHit = &HitL;
	if (bHitR && (!UseHit || HitR.Distance < UseHit->Distance)) UseHit = &HitR;

	if (!UseHit) return false;

	// reject floors/ceilings
	if (FMath::Abs(UseHit->Normal.Z) > 0.2f) return false;

	SetMovementMode(MOVE_Custom, (uint8)EPilotCustomMode::WallRun);
	return true;
}

void UPilotMovementComponent::PhysWallRun(float DeltaTime, int32 Iterations)
{
	// If we lose the wall or slow down, fall
	if (Velocity.Size2D() < WallRunMinSpeed)
	{
		SetMovementMode(MOVE_Falling);
		return;
	}

	// Check wall each tick
	FHitResult HitL, HitR;
	const bool bHitL = TraceWall(HitL, -1.f);
	const bool bHitR = TraceWall(HitR, +1.f);

	const FHitResult* UseHit = nullptr;
	if (bHitL) UseHit = &HitL;
	if (bHitR && (!UseHit || HitR.Distance < UseHit->Distance)) UseHit = &HitR;

	if (!UseHit || FMath::Abs(UseHit->Normal.Z) > 0.2f)
	{
		SetMovementMode(MOVE_Falling);
		return;
	}

	// Wall tangent direction (run along wall)
	const FVector WallNormal = UseHit->Normal.GetSafeNormal();
	const FVector Up = FVector::UpVector;
	FVector WallTangent = FVector::CrossProduct(Up, WallNormal).GetSafeNormal();

	// Choose tangent that matches current velocity direction
	if (FVector::DotProduct(WallTangent, Velocity) < 0.f)
	{
		WallTangent *= -1.f;
	}

	// Apply reduced gravity
	const float SavedGrav = GravityScale;
	GravityScale = WallRunGravityScale;

	// Force velocity to stay aligned mostly with wall tangent (TF2-ish)
	const float Speed = Velocity.Size2D();
	Velocity = WallTangent * Speed + FVector(0,0, Velocity.Z);

	// Slightly pull into wall to keep contact
	Velocity += (-WallNormal * 50.f) * DeltaTime;

	PhysFalling(DeltaTime, Iterations);

	GravityScale = SavedGrav;
}
