//
//  SupportVC.swift
//  TrailGuru-ios
//
//  Created by kishlay kishore on 22/02/21.
//

import UIKit
import MessageUI

class SupportVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Support"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Inter-SemiBold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.03137254902, green: 0.6980392157, blue: 0.7333333333, alpha: 1)
    }
    
    // MARK: - Back Button Action
    @IBAction func btnBack_Action(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Button Email Address Action
    @IBAction func btnEmail_Action(_ sender: UIButton) {
        sendMail()
    }
}

//MARK:- Mail App Configuration
extension SupportVC : MFMailComposeViewControllerDelegate {
    func sendMail() {
        let recipientEmail = "contact@trailguru.me"
        let subject = "Contact request".localized
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipientEmail])
            mail.setSubject(subject)
            present(mail, animated: true)
        } else {
            Common.showAlertMessage(message: "Cannot Open Mail".localized, alertType: .error)
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
