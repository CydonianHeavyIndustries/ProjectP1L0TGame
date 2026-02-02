#pragma once

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"
#include "PauseMenuWidget.generated.h"

class UButton;
class UVerticalBox;

UCLASS()
class PROJECTP1L0T_API UPauseMenuWidget : public UUserWidget
{
	GENERATED_BODY()

protected:
	virtual void NativeConstruct() override;

private:
	UPROPERTY()
	TObjectPtr<UButton> ResumeButton;

	UPROPERTY()
	TObjectPtr<UButton> OptionsButton;

	UPROPERTY()
	TObjectPtr<UButton> ExitButton;

	void BuildLayout();
	UButton* BuildButton(const FString& Label, UVerticalBox* Container);

	UFUNCTION()
	void HandleResumeClicked();

	UFUNCTION()
	void HandleOptionsClicked();

	UFUNCTION()
	void HandleExitClicked();
};
