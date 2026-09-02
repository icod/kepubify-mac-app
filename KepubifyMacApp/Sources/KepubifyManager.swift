//
//  KepubifyManager.swift
//  KepubifyMacApp
//
//  Created by Vibe Code
//

import Foundation
import Combine

enum ConversionStatus: String {
    case idle
    case converting
    case completed
    case failed
}

struct ConversionResult {
    let success: Bool
    let message: String
    let outputPath: String?
}

struct KepubifyOptions {
    var outputDirectory: URL?
    var inPlace: Bool = false
    var update: Bool = false
    var noPreserveDirs: Bool = false
    var calibre: Bool = false
    var copyExtensions: [String] = []
    var smartenPunctuation: Bool = false
    var hyphenate: Bool? = nil
    var fullscreenReadingFixes: Bool = false
    var replaceRules: [String] = []
    var charset: String = "utf-8"
    var verbose: Bool = false
}

class KepubifyManager: ObservableObject {
    @Published var status: ConversionStatus = .idle
    @Published var progress: Double = 0.0
    @Published var logOutput: String = ""
    @Published var lastResult: ConversionResult?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Check if kepubify is available
    func checkKepubifyAvailable() -> Bool {
        let whichTask = Process()
        let pipe = Pipe()
        
        whichTask.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        whichTask.arguments = ["kepubify"]
        whichTask.standardOutput = pipe
        
        do {
            try whichTask.run()
            whichTask.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            return !output?.isEmpty ?? false
        } catch {
            return false
        }
    }
    
    // Find kepubify in common locations
    func findKepubifyPath() -> URL? {
        let paths = [
            URL(fileURLWithPath: "/usr/local/bin/kepubify"),
            URL(fileURLWithPath: "/opt/homebrew/bin/kepubify"),
            URL(fileURLWithPath: "/usr/bin/kepubify")
        ]
        
        for path in paths {
            if FileManager.default.fileExists(atPath: path.path) {
                return path
            }
        }
        
        return nil
    }
    
    // Convert EPUB files
    func convertFiles(at urls: [URL], options: KepubifyOptions, completion: @escaping (ConversionResult) -> Void) {
        guard !urls.isEmpty else {
            completion(ConversionResult(success: false, message: "No files selected", outputPath: nil))
            return
        }
        
        guard let kepubifyPath = findKepubifyPath() else {
            completion(ConversionResult(success: false, message: "Kepubify not found. Install with: brew install kepubify", outputPath: nil))
            return
        }
        
        DispatchQueue.main.async {
            self.status = .converting
            self.progress = 0.0
            self.logOutput = "Starting conversion...\n"
        }
        
        // Build arguments
        var arguments: [String] = []
        
        if options.verbose {
            arguments.append("--verbose")
        }
        if options.inPlace {
            arguments.append("--inplace")
        }
        if options.update {
            arguments.append("--update")
        }
        if options.noPreserveDirs {
            arguments.append("--no-preserve-dirs")
        }
        if options.calibre {
            arguments.append("--calibre")
        }
        if options.smartenPunctuation {
            arguments.append("--smarten-punctuation")
        }
        if let hyphenate = options.hyphenate {
            arguments.append(hyphenate ? "--hyphenate" : "--no-hyphenate")
        }
        if options.fullscreenReadingFixes {
            arguments.append("--fullscreen-reading-fixes")
        }
        if !options.copyExtensions.isEmpty {
            for ext in options.copyExtensions {
                arguments.append("--copy")
                arguments.append(ext)
            }
        }
        if !options.replaceRules.isEmpty {
            for rule in options.replaceRules {
                arguments.append("--replace")
                arguments.append(rule)
            }
        }
        if options.charset != "utf-8" {
            arguments.append("--charset")
            arguments.append(options.charset)
        }
        if let outputDir = options.outputDirectory {
            arguments.append("--output")
            arguments.append(outputDir.path)
        }
        
        // Add input files
        for url in urls {
            arguments.append(url.path)
        }
        
        // Execute kepubify
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.executableURL = kepubifyPath
        task.arguments = arguments
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            
            // Read output asynchronously
            let outputHandle = outputPipe.fileHandleForReading
            let errorHandle = errorPipe.fileHandleForReading
            
            outputHandle.readabilityHandler = { handle in
                let data = handle.readDataToEndOfFile()
                if !data.isEmpty {
                    let output = String(data: data, encoding: .utf8) ?? ""
                    DispatchQueue.main.async {
                        self.logOutput += output
                    }
                }
            }
            
            errorHandle.readabilityHandler = { handle in
                let data = handle.readDataToEndOfFile()
                if !data.isEmpty {
                    let error = String(data: data, encoding: .utf8) ?? ""
                    DispatchQueue.main.async {
                        self.logOutput += "ERROR: " + error
                    }
                }
            }
            
            // Wait for completion
            task.terminationHandler = { _ in
                outputHandle.readabilityHandler = nil
                errorHandle.readabilityHandler = nil
                
                let exitCode = task.terminationStatus
                
                DispatchQueue.main.async {
                    if exitCode == 0 {
                        self.status = .completed
                        self.progress = 1.0
                        
                        let outputPath = options.outputDirectory?.path ?? 
                            (urls.first?.deletingPathExtension().appendingPathExtension("kepub.epub").path ?? "")
                        
                        completion(ConversionResult(
                            success: true,
                            message: "Conversion completed successfully",
                            outputPath: outputPath
                        ))
                    } else {
                        self.status = .failed
                        completion(ConversionResult(
                            success: false,
                            message: "Conversion failed with exit code: \(exitCode)",
                            outputPath: nil
                        ))
                    }
                    
                    self.lastResult = ConversionResult(
                        success: exitCode == 0,
                        message: exitCode == 0 ? "Conversion completed" : "Conversion failed",
                        outputPath: options.outputDirectory?.path
                    )
                }
            }
            
        } catch {
            DispatchQueue.main.async {
                self.status = .failed
                self.logOutput += "ERROR: Failed to start kepubify: \(error.localizedDescription)\n"
                completion(ConversionResult(
                    success: false,
                    message: "Failed to start kepubify: \(error.localizedDescription)",
                    outputPath: nil
                ))
            }
        }
    }
    
    // Get version of kepubify
    func getKepubifyVersion(completion: @escaping (String?) -> Void) {
        guard let kepubifyPath = findKepubifyPath() else {
            completion(nil)
            return
        }
        
        let task = Process()
        let pipe = Pipe()
        
        task.executableURL = kepubifyPath
        task.arguments = ["--version"]
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            completion(output)
        } catch {
            completion(nil)
        }
    }
}
