//
//  ViewEmojiController.swift
//  TestDummy
//
//  Created by Akash Verma on 16/08/18.
//  Copyright © 2018 Akash Verma. All rights reserved.
//

import UIKit

protocol EmojiProtocol {
    func viewEmojiData(strEmoji : String)
    func viewDismissDone()
}
class ViewEmojiController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    private var pullToDismiss: PullToDismiss?
    @IBOutlet weak var collectionViewEmojies: UICollectionView!
    var arrEmoji = [Any]()
    var delegateEmoji : EmojiProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "Emoticons", ofType: "plist"),
            let dicRoot = NSDictionary(contentsOfFile: path)
        {
            if let arrRoot = dicRoot["emoticons"] as? [Any]
            {
                for dic in arrRoot
                {
                    if let dicT = dic as? [String:Any], let arrSmily = dicT["emoticons"] as? [Any]
                    {
                        arrEmoji = arrEmoji + arrSmily
                    }
                }
            }
        }

        pullToDismiss = PullToDismiss(scrollView: collectionViewEmojies)
        pullToDismiss?.delegate = self

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegateEmoji?.viewDismissDone()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: UIcollectionView DataSource and Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrEmoji.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
            if let dic = arrEmoji[indexPath.row] as? [String:Any], let strEmoji = dic["emoji"]
            {
                cell.txtViewEmoji.text = strEmoji as! String
                cell.txtViewEmoji.centerVertically()
            }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {

        if collectionView == collectionViewEmojies
        {
            if let dic = arrEmoji[indexPath.row] as? [String:Any], let strEmoji = dic["emoji"]
            {
                delegateEmoji?.viewEmojiData(strEmoji: strEmoji as! String)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }


}
