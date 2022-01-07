//
//  StoryController.swift
//  TestDummy
//
//  Created by Akash Verma on 07/08/18.
//  Copyright © 2018 Akash Verma. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import IGRPhotoTweaks

var selectedIndexMovingText = 0
var arrSelectedAssests = [TLPHAsset]()

enum ViewMovingObjectType {
    case labelText, emojiText, stickerImage
}

class StoryController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, EmojiProtocol, StickerFetchImage, TLPhotosPickerViewControllerDelegate, TLPhotosPickerLogDelegate, IGRPhotoTweakViewControllerDelegate{
    
    //MARK: Constants
    let viewStcikerHeightConstraintConstant : CGFloat = 320
    let viewFilterHeightConstraintConstant : CGFloat = 100
    let viewEffectsIconHeightConstraintConstant : CGFloat = 80.0
    let viewBrushHeightConstraintConstant : CGFloat = 230.0
    //MARK: Properties
    
    @IBOutlet weak var viewUndoLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewCropWidthConstraint: NSLayoutConstraint!
    
    var currentlySelectedAsset: TLPHAsset!
    var stikerView = StickerView()
    var searchDictionary = Dictionary<String, String>()
    var boolCheckIfTextClick = false
    var swipeUp = UISwipeGestureRecognizer()
    var swipeDown = UISwipeGestureRecognizer()
    var tapGesture = UITapGestureRecognizer()
    var defaultSelectedIndex = 0
    var lastRotation : CGFloat = 0.0
    var previousScale : CGFloat = 1.0
    var beginX : CGFloat = 0.0
    var beginY : CGFloat = 0.0
    var placeholderLabel : UILabel!
    var arrColors = [["color" : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), "isSelected" : true],["color" :  #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1), "isSelected" : false],["color" :  #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), "isSelected" : false] ,["color" :  #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), "isSelected" : false], ["color" : #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), "isSelected" : false], ["color" : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), "isSelected" : false], ["color" : #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), "isSelected" : false],["color" : #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), "isSelected" : false]]
    
    var CIFilterNames = [
        ["effect":"CIPhotoEffectChrome", "name": "Chrome"],
        ["effect":"CIPhotoEffectFade", "name": "Fade"],
        ["effect":"CIPhotoEffectInstant", "name": "Instant"],
        ["effect":"CIPhotoEffectNoir", "name": "Noir"],
        ["effect":"CIPhotoEffectProcess", "name": "Process"],
        ["effect":"CIPhotoEffectTonal", "name": "Tonal"],
        ["effect":"CIPhotoEffectTransfer", "name": "Transfer"],
        ["effect":"CISepiaTone", "name": "Sepia"]
    ]
    var arrFilterImages = [[String : Any]]()
    var imgSelectedInPreview = UIImage()
    var arrTextGrowData = [TextViewGrowData]()
    var txtGrowData = TextViewGrowData()
    var isVideoSelected = false
    var isCameraSelected = false
    var viewMovingActive = UIView()
    var viewDrawingActive = TouchDrawView()
    
    var colorAlphaActive : CGFloat = 1.0
    var deltaWidthActive = CGFloat(2.0)
    
    var colorAlpha1 : CGFloat = 1.0
    let deltaWidth1 = CGFloat(2.0)
    var colorAlpha2 : CGFloat = 1.0
    let deltaWidth2 = CGFloat(2.0)
    var colorAlpha3 : CGFloat = 1.0
    let deltaWidth3 = CGFloat(2.0)
    var colorAlpha4 : CGFloat = 1.0
    let deltaWidth4 = CGFloat(2.0)
    var colorAlpha5 : CGFloat = 1.0
    let deltaWidth5 = CGFloat(2.0)
    var colorAlpha6 : CGFloat = 1.0
    let deltaWidth6 = CGFloat(2.0)
    var colorAlpha7 : CGFloat = 1.0
    let deltaWidth7 = CGFloat(2.0)
    var colorAlpha8 : CGFloat = 1.0
    let deltaWidth8 = CGFloat(2.0)
    var colorAlpha9 : CGFloat = 1.0
    let deltaWidth9 = CGFloat(2.0)
    var colorAlpha10 : CGFloat = 1.0
    let deltaWidth10 = CGFloat(2.0)
    
    //MARK: Outlets
    
    @IBOutlet weak var btnUndoIcon: UIButton!
    @IBOutlet weak var imgUndoIcon: UIImageView!
    
    @IBOutlet weak var imgRedoIcon: UIImageView!
    @IBOutlet weak var viewDoneGradient: GradientView!
    @IBOutlet weak var btnSkipIcon: UIButton!
    @IBOutlet weak var btnRedoIcon: UIButton!
    
    @IBOutlet weak var imgAPIAppearenceViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerViewCapture: UIView!
    @IBOutlet weak var viewFiltersCollectionConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionMainView: UICollectionView!
    //@IBOutlet weak var containerDrawView: UIView!
    @IBOutlet weak var collectionPreview: UICollectionView!
    @IBOutlet weak var viewGrowingTextField: UIView!
    @IBOutlet weak var txtViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgAPIAppearence: UIImageView!
    
    @IBOutlet weak var viewEmpty: UIView!
    @IBOutlet weak var imgAPIAppearenceView: UIView!
    @IBOutlet weak var imgAPIAppearenceDrawing: UIImageView!
    @IBOutlet weak var lblLoadingPlease: UILabel!
    
    @IBOutlet weak var lblOpacitytext: UILabel!
    @IBOutlet weak var lblBrushText: UILabel!
    @IBOutlet weak var lblFilters: UILabel!
    @IBOutlet weak var imgAPIAppearenceMoving: UIImageView!
    @IBOutlet weak var txtViewGrowing: UITextView!
    @IBOutlet weak var viewGrowingBottomCOnstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewMainFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var btnBrush: UIButton!
    @IBOutlet weak var viewEffectsIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewEffectsIcon: UIView!
    @IBOutlet weak var viewFilterIcon: UIView!
    @IBOutlet weak var btnSend: DesignableButton!
    @IBOutlet weak var viewBrush: UIView!
    @IBOutlet weak var viewBrushHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewTextViewLargeBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgAPIAppearenceFinal: UIImageView!
    
    @IBOutlet weak var collectionViewMainImageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnEraseDrwaing: UIButton!
    
    @IBOutlet weak var activityMainView: UIActivityIndicatorView!
    @IBOutlet weak var collectionViewLargeTextView: UICollectionView!
    @IBOutlet weak var btnTextDraw: UIButton!
    @IBOutlet weak var btnLargeTextView: DesignableButton!
    @IBOutlet weak var txtViewLarge: UITextView!
    @IBOutlet weak var viewTextViewLarge: UIView!
    
    @IBOutlet weak var viewFilterHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnSliderOpacity: UISlider!
    @IBOutlet weak var btnSliderBrush: UISlider!
    @IBOutlet weak var collectionViewBrushColor: UICollectionView!
    @IBOutlet weak var btnEmoji: UIButton!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var viewFilters: UIView!
    
    @IBOutlet weak var viewStickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewSticker: UIView!
    @IBOutlet weak var stackViewEffectsIcon: UIStackView!
    @IBOutlet weak var btnStickers: UIButton!
    //@IBOutlet weak var containerViewMovingText: UIView!
    
    @IBOutlet weak var collectionFilters: UICollectionView!
    
    //Moving Views
    @IBOutlet weak var viewMoving1: UIView!
    @IBOutlet weak var viewMoving2: UIView!
    @IBOutlet weak var viewMoving3: UIView!
    @IBOutlet weak var viewMoving4: UIView!
    @IBOutlet weak var viewMoving5: UIView!
    @IBOutlet weak var viewMoving6: UIView!
    @IBOutlet weak var viewMoving9: UIView!
    @IBOutlet weak var viewMoving10: UIView!
    @IBOutlet weak var viewMoving8: UIView!
    @IBOutlet weak var viewMoving7: UIView!
    
    @IBOutlet weak var viewMovingHeight1: NSLayoutConstraint!
    @IBOutlet weak var viewMovingHeight3: NSLayoutConstraint!
    @IBOutlet weak var viewMovingHeight2: NSLayoutConstraint!
    
    @IBOutlet weak var viewMovingHeight10: NSLayoutConstraint!
    @IBOutlet weak var viewMovingHeight9: NSLayoutConstraint!
    @IBOutlet weak var viewMovingHeight8: NSLayoutConstraint!
    @IBOutlet weak var viewMovingHeight7: NSLayoutConstraint!
    @IBOutlet weak var viewMovingHeight6: NSLayoutConstraint!
    @IBOutlet weak var viewMovingHeight5: NSLayoutConstraint!
    @IBOutlet weak var viewMovingHeight4: NSLayoutConstraint!
    
    
    //Drawing Objects
    @IBOutlet weak var viewDrawing1: TouchDrawView!
    @IBOutlet weak var viewDrawing2: TouchDrawView!
    @IBOutlet weak var viewDrawing3: TouchDrawView!
    @IBOutlet weak var viewDrawing4: TouchDrawView!
    @IBOutlet weak var viewDrawing5: TouchDrawView!
    @IBOutlet weak var viewDrawing6: TouchDrawView!
    @IBOutlet weak var viewDrawing7: TouchDrawView!
    @IBOutlet weak var viewDrawing8: TouchDrawView!
    @IBOutlet weak var viewDrawing9: TouchDrawView!
    @IBOutlet weak var viewDrawing10: TouchDrawView!
    
    @IBOutlet weak var viewCropContainer: GradientView!
    
    @IBOutlet weak var imgCropIcon: UIImageView!
    
    @IBOutlet weak var viewDrawingUndoRedo10: UIView!
    
    @IBOutlet weak var viewDrawingHeight1: NSLayoutConstraint!
    @IBOutlet weak var viewDrawingHeight10: NSLayoutConstraint!
    @IBOutlet weak var viewDrawingHeight9: NSLayoutConstraint!
    @IBOutlet weak var viewDrawingHeight8: NSLayoutConstraint!
    @IBOutlet weak var viewDrawingHeight7: NSLayoutConstraint!
    @IBOutlet weak var viewDrawingHeight6: NSLayoutConstraint!
    @IBOutlet weak var viewDrawingHeight5: NSLayoutConstraint!
    @IBOutlet weak var viewDrawingHeight4: NSLayoutConstraint!
    @IBOutlet weak var viewDrawingHeight3: NSLayoutConstraint!
    @IBOutlet weak var viewDrawingHeight2: NSLayoutConstraint!
    
    //MARK: ViewController LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        lblLoadingPlease.text = NSLocalizedString("Loading please wait..",comment: "")
        lblFilters.text = NSLocalizedString("Filters",comment: "")
        lblBrushText.text = NSLocalizedString("Brush",comment: "")
        lblOpacitytext.text = NSLocalizedString("Opacity",comment: "")
        btnSend.isHidden = true
        activityIndicatorView.stopAnimating()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        viewTextViewLarge.isHidden = true
        viewFilterIcon.isHidden = true
        collectionViewBrushColor.isHidden = true
        collectionViewMainFlowLayout.itemSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        openTLSImagePicker()
        
    }
    
    func viewDidLodEventsCall()
    {
        var totalData = Data()
        print(arrSelectedAssests.count)
        for (index, var asset) in arrSelectedAssests.enumerated()
        {
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .opportunistic
            options.version = .current
            options.resizeMode = .exact
            options.progressHandler = { (progress,error,stop,info) in
                //progressBlock(progress)
            }
            if let img = asset.fullResolutionImage
            {
                let aspectRatio = img.size.width/img.size.height
                let requiredHeight = self.view.bounds.size.width / aspectRatio
                asset.imageHeight = requiredHeight
                arrSelectedAssests.remove(at: index)
                arrSelectedAssests.insert(asset, at: index)
                let requestId = PHCachingImageManager().requestImageData(for: asset.phAsset!, options: options) { (imageData, dataUTI, orientation, info) in
                    if let data = imageData,let _ = info {
                        //completionBlock(UIImage(data: data))
                        totalData.append(data)
                    }
                }
            }
            else {
                _ = arrSelectedAssests[0].phAsset?.image(completionHandler: {(img) in
                    let aspectRatio = img.size.width/img.size.height
                    let requiredHeight = self.view.bounds.size.width / aspectRatio
                    asset.imageHeight = requiredHeight
                    arrSelectedAssests.remove(at: index)
                    arrSelectedAssests.insert(asset, at: index)
                    let requestId = PHCachingImageManager().requestImageData(for: asset.phAsset!, options: options) { (imageData, dataUTI, orientation, info) in
                        if let data = imageData,let _ = info {
                            //completionBlock(UIImage(data: data))
                            totalData.append(data)
                        }
                    }
                })
            }
            
        }
        updateUIAsPerAssets()
        guard arrSelectedAssests.count != 0 else { return }
        currentlySelectedAsset = arrSelectedAssests[0]
        selectedIndexMovingText = 0
        setCurrentlyActiveViews()
        hideShowAsPerIndex()
        if let img = currentlySelectedAsset.fullResolutionImage
        {
            imgSelectedInPreview = img
        }
        else {
            _ = currentlySelectedAsset.phAsset?.image(completionHandler: {(img) in
                self.imgSelectedInPreview = img
            })
        }
        
        viewCropContainer.isHidden = true
        self.collectionMainView.reloadData()
        self.collectionPreview.reloadData()
        
        placeholderLabel = UILabel()
        placeholderLabel.text = NSLocalizedString("Add a caption",comment: "")
        placeholderLabel.font = txtViewGrowing.font
        placeholderLabel.sizeToFit()
        txtViewGrowing.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (txtViewGrowing.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.white
        placeholderLabel.isHidden = !txtViewGrowing.text.isEmpty
        // adjustContentSize(tv: txtViewLarge)
        
        for _ in 0..<arrSelectedAssests.count {
            arrTextGrowData.append(TextViewGrowData())
        }
        txtGrowData = arrTextGrowData[selectedIndexMovingText]
        txtViewGrowing.text = txtGrowData.text
        txtViewHeightConstraint.constant = txtGrowData.textHeightConstant
        viewEmpty.isHidden = true
        collectionViewBrushColor.isHidden = false
        viewFilterIcon.isHidden = false
        btnSend.isHidden = false
        
        viewDrawingUndoRedo10.gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.1).cgColor]
        viewDrawingUndoRedo10.gradientLayer.gradient = GradientPoint.bottomTop.draw()
        
