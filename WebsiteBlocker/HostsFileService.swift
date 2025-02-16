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
}

class HostsFileService {
    private let hostsFilePath: String
    private let blockMarker = "# Blocked by WebsiteBlockerApp"
    
    init(hostsFilePath: String = Constants.hostsFilePath) {
        self.hostsFilePath = hostsFilePath
    }
    
    func readHostsFile() throws -> String {
        do {
            return try String(contentsOfFile: hostsFilePath, encoding: .utf8)
        }
        catch {
            throw HostsFileError.readFailure
        }
    }
    

    func updateHostsFile(with blockedSites: [String]) throws {
        var hostsContent = try readHostsFile()
        

        let filteredLines = hostsContent
            .components(separatedBy: .newlines)
            .filter { !$0.contains(blockMarker) }
        

        hostsContent = filteredLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        

        var newEntries = [String]()
        for site in blockedSites {
            let normalized = try normalizeSite(site)
            newEntries.append("127.0.0.1 \(normalized) \(blockMarker)")
            newEntries.append("127.0.0.1 www.\(normalized) \(blockMarker)")
        }
        
        
        if !newEntries.isEmpty {
            if !hostsContent.isEmpty {
                hostsContent += "\n"
            }
            hostsContent += newEntries.joined(separator: "\n")
        }
        
        try writeHostsFile(content: hostsContent)
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
        let pattern = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9])$"
        return hostname.range(of: pattern, options: .regularExpression) != nil
    }
    

    private func writeHostsFile(content: String) throws {
        do {
            try content.write(toFile: hostsFilePath, atomically: true, encoding: .utf8)
            
        }
        catch {
            throw HostsFileError.writeFailure
        }
    }
}
