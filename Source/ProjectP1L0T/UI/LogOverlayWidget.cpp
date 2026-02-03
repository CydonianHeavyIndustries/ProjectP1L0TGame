#include "UI/LogOverlayWidget.h"
#include "Components/Border.h"
#include "Components/MultiLineEditableTextBox.h"
#include "Blueprint/WidgetTree.h"

void ULogOverlayWidget::NativeConstruct()
{
	Super::NativeConstruct();

	if (!WidgetTree)
	{
		return;
	}

	UBorder* Root = WidgetTree->ConstructWidget<UBorder>(UBorder::StaticClass(), TEXT("LogBorder"));
	Root->SetPadding(FMargin(8.f));
	Root->SetBrushColor(FLinearColor(0.f, 0.f, 0.f, 0.65f));

	LogTextBox = WidgetTree->ConstructWidget<UMultiLineEditableTextBox>(UMultiLineEditableTextBox::StaticClass(), TEXT("LogText"));
	LogTextBox->SetIsReadOnly(true);
	LogTextBox->SetText(FText::FromString(TEXT("Log overlay active...")));
	LogTextBox->SetAutoWrapText(true);

	Root->SetContent(LogTextBox);
	WidgetTree->RootWidget = Root;
}

void ULogOverlayWidget::SetLogText(const FString& Text)
{
	if (!LogTextBox)
	{
		return;
	}

	LogTextBox->SetText(FText::FromString(Text));
}
