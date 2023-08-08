import UIKit
class EditorVM{
    var dataModel : AppModel?
    var flipNRotationVM: FlipNRotationVM?
    var borderPanelVM: BorderPanelVM?
    var opacityNRatioVM : OpacityNRatioVM?
    var onBindAspectRatio : ((CGFloat?)->())?
    var onBindOpacity : ((CGFloat?)->())?
    var onBinderModelUpdate : ((CGFloat)->())?
    var onBinderDidFrameChanged : ((CGRect)->())?
    var onBinderDidPlaceholderFrameChanged : ((CGRect)->())?
    var onBinderDidImageViewFrameChanged : ((CGRect)->())?
    var onBinderDidFlipNRotationModelChanged : ((ImageFlipModel?)->())?
    var onBinderDidBorderPanelModelChanged : ((BorderPanelModel?)->())?
    init(dataModel: AppModel? = nil) {
        self.dataModel = dataModel
    }
    func setAngle(rotationAngle: CGFloat){
        dataModel?.imageFlipData?.radian = rotationAngle
        
    }
    func setScaledWidthNHeight(scale: CGFloat){
        dataModel?.width = (dataModel?.width)! * scale
        dataModel?.height = (dataModel?.height)! * scale
    }
    func setScale(scale: CGFloat){
        dataModel?.scale = scale
    }
    func setCenter(center : CGPoint){
        dataModel?.centerX = center.x
        dataModel?.centerY = center.y
    }
    //This func used to get the image
    func getImage()->UIImage{
        return (dataModel?.image)!
    }
    func getOpacity()->CGFloat{
        return (dataModel?.opacityRatio?.opacity)!
    }
    func getImageAspectratio()->CGFloat{
        let image = getImage()
        let ratio = image.size.width/image.size.height
        return ratio
    }
    func getBorderPanelDataModel()->BorderPanelModel{
        return dataModel!.borderPanelData
    }
    func updateBorderWidthNColor(model: BorderPanelModel){
        onBinderDidBorderPanelModelChanged!(model)
    }
    // Replace the OpacityRatio Struct model in App Model
    func updateOpacityNRatio(model : OpacityRatioModel){
        onBinderModelUpdate!(model.opacity!)
        onBindAspectRatio!(model.aspectRatio)
        onBindOpacity!(model.opacity)
    }
    func updateOpacityNRatioModel(model : OpacityRatioModel){
        dataModel?.opacityRatio = model
    }
    
    func updateBorderPanelModel(model : BorderPanelModel){
        dataModel?.borderPanelData = model
    }
    
    func updateFlipNRotationModel(model : ImageFlipModel){
        dataModel?.imageFlipData = model
    }
    func getReferenceSize()->CGSize{
        return (dataModel?.referenceSize)!
    }
    func getBGColor()->UIColor{
        return (dataModel?.borderPanelData.borderColor)!
    }
    func getBorderColor()->UIColor{
        return (dataModel?.borderPanelData.borderColor)!
    }
    func getBorderSize()->CGFloat{
        return (dataModel?.borderPanelData.borderWidth)!
    }
    func getAspectRatio()->CGFloat{
        return (dataModel?.opacityRatio?.aspectRatio)!
    }
    func getOpacityNRatioDataModel()->OpacityRatioModel{
        return (dataModel?.opacityRatio)!
    }
    func setReferenceSize(size : CGSize, aspectRatio: CGFloat){
        var imageViewFrame = CGRect.zero
        let placeHolderFrame = calculateViewFrame(size: size, aspectRatio: aspectRatio)
        dataModel?.referenceSize = placeHolderFrame.size
        if let referenceSize = dataModel?.referenceSize{
            imageViewFrame = calculateImageViewFrame(size:  referenceSize, aspectRatio: getImageAspectratio(), scale: (dataModel?.scale)!)
            dataModel?.width = imageViewFrame.width
            dataModel?.height = imageViewFrame.height
            dataModel?.centerX = referenceSize.width/2
            dataModel?.centerY = referenceSize.height/2
        }
        
        onBinderDidPlaceholderFrameChanged!(placeHolderFrame)
        onBinderDidImageViewFrameChanged!(imageViewFrame)
    }
    
    func updateReferenceSize(size: CGSize){
        dataModel?.referenceSize?.width = size.width
        dataModel?.referenceSize?.height = size.height
    }
    func upadetImageViewSize(size : CGSize){
        dataModel?.width = size.width
        dataModel?.height = size.height
    }
    func updateFlipNRotate(model : ImageFlipModel?){
        onBinderDidFlipNRotationModelChanged!(model)
    }
    
    func calculateViewFrame(size: CGSize , aspectRatio: CGFloat) -> CGRect {
        var viewWidth = size.width
        var viewHeight = size.width / aspectRatio
        
        // If the calculated height exceeds the parent height, adjust the height and width
        if viewHeight > size.height {
            viewHeight = size.height
            viewWidth = viewHeight * aspectRatio
        }
        
        let originX = (size.width - viewWidth) / 2
        let originY = (size.height - viewHeight) / 2
        
       
        
        return CGRect(x: originX, y: originY, width: viewWidth, height: viewHeight)
    }
    
    func calculateImageViewFrame(size: CGSize , aspectRatio: CGFloat, scale: CGFloat) -> CGRect {
        var viewWidth = size.width
        var viewHeight = size.width / aspectRatio
        
        // If the calculated height exceeds the parent height, adjust the height and width
        if viewHeight > size.height {
            viewHeight = size.height
            viewWidth = viewHeight * aspectRatio
        }
        
        let originX = (size.width - viewWidth * scale) / 2
        let originY = (size.height - viewHeight * scale) / 2
        
       
        
        return CGRect(x: originX, y: originY, width: viewWidth * scale, height: viewHeight * scale)
    }
    
    // Creates the OpacityNRatioVM
    func createOpacityNRatioVM()->OpacityNRatioVM{
        opacityNRatioVM = OpacityNRatioVM(dataModel: (dataModel?.opacityRatio)!)
        return opacityNRatioVM!
    }
    
    // Creates the FlipNRotationVM
    func createFlipNRotationVM()->FlipNRotationVM{
        flipNRotationVM = FlipNRotationVM(dataModel: (dataModel?.imageFlipData)!)
        return flipNRotationVM!
    }
    
    func createBorderPanelVM()->BorderPanelVM{
        borderPanelVM = BorderPanelVM(dataModel: dataModel!.borderPanelData)
        return borderPanelVM!
    }
}
