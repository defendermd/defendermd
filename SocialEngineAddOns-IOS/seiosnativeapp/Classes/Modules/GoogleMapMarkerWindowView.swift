//
//  MapMarkerWindowView.swift
//  seiosnativeapp
//
//  Created by BigStep on 21/06/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

protocol GoogleMapMarkerDelegate: class {
    func didTapInfoButton(data: NSDictionary)
    func didTapRedirectLocButton(data: NSDictionary)
}

class GoogleMapMarkerWindowView: UIView {
    
    @IBOutlet weak var btnProfileImage: DesignableButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblTag: UILabel!
    
    @IBOutlet weak var btnRedirectLocation: UIButton!
    
    @IBOutlet weak var btnTitleClick: UIButton!
    
    weak var delegate: GoogleMapMarkerDelegate?
    var spotData: NSDictionary?
    
    @IBAction func btnTitleClickRedirection(_ sender: Any) {
        delegate?.didTapInfoButton(data: spotData!)
    }
    
    @IBAction func btnRedirectLocAction(_ sender: Any) {
        delegate?.didTapRedirectLocButton(data: spotData!)
    }
    
    @IBAction func btnGoogleCloseView(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    @IBAction func btnProfileTabAction(_ sender: Any) {
        delegate?.didTapInfoButton(data: spotData!)
    }
    func commonInit()
    {
        Bundle.main.loadNibNamed("GoogleMapMarkerWindowView", owner: self, options: nil)
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "GoogleMapMarkerWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
}
