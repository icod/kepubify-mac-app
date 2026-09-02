//
//  ContentView.swift
//  KepubifyMacApp
//
//  Created by Vibe Code
//

import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct ContentView: View {
    @EnvironmentObject var manager: KepubifyManager
    
    @State private var inputFiles: [URL] = []
    @State private var outputDirectory: URL?
    @State private var showFileImporter = false
    @State private var showFolderImporter = false
    @State private var showOutputFolderPicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Kepubify options
    @State private var options = KepubifyOptions()
    @State private var kepubifyVersion: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                headerView
                
                Divider()
                
                // Input Section
                inputSection
                
                Divider()
                
                // Output Section
                outputSection
                
                Divider()
                
                // Conversion Options
                optionsSection
                
                Divider()
                
                // Log Output
                logSection
                
                // Convert Button
                convertButton
            }
            .padding()
            .navigationTitle("Kepubify")
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.data],
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result: result)
            }
            .fileImporter(
                isPresented: $showFolderImporter,
                allowedContentTypes: [.folder],
                allowsMultipleSelection: false
            ) { result in
                handleFolderImport(result: result)
            }
            .onAppear {
                checkKepubify()
            }
            .alert("Info", isPresented: $showAlert) {
                Button("OK") { showAlert = false }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Views
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Kepubify macOS App")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let version = kepubifyVersion {
                    Text("Kepubify Version: \(version)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Kepubify not found")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            Image(systemName: "book.closed.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
        }
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Input Files")
                .font(.headline)
            
            HStack {
                Button(action: { showFileImporter = true }) {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                        Text("Add Files")
                    }
                }
                
                Button(action: { showFolderImporter = true }) {
                    HStack {
                        Image(systemName: "folder.badge.plus")
                        Text("Add Folder")
                    }
                }
                
                Button(action: { inputFiles.removeAll() }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear")
                    }
                }
                .disabled(inputFiles.isEmpty)
                .foregroundColor(inputFiles.isEmpty ? .gray : .red)
            }
            
            if !inputFiles.isEmpty {
                List(inputFiles, id: \.self, selection: .constant(nil as URL?)) { url in
                    HStack {
                        Image(systemName: "doc.fill")
                            .foregroundColor(.blue)
                        Text(url.lastPathComponent)
                            .font(.caption)
                        Spacer()
                    }
                }
                .frame(maxHeight: 150)
                .listStyle(.plain)
            } else {
                Text("No files selected")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
    
    private var outputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Output")
                .font(.headline)
            
            HStack {
                Button(action: { showOutputFolderPicker = true }) {
                    HStack {
                        Image(systemName: "folder")
                        Text(outputDirectory?.lastPathComponent ?? "Select Output Folder")
                    }
                }
                
                Toggle("In-place conversion", isOn: $options.inPlace)
                    .help("Don't add _converted suffix to output files")
            }
            
            Toggle("Update existing", isOn: $options.update)
                .help("Skip files that have already been converted")
            
            Toggle("No preserve dirs", isOn: $options.noPreserveDirs)
                .help("Flatten directory structure in output")
            
            Toggle("Calibre compatible", isOn: $options.calibre)
                .help("Use .kepub extension instead of .kepub.epub")
        }
    }
    
    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Conversion Options")
                .font(.headline)
            
            // Text processing options
            VStack(alignment: .leading, spacing: 8) {
                Text("Text Processing")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Toggle("Smarten punctuation", isOn: $options.smartenPunctuation)
                    .help("Convert straight quotes to smart quotes, etc.")
                
                HStack {
                    Text("Hyphenation:")
                    Picker("", selection: Binding(
                        get: { options.hyphenate ?? false ? "enabled" : options.hyphenate == false ? "disabled" : "default" },
                        set: { newValue in
                            switch newValue {
                            case "enabled": options.hyphenate = true
                            case "disabled": options.hyphenate = false
                            default: options.hyphenate = nil
                            }
                        }
                    )) {
                        Text("Default").tag("default")
                        Text("Enabled").tag("enabled")
                        Text("Disabled").tag("disabled")
                    }
                    .pickerStyle(.segmented)
                }
                
                Toggle("Fullscreen reading fixes", isOn: $options.fullscreenReadingFixes)
                    .help("Apply fixes for fullscreen reading bugs")
            }
            
            // Advanced options
            VStack(alignment: .leading, spacing: 8) {
                Text("Advanced")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text("Charset:")
                    TextField("utf-8", text: $options.charset)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                }
                
                HStack {
                    Text("Copy extensions:")
                    TextField("e.g. .pdf .jpg", text: Binding(
                        get: { options.copyExtensions.joined(separator: " ") },
                        set: { newValue in
                            options.copyExtensions = newValue.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                        }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading) {
                    Text("Find & Replace Rules:")
                    ForEach(0..<options.replaceRules.count, id: \.self) { index in
                        HStack {
                            TextField("find|replace", text: $options.replaceRules[index])
                                .textFieldStyle(.roundedBorder)
                            Button(action: { options.replaceRules.remove(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    Button(action: { options.replaceRules.append("") }) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Rule")
                    }
                }
            }
            
            // Verbose option
            Toggle("Verbose output", isOn: $options.verbose)
        }
    }
    
    private var logSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Log Output")
                .font(.headline)
            
            ScrollView {
                Text(manager.logOutput)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 150)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            if manager.status == .converting {
                ProgressView(value: manager.progress)
            }
        }
    }
    
    private var convertButton: some View {
        HStack {
            Spacer()
            
            Button(action: startConversion) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Convert")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(inputFiles.isEmpty || manager.status == .converting)
            
            Spacer()
        }
    }
    
    // MARK: - Actions
    
    private func checkKepubify() {
        manager.getKepubifyVersion { version in
            DispatchQueue.main.async {
                self.kepubifyVersion = version
            }
        }
    }
    
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            // Filter for EPUB files
            let epubFiles = urls.filter { url in
                let ext = url.pathExtension.lowercased()
                return ext == "epub" || ext == "kepub" || ext == "kepub.epub"
            }
            
            if epubFiles.isEmpty {
                alertMessage = "No EPUB files found in selection"
                showAlert = true
            } else {
                inputFiles.append(contentsOf: epubFiles)
            }
        case .failure(let error):
            alertMessage = "Error importing files: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func handleFolderImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let folder = urls.first {
                // Find all EPUB files in the folder
                let epubFiles = findEPUBFiles(in: folder)
                if epubFiles.isEmpty {
                    alertMessage = "No EPUB files found in folder"
                    showAlert = true
                } else {
                    inputFiles.append(contentsOf: epubFiles)
                }
            }
        case .failure(let error):
            alertMessage = "Error importing folder: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func findEPUBFiles(in directory: URL) -> [URL] {
        var epubFiles: [URL] = []
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            
            for url in contents {
                if url.pathExtension.lowercased() == "epub" || 
                   url.pathExtension.lowercased() == "kepub" ||
                   url.pathExtension.lowercased() == "kepub.epub" {
                    epubFiles.append(url)
                } else if url.hasDirectoryPath {
                    // Recursively search subdirectories
                    epubFiles.append(contentsOf: findEPUBFiles(in: url))
                }
            }
        } catch {
            print("Error reading directory: \(error)")
        }
        
        return epubFiles
    }
    
    private func startConversion() {
        // Set output directory if in-place is not selected
        var options = options
        if !options.inPlace, outputDirectory == nil {
            // Default to Documents/KepubifyOutput
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let outputURL = documents?.appendingPathComponent("KepubifyOutput")
            
            do {
                if let outputURL = outputURL {
                    try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
                    options.outputDirectory = outputURL
                }
            } catch {
                alertMessage = "Failed to create output directory: \(error.localizedDescription)"
                showAlert = true
                return
            }
        } else if let outputDir = outputDirectory {
            options.outputDirectory = outputDir
        }
        
        manager.convertFiles(at: inputFiles, options: options) { result in
            Task { @MainActor in
                if result.success {
                    alertMessage = "Conversion completed! Output: \(result.outputPath ?? "")"
                } else {
                    alertMessage = result.message ?? "Conversion failed"
                }
                showAlert = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(KepubifyManager())
    }
}
