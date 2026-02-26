import Foundation

// Stable identifier used for both the macOS LaunchAgent label and Nix-managed defaults suite.
// nix-dryads-ai writes app defaults into this suite to survive app bundle identifier churn.
let launchdLabel = "ai.dryadsai.mac"
let gatewayLaunchdLabel = "ai.dryadsai.gateway"
let onboardingVersionKey = "dryads-ai.onboardingVersion"
let onboardingSeenKey = "dryads-ai.onboardingSeen"
let currentOnboardingVersion = 7
let pauseDefaultsKey = "dryads-ai.pauseEnabled"
let iconAnimationsEnabledKey = "dryads-ai.iconAnimationsEnabled"
let swabbleEnabledKey = "dryads-ai.swabbleEnabled"
let swabbleTriggersKey = "dryads-ai.swabbleTriggers"
let voiceWakeTriggerChimeKey = "dryads-ai.voiceWakeTriggerChime"
let voiceWakeSendChimeKey = "dryads-ai.voiceWakeSendChime"
let showDockIconKey = "dryads-ai.showDockIcon"
let defaultVoiceWakeTriggers = ["dryads-ai"]
let voiceWakeMaxWords = 32
let voiceWakeMaxWordLength = 64
let voiceWakeMicKey = "dryads-ai.voiceWakeMicID"
let voiceWakeMicNameKey = "dryads-ai.voiceWakeMicName"
let voiceWakeLocaleKey = "dryads-ai.voiceWakeLocaleID"
let voiceWakeAdditionalLocalesKey = "dryads-ai.voiceWakeAdditionalLocaleIDs"
let voicePushToTalkEnabledKey = "dryads-ai.voicePushToTalkEnabled"
let talkEnabledKey = "dryads-ai.talkEnabled"
let iconOverrideKey = "dryads-ai.iconOverride"
let connectionModeKey = "dryads-ai.connectionMode"
let remoteTargetKey = "dryads-ai.remoteTarget"
let remoteIdentityKey = "dryads-ai.remoteIdentity"
let remoteProjectRootKey = "dryads-ai.remoteProjectRoot"
let remoteCliPathKey = "dryads-ai.remoteCliPath"
let canvasEnabledKey = "dryads-ai.canvasEnabled"
let cameraEnabledKey = "dryads-ai.cameraEnabled"
let systemRunPolicyKey = "dryads-ai.systemRunPolicy"
let systemRunAllowlistKey = "dryads-ai.systemRunAllowlist"
let systemRunEnabledKey = "dryads-ai.systemRunEnabled"
let locationModeKey = "dryads-ai.locationMode"
let locationPreciseKey = "dryads-ai.locationPreciseEnabled"
let peekabooBridgeEnabledKey = "dryads-ai.peekabooBridgeEnabled"
let deepLinkKeyKey = "dryads-ai.deepLinkKey"
let modelCatalogPathKey = "dryads-ai.modelCatalogPath"
let modelCatalogReloadKey = "dryads-ai.modelCatalogReload"
let cliInstallPromptedVersionKey = "dryads-ai.cliInstallPromptedVersion"
let heartbeatsEnabledKey = "dryads-ai.heartbeatsEnabled"
let debugPaneEnabledKey = "dryads-ai.debugPaneEnabled"
let debugFileLogEnabledKey = "dryads-ai.debug.fileLogEnabled"
let appLogLevelKey = "dryads-ai.debug.appLogLevel"
let voiceWakeSupported: Bool = ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
