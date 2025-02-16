//
//  HomeView.swift
//  WebsiteBlocker
//
//  Created by Shashwat Singh on 15/2/25.
//

import SwiftUI

struct WebsiteBlockerView: View {
    
    @State private var websiteInput: String = ""
    @State private var blockedWebsites: [Website] = [
        Website(url: "facebook.com", isBlocked: true),
        Website(url: "google.com", isBlocked: true)]
    
    var body: some View {
        VStack{
            
            Image(systemName: "globe")
                .font(.largeTitle)
                .foregroundColor(.blue)
                .padding(.top)
            
            HStack{
                TextField("Enter website (e.g. Google.com)",
                          text: $websiteInput)
                .padding(.leading)
                
                Button {
                    
                } label: {
                    Image(systemName: "plus.app.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                .padding(.trailing)
                .buttonStyle(BorderlessButtonStyle())
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
                    .buttonStyle(BorderlessButtonStyle())

                }
            }
            .listStyle(PlainListStyle())
            .padding()
        }
    }
}


struct WebsiteBlockerView_Previews: PreviewProvider {
    static var previews: some View {
        WebsiteBlockerView()
    }
}
