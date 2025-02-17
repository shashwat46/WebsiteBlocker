//
//  BlocklistView.swift
//  WebsiteBlocker
//
//  Created by Shashwat Singh on 16/2/25.
//

import SwiftUI

struct BlocklistView: View {
    
    @Binding var blockedSites: [Website]
    let removeWebsite: (Website) -> Void
    
    var body: some View {
        List {
            ForEach($blockedSites) { $site in
                HStack {
                    Text(site.url)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Toggle("", isOn: $site.isBlocked)
                        .toggleStyle(SwitchToggleStyle())
                    .labelsHidden()
                    
                    Button(action: { removeWebsite(site) }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .listStyle(PlainListStyle())
        .padding()

    }
    
}

