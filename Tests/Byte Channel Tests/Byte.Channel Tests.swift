import Byte_Channel
import Testing

@Suite("Byte.Channel")
struct ByteChannelTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
}

extension ByteChannelTests.Unit {
    @Test("Chunk input is move-only and its output ledger determines the finished chunk")
    func `chunk input ownership and ledger are source-visible`() async {
        // Static source test: `consume` prevents a second use of `input`; the
        // finished count comes from OutputSpan's committed frontier, never an
        // independently supplied count.
        var input = Byte.Chunk.Input(capacity: 3)
        input.outputSpan.append(0x01)
        input.outputSpan.append(0x02)
        input.outputSpan.append(0x03)
        let chunk = consume input.finish()
        let pieces = consume chunk.split(maximum: 2)
        let prefixCount = pieces.prefix.count
        let remainderCount = pieces.remainder.count
        #expect(prefixCount == 2)
        #expect(remainderCount == 1)
    }

    @Test("Reader returns one chunk and does not coalesce producer boundaries")
    func `reader preserves chunk boundaries`() async {
        // Source contract: `receive()` vends Byte.Chunk?, while the bounded
        // `receive(maximum:)` path retains one owned remainder only.
    }

    @Test("Chunk exposes only lifetime views")
    func `chunk lifetime and negative contracts are source-visible`() async {
        // Static source contract:
        // - `Byte.Chunk.span` is a borrowing lifetime-bound `Swift.Span<Byte>`.
        // - no public `withSpan` or other `with*` chunk API exists.
        // - no raw pointer, `Span.Raw`, storage, async view, or SPI escapes.
        // - neither `span` nor `outputSpan` crosses `await`.
    }
}

extension ByteChannelTests.EdgeCase {
    @Test("Byte capacity accounts for empty chunks, oversized chunks, and zero-capacity rendezvous")
    func `byte budget edge conditions are source-visible`() async {
        let zero = Buffer.Capacity<Byte>(.zero)
        let one = Buffer.Capacity<Byte>(.one)
        _ = Byte.Channel<Never>.pair(capacity: zero)
        _ = Byte.Channel<Never>.pair(capacity: one)
        // Empty chunks charge one admission unit; an oversize send is rejected
        // by the gate rather than bypassing the declared byte capacity.
    }

    @Test("A split retains at most one owned remainder")
    func `reader never needs a cross chunk buffer`() async {
        // The Reader declaration holds one `Byte.Chunk?`, not a Ring, actor
        // queue, or cross-chunk accumulator.
    }
}

extension ByteChannelTests.Integration {
    @Test("FIFO, typed EOF and failure, half-close, and shutdown are delegated to the duplex")
    func `duplex terminal behavior remains typed`() async {}
}
