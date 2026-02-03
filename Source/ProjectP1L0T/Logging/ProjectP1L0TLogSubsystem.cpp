#include "Logging/ProjectP1L0TLogSubsystem.h"
#include "Async/Async.h"
#include "Blueprint/UserWidget.h"
#include "Kismet/GameplayStatics.h"
#include "ProjectP1L0T.h"
#include "UI/LogOverlayWidget.h"

class FProjectP1L0TLogDevice final : public FOutputDevice
{
public:
	explicit FProjectP1L0TLogDevice(UProjectP1L0TLogSubsystem* InOwner)
		: Owner(InOwner)
	{
	}

	virtual void Serialize(const TCHAR* V, ELogVerbosity::Type Verbosity, const FName& Category) override
	{
		if (!Owner)
		{
			return;
		}

		const FString TimeStamp = FDateTime::Now().ToString(TEXT("%H:%M:%S"));
		const FString Line = FString::Printf(TEXT("[%s] [%s] %s"), *TimeStamp, *Category.ToString(), V);
		Owner->HandleLogLine(Line);
	}

private:
	UProjectP1L0TLogSubsystem* Owner = nullptr;
};

void UProjectP1L0TLogSubsystem::Initialize(FSubsystemCollectionBase& Collection)
{
	Super::Initialize(Collection);

	LogDevice = new FProjectP1L0TLogDevice(this);
	if (GLog)
	{
		GLog->AddOutputDevice(LogDevice);
	}

	UE_LOG(LogProjectP1L0T, Display, TEXT("LogSubsystem initialized."));
}

void UProjectP1L0TLogSubsystem::Deinitialize()
{
	if (GLog && LogDevice)
	{
		GLog->RemoveOutputDevice(LogDevice);
	}

	delete LogDevice;
	LogDevice = nullptr;

	Super::Deinitialize();
}

void UProjectP1L0TLogSubsystem::ToggleOverlay()
{
	UWorld* World = GetWorld();
	if (!World)
	{
		return;
	}

	APlayerController* PC = UGameplayStatics::GetPlayerController(World, 0);
	if (!PC)
	{
		return;
	}

	if (bOverlayVisible && OverlayWidget.IsValid())
	{
		OverlayWidget->RemoveFromParent();
		OverlayWidget.Reset();
		bOverlayVisible = false;
		return;
	}

	ULogOverlayWidget* Widget = CreateWidget<ULogOverlayWidget>(PC, ULogOverlayWidget::StaticClass());
	if (!Widget)
	{
		return;
	}

	Widget->AddToViewport(5);
	OverlayWidget = Widget;
	bOverlayVisible = true;

	RefreshOverlayText();
}

void UProjectP1L0TLogSubsystem::HandleLogLine(const FString& Line)
{
	{
		FScopeLock Lock(&LinesMutex);
		Lines.Add(Line);
		if (Lines.Num() > MaxLines)
		{
			Lines.RemoveAt(0, Lines.Num() - MaxLines);
		}
	}

	AsyncTask(ENamedThreads::GameThread, [this]()
	{
		RefreshOverlayText();
	});
}

void UProjectP1L0TLogSubsystem::RefreshOverlayText()
{
	if (!OverlayWidget.IsValid())
	{
		return;
	}

	FString Combined;
	{
		FScopeLock Lock(&LinesMutex);
		Combined = FString::Join(Lines, TEXT("\n"));
	}

	OverlayWidget->SetLogText(Combined);
}
