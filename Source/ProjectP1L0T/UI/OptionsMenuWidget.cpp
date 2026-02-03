#include "UI/OptionsMenuWidget.h"
#include "Components/Button.h"
#include "Components/CheckBox.h"
#include "Components/CanvasPanel.h"
#include "Components/CanvasPanelSlot.h"
#include "Components/HorizontalBox.h"
#include "Components/HorizontalBoxSlot.h"
#include "Components/Slider.h"
#include "Components/TextBlock.h"
#include "Components/VerticalBox.h"
#include "Components/VerticalBoxSlot.h"
#include "Blueprint/WidgetTree.h"
#include "GameFramework/PlayerController.h"
#include "ProjectP1L0TPlayerController.h"
#include "ProjectP1L0T.h"

void UOptionsMenuWidget::NativeConstruct()
{
	Super::NativeConstruct();
	BuildLayout();

	if (AProjectP1L0TPlayerController* PC = Cast<AProjectP1L0TPlayerController>(GetOwningPlayer()))
	{
		if (MasterVolumeSlider)
		{
			MasterVolumeSlider->SetValue(PC->GetMasterVolume());
		}
		if (MusicVolumeSlider)
		{
			MusicVolumeSlider->SetValue(PC->GetMusicVolume());
		}
		if (SfxVolumeSlider)
		{
			SfxVolumeSlider->SetValue(PC->GetSfxVolume());
		}
		if (GraphicsQualitySlider)
		{
			GraphicsQualitySlider->SetValue(PC->GetGraphicsQuality());
		}
		if (FullscreenToggle)
		{
			FullscreenToggle->SetIsChecked(PC->IsFullscreenEnabled());
		}
	}
}

void UOptionsMenuWidget::BuildLayout()
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

	BuildSectionTitle(TEXT("Audio"), MenuBox);
	MasterVolumeSlider = BuildSliderRow(TEXT("Master"), MenuBox, 0.8f);
	MusicVolumeSlider = BuildSliderRow(TEXT("Music"), MenuBox, 0.7f);
	SfxVolumeSlider = BuildSliderRow(TEXT("SFX"), MenuBox, 0.85f);

	BuildSectionTitle(TEXT("Visuals"), MenuBox);
	FullscreenToggle = BuildToggleRow(TEXT("Fullscreen"), MenuBox, true);
	GraphicsQualitySlider = BuildSliderRow(TEXT("Graphics: idk lmao"), MenuBox, 0.5f);

	BackButton = BuildButton(TEXT("Back"), MenuBox);

	if (BackButton)
	{
		BackButton->OnClicked.AddDynamic(this, &UOptionsMenuWidget::HandleBackClicked);
	}

	if (MasterVolumeSlider)
	{
		MasterVolumeSlider->OnValueChanged.AddDynamic(this, &UOptionsMenuWidget::HandleMasterChanged);
	}

	if (MusicVolumeSlider)
	{
		MusicVolumeSlider->OnValueChanged.AddDynamic(this, &UOptionsMenuWidget::HandleMusicChanged);
	}

	if (SfxVolumeSlider)
	{
		SfxVolumeSlider->OnValueChanged.AddDynamic(this, &UOptionsMenuWidget::HandleSfxChanged);
	}

	if (GraphicsQualitySlider)
	{
		GraphicsQualitySlider->OnValueChanged.AddDynamic(this, &UOptionsMenuWidget::HandleGraphicsChanged);
	}

	if (FullscreenToggle)
	{
		FullscreenToggle->OnCheckStateChanged.AddDynamic(this, &UOptionsMenuWidget::HandleFullscreenChanged);
	}
}

UTextBlock* UOptionsMenuWidget::BuildSectionTitle(const FString& Label, UVerticalBox* Container)
{
	if (!WidgetTree || !Container)
	{
		return nullptr;
	}

	UTextBlock* Text = WidgetTree->ConstructWidget<UTextBlock>(UTextBlock::StaticClass());
	Text->SetText(FText::FromString(Label));

	UVerticalBoxSlot* TextSlot = Container->AddChildToVerticalBox(Text);
	TextSlot->SetPadding(FMargin(8.f, 16.f, 8.f, 4.f));
	TextSlot->SetHorizontalAlignment(HAlign_Center);

	return Text;
}

