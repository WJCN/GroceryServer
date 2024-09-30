import Vapor

@main
enum Entrypoint {
	static func main() async throws {
		var environment = try Environment.detect()
		try LoggingSystem.bootstrap(from: &environment)

		let application = try await Application.make(environment)

		/// This attempts to install NIO as the Swift Concurrency global executor.
		/// You can enable it if you'd like to reduce the amount of context switching between NIO and Swift Concurrency.
		/// Note: this has caused issues with some libraries that use `.wait()` and cleanly shutting down.
		/// If enabled, you should be careful about calling async functions before this point as it can cause assertion failures.
		/// let executorTakeoverSuccess = NIOSingletons.unsafeTryInstallSingletonPosixEventLoopGroupAsConcurrencyGlobalExecutor()
		/// app.logger.debug("Tried to install SwiftNIO's EventLoopGroup as Swift's global concurrency executor", metadata: ["success": .stringConvertible(executorTakeoverSuccess)])

		do {
			try await configure(application)
		} catch {
			application.logger.report(error: error)
			try? await application.asyncShutdown()
			throw error
		}
		try await application.execute()
		try await application.asyncShutdown()
	}
}
