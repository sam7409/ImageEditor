import UIKit

class EditorVC: UIViewController{
    @IBOutlet var placeHolder: UIView!
    @IBOutlet var opacityRatioView: UIView!
    
    @IBOutlet var handyView: UIView!
    var viewModel : EditorVM
    var imageView : UIImageView?
    var opacityNRatioVC : OpacityNRatioVC?
    var initialCenter : CGPoint = CGPoint.zero
    var originalCenter : CGPoint = CGPoint.zero
    var originalScale : CGFloat = 1.0
    var backgroundView : UIView?
    var rotationAngle: CGFloat = 0.0
    var lastRotation: CGFloat = 0.0
    var flipNRotationVC : FlipNRotationVC?
    var borderPanelVC : BorderPanelVC?
    init(viewModel: EditorVM) {
        self.viewModel = viewModel
        super.init(nibName: "EditorVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createBackgroundView()
        createImageView()
        activateBinder()
        DispatchQueue.main.async { [self] in
            viewModel.setReferenceSize(size: placeHolder.frame.size, aspectRatio: viewModel.getAspectRatio())
        }

        originalCenter = imageView!.center
        tapGestureOnimage()
        pinchGestureOnImage()
        panGestureOnImage()
        addRotationGesture()
        createSaveButtonOnNavigationBar()
        createAllVC()
        createTabBarController()
    }
    func createTabBarController(){
        // Customize tab bar items for each view controller
        flipNRotationVC?.tabBarItem = UITabBarItem()
        flipNRotationVC?.tabBarItem.title = "TP"
        opacityNRatioVC?.tabBarItem = UITabBarItem()
        opacityNRatioVC?.tabBarItem.title = "ORP"
        borderPanelVC?.tabBarItem = UITabBarItem()
        borderPanelVC?.tabBarItem.title = "BP"
        
        // Create a tab bar controller
        let tabBarController = UITabBarController()
        
        // Add your view controllers to the tab bar controller
       tabBarController.viewControllers = [flipNRotationVC!, opacityNRatioVC!, borderPanelVC!]
        
        // Customize the appearance of the tab bar items (increase the font size)
        let tabBarFont = UIFont.systemFont(ofSize: 18) // Change the font size as desired
        let attributes = [NSAttributedString.Key.font: tabBarFont]
        tabBarController.tabBar.items?.forEach { item in
            item.setTitleTextAttributes(attributes, for: .normal)
        }

        // Add the tab bar controller as a child view controller
        addChild(tabBarController)

         // Add the tab bar controller's view to your current view controller's view
        opacityRatioView.addSubview(tabBarController.view)

         // Set the tab bar controller's view frame to fill your current view controller's view
         tabBarController.view.frame = opacityRatioView.bounds

       // Finish adding the tab bar controller as a child view controller
       tabBarController.didMove(toParent: self)
    }
    func createBackgroundView(){
        backgroundView = UIView()
        backgroundView?.backgroundColor = .systemPink
        backgroundView!.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        placeHolder.addSubview(backgroundView!)
        backgroundView!.clipsToBounds = true
    }
    
    func createImageView(){
        imageView = UIImageView()
        imageView?.translatesAutoresizingMaskIntoConstraints = true
        imageView?.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        imageView!.image = viewModel.getImage()
        imageView?.backgroundColor = .white
        backgroundView!.addSubview(imageView!)
    }
    //MARK: -Create Save Button on Navigation Bar
    func createSaveButtonOnNavigationBar(){
        // Create a custom UIBarButtonItem with a title
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(SaveButton))
        saveButton.tintColor = .black
        // Add the UIBarButtonItem to the right side of the navigation bar
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc func SaveButton() {
        savePhotoToGallery(dataModel: viewModel.dataModel!)
    }
    //MARK: - End of Save Button
    
    //MARK: - Tap Gesture Implementation
    func tapGestureOnimage(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapEvent))
        tapGesture.numberOfTapsRequired = 2
        imageView?.addGestureRecognizer(tapGesture)
        imageView?.isUserInteractionEnabled = true
    }
    @objc private func handleTapEvent(){
        
        imageView?.transform = CGAffineTransform(scaleX: originalScale, y: originalScale)
        imageView?.center = originalCenter
        viewModel.setCenter(center: originalCenter)
        viewModel.setScale(scale: originalScale)
    }
    //MARK: - Tap Gesture End
    //MARK: - Pinch Gesture Implemenatation
    func pinchGestureOnImage(){
        // Create a pinch gesture recognizer
          let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(imagePinched(_:)))
          
          // Add the gesture recognizer to the image view
          imageView?.addGestureRecognizer(pinchGesture)
          
          // Enable user interaction on the image view
          imageView?.isUserInteractionEnabled = true
      }
      
      @objc func imagePinched(_ gestureRecognizer: UIPinchGestureRecognizer) {
          var currentScale : CGFloat = 1.0
          if gestureRecognizer.state == .began {
                   //Save the current scale when the pinch gesture starts
              currentScale = (imageView?.transform.a)!
              
              }
              else if gestureRecognizer.state == .changed {
                  // Calculate the new scale based on the pinch gesture's scale
                  let newScale = currentScale * gestureRecognizer.scale

                  // Limit the new scale to be between 0.5x and 3x of the original scale
                  let clampedScale = min(max(newScale, originalScale * 0.5), originalScale * 3.0)

                  // Apply the clamped scale to the image view's transform
                  var transform = CGAffineTransform(scaleX: clampedScale, y: clampedScale)
                  transform = transform.scaledBy(x: viewModel.dataModel!.imageFlipData!.horizontally ? -1 : 1 , y: viewModel.dataModel!.imageFlipData!.vertically ? -1 : 1)
                  imageView?.transform = transform
                  viewModel.setScale(scale: clampedScale)
                  
              }
              else if gestureRecognizer.state == .ended {
                  // Save the current scale for future use
                  currentScale = (imageView?.transform.a)!
                  
              }
      }
    //MARK: - End Pinch Gesture
    
    //MARK: - Pan Gesture Implementation
    func panGestureOnImage(){
        // Create a pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(imageViewPanned(_:)))
        placeHolder.addGestureRecognizer(panGesture)
    }
    @objc func imageViewPanned(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)
        if gestureRecognizer.state == .began {
            // Save the initial center of the view when the pan gesture starts
            initialCenter = imageView!.center
        }
        else if gestureRecognizer.state == .changed {
            // Calculate the new center based on the translation
            let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            
            // Apply the new center to the draggable view
            imageView?.center = newCenter
            viewModel.setCenter(center: newCenter)
        }
    }
    //MARK: - Pan Gesture END
    
    
    
    //MARK: -Rotation Gesture
    func addRotationGesture() {
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
        imageView!.addGestureRecognizer(rotationGesture)
        imageView!.isUserInteractionEnabled = true
    }

    @objc func handleRotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // Store the current rotation angle
            lastRotation = rotationAngle
        case .changed:
            // Calculate the new rotation angle
            rotationAngle = lastRotation + recognizer.rotation
            // Apply the rotation to the image view
            imageView!.transform = CGAffineTransform(rotationAngle: rotationAngle)
            // Reset the recognizer's rotation to zero after applying the transformation
            recognizer.rotation = 0.0
        case .ended:
            // Save the final rotation angle if needed
            // For example, you can store the final angle for future references
            lastRotation = rotationAngle
            viewModel.setAngle(rotationAngle: rotationAngle)
        default:
            break
        }
    }
    //MARK: -END Rotation Gesture
    
    func createAllVC(){
        let opcityNRatioVM = viewModel.createOpacityNRatioVM()
        opacityNRatioVC = OpacityNRatioVC(viewModel: opcityNRatioVM)
        opacityNRatioVC?.editorDelegate = self
        let flipNRotationVM = viewModel.createFlipNRotationVM()
        flipNRotationVC = FlipNRotationVC(viewModel: flipNRotationVM)
        flipNRotationVC?.flipNRotaionDelegate = self
        let borderPanelVM = viewModel.createBorderPanelVM()
        borderPanelVC = BorderPanelVC(dataModel: borderPanelVM)
        borderPanelVC?.borderPanelDelegate = self
        
    }