USlider* UOptionsMenuWidget::BuildSliderRow(const FString& Label, UVerticalBox* Container, float DefaultValue)
{
	if (!WidgetTree || !Container)
	{
		return nullptr;
	}

	UHorizontalBox* Row = WidgetTree->ConstructWidget<UHorizontalBox>(UHorizontalBox::StaticClass());
	UVerticalBoxSlot* RowSlot = Container->AddChildToVerticalBox(Row);
	RowSlot->SetPadding(FMargin(8.f));
	RowSlot->SetHorizontalAlignment(HAlign_Center);

	UTextBlock* Text = WidgetTree->ConstructWidget<UTextBlock>(UTextBlock::StaticClass());
	Text->SetText(FText::FromString(Label));
	UHorizontalBoxSlot* LabelSlot = Row->AddChildToHorizontalBox(Text);
	LabelSlot->SetPadding(FMargin(0.f, 0.f, 12.f, 0.f));
	LabelSlot->SetHorizontalAlignment(HAlign_Left);

	USlider* Slider = WidgetTree->ConstructWidget<USlider>(USlider::StaticClass());
	Slider->SetValue(DefaultValue);
	UHorizontalBoxSlot* SliderSlot = Row->AddChildToHorizontalBox(Slider);
	SliderSlot->SetPadding(FMargin(0.f));
	SliderSlot->SetHorizontalAlignment(HAlign_Fill);

	return Slider;
}

UCheckBox* UOptionsMenuWidget::BuildToggleRow(const FString& Label, UVerticalBox* Container, bool bDefault)
{
	if (!WidgetTree || !Container)
	{
		return nullptr;
	}

	UHorizontalBox* Row = WidgetTree->ConstructWidget<UHorizontalBox>(UHorizontalBox::StaticClass());
	UVerticalBoxSlot* RowSlot = Container->AddChildToVerticalBox(Row);
	RowSlot->SetPadding(FMargin(8.f));
	RowSlot->SetHorizontalAlignment(HAlign_Center);

	UTextBlock* Text = WidgetTree->ConstructWidget<UTextBlock>(UTextBlock::StaticClass());
	Text->SetText(FText::FromString(Label));
	UHorizontalBoxSlot* LabelSlot = Row->AddChildToHorizontalBox(Text);
	LabelSlot->SetPadding(FMargin(0.f, 0.f, 12.f, 0.f));
	LabelSlot->SetHorizontalAlignment(HAlign_Left);

	UCheckBox* Toggle = WidgetTree->ConstructWidget<UCheckBox>(UCheckBox::StaticClass());
	Toggle->SetIsChecked(bDefault);
	UHorizontalBoxSlot* ToggleSlot = Row->AddChildToHorizontalBox(Toggle);
	ToggleSlot->SetHorizontalAlignment(HAlign_Right);

	return Toggle;
}

UButton* UOptionsMenuWidget::BuildButton(const FString& Label, UVerticalBox* Container)
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
	ButtonSlot->SetPadding(FMargin(12.f, 20.f, 12.f, 0.f));
	ButtonSlot->SetHorizontalAlignment(HAlign_Center);

	return Button;
}

void UOptionsMenuWidget::HandleBackClicked()
{
	if (AProjectP1L0TPlayerController* PC = Cast<AProjectP1L0TPlayerController>(GetOwningPlayer()))
	{
		PC->HandleOptionsBack();
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
		PC->SetPause(false);
	}
}

void UOptionsMenuWidget::HandleMasterChanged(float Value)
{
	if (AProjectP1L0TPlayerController* PC = Cast<AProjectP1L0TPlayerController>(GetOwningPlayer()))
	{
		PC->SetMasterVolume(Value);
	}
}

void UOptionsMenuWidget::HandleMusicChanged(float Value)
{
	if (AProjectP1L0TPlayerController* PC = Cast<AProjectP1L0TPlayerController>(GetOwningPlayer()))
	{
		PC->SetMusicVolume(Value);
	}
}

void UOptionsMenuWidget::HandleSfxChanged(float Value)
{
	if (AProjectP1L0TPlayerController* PC = Cast<AProjectP1L0TPlayerController>(GetOwningPlayer()))
	{
		PC->SetSfxVolume(Value);
	}
}

void UOptionsMenuWidget::HandleGraphicsChanged(float Value)
{
	if (AProjectP1L0TPlayerController* PC = Cast<AProjectP1L0TPlayerController>(GetOwningPlayer()))
	{
		PC->SetGraphicsQuality(Value);
	}
}

void UOptionsMenuWidget::HandleFullscreenChanged(bool bIsChecked)
{
	if (AProjectP1L0TPlayerController* PC = Cast<AProjectP1L0TPlayerController>(GetOwningPlayer()))
	{
		PC->SetFullscreenEnabled(bIsChecked);
	}
}
