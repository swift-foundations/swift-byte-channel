import Async_Channel_Primitives
import Byte_Chunk
import Index_Primitives

extension Byte.Channel {
    /// The move-only inbound endpoint for one chunk at a time.
    public struct Reader: ~Copyable, Sendable {
        @usableFromInline
        var raw: Async.Channel<Byte.Chunk>.Typed<Failure>.Receiver

        @usableFromInline
        let gate: Gate

        /// The only retained producer remainder. It is never coalesced with a
        /// later producer chunk.
        @usableFromInline
        var remainder: Byte.Chunk?

        @usableFromInline
        init(raw: consuming Async.Channel<Byte.Chunk>.Typed<Failure>.Receiver, gate: Gate) {
            self.raw = consume raw
            self.gate = gate
            self.remainder = nil
        }
    }
}

extension Byte.Channel.Reader {
    /// Receives exactly one producer chunk, without cross-chunk coalescing.
    public mutating func receive() async throws(Byte.Channel<Failure>.Error) -> sending Byte.Chunk? {
        if let remainder = consume remainder {
            return remainder
        }

        await gate.demand()
        guard let chunk = try await raw.receive() else { return nil }
        await gate.release(chunk)
        return chunk
    }

    /// Receives at most `maximum` bytes from one producer chunk.
    ///
    /// A shorter prefix retains exactly one owned remainder for the next call.
    /// This never combines bytes from different producer chunks.
    public mutating func receive(
        maximum: Index<Byte>.Count
    ) async throws(Byte.Channel<Failure>.Error) -> sending Byte.Chunk? {
        guard let chunk = try await receive() else { return nil }
        let pieces = consume chunk.split(maximum: maximum)
        if pieces.remainder.count != .zero {
            remainder = consume pieces.remainder
        }
        return pieces.prefix
    }

    /// Finishes the peer writer after any already-received chunk is handled.
    public func finish() { raw.finish() }

    /// Fails the peer writer with the channel's declared failure type.
    public func fail(_ failure: consuming Failure) { raw.fail(consume failure) }
}