//    func addORPanelToVC(){
//        opacityRatioView.addSubview((opacityNRatioVC?.view)!)
//        opacityNRatioVC!.didMove(toParent: self)
//        opacityNRatioVC!.view.frame = CGRect(x: 0, y: 0, width: opacityRatioView.frame.width, height: opacityRatioView.frame.height)
//        opacityNRatioVC?.editorDelegate = self
//    }
//
//    func AddTransformationPanelToVC(){
//        opacityRatioView.addSubview((flipNRotationVC?.view)!)
//        flipNRotationVC!.didMove(toParent: self)
//        flipNRotationVC!.view.frame = CGRect(x: 0, y: 0, width: opacityRatioView.frame.width, height: opacityRatioView.frame.height)
//        flipNRotationVC?.flipNRotaionDelegate = self
//    }
//
//    func AddBorderPanelToVC(){
//        opacityRatioView.addSubview((borderPanelVC?.view)!)
//        borderPanelVC!.didMove(toParent: self)
//        borderPanelVC!.view.frame = CGRect(x: 0, y: 0, width: opacityRatioView.frame.width, height: opacityRatioView.frame.height)
//        borderPanelVC?.borderPanelDelegate = self
//    }
    
//    @IBAction func goToOpacityNRatioView(_ sender: Any) {
//        addORPanelToVC()
//    }
//
//    @IBAction func goToFlipNRotationView(_ sender: Any) {
//        AddTransformationPanelToVC()
//    }
//
//    @IBAction func goToBorderPanelView(_ sender: Any) {
//        AddBorderPanelToVC()
//    }
    
    //MARK: - All Binder Activation Function
    func activateBinder(){
        viewModel.onBinderDidFrameChanged = { frame in
        
        }
        viewModel.onBinderModelUpdate = { [self] opacity in
            imageView?.alpha = opacity
        }
        viewModel.onBindAspectRatio = { [self] aspectRatio in
            print(aspectRatio as Any)
            viewModel.setReferenceSize(size: (placeHolder?.frame.size)!, aspectRatio: aspectRatio!)
        }
        viewModel.onBindOpacity = { opacity in
            print(opacity as Any)
        }
        viewModel.onBinderDidPlaceholderFrameChanged = { [self] frame in
            backgroundView!.frame = frame
        }
        viewModel.onBinderDidImageViewFrameChanged = { [self] frame in
            imageView?.frame = frame
        }
        viewModel.onBinderDidFlipNRotationModelChanged = { [self] model in
            imageView!.transform = CGAffineTransform(rotationAngle: model!.radian)
            
            if (model?.horizontally == true || model?.vertically == true) {
                let flippedHorizontally = model?.horizontally ?? false
                let flippedVertically = model?.vertically ?? false
                
                let scaleX: CGFloat = flippedHorizontally ? -1.0 : 1.0
                let scaleY: CGFloat = flippedVertically ? -1.0 : 1.0
                
                imageView!.transform = imageView!.transform.scaledBy(x: scaleX, y: scaleY)
            }
        }
        viewModel.onBinderDidBorderPanelModelChanged = { [self] model in
            backgroundView?.layer.borderWidth = model!.borderWidth
            backgroundView?.layer.borderColor = (model?.borderColor.cgColor)
        }
    }
    //MARK: -Binder Activation END
}

