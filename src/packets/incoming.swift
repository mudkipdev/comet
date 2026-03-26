import NIOCore

protocol IncomingPacket {
    init(from buffer: inout ByteBuffer) throws
}