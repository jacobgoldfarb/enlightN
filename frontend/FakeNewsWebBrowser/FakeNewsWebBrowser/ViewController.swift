//
//  ViewController.swift
//  FakeNewsWebBrowser
//
//  Created by Jacob Goldfarb on 2019-02-16.
//  Copyright © 2019 Jacob Goldfarb. All rights reserved.
//

import UIKit
import WebKit
import Kanna
import Alamofire

class ViewController: UIViewController {
    
//    @IBOutlet var webview: WKWebView!
    var webview: WKWebView!
    @IBOutlet var urlBar: UITextField!
    let javascript: String = {
        guard let scriptPath = Bundle.main.path(forResource: "script", ofType: "js"),
            let scriptSource = try? String(contentsOfFile: scriptPath) else { return "" }
        return scriptSource
        
        //        """
//    var array = [];
//    var elements = document.body.getElementsByTagName('*');
//    for(var i = 0; i < elements.length; i++) {
//        var current = elements[i];
//        if(current.children.length === 0 && current.textContent.replace(/ |\n/g,'') !== '') {
//            array.push(current.textContent);
//        }
//    }
//    for(var i = 0; i < array.length; i++) {
//        alert(array[i]);
//    }
//    """
    }()
    var contentController = WKUserContentController();

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleUI()
        
        urlBar.delegate = self
        print("JS: \(javascript)")
        var script = WKUserScript(source: javascript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        let contentController = WKUserContentController();
        contentController.addUserScript(script)
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webview = WKWebView(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.height - 100), configuration: config)
        view.addSubview(webview)
        
        webview.navigationDelegate = self


        
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
        if !urlText.contains("https://www."){
            let url = URL(string: "https://www.\(urlBar.text ?? "")")
            webview.load(URLRequest(url: url!))
        }
        else{
            webview.load(URLRequest(url: URL(string: urlText)!))
        }
        
    }
    @IBAction func goBack(_ sender: Any) {
        webview.goBack()
    }
    @IBAction func goForwards(_ sender: Any) {
        webview.goForward()
    }
    
    
}
extension ViewController: WKNavigationDelegate, UITextFieldDelegate, WKUIDelegate{
    
    //MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView,
                 didCommit navigation: WKNavigation!){

        urlBar.text = webView.url?.absoluteString
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                   completionHandler: { (html: Any?, error: Error?) in
                                    print(html ?? "")
        })
        guard let url = webview.url else { return }
        Alamofire.request(url).responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                print("HTML: \(html)")
            }
        }
        var script = WKUserScript(source: javascript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
      
    }
    //Disables opening of websites in their native apps.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        decisionHandler(WKNavigationActionPolicy(rawValue: WKNavigationActionPolicy.allow.rawValue + 2)!)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  //if desired
        goToURL(webview)
        return true
    }
  
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        print("Received alert");
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let title = NSLocalizedString("OK", comment: "OK Button")
        let ok = UIAlertAction(title: title, style: .default) { (action: UIAlertAction) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        present(alert, animated: true)
        
        completionHandler()
    }
}

