package ai.dryadsai.android.node

import android.os.Build
import ai.dryadsai.android.BuildConfig
import ai.dryadsai.android.SecurePrefs
import ai.dryadsai.android.gateway.GatewayClientInfo
import ai.dryadsai.android.gateway.GatewayConnectOptions
import ai.dryadsai.android.gateway.GatewayEndpoint
import ai.dryadsai.android.gateway.GatewayTlsParams
import ai.dryadsai.android.protocol.DryadsAiCanvasA2UICommand
import ai.dryadsai.android.protocol.DryadsAiCanvasCommand
import ai.dryadsai.android.protocol.DryadsAiCameraCommand
import ai.dryadsai.android.protocol.DryadsAiLocationCommand
import ai.dryadsai.android.protocol.DryadsAiScreenCommand
import ai.dryadsai.android.protocol.DryadsAiSmsCommand
import ai.dryadsai.android.protocol.DryadsAiCapability
import ai.dryadsai.android.LocationMode
import ai.dryadsai.android.VoiceWakeMode

class ConnectionManager(
  private val prefs: SecurePrefs,
  private val cameraEnabled: () -> Boolean,
  private val locationMode: () -> LocationMode,
  private val voiceWakeMode: () -> VoiceWakeMode,
  private val smsAvailable: () -> Boolean,
  private val hasRecordAudioPermission: () -> Boolean,
  private val manualTls: () -> Boolean,
) {
  companion object {
    internal fun resolveTlsParamsForEndpoint(
      endpoint: GatewayEndpoint,
      storedFingerprint: String?,
      manualTlsEnabled: Boolean,
    ): GatewayTlsParams? {
      val stableId = endpoint.stableId
      val stored = storedFingerprint?.trim().takeIf { !it.isNullOrEmpty() }
      val isManual = stableId.startsWith("manual|")

      if (isManual) {
        if (!manualTlsEnabled) return null
        if (!stored.isNullOrBlank()) {
          return GatewayTlsParams(
            required = true,
            expectedFingerprint = stored,
            allowTOFU = false,
            stableId = stableId,
          )
        }
        return GatewayTlsParams(
          required = true,
          expectedFingerprint = null,
          allowTOFU = false,
          stableId = stableId,
        )
      }

      // Prefer stored pins. Never let discovery-provided TXT override a stored fingerprint.
      if (!stored.isNullOrBlank()) {
        return GatewayTlsParams(
          required = true,
          expectedFingerprint = stored,
          allowTOFU = false,
          stableId = stableId,
        )
      }

      val hinted = endpoint.tlsEnabled || !endpoint.tlsFingerprintSha256.isNullOrBlank()
      if (hinted) {
        // TXT is unauthenticated. Do not treat the advertised fingerprint as authoritative.
        return GatewayTlsParams(
          required = true,
          expectedFingerprint = null,
          allowTOFU = false,
          stableId = stableId,
        )
      }

      return null
    }
  }

  fun buildInvokeCommands(): List<String> =
    buildList {
      add(DryadsAiCanvasCommand.Present.rawValue)
      add(DryadsAiCanvasCommand.Hide.rawValue)
      add(DryadsAiCanvasCommand.Navigate.rawValue)
      add(DryadsAiCanvasCommand.Eval.rawValue)
      add(DryadsAiCanvasCommand.Snapshot.rawValue)
      add(DryadsAiCanvasA2UICommand.Push.rawValue)
      add(DryadsAiCanvasA2UICommand.PushJSONL.rawValue)
      add(DryadsAiCanvasA2UICommand.Reset.rawValue)
      add(DryadsAiScreenCommand.Record.rawValue)
      if (cameraEnabled()) {
        add(DryadsAiCameraCommand.Snap.rawValue)
        add(DryadsAiCameraCommand.Clip.rawValue)
      }
      if (locationMode() != LocationMode.Off) {
        add(DryadsAiLocationCommand.Get.rawValue)
      }
      if (smsAvailable()) {
        add(DryadsAiSmsCommand.Send.rawValue)
      }
      if (BuildConfig.DEBUG) {
        add("debug.logs")
        add("debug.ed25519")
      }
      add("app.update")
    }

  fun buildCapabilities(): List<String> =
    buildList {
      add(DryadsAiCapability.Canvas.rawValue)
      add(DryadsAiCapability.Screen.rawValue)
      if (cameraEnabled()) add(DryadsAiCapability.Camera.rawValue)
      if (smsAvailable()) add(DryadsAiCapability.Sms.rawValue)
      if (voiceWakeMode() != VoiceWakeMode.Off && hasRecordAudioPermission()) {
        add(DryadsAiCapability.VoiceWake.rawValue)
      }
      if (locationMode() != LocationMode.Off) {
        add(DryadsAiCapability.Location.rawValue)
      }
    }

  fun resolvedVersionName(): String {
    val versionName = BuildConfig.VERSION_NAME.trim().ifEmpty { "dev" }
    return if (BuildConfig.DEBUG && !versionName.contains("dev", ignoreCase = true)) {
      "$versionName-dev"
    } else {
      versionName
    }
  }

  fun resolveModelIdentifier(): String? {
    return listOfNotNull(Build.MANUFACTURER, Build.MODEL)
      .joinToString(" ")
      .trim()
      .ifEmpty { null }
  }

  fun buildUserAgent(): String {
    val version = resolvedVersionName()
    val release = Build.VERSION.RELEASE?.trim().orEmpty()
    val releaseLabel = if (release.isEmpty()) "unknown" else release
    return "DryadsAiAndroid/$version (Android $releaseLabel; SDK ${Build.VERSION.SDK_INT})"
  }

  fun buildClientInfo(clientId: String, clientMode: String): GatewayClientInfo {
    return GatewayClientInfo(
      id = clientId,
      displayName = prefs.displayName.value,
      version = resolvedVersionName(),
      platform = "android",
      mode = clientMode,
      instanceId = prefs.instanceId.value,
      deviceFamily = "Android",
      modelIdentifier = resolveModelIdentifier(),
    )
  }

  fun buildNodeConnectOptions(): GatewayConnectOptions {
    return GatewayConnectOptions(
      role = "node",
      scopes = emptyList(),
      caps = buildCapabilities(),
      commands = buildInvokeCommands(),
      permissions = emptyMap(),
      client = buildClientInfo(clientId = "dryads-ai-android", clientMode = "node"),
      userAgent = buildUserAgent(),
    )
  }

  fun buildOperatorConnectOptions(): GatewayConnectOptions {
    return GatewayConnectOptions(
      role = "operator",
      scopes = listOf("operator.read", "operator.write", "operator.talk.secrets"),
      caps = emptyList(),
      commands = emptyList(),
      permissions = emptyMap(),
      client = buildClientInfo(clientId = "dryads-ai-control-ui", clientMode = "ui"),
      userAgent = buildUserAgent(),
    )
  }

  fun resolveTlsParams(endpoint: GatewayEndpoint): GatewayTlsParams? {
    val stored = prefs.loadGatewayTlsFingerprint(endpoint.stableId)
    return resolveTlsParamsForEndpoint(endpoint, storedFingerprint = stored, manualTlsEnabled = manualTls())
  }
}
