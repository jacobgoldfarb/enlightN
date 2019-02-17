//
//  NewsVerifier.swift
//  FakeNewsWebBrowser
//
//  Created by Jacob Goldfarb on 2019-02-16.
//  Copyright © 2019 Jacob Goldfarb. All rights reserved.
//

import Foundation
import Alamofire

class NewsVerifier{
    
    private static var url: String = "https://fact-checkers.appspot.com/verification/check"
    
    static func post(_ body: Any, webURL: Any, completion: @escaping ([Report]? , Error?)->Void){
        Alamofire.request(url, method: HTTPMethod.post, parameters: ["html": body, "url": webURL], encoding: JSONEncoding.default, headers: nil).responseJSON{ response in
      
            print(response.data)
            if let data = response.data, let json = String(data: data, encoding: .utf8) {
                if let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                    print("JSON Dict: \(jsonDict)")
                    guard let response = jsonDict?["response"] as? [String: Any] else { return }
                    guard let results = response["results"] as? [[String: Any]] else { return }
                    guard let domain = response["domain"] as? String else { return }
                    let reports = parseResponse(from: results, url: domain)
                    completion(reports, nil)
                }
            }
        }
    }
    static func parseResponse(from json: [[String: Any]], url: String) -> [Report]?{
        var reports = [Report]()
        for result in json{
            guard let description = result["description"] as? String else { print("1"); break}
            guard let text = result["text"] as? String else { print("2"); break}
            guard let tags = result["tags"] as? [String] else { print("3"); break }
            let report = Report(description: description, text: text, url: url, tags: tags)
            reports.append(report)
        }
        return reports
    }
}
