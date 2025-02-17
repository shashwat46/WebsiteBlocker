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
        }
        .frame(minWidth: 400, minHeight: 500)
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

    private func toggleBlockStatus(_ site: Website) {
        Task {
            if site.isBlocked {
                await viewModel.removeWebsite(site)
            } else {
                await viewModel.addWebsite(site.url)
            }
        }
    }
}

// MARK: - Preview
struct WebsiteBlockerView_Previews: PreviewProvider {
    static var previews: some View {
        WebsiteBlockerView()
    }
}
