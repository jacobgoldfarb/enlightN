//
//  ViewController.swift
//  FakeNewsWebBrowser
//
//  Created by Jacob Goldfarb on 2019-02-16.
//  Copyright © 2019 Jacob Goldfarb. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class ViewController: UIViewController {
    
    var webview: WKWebView!
    @IBOutlet var urlBar: UITextField!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    @IBOutlet var verificationButton: UIButton!
    
    @IBOutlet var logoTitle: UILabel!
    @IBOutlet var tagline: UILabel!
    @IBOutlet var instructionTag: UILabel!
    @IBOutlet var instructions: UILabel!
    
    private var reports = [Report]()
    var initialEdit = true
    
    let javascript: String = {
        guard let scriptPath = Bundle.main.path(forResource: "script", ofType: "js"),
            let scriptSource = try? String(contentsOfFile: scriptPath) else { return "" }
        return scriptSource
    }()
    var contentController = WKUserContentController();
    var fakeNewsFound = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlBar.delegate = self
        let contentController = WKUserContentController();
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webview = WKWebView(frame: CGRect(x: 0, y: 70, width: view.frame.width, height: view.frame.height - 130), configuration: config)
        view.addSubview(webview)
        
        styleUI()

        webview.navigationDelegate = self
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Did appear")
        resetReportButton()
    }

    func styleUI(){
        urlBar.backgroundColor = UIColor(named: "urlBarColour")
        backButton.backgroundColor = UIColor(named: "urlBarColour")
        forwardButton.backgroundColor = UIColor(named: "urlBarColour")
        
        urlBar.layer.cornerRadius = urlBar.frame.height / 2
        backButton.layer.cornerRadius = backButton.frame.height / 2
        forwardButton.layer.cornerRadius = forwardButton.frame.height / 2
        
        forwardButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 13, bottom: 10, right: 10)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 13)

        
        verificationButton.layer.cornerRadius = verificationButton.frame.height/2.5
        webview.isOpaque = false
        
    }
    func route(to urlString: String){
        print("URL string: \(urlString)")
        urlBar.text = urlString
        
        goToURL(self)
    }
    @IBAction func goToURL(_ sender: Any) {
        
        reports = []
        resetReportButton()
        urlBar.resignFirstResponder()
        guard let urlText = urlBar.text else { return }
        print("pressed go")
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
        
        if !urlText.contains("https://"){
            print("Doesn't contain...")
            let urlStr = "https://www.\(urlBar.text ?? "")"
            guard verifyUrl(urlString: urlStr) else {
                print("Invalid URL")
                return
            }
            let url = URL(string: urlStr)
            webview.load(URLRequest(url: url!))
        }
        else{
            print("Load.....")
            webview.load(URLRequest(url: URL(string: urlText)!))
        }
        logoTitle.isHidden = true
        tagline.isHidden = true
        instructionTag.isHidden = true
        instructions.isHidden = true
    }
    func fakeNewsDetected(){
        fakeNewsFound = true
        UIView.animate(withDuration: 1.0, delay: 0, options: .transitionCrossDissolve, animations: {
            self.verificationButton.layer.backgroundColor = UIColor(named: "danger")?.cgColor
        }, completion: nil)
        UIView.transition(with: verificationButton, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.verificationButton.setTitle("!", for: .normal)
        }, completion: nil)
    }
    func resetReportButton(){
        self.fakeNewsFound = false
        UIView.animate(withDuration: 1.0, delay: 0, options: .transitionCrossDissolve, animations: {
            self.verificationButton.layer.backgroundColor = UIColor(named: "okay")?.cgColor
        }, completion: nil)
        UIView.transition(with: self.verificationButton, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.verificationButton.setTitle("", for: .normal)
        }, completion: nil)
    
    }
    @IBAction func goBack(_ sender: Any) {
        reports = []
        fakeNewsFound = false
        webview.goBack()
    }
    @IBAction func goForwards(_ sender: Any) {
      
        webview.goForward()
    }
    @IBAction func showNewsAnalyzer(_ sender: Any) {
        guard fakeNewsFound else { return }
        let viewController: VerificationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "verificationVC") as! VerificationViewController
        viewController.reports = reports
        viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

        present(viewController, animated: true, completion: nil)
    }
    
    
}
extension ViewController: WKNavigationDelegate, UITextFieldDelegate, WKUIDelegate{
    
    //MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView,
                 didCommit navigation: WKNavigation!){
        
        urlBar.text = webView.url?.absoluteString
    
        guard let url = webview.url else { return }
        Alamofire.request(url).responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                NewsVerifier.post(html, webURL: url.absoluteString, completion: { (reports, error) in
                    guard let reports = reports, !reports.isEmpty else {
                        return
                    }
                    self.reports = reports
                    self.fakeNewsDetected()
                })
            }
        }
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        urlBar.text = webView.url?.absoluteString
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        urlBar.text = webView.url?.absoluteString
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard initialEdit else {return}
        UIView.transition(with: logoTitle, duration: 2.5, options: .transitionCrossDissolve, animations: {
            self.logoTitle.textColor = .clear
        }, completion: nil)
        UIView.transition(with: tagline, duration: 2.5, options: .transitionCrossDissolve, animations: {
            self.tagline.textColor = .clear
        }, completion: nil)
        UIView.transition(with: instructionTag, duration: 2.5, options: .transitionCrossDissolve, animations: {
            self.instructionTag.textColor = .clear
        }, completion: nil)
        UIView.transition(with: instructions, duration: 2.5, options: .transitionCrossDissolve, animations: {
            self.instructions.textColor = .clear
        }, completion: nil)
        
        initialEdit = false
        
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
extension ViewController{
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
}
