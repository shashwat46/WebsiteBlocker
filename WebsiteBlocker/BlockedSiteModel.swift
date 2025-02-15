//
//  BlockedSiteModel.swift
//  WebsiteBlocker
//
//  Created by Shashwat Singh on 15/2/25.
//

import Foundation


struct BlockedSite: Identifiable {
    let id = UUID()
    let url: String
    var isEnabled: Bool
}
