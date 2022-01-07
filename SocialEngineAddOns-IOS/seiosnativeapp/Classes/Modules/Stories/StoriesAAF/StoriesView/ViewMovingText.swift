//
//  ViewMovingText.swift
//  TestDummy
//
//  Created by BigStep on 12/08/18.
//  Copyright © 2018 Akash Verma. All rights reserved.
//

import UIKit

class ViewMovingText: UIView {

    @IBOutlet var viewContainer: UIView!
    @IBOutlet weak var viewMovingTextBorder: UIView!
    @IBOutlet weak var btnMovingText: UIButton!
    @IBOutlet weak var lblMovingText: UILabel!
    @IBOutlet weak var txtViewEmoji: UITextView!
    @IBOutlet weak var imgViewSticker: UIImageView!
   
    @IBOutlet weak var btnMovingTextClose: UIButton!
    override init(frame: CGRect) {  //To use it in code
        super.init(frame: frame)

    }
    
    required init?(coder aDecoder: NSCoder) { // To use it in IB
        super.init(coder: aDecoder)

    }
    
    convenience init(frame : CGRect, dataType : ViewMovingObjectType, strData : String) {
        self.init(frame: frame)
   
        commonInit(dataType : dataType, strData : strData)
    }

    func commonInit(dataType : ViewMovingObjectType, strData : String)
    {
        Bundle.main.loadNibNamed("ViewMovingText", owner: self, options: nil)
        addSubview(viewContainer)
        viewContainer.frame = self.bounds
        viewContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        switch dataType {
        case .labelText:
            imgViewSticker.isHidden = true
            txtViewEmoji.isHidden = true
            lblMovingText.isHidden = false
        case .emojiText:
            imgViewSticker.isHidden = true
            lblMovingText.isHidden = true
            txtViewEmoji.isHidden = false
            txtViewEmoji.text = strData
            viewMovingTextBorder.layer.borderColor = UIColor.white.cgColor
            btnMovingText.setImage(UIImage(named: "crossIcon"), for: .normal)
        case .stickerImage:
            txtViewEmoji.isHidden = true
            lblMovingText.isHidden = true
            imgViewSticker.isHidden = false
            viewMovingTextBorder.layer.borderColor = UIColor.white.cgColor
            btnMovingText.setImage(UIImage(named: "crossIcon"), for: .normal)
            if let url = URL(string:strData)
            {
                imgViewSticker.kf.indicatorType = .activity
                (imgViewSticker.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                imgViewSticker.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
    
                })
            }

        }
        
        viewMovingTextBorder.layer.cornerRadius = 5.0
        viewMovingTextBorder.layer.borderWidth = 1.0
        viewMovingTextBorder.backgroundColor = .clear
      //  viewMovingTextBorder.dropShadow()
        viewMovingTextBorder.clipsToBounds = true
    }
    func createMovingLabel(colorLabel: UIColor, text: String)
    {
        lblMovingText.textColor = colorLabel
        lblMovingText.text = text
        viewMovingTextBorder.layer.borderColor = colorLabel.cgColor
        btnMovingText.setImage(UIImage(named: "crossIcon"), for: .normal)
    }
//    func returnMainObject()->ViewMovingText
//    {
//        print(viewMovingText.subviews)
//        return viewMovingText as! ViewMovingText
//    }
    func hideBordarAndButton(isHidden : Bool)
    {
        setViewHideShow(view: btnMovingText, hidden: isHidden)
        setViewHideShow(view: viewMovingTextBorder, hidden: isHidden)
    }
    @IBAction func btnHideViewAction(_ sender: UIButton) {
        
        if sender.tag == 1 {
            sender.tag = 2
            setViewHideShow(view: btnMovingText, hidden: true)
            setViewHideShow(view: viewMovingTextBorder, hidden: true)
            
        }
        else
        {
            sender.tag = 1
            setViewHideShow(view: btnMovingText, hidden: false)
            setViewHideShow(view: viewMovingTextBorder, hidden: false)
        }
    }
    
    @IBAction func btnMovingTextCloseAction(_ sender: UIButton) {
        removeFromSuperview()
    }
    
    func setViewHideShow(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
}
