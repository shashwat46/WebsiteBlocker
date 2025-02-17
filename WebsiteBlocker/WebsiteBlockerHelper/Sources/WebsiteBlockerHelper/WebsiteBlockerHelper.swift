import Foundation

@main
struct WebsiteBlockerHelper {
    static func main() {
        let args = CommandLine.arguments
        guard args.count > 1 else {
            print("Usage: WebsiteBlockerHelper --activate | --update <configPath> | --deactivate | --flush-all")
            exit(1)
        }

        do {
            switch args[1] {
            case "--activate":
                try activateBlocking()
            case "--update":
                guard args.count > 2 else {
                    print("Usage: WebsiteBlockerHelper --update <configPath>")
                    exit(1)
                }
                try updateBlockList(configPath: args[2])
            case "--deactivate":
                try removeBlocking()
            case "--flush-all":
                try flushDNSCache()
                print("✅ Flushed all DNS caches successfully!")
            default:
                print("Invalid command")
                exit(1)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            exit(1)
        }
    }

    static func activateBlocking() throws {
        print("✅ Blocking system activated. Use --update to add sites.")
    }

    static func updateBlockList(configPath: String) throws {
        let expandedPath = (configPath as NSString).expandingTildeInPath
        let fileURL = URL(fileURLWithPath: expandedPath)
        let data = try Data(contentsOf: fileURL)
        let blockedSites = try JSONDecoder().decode([String].self, from: data)

        let formattedEntries = blockedSites.flatMap { site in
            ["127.0.0.1 \(site)", "::1 \(site)", "127.0.0.1 www.\(site)", "::1 www.\(site)"]
        }

        let hostsPath = "/etc/hosts"
        var hostsContent = try String(contentsOfFile: hostsPath, encoding: .utf8)

        // Remove old blocked entries
        if let startRange = hostsContent.range(of: "# BEGIN WEBSITE BLOCKER"),
           let endRange = hostsContent.range(of: "# END WEBSITE BLOCKER") {
            hostsContent.removeSubrange(startRange.lowerBound..<hostsContent.index(after: endRange.upperBound))
        }

        if !formattedEntries.isEmpty {
            let newBlockSection = """
            # BEGIN WEBSITE BLOCKER
            \(formattedEntries.joined(separator: "\n"))
            # END WEBSITE BLOCKER
            """
            hostsContent.append("\n\(newBlockSection)\n")
        }

        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("hosts.tmp").path
        try hostsContent.write(toFile: tempFile, atomically: true, encoding: .utf8)

        try executeShellCommand("sudo mv \(tempFile) \(hostsPath)")
        try executeShellCommand("sudo chmod 644 \(hostsPath)")
        try flushDNSCache()
        print("✅ Website blocking updated successfully!")
    }

    static func removeBlocking() throws {
        let hostsPath = "/etc/hosts"
        var hostsContent = try String(contentsOfFile: hostsPath, encoding: .utf8)

        if let startRange = hostsContent.range(of: "# BEGIN WEBSITE BLOCKER"),
           let endRange = hostsContent.range(of: "# END WEBSITE BLOCKER") {
            hostsContent.removeSubrange(startRange.lowerBound..<hostsContent.index(after: endRange.upperBound))

            let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("hosts.tmp").path
            try hostsContent.write(toFile: tempFile, atomically: true, encoding: .utf8)

            try executeShellCommand("sudo mv \(tempFile) \(hostsPath)")
            try executeShellCommand("sudo chmod 644 \(hostsPath)")
            try flushDNSCache()
            print("✅ Website blocking removed!")
        } else {
            print("ℹ️ No blocked sites found in /etc/hosts.")
        }
    }

    static func executeShellCommand(_ command: String) throws {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardError = pipe
        task.launch()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
            let errorData = pipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "WebsiteBlockerHelper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Command failed: \(command)\n\(errorMessage)"])
        }
    }

    static func flushDNSCache() throws {
        let commands = [
            "sudo killall -HUP mDNSResponder",  // Most common DNS flush
            "sudo dscacheutil -flushcache",    // Older macOS support
            "sudo discoveryutil mdnsflushcache" // macOS Yosemite-specific
        ]

        for command in commands {
            try? executeShellCommand(command)
        }
    }
}

