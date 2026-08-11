import Byte_Chunk
import Index_Primitives

extension Byte.Channel {
    /// Byte-budget accounting shared by the writer and its peer reader.
    ///
    /// The gate accounts in bytes while the underlying duplex holds at most one
    /// chunk element. Empty chunks cost one admission unit, so they cannot pass
    /// an exhausted byte bound. A zero byte capacity is a rendezvous: only a
    /// reader that has announced demand can admit a writer.
    actor Gate {
        let capacity: Index<Byte>.Count
        var available: Index<Byte>.Count
        var readerDemand = false

        init(capacity: Index<Byte>.Count) {
            self.capacity = capacity
            self.available = capacity
        }

        func admit(_ chunk: borrowing Byte.Chunk) async {
            let charge = chunk.count == .zero ? Index<Byte>.Count.one : chunk.count
            precondition(charge <= capacity || capacity == .zero, "chunk exceeds channel byte capacity")

            while charge > available && !(capacity == .zero && readerDemand) {
                await Task.yield()
            }

            if capacity == .zero {
                readerDemand = false
            } else {
                available = available.subtract.saturating(charge)
            }
        }

        func release(_ chunk: borrowing Byte.Chunk) {
            let charge = chunk.count == .zero ? Index<Byte>.Count.one : chunk.count
            if capacity == .zero {
                readerDemand = true
            } else {
                available = available.add.saturating(charge)
            }
        }

        func demand() {
            if capacity == .zero { readerDemand = true }
        }
    }
}
