import Vapor

struct RequestLoggingMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Log request headers
        request.logger.info("Headers: \(request.headers)")

        // Log request body if it is present
        if let body = request.body.string {
            request.logger.info("Body: \(body)")
        }

        // Continue to the next middleware in the chain
        return try await next.respond(to: request)
    }
}
