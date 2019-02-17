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
    
    private static var url: String = "https://enlightn.net/verification/check"
    
    static func post(_ body: Any, webURL: Any, completion: @escaping ([Report]? , Error?)->Void){
        Alamofire.request(url, method: HTTPMethod.post, parameters: ["html": body, "url": webURL], encoding: JSONEncoding.default, headers: nil).responseJSON{ response in
      
            print(response.data as Any)
            if let data = response.data {
                if let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                    print("JSON Dict: \(jsonDict ?? ["Empty":"Sorry"])")
                    guard let response = jsonDict?["response"] as? [String: Any] else { return }
                    guard let results = response["results"] as? [[String: Any]] else { return }
                    guard let domain = response["domain"] as? String else { return }
                    let reports = parseResponse(from: results, url: domain)
                    completion(reports, nil)
                }
            }
        }
    }
    //tags, always exist
    //text, always exists
    static func parseResponse(from json: [[String: Any]], url: String) -> [Report]?{
        var reports = [Report]()
        for result in json{
            guard let text = result["text"] as? String else {
                continue
            }
            guard let tags = result["tags"] as? [String] else { print("3"); continue }

            guard let badWebsite = result["bad_website"] as? Bool else { continue }
            guard !badWebsite else {
                let report = Report(badWebsite: badWebsite, moreInfoURL: nil, text: nil, url: url, tags: tags)
                reports.append(report)
                continue
            }
            guard let moreInfo = result["fact_check_url"] as? String else { print("1"); break}
            let report = Report(badWebsite: badWebsite, moreInfoURL: moreInfo, text: text, url: url, tags: tags)
            reports.append(report)
        }
        return reports
    }
}
