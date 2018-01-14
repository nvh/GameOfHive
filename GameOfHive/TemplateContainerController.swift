//
//  TemplateContainerController.swift
//  GameOfHive
//
//  Created by Tomas Harkema on 03-04-16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

class TemplateContainerController: UIViewController {
    @IBOutlet weak var leftOffsetConstraint: NSLayoutConstraint!

    
    weak var templateDelegate: TemplatePickerDelegate?
    var leftOffset: CGFloat = 120
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        templateDelegate?.contentWillClose(openedViewController: self)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        leftOffsetConstraint.constant = leftOffset + 60
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? TemplateViewController, segue.identifier == "embedTemplates" else {
            return
        }

        destination.delegate = templateDelegate
    }
}
