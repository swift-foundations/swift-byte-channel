# swift-byte-channel

Owned `Byte.Chunk` values and typed, bidirectional `Byte.Channel` endpoints.

`Byte.Chunk` owns initialized contiguous bytes in `Buffer.Linear`, offers only a
synchronous span borrow, and uses the buffer producer's owned split operation.
`Byte.Channel` wraps `Async.Channel<Byte.Chunk>.Duplex`, preserving FIFO,
directional EOF/failure, and half-close behavior while adding byte-budget
admission. It transports complete chunks only; it does not coalesce chunks or
promise zero-copy splitting.

## Status

This implementation is source-complete but **UNVERIFIED**. It depends on the
unlanded typed-duplex producer at
`https://github.com/swift-primitives/swift-async-primitives/commit/dbfcf6a3c61e72fe98580a7ef1f5384c59898cc4`
and the unlanded owned-linear-split producer at
`https://github.com/swift-primitives/swift-buffer-linear-primitives/commit/3eead6eb2b440d417338929c60da94cc18fd3386`.
