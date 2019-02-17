
//
//  VerificationViewController.swift
//  FakeNewsWebBrowser
//
//  Created by Jacob Goldfarb on 2019-02-16.
//  Copyright © 2019 Jacob Goldfarb. All rights reserved.
//

import UIKit

class VerificationViewController: UIViewController {

    @IBOutlet var doneButton: UIButton!
    @IBOutlet var reportCollectionView: UICollectionView!
    
    var reports = [Report]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reportCollectionView.delegate = self
        reportCollectionView.dataSource = self
        doneButton.layer.cornerRadius = doneButton.frame.height/2.5
    }
    
    @IBAction func pressedDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
extension VerificationViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reports.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reportCell", for: indexPath) as! ReportCollectionViewCell

        let report = reports[indexPath.item]
        let tagsStrings = report.tags.joined(separator: ", ") // "1-2-3"

        cell.reportDescription.text = "The text \"\(report.text)\" from \(report.url) has been tagged \(tagsStrings)."
        return cell
    }
    
    
}
