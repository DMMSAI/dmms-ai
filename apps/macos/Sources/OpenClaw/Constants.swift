import Foundation

// Stable identifier used for both the macOS LaunchAgent label and Nix-managed defaults suite.
// nix-dmms-ai writes app defaults into this suite to survive app bundle identifier churn.
let launchdLabel = "ai.dmmsai.mac"
let gatewayLaunchdLabel = "ai.dmmsai.gateway"
let onboardingVersionKey = "dmms-ai.onboardingVersion"
let onboardingSeenKey = "dmms-ai.onboardingSeen"
let currentOnboardingVersion = 7
let pauseDefaultsKey = "dmms-ai.pauseEnabled"
let iconAnimationsEnabledKey = "dmms-ai.iconAnimationsEnabled"
let swabbleEnabledKey = "dmms-ai.swabbleEnabled"
let swabbleTriggersKey = "dmms-ai.swabbleTriggers"
let voiceWakeTriggerChimeKey = "dmms-ai.voiceWakeTriggerChime"
let voiceWakeSendChimeKey = "dmms-ai.voiceWakeSendChime"
let showDockIconKey = "dmms-ai.showDockIcon"
let defaultVoiceWakeTriggers = ["dmms-ai"]
let voiceWakeMaxWords = 32
let voiceWakeMaxWordLength = 64
let voiceWakeMicKey = "dmms-ai.voiceWakeMicID"
let voiceWakeMicNameKey = "dmms-ai.voiceWakeMicName"
let voiceWakeLocaleKey = "dmms-ai.voiceWakeLocaleID"
let voiceWakeAdditionalLocalesKey = "dmms-ai.voiceWakeAdditionalLocaleIDs"
let voicePushToTalkEnabledKey = "dmms-ai.voicePushToTalkEnabled"
let talkEnabledKey = "dmms-ai.talkEnabled"
let iconOverrideKey = "dmms-ai.iconOverride"
let connectionModeKey = "dmms-ai.connectionMode"
let remoteTargetKey = "dmms-ai.remoteTarget"
let remoteIdentityKey = "dmms-ai.remoteIdentity"
let remoteProjectRootKey = "dmms-ai.remoteProjectRoot"
let remoteCliPathKey = "dmms-ai.remoteCliPath"
let canvasEnabledKey = "dmms-ai.canvasEnabled"
let cameraEnabledKey = "dmms-ai.cameraEnabled"
let systemRunPolicyKey = "dmms-ai.systemRunPolicy"
let systemRunAllowlistKey = "dmms-ai.systemRunAllowlist"
let systemRunEnabledKey = "dmms-ai.systemRunEnabled"
let locationModeKey = "dmms-ai.locationMode"
let locationPreciseKey = "dmms-ai.locationPreciseEnabled"
let peekabooBridgeEnabledKey = "dmms-ai.peekabooBridgeEnabled"
let deepLinkKeyKey = "dmms-ai.deepLinkKey"
let modelCatalogPathKey = "dmms-ai.modelCatalogPath"
let modelCatalogReloadKey = "dmms-ai.modelCatalogReload"
let cliInstallPromptedVersionKey = "dmms-ai.cliInstallPromptedVersion"
let heartbeatsEnabledKey = "dmms-ai.heartbeatsEnabled"
let debugPaneEnabledKey = "dmms-ai.debugPaneEnabled"
let debugFileLogEnabledKey = "dmms-ai.debug.fileLogEnabled"
let appLogLevelKey = "dmms-ai.debug.appLogLevel"
let voiceWakeSupported: Bool = ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
