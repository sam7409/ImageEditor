import UIKit
class BorderPanelVM {
    var prevDataModel : BorderPanelModel
    var dataModel : BorderPanelModel
    var onBindBorderWidth: ((CGFloat?)->())?
    init(dataModel: BorderPanelModel) {
        self.dataModel = dataModel
        self.prevDataModel = dataModel
    }
    func updateCurrentModelToPreviousModel(){
        dataModel = prevDataModel
        onBindBorderWidth!(dataModel.borderWidth)
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
        onBindBorderWidth!(dataModel.borderWidth)
    }
    func updateBorderColor(color: UIColor){
        dataModel.borderColor = color
    }
    
    func colorFromCGColor(_ cgColor: CGColor) -> UIColor? {
        // Get the number of components in the color
        guard let components = cgColor.components, components.count >= 4 else {
            return nil
        }

        // Extract the red, green, blue, and alpha components from the array
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        let alpha = components[3]

        // Create a UIColor using the extracted components
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
