import NIOCore

struct UnexpectedEndOfBuffer: Error {

}

extension ByteBuffer {
    mutating func readInteger<T: FixedWidthInteger>(as: T.Type = T.self) throws -> T {
        // could not read the value
        guard let value: T = readInteger() else {
            throw UnexpectedEndOfBuffer()
        }

        return value
    }

    mutating func readBoolean() throws -> Bool {
        try readInteger(as: UInt8.self) != 0
    }

    mutating func writeBoolean(_ value: Bool) {
        writeInteger(UInt8(value ? 1 : 0))
    }

    mutating func readFloat() throws -> Float {
        Float(bitPattern: try readInteger(as: UInt32.self))
    }

    mutating func writeFloat(_ value: Float) {
        writeInteger(value.bitPattern)
    }

    mutating func readDouble() throws -> Double {
        Double(bitPattern: try readInteger(as: UInt64.self))
    }

    mutating func writeDouble(_ value: Double) {
        writeInteger(value.bitPattern)
    }

    mutating func readString16() throws -> String {
        let length = Int(try readInteger(as: UInt16.self))

        guard let bytes = readBytes(length: length * 2) else {
            throw UnexpectedEndOfBuffer()
        }

        var codeUnits = [UInt16]()
        codeUnits.reserveCapacity(length)

        for i in 0..<length {
            codeUnits.append(UInt16(bytes[i * 2]) << 8 | UInt16(bytes[i * 2 + 1]))
        }

        return String(decoding: codeUnits, as: UTF16.self)
    }

    mutating func writeString16(_ value: String) {
        let codeUnits = Array(value.utf16)
        writeInteger(UInt16(codeUnits.count))

        for unit in codeUnits {
            writeInteger(unit)
        }
    }
}
