public import Async_Channel_Primitives
public import Buffer_Protocol_Primitives
public import Byte_Chunk
public import Byte_Primitives
public import Index_Primitives

extension Byte {
    /// A typed, bidirectional channel of owned byte chunks.
    ///
    /// The transport is `Async.Channel<Byte.Chunk>.Duplex`. This layer owns
    /// only byte-budget admission; it never coalesces chunks or owns a queue.
    public struct Channel<Failure: Swift.Error & Sendable>: ~Copyable, Sendable {
        /// The inbound half of one endpoint.
        public var reader: Reader

        /// The outbound half of one endpoint.
        public let writer: Writer

        /// Creates connected endpoints with a byte capacity for each direction.
        public static func pair(capacity: Buffer.Capacity<Byte>) -> (Self, Self) {
            var duplexes = Async.Channel<Byte.Chunk>.Duplex<Failure>.pair(capacity: .one)
            let leftGate = Gate(capacity: capacity.count)
            let rightGate = Gate(capacity: capacity.count)

            return (
                .init(
                    reader: .init(raw: consume duplexes.0.inbound, gate: rightGate),
                    writer: .init(raw: duplexes.0.outbound, gate: leftGate)
                ),
                .init(
                    reader: .init(raw: consume duplexes.1.inbound, gate: leftGate),
                    writer: .init(raw: duplexes.1.outbound, gate: rightGate)
                )
            )
        }

        @usableFromInline
        init(reader: consuming Reader, writer: Writer) {
            self.reader = consume reader
            self.writer = writer
        }
    }
}

extension Byte.Channel {
    /// Typed terminal and backpressure outcomes inherited from the duplex.
    public typealias Error = Async.Channel<Byte.Chunk>.Typed<Failure>.Error
}
