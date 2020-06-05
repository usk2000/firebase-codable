import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(firebase_codableTests.allTests),
    ]
}
#endif
