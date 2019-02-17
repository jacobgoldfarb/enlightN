//
//  Report.swift
//  FakeNewsWebBrowser
//
//  Created by Jacob Goldfarb on 2019-02-16.
//  Copyright © 2019 Jacob Goldfarb. All rights reserved.
//

import Foundation

class Report {
    
    var moreInfo: String?
    var text: String?
    var url: String
    var badWebsite: Bool
    var tags: [String]
    
    init(badWebsite: Bool, moreInfoURL: String?, text: String?, url: String, tags: [String]?) {
        self.badWebsite = badWebsite
        self.text = text
        self.url = url
        self.moreInfo = moreInfoURL
        self.tags = tags != nil ? tags! : [String]()
    }
}
