//
//  WebViewController.swift
//  TrailGuru-ios
//
//  Created by kishlay kishore on 05/03/21.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    // MARK: IBOutlet
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnAccept: DesignableButton!
    
   // MARK: Properties
    public var url = "http://trailguru.jdcomp1.com/privacy-policy"
    public var flag = false
    var titleString = "Privacy Policy"
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
      webView.scrollView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        webView.navigationDelegate = self
        let request = URLRequest(url: URL(string: url)!)
        webView.load(request)
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        self.navigationController?.isNavigationBarHidden = false
        self.setNavigationBarImage(for: nil, color: #colorLiteral(red: 0.03137254902, green: 0.6980392157, blue: 0.7333333333, alpha: 1))
       // setBackButton(tintColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), isImage: true, #imageLiteral(resourceName: "backBtn"))
        self.title = titleString
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), NSAttributedString.Key.kern: -0.41]
        viewHeight.constant = 0.0
        btnAccept.isHidden = true
           
        
    }
//    override func backBtnTapAction() {
//     self.navigationController?.popViewController(animated: true)
//    }
    @IBAction func BtnAcceptPressed(_ sender: UIButton) {
      UserDefaults.standard.setValue(true, forKey: "POLICYSCREEN")
      self.dismiss(animated: true, completion: nil)
    }
    
}
// MARK: UIWebViewDelegate
extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Global.showLoadingSpinner()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Global.dismissLoadingSpinner()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Global.dismissLoadingSpinner()
        print(error)
    }
}

// MARK: ScrollView Delegate
extension WebViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
          if scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.size.height < 100 {
            viewHeight.constant = 140
            btnAccept.isHidden = false
          } else if scrollView.contentOffset.y < 100 {
            viewHeight.constant = 0.0
            btnAccept.isHidden = true
          }
      }
}

