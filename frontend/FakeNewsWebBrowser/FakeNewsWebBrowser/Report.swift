//
//  Report.swift
//  FakeNewsWebBrowser
//
//  Created by Jacob Goldfarb on 2019-02-16.
//  Copyright © 2019 Jacob Goldfarb. All rights reserved.
//

import Foundation

class Report {
    
    var description: String
    var text: String
    var url: String
    var tags: [String]
    
    init(description: String?, text: String, url: String, tags: [String]?) {
        self.text = text
        self.url = url
        
        self.description = description != nil ? description! : ""
        self.tags = tags != nil ? tags! : [String]()
    }
}
