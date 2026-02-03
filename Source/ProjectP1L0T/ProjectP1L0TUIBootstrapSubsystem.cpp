#include "ProjectP1L0TUIBootstrapSubsystem.h"
#include "Blueprint/UserWidget.h"
#include "Blueprint/WidgetBlueprintLibrary.h"
#include "Components/InputComponent.h"
#include "GameFramework/PlayerController.h"
#include "Kismet/GameplayStatics.h"
#include "Logging/ProjectP1L0TLogSubsystem.h"
#include "ProjectP1L0T.h"
#include "ProjectP1L0TPlayerController.h"
#include "UI/PauseMenuWidget.h"
#include "UI/TitleScreenWidget.h"

void UProjectP1L0TUIBootstrapSubsystem::Initialize(FSubsystemCollectionBase& Collection)
{
	Super::Initialize(Collection);

	UE_LOG(LogProjectP1L0T, Display, TEXT("UIBootstrapSubsystem Initialize"));
	FCoreUObjectDelegates::PostLoadMapWithWorld.AddUObject(this, &UProjectP1L0TUIBootstrapSubsystem::HandlePostLoadMap);
}

void UProjectP1L0TUIBootstrapSubsystem::Deinitialize()
{
	FCoreUObjectDelegates::PostLoadMapWithWorld.RemoveAll(this);
	Super::Deinitialize();
}

void UProjectP1L0TUIBootstrapSubsystem::HandlePostLoadMap(UWorld* World)
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

	EnsureLogInput(PC);

	if (Cast<AProjectP1L0TPlayerController>(PC))
	{
		UE_LOG(LogProjectP1L0T, Display, TEXT("UIBootstrapSubsystem: Custom PlayerController detected, skipping fallback."));
		return;
	}

	FallbackPlayerController = PC;
	EnsureFallbackInput(PC);

	TArray<UUserWidget*> Existing;
	UWidgetBlueprintLibrary::GetAllWidgetsOfClass(World, Existing, UTitleScreenWidget::StaticClass(), false);
	if (Existing.Num() > 0)
	{
		TitleScreenWidget = Existing[0];
		return;
	}

	UUserWidget* Widget = CreateWidget<UUserWidget>(PC, UTitleScreenWidget::StaticClass());
	if (!Widget)
	{
		UE_LOG(LogProjectP1L0T, Warning, TEXT("UIBootstrapSubsystem: Failed to create TitleScreenWidget."));
		return;
	}

	Widget->AddToViewport(0);
	TitleScreenWidget = Widget;

	FInputModeUIOnly InputMode;
	InputMode.SetLockMouseToViewportBehavior(EMouseLockMode::DoNotLock);
	InputMode.SetWidgetToFocus(Widget->TakeWidget());
	PC->SetInputMode(InputMode);
	PC->bShowMouseCursor = true;
	PC->bEnableClickEvents = true;
	PC->bEnableMouseOverEvents = true;
	PC->SetIgnoreMoveInput(true);
	PC->SetIgnoreLookInput(true);

	UE_LOG(LogProjectP1L0T, Display, TEXT("UIBootstrapSubsystem: Title screen displayed."));
}

void UProjectP1L0TUIBootstrapSubsystem::EnsureFallbackInput(APlayerController* PC)
{
	if (!PC || FallbackInputComponent)
	{
		return;
	}

	FallbackInputComponent = NewObject<UInputComponent>(PC, TEXT("ProjectP1L0TFallbackMenuInput"));
	if (!FallbackInputComponent)
	{
		return;
	}

	FallbackInputComponent->RegisterComponent();
	FallbackInputComponent->bBlockInput = false;
	FallbackInputComponent->Priority = 1;
	FInputActionBinding& MenuBinding = FallbackInputComponent->BindAction("Menu", IE_Pressed, this, &UProjectP1L0TUIBootstrapSubsystem::HandleFallbackMenuPressed);
	MenuBinding.bExecuteWhenPaused = true;
	PC->PushInputComponent(FallbackInputComponent);
}

void UProjectP1L0TUIBootstrapSubsystem::EnsureLogInput(APlayerController* PC)
{
	if (!PC || LogInputComponent)
	{
		return;
	}

	LogInputComponent = NewObject<UInputComponent>(PC, TEXT("ProjectP1L0TLogInput"));
	if (!LogInputComponent)
	{
		return;
	}

	LogInputComponent->RegisterComponent();
	LogInputComponent->bBlockInput = false;
	LogInputComponent->Priority = 0;
	FInputKeyBinding& LogBinding = LogInputComponent->BindKey(EKeys::F9, IE_Pressed, this, &UProjectP1L0TUIBootstrapSubsystem::HandleLogTogglePressed);
	LogBinding.bExecuteWhenPaused = true;
	PC->PushInputComponent(LogInputComponent);
}

void UProjectP1L0TUIBootstrapSubsystem::HandleFallbackMenuPressed()
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

void UProjectP1L0TUIBootstrapSubsystem::HandleLogTogglePressed()
{
	if (UProjectP1L0TLogSubsystem* LogSubsystem = GetGameInstance()->GetSubsystem<UProjectP1L0TLogSubsystem>())
	{
		LogSubsystem->ToggleOverlay();
	}
}

void UProjectP1L0TUIBootstrapSubsystem::ShowFallbackPauseMenu(APlayerController* PC)
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

void UProjectP1L0TUIBootstrapSubsystem::HideFallbackPauseMenu(APlayerController* PC)
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
	PC->SetIgnoreMoveInput(false);
	PC->SetIgnoreLookInput(false);
	PC->SetPause(false);
}
