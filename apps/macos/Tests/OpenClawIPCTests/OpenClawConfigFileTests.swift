import Foundation
import Testing
@testable import Dryads AI

@Suite(.serialized)
struct DryadsAiConfigFileTests {
    @Test
    func configPathRespectsEnvOverride() async {
        let override = FileManager().temporaryDirectory
            .appendingPathComponent("dryads-ai-config-\(UUID().uuidString)")
            .appendingPathComponent("dryads-ai.json")
            .path

        await TestIsolation.withEnvValues(["DRYADS_AI_CONFIG_PATH": override]) {
            #expect(DryadsAiConfigFile.url().path == override)
        }
    }

    @MainActor
    @Test
    func remoteGatewayPortParsesAndMatchesHost() async {
        let override = FileManager().temporaryDirectory
            .appendingPathComponent("dryads-ai-config-\(UUID().uuidString)")
            .appendingPathComponent("dryads-ai.json")
            .path

        await TestIsolation.withEnvValues(["DRYADS_AI_CONFIG_PATH": override]) {
            DryadsAiConfigFile.saveDict([
                "gateway": [
                    "remote": [
                        "url": "ws://gateway.ts.net:19999",
                    ],
                ],
            ])
            #expect(DryadsAiConfigFile.remoteGatewayPort() == 19999)
            #expect(DryadsAiConfigFile.remoteGatewayPort(matchingHost: "gateway.ts.net") == 19999)
            #expect(DryadsAiConfigFile.remoteGatewayPort(matchingHost: "gateway") == 19999)
            #expect(DryadsAiConfigFile.remoteGatewayPort(matchingHost: "other.ts.net") == nil)
        }
    }

    @MainActor
    @Test
    func setRemoteGatewayUrlPreservesScheme() async {
        let override = FileManager().temporaryDirectory
            .appendingPathComponent("dryads-ai-config-\(UUID().uuidString)")
            .appendingPathComponent("dryads-ai.json")
            .path

        await TestIsolation.withEnvValues(["DRYADS_AI_CONFIG_PATH": override]) {
            DryadsAiConfigFile.saveDict([
                "gateway": [
                    "remote": [
                        "url": "wss://old-host:111",
                    ],
                ],
            ])
            DryadsAiConfigFile.setRemoteGatewayUrl(host: "new-host", port: 2222)
            let root = DryadsAiConfigFile.loadDict()
            let url = ((root["gateway"] as? [String: Any])?["remote"] as? [String: Any])?["url"] as? String
            #expect(url == "wss://new-host:2222")
        }
    }

    @Test
    func stateDirOverrideSetsConfigPath() async {
        let dir = FileManager().temporaryDirectory
            .appendingPathComponent("dryads-ai-state-\(UUID().uuidString)", isDirectory: true)
            .path

        await TestIsolation.withEnvValues([
            "DRYADS_AI_CONFIG_PATH": nil,
            "DRYADS_AI_STATE_DIR": dir,
        ]) {
            #expect(DryadsAiConfigFile.stateDirURL().path == dir)
            #expect(DryadsAiConfigFile.url().path == "\(dir)/dryads-ai.json")
        }
    }

    @MainActor
    @Test
    func saveDictAppendsConfigAuditLog() async throws {
        let stateDir = FileManager().temporaryDirectory
            .appendingPathComponent("dryads-ai-state-\(UUID().uuidString)", isDirectory: true)
        let configPath = stateDir.appendingPathComponent("dryads-ai.json")
        let auditPath = stateDir.appendingPathComponent("logs/config-audit.jsonl")

        defer { try? FileManager().removeItem(at: stateDir) }

        try await TestIsolation.withEnvValues([
            "DRYADS_AI_STATE_DIR": stateDir.path,
            "DRYADS_AI_CONFIG_PATH": configPath.path,
        ]) {
            DryadsAiConfigFile.saveDict([
                "gateway": ["mode": "local"],
            ])

            let configData = try Data(contentsOf: configPath)
            let configRoot = try JSONSerialization.jsonObject(with: configData) as? [String: Any]
            #expect((configRoot?["meta"] as? [String: Any]) != nil)

            let rawAudit = try String(contentsOf: auditPath, encoding: .utf8)
            let lines = rawAudit
                .split(whereSeparator: \.isNewline)
                .map(String.init)
            #expect(!lines.isEmpty)
            guard let last = lines.last else {
                Issue.record("Missing config audit line")
                return
            }
            let auditRoot = try JSONSerialization.jsonObject(with: Data(last.utf8)) as? [String: Any]
            #expect(auditRoot?["source"] as? String == "macos-dryads-ai-config-file")
            #expect(auditRoot?["event"] as? String == "config.write")
            #expect(auditRoot?["result"] as? String == "success")
            #expect(auditRoot?["configPath"] as? String == configPath.path)
        }
    }
}
