//
//  MapMarkerWindowView.swift
//  seiosnativeapp
//
//  Created by BigStep on 21/06/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

protocol MapMarkerDelegate: class {
    func didTapInfoButton(data: Members)
    func didTapRedirectLocButton(data: Members)
    func didTapRedirectFriendType(data: Members)
}

class MapMarkerWindowView: UIView {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
  
    @IBOutlet weak var btnProfileImage: UIButton!
    @IBOutlet weak var lblViewCount: UILabel!
    @IBOutlet weak var lblView: UILabel!
    @IBOutlet weak var lblFollowCount: UILabel!
    @IBOutlet weak var lblFollow: UILabel!
    @IBOutlet weak var lblFriendCount: UILabel!
    @IBOutlet weak var lblFriend: UILabel!
    
    @IBOutlet weak var btnFriendType: UIButton!
    @IBOutlet weak var btnRedirectLocation: UIButton!
    weak var delegate: MapMarkerDelegate?
    var spotData: Members?
    
    @IBAction func friendType(_ sender: Any) {
        delegate?.didTapRedirectFriendType(data: spotData!)
    }
    
    @IBAction func btnRedirectLocAction(_ sender: Any) {
        delegate?.didTapRedirectLocButton(data: spotData!)
    }
    
    @IBAction func btnMemberMapCloseView(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBAction func btnProfileTabAction(_ sender: UIButton) {
        delegate?.didTapInfoButton(data: spotData!)
    }
    
    func commonInit()
    {
        Bundle.main.loadNibNamed("MapMarkerWindowView", owner: self, options: nil)
//        btnProfileImage.layer.masksToBounds = true
//        btnProfileImage.clipsToBounds = true
//        btnProfileImage.layer.cornerRadius = btnProfileImage.frame.width/2
        
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
}
