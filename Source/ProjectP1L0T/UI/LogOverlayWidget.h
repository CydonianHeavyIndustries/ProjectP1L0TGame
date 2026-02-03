#pragma once

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"
#include "LogOverlayWidget.generated.h"

class UMultiLineEditableTextBox;
class UBorder;

UCLASS()
class PROJECTP1L0T_API ULogOverlayWidget : public UUserWidget
{
	GENERATED_BODY()

public:
	virtual void NativeConstruct() override;

	void SetLogText(const FString& Text);

private:
	UPROPERTY()
	TObjectPtr<UMultiLineEditableTextBox> LogTextBox;
};
