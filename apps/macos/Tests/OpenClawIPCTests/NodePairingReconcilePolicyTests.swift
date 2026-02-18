import Testing
@testable import DMMS AI

@Suite struct NodePairingReconcilePolicyTests {
    @Test func policyPollsOnlyWhenActive() {
        #expect(NodePairingReconcilePolicy.shouldPoll(pendingCount: 0, isPresenting: false) == false)
        #expect(NodePairingReconcilePolicy.shouldPoll(pendingCount: 1, isPresenting: false))
        #expect(NodePairingReconcilePolicy.shouldPoll(pendingCount: 0, isPresenting: true))
    }

    @Test func policyUsesSlowSafetyInterval() {
        #expect(NodePairingReconcilePolicy.activeIntervalMs >= 10000)
    }
}
