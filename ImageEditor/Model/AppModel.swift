import UIKit          
class AppModel{
    var image : UIImage?
    var centerX : CGFloat?
    var centerY : CGFloat?
    var width : CGFloat?
    var height : CGFloat?
    var referenceSize : CGSize?
    var opacityRatio : OpacityRatioModel?
    var contextSize : CGFloat?
    var scale : CGFloat?
    var imageFlipData : ImageFlipModel?
    var borderPanelData : BorderPanelModel
    
    init(image : UIImage){
        self.image = image
        self.centerX = 150
        self.centerY = 150
        self.width = 100
        self.height = 100
        self.referenceSize = CGSize(width: 400, height: 400)
        self.opacityRatio = OpacityRatioModel(opacity: 1.0,aspectRatio: 1.0)
        self.contextSize = 1000
        self.imageFlipData = ImageFlipModel(horizontally: false, vertically: false, radian: 0.0)
        self.borderPanelData = BorderPanelModel(borderWidth: 0.0, borderColor: .systemPink, bordeColorArray: [.red,.white,.systemPink,.black,.cyan, .gray,.lightGray, .darkGray])
        self.scale = 1.0
    }
    
}

struct OpacityRatioModel{
    var opacity : CGFloat?
    var aspectRatio : CGFloat?
    var aspectRatioDict : [String : Float]?
    init(opacity: CGFloat? = nil, aspectRatio: CGFloat? = nil) {
        self.opacity = opacity
        self.aspectRatio = aspectRatio
        self.aspectRatioDict = ["1:1" : 1.0 ,"1:2" : 0.5 ,"2:1" : 2.0 ,"3:2" : 1.5 ,"4:3" : 1.33,"2:3" : 0.66]
    }
}

struct ImageFlipModel{
    var horizontally : Bool
    var vertically : Bool
    var radian : CGFloat
}

struct BorderPanelModel{
    var borderWidth : CGFloat
    var borderColor : UIColor
    var bordeColorArray : [UIColor]
}
