#pragma once

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"
#include "OptionsMenuWidget.generated.h"

class UButton;
class UCheckBox;
class UHorizontalBox;
class USlider;
class UTextBlock;
class UVerticalBox;

UCLASS()
class PROJECTP1L0T_API UOptionsMenuWidget : public UUserWidget
{
	GENERATED_BODY()

protected:
	virtual void NativeConstruct() override;

private:
	UPROPERTY()
	TObjectPtr<UButton> BackButton;

	UPROPERTY()
	TObjectPtr<USlider> MasterVolumeSlider;

	UPROPERTY()
	TObjectPtr<USlider> MusicVolumeSlider;

	UPROPERTY()
	TObjectPtr<USlider> SfxVolumeSlider;

	UPROPERTY()
	TObjectPtr<UCheckBox> FullscreenToggle;

	UPROPERTY()
	TObjectPtr<USlider> GraphicsQualitySlider;

	void BuildLayout();
	UTextBlock* BuildSectionTitle(const FString& Label, UVerticalBox* Container);
	USlider* BuildSliderRow(const FString& Label, UVerticalBox* Container, float DefaultValue);
	UCheckBox* BuildToggleRow(const FString& Label, UVerticalBox* Container, bool bDefault);
	UButton* BuildButton(const FString& Label, UVerticalBox* Container);

	UFUNCTION()
	void HandleBackClicked();

	UFUNCTION()
	void HandleMasterChanged(float Value);

	UFUNCTION()
	void HandleMusicChanged(float Value);

	UFUNCTION()
	void HandleSfxChanged(float Value);

	UFUNCTION()
	void HandleGraphicsChanged(float Value);

	UFUNCTION()
	void HandleFullscreenChanged(bool bIsChecked);
};
