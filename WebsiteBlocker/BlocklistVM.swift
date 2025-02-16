//
//  BlockedSiteVM.swift
//  WebsiteBlocker
//
//  Created by Shashwat Singh on 15/2/25.
//

import SwiftUI

@MainActor
class BlocklistViewModel: ObservableObject {
    @Published var blockedSites: [Website] = []
    @Published var errorMessage: String?
    
    private let hostService = HostsFileService()

    init() {
        loadBlockedSites()
    }
    
    
    func addWebsite(_ site: String) async {
        do {
            let normalizedSite = try await normalizeAndValidateSite(site)
            guard !hasExistingSite(normalizedSite) else { return }
            
            blockedSites.append(Website(url: normalizedSite, isBlocked: true))
            try await updateHostsFile()
        } catch {
            handleError(error)
        }
    }
    
    
    func removeWebsite(_ site: Website) async {
        blockedSites.removeAll { $0.url.caseInsensitiveCompare(site.url) == .orderedSame }
        do {
            try await updateHostsFile()
        } catch {
            handleError(error)
        }
    }
    
    
    private func loadBlockedSites() {
        do {
            let hostsContent = try hostService.readHostsFile()
            blockedSites = parseBlockedSites(from: hostsContent)
        } catch {
            handleError(error)
        }
    }
    
    
    private func updateHostsFile() async throws {
        try await Task(priority: .userInitiated) {
            try hostService.updateHostsFile(with: blockedSites.map(\.url))
        }.value
    }
    
    
    private func normalizeAndValidateSite(_ site: String) async throws -> String {
        try await Task(priority: .utility) {
            try hostService.normalizeSite(site)
        }.value
    }

    
    private func hasExistingSite(_ domain: String) -> Bool {
        blockedSites.contains { $0.url.caseInsensitiveCompare(domain) == .orderedSame }
    }

    
    private func handleError(_ error: Error) {
        switch error {
        case HostsFileError.permissionDenied:
            errorMessage = "Permission Denied! Try running with admin rights."
        case HostsFileError.invalidHostname(let name):
            errorMessage = "Invalid domain: \(name)"
        case HostsFileError.readFailure:
            errorMessage = "Failed to read the hosts file."
        case HostsFileError.writeFailure:
            errorMessage = "Failed to update the hosts file."
        default:
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
    }
    
    
    private func parseBlockedSites(from content: String) -> [Website] {
        content.components(separatedBy: .newlines)
            .filter { $0.contains("# Blocked by WebsiteBlockerApp") }
            .compactMap { line in
                let parts = line.split(separator: " ")
                guard parts.count >= 2 else { return nil }
                return Website(url: String(parts[1]), isBlocked: true)
            }
    }
}



