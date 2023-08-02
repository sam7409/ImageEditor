import UIKit

class FlipNRotationVM{
    var dataModel : ImageFlipModel
    init(dataModel: ImageFlipModel) {
        self.dataModel = dataModel
    }
    func getDataModel()->ImageFlipModel{
        return dataModel
    }
    func getHorizontalFlip()->Bool{
        return dataModel.horizontally
    }
    
    func getVerticallyFlip()->Bool{
        return dataModel.vertically
    }
    func getRotaionRadian()->CGFloat{
        return dataModel.radian
    }
    func updateHorizontalFlip(bool : Bool){
        dataModel.horizontally = bool
    }
    func updateVerticalFlip(bool : Bool){
        dataModel.vertically = bool
    }
    func updateRotation(radian : CGFloat){
        dataModel.radian = radian
    }
    
}
