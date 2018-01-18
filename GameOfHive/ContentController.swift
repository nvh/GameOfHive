//
//  ContentController.swift
//  GameOfHive
//
//  Created by Tomas Harkema on 03-04-16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit
import WebKit


class ContentViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet fileprivate weak var leftOffsetConstraint: NSLayoutConstraint!
    var leftOffset: CGFloat = 120

    let webView = WKWebView()

    weak var delegate: SubMenuDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = UIColor.backgroundColor
        webView.isOpaque = false
        webView.navigationDelegate = self
        webViewContainer.addSubview(webView)
        webView.constrainToView(webViewContainer, margin: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        leftOffsetConstraint.constant = leftOffset + 60

        webViewContainer.alpha = 0

        UIView.animate(withDuration: 0.3, animations: { 
            self.webViewContainer.alpha = 1.0
        }) 

        webView.layer.backgroundColor = UIColor.backgroundColor.cgColor
        webView.layer.borderColor = UIColor.darkAmberColor.cgColor
        webView.layer.borderWidth = 1
    }

    @IBAction func dismissButtonPressed(_ sender: AnyObject) {
        delegate?.contentWillClose(openedViewController: self)
        dismiss(animated: true, completion: nil)
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.landscapeLeft,.landscapeRight]
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url, url.host != "nvh.github.io" {
            decisionHandler(.cancel)
            UIApplication.shared.openURL(url)
        } else {
            decisionHandler(.allow)
        }
    }
}
