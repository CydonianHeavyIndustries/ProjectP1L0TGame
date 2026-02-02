#pragma once

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"
#include "TitleScreenWidget.generated.h"

class UButton;
class UVerticalBox;

UCLASS()
class PROJECTP1L0T_API UTitleScreenWidget : public UUserWidget
{
	GENERATED_BODY()

protected:
	virtual void NativeConstruct() override;

private:
	UPROPERTY()
	TObjectPtr<UButton> PlayButton;

	UPROPERTY()
	TObjectPtr<UButton> OptionsButton;

	UPROPERTY()
	TObjectPtr<UButton> ExitButton;

	void BuildLayout();
	UButton* BuildButton(const FString& Label, UVerticalBox* Container);

	UFUNCTION()
	void HandlePlayClicked();

	UFUNCTION()
	void HandleOptionsClicked();

	UFUNCTION()
	void HandleExitClicked();
};
