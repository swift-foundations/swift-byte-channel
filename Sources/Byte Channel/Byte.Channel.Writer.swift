import Async_Channel_Primitives
import Byte_Chunk

extension Byte.Channel {
    /// The outbound endpoint for owned byte chunks.
    public struct Writer: Sendable {
        @usableFromInline
        let raw: Async.Channel<Byte.Chunk>.Typed<Failure>.Sender

        @usableFromInline
        let gate: Gate

        @usableFromInline
        init(raw: Async.Channel<Byte.Chunk>.Typed<Failure>.Sender, gate: Gate) {
            self.raw = raw
            self.gate = gate
        }
    }
}

extension Byte.Channel.Writer {
    /// Sends one whole chunk after byte-budget admission.
    public func send(_ chunk: consuming sending Byte.Chunk) async throws(Byte.Channel<Failure>.Error) {
        await gate.admit(chunk)
        try await raw.send(consume chunk)
    }

    /// Half-closes this outbound direction while inbound remains drainable.
    public func finish() { raw.finish() }

    /// Fails this outbound direction after its buffered chunk drains.
    public func fail(_ failure: consuming Failure) { raw.fail(consume failure) }
}
