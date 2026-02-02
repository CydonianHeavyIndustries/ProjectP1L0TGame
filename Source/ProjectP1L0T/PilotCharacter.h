#include "GameFramework/Character.h"
#include "PilotCharacter.generated.h"

UCLASS()
class PROJECTP1LOT_API APilotCharacter : public ACharacter
{
	GENERATED_BODY()

public:
	APilotCharacter(const FObjectInitializer& ObjectInitializer);

protected:
	virtual void Tick(float DeltaSeconds) override;
};