        viewCropContainer.gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.1).cgColor]
        viewCropContainer.gradientLayer.gradient = GradientPoint.bottomTop.draw()
        
        viewDoneGradient.gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.1).cgColor]
        viewDoneGradient.gradientLayer.gradient = GradientPoint.bottomTop.draw()
        if currentlySelectedAsset.isVideoSelected{
            btnFilter.isHidden = true
            viewCropWidthConstraint.constant = 0
            viewUndoLeftConstraint.constant = 5
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestAVAsset(forVideo: currentlySelectedAsset.phAsset!, options: options, resultHandler: { (asset, mix, nil) in
                let myAsset = asset as? AVURLAsset
                do {
                    if let url = myAsset?.url
                    {
                        print(url)
                        let videoData = try Data(contentsOf: url)
                        if self.checkSizeValidation(data: videoData)
                        {
                            self.currentlySelectedAsset.videoData = videoData
                            self.currentlySelectedAsset.strVideoPath = myAsset?.url
                            self.currentlySelectedAsset.videoDuration = (myAsset?.duration.seconds)!
                        }
                        else
                        {
                            return
                        }
                    }
                    
                } catch  {
                    print("exception catch at block - while uploading video")
                }
            })
            isVideoSelected = true
        }
        else
        {
            btnFilter.isHidden = false
            viewCropWidthConstraint.constant = 75
            viewUndoLeftConstraint.constant = 75
            if !checkSizeValidation(data: totalData)
            {
                return
            }
            
        }
        swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        viewBrushHeightConstraint.constant = 0
        //Sticker works
        allStickersDic.removeAll(keepingCapacity : false)
        DispatchQueue.global(qos:.userInteractive).async {
            self.getStickers()
            self.initializeFilterArray()
            DispatchQueue.main.async {
                self.collectionFilters.reloadData()
            }
        }
        imgUndoIcon.image = UIImage(named: "StoryIcons_Undo")!.maskWithColor(color: .white)
        imgRedoIcon.image = UIImage(named: "StoryIcons_redo")!.maskWithColor(color: .white)
        imgCropIcon.image = UIImage(named: "StoryIcon_Crop")!.maskWithColor(color: .white)
        
        // txtViewLarge.tintColor = navColor
    }
    
    func checkSizeValidation(data : Data) -> Bool
    {
        if let videoSize = UserDefaults.standard.object(forKey: "videoSize") as? String, let v = Double(videoSize), v <= Double(data.count / 1048576)
        {
            let alertController = UIAlertController(title: "\(NSLocalizedString("Maximum allowed size for Media is", comment: "")) \(videoSize)\(NSLocalizedString("MB. Please try uploading a smaller size file.", comment: ""))", message: nil, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                let viewControllers = self.navigationController!.viewControllers
                for aViewController in viewControllers {
                    if aViewController is AdvanceActivityFeedViewController {
                        self.navigationController!.popToViewController(aViewController, animated: true)
                    }
                }
            }))
            self.present(alertController, animated:true, completion: nil)
            return false
            
        }
        else if let videoSize = UserDefaults.standard.object(forKey: "rest_space") as? Int, videoSize >= 0 , Double(videoSize) <= Double((data.count) / 1048576)
        {
            let alertController = UIAlertController(title:  "\(NSLocalizedString("Remaining Storage Limit for your account is", comment: "")) \(videoSize)\(NSLocalizedString("MB. Please try uploading a smaller size file or delete your previously uploaded Media.", comment: ""))", message: nil, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                let viewControllers = self.navigationController!.viewControllers
                for aViewController in viewControllers {
                    if aViewController is AdvanceActivityFeedViewController {
                        self.navigationController!.popToViewController(aViewController, animated: true)
                    }
                }
                
            }))
            self.present(alertController, animated:true, completion: nil)
            return false
        }
        return true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        //UIApplication.shared.isStatusBarHidden = true
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        //UIApplication.shared.isStatusBarHidden = false
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHeightConstraint()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func adjustContentSize(tv: UITextView){
        let deadSpace = tv.bounds.size.height - tv.contentSize.height
        let inset = max(0, deadSpace/2.0)
        tv.contentInset = UIEdgeInsets(top: inset, left: tv.contentInset.left, bottom: inset, right: tv.contentInset.right)
    }
    //MARK: UITextView Delegate
    func textViewDidChangeSelection(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        if textView == txtViewLarge
        {
            // adjustContentSize(tv: textView)
        }
        else
        {
            txtGrowData.text = textView.text
            placeholderLabel.isHidden = !textView.text.isEmpty
            if newSize.height <= 150 {
                textView.isScrollEnabled = false
                txtGrowData.isScrollEnabled = false
                txtGrowData.textHeightConstant = newSize.height
                txtViewHeightConstraint.constant = newSize.height
                self.view.layoutIfNeeded()
            }
            else
            {
                textView.isScrollEnabled = true
                txtGrowData.isScrollEnabled = true
            }
            arrTextGrowData[selectedIndexMovingText] = txtGrowData
        }
        
    }
    //    func textViewDidChange(_ textView: UITextView) {
    //        let fixedWidth = textView.frame.size.width
    //        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    //        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    //
    //        if textView == txtViewLarge
    //        {
    //           // adjustContentSize(tv: textView)
    //        }
    //        else
    //        {
    //            txtGrowData.text = textView.text
    //            placeholderLabel.isHidden = !textView.text.isEmpty
    //            if newSize.height <= 150 {
    //                textView.isScrollEnabled = false
    //                txtGrowData.isScrollEnabled = false
    //                txtGrowData.textHeightConstant = newSize.height
    //                txtViewHeightConstraint.constant = newSize.height
    //                self.view.layoutIfNeeded()
    //            }
    //            else
    //            {
    //                textView.isScrollEnabled = true
    //                txtGrowData.isScrollEnabled = true
    //            }
    //            arrTextGrowData[selectedIndexMovingText] = txtGrowData
    //        }
    //
    //    }
    
    
    //MARK: UIcollectionView DataSource and Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewBrushColor || collectionView == collectionViewLargeTextView {
            return arrColors.count
        }
        else if collectionView == collectionFilters
        {
            return arrFilterImages.count
        }
        else{
            return arrSelectedAssests.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        if collectionView == collectionViewBrushColor || collectionView == collectionViewLargeTextView
        {
            let dic = arrColors[indexPath.row]
            cell.viewPreview.backgroundColor = dic["color"] as? UIColor
            if let selected = dic["isSelected"] as? Bool, selected == true
            {
                cell.imgViewCheckUnCheck.dropShadow()
                cell.imgViewCheckUnCheck.image = #imageLiteral(resourceName: "StoryIcons_Right")
            }
            else
            {
                cell.imgViewCheckUnCheck.image = nil
            }
        }
        else if collectionView == collectionFilters
        {
            let dic = arrFilterImages[indexPath.row]
            if let img = dic["effectImage"] as? UIImage
            {
                cell.imgFilter.image = img
                cell.imgFilter.setRounded()
            }
            if let strName = dic["name"] as? String
            {
                cell.lblFilterName.text = strName
            }
            
        }
        else if collectionView == collectionMainView
        {
            let asset = arrSelectedAssests[indexPath.row]
            if asset.imgFilter.size.width != 0
            {
                cell.imgMain.image = asset.imgFilter
            }
            else if asset.imgCrop.size.width != 0
            {
                cell.imgMain.image = asset.imgCrop
            }
            else
            {
                if let img = asset.fullResolutionImage {
                    cell.imgMain.image = img
                }
                else {
                    cell.imgMain.image = imgSelectedInPreview
                }
            }
            if isVideoSelected
            {
                cell.imgVideoIcon.isHidden = false
            }
            else
            {
                cell.imgVideoIcon.isHidden = true
            }
            
            
        }
        else
        {
            let asset = arrSelectedAssests[indexPath.row]
            cell.btnPreviewClose.tag = indexPath.row
            
            cell.btnPreviewClose.addTarget(self, action: #selector(btnPreviewCloseAction), for: .touchUpInside)
            //  cell.btnPreviewClose.setImage(UIImage(named: "StoryIcons_Cross")!.maskWithColor(color: .white), for: .normal)
            cell.imgPreviewClose.image = UIImage(named: "crossIconMoving")!.maskWithColor(color: .white)
            cell.imgPreviewClose.dropShadow()
            if asset.imgCrop.size.width != 0
            {
                cell.imgPreview.image = asset.imgCrop
            }
            else
            {
                if let img = asset.fullResolutionImage {
                    cell.imgPreview.image = img
                }
                else {
                    cell.imgPreview.image = imgSelectedInPreview
                }
                
            }
            if asset.isCellSelected
            {
                cell.viewPreview.backgroundColor = .red
            }
            else
            {
                cell.viewPreview.backgroundColor = .clear
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView == collectionViewBrushColor
        {
            for (index, var dic) in arrColors.enumerated()
            {
                dic["isSelected"] = false
                arrColors[index] = dic
            }
            defaultSelectedIndex = indexPath.row
            var dic = arrColors[defaultSelectedIndex]
            dic["isSelected"] = true
            if let color = dic["color"] as? UIColor
            {
                viewDrawingActive.setColor(color.withAlphaComponent(colorAlphaActive))
            }
            arrColors[indexPath.row] = dic
            collectionViewBrushColor.reloadData()
        }
        else if collectionView == collectionViewLargeTextView
        {
            for (index,var dic) in arrColors.enumerated()
            {
                dic["isSelected"] = false
                arrColors[index] = dic
            }
            var dic = arrColors[indexPath.row]
            dic["isSelected"] = true
            if let color = dic["color"] as? UIColor
            {
                txtViewLarge.textColor = color
            }
            arrColors[indexPath.row] = dic
            collectionViewLargeTextView.reloadData()
        }
        else if collectionView == collectionFilters
        {
            let dic = arrFilterImages[indexPath.row]
            if let filter = CIFilter(name: "\(dic["effect"]!)")
            {
                self.view.bringSubviewToFront( activityMainView)
                activityMainView.startAnimating()
                DispatchQueue.global(qos:.userInteractive).async {
                    let ciContext = CIContext(options: nil)
                    let imgt = self.imgSelectedInPreview.fixOrientation(img: self.imgSelectedInPreview)
                    let coreImage = CIImage(image: imgt)
                    filter.setDefaults()
                    filter.setValue(coreImage, forKey: kCIInputImageKey)
                    if let output = filter.outputImage
                    {
                        if let cgimg = ciContext.createCGImage(output, from: output.extent) {
                            let processedImage = UIImage(cgImage: cgimg)
                            self.currentlySelectedAsset.imgFilter = processedImage
                            arrSelectedAssests[selectedIndexMovingText] = self.currentlySelectedAsset
                        }
                    }
                    DispatchQueue.main.async {
                        self.activityMainView.stopAnimating()
                        self.collectionMainView.reloadData()
                    }
                }
                
            }
            else
            {
                self.currentlySelectedAsset = arrSelectedAssests[selectedIndexMovingText]
                var imgT = UIImage()
                if currentlySelectedAsset.imgCrop.size.width != 0
                {
                    imgT = currentlySelectedAsset.imgCrop
                }
                else
                {
                    imgT = currentlySelectedAsset.fullResolutionImage!
                }
                if imgT.size.width != 0
                {
                    self.currentlySelectedAsset.imgFilter = imgT
                    arrSelectedAssests[selectedIndexMovingText] = self.currentlySelectedAsset
                    imgSelectedInPreview = imgT
                }
                collectionMainView.reloadData()
            }
            
        }
        else if collectionView == collectionPreview
        {
            if indexPath.row == selectedIndexMovingText
            {
                return
            }
            if arrSelectedAssests.count != 1
            {
                for (index,assetData) in arrSelectedAssests.enumerated() {
                    var assetT = assetData
                    assetT.isCellSelected = false
                    if index == indexPath.row
                    {
                        assetT.isCellSelected = true
                    }
                    arrSelectedAssests[index] = assetT
                }
                currentlySelectedAsset.isCellSelected = false
            }
            
            
            
            collectionPreview.reloadData()
            collectionMainView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            updateDataForAPI(isUpdateOnSend: false)
            
            arrSelectedAssests[selectedIndexMovingText] = currentlySelectedAsset
            selectedIndexMovingText = indexPath.row
            currentlySelectedAsset = arrSelectedAssests[indexPath.row]
            if currentlySelectedAsset.imgCrop.size.width != 0
            {
                imgSelectedInPreview = currentlySelectedAsset.imgCrop
            }
            else if let img = currentlySelectedAsset.fullResolutionImage
            {
                imgSelectedInPreview = img
            }
            
            self.initializeFilterArray()
            self.collectionFilters.reloadData()
            setCurrentlyActiveViews()
            hideShowAsPerIndex()
            // arrFilterImages.removeAll()
            
            txtGrowData = arrTextGrowData[selectedIndexMovingText]
            txtViewGrowing.text = txtGrowData.text
            placeholderLabel.isHidden = !txtGrowData.text.isEmpty
            txtViewGrowing.isScrollEnabled = txtGrowData.isScrollEnabled
            txtViewHeightConstraint.constant = txtGrowData.textHeightConstant
            self.view.layoutIfNeeded()
        }
    }
    //MARK:- IBActions and Methods
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            if txtViewLarge.isFirstResponder
            {
                viewTextViewLargeBottomConstraint.constant = keyboardHeight
                collectionViewMainImageBottomConstraint.constant = keyboardHeight
            }
            else
            {
                viewGrowingBottomCOnstraint.constant = keyboardHeight
            }
            view.layoutIfNeeded()
        }
    }
    
    @objc func btnPreviewCloseAction(sender: UIButton!) {
        
        if arrSelectedAssests.count == 0
        {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is AdvanceActivityFeedViewController {
                    self.navigationController!.popToViewController(aViewController, animated: true)
                }
            }
            return
        }
        else if arrSelectedAssests.count == 1 {
            arrSelectedAssests.remove(at: sender.tag)
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is AdvanceActivityFeedViewController {
                    self.navigationController!.popToViewController(aViewController, animated: true)
                }
            }
        }
        else
        {
            let asset = arrSelectedAssests[sender.tag]
            if asset.isCellSelected == true
            {
                arrSelectedAssests.remove(at: sender.tag)
                if arrSelectedAssests.count > sender.tag && arrSelectedAssests.count != 1
                {
                    currentlySelectedAsset = arrSelectedAssests[sender.tag ]
                    currentlySelectedAsset.isCellSelected = true
                    arrSelectedAssests[sender.tag] = self.currentlySelectedAsset
                    selectedIndexMovingText = sender.tag
                }
                else if arrSelectedAssests.count > sender.tag - 1 && arrSelectedAssests.count != 1
                {
                    currentlySelectedAsset = arrSelectedAssests[sender.tag - 1]
                    currentlySelectedAsset.isCellSelected = true
                    arrSelectedAssests[sender.tag - 1] = self.currentlySelectedAsset
                    selectedIndexMovingText = sender.tag - 1
                }
                else
                {
                    currentlySelectedAsset = arrSelectedAssests[0]
                    currentlySelectedAsset.isCellSelected = true
                    arrSelectedAssests[0] = self.currentlySelectedAsset
                    selectedIndexMovingText = 0
                }
                setCurrentlyActiveViews()
                hideShowAsPerIndex()
                
            }
            else
            {
                arrSelectedAssests.remove(at: sender.tag)
            }
            
            
            self.collectionPreview.reloadData()
            self.collectionMainView.reloadData()
        }
        
    }
    
    @IBAction func btnSliderBrushAction(_ sender: UISlider) {
        let newWidth = CGFloat(sender.value) * deltaWidthActive
        viewDrawingActive.setWidth(newWidth)
    }
    @IBAction func btnSliderOpacityAction(_ sender: UISlider) {
        colorAlphaActive = CGFloat(sender.value)
    }
    
    @IBAction func btnEraseDrawingAction(_ sender: UIButton) {
        if sender.tag == 103 {
            self.containerViewCapture.bringSubviewToFront( viewDrawingActive)
            self.containerViewCapture.bringSubviewToFront( viewDrawingUndoRedo10)
            self.view.bringSubviewToFront( viewBrush)
            self.view.bringSubviewToFront( viewGrowingTextField)
            self.view.bringSubviewToFront( viewFilterIcon)
            self.view.bringSubviewToFront( viewEffectsIcon)
            swipeUp.isEnabled = false
            swipeDown.isEnabled = false
            tapGesture.isEnabled = false
            viewDrawingActive.isUserInteractionEnabled = true
            sender.tag = 1003
            viewDrawingActive.setColor(nil)
            sender.setImage(UIImage(named: "StoryIcons_FilterEraser")!.maskWithColor(color: navColor), for: .normal)
            btnBrush.tag = 101
            btnBrush.setImage(UIImage(named: "StoryIcons_FilterBrush")!.maskWithColor(color: .white), for: .normal)
            btnTextDraw.tag = 102
            btnTextDraw.setImage(UIImage(named: "StoryIcons_FilterText")!.maskWithColor(color: .white), for: .normal)
        }
        else
        {
            self.containerViewCapture.bringSubviewToFront( viewMovingActive)
            self.containerViewCapture.bringSubviewToFront( viewDrawingUndoRedo10)
            self.view.bringSubviewToFront( viewGrowingTextField)
            self.view.bringSubviewToFront( viewFilterIcon)
            self.view.bringSubviewToFront( viewEffectsIcon)
            swipeUp.isEnabled = true
            swipeDown.isEnabled = true
            tapGesture.isEnabled = true
            sender.tag = 103
            sender.setImage(UIImage(named: "StoryIcons_FilterEraser")!.maskWithColor(color: .white), for: .normal)
            viewDrawingActive.isUserInteractionEnabled = false
        }
    }
    @IBAction func btnBrushAction(_ sender: UIButton) {
        
        if sender.tag == 101
        {
            currentlySelectedAsset.isViewDrawVisible = true
            viewDrawingActive.isUserInteractionEnabled = false
            self.containerViewCapture.bringSubviewToFront( viewDrawingActive)
            self.containerViewCapture.bringSubviewToFront( viewDrawingUndoRedo10)
            self.view.bringSubviewToFront( viewBrush)
            self.view.bringSubviewToFront( viewGrowingTextField)
            self.view.bringSubviewToFront( viewFilterIcon)
            self.view.bringSubviewToFront( viewEffectsIcon)
            tapGesture.isEnabled = true
            sender.tag = 1001
            sender.setImage(UIImage(named: "StoryIcons_FilterBrush")!.maskWithColor(color: navColor), for: .normal)
            stackViewEffectsIcon.alpha = 0.0
            viewEffectsIconHeightConstraint.constant = 0
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            viewBrushHeightConstraint.constant = viewBrushHeightConstraintConstant
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            btnEraseDrwaing.tag = 103
            btnEraseDrwaing.setImage(UIImage(named: "StoryIcons_FilterEraser")!.maskWithColor(color: .white), for: .normal)
            btnTextDraw.tag = 102
            btnTextDraw.setImage(UIImage(named: "StoryIcons_FilterText")!.maskWithColor(color: .white), for: .normal)
        }
        else
        {
            self.containerViewCapture.bringSubviewToFront( viewMovingActive)
            self.containerViewCapture.bringSubviewToFront( viewDrawingUndoRedo10)
            self.view.bringSubviewToFront( viewGrowingTextField)
            self.view.bringSubviewToFront( viewFilterIcon)
            self.view.bringSubviewToFront( viewEffectsIcon)
            swipeUp.isEnabled = true
            swipeDown.isEnabled = true
            tapGesture.isEnabled = true
            viewDrawingActive.isUserInteractionEnabled = false
            sender.tag = 101
            sender.setImage(UIImage(named: "StoryIcons_FilterBrush")!.maskWithColor(color: .white), for: .normal)
        }
        
    }
    
    @IBAction func btnTextViewDoneAction(_ sender: DesignableButton) {
        
        setViewHideShow(view: viewCropContainer, hidden: false)
        txtViewLarge.resignFirstResponder()
        if boolCheckIfTextClick == true {
            boolCheckIfTextClick = false
            viewDrawingUndoRedo10.isHidden = false
            setViewHideShow(view: viewDrawingActive, hidden: false)
        }
        setViewHideShow(view: viewTextViewLarge, hidden: true)
        // viewDrawContainer.isUserInteractionEnabled = false
        self.containerViewCapture.bringSubviewToFront( viewMovingActive)
        self.containerViewCapture.bringSubviewToFront( viewDrawingUndoRedo10)
        setViewHideShow(view: viewMovingActive, hidden: false)
        self.view.bringSubviewToFront( viewGrowingTextField)
        self.view.bringSubviewToFront( viewFilterIcon)
        self.view.bringSubviewToFront( viewEffectsIcon)
        
        
        if let textString = txtViewLarge.text, textString.count != 0
        {
            let font = UIFont.systemFont(ofSize: 20, weight: .medium)
            let lblMovingTextSize = textString.heightLabel(constraintedWidth: viewMovingActive.bounds.width - 40, font: font)
            self.setObjectInMovingView(strData: textString, dataType: .labelText, frame: CGRect(x: 0, y: 0, width: lblMovingTextSize.width + 40, height: lblMovingTextSize.height + 30), strColor: txtViewLarge.textColor!)
        }
        stackViewEffectsIcon.alpha = 1.0
        viewEffectsIconHeightConstraint.constant = viewEffectsIconHeightConstraintConstant
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        
        swipeUp.isEnabled = true
        swipeDown.isEnabled = true
        tapGesture.isEnabled = true
        
    }
    @IBAction func btnTextDrawAction(_ sender: UIButton) {
        
        setViewHideShow(view: viewCropContainer, hidden: true)
        if viewDrawingUndoRedo10.isHidden == false {
            boolCheckIfTextClick = true
            viewDrawingUndoRedo10.isHidden = true
            setViewHideShow(view: viewDrawingActive, hidden: true)
        }
        
        stackViewEffectsIcon.alpha = 0.0
        viewEffectsIconHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        sender.tag = 1002
        sender.setTitleColor(.red, for: .highlighted)
        btnEraseDrwaing.tag = 103
        btnEraseDrwaing.setImage(UIImage(named: "StoryIcons_FilterEraser")!.maskWithColor(color: .white), for: .normal)
        btnBrush.tag = 101
        btnBrush.setImage(UIImage(named: "StoryIcons_FilterBrush")!.maskWithColor(color: .white), for: .normal)
        setViewHideShow(view: viewTextViewLarge, hidden: false)
        self.view.bringSubviewToFront( viewGrowingTextField)
        self.view.bringSubviewToFront( viewFilterIcon)
        self.view.bringSubviewToFront( viewEffectsIcon)
        self.containerViewCapture.bringSubviewToFront( viewTextViewLarge)
        txtViewLarge.text = nil
        txtViewLarge.becomeFirstResponder()
        swipeUp.isEnabled = false
        swipeDown.isEnabled = false
        tapGesture.isEnabled = false
        viewDrawingActive.isUserInteractionEnabled = false
        
    }
    
    @IBAction func btnEmojiAction(_ sender: Any) {
        setViewHideShow(view: viewCropContainer, hidden: true)
        stackViewEffectsIcon.alpha = 0.0
        viewEffectsIconHeightConstraint.constant = 0
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc  = storyboard.instantiateViewController(withIdentifier: "ViewEmojiController") as! ViewEmojiController
        vc.view.backgroundColor = UIColor.clear
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegateEmoji = self
        present(vc, animated: true) {
        }
        
    }
    @IBAction func btnFilterAction(_ sender: UIButton) {
        
        btnEraseDrwaing.tag = 103
        btnEraseDrwaing.setImage(UIImage(named: "StoryIcons_FilterEraser")!.maskWithColor(color: .white), for: .normal)
        btnBrush.tag = 101
        btnBrush.setImage(UIImage(named: "StoryIcons_FilterBrush")!.maskWithColor(color: .white), for: .normal)
        
        viewDrawingActive.isUserInteractionEnabled = false
        swipeUp.isEnabled = true
        swipeDown.isEnabled = true
        tapGesture.isEnabled = true
        self.view.bringSubviewToFront( viewFilters)
        
        viewFiltersCollectionConstraintHeight.constant = viewFilterHeightConstraintConstant
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        stackViewEffectsIcon.alpha = 0.0
        viewEffectsIconHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        
    }
    @IBAction func btnStickerAction(_ sender: UIButton) {
        
        btnEraseDrwaing.tag = 103
        btnEraseDrwaing.setImage(UIImage(named: "StoryIcons_FilterEraser")!.maskWithColor(color: .white), for: .normal)
        btnBrush.tag = 101
        btnBrush.setImage(UIImage(named: "StoryIcons_FilterBrush")!.maskWithColor(color: .white), for: .normal)
        
        swipeUp.isEnabled = true
        swipeDown.isEnabled = true
        tapGesture.isEnabled = true
        viewDrawingActive.isUserInteractionEnabled = false
        
        self.view.bringSubviewToFront( viewSticker)
        viewStickerHeightConstraint.constant = viewStcikerHeightConstraintConstant
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        stackViewEffectsIcon.alpha = 0.0
        viewEffectsIconHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btnSendAction(_ sender: DesignableButton) {
        updateDataForAPI(isUpdateOnSend: true)
    }
    @IBAction func btnUndoAction(_ sender: UIButton)
    {
        viewDrawingActive.undo()
    }
    
    @IBAction func btnRedoAction(_ sender: UIButton)
    {
        viewDrawingActive.redo()
    }
    @IBAction func btnSkipAction(_ sender: UIButton)
    {
        currentlySelectedAsset.isViewDrawVisible = false
        viewDrawingActive.clearDrawing()
        viewDrawingActive.isUserInteractionEnabled = false
        swipeUp.isEnabled = true
        swipeDown.isEnabled = true
        tapGesture.isEnabled = true
        viewDrawingUndoRedo10.isHidden = true
        setViewHideShow(view: viewDrawingActive, hidden: true)
        btnEraseDrwaing.tag = 103
        btnEraseDrwaing.setImage(UIImage(named: "StoryIcons_FilterEraser")!.maskWithColor(color: .white), for: .normal)
        btnBrush.tag = 101
        btnBrush.setImage(UIImage(named: "StoryIcons_FilterBrush")!.maskWithColor(color: .white), for: .normal)
        btnTextDraw.tag = 102
        btnTextDraw.setImage(UIImage(named: "StoryIcons_FilterText")!.maskWithColor(color: .white), for: .normal)
        self.containerViewCapture.bringSubviewToFront( viewMovingActive)
        self.containerViewCapture.bringSubviewToFront( viewDrawingUndoRedo10)
        self.view.bringSubviewToFront( viewGrowingTextField)
        self.view.bringSubviewToFront( viewFilterIcon)
        self.view.bringSubviewToFront( viewEffectsIcon)
    }
    @IBAction func btnCropAction(_ sender: UIButton) {
        presentCropViewController()
    }
    
    //MARK: Crop Image
    func presentCropViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CropController") as! CropController
        var image = UIImage()
        if currentlySelectedAsset.imgFilter.size.width != 0
        {
            image = currentlySelectedAsset.imgFilter
        }
        else if currentlySelectedAsset.imgCrop.size.width != 0
        {
            image = currentlySelectedAsset.imgCrop
        }
        else
        {
            image = currentlySelectedAsset.fullResolutionImage!
        }
        controller.image = image
        controller.delegate = self
        self.present(controller, animated: false, completion: nil)
    }
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        imgSelectedInPreview = croppedImage
        let aspectRatio = croppedImage.size.width/croppedImage.size.height
        let requiredHeight = self.view.bounds.size.width / aspectRatio
        currentlySelectedAsset.imageHeight = requiredHeight
        if currentlySelectedAsset.imgFilter.size.width != 0
        {
            currentlySelectedAsset.imgFilter = croppedImage
        }
        currentlySelectedAsset.imgCrop = croppedImage
        arrSelectedAssests[selectedIndexMovingText] = currentlySelectedAsset
        let indexPath = IndexPath(item: selectedIndexMovingText, section: 0)
        self.collectionMainView.reloadItems(at: [indexPath])
        self.collectionPreview.reloadItems(at: [indexPath])
        self.dismiss(animated: false) {
            self.initializeFilterArray()
            self.collectionFilters.reloadData()
        }
    }
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func updateHeightConstraint()
    {
        switch arrSelectedAssests.count {
        case 1:
            let asset1 = arrSelectedAssests[0]
            viewMovingHeight1.constant = asset1.imageHeight
            viewDrawingHeight1.constant = asset1.imageHeight
        case 2:
            let asset1 = arrSelectedAssests[0]
            viewMovingHeight1.constant = asset1.imageHeight
            viewDrawingHeight1.constant = asset1.imageHeight
            
            let asset2 = arrSelectedAssests[1]
            viewMovingHeight2.constant = asset2.imageHeight
            viewDrawingHeight2.constant = asset2.imageHeight
        case 3:
            let asset1 = arrSelectedAssests[0]
            viewMovingHeight1.constant = asset1.imageHeight
            viewDrawingHeight1.constant = asset1.imageHeight
            
            let asset2 = arrSelectedAssests[1]
            viewMovingHeight2.constant = asset2.imageHeight
            viewDrawingHeight2.constant = asset2.imageHeight
            
            let asset3 = arrSelectedAssests[2]
            viewMovingHeight3.constant = asset3.imageHeight
            viewDrawingHeight3.constant = asset3.imageHeight
        case 4:
            let asset1 = arrSelectedAssests[0]
            viewMovingHeight1.constant = asset1.imageHeight
            viewDrawingHeight1.constant = asset1.imageHeight
            
            let asset2 = arrSelectedAssests[1]
            viewMovingHeight2.constant = asset2.imageHeight
            viewDrawingHeight2.constant = asset2.imageHeight
            
            let asset3 = arrSelectedAssests[2]
            viewMovingHeight3.constant = asset3.imageHeight
            viewDrawingHeight3.constant = asset3.imageHeight
            
            let asset4 = arrSelectedAssests[3]
            viewMovingHeight4.constant = asset4.imageHeight
            viewDrawingHeight4.constant = asset4.imageHeight
        case 5:
            let asset1 = arrSelectedAssests[0]
            viewMovingHeight1.constant = asset1.imageHeight
            viewDrawingHeight1.constant = asset1.imageHeight
            
            let asset2 = arrSelectedAssests[1]
            viewMovingHeight2.constant = asset2.imageHeight
            viewDrawingHeight2.constant = asset2.imageHeight
            
            let asset3 = arrSelectedAssests[2]
            viewMovingHeight3.constant = asset3.imageHeight
            viewDrawingHeight3.constant = asset3.imageHeight
            
            let asset4 = arrSelectedAssests[3]
            viewMovingHeight4.constant = asset4.imageHeight
            viewDrawingHeight4.constant = asset4.imageHeight
            
            let asset5 = arrSelectedAssests[4]
            viewMovingHeight5.constant = asset5.imageHeight
            viewDrawingHeight5.constant = asset5.imageHeight
        case 6:
            let asset1 = arrSelectedAssests[0]
            viewMovingHeight1.constant = asset1.imageHeight
            viewDrawingHeight1.constant = asset1.imageHeight
            
            let asset2 = arrSelectedAssests[1]
            viewMovingHeight2.constant = asset2.imageHeight
            viewDrawingHeight2.constant = asset2.imageHeight
            
            let asset3 = arrSelectedAssests[2]
            viewMovingHeight3.constant = asset3.imageHeight
            viewDrawingHeight3.constant = asset3.imageHeight
            
            let asset4 = arrSelectedAssests[3]
            viewMovingHeight4.constant = asset4.imageHeight
            viewDrawingHeight4.constant = asset4.imageHeight
            
            let asset5 = arrSelectedAssests[4]
            viewMovingHeight5.constant = asset5.imageHeight
            viewDrawingHeight5.constant = asset5.imageHeight
            
            let asset6 = arrSelectedAssests[5]
            viewMovingHeight6.constant = asset6.imageHeight
            viewDrawingHeight6.constant = asset6.imageHeight
        case 7:
            
            let asset1 = arrSelectedAssests[0]
            viewMovingHeight1.constant = asset1.imageHeight
            viewDrawingHeight1.constant = asset1.imageHeight
            
            let asset2 = arrSelectedAssests[1]
            viewMovingHeight2.constant = asset2.imageHeight
            viewDrawingHeight2.constant = asset2.imageHeight
            
            let asset3 = arrSelectedAssests[2]
            viewMovingHeight3.constant = asset3.imageHeight
            viewDrawingHeight3.constant = asset3.imageHeight
            
            let asset4 = arrSelectedAssests[3]
            viewMovingHeight4.constant = asset4.imageHeight
            viewDrawingHeight4.constant = asset4.imageHeight
            
            let asset5 = arrSelectedAssests[4]
            viewMovingHeight5.constant = asset5.imageHeight
            viewDrawingHeight5.constant = asset5.imageHeight
            
            let asset6 = arrSelectedAssests[5]
            viewMovingHeight6.constant = asset6.imageHeight
            viewDrawingHeight6.constant = asset6.imageHeight
            
            let asset7 = arrSelectedAssests[6]
            viewMovingHeight7.constant = asset7.imageHeight
            viewDrawingHeight7.constant = asset7.imageHeight
        case 8:
            
            let asset1 = arrSelectedAssests[0]
            viewMovingHeight1.constant = asset1.imageHeight
            viewDrawingHeight1.constant = asset1.imageHeight
            
            let asset2 = arrSelectedAssests[1]
            viewMovingHeight2.constant = asset2.imageHeight
            viewDrawingHeight2.constant = asset2.imageHeight
            
            let asset3 = arrSelectedAssests[2]
            viewMovingHeight3.constant = asset3.imageHeight
            viewDrawingHeight3.constant = asset3.imageHeight
            
            let asset4 = arrSelectedAssests[3]
            viewMovingHeight4.constant = asset4.imageHeight
            viewDrawingHeight4.constant = asset4.imageHeight
            
            let asset5 = arrSelectedAssests[4]
            viewMovingHeight5.constant = asset5.imageHeight
            viewDrawingHeight5.constant = asset5.imageHeight
            
            let asset6 = arrSelectedAssests[5]
            viewMovingHeight6.constant = asset6.imageHeight
            viewDrawingHeight6.constant = asset6.imageHeight
            
            let asset7 = arrSelectedAssests[6]
            viewMovingHeight7.constant = asset7.imageHeight
            viewDrawingHeight7.constant = asset7.imageHeight
            
            let asset8 = arrSelectedAssests[7]
            viewMovingHeight8.constant = asset8.imageHeight
            viewDrawingHeight8.constant = asset8.imageHeight
        case 9:
            
            let asset1 = arrSelectedAssests[0]
            viewMovingHeight1.constant = asset1.imageHeight
            viewDrawingHeight1.constant = asset1.imageHeight
            
            let asset2 = arrSelectedAssests[1]
            viewMovingHeight2.constant = asset2.imageHeight
            viewDrawingHeight2.constant = asset2.imageHeight
            
            let asset3 = arrSelectedAssests[2]
            viewMovingHeight3.constant = asset3.imageHeight
            viewDrawingHeight3.constant = asset3.imageHeight
            
            let asset4 = arrSelectedAssests[3]
            viewMovingHeight4.constant = asset4.imageHeight
            viewDrawingHeight4.constant = asset4.imageHeight
            
            let asset5 = arrSelectedAssests[4]
            viewMovingHeight5.constant = asset5.imageHeight
            viewDrawingHeight5.constant = asset5.imageHeight
            
            let asset6 = arrSelectedAssests[5]
            viewMovingHeight6.constant = asset6.imageHeight
            viewDrawingHeight6.constant = asset6.imageHeight
            
            let asset7 = arrSelectedAssests[6]
            viewMovingHeight7.constant = asset7.imageHeight
            viewDrawingHeight7.constant = asset7.imageHeight
            
            let asset8 = arrSelectedAssests[7]
            viewMovingHeight8.constant = asset8.imageHeight
            viewDrawingHeight8.constant = asset8.imageHeight
            
            let asset9 = arrSelectedAssests[8]
            viewMovingHeight9.constant = asset9.imageHeight
            viewDrawingHeight9.constant = asset9.imageHeight
        case 10:
            
            let asset1 = arrSelectedAssests[0]
            viewMovingHeight1.constant = asset1.imageHeight
            viewDrawingHeight1.constant = asset1.imageHeight
            
            let asset2 = arrSelectedAssests[1]
            viewMovingHeight2.constant = asset2.imageHeight
            viewDrawingHeight2.constant = asset2.imageHeight
            
            let asset3 = arrSelectedAssests[2]
            viewMovingHeight3.constant = asset3.imageHeight
            viewDrawingHeight3.constant = asset3.imageHeight
            
            let asset4 = arrSelectedAssests[3]
            viewMovingHeight4.constant = asset4.imageHeight
            viewDrawingHeight4.constant = asset4.imageHeight
            
            let asset5 = arrSelectedAssests[4]
            viewMovingHeight5.constant = asset5.imageHeight
            viewDrawingHeight5.constant = asset5.imageHeight
            
            let asset6 = arrSelectedAssests[5]
            viewMovingHeight6.constant = asset6.imageHeight
            viewDrawingHeight6.constant = asset6.imageHeight
            
            let asset7 = arrSelectedAssests[6]
            viewMovingHeight7.constant = asset7.imageHeight
            viewDrawingHeight7.constant = asset7.imageHeight
            
            let asset8 = arrSelectedAssests[7]
            viewMovingHeight8.constant = asset8.imageHeight
            viewDrawingHeight8.constant = asset8.imageHeight
            
            let asset9 = arrSelectedAssests[8]
            viewMovingHeight9.constant = asset9.imageHeight
            viewDrawingHeight9.constant = asset9.imageHeight
            
            let asset10 = arrSelectedAssests[9]
            viewMovingHeight10.constant = asset10.imageHeight
            viewDrawingHeight10.constant = asset10.imageHeight
        default:
            print("None")
        }
    }
    func updateUIAsPerAssets()
    {
        switch arrSelectedAssests.count {
        case 1:
            viewMoving1.isHidden = false
            viewMoving2.isHidden = true
            viewMoving3.isHidden = true
            viewMoving4.isHidden = true
            viewMoving5.isHidden = true
            viewMoving6.isHidden = true
            viewMoving7.isHidden = true
            viewMoving8.isHidden = true
            viewMoving9.isHidden = true
            viewMoving10.isHidden = true
            
            viewDrawing1.setWidth(10)
            viewDrawing1.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha1))
            
            var asset1 = arrSelectedAssests[0]
            asset1.viewMoving = viewMoving1
            asset1.viewDrawing = viewDrawing1
            asset1.colorAlpha = colorAlpha1
            asset1.deltaWidth = deltaWidth1
            
            arrSelectedAssests[0] = asset1
            
        case 2:
            viewMoving1.isHidden = false
            viewMoving2.isHidden = false
            viewMoving3.isHidden = true
            viewMoving4.isHidden = true
            viewMoving5.isHidden = true
            viewMoving6.isHidden = true
            viewMoving7.isHidden = true
            viewMoving8.isHidden = true
            viewMoving9.isHidden = true
            viewMoving10.isHidden = true
            
            viewDrawing1.setWidth(10)
            viewDrawing1.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha1))
            
            viewDrawing2.setWidth(10)
            viewDrawing2.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha2))
            
            var asset1 = arrSelectedAssests[0]
            asset1.viewMoving = viewMoving1
            asset1.viewDrawing = viewDrawing1
            asset1.colorAlpha = colorAlpha1
            asset1.deltaWidth = deltaWidth1
            
            arrSelectedAssests[0] = asset1
            
            var asset2 = arrSelectedAssests[1]
            asset2.viewMoving = viewMoving2
            asset2.viewDrawing = viewDrawing2
            asset2.colorAlpha = colorAlpha2
            asset2.deltaWidth = deltaWidth2
            
            arrSelectedAssests[1] = asset2
            
            
        case 3:
            viewMoving1.isHidden = false
            viewMoving2.isHidden = false
            viewMoving3.isHidden = false
            viewMoving4.isHidden = true
            viewMoving5.isHidden = true
            viewMoving6.isHidden = true
            viewMoving7.isHidden = true
            viewMoving8.isHidden = true
            viewMoving9.isHidden = true
            viewMoving10.isHidden = true
            
            viewDrawing1.setWidth(10)
            viewDrawing1.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha1))
            
            viewDrawing2.setWidth(10)
            viewDrawing2.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha2))
            
            viewDrawing3.setWidth(10)
            viewDrawing3.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha3))
            
            var asset1 = arrSelectedAssests[0]
            asset1.viewMoving = viewMoving1
            asset1.viewDrawing = viewDrawing1
            asset1.colorAlpha = colorAlpha1
            asset1.deltaWidth = deltaWidth1
            
            arrSelectedAssests[0] = asset1
            
            var asset2 = arrSelectedAssests[1]
            asset2.viewMoving = viewMoving2
            asset2.viewDrawing = viewDrawing2
            asset2.colorAlpha = colorAlpha2
            asset2.deltaWidth = deltaWidth2
            arrSelectedAssests[1] = asset2
            
            var asset3 = arrSelectedAssests[2]
            asset3.viewMoving = viewMoving3
            asset3.viewDrawing = viewDrawing3
            asset3.colorAlpha = colorAlpha3
            asset3.deltaWidth = deltaWidth3
            arrSelectedAssests[2] = asset3
            
            
        case 4:
            viewMoving1.isHidden = false
            viewMoving2.isHidden = false
            viewMoving3.isHidden = false
            viewMoving4.isHidden = false
            viewMoving5.isHidden = true
            viewMoving6.isHidden = true
            viewMoving7.isHidden = true
            viewMoving8.isHidden = true
            viewMoving9.isHidden = true
            viewMoving10.isHidden = true
            
            viewDrawing1.setWidth(10)
            viewDrawing1.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha1))
            
            viewDrawing2.setWidth(10)
            viewDrawing2.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha2))
            
            viewDrawing3.setWidth(10)
            viewDrawing3.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha3))
            
            viewDrawing4.setWidth(10)
            viewDrawing4.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha4))
            
            var asset1 = arrSelectedAssests[0]
            asset1.viewMoving = viewMoving1
            asset1.viewDrawing = viewDrawing1
            asset1.colorAlpha = colorAlpha1
            asset1.deltaWidth = deltaWidth1
            
            arrSelectedAssests[0] = asset1
            
            var asset2 = arrSelectedAssests[1]
            asset2.viewMoving = viewMoving2
            asset2.viewDrawing = viewDrawing2
            asset2.colorAlpha = colorAlpha2
            asset2.deltaWidth = deltaWidth2
            
            arrSelectedAssests[1] = asset2
            
            var asset3 = arrSelectedAssests[2]
            asset3.viewMoving = viewMoving3
            asset3.viewDrawing = viewDrawing3
            asset3.colorAlpha = colorAlpha3
            asset3.deltaWidth = deltaWidth3
            
            arrSelectedAssests[2] = asset3
            
            var asset4 = arrSelectedAssests[3]
            asset4.viewMoving = viewMoving4
            asset4.viewDrawing = viewDrawing4
            asset4.colorAlpha = colorAlpha4
            asset4.deltaWidth = deltaWidth4
            arrSelectedAssests[3] = asset4
            
            
        case 5:
            viewMoving1.isHidden = false
            viewMoving2.isHidden = false
            viewMoving3.isHidden = false
            viewMoving4.isHidden = false
            viewMoving5.isHidden = false
            viewMoving6.isHidden = true
            viewMoving7.isHidden = true
            viewMoving8.isHidden = true
            viewMoving9.isHidden = true
            viewMoving10.isHidden = true
            
            viewDrawing1.setWidth(10)
            viewDrawing1.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha1))
            
            viewDrawing2.setWidth(10)
            viewDrawing2.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha2))
            
            viewDrawing3.setWidth(10)
            viewDrawing3.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha3))
            
            viewDrawing4.setWidth(10)
            viewDrawing4.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha4))
            
            viewDrawing5.setWidth(10)
            viewDrawing5.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha5))
            
            var asset1 = arrSelectedAssests[0]
            asset1.viewMoving = viewMoving1
            asset1.viewDrawing = viewDrawing1
            asset1.colorAlpha = colorAlpha1
            asset1.deltaWidth = deltaWidth1
            
            arrSelectedAssests[0] = asset1
            
            var asset2 = arrSelectedAssests[1]
            asset2.viewMoving = viewMoving2
            asset2.viewDrawing = viewDrawing2
            asset2.colorAlpha = colorAlpha2
            asset2.deltaWidth = deltaWidth2
            
            arrSelectedAssests[1] = asset2
            
            var asset3 = arrSelectedAssests[2]
            asset3.viewMoving = viewMoving3
            asset3.viewDrawing = viewDrawing3
            asset3.colorAlpha = colorAlpha3
            asset3.deltaWidth = deltaWidth3
            arrSelectedAssests[2] = asset3
            
            var asset4 = arrSelectedAssests[3]
            asset4.viewMoving = viewMoving4
            asset4.viewDrawing = viewDrawing4
            asset4.colorAlpha = colorAlpha4
            asset4.deltaWidth = deltaWidth4
            arrSelectedAssests[3] = asset4
            
            var asset5 = arrSelectedAssests[4]
            asset5.viewMoving = viewMoving5
            asset5.viewDrawing = viewDrawing5
            asset5.colorAlpha = colorAlpha5
            asset5.deltaWidth = deltaWidth5
            
            arrSelectedAssests[4] = asset5
            
        case 6:
            viewMoving1.isHidden = false
            viewMoving2.isHidden = false
            viewMoving3.isHidden = false
            viewMoving4.isHidden = false
            viewMoving5.isHidden = false
            viewMoving6.isHidden = false
            viewMoving7.isHidden = true
            viewMoving8.isHidden = true
            viewMoving9.isHidden = true
            viewMoving10.isHidden = true
            
            viewDrawing1.setWidth(10)
            viewDrawing1.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha1))
            
            viewDrawing2.setWidth(10)
            viewDrawing2.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha2))
            
            viewDrawing3.setWidth(10)
            viewDrawing3.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha3))
            
            viewDrawing4.setWidth(10)
            viewDrawing4.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha4))
            
            viewDrawing5.setWidth(10)
            viewDrawing5.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha5))
            
            viewDrawing6.setWidth(10)
            viewDrawing6.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha6))
            
            var asset1 = arrSelectedAssests[0]
            asset1.viewMoving = viewMoving1
            asset1.viewDrawing = viewDrawing1
            asset1.colorAlpha = colorAlpha1
            asset1.deltaWidth = deltaWidth1
            
            arrSelectedAssests[0] = asset1
            
            var asset2 = arrSelectedAssests[1]
            asset2.viewMoving = viewMoving2
            asset2.viewDrawing = viewDrawing2
            asset2.colorAlpha = colorAlpha2
            asset2.deltaWidth = deltaWidth2
            
            arrSelectedAssests[1] = asset2
            
            var asset3 = arrSelectedAssests[2]
            asset3.viewMoving = viewMoving3
            asset3.viewDrawing = viewDrawing3
            asset3.colorAlpha = colorAlpha3
            asset3.deltaWidth = deltaWidth3
            
            arrSelectedAssests[2] = asset3
            
            var asset4 = arrSelectedAssests[3]
            asset4.viewMoving = viewMoving4
            asset4.viewDrawing = viewDrawing4
            asset4.colorAlpha = colorAlpha4
            asset4.deltaWidth = deltaWidth4
            arrSelectedAssests[3] = asset4
            
            var asset5 = arrSelectedAssests[4]
            asset5.viewMoving = viewMoving5
            asset5.viewDrawing = viewDrawing5
            asset5.colorAlpha = colorAlpha5
            asset5.deltaWidth = deltaWidth5
            
            arrSelectedAssests[4] = asset5
            
            var asset6 = arrSelectedAssests[5]
            asset6.viewMoving = viewMoving6
            asset6.viewDrawing = viewDrawing6
            asset6.colorAlpha = colorAlpha6
            asset6.deltaWidth = deltaWidth6
            
            arrSelectedAssests[5] = asset6
            
        case 7:
            viewMoving1.isHidden = false
            viewMoving2.isHidden = false
            viewMoving3.isHidden = false
            viewMoving4.isHidden = false
            viewMoving5.isHidden = false
            viewMoving6.isHidden = false
            viewMoving7.isHidden = false
            viewMoving8.isHidden = true
            viewMoving9.isHidden = true
            viewMoving10.isHidden = true
            
            viewDrawing1.setWidth(10)
            viewDrawing1.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha1))
            
            viewDrawing2.setWidth(10)
            viewDrawing2.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha2))
            
            viewDrawing3.setWidth(10)
            viewDrawing3.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha3))
            
            viewDrawing4.setWidth(10)
            viewDrawing4.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha4))
            
            viewDrawing5.setWidth(10)
            viewDrawing5.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha5))
            
            viewDrawing6.setWidth(10)
            viewDrawing6.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha6))
            
            viewDrawing7.setWidth(10)
            viewDrawing7.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha7))
            
            var asset1 = arrSelectedAssests[0]
            asset1.viewMoving = viewMoving1
            asset1.viewDrawing = viewDrawing1
            asset1.colorAlpha = colorAlpha1
            asset1.deltaWidth = deltaWidth1
            
            arrSelectedAssests[0] = asset1
            
            var asset2 = arrSelectedAssests[1]
            asset2.viewMoving = viewMoving2
            asset2.viewDrawing = viewDrawing2
            asset2.colorAlpha = colorAlpha2
            asset2.deltaWidth = deltaWidth2
            
            arrSelectedAssests[1] = asset2
            
            var asset3 = arrSelectedAssests[2]
            asset3.viewMoving = viewMoving3
            asset3.viewDrawing = viewDrawing3
            asset3.colorAlpha = colorAlpha3
            asset3.deltaWidth = deltaWidth3
            
            arrSelectedAssests[2] = asset3
            
            var asset4 = arrSelectedAssests[3]
            asset4.viewMoving = viewMoving4
            asset4.viewDrawing = viewDrawing4
            asset4.colorAlpha = colorAlpha4
            asset4.deltaWidth = deltaWidth4
            
            arrSelectedAssests[3] = asset4
            
            var asset5 = arrSelectedAssests[4]
            asset5.viewMoving = viewMoving5
            asset5.viewDrawing = viewDrawing5
            asset5.colorAlpha = colorAlpha5
            asset5.deltaWidth = deltaWidth5
            
            arrSelectedAssests[4] = asset5
            
            var asset6 = arrSelectedAssests[5]
            asset6.viewMoving = viewMoving6
            asset6.viewDrawing = viewDrawing6
            asset6.colorAlpha = colorAlpha6
            asset6.deltaWidth = deltaWidth6
            
            arrSelectedAssests[5] = asset6
            
            var asset7 = arrSelectedAssests[6]
            asset7.viewMoving = viewMoving7
            asset7.viewDrawing = viewDrawing7
            asset7.colorAlpha = colorAlpha7
            asset7.deltaWidth = deltaWidth7
            
            arrSelectedAssests[6] = asset7
            
        case 8:
            viewMoving1.isHidden = false
            viewMoving2.isHidden = false
            viewMoving3.isHidden = false
            viewMoving4.isHidden = false
            viewMoving5.isHidden = false
            viewMoving6.isHidden = false
            viewMoving7.isHidden = false
            viewMoving8.isHidden = false
            viewMoving9.isHidden = true
            viewMoving10.isHidden = true
            
            viewDrawing1.setWidth(10)
            viewDrawing1.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha1))
            
            viewDrawing2.setWidth(10)
            viewDrawing2.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha2))
            
            viewDrawing3.setWidth(10)
            viewDrawing3.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha3))
            
            viewDrawing4.setWidth(10)
            viewDrawing4.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha4))
            
            viewDrawing5.setWidth(10)
            viewDrawing5.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha5))
            
            viewDrawing6.setWidth(10)
            viewDrawing6.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha6))
            
            viewDrawing7.setWidth(10)
            viewDrawing7.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha7))
            
            viewDrawing8.setWidth(10)
            viewDrawing8.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha8))
            
            var asset1 = arrSelectedAssests[0]
            asset1.viewMoving = viewMoving1
            asset1.viewDrawing = viewDrawing1
            asset1.colorAlpha = colorAlpha1
            asset1.deltaWidth = deltaWidth1
            
            arrSelectedAssests[0] = asset1
            
            var asset2 = arrSelectedAssests[1]
            asset2.viewMoving = viewMoving2
            asset2.viewDrawing = viewDrawing2
            asset2.colorAlpha = colorAlpha2
            asset2.deltaWidth = deltaWidth2
            
            arrSelectedAssests[1] = asset2
            
            var asset3 = arrSelectedAssests[2]
            asset3.viewMoving = viewMoving3
            asset3.viewDrawing = viewDrawing3
            asset3.colorAlpha = colorAlpha3
            asset3.deltaWidth = deltaWidth3
            
            arrSelectedAssests[2] = asset3
            
            var asset4 = arrSelectedAssests[3]
            asset4.viewMoving = viewMoving4
            asset4.viewDrawing = viewDrawing4
            asset4.colorAlpha = colorAlpha4
            asset4.deltaWidth = deltaWidth4
            
            arrSelectedAssests[3] = asset4
            
            var asset5 = arrSelectedAssests[4]
            asset5.viewMoving = viewMoving5
            asset5.viewDrawing = viewDrawing5
            asset5.colorAlpha = colorAlpha5
            asset5.deltaWidth = deltaWidth5
            
            arrSelectedAssests[4] = asset5
            
            var asset6 = arrSelectedAssests[5]
            asset6.viewMoving = viewMoving6
            asset6.viewDrawing = viewDrawing6
            asset6.colorAlpha = colorAlpha6
            asset6.deltaWidth = deltaWidth6
            
            arrSelectedAssests[5] = asset6
            
            var asset7 = arrSelectedAssests[6]
            asset7.viewMoving = viewMoving7
            asset7.viewDrawing = viewDrawing7
            asset7.colorAlpha = colorAlpha7
            asset7.deltaWidth = deltaWidth7
            
            arrSelectedAssests[6] = asset7
            
            var asset8 = arrSelectedAssests[7]
            asset8.viewMoving = viewMoving8
            asset8.viewDrawing = viewDrawing8
            asset8.colorAlpha = colorAlpha8
            asset8.deltaWidth = deltaWidth8
            
            arrSelectedAssests[7] = asset8
            
            
        case 9:
            viewMoving1.isHidden = false
            viewMoving2.isHidden = false
            viewMoving3.isHidden = false
            viewMoving4.isHidden = false
            viewMoving5.isHidden = false
            viewMoving6.isHidden = false
            viewMoving7.isHidden = false
            viewMoving8.isHidden = false
            viewMoving9.isHidden = false
            viewMoving10.isHidden = true
            
            viewDrawing1.setWidth(10)
            viewDrawing1.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha1))
            
            viewDrawing2.setWidth(10)
            viewDrawing2.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha2))
            
            viewDrawing3.setWidth(10)
            viewDrawing3.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha3))
            
            viewDrawing4.setWidth(10)
            viewDrawing4.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha4))
            
            viewDrawing5.setWidth(10)
            viewDrawing5.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha5))
            
            viewDrawing6.setWidth(10)
            viewDrawing6.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha6))
            
            viewDrawing7.setWidth(10)
            viewDrawing7.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha7))
            
            viewDrawing8.setWidth(10)
            viewDrawing8.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha8))
            
            viewDrawing9.setWidth(10)
            viewDrawing9.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha9))
            
            var asset1 = arrSelectedAssests[0]
            asset1.viewMoving = viewMoving1
            asset1.viewDrawing = viewDrawing1
            asset1.colorAlpha = colorAlpha1
            asset1.deltaWidth = deltaWidth1
            
            arrSelectedAssests[0] = asset1
            
            var asset2 = arrSelectedAssests[1]
            asset2.viewMoving = viewMoving2
            asset2.viewDrawing = viewDrawing2
            asset2.colorAlpha = colorAlpha2
            asset2.deltaWidth = deltaWidth2
            
            arrSelectedAssests[1] = asset2
            
            var asset3 = arrSelectedAssests[2]
            asset3.viewMoving = viewMoving3
            asset3.viewDrawing = viewDrawing3
            asset3.colorAlpha = colorAlpha3
            asset3.deltaWidth = deltaWidth3
            
            arrSelectedAssests[2] = asset3
            
            var asset4 = arrSelectedAssests[3]
            asset4.viewMoving = viewMoving4
            asset4.viewDrawing = viewDrawing4
            asset4.colorAlpha = colorAlpha4
            asset4.deltaWidth = deltaWidth4
            
            arrSelectedAssests[3] = asset4
            
            var asset5 = arrSelectedAssests[4]
            asset5.viewMoving = viewMoving5
            asset5.viewDrawing = viewDrawing5
            asset5.colorAlpha = colorAlpha5
            asset5.deltaWidth = deltaWidth5
            
            arrSelectedAssests[4] = asset5
            
            var asset6 = arrSelectedAssests[5]
            asset6.viewMoving = viewMoving6
            asset6.viewDrawing = viewDrawing6
            asset6.colorAlpha = colorAlpha6
            asset6.deltaWidth = deltaWidth6
            
            arrSelectedAssests[5] = asset6
            
            var asset7 = arrSelectedAssests[6]
            asset7.viewMoving = viewMoving7
            asset7.viewDrawing = viewDrawing7
            asset7.colorAlpha = colorAlpha7
            asset7.deltaWidth = deltaWidth7
            
            arrSelectedAssests[6] = asset7
            
            var asset8 = arrSelectedAssests[7]
            asset8.viewMoving = viewMoving8
            asset8.viewDrawing = viewDrawing8
            asset8.colorAlpha = colorAlpha8
            asset8.deltaWidth = deltaWidth8
            
            arrSelectedAssests[7] = asset8
            
            var asset9 = arrSelectedAssests[8]
            asset9.viewMoving = viewMoving9
            asset9.viewDrawing = viewDrawing9
            asset9.colorAlpha = colorAlpha9
            asset9.deltaWidth = deltaWidth9
            
            arrSelectedAssests[8] = asset9
            
        case 10:
            viewMoving1.isHidden = false
            viewMoving2.isHidden = false
            viewMoving3.isHidden = false
            viewMoving4.isHidden = false
            viewMoving5.isHidden = false
            viewMoving6.isHidden = false
            viewMoving7.isHidden = false
            viewMoving8.isHidden = false
            viewMoving9.isHidden = false
            viewMoving10.isHidden = false
            
            viewDrawing1.setWidth(10)
            viewDrawing1.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha1))
            
            viewDrawing2.setWidth(10)
            viewDrawing2.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha2))
            
            viewDrawing3.setWidth(10)
            viewDrawing3.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha3))
            
            viewDrawing4.setWidth(10)
            viewDrawing4.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha4))
            
            viewDrawing5.setWidth(10)
            viewDrawing5.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha5))
            
            viewDrawing6.setWidth(10)
            viewDrawing6.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha6))
            
            viewDrawing7.setWidth(10)
            viewDrawing7.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha7))
            
            viewDrawing8.setWidth(10)
            viewDrawing8.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha8))
            
            viewDrawing9.setWidth(10)
            viewDrawing9.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha9))
            
            viewDrawing10.setWidth(10)
            viewDrawing10.setColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(colorAlpha10))
            
            var asset1 = arrSelectedAssests[0]
            asset1.viewMoving = viewMoving1
            asset1.viewDrawing = viewDrawing1
            asset1.colorAlpha = colorAlpha1
            asset1.deltaWidth = deltaWidth1
            
            arrSelectedAssests[0] = asset1
            
            var asset2 = arrSelectedAssests[1]
            asset2.viewMoving = viewMoving2
            asset2.viewDrawing = viewDrawing2
            asset2.colorAlpha = colorAlpha2
            asset2.deltaWidth = deltaWidth2
            
            arrSelectedAssests[1] = asset2
            
            var asset3 = arrSelectedAssests[2]
            asset3.viewMoving = viewMoving3
            asset3.viewDrawing = viewDrawing3
            asset3.colorAlpha = colorAlpha3
            asset3.deltaWidth = deltaWidth3
            
            arrSelectedAssests[2] = asset3
            
            var asset4 = arrSelectedAssests[3]
            asset4.viewMoving = viewMoving4
            asset4.viewDrawing = viewDrawing4
            asset4.colorAlpha = colorAlpha4
            asset4.deltaWidth = deltaWidth4
            
            arrSelectedAssests[3] = asset4
            
            var asset5 = arrSelectedAssests[4]
            asset5.viewMoving = viewMoving5
            asset5.viewDrawing = viewDrawing5
            asset5.colorAlpha = colorAlpha5
            asset5.deltaWidth = deltaWidth5
            
            arrSelectedAssests[4] = asset5
            
            var asset6 = arrSelectedAssests[5]
            asset6.viewMoving = viewMoving6
            asset6.viewDrawing = viewDrawing6
            asset6.colorAlpha = colorAlpha6
            asset6.deltaWidth = deltaWidth6
            
            arrSelectedAssests[5] = asset6
            
            var asset7 = arrSelectedAssests[6]
            asset7.viewMoving = viewMoving7
            asset7.viewDrawing = viewDrawing7
            asset7.colorAlpha = colorAlpha7
            asset7.deltaWidth = deltaWidth7
            
            arrSelectedAssests[6] = asset7
            
            var asset8 = arrSelectedAssests[7]
            asset8.viewMoving = viewMoving8
            asset8.viewDrawing = viewDrawing8
            asset8.colorAlpha = colorAlpha8
            asset8.deltaWidth = deltaWidth8
            
            arrSelectedAssests[7] = asset8
            
            var asset9 = arrSelectedAssests[8]
            asset9.viewMoving = viewMoving9
            asset9.viewDrawing = viewDrawing9
            asset9.colorAlpha = colorAlpha9
            asset9.deltaWidth = deltaWidth9
            
            arrSelectedAssests[8] = asset9
            
            var asset10 = arrSelectedAssests[9]
            asset10.viewMoving = viewMoving10
            asset10.viewDrawing = viewDrawing10
            asset10.colorAlpha = colorAlpha10
            asset10.deltaWidth = deltaWidth10
            
            arrSelectedAssests[9] = asset10
            
        default:
            print("None")
        }
    }
    
    func setCurrentlyActiveViews()
    {
        viewMovingActive = currentlySelectedAsset.viewMoving
        viewDrawingActive = currentlySelectedAsset.viewDrawing
        colorAlphaActive = currentlySelectedAsset.colorAlpha
        deltaWidthActive = currentlySelectedAsset.deltaWidth
        viewDrawingUndoRedo10.isHidden = !currentlySelectedAsset.isViewDrawVisible
        
    }
    
    
    func hideShowAsPerIndex()
    {
        viewMoving1.alpha = 0.0
        viewMoving2.alpha = 0.0
        viewMoving3.alpha = 0.0
        viewMoving4.alpha = 0.0
        viewMoving5.alpha = 0.0
        viewMoving6.alpha = 0.0
        viewMoving7.alpha = 0.0
        viewMoving8.alpha = 0.0
        viewMoving9.alpha = 0.0
        viewMoving10.alpha = 0.0
        
        viewDrawing1.alpha = 0.0
        viewDrawing2.alpha = 0.0
        viewDrawing3.alpha = 0.0
        viewDrawing4.alpha = 0.0
        viewDrawing5.alpha = 0.0
        viewDrawing6.alpha = 0.0
        viewDrawing7.alpha = 0.0
        viewDrawing8.alpha = 0.0
        viewDrawing9.alpha = 0.0
        viewDrawing10.alpha = 0.0
        
        viewMovingActive.alpha = 1.0
        viewDrawingActive.alpha = 1.0
    }
    
    func initializeFilterArray()
    {
        arrFilterImages.removeAll()
        guard let image = imgSelectedInPreview.resized(withPercentage: 0.3) else{
            return
        }
        for (Index,dic) in CIFilterNames.enumerated()
        {
            let ciContext = CIContext(options: nil)
            if let filter = CIFilter(name: "\(dic["effect"]!)")
            {
                let coreImage = CIImage(image: image)
                filter.setDefaults()
                filter.setValue(coreImage, forKey: kCIInputImageKey)
                if let output = filter.outputImage
                {
                    if let cgimg = ciContext.createCGImage(output, from: output.extent) {
                        let processedImage = UIImage(cgImage: cgimg)
                        let dic = ["effectImage": processedImage, "name": dic["name"]!, "effect": dic["effect"]!] as [String : Any]
                        
                        let isObjectExist = arrFilterImages.contains { animal in
                            if case dic["name"] as! String = animal["name"] as! String {
                                return true
                            }
                            return false
                        }
                        if isObjectExist
                        {
                            if arrFilterImages.count > Index
                            {
                                arrFilterImages.remove(at: Index)
                            }
                        }
                        arrFilterImages.append(dic)
                    }
                }
            }
        }
        
        let dic = ["effectImage": image, "name":"Original", "effect": "Original"] as [String : Any]
        let isObjectExist = arrFilterImages.contains { animal in
            if case dic["name"] as! String = animal["name"] as! String {
                return true
            }
            return false
        }
        if isObjectExist
        {
            if arrFilterImages.count != 0
            {
                arrFilterImages.remove(at: 0)
            }
        }
        arrFilterImages.insert(dic, at: 0)
        
    }
    
    
    func image(with view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            // 1. when I create the UIImage - clearColor background
            context.setFillColor(UIColor.clear.cgColor);
            context.fill(view.bounds);
            
            // 2. when I create the UIImage - clear background
            context.clear(view.bounds);
            
            view.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
    func updateDataForAPI(isUpdateOnSend: Bool)
    {
        //        if currentlySelectedAsset.isVideoSelected
        //        {
        //            currentlySelectedAsset.strDescription = arrTextGrowData[0].text
        //            arrSelectedAssests[0] = currentlySelectedAsset
        //
        //            let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //            let vc  = storyboard.instantiateViewController(withIdentifier: "ShareStoryController") as! ShareStoryController
        //            self.navigationController?.pushViewController(vc, animated: true)
        //        }
        //        else
        //        {
        hideShowBorderAmongMovingObjects(isHidden: true)
        let imageDrawing = UIImage.imageWithView(view: self.viewDrawingActive)
        self.currentlySelectedAsset.imgPassdrawingAPI = imageDrawing
        if let imageMoving = image(with: self.viewMovingActive)
        {
            self.currentlySelectedAsset.imgPassMovingAPI = imageMoving
        }
        self.hideShowBorderAmongMovingObjects(isHidden: false)
        if isUpdateOnSend
        {
            arrSelectedAssests[selectedIndexMovingText] = self.currentlySelectedAsset
            self.updateDataIntoArrayForAPI()
        }
        //       }
        
    }
    func hideShowBorderAmongMovingObjects(isHidden : Bool)
    {
        for viewSubview in viewMovingActive.subviews
        {
            if let view = viewSubview as? ViewMovingText
            {
                view.hideBordarAndButton(isHidden: isHidden)
            }
        }
    }
    func updateDataIntoArrayForAPI()
    {
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        
        self.imgAPIAppearenceView.isHidden = false
        self.view.bringSubviewToFront( self.imgAPIAppearenceView)
        
        for (index, var asset) in arrSelectedAssests.enumerated()
        {
            if currentlySelectedAsset.isVideoSelected
            {
                if asset.imgFilter.size.width != 0
                {
                    asset.imgFinalPassAPI = asset.imgFilter
                }
                else if asset.imgCrop.size.width != 0
                {
                    asset.imgFinalPassAPI = asset.imgCrop
                }
                else
                {
                    if let img = asset.fullResolutionImage {
                        asset.imgFinalPassAPI = img
                    }
                    else {
                        asset.imgFinalPassAPI = imgSelectedInPreview
                    }
                    
                }
                // self.imgAPIAppearence.alpha = 0
                self.imgAPIAppearenceDrawing.image = asset.imgPassdrawingAPI
                self.imgAPIAppearenceMoving.image = asset.imgPassMovingAPI
                imgAPIAppearenceViewHeight.constant = asset.imageHeight
                self.imgAPIAppearenceView.layoutIfNeeded()
                if let imageFinal = image(with: self.imgAPIAppearenceView)
                {
                    let data = imageFinal.pngData()
                    asset.imgFinalTransparentVideoImage = UIImage(data: data!)!
                }
                
                
            }
            else
            {
                if asset.imgFilter.size.width != 0
                {
                    self.imgAPIAppearence.image = asset.imgFilter
                }
                else if asset.imgCrop.size.width != 0
                {
                    self.imgAPIAppearence.image = asset.imgCrop
                }
                else
                {
                    self.imgAPIAppearence.image = asset.fullResolutionImage
                }
                self.imgAPIAppearenceDrawing.image = asset.imgPassdrawingAPI  //imgFinalTransparentVideoImage
                self.imgAPIAppearenceMoving.image = asset.imgPassMovingAPI
                imgAPIAppearenceViewHeight.constant = asset.imageHeight
                self.imgAPIAppearenceView.layoutIfNeeded()
                let imageFinal = UIImage.imageWithView(view: self.imgAPIAppearenceView)
                asset.imgFinalPassAPI = imageFinal
            }
            asset.strDescription = arrTextGrowData[index].text
            arrSelectedAssests[index] = asset
        }
        
        activityIndicatorView.stopAnimating()
        imgAPIAppearenceView.isHidden = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc  = storyboard.instantiateViewController(withIdentifier: "ShareStoryController") as! ShareStoryController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    var boolT = false
    @IBAction func btnShowNext(_ sender: UIButton)
    {
        if arrSelectedAssests.count > sender.tag
        {
            let asset = arrSelectedAssests[sender.tag]
            self.imgAPIAppearence.isHidden = false
            self.imgAPIAppearenceDrawing.isHidden = false
            self.imgAPIAppearenceMoving.isHidden = false
            self.imgAPIAppearenceFinal.image = asset.imgFinalPassAPI
            sender.tag += 1
        }
        else
        {
            sender.tag = 0
        }
    }
    
    //MARK:- View Moving Methods
    var viewMovingText = ViewMovingText()
    func setObjectInMovingView(strData : String, dataType: ViewMovingObjectType, frame: CGRect, strColor: UIColor)
    {
        //var viewMovingText: ViewMovingText!
        switch dataType {
        case .labelText:
            viewMovingText = ViewMovingText(frame : frame, dataType : .labelText, strData : "")
            viewMovingText.createMovingLabel(colorLabel: strColor, text: strData)
        case .emojiText:
            viewMovingText = ViewMovingText(frame : frame, dataType : .emojiText, strData : strData)
        case .stickerImage:
            viewMovingText = ViewMovingText(frame : frame, dataType : .stickerImage, strData : strData)
        }
        // print(viewMovingText.subviews)
        //  viewMovingText = viewMovingText.returnMainObject()
        //   print(viewMovingText.subviews)
        //   print(viewMovingText.viewContainer.subviews)
        viewMovingText.tag = 1001
        viewMovingActive.addSubview(viewMovingText)
        viewMovingText.center = CGPoint(x: viewMovingActive.frame.width / 2, y: viewMovingActive.frame.height / 2)
        let rotationGesture = UIRotationGestureRecognizer.init(target: self, action: #selector(rotate(gesture:)))
        viewMovingText.addGestureRecognizer(rotationGesture)
        let pinchGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(scale(gesture:)))
        viewMovingText.addGestureRecognizer(pinchGesture)
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(pan(gesture:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        viewMovingText.addGestureRecognizer(panGesture)
    }
    
    //MARK:- Gesture Methods and Delegates
    
    @objc func rotate(gesture : UIRotationGestureRecognizer){
        if gesture.state == UIGestureRecognizer.State.began || gesture.state == UIGestureRecognizer.State.changed{
            //print("UIRotationGestureRecognizer")
            gesture.view?.transform = (gesture.view?.transform)!.rotated(by: gesture.rotation)
            gesture.rotation = 0
        }
    }
    
    @objc func scale(gesture : UIPinchGestureRecognizer){
        if gesture.state == UIGestureRecognizer.State.began || gesture.state == UIGestureRecognizer.State.changed{
            //print("UIPinchGestureRecognizer")
            gesture.view?.transform = (gesture.view?.transform)!.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.view?.layer.contentsScale = UIScreen.main.scale + (4 * gesture.scale)
            gesture.view?.layer.allowsEdgeAntialiasing = true
            //  print(viewMovingText.subviews)
            //  print(gesture.view?.subviews)
            for subview in (gesture.view?.subviews)! {
                subview.contentScaleFactor = gesture.scale
                subview.layer.contentsScale = UIScreen.main.scale + (4 * gesture.scale)
                subview.layer.allowsEdgeAntialiasing = true
                
                viewMovingText.viewContainer.contentScaleFactor = gesture.scale
                viewMovingText.viewContainer.layer.contentsScale = UIScreen.main.scale + (4 * gesture.scale)
                viewMovingText.viewContainer.layer.allowsEdgeAntialiasing = true
                
                viewMovingText.lblMovingText.contentScaleFactor = gesture.scale
                viewMovingText.lblMovingText.layer.contentsScale = UIScreen.main.scale + (4 * gesture.scale)
                viewMovingText.lblMovingText.layer.allowsEdgeAntialiasing = true
                
                viewMovingText.txtViewEmoji.contentScaleFactor = gesture.scale
                viewMovingText.txtViewEmoji.layer.contentsScale = UIScreen.main.scale + (4 * gesture.scale)
                viewMovingText.txtViewEmoji.layer.allowsEdgeAntialiasing = true
                viewMovingText.txtViewEmoji.font = viewMovingText.txtViewEmoji.font?.withSize(80 + (4 * gesture.scale))
                // print(gesture.scale)
                viewMovingText.imgViewSticker.contentScaleFactor = gesture.scale
                viewMovingText.imgViewSticker.layer.contentsScale = UIScreen.main.scale + (4 * gesture.scale)
                viewMovingText.imgViewSticker.layer.allowsEdgeAntialiasing = true
                //                if let obj = subview as? ViewMovingText
                //                {
                //                    obj.contentScaleFactor = gesture.scale
                ////                    if let lbl = obj as? UILabel
                ////                    {
                ////                        lbl.font = lbl.font.withSize(20 * gesture.scale)
                ////                    }
                ////                    else if let lbl = obj as? UITextView
                ////                    {
                ////                        lbl.font = lbl.font?.withSize(80 * gesture.scale)
                ////                    }
                //                }
            }
            gesture.scale = 1.0
        }
    }
    //    func scaleView() {
    //        let scaleValue: CGFloat = 5
    //        self.viewLetter.transform = CGAffineTransformMakeScale(scaleValue, scaleValue)
    //        self.labelLetter.contentScaleFactor = scaleValue * x //scaleValue * native content scale  (2 on iPhone 8 and 3 on iPhone 8 plus)
    //    }
    @objc func pan(gesture : UIPanGestureRecognizer){
        if gesture.state == UIGestureRecognizer.State.began || gesture.state == UIGestureRecognizer.State.changed
        {
            let point = gesture.location(in: view)
            let superBounds = viewMovingActive.frame
            if (superBounds.contains(point))
            {
                let translation = gesture.translation(in: self.viewMovingActive)
                gesture.view!.center = CGPoint(x: gesture.view!.center.x + translation.x, y: gesture.view!.center.y + translation.y)
                gesture.setTranslation(CGPoint.zero, in: self.viewMovingActive)
            }
            else
            {
                gesture.view!.center = CGPoint(x: viewMovingActive.frame.width / 2, y: viewMovingActive.frame.height / 2)
                gesture.setTranslation(CGPoint.zero, in: self.viewMovingActive)
            }
        }
    }
    
    
    
    //MARK:- Gesture Methods and Delegates
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func tapGestureHandler() {
        view.endEditing(true)
        imgAPIAppearenceView.isHidden = true
        if viewBrushHeightConstraint.constant == viewBrushHeightConstraintConstant
        {
            swipeUp.isEnabled = false
            swipeDown.isEnabled = false
            tapGesture.isEnabled = false
            viewBrushHeightConstraint.constant = 0
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            setViewHideShow(view: viewCropContainer, hidden: false)
            stackViewEffectsIcon.alpha = 1.0
            viewEffectsIconHeightConstraint.constant = viewEffectsIconHeightConstraintConstant
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            var dic = arrColors[defaultSelectedIndex]
            if let color = dic["color"] as? UIColor
            {
                viewDrawingActive.setColor(color.withAlphaComponent(colorAlphaActive))
            }
            viewDrawingActive.isUserInteractionEnabled = true
            viewDrawingUndoRedo10.isHidden = false
            self.containerViewCapture.bringSubviewToFront( viewDrawingActive)
            self.containerViewCapture.bringSubviewToFront( viewDrawingUndoRedo10)
            setViewHideShow(view: viewDrawingActive, hidden: false)
            self.view.bringSubviewToFront( viewBrush)
            self.view.bringSubviewToFront( viewGrowingTextField)
            self.view.bringSubviewToFront( viewFilterIcon)
            self.view.bringSubviewToFront( viewEffectsIcon)
        }
        else if viewEffectsIconHeightConstraint.constant == viewEffectsIconHeightConstraintConstant
        {
            swipeUp.isEnabled = true
            swipeDown.isEnabled = true
            tapGesture.isEnabled = true
            self.view.bringSubviewToFront( viewGrowingTextField)
            self.view.bringSubviewToFront( viewFilterIcon)
            self.view.bringSubviewToFront( viewEffectsIcon)
            setViewHideShow(view: viewGrowingTextField, hidden: false)
            setViewHideShow(view: viewFilterIcon, hidden: false)
            setViewHideShow(view: viewCropContainer, hidden: true)
            stackViewEffectsIcon.alpha = 0.0
            viewEffectsIconHeightConstraint.constant = 0
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
        }
        if viewFiltersCollectionConstraintHeight.constant == viewFilterHeightConstraintConstant
        {
            viewFiltersCollectionConstraintHeight.constant = 0
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            setViewHideShow(view: viewCropContainer, hidden: false)
            stackViewEffectsIcon.alpha = 1.0
            viewEffectsIconHeightConstraint.constant = viewEffectsIconHeightConstraintConstant
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
        }
        if viewStickerHeightConstraint.constant == viewStcikerHeightConstraintConstant
        {
            viewStickerHeightConstraint.constant = 0
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            setViewHideShow(view: viewCropContainer, hidden: false)
            stackViewEffectsIcon.alpha = 1.0
            viewEffectsIconHeightConstraint.constant = viewEffectsIconHeightConstraintConstant
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        else if touch.view is UITextView {
            return false
        }
        else  if touch.view is ViewMovingText {
            return false
        }
        else if touch.view?.isDescendant(of: viewBrush) == true {
            return false
        }
        else if touch.view?.isDescendant(of: collectionViewBrushColor) == true {
            return false
        }
        else if touch.view?.isDescendant(of: collectionViewLargeTextView) == true {
            return false
        }
        else if touch.view?.isDescendant(of: collectionFilters) == true {
            return false
        }
        else if touch.view?.isDescendant(of: viewSticker) == true {
            return false
        }
        return true
    }
    @objc func handleSwipeGesture(gesture: UISwipeGestureRecognizer) -> Void {
        view.endEditing(true)
        if viewDrawingActive.isUserInteractionEnabled == false
        {
            if gesture.direction == UISwipeGestureRecognizer.Direction.up {
                setViewHideShow(view: viewGrowingTextField, hidden: true)
                setViewHideShow(view: viewFilterIcon, hidden: true)
                stackViewEffectsIcon.alpha = 1.0
                setViewHideShow(view: viewCropContainer, hidden: false)
                viewEffectsIconHeightConstraint.constant = viewEffectsIconHeightConstraintConstant
                UIView.animate(withDuration: 0.3){
                    self.view.layoutIfNeeded()
                }
            }
            else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
                self.view.bringSubviewToFront( viewGrowingTextField)
                self.view.bringSubviewToFront( viewFilterIcon)
                self.view.bringSubviewToFront( viewEffectsIcon)
                setViewHideShow(view: viewGrowingTextField, hidden: false)
                setViewHideShow(view: viewFilterIcon, hidden: false)
                stackViewEffectsIcon.alpha = 0.0
                setViewHideShow(view: viewCropContainer, hidden: true)
                viewEffectsIconHeightConstraint.constant = 0
                UIView.animate(withDuration: 0.3){
                    self.view.layoutIfNeeded()
                }
                
            }
        }
        if viewBrushHeightConstraint.constant == viewBrushHeightConstraintConstant
        {
            swipeUp.isEnabled = false
            swipeDown.isEnabled = false
            tapGesture.isEnabled = false
            viewBrushHeightConstraint.constant = 0
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            setViewHideShow(view: viewCropContainer, hidden: false)
            stackViewEffectsIcon.alpha = 1.0
            viewEffectsIconHeightConstraint.constant = viewEffectsIconHeightConstraintConstant
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            var dic = arrColors[defaultSelectedIndex]
            if let color = dic["color"] as? UIColor
            {
                viewDrawingActive.setColor(color.withAlphaComponent(colorAlphaActive))
            }
            viewDrawingActive.isUserInteractionEnabled = true
            viewDrawingUndoRedo10.isHidden = false
            self.containerViewCapture.bringSubviewToFront( viewDrawingActive)
            self.containerViewCapture.bringSubviewToFront( viewDrawingUndoRedo10)
            setViewHideShow(view: viewDrawingActive, hidden: false)
            self.view.bringSubviewToFront( viewBrush)
            self.view.bringSubviewToFront( viewGrowingTextField)
            self.view.bringSubviewToFront( viewFilterIcon)
            self.view.bringSubviewToFront( viewEffectsIcon)
        }
        if viewFiltersCollectionConstraintHeight.constant == viewFilterHeightConstraintConstant
        {
            viewFiltersCollectionConstraintHeight.constant = 0
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            if gesture.direction == UISwipeGestureRecognizer.Direction.up
            {
                setViewHideShow(view: viewCropContainer, hidden: false)
                stackViewEffectsIcon.alpha = 1.0
                viewEffectsIconHeightConstraint.constant = viewEffectsIconHeightConstraintConstant
                UIView.animate(withDuration: 0.3){
                    self.view.layoutIfNeeded()
                }
            }
            
        }
        if viewStickerHeightConstraint.constant == viewStcikerHeightConstraintConstant
        {
            viewStickerHeightConstraint.constant = 0
            UIView.animate(withDuration: 0.3){
                self.view.layoutIfNeeded()
            }
            if gesture.direction == UISwipeGestureRecognizer.Direction.up
            {
                setViewHideShow(view: viewCropContainer, hidden: false)
                stackViewEffectsIcon.alpha = 1.0
                viewEffectsIconHeightConstraint.constant = viewEffectsIconHeightConstraintConstant
                UIView.animate(withDuration: 0.3){
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        
    }
    func setViewHideShow(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    
    //MARK: Get All Initial Stickers
    func  getStickers(){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            //  removeAlert()
            // Send Server Request for Comments
            var dic = Dictionary<String, String>()
            
            // activityIndicatorView.startAnimating()
            
            if searchDictionary.count > 0{
                let keyword : String = searchDictionary["search"]!
                dic["sticker_search"] = keyword
            }
            post(dic, url: "reactions/stickers", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    // activityIndicatorView.stopAnimating()
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                // Check for Stickers Array that
                                if let stickerArray = body["collectionList"] as? NSArray
                                {
                                    sticterArray = stickerArray as! NSMutableArray
                                    allStickersDic.removeAll(keepingCapacity : false)
                                    for i in 0..<sticterArray.count {
                                        let singleStickerDictionary = sticterArray[i] as! NSDictionary
                                        let order = singleStickerDictionary["order"] as? Int
                                        allStickersDic["\(order!)"] = singleStickerDictionary
                                    }
                                    if let searchStickersArray1 = body["searchList"] as? NSArray
                                    {
                                        searchStickersArray = searchStickersArray1
                                    }
                                    if self.searchDictionary.count == 0{
                                        self.stikerView = StickerView(frame: CGRect(x:0, y: 0, width: self.viewSticker.bounds.width, height: self.viewStcikerHeightConstraintConstant))
                                        self.stikerView.delegateSticker = self
                                        self.stikerView.isComingFromMovingView = true
                                        self.stikerView.backgroundColor = .clear
                                        self.viewSticker.addSubview(self.stikerView)
                                    }
                                }
                            }
                        }
                    }
                })
            }
        }
        else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
    }
    //MARK:- Delegate for Sticker
    func pushAddRemoveStickersViewController()
    {
        let presentedVC = AddRemoveStickersViewController()
        self.navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    func getStickerImage(strImage: String) {
        
        viewStickerHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        stackViewEffectsIcon.alpha = 1.0
        viewEffectsIconHeightConstraint.constant = viewEffectsIconHeightConstraintConstant
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        
        viewDrawingActive.isUserInteractionEnabled = false
        swipeUp.isEnabled = true
        swipeDown.isEnabled = true
        tapGesture.isEnabled = true
        self.containerViewCapture.bringSubviewToFront( viewMovingActive)
        self.containerViewCapture.bringSubviewToFront( viewDrawingUndoRedo10)
        setViewHideShow(view: viewMovingActive, hidden: false)
        self.view.bringSubviewToFront( viewGrowingTextField)
        self.view.bringSubviewToFront( viewFilterIcon)
        self.view.bringSubviewToFront( viewEffectsIcon)
        self.setObjectInMovingView(strData: strImage, dataType: .stickerImage, frame: CGRect(x: 0, y: 0, width: 120, height: 120), strColor: .white)
    }
    
    //MARK:- Delegate for Emoji
    func viewDismissDone()
    {
        setViewHideShow(view: viewCropContainer, hidden: false)
        stackViewEffectsIcon.alpha = 1.0
        viewEffectsIconHeightConstraint.constant = viewEffectsIconHeightConstraintConstant
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        
    }
    func viewEmojiData(strEmoji: String)
    {
        
        btnEraseDrwaing.tag = 103
        btnEraseDrwaing.setImage(UIImage(named: "StoryIcons_FilterEraser")!.maskWithColor(color: .white), for: .normal)
        btnBrush.tag = 101
        btnBrush.setImage(UIImage(named: "StoryIcons_FilterBrush")!.maskWithColor(color: .white), for: .normal)
        viewDrawingActive.isUserInteractionEnabled = false
        swipeUp.isEnabled = true
        swipeDown.isEnabled = true
        tapGesture.isEnabled = true
        self.containerViewCapture.bringSubviewToFront( viewMovingActive)
        self.containerViewCapture.bringSubviewToFront( viewDrawingUndoRedo10)
        setViewHideShow(view: viewMovingActive, hidden: false)
        self.view.bringSubviewToFront( viewGrowingTextField)
        self.view.bringSubviewToFront( viewFilterIcon)
        self.view.bringSubviewToFront( viewEffectsIcon)
        self.setObjectInMovingView(strData: strEmoji, dataType: .emojiText, frame: CGRect(x: 0, y: 0, width: 120, height: 120), strColor: .white)
        
    }
    
    //MARK:- Picker Delegate
    func openTLSImagePicker() {
        DispatchQueue.main.async{
            arrSelectedAssests.removeAll()
            let viewController = TLPhotosPickerViewController()
            viewController.delegate = self
            viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
                self?.showExceededMaximumAlert(vc: picker)
            }
            var configure = TLPhotosPickerConfigure()
            configure.maxSelectedAssets = 5
            configure.maxVideoDuration = 1000
            if video_quality == 1
            {
                configure.recordingVideoQuality = .typeHigh
            }
            else
            {
                configure.recordingVideoQuality = .typeMedium
            }
            configure.numberOfColumn = 3
            configure.defaultCameraRollTitle = "Gallery"
            configure.selectedColor = navColor
            //configure.cameraBgColor = .gray
            viewController.configure = configure
            viewController.selectedAssets = arrSelectedAssests
            viewController.logDelegate = self
            DispatchQueue.main.async{
                self.present(viewController, animated: false, completion: nil)
            }
        }
    }
    //MARK:- TLPhotosPickerViewControllerDelegate
    func photoPickerDidCancel()
    {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is AdvanceActivityFeedViewController {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }
    func dismissComplete()
    {
        if arrSelectedAssests.count == 0 {
            if let viewControllers = self.navigationController?.viewControllers {
                for aViewController in viewControllers {
                    if aViewController is AdvanceActivityFeedViewController {
                        self.navigationController!.popToViewController(aViewController, animated: true)
                    }
                }
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        else
        {
            viewDidLodEventsCall()
        }
        
    }
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        arrSelectedAssests = withTLPHAssets
        if arrSelectedAssests.count != 0
        {
            var assetTemp = arrSelectedAssests[0]
            assetTemp.isCellSelected = true
            assetTemp.isVideoSelected = false
            arrSelectedAssests.remove(at: 0)
            arrSelectedAssests.insert(assetTemp, at: 0)
        }
        else {
            let alert = UIAlertController(title: "", message: NSLocalizedString("No photo is selected, Please try again",comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        }
        
    }
    func getImage(phasset: PHAsset?) {
        guard let asset = phasset else { return }
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        options.version = .current
        options.resizeMode = .exact
        options.progressHandler = { (progress,error,stop,info) in
            //progressBlock(progress)
        }
        let requestId = PHCachingImageManager().requestImageData(for: asset, options: options) { (imageData, dataUTI, orientation, info) in
            if let data = imageData,let _ = info {
                //completionBlock(UIImage(data: data))
                print(data)
            }
        }
    }
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        self.showExceededMaximumAlert(vc: picker)
    }
    
    func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        picker.dismiss(animated: true) {
            let alert = UIAlertController(title: "", message: NSLocalizedString("Denied albums permissions granted",comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        let alert = UIAlertController(title: "", message: NSLocalizedString("Denied camera permissions granted",comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        picker.present(alert, animated: true, completion: nil)
    }
    
    func showExceededMaximumAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "", message: NSLocalizedString("Exceed Maximum Number Of Selection",comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    func showUnsatisifiedSizeAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "Oups!", message: NSLocalizedString("The required size is: 300 x 300",comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- TLPhotosPickerLogDelegate
    func selectedCameraCell(picker: TLPhotosPickerViewController) {
        isCameraSelected = true
    }
    
    func selectedPhoto(picker: TLPhotosPickerViewController, at: Int) {
        arrSelectedAssests = picker.selectedAssets
        if var asset = arrSelectedAssests.last
        {
            if isCameraSelected
            {
                isCameraSelected = false
                if asset.type == .video {
                    arrSelectedAssests.removeAll()
                    asset.isVideoSelected = true
                    arrSelectedAssests.append(asset)
                }
                picker.dismiss(animated: true) {
                    if arrSelectedAssests.count != 0
                    {
                        var assetTemp = arrSelectedAssests[0]
                        assetTemp.isCellSelected = true
                        arrSelectedAssests.remove(at: 0)
                        arrSelectedAssests.insert(assetTemp, at: 0)
                        self.viewDidLodEventsCall()
                    }
                    
                }
            }
            else
            {
                if asset.type == .video {
                    picker.dismiss(animated: false) {
                        if arrSelectedAssests.count != 0
                        {
                            var assetTemp = arrSelectedAssests[0]
                            assetTemp.isCellSelected = true
                            assetTemp.isVideoSelected = true
                            arrSelectedAssests.remove(at: 0)
                            arrSelectedAssests.insert(assetTemp, at: 0)
                            self.viewDidLodEventsCall()
                        }
                    }
                    return
                }
            }
        }
        
    }
    func selectedAlbum(picker: TLPhotosPickerViewController, title: String, at: Int) {
        
    }
    
}
extension UIImage {
    class func imageWithView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}
extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}

extension UITextView {
    func updateTextFont() {
        if (self.text.isEmpty || self.bounds.size.equalTo(CGSize.zero)) {
            return;
        }
        
        let textViewSize = self.frame.size;
        let fixedWidth = textViewSize.width;
        let expectSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        
        
        var expectFont = self.font
        if (expectSize.height > textViewSize.height) {
            
            while (self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height > textViewSize.height) {
                expectFont = self.font!.withSize(self.font!.pointSize - 1)
                self.font = expectFont
            }
        }
        else {
            while (self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height < textViewSize.height) {
                expectFont = self.font
                self.font = self.font!.withSize(self.font!.pointSize + 1)
            }
            self.font = expectFont
        }
    }
}

extension PHAsset {
    
    func image(completionHandler: @escaping (UIImage) -> ()){
        var thumbnail = UIImage()
        let imageManager = PHCachingImageManager()
        imageManager.requestImage(for: self, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: nil, resultHandler: { img, _ in
            thumbnail = img!
        })
        completionHandler(thumbnail)
    }
}

