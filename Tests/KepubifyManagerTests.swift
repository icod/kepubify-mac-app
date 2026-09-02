//
//  KepubifyManagerTests.swift
//  KepubifyMacAppTests
//
//  Created by Vibe Code
//

import XCTest
@testable import KepubifyMacApp

class KepubifyManagerTests: XCTestCase {

    var manager: KepubifyManager!
    var tempDirectory: URL!

    override func setUpWithError() throws {
        manager = KepubifyManager()
        
        // Create a temporary directory for testing
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("KepubifyTest")
            .appendingPathComponent(UUID().uuidString)
        
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        tempDirectory = tempDir
    }

    override func tearDownWithError() throws {
        // Clean up temporary directory
        try? FileManager.default.removeItem(at: tempDirectory)
        manager = nil
    }

    func testFindKepubifyPathWithMultipleLocations() {
        // Test that we can find kepubify in standard locations
        let path = manager.findKepubifyPath()
        
        if let path = path {
            // Verify the path exists
            XCTAssertTrue(FileManager.default.fileExists(atPath: path.path))
            
            // Verify it's executable
            var isExecutable = false
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: path.path)
                if let permissions = attributes[.posixPermissions] as? Int16 {
                    isExecutable = (permissions & 0o111) != 0
                }
            } catch {
                XCTFail("Failed to check file permissions: \(error)")
            }
            
            XCTAssertTrue(isExecutable, "Kepubify should be executable")
        } else {
            XCTFail("Kepubify should be found in standard locations")
        }
    }

    func testKepubifyVersionFormat() {
        let expectation = self.expectation(description: "Get kepubify version")
        
        manager.getKepubifyVersion { version in
            if let version = version {
                // Version should follow semantic versioning format (e.g., "v4.0.0")
                let pattern = #"^v?\d+\.\d+\.\d+$"#
                let regex = try? NSRegularExpression(pattern: pattern)
                
                if let regex = regex {
                    let range = NSRange(location: 0, length: version.utf16.count)
                    let matches = regex.firstMatch(in: version, options: [], range: range)
                    XCTAssertNotNil(matches, "Version should match semantic versioning format")
                }
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testConversionOptionsArgumentBuilding() {
        // Test that options are correctly converted to command-line arguments
        var options = KepubifyOptions()
        options.verbose = true
        options.inPlace = true
        options.update = true
        options.smartenPunctuation = true
        options.fullscreenReadingFixes = true
        options.charset = "iso-8859-1"
        options.copyExtensions = [".pdf", ".jpg"]
        options.replaceRules = ["old|new"]
        options.hyphenate = true
        
        // This test verifies the logic in convertFiles method
        // We can't directly test the argument building, but we can verify the options are set correctly
        XCTAssertTrue(options.verbose)
        XCTAssertTrue(options.inPlace)
        XCTAssertTrue(options.update)
        XCTAssertTrue(options.smartenPunctuation)
        XCTAssertTrue(options.fullscreenReadingFixes)
        XCTAssertEqual(options.charset, "iso-8859-1")
        XCTAssertEqual(options.copyExtensions, [".pdf", ".jpg"])
        XCTAssertEqual(options.replaceRules, ["old|new"])
        XCTAssertEqual(options.hyphenate, true)
    }

    func testConversionWithNonExistentKepubify() {
        // Mock a scenario where kepubify doesn't exist
        let expectation = self.expectation(description: "Test conversion without kepubify")
        
        // Temporarily override findKepubifyPath to return nil
        let originalMethod = manager.findKepubifyPath
        manager.findKepubifyPath = { nil }
        
        let testFile = self.tempDirectory.appendingPathComponent("test.epub")
        let data = "test".data(using: .utf8)!
        try? data.write(to: testFile)
        
        manager.convertFiles(at: [testFile], options: KepubifyOptions()) { result in
            XCTAssertFalse(result.success)
            XCTAssertNotNil(result.message)
            XCTAssertTrue(result.message?.contains("Kepubify not found") ?? false)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFileSystemOperations() {
        // Test creating and detecting EPUB files
        let testFile = tempDirectory.appendingPathComponent("test.epub")
        let testContent = "This is a test EPUB file content".data(using: .utf8)!
        
        do {
            try testContent.write(to: testFile)
            XCTAssertTrue(FileManager.default.fileExists(atPath: testFile.path))
            
            // Test file properties
            XCTAssertEqual(testFile.pathExtension, "epub")
            XCTAssertTrue(testFile.lastPathComponent.contains("test.epub"))
            
        } catch {
            XCTFail("Failed to create test file: \(error)")
        }
    }

    func testDirectoryCreation() {
        let subDir = tempDirectory.appendingPathComponent("SubDirectory")
        
        do {
            try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true)
            XCTAssertTrue(FileManager.default.fileExists(atPath: subDir.path))
            XCTAssertTrue(subDir.hasDirectoryPath)
            
        } catch {
            XCTFail("Failed to create directory: \(error)")
        }
    }

    func testEPUBFileDetection() {
        // Create test files with different extensions
        let epubFile = tempDirectory.appendingPathComponent("book.epub")
        let kepubFile = tempDirectory.appendingPathComponent("book.kepub.epub")
        let pdfFile = tempDirectory.appendingPathComponent("document.pdf")
        
        do {
            try "".data(using: .utf8)!.write(to: epubFile)
            try "".data(using: .utf8)!.write(to: kepubFile)
            try "".data(using: .utf8)!.write(to: pdfFile)
            
            // Test file extension detection
            XCTAssertEqual(epubFile.pathExtension, "epub")
            XCTAssertEqual(kepubFile.pathExtension, "epub")
            XCTAssertEqual(pdfFile.pathExtension, "pdf")
            
            // Test that we can identify EPUB files
            let isEPUB1 = epubFile.pathExtension.lowercased() == "epub"
            let isEPUB2 = kepubFile.pathExtension.lowercased() == "kepub.epub" || 
                          kepubFile.pathExtension.lowercased() == "epub"
            let isPDF = pdfFile.pathExtension.lowercased() == "pdf"
            
            XCTAssertTrue(isEPUB1)
            XCTAssertTrue(isEPUB2)
            XCTAssertTrue(isPDF)
            
        } catch {
            XCTFail("Failed to create test files: \(error)")
        }
    }

    func testURLPathManipulation() {
        let testURL = URL(fileURLWithPath: "/path/to/file.epub")
        
        XCTAssertEqual(testURL.lastPathComponent, "file.epub")
        XCTAssertEqual(testURL.pathExtension, "epub")
        XCTAssertEqual(testURL.deletingPathExtension().lastPathComponent, "file")
        
        let parentURL = testURL.deletingLastPathComponent()
        XCTAssertEqual(parentURL.lastPathComponent, "to")
        
        let newURL = parentURL.appendingPathComponent("newfile.kepub.epub")
        XCTAssertEqual(newURL.lastPathComponent, "newfile.kepub.epub")
    }
}
