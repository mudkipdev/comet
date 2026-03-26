import NIOCore

protocol OutgoingPacket {
    func write(to buffer: inout ByteBuffer) throws
}