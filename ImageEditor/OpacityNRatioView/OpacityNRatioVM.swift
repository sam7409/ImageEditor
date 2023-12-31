import UIKit
class OpacityNRatioVM{
    var prevDataModel: OpacityRatioModel
    var dataModel : OpacityRatioModel
    var onBindOpacity : ((CGFloat?)->())?
    init(dataModel: OpacityRatioModel) {
        self.dataModel = dataModel
        self.prevDataModel = dataModel
    }
    func updateCurrentModelToPreviousModel(){
        dataModel = prevDataModel
        onBindOpacity!(dataModel.opacity)
    }
    func getModelData()->OpacityRatioModel{
        return dataModel
    }
    func getCountOfRatios()->Int{
        return dataModel.aspectRatioDict!.count
    }
    func getRatioTextForCurrentIndex(index : Int)->String{
        let ratiosArray = Array(dataModel.aspectRatioDict!)
        return ratiosArray[index].key
    }
    
    func getRatioValueForCurrentIndex(selectedRatio : String)->CGFloat{
        return CGFloat(dataModel.aspectRatioDict![selectedRatio]!)
    }
    func getOpacity()->CGFloat{
        return dataModel.opacity!
    }
    
    func setOpacity(opacity : CGFloat){
        dataModel.opacity = opacity
        onBindOpacity!(opacity)
    }
    
    func setAspectRatio(aspectRatio : CGFloat){
        dataModel.aspectRatio = aspectRatio
    }
}
