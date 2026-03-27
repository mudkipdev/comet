import Compression

// this is AI cuz i cba to do this

func zlibCompress(_ input: [UInt8]) -> [UInt8]? {
    // Compress with raw deflate (Apple's Compression framework)
    var compressed = [UInt8](repeating: 0, count: input.count + 1024)

    let compressedSize = input.withUnsafeBufferPointer { src in
        compressed.withUnsafeMutableBufferPointer { dst in
            compression_encode_buffer(dst.baseAddress!, dst.count, src.baseAddress!, src.count, nil, COMPRESSION_ZLIB)
        }
    }

    guard compressedSize > 0 else { return nil }

    // Wrap in zlib format: 2-byte header + deflate data + 4-byte Adler-32
    var result = [UInt8]()
    result.reserveCapacity(2 + compressedSize + 4)

    // zlib header: CMF=0x78 (deflate, 32K window), FLG=0x9C (level 6, check bits)
    result.append(0x78)
    result.append(0x9C)
    result.append(contentsOf: compressed[..<compressedSize])

    // Adler-32 checksum of uncompressed data
    let checksum = adler32(input)
    result.append(UInt8((checksum >> 24) & 0xFF))
    result.append(UInt8((checksum >> 16) & 0xFF))
    result.append(UInt8((checksum >> 8) & 0xFF))
    result.append(UInt8(checksum & 0xFF))

    return result
}

private func adler32(_ data: [UInt8]) -> UInt32 {
    var a: UInt32 = 1
    var b: UInt32 = 0

    for byte in data {
        a = (a + UInt32(byte)) % 65521
        b = (b + a) % 65521
    }

    return (b << 16) | a
}
