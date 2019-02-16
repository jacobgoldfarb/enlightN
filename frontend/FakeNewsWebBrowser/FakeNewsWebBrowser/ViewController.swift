//
//  ViewController.swift
//  FakeNewsWebBrowser
//
//  Created by Jacob Goldfarb on 2019-02-16.
//  Copyright © 2019 Jacob Goldfarb. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    @IBOutlet var webview: WKWebView!
    @IBOutlet var urlBar: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleUI()
        
        webview.navigationDelegate = self
        urlBar.delegate = self
    }
    func styleUI(){
        urlBar.backgroundColor = UIColor(named: "urlBarColour")
        urlBar.layer.cornerRadius = urlBar.frame.height / 2
    }
    @IBAction func goToURL(_ sender: Any) {
        
        urlBar.resignFirstResponder()
        guard let urlText = urlBar.text else { return }
        
        guard urlText.contains(".") else{
            let urlArr = urlText.split(separator: " ")
            var searchURL = "https://www.google.com/search?q="
            for word in urlArr{
                searchURL += "\(word)+"
            }
            webview.load(URLRequest(url: URL(string: searchURL)!))
            return
        }
        print("URL Bar text: \(urlBar.text ?? "")")
        let url = URL(string: "https://www.\(urlBar.text ?? "")")
        webview.load(URLRequest(url: url!))
        
    }
    @IBAction func goBack(_ sender: Any) {
        webview.goBack()
    }
    @IBAction func goForwards(_ sender: Any) {
        webview.goForward()
    }
    
    
}
extension ViewController: WKNavigationDelegate, UITextFieldDelegate{
    
    //MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView,
                 didCommit navigation: WKNavigation!){
        print("Here")
        urlBar.text = webView.url?.absoluteString
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                   completionHandler: { (html: Any?, error: Error?) in
                                    print(html ?? "")
        })
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy(rawValue: WKNavigationActionPolicy.allow.rawValue + 2)!)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  //if desired
        goToURL(webview)
        return true
    }

}

