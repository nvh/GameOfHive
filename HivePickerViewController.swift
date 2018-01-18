//
//  HivePickerViewController.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

class HivePickerCell: UICollectionViewCell {
    static let reuseIdentifier = "HivePickerCell"
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var dateLabel: UILabel?
    
    override func awakeFromNib() {
        dateLabel?.textColor = UIColor.lightAmberColor
    }
}

protocol HivePickerDelegate: SubMenuDelegate  {
    func didSelectHive(hive: Hive)
}

class HivePickerViewController: UICollectionViewController {
    
    var dataSource: HiveDataSource!
    weak var delegate: HivePickerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView!.backgroundColor = UIColor.backgroundColor
        collectionView!.layer.borderColor = UIColor.darkAmberColor.cgColor
        collectionView!.layer.borderWidth = 1
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.refresh()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSections
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(dataSource.numberOfHives(inSection: section))
        return dataSource.numberOfHives(inSection: section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HivePickerCell.reuseIdentifier, for: indexPath as IndexPath) as? HivePickerCell,
            let hive = dataSource.hive(atIndexPath: indexPath) else {
                return UICollectionViewCell()
        }
        
        cell.imageView?.image = hive.image
        let dateFormat = DateFormatter.init()
        dateFormat.dateStyle = DateFormatter.Style.short
        dateFormat.timeStyle = DateFormatter.Style.medium
        cell.dateLabel?.text = hive.title
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt  indexPath: IndexPath) {
        guard let hive = dataSource.hive(atIndexPath: indexPath) else {
            return
        }
        delegate?.didSelectHive(hive: hive)
        dismiss(animated: true, completion: nil)
    }
}
