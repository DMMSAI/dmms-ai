package ai.dmmsai.android.protocol

import org.junit.Assert.assertEquals
import org.junit.Test

class DmmsAiProtocolConstantsTest {
  @Test
  fun canvasCommandsUseStableStrings() {
    assertEquals("canvas.present", DmmsAiCanvasCommand.Present.rawValue)
    assertEquals("canvas.hide", DmmsAiCanvasCommand.Hide.rawValue)
    assertEquals("canvas.navigate", DmmsAiCanvasCommand.Navigate.rawValue)
    assertEquals("canvas.eval", DmmsAiCanvasCommand.Eval.rawValue)
    assertEquals("canvas.snapshot", DmmsAiCanvasCommand.Snapshot.rawValue)
  }

  @Test
  fun a2uiCommandsUseStableStrings() {
    assertEquals("canvas.a2ui.push", DmmsAiCanvasA2UICommand.Push.rawValue)
    assertEquals("canvas.a2ui.pushJSONL", DmmsAiCanvasA2UICommand.PushJSONL.rawValue)
    assertEquals("canvas.a2ui.reset", DmmsAiCanvasA2UICommand.Reset.rawValue)
  }

  @Test
  fun capabilitiesUseStableStrings() {
    assertEquals("canvas", DmmsAiCapability.Canvas.rawValue)
    assertEquals("camera", DmmsAiCapability.Camera.rawValue)
    assertEquals("screen", DmmsAiCapability.Screen.rawValue)
    assertEquals("voiceWake", DmmsAiCapability.VoiceWake.rawValue)
  }

  @Test
  fun screenCommandsUseStableStrings() {
    assertEquals("screen.record", DmmsAiScreenCommand.Record.rawValue)
  }
}
