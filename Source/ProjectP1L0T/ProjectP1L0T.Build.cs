// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;

public class ProjectP1L0T : ModuleRules
{
	public ProjectP1L0T(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

		PublicDependencyModuleNames.AddRange(new string[] {
			"Core",
			"CoreUObject",
			"Engine",
			"InputCore",
			"EnhancedInput",
			"AIModule",
			"StateTreeModule",
			"GameplayStateTreeModule",
			"UMG",
			"Slate"
		});

		PrivateDependencyModuleNames.AddRange(new string[] { });

		PublicIncludePaths.AddRange(new string[] {
			"ProjectP1L0T",
			"ProjectP1L0T/Variant_Horror",
			"ProjectP1L0T/Variant_Horror/UI",
			"ProjectP1L0T/Variant_Shooter",
			"ProjectP1L0T/Variant_Shooter/AI",
			"ProjectP1L0T/Variant_Shooter/UI",
			"ProjectP1L0T/Variant_Shooter/Weapons"
		});

		// Uncomment if you are using Slate UI
		// PrivateDependencyModuleNames.AddRange(new string[] { "Slate", "SlateCore" });

		// Uncomment if you are using online features
		// PrivateDependencyModuleNames.Add("OnlineSubsystem");

		// To include OnlineSubsystemSteam, add it to the plugins section in your uproject file with the Enabled attribute set to true
	}
}
