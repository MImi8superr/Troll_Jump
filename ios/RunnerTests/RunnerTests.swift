import Flutter
import UIKit
import XCTest
@testable import Runner

class RunnerTests: XCTestCase {
  func testProductIdentityIsConfigured() throws {
    let info = try XCTUnwrap(Bundle(for: AppDelegate.self).infoDictionary)

    XCTAssertEqual(info["CFBundleDisplayName"] as? String, "Troll Dash")
    XCTAssertNil(info["CFBundleURLTypes"], "Troll Dash does not register URL schemes")
  }
}
