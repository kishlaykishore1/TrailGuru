//
//  PrivacyPolicyVC.swift
//  TrailGuru-ios
//
//  Created by kishlay kishore on 22/02/21.
//

import UIKit

class AboutUsVC: UIViewController {

    @IBOutlet weak var lblAboutusText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About Us"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Inter-SemiBold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
       // lblAboutusText.text = Messages.txtPPData.htmlToString
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.03137254902, green: 0.6980392157, blue: 0.7333333333, alpha: 1)
    }
        // MARK: - Back Button Action
    @IBAction func backButtonAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}
