import XCTest
import class Foundation.Bundle
@testable import ExampleResponseApp

final class MessageTests: XCTestCase {
    func notEmptyText() {
        let message = Message(text: "foo")
        do {
            try message.validate()
        } catch {
            XCTFail("expected no error, but error was thrown: \(error)")
        }
    }

    func emptyText() {
        let message = Message(text: "")
        do {
            try message.validate()
            XCTFail("expected error, but error was not thrown: \(message)")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    static var allTests = [
        ("notEmptyText", notEmptyText),
        ("emptyText", emptyText),
    ]
}
