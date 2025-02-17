//
//  HostService.swift
//  WebsiteBlocker
//
//  Created by Shashwat Singh on 16/2/25.
//

import Foundation

enum HostsFileError: Error {
    case invalidHostname(String)
    case permissionDenied
    case readFailure
    case writeFailure
    case helperToolNotFound(String)
    case helperToolFailure(String)
}

class HostsFileService {
    private let configFilePath: String
    private let helperToolPath: String
    
    init(helperToolName: String = "WebsiteBlockerHelper") {
        // Get the path for the helper tool within the app bundle
        if let path = Bundle.main.path(forResource: helperToolName, ofType: nil) {
            self.helperToolPath = path
        } else {
            self.helperToolPath = ""
        }
        
        // Temporary config file path for blocklist
        let tempDir = FileManager.default.temporaryDirectory
        self.configFilePath = tempDir.appendingPathComponent("blocklist.json").path
    }
    
    func updateBlockedSites(sites: [String]) throws {
        let normalizedSites = try sites.map { try normalizeSite($0) }
        
        let jsonData = try JSONEncoder().encode(normalizedSites)
        try jsonData.write(to: URL(fileURLWithPath: configFilePath))
        
        try runHelperCommand(["--update", configFilePath])
    }
    
    func removeAllBlocking() throws {
        try runHelperCommand(["--deactivate"])
    }
    
    func flushDNSCache() throws {
        try runHelperCommand(["--flush-all"])
    }
    
    func checkHelperInstallation() -> Bool {
        return FileManager.default.isExecutableFile(atPath: helperToolPath)
    }
    
    func normalizeSite(_ site: String) throws -> String {
        let cleaned = site.trimmingCharacters(in: .whitespaces)
        
        guard isValidHostname(cleaned) else {
            throw HostsFileError.invalidHostname(cleaned)
        }
        
        return cleaned.lowercased()
            .replacingOccurrences(of: "^www\\.", with: "", options: .regularExpression)
    }
    
    private func isValidHostname(_ hostname: String) -> Bool {
        let pattern = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][a-zA-Z0-9-]*[A-Za-z0-9])$"
        return hostname.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func runHelperCommand(_ arguments: [String]) throws {
        if !FileManager.default.isExecutableFile(atPath: helperToolPath) {
            throw HostsFileError.helperToolNotFound("Helper tool not found at \(helperToolPath)")
        }
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus != 0 {
                let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: outputData, encoding: .utf8) ?? "Unknown error"
                throw HostsFileError.helperToolFailure(output)
            }
        } catch let error as HostsFileError {
            throw error
        } catch {
            throw HostsFileError.helperToolFailure("Failed to run helper tool: \(error.localizedDescription)")
        }
    }
}

