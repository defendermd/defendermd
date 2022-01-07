//
//  SinglePhotoViewController.swift
//  seiosnativeapp
/*
* Copyright (c) 2016 BigStep Technologies Private Limited.
*
* You may not use this file except in compliance with the
* SocialEngineAddOns License Agreement.
* You may obtain a copy of the License at:
* https://www.socialengineaddons.com/ios-app-license
* The full copyright and license information is also mentioned
* in the LICENSE file that was distributed with this
* source code.
*/


import UIKit

class SinglePhotoLightBoxController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    var imageUrl : String!
    var crossButton : UIButton!
    var savePhotoButton : UIButton!
    var sharePhotoButton : UIButton!
    var lightBoxImage : UIImageView!
    let photoViewerScrollView = UIScrollView()
    var contentType : String = ""
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
        if contentType == "product"{
        self.view.backgroundColor = UIColor.white
        }
        else{
             self.view.backgroundColor = UIColor.black
        }

        photoViewerScrollView.frame = view.frame
        photoViewerScrollView.delegate = self
        photoViewerScrollView.isPagingEnabled = true
        photoViewerScrollView.bounces = true
        photoViewerScrollView.tag = 1
        photoViewerScrollView.isUserInteractionEnabled = true
        view.addSubview(photoViewerScrollView)
        
        
        lightBoxImage  = UIImageView(frame:view.frame);
        lightBoxImage.contentMode = UIView.ContentMode.scaleAspectFit
        self.lightBoxImage.clipsToBounds = true;

        if contentType == "product"{
            self.lightBoxImage.layer.shadowColor = UIColor.white.cgColor
        }
        else{
        self.lightBoxImage.layer.shadowColor = UIColor.black.cgColor
        }
        let urlLink = URL(string: imageUrl)
        self.lightBoxImage.kf.indicatorType = .activity
        (self.lightBoxImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
        self.lightBoxImage.kf.setImage(with: urlLink, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
        })
        
        photoViewerScrollView.addSubview(lightBoxImage)
        photoViewerScrollView.minimumZoomScale = 1;
        photoViewerScrollView.maximumZoomScale = 3;
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(SinglePhotoLightBoxController.doubleTapped(_:)))
        doubleTap.numberOfTapsRequired = 2;
        photoViewerScrollView.addGestureRecognizer(doubleTap);

        if contentType == "product"{
        
        crossButton =  createButton(CGRect(x: 15, y: 40, width: 20, height: 20), title: "", border: false,bgColor: false, textColor: textColorLight)
        }
        else{
        
        crossButton =  createButton(CGRect(x: 15, y: 10, width: 40, height: 70), title: "", border: false,bgColor: false, textColor: textColorLight)
        }
        if contentType == "product"{
             crossButton.setImage(UIImage(named: "cross")!.maskWithColor(color: textColorPrime), for: UIControl.State())
        }
        else{
        crossButton.setImage(UIImage(named: "cross_icon")!.maskWithColor(color: textColorPrime), for: UIControl.State())
        }
        crossButton.addTarget(self, action: #selector(SinglePhotoLightBoxController.cancel), for: .touchUpInside)

        view.addSubview(crossButton)
        
        savePhotoButton = createButton(CGRect(x: 30, y: view.bounds.height - 40 , width: 40, height: 40), title: "\u{f0ed}", border: false,bgColor: false, textColor: textColorLight)
        savePhotoButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 20)

        savePhotoButton.addTarget(self, action: #selector(SinglePhotoLightBoxController.savePhoto), for: .touchUpInside)
        if contentType == "product"{
            savePhotoButton.isHidden = true
        }

        view.addSubview(savePhotoButton)
        
        sharePhotoButton = createButton(CGRect(x: 70, y: view.bounds.height - 40 , width: 40, height: 40), title: shareIcon , border: false,bgColor: false, textColor: textColorLight)
        sharePhotoButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 20)

        sharePhotoButton.addTarget(self, action: #selector(SinglePhotoLightBoxController.contentShare), for: .touchUpInside)
        if contentType == "product"{
        sharePhotoButton.isHidden = true
        }

        view.addSubview(sharePhotoButton)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SinglePhotoLightBoxController.cancel))
        downSwipe.direction = .down
        photoViewerScrollView.addGestureRecognizer(downSwipe)
        
        // Do any additional setup after loading the view.
    }
    
    func pinchDetected(_ pinchRecognizer: UIPinchGestureRecognizer) {
        let scale: CGFloat = pinchRecognizer.scale;
        self.lightBoxImage.transform = self.view.transform.scaledBy(x: scale, y: scale);
        pinchRecognizer.scale = 1.0;
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //        navigationController?.navigationBar.isHidden = true
    }
    
    @objc func cancel(){
        isPresented = false
        scrollingToBottom = false
        dismiss(animated: true, completion: nil)
    }
    @objc func contentShare(){
        
        let url = URL(string: self.imageUrl)
        let data = try? Data(contentsOf: url!)
        let  image = UIImage(data: data!)
        self.shareTextImageAndURL(sharingText: "", sharingImage: image)
        
    }
    
    @objc func savePhoto(){
        let url = URL(string: self.imageUrl)
        let data = try? Data(contentsOf: url!)
        ALAssetsLibrary().writeImageData(toSavedPhotosAlbum: data, metadata:nil , completionBlock: nil)
        self.view.makeToast(NSLocalizedString("Photo Saved", comment: ""), duration: 5, position: CSToastPositionCenter)
        
    }
    
    func shareTextImageAndURL(sharingText: String?, sharingImage: UIImage?)
    {
        var shareText = ""
        var shareImage : UIImage?
        var shareUrl = "none"
        if let text = sharingText
        {
            shareText = text
        }
        if let image = sharingImage
        {
            shareImage = image
        }
        
        let activityItems = ActivityShareItemSources(text: shareText, image: shareImage!, url: URL(string: shareUrl)!)

        let activityViewController = UIActivityViewController(activityItems: [activityItems], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        if(activityViewController.popoverPresentationController != nil) {
            activityViewController.popoverPresentationController?.sourceView = self.view;
            let frame = UIScreen.main.bounds
            activityViewController.popoverPresentationController?.sourceRect = frame;
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView)->UIView?
    {
        return self.lightBoxImage
    }
    
    
    @objc func doubleTapped(_ sender:UITapGestureRecognizer)
    {
        if photoViewerScrollView.zoomScale > 1.0
        {
            photoViewerScrollView.setZoomScale(1.0, animated:true);
        }
        else
        {
            let point = sender.location(in: photoViewerScrollView);
            photoViewerScrollView.zoom(to: CGRect(x: point.x-50, y: point.y-50, width: 100, height: 100), animated:true)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
