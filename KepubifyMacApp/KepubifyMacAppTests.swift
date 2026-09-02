//
//  KepubifyMacAppTests.swift
//  KepubifyMacAppTests
//
//  Created by Vibe Code
//

import XCTest
@testable import KepubifyMacApp

class KepubifyMacAppTests: XCTestCase {

    var manager: KepubifyManager!

    override func setUpWithError() throws {
        manager = KepubifyManager()
    }

    override func tearDownWithError() throws {
        manager = nil
    }

    func testCheckKepubifyAvailable() {
        // This test checks if kepubify is available in the system
        let available = manager.checkKepubifyAvailable()
        XCTAssertTrue(available, "Kepubify should be available in the system")
    }

    func testFindKepubifyPath() {
        // This test checks if we can find the kepubify path
        let path = manager.findKepubifyPath()
        XCTAssertNotNil(path, "Should be able to find kepubify path")
    }

    func testGetKepubifyVersion() {
        let expectation = self.expectation(description: "Get kepubify version")
        
        manager.getKepubifyVersion { version in
            XCTAssertNotNil(version, "Should be able to get version")
            if let version = version {
                XCTAssertFalse(version.isEmpty, "Version string should not be empty")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testConversionWithEmptyFiles() {
        let expectation = self.expectation(description: "Test empty files conversion")
        
        let options = KepubifyOptions()
        
        manager.convertFiles(at: [], options: options) { result in
            XCTAssertFalse(result.success, "Should fail with empty files")
            XCTAssertEqual(result.message, "No files selected")
            XCTAssertNil(result.outputPath)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testKepubifyOptionsDefaultValues() {
        let options = KepubifyOptions()
        
        XCTAssertNil(options.outputDirectory)
        XCTAssertFalse(options.inPlace)
        XCTAssertFalse(options.update)
        XCTAssertFalse(options.noPreserveDirs)
        XCTAssertFalse(options.calibre)
        XCTAssertTrue(options.copyExtensions.isEmpty)
        XCTAssertFalse(options.smartenPunctuation)
        XCTAssertNil(options.hyphenate)
        XCTAssertFalse(options.fullscreenReadingFixes)
        XCTAssertTrue(options.replaceRules.isEmpty)
        XCTAssertEqual(options.charset, "utf-8")
        XCTAssertFalse(options.verbose)
    }

    func testConversionStatus() {
        XCTAssertEqual(manager.status, .idle)
        
        // Test that we can change the status
        manager.status = .converting
        XCTAssertEqual(manager.status, .converting)
        
        manager.status = .completed
        XCTAssertEqual(manager.status, .completed)
        
        manager.status = .failed
        XCTAssertEqual(manager.status, .failed)
        
        // Reset to idle
        manager.status = .idle
        XCTAssertEqual(manager.status, .idle)
    }

    func testProgressTracking() {
        XCTAssertEqual(manager.progress, 0.0)
        
        manager.progress = 0.5
        XCTAssertEqual(manager.progress, 0.5)
        
        manager.progress = 1.0
        XCTAssertEqual(manager.progress, 1.0)
        
        // Reset
        manager.progress = 0.0
        XCTAssertEqual(manager.progress, 0.0)
    }

    func testLogOutput() {
        XCTAssertTrue(manager.logOutput.isEmpty)
        
        manager.logOutput = "Test log message"
        XCTAssertEqual(manager.logOutput, "Test log message")
        
        manager.logOutput = ""
        XCTAssertTrue(manager.logOutput.isEmpty)
    }

    func testConversionResult() {
        let successResult = ConversionResult(
            success: true,
            message: "Conversion completed",
            outputPath: "/path/to/output"
        )
        
        XCTAssertTrue(successResult.success)
        XCTAssertEqual(successResult.message, "Conversion completed")
        XCTAssertEqual(successResult.outputPath, "/path/to/output")
        
        let failureResult = ConversionResult(
            success: false,
            message: "Conversion failed",
            outputPath: nil
        )
        
        XCTAssertFalse(failureResult.success)
        XCTAssertEqual(failureResult.message, "Conversion failed")
        XCTAssertNil(failureResult.outputPath)
    }
}
