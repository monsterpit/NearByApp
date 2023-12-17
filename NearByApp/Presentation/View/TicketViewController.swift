//
//  TicketViewController.swift
//  NearByApp
//
//  Created by Vikas Salian on 16/12/23.
//
import WebKit
import UIKit

class TicketViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var url: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: URL(string: url)!))

    }
    

}
