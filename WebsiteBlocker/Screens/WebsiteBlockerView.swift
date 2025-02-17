//
//  HomeView.swift
//  WebsiteBlocker
//
//  Created by Shashwat Singh on 15/2/25.
//

import SwiftUI

struct WebsiteBlockerView: View {
    
    @StateObject private var viewModel = BlocklistViewModel()
    @State private var websiteInput: String = ""

    var body: some View {
        VStack {
            if !viewModel.helperToolInstalled {
                HelperToolMissingView()
            } else {
                mainContent
            }
        }
        .frame(minWidth: 400, minHeight: 500)
    }
    
    private var mainContent: some View {
        VStack {
            Image(systemName: "globe")
                .font(.largeTitle)
                .foregroundColor(.blue)
                .padding(.top)
            
            HStack {
                TextField("Enter website (e.g. google.com)", text: $websiteInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)
                
                Button(action: addWebsite) {
                    Image(systemName: "plus.app.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                .padding(.trailing)
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding()
            
            BlocklistView(
                blockedSites: $viewModel.blockedSites,
                removeWebsite: removeWebsite
            )
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            HStack {
                Button("Flush DNS Cache") {
                    Task {
                        await viewModel.flushDNSCache()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Remove All Blocking") {
                    Task {
                        await viewModel.removeAllBlocking()
                    }
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
            .padding()
        }
    }
    
    private func addWebsite() {
        Task {
            await viewModel.addWebsite(websiteInput)
            websiteInput = ""
        }
    }
    
    private func removeWebsite(_ site: Website) {
        Task {
            await viewModel.removeWebsite(site)
        }
    }
}

struct HelperToolMissingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
                .padding()
            
            Text("Helper Tool Missing")
                .font(.title)
                .fontWeight(.bold)
            
            Text("The WebsiteBlockerHelper tool is not installed or not found at /usr/local/bin/WebsiteBlockerHelper.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Install Helper Tool") {
                installHelperTool()
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            Text("Click the button above to install the helper tool automatically.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.black))
    }
    
    private func installHelperTool() {
        let script = """
        tell application "Terminal"
            activate
            do script "echo 'Installing Helper Tool...'; \
            sudo cp /path/to/helper /usr/local/bin/WebsiteBlockerHelper; \
            sudo chmod +x /usr/local/bin/WebsiteBlockerHelper; \
            sudo chown root:wheel /usr/local/bin/WebsiteBlockerHelper"
            activate
        end tell
        """

        let process = Process()
        process.launchPath = "/usr/bin/osascript"
        process.arguments = ["-e", script]
        process.launch()
    }
}


// MARK: - Preview
struct WebsiteBlockerView_Previews: PreviewProvider {
    static var previews: some View {
        WebsiteBlockerView()
    }
}
