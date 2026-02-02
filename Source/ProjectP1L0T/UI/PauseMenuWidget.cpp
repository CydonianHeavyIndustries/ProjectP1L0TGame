#include "UI/PauseMenuWidget.h"
#include "Components/Button.h"
#include "Components/CanvasPanel.h"
#include "Components/CanvasPanelSlot.h"
#include "Components/TextBlock.h"
#include "Components/VerticalBox.h"
#include "Components/VerticalBoxSlot.h"
#include "Blueprint/WidgetTree.h"
#include "ProjectP1L0TPlayerController.h"

void UPauseMenuWidget::NativeConstruct()
{
	Super::NativeConstruct();
	BuildLayout();
}

void UPauseMenuWidget::BuildLayout()
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

	ResumeButton = BuildButton(TEXT("Resume"), MenuBox);
	OptionsButton = BuildButton(TEXT("Options"), MenuBox);
	ExitButton = BuildButton(TEXT("Exit"), MenuBox);

	if (ResumeButton)
	{
		ResumeButton->OnClicked.AddDynamic(this, &UPauseMenuWidget::HandleResumeClicked);
	}

	if (OptionsButton)
	{
		OptionsButton->OnClicked.AddDynamic(this, &UPauseMenuWidget::HandleOptionsClicked);
	}

	if (ExitButton)
	{
		ExitButton->OnClicked.AddDynamic(this, &UPauseMenuWidget::HandleExitClicked);
	}
}

UButton* UPauseMenuWidget::BuildButton(const FString& Label, UVerticalBox* Container)
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

void UPauseMenuWidget::HandleResumeClicked()
{
	if (AProjectP1L0TPlayerController* PC = Cast<AProjectP1L0TPlayerController>(GetOwningPlayer()))
	{
		PC->HandlePauseResume();
	}
}

void UPauseMenuWidget::HandleOptionsClicked()
{
	if (AProjectP1L0TPlayerController* PC = Cast<AProjectP1L0TPlayerController>(GetOwningPlayer()))
	{
		PC->HandlePauseOptions();
	}
}

void UPauseMenuWidget::HandleExitClicked()
{
	if (AProjectP1L0TPlayerController* PC = Cast<AProjectP1L0TPlayerController>(GetOwningPlayer()))
	{
		PC->HandlePauseExit();
	}
}
