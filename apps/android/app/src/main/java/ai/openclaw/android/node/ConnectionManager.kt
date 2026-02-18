package ai.dmmsai.android.node

import android.os.Build
import ai.dmmsai.android.BuildConfig
import ai.dmmsai.android.SecurePrefs
import ai.dmmsai.android.gateway.GatewayClientInfo
import ai.dmmsai.android.gateway.GatewayConnectOptions
import ai.dmmsai.android.gateway.GatewayEndpoint
import ai.dmmsai.android.gateway.GatewayTlsParams
import ai.dmmsai.android.protocol.DmmsAiCanvasA2UICommand
import ai.dmmsai.android.protocol.DmmsAiCanvasCommand
import ai.dmmsai.android.protocol.DmmsAiCameraCommand
import ai.dmmsai.android.protocol.DmmsAiLocationCommand
import ai.dmmsai.android.protocol.DmmsAiScreenCommand
import ai.dmmsai.android.protocol.DmmsAiSmsCommand
import ai.dmmsai.android.protocol.DmmsAiCapability
import ai.dmmsai.android.LocationMode
import ai.dmmsai.android.VoiceWakeMode

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
      add(DmmsAiCanvasCommand.Present.rawValue)
      add(DmmsAiCanvasCommand.Hide.rawValue)
      add(DmmsAiCanvasCommand.Navigate.rawValue)
      add(DmmsAiCanvasCommand.Eval.rawValue)
      add(DmmsAiCanvasCommand.Snapshot.rawValue)
      add(DmmsAiCanvasA2UICommand.Push.rawValue)
      add(DmmsAiCanvasA2UICommand.PushJSONL.rawValue)
      add(DmmsAiCanvasA2UICommand.Reset.rawValue)
      add(DmmsAiScreenCommand.Record.rawValue)
      if (cameraEnabled()) {
        add(DmmsAiCameraCommand.Snap.rawValue)
        add(DmmsAiCameraCommand.Clip.rawValue)
      }
      if (locationMode() != LocationMode.Off) {
        add(DmmsAiLocationCommand.Get.rawValue)
      }
      if (smsAvailable()) {
        add(DmmsAiSmsCommand.Send.rawValue)
      }
      if (BuildConfig.DEBUG) {
        add("debug.logs")
        add("debug.ed25519")
      }
      add("app.update")
    }

  fun buildCapabilities(): List<String> =
    buildList {
      add(DmmsAiCapability.Canvas.rawValue)
      add(DmmsAiCapability.Screen.rawValue)
      if (cameraEnabled()) add(DmmsAiCapability.Camera.rawValue)
      if (smsAvailable()) add(DmmsAiCapability.Sms.rawValue)
      if (voiceWakeMode() != VoiceWakeMode.Off && hasRecordAudioPermission()) {
        add(DmmsAiCapability.VoiceWake.rawValue)
      }
      if (locationMode() != LocationMode.Off) {
        add(DmmsAiCapability.Location.rawValue)
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
    return "DmmsAiAndroid/$version (Android $releaseLabel; SDK ${Build.VERSION.SDK_INT})"
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
      client = buildClientInfo(clientId = "dmms-ai-android", clientMode = "node"),
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
      client = buildClientInfo(clientId = "dmms-ai-control-ui", clientMode = "ui"),
      userAgent = buildUserAgent(),
    )
  }

  fun resolveTlsParams(endpoint: GatewayEndpoint): GatewayTlsParams? {
    val stored = prefs.loadGatewayTlsFingerprint(endpoint.stableId)
    return resolveTlsParamsForEndpoint(endpoint, storedFingerprint = stored, manualTlsEnabled = manualTls())
  }
}
