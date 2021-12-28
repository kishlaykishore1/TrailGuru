//
//  MapLegendVC.swift
//  TrailGuru-ios
//
//  Created by kishlay kishore on 23/02/21.
//

import UIKit

protocol NotiPermissionAlertViewDelegate {
    func actionNotiAuthorize()
    func actionNotiCloseBtn()
}

class MapLegendVC: UIViewController {
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var btnAuthorize: UIButton!
    
    var delegate: NotiPermissionAlertViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        DispatchQueue.main.async {
//            self.btnAuthorize.cornerRadius = self.btnAuthorize.frame.height / 2
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        animateView()
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    @IBAction func onTapAuthorize(_ sender: UIButton) {
        delegate?.actionNotiAuthorize()
        self.dismiss(animated: true, completion: nil)
    }
}
