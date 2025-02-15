//
//  HomeView.swift
//  WebsiteBlocker
//
//  Created by Shashwat Singh on 15/2/25.
//

import SwiftUI

struct HomeView: View {
    
    @State private var websiteInput: String = ""
    @State private var blockedWebsites: [BlockedSite] = [
        BlockedSite(url: "facebook.com", isEnabled: true),
        BlockedSite(url: "google.com", isEnabled: true)]
    
    var body: some View {
        VStack{
            
            Image(systemName: "globe")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            HStack{
                TextField("Enter website (e.g. Google.com",
                          text: $websiteInput)
                .padding()
                Button {
                    
                } label: {
                    Image(systemName: "plus.app.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                .padding()
            }
            .padding(.top)
            
            List(blockedWebsites) { site in
                HStack {
                    Text(site.url)
                    
                    Spacer()
                    
                    Toggle("",isOn: .constant(true))
                        .labelsHidden()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }

                }
            }
            .listStyle(PlainListStyle())
            .padding()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
