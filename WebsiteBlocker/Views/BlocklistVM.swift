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
    @Published var helperToolInstalled: Bool = false
    
    private let hostService = HostsFileService()

    init() {
        checkHelperTool()
        loadBlockedSites()
    }
    
    private func checkHelperTool() {
        helperToolInstalled = hostService.checkHelperInstallation()
        if !helperToolInstalled {
            errorMessage = "Helper tool not found. Please install it first."
        }
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
        // Since the new service doesn't provide a method to read currently blocked sites,
        // we're starting with an empty list. Users will need to re-add their sites.
        blockedSites = []
    }
    
    private func updateHostsFile() async throws {
        try await Task(priority: .userInitiated) {
            try hostService.updateBlockedSites(sites: blockedSites.map(\.url))
        }.value
    }
    
    func removeAllBlocking() async {
        do {
            try hostService.removeAllBlocking()
            blockedSites.removeAll()
        } catch {
            handleError(error)
        }
    }
    
    func flushDNSCache() async {
        do {
            try hostService.flushDNSCache()
        } catch {
            handleError(error)
        }
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
        case HostsFileError.helperToolNotFound(let message):
            errorMessage = message
        case HostsFileError.helperToolFailure(let message):
            errorMessage = "Helper tool failed: \(message)"
        default:
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }
    }
}


