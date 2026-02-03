#include "ProjectP1L0TGameInstance.h"
#include "Blueprint/UserWidget.h"
#include "Components/InputComponent.h"
#include "GameFramework/PlayerController.h"
#include "Kismet/GameplayStatics.h"
#include "ProjectP1L0TPlayerController.h"
#include "UI/PauseMenuWidget.h"
#include "UI/TitleScreenWidget.h"

void UProjectP1L0TGameInstance::Init()
{
	Super::Init();

	FCoreUObjectDelegates::PostLoadMapWithWorld.AddUObject(this, &UProjectP1L0TGameInstance::HandlePostLoadMap);
}

void UProjectP1L0TGameInstance::HandlePostLoadMap(UWorld* World)
{
	if (!World)
	{
		return;
	}

	APlayerController* PC = UGameplayStatics::GetPlayerController(World, 0);
	if (!PC)
	{
		return;
	}

	if (Cast<AProjectP1L0TPlayerController>(PC))
	{
		return;
	}

	FallbackPlayerController = PC;
	EnsureFallbackInput(PC);

	if (TitleScreenWidget && TitleScreenWidget->IsInViewport())
	{
		return;
	}

	UUserWidget* Widget = CreateWidget<UUserWidget>(PC, UTitleScreenWidget::StaticClass());
	if (!Widget)
	{
		return;
	}

	Widget->AddToViewport(0);
	TitleScreenWidget = Widget;

	FInputModeGameAndUI InputMode;
	InputMode.SetLockMouseToViewportBehavior(EMouseLockMode::DoNotLock);
	InputMode.SetWidgetToFocus(Widget->TakeWidget());
	PC->SetInputMode(InputMode);
	PC->bShowMouseCursor = true;
	PC->bEnableClickEvents = true;
	PC->bEnableMouseOverEvents = true;
	PC->SetPause(true);
}

void UProjectP1L0TGameInstance::EnsureFallbackInput(APlayerController* PC)
{
	if (!PC || FallbackInputComponent)
	{
		return;
	}

	FallbackInputComponent = NewObject<UInputComponent>(PC, TEXT("ProjectP1L0TMenuInput"));
	if (!FallbackInputComponent)
	{
		return;
	}

	FallbackInputComponent->RegisterComponent();
	FallbackInputComponent->bBlockInput = false;
	FallbackInputComponent->Priority = 1;
	FallbackInputComponent->BindAction("Menu", IE_Pressed, this, &UProjectP1L0TGameInstance::HandleFallbackMenuPressed);
	PC->PushInputComponent(FallbackInputComponent);
}

void UProjectP1L0TGameInstance::HandleFallbackMenuPressed()
{
	APlayerController* PC = FallbackPlayerController.Get();
	if (!PC)
	{
		return;
	}

	if (TitleScreenWidget && TitleScreenWidget->IsInViewport())
	{
		TitleScreenWidget->RemoveFromParent();
		TitleScreenWidget = nullptr;
		HideFallbackPauseMenu(PC);
		return;
	}

	if (PauseMenuWidget && PauseMenuWidget->IsInViewport())
	{
		HideFallbackPauseMenu(PC);
		return;
	}

	ShowFallbackPauseMenu(PC);
}

void UProjectP1L0TGameInstance::ShowFallbackPauseMenu(APlayerController* PC)
{
	if (!PC)
	{
		return;
	}

	if (!PauseMenuWidget)
	{
		PauseMenuWidget = CreateWidget<UUserWidget>(PC, UPauseMenuWidget::StaticClass());
	}

	if (!PauseMenuWidget)
	{
		return;
	}

	PauseMenuWidget->AddToViewport(1);
	FInputModeGameAndUI InputMode;
	InputMode.SetLockMouseToViewportBehavior(EMouseLockMode::DoNotLock);
	InputMode.SetWidgetToFocus(PauseMenuWidget->TakeWidget());
	PC->SetInputMode(InputMode);
	PC->bShowMouseCursor = true;
	PC->bEnableClickEvents = true;
	PC->bEnableMouseOverEvents = true;
	PC->SetPause(true);
}

void UProjectP1L0TGameInstance::HideFallbackPauseMenu(APlayerController* PC)
{
	if (!PC)
	{
		return;
	}

	if (PauseMenuWidget && PauseMenuWidget->IsInViewport())
	{
		PauseMenuWidget->RemoveFromParent();
	}

	FInputModeGameOnly InputMode;
	PC->SetInputMode(InputMode);
	PC->bShowMouseCursor = false;
	PC->bEnableClickEvents = false;
	PC->bEnableMouseOverEvents = false;
	PC->SetPause(false);
}
