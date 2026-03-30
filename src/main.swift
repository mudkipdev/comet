let server = Server(config: try loadConfig())
try await server.start()
server.stop()