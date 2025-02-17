//
//  BlockedSiteModel.swift
//  WebsiteBlocker
//
//  Created by Shashwat Singh on 15/2/25.
//

import Foundation

struct Website: Identifiable, Equatable, Hashable {
    var id = UUID()
    var url: String
    var isBlocked: Bool
    
    static func == (lhs: Website, rhs: Website) -> Bool {
        return lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

