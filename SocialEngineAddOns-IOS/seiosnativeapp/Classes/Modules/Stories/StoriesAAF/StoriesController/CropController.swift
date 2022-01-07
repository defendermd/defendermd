//
//  CropController.swift
//  TestDummy
//
//  Created by Akash Verma on 07/08/18.
//  Copyright © 2018 Akash Verma. All rights reserved.
//

import IGRPhotoTweaks

import UIKit

class CropController: IGRPhotoTweakViewController {

    @IBOutlet weak fileprivate var angleSlider: UISlider?
    @IBOutlet weak fileprivate var angleLabel: UILabel?
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var btnReset: UIBarButtonItem!
    @IBOutlet weak var btnAspect: UIBarButtonItem!
    @IBOutlet weak var btnCrop: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSlider()
        btnCancel.tintColor = navColor
        btnReset.tintColor = navColor
        btnAspect.tintColor = navColor
        btnCrop.tintColor = navColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //  UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // UIApplication.shared.isStatusBarHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //FIXME: Themes Preview
    override open func setupThemes() {
        
        IGRCropLine.appearance().backgroundColor = UIColor.white
        IGRCropGridLine.appearance().backgroundColor = UIColor.white
        //IGRCropCornerView.appearance().backgroundColor = UIColor.black.withAlphaComponent(0.5)
        IGRCropCornerLine.appearance().backgroundColor = UIColor.white
        IGRCropMaskView.appearance().backgroundColor = UIColor.black.withAlphaComponent(0.5)
        IGRPhotoContentView.appearance().backgroundColor = UIColor.black
        IGRPhotoTweakView.appearance().backgroundColor = UIColor.black
    }
    
    fileprivate func setupSlider() {
        self.angleSlider?.minimumValue = -Float(IGRRadianAngle.toRadians(45))
        self.angleSlider?.maximumValue = Float(IGRRadianAngle.toRadians(45))
        self.angleSlider?.value = 0.0
        
        setupAngleLabelValue(radians: CGFloat((self.angleSlider?.value)!))
    }
    
    fileprivate func setupAngleLabelValue(radians: CGFloat) {
        let intDegrees: Int = Int(IGRRadianAngle.toDegrees(radians))
        self.angleLabel?.text = "\(intDegrees)°"
    }
    
    // MARK: - Rotation
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.view.layoutIfNeeded()
        }) { (context) in
            //
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onChandeAngleSliderValue(_ sender: UISlider) {
        let radians: CGFloat = CGFloat(sender.value)
        setupAngleLabelValue(radians: radians)
        self.changeAngle(radians: radians)
    }
    
    @IBAction func onEndTouchAngleControl(_ sender: UIControl) {
        self.stopChangeAngle()
    }
    
    @IBAction func onTouchResetButton(_ sender: UIButton) {
        self.angleSlider?.value = 0.0
        //self.horizontalDial?.value = 0.0
        setupAngleLabelValue(radians: 0.0)
        
        self.resetView()
    }
    
    @IBAction func onTouchCancelButton(_ sender: UIButton) {
        self.dismissAction()
    }
    
    @IBAction func onTouchCropButton(_ sender: UIButton) {
        cropAction()
    }
    
    @IBAction func onTouchAspectButton(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        
        actionSheet.addAction(UIAlertAction(title: "Original", style: .default) { (action) in
            self.resetAspectRect()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Square", style: .default) { (action) in
            self.setCropAspectRect(aspect: "1:1")
        })
        
        actionSheet.addAction(UIAlertAction(title: "2:3", style: .default) { (action) in
            self.setCropAspectRect(aspect: "2:3")
        })
        
        actionSheet.addAction(UIAlertAction(title: "3:5", style: .default) { (action) in
            self.setCropAspectRect(aspect: "3:5")
        })
        
        actionSheet.addAction(UIAlertAction(title: "3:4", style: .default) { (action) in
            self.setCropAspectRect(aspect: "3:4")
        })
        
        actionSheet.addAction(UIAlertAction(title: "5:7", style: .default) { (action) in
            self.setCropAspectRect(aspect: "5:7")
        })
        
        actionSheet.addAction(UIAlertAction(title: "9:16", style: .default) { (action) in
            self.setCropAspectRect(aspect: "9:16")
        })
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func onTouchLockAspectRatioButton(_ sender: UISwitch) {
        self.lockAspectRatio(sender.isOn)
    }
    
    //FIXME: Themes Preview
//        override open func customBorderColor() -> UIColor {
//            return UIColor.red
//        }
    
        override open func customBorderWidth() -> CGFloat {
            return 2.0
        }
    
        override open func customCornerBorderWidth() -> CGFloat {
            return 4.0
        }
    
        override open func customCornerBorderLength() -> CGFloat {
            return 30.0
        }
    
        override open func customIsHighlightMask() -> Bool {
            return true
        }
    
        override open func customHighlightMaskAlphaValue() -> CGFloat {
            return 0.3
        }
    
    override open func customCanvasHeaderHeigth() -> CGFloat {
        var heigth: CGFloat = 0.0
        
        if UIDevice.current.orientation.isLandscape {
            heigth = 40.0
        } else {
            heigth = 100.0
        }
        
        return heigth
    }
}

