import Foundation
import UIKit

class ImageTextButton : UIButton
{
    var imageFrame = CGRect()
    var titleFrame = CGRect()
    
    init(imageFrame: CGRect,titleFrame: CGRect,frame: CGRect) {
        
        self.imageFrame = imageFrame
        self.titleFrame = titleFrame
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return imageFrame
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return titleFrame
}
}
