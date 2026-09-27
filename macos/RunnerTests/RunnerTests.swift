import Cocoa
import FlutterMacOS
import XCTest
@testable import Runner

class RunnerTests: XCTestCase {
  func testProductIdentityIsConfigured() throws {
    let info = try XCTUnwrap(Bundle(for: MainFlutterWindow.self).infoDictionary)
    XCTAssertEqual(info["CFBundleName"] as? String, "Fake Floor")
    XCTAssertEqual(info["CFBundleIdentifier"] as? String, "ch.gregiwaller.fakefloor")
  }
}