//MARK: - Editor Delegate Func Implementation
extension EditorVC : EditorDelegate{
    func didChangeModel(model: OpacityRatioModel) {
        viewModel.updateOpacityNRatio(model : model)
    }
    func didORViewDismissWithoutData() {
//        if let childVC = opacityNRatioVC {
//            childVC.willMove(toParent: nil)
//            childVC.view.removeFromSuperview()
//            childVC.removeFromParent()
//            opacityNRatioVC = nil // Reset the reference to the child view controller
//        }
        viewModel.updateOpacityNRatio(model : viewModel.getOpacityNRatioDataModel())
    }
    func didORViewDismissWithData(model: OpacityRatioModel) {
        viewModel.updateOpacityNRatioModel(model : model)
//        if let childVC = opacityNRatioVC {
//            childVC.willMove(toParent: nil)
//            childVC.view.removeFromSuperview()
//            childVC.removeFromParent()
//            opacityNRatioVC = nil // Reset the reference to the child view controller
//        }
    }
}
//MARK: - FlipNRotation Delegate Func Implementation
extension EditorVC : FlipNRotationDelegate{
    func didFlipNRitationModelChange(model: ImageFlipModel) {
        viewModel.updateFlipNRotate(model: model)
    }
    func didTransformViewDismissWithData(model: ImageFlipModel) {
        viewModel.updateFlipNRotationModel(model: model)
//        if let childVC = flipNRotationVC {
//            childVC.willMove(toParent: nil)
//            childVC.view.removeFromSuperview()
//            childVC.removeFromParent()
//            flipNRotationVC = nil // Reset the reference to the child view controller
//        }
    }
    
    func didTransformViewDismissWithoutData(){
//        if let childVC = flipNRotationVC {
//            childVC.willMove(toParent: nil)
//            childVC.view.removeFromSuperview()
//            childVC.removeFromParent()
//            flipNRotationVC = nil // Reset the reference to the child view controller
//        }
        let model = viewModel.dataModel?.imageFlipData
        viewModel.updateFlipNRotate(model: model!)
    }
}

//MARK: - BorderPanelDelegate Delegate Func Implementation
extension EditorVC : BorderPanelDelegate{
    func didBorderPanelModelChanged(model: BorderPanelModel){
        viewModel.updateBorderWidthNColor(model: model)
    }
    func didBorderPanelViewDismissWithoutData() {
//        if let childVC = borderPanelVC {
//            childVC.willMove(toParent: nil)
//            childVC.view.removeFromSuperview()
//            childVC.removeFromParent()
//            borderPanelVC = nil // Reset the reference to the child view controller
//        }
        viewModel.updateBorderWidthNColor(model: viewModel.getBorderPanelDataModel())
    }
    
    func didBorderPanelViewDismissWithData(model: BorderPanelModel) {
        viewModel.updateBorderPanelModel(model: model)
//        if let childVC = borderPanelVC {
//            childVC.willMove(toParent: nil)
//            childVC.view.removeFromSuperview()
//            childVC.removeFromParent()
//            borderPanelVC = nil // Reset the reference to the child view controller
//        }
    }
}
