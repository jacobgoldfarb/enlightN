
//
//  VerificationViewController.swift
//  FakeNewsWebBrowser
//
//  Created by Jacob Goldfarb on 2019-02-16.
//  Copyright © 2019 Jacob Goldfarb. All rights reserved.
//

import UIKit

class VerificationViewController: UIViewController {

    @IBOutlet var backgroundView: UIView!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var reportCollectionView: UICollectionView!
    
    var reports = [Report]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reportCollectionView.delegate = self
        reportCollectionView.dataSource = self
        doneButton.layer.cornerRadius = doneButton.frame.height/2.5
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.layer.masksToBounds = true

        backgroundView.addSubview(blurEffectView)
            
        backgroundView.layer.cornerRadius = 20
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func pressedDone(_ sender: Any) {
        guard let rootVC = presentingViewController as? ViewController else { return }
        dismiss(animated: true){
           rootVC.resetReportButton()
        }
        
    }
    @objc func soughtMoreInfo(_ sender: Any){
        
        guard let rootVC = presentingViewController as? ViewController, let button = sender as? Button, let moreInfoURL = button.url else { return }
        dismiss(animated: true){
            rootVC.route(to: moreInfoURL)
        }
    }
}
extension VerificationViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reports.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reportCell", for: indexPath) as! ReportCollectionViewCell

        let report = reports[indexPath.item]
//        let tagsStrings = report.tags.joined(separator: ", ") // "1-2-3"
        
        let tagStrings  = report.tags.joined(separator: ", ")
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)]
        let attributedString = NSMutableAttributedString(string:tagStrings, attributes:attrs)
        

        if(report.badWebsite){
            cell.reportDescription.text = "The website \(report.url) has been tagged \(tagStrings)"
        }else{
            
            let normalText = "The text \"\(report.text ?? "")\" from \(report.url) has been tagged "
            let normalString = NSMutableAttributedString(string:normalText)
            normalString.append(attributedString)

            cell.reportDescription.attributedText = normalString
            if let moreInfo = report.moreInfo{
                let moreInfoButton = Button(frame: CGRect(x: 10, y: cell.frame.height - 55, width: 140, height: 35), url: moreInfo)
                moreInfoButton.center.x = cell.center.x - 15
                moreInfoButton.layer.cornerRadius = moreInfoButton.frame.height / 2
                moreInfoButton.backgroundColor = UIColor(named: "urlBarColour")
                moreInfoButton.tintColor = .white
                moreInfoButton.setTitle("Learn More", for: .normal)
                moreInfoButton.addTarget(self, action: #selector(soughtMoreInfo(_:)), for: .touchUpInside)
                print("-----")
//                print("More info link: \(more)")
                cell.addSubview(moreInfoButton)
            }
        }

        return cell
    }
    
    
}
class Button: UIButton{
    var url: String?
    init(frame: CGRect, url: String) {
        super.init(frame: frame)
        self.url = url
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.url = nil
    }
}
