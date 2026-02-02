#include "ProjectP1LOTGameMode.h"
#include "PilotCharacter.h"

AProjectP1LOTGameMode::AProjectP1LOTGameMode()
{
    DefaultPawnClass = APilotCharacter::StaticClass();
}
