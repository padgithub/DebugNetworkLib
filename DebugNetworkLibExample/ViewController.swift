//
//  ViewController.swift
//  DebugNetworkLibExample
//
//  Created by Phung Anh Dung on 11/14/20.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: URL(string: "https://google.com")!))
    }


}

