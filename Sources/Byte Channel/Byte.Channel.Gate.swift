import Byte_Chunk
import Buffer_Protocol_Primitives
import Index_Primitives

extension Byte.Channel {
    /// Byte-budget accounting shared by the writer and its peer reader.
    ///
    /// The gate accounts in bytes while the underlying duplex holds at most one
    /// chunk element. Empty chunks cost one admission unit, so they cannot pass
    /// an exhausted byte bound. A zero byte capacity is a rendezvous: only a
    /// reader that has announced demand can admit a writer.
    actor Gate {
        nonisolated let capacity: Buffer.Capacity<Byte>
        var available: Index<Byte>.Count
        var readerDemand = false

        init(capacity: Buffer.Capacity<Byte>) {
            self.capacity = capacity
            self.available = capacity.count
        }

        func admit(_ chunk: borrowing Byte.Chunk) async {
            let charge = chunk.count == .zero ? Index<Byte>.Count.one : chunk.count
            precondition(charge <= capacity.count || capacity.count == .zero, "chunk exceeds channel byte capacity")

            while charge > available && !(capacity.count == .zero && readerDemand) {
                await Task.yield()
            }

            if capacity.count == .zero {
                readerDemand = false
            } else {
                available = available.subtract.saturating(charge)
            }
        }

        func release(_ chunk: borrowing Byte.Chunk) {
            let charge = chunk.count == .zero ? Index<Byte>.Count.one : chunk.count
            if capacity.count == .zero {
                readerDemand = true
            } else {
                available = available.add.saturating(charge)
            }
        }

        func demand() {
            if capacity.count == .zero { readerDemand = true }
        }
    }
}
