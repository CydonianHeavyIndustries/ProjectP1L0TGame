#include "UI/TitleScreenWidget.h"
#include "Components/Button.h"
#include "Components/CanvasPanel.h"
#include "Components/CanvasPanelSlot.h"
#include "Components/TextBlock.h"
#include "Components/VerticalBox.h"
#include "Components/VerticalBoxSlot.h"
#include "Blueprint/WidgetTree.h"
#include "GameFramework/PlayerController.h"
#include "ProjectP1L0TPlayerController.h"

void UTitleScreenWidget::NativeConstruct()
{
	Super::NativeConstruct();
	BuildLayout();
}

void UTitleScreenWidget::BuildLayout()
{
	if (!WidgetTree)
	{
		return;
	}

	UCanvasPanel* Root = WidgetTree->ConstructWidget<UCanvasPanel>(UCanvasPanel::StaticClass());
	WidgetTree->RootWidget = Root;

	UVerticalBox* MenuBox = WidgetTree->ConstructWidget<UVerticalBox>(UVerticalBox::StaticClass());
	UCanvasPanelSlot* BoxSlot = Root->AddChildToCanvas(MenuBox);
	BoxSlot->SetAnchors(FAnchors(0.5f, 0.5f));
	BoxSlot->SetAlignment(FVector2D(0.5f, 0.5f));
	BoxSlot->SetAutoSize(true);

	PlayButton = BuildButton(TEXT("Play"), MenuBox);
	OptionsButton = BuildButton(TEXT("Options"), MenuBox);
	ExitButton = BuildButton(TEXT("Exit"), MenuBox);

	if (PlayButton)
	{
		PlayButton->OnClicked.AddDynamic(this, &UTitleScreenWidget::HandlePlayClicked);
	}

	if (OptionsButton)
	{
		OptionsButton->OnClicked.AddDynamic(this, &UTitleScreenWidget::HandleOptionsClicked);
	}

	if (ExitButton)
	{
		ExitButton->OnClicked.AddDynamic(this, &UTitleScreenWidget::HandleExitClicked);
	}
}

UButton* UTitleScreenWidget::BuildButton(const FString& Label, UVerticalBox* Container)
{
	if (!WidgetTree || !Container)
	{
		return nullptr;
	}

	UButton* Button = WidgetTree->ConstructWidget<UButton>(UButton::StaticClass());
	UTextBlock* Text = WidgetTree->ConstructWidget<UTextBlock>(UTextBlock::StaticClass());
	Text->SetText(FText::FromString(Label));
	Text->SetJustification(ETextJustify::Center);
	
	Button->AddChild(Text);
	UVerticalBoxSlot* ButtonSlot = Container->AddChildToVerticalBox(Button);
	ButtonSlot->SetPadding(FMargin(8.f));
	ButtonSlot->SetHorizontalAlignment(HAlign_Center);

	return Button;
}

void UTitleScreenWidget::HandlePlayClicked()
{
	if (AProjectP1L0TPlayerController* PC = Cast<AProjectP1L0TPlayerController>(GetOwningPlayer()))
	{
		PC->HandleTitlePlay();
		return;
	}

	if (APlayerController* PC = GetOwningPlayer())
	{
		RemoveFromParent();
		FInputModeGameOnly InputMode;
		PC->SetInputMode(InputMode);
		PC->bShowMouseCursor = false;
		PC->bEnableClickEvents = false;
		PC->bEnableMouseOverEvents = false;
		PC->SetIgnoreMoveInput(false);
		PC->SetIgnoreLookInput(false);
		PC->SetPause(false);
	}
}

void UTitleScreenWidget::HandleOptionsClicked()
{
	if (AProjectP1L0TPlayerController* PC = Cast<AProjectP1L0TPlayerController>(GetOwningPlayer()))
	{
		PC->HandleTitleOptions();
	}
}

void UTitleScreenWidget::HandleExitClicked()
{
	if (AProjectP1L0TPlayerController* PC = Cast<AProjectP1L0TPlayerController>(GetOwningPlayer()))
	{
		PC->HandleTitleExit();
	}
}
