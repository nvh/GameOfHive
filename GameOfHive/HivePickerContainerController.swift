//
//  HivePickerContainerController.swift
//  GameOfHive
//
//  Created by Tomas Harkema on 03-04-16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

class HivePickerContainerController: UIViewController {
    @IBOutlet weak var leftOffsetConstraint: NSLayoutConstraint!

    
    weak var hivePickerDelegate: HivePickerDelegate?
    var leftOffset: CGFloat = 120
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        hivePickerDelegate?.contentWillClose(openedViewController: self)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        leftOffsetConstraint.constant = leftOffset + 60
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? HivePickerViewController, segue.identifier == "hivePicker" else {
            return
        }

        destination.delegate = hivePickerDelegate
    }
}
