import SmokeHTTP1
import SmokeOperationsHTTP1
import SmokeOperations
import NIOHTTP1
import LoggerAPI
import Foundation

struct StandardOutLogger: Logger {
    func log(_ type: LoggerMessageType, msg: String, functionName: String, lineNum: Int, fileName: String) {
        if isLogging(type) {
            NSLog("\(type) (\(fileName) - \(functionName) -\(lineNum)) - \(msg)")
        }
    }

    func isLogging(_ level: LoggerMessageType) -> Bool {
        switch level {
        case .info, .error, .warning: return true
        default: return false
        }
    }
}

Log.logger = StandardOutLogger()

public struct MyAppContext {
}

public enum ErrorResponse {
    case notFound
    case internalServerError
}

extension ErrorResponse: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notFound:
            return "not found"
        case .internalServerError:
            return "internal server error"
        }
    }
}

extension ErrorResponse: Swift.Error {
}

extension ErrorResponse {
    var asErrorType: (ErrorResponse, Int) {
        get {
            switch self {
            case .notFound:
                return (self, 404)
            case .internalServerError:
                return (self, 500)
            }
        }
    }
    static var values: [ErrorResponse] {
        return [.notFound, .internalServerError]
    }
}

public typealias HandlerSelector = StandardSmokeHTTP1HandlerSelector<MyAppContext, JSONPayloadHTTP1OperationDelegate>

struct Message {
    let text: String
}

extension Message: ValidatableCodable, CustomStringConvertible {
    public func validate() throws {
        if self.text.isEmpty {
            throw ErrorResponse.notFound
        }
    }

    public var description: String {
        return "\(self.text)"
    }
}

@available(OSX 10.12, *)
struct LoggedMessage {
    let text: String
    let time: String

    init(text: String, time: Date) {
        self.text = text
        let formatter = ISO8601DateFormatter.init()
        formatter.timeZone = TimeZone(identifier: "UTC")!
        self.time = formatter.string(from: time)
    }
}

@available(OSX 10.12, *)
extension LoggedMessage: ValidatableCodable, CustomStringConvertible {
    public func validate() throws {}

    public var description: String {
        return "[text: \(self.text), time: \(self.time)]"
    }
}

@available(OSX 10.12, *)
func echoHandler(message: Message, context: MyAppContext) throws -> LoggedMessage {
    Log.info("message: \(message)")
    return LoggedMessage(text: message.text, time: Date())
}

@available(OSX 10.12, *)
public func handlerSelector() -> HandlerSelector {
    var selector = HandlerSelector()
    let errors: [(ErrorResponse, Int)] = ErrorResponse.values.map({ (it: ErrorResponse) in it.asErrorType })
    selector.addHandlerForUri(
            "/example",
            httpMethod: HTTPMethod.POST,
            operation: echoHandler,
            allowedErrors: errors,
            operationDelegate: nil)
    return selector
}

struct AppError: Error, CustomStringConvertible {
    let message: String
    init(_ message: String) {
        self.message = message
    }
    var description: String {
        return message
    }
}

do {
    if #available(OSX 10.12, *) {
        try SmokeHTTP1Server.startAsOperationServer(
                withHandlerSelector: handlerSelector(),
                andContext: MyAppContext(),
                defaultOperationDelegate: JSONPayloadHTTP1OperationDelegate())
    } else {
        throw AppError("cannot launch application. use OSX 10.12 or later")
    }
} catch {
    Log.error("failed to start server: \(error)")
}
