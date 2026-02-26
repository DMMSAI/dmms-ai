package ai.dryadsai.android.protocol

import org.junit.Assert.assertEquals
import org.junit.Test

class DryadsAiProtocolConstantsTest {
  @Test
  fun canvasCommandsUseStableStrings() {
    assertEquals("canvas.present", DryadsAiCanvasCommand.Present.rawValue)
    assertEquals("canvas.hide", DryadsAiCanvasCommand.Hide.rawValue)
    assertEquals("canvas.navigate", DryadsAiCanvasCommand.Navigate.rawValue)
    assertEquals("canvas.eval", DryadsAiCanvasCommand.Eval.rawValue)
    assertEquals("canvas.snapshot", DryadsAiCanvasCommand.Snapshot.rawValue)
  }

  @Test
  fun a2uiCommandsUseStableStrings() {
    assertEquals("canvas.a2ui.push", DryadsAiCanvasA2UICommand.Push.rawValue)
    assertEquals("canvas.a2ui.pushJSONL", DryadsAiCanvasA2UICommand.PushJSONL.rawValue)
    assertEquals("canvas.a2ui.reset", DryadsAiCanvasA2UICommand.Reset.rawValue)
  }

  @Test
  fun capabilitiesUseStableStrings() {
    assertEquals("canvas", DryadsAiCapability.Canvas.rawValue)
    assertEquals("camera", DryadsAiCapability.Camera.rawValue)
    assertEquals("screen", DryadsAiCapability.Screen.rawValue)
    assertEquals("voiceWake", DryadsAiCapability.VoiceWake.rawValue)
  }

  @Test
  fun screenCommandsUseStableStrings() {
    assertEquals("screen.record", DryadsAiScreenCommand.Record.rawValue)
  }
}
