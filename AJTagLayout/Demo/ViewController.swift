//
//  ViewController.swift
//  AJTagLayout
//
//  Created by 张龙 on 2020/8/27.
//  Copyright © 2020 Amiee. All rights reserved.
//

import UIKit
import os.log

class ViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var segment: UISegmentedControl!
    private var layout: AJTagLayout!
    
    private let tagsBase = ["Tech", "Design", "Humor", "Travel", "Music", "Writing", "Social Media", "Life", "Education", "Edtech", "Education Reform", "Photography", "Startup", "Poetry", "Women In Tech", "Female Founders", "Business", "Fiction", "Love", "Food", "Sports", "Long Long Long Text", "Long Long Long Long Long Text", "Long Long Long Long Long Text", "Long Long Long Long Long Long Long Text", "Long Long Long Long Long Long Long Long Text", "Long Long Long Long Long Long Long Long Long Text", "Long Long Long Long Long Long Long Long Long Text", "Long Long Long Long Long Long Long Long Long Text", "Long Long Long Long Long Long Long Long Long Text"]
    private lazy var tags: [String] = {
        tagsBase
    }()
    private lazy var sizingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    private let log = OSLog(subsystem: "me.amiee.AJTagLayout", category: "UI")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout = collectionView.collectionViewLayout as? AJTagLayout
        layout.horizontalAlignment = .leading
        layout.fillIgnoreFirst = false
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        collectionView.reloadData()
    }
    
    @IBAction func changeHorizontalAlignment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            layout.horizontalAlignment = .leading
        case 1:
            layout.horizontalAlignment = .center
        case 2:
            layout.horizontalAlignment = .trailing
        case 3:
            layout.horizontalAlignment = .justified
        case 4:
            layout.horizontalAlignment = .fill
        default:
            layout.horizontalAlignment = .leading
        }
        
        let bounceEnabled = true
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: bounceEnabled ? 0.7 : 1, initialSpringVelocity: bounceEnabled ? 1 : 0, options: [], animations: {
            self.layout.invalidateLayout()
            self.collectionView.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func changeVerticalAlignment(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction func shuffleTags(_ sender: UIBarButtonItem) {
        tags.shuffle()
        collectionView.performBatchUpdates({
            self.collectionView.reloadSections([0])
        }, completion: nil)
    }
    
    @IBAction func addTag(_ sender: UIBarButtonItem) {
        let index = randomIndex()
        NSLog("addTag:\(index)")
        tags.insert(randomTag(), at: index)
        collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
    }
    
    @IBAction func removeTag(_ sender: UIBarButtonItem) {
        guard tags.count > 0 else {
            return
        }
        let index = randomIndex()
        NSLog("removeTag:\(index)")
        tags.remove(at: index)
        collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
    
    private func randomIndex() -> Int {
        if tags.count == 0 {
            return 0
        }
        return Int.random(in: 0..<min(tags.count, 20))
    }
    
    private func randomTag() -> String {
        let index = randomIndex()
        return tagsBase[index]
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        sizingLabel.text = tags[indexPath.item]
        let labelSize = sizingLabel.systemLayoutSizeFitting(CGSize(width: collectionView.bounds.width - 16 - 16 - 16, height: 999))
        return CGSize(width: ceil(labelSize.width + 16), height: ceil(labelSize.height + 16))
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath as IndexPath) as! TagCollectionViewCell
//        cell.tagName = tags[indexPath.item]
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        os_log("didSelectItemAt:%d-%d", log: log, type: .debug, indexPath.section, indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let tagCell = cell as! TagCollectionViewCell
        tagCell.tagName = tags[indexPath.item]
    }
}
