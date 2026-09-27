import Flutter
import UIKit
import XCTest
@testable import Runner

class RunnerTests: XCTestCase {
  func testProductIdentityIsConfigured() throws {
    let info = try XCTUnwrap(Bundle(for: AppDelegate.self).infoDictionary)

    XCTAssertEqual(info["CFBundleDisplayName"] as? String, "Fake Floor")
    XCTAssertNil(info["CFBundleURLTypes"], "Fake Floor does not register URL schemes")
  }
}
