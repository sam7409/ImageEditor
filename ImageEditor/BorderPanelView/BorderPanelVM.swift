import UIKit
class BorderPanelVM {
    var dataModel : BorderPanelModel
    init(dataModel: BorderPanelModel) {
        self.dataModel = dataModel
    }
    func getBorderWidth()->Float{
        return Float(dataModel.borderWidth)
    }
    func getDataModel()->BorderPanelModel{
        return dataModel
    }
    func getColorCount()->Int{
        return dataModel.bordeColorArray.count
    }
    
    func getColorOnCurrentIndex(index : Int)->UIColor{
        return dataModel.bordeColorArray[index]
    }
    
    func updateBorderWidth(borderWidth: CGFloat){
        dataModel.borderWidth = borderWidth
    }
    func updateBorderColor(color: UIColor){
        dataModel.borderColor = color
    }
}
