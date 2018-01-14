//
//  TemplateViewController.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 03/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

class TemplateCell: UICollectionViewCell {
    static let reuseIdentifier = "TemplateCell"
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var dateLabel: UILabel?
    
    override func awakeFromNib() {
        dateLabel?.textColor = UIColor.lightAmberColor
    }
}

protocol TemplatePickerDelegate: class, SubMenuDelegate  {
    func didSelectTemplate(template: Template)
}

class TemplateViewController: UICollectionViewController {
    
    let dataSource = TemplateDataSource()
    weak var delegate: TemplatePickerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource.refresh()
        collectionView!.backgroundColor = UIColor.backgroundColor
        collectionView!.layer.borderColor = UIColor.darkAmberColor.cgColor
        collectionView!.layer.borderWidth = 1
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSections
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(dataSource.numberOfTemplates(inSection: section))
        return dataSource.numberOfTemplates(inSection: section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateCell.reuseIdentifier, for: indexPath as IndexPath) as? TemplateCell,
            let template = dataSource.template(atIndexPath: indexPath) else {
                return UICollectionViewCell()
        }
        
        cell.imageView?.image = template.image
        let dateFormat = DateFormatter.init()
        dateFormat.dateStyle = DateFormatter.Style.short
        dateFormat.timeStyle = DateFormatter.Style.medium
        cell.dateLabel?.text = dateFormat.string(from: template.date)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt  indexPath: IndexPath) {
        guard let template = dataSource.template(atIndexPath: indexPath) else {
            return
        }
        delegate?.didSelectTemplate(template: template)
        dismiss(animated: true, completion: nil)
    }
}
