import UIKit

class EditorVC: UIViewController{
    @IBOutlet var placeHolder: UIView!
    @IBOutlet var opacityRatioView: UIView!
    
    @IBOutlet var handyView: UIView!
    @IBOutlet var tabBarPlaceHolder: UIView!
    
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
    var tabBarView : UIView?
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
        originalCenter = imageView!.center
        tapGestureOnimage()
        pinchGestureOnImage()
        panGestureOnImage()
        addRotationGesture()
        createSaveButtonOnNavigationBar()
        createTabBarView(index: 0)
    }
    
    override func viewWillLayoutSubviews() {
        DispatchQueue.main.async { [self] in
            viewModel.setReferenceSize(size: placeHolder.frame.size, aspectRatio: viewModel.getAspectRatio())
        }
        print(viewModel.dataModel?.width)
        print(viewModel.dataModel?.height)
        print(viewModel.dataModel?.scale)
    }
    
    func createTabBarView(index: Int) {
        // Create a view to serve as the container for the buttons
        tabBarView = UIView(frame: CGRect(x: 0, y: 162, width: view.frame.width, height: 50))
        tabBarView!.backgroundColor = UIColor(named: "PrimaryColor") // Customize the background color as desired

        // Create buttons for each view
        let transformButton = UIButton(type: .system)
        transformButton.tintColor = UIColor(named: "ThemeColor")
        transformButton.setTitle("Transform", for: .normal)
        transformButton.addTarget(self, action: #selector(showTransformView), for: .touchUpInside)
        tabBarView!.addSubview(transformButton)

        let resizeButton = UIButton(type: .system)
        resizeButton.tintColor = UIColor(named: "ThemeColor")
        resizeButton.setTitle("Resize", for: .normal)
        resizeButton.addTarget(self, action: #selector(showResizeView), for: .touchUpInside)
        tabBarView!.addSubview(resizeButton)

        let borderButton = UIButton(type: .system)
        borderButton.tintColor = UIColor(named: "ThemeColor")
        borderButton.setTitle("Border", for: .normal)
        borderButton.addTarget(self, action: #selector(showBorderView), for: .touchUpInside)
        tabBarView!.addSubview(borderButton)

        // Layout the buttons horizontally
        let buttonWidth = tabBarView!.frame.width / 3
        transformButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: tabBarView!.frame.height)
        resizeButton.frame = CGRect(x: buttonWidth, y: 0, width: buttonWidth, height: tabBarView!.frame.height)
        borderButton.frame = CGRect(x: buttonWidth * 2, y: 0, width: buttonWidth, height: tabBarView!.frame.height)

        // Add the tabBarView to your current view controller's view
        opacityRatioView.addSubview(tabBarView!)

        // Optionally, you can set the selected view index (e.g., to highlight the initial view)
        // You'll need to keep track of the selected index yourself as you switch views.
        // For simplicity, I'm showing a single variable `selectedIndex`.
       // selectedIndex = index
    }

    func addOverlay() {
        let overlayView = UIView(frame: opacityRatioView.bounds)
        overlayView.backgroundColor = UIColor(named: "SecondaryColor")!.withAlphaComponent(1.0) // Customize the opacity of the overlay as desired
        opacityRatioView.addSubview(overlayView)
    }

    func removeOverlay() {
        for subview in opacityRatioView.subviews {
            if subview is UIView && subview != tabBarView {
                subview.removeFromSuperview()
            }
        }
    }

    @objc func showResizeView() {
        addOverlay()
        // Present the view you want to show when the "Transform" button is tapped
        let opcityNRatioVM = viewModel.createOpacityNRatioVM()
        opacityNRatioVC = OpacityNRatioVC(viewModel: opcityNRatioVM)// Replace with your Transform view controller
        addChild(opacityNRatioVC!)
        opacityNRatioVC!.view.frame = opacityRatioView.bounds
        opacityRatioView.addSubview(opacityNRatioVC!.view)
        opacityNRatioVC!.didMove(toParent: self)
        opacityNRatioVC?.editorDelegate = self
    }

    @objc func showTransformView() {
        addOverlay()
        
        // Present the view you want to show when the "Resize" button is tapped
        let flipNRotationVM = viewModel.createFlipNRotationVM()
        flipNRotationVC = FlipNRotationVC(viewModel: flipNRotationVM)// Replace with your Resize view controller
        addChild(flipNRotationVC!)
        flipNRotationVC!.view.frame = opacityRatioView.bounds
        opacityRatioView.addSubview(flipNRotationVC!.view)
        flipNRotationVC!.didMove(toParent: self)
        flipNRotationVC?.flipNRotaionDelegate = self
    }

    @objc func showBorderView() {
        addOverlay()
        
        // Present the view you want to show when the "Border" button is tapped
        let borderPanelVM = viewModel.createBorderPanelVM()
        borderPanelVC = BorderPanelVC(dataModel: borderPanelVM) // Replace with your Border view controller
        addChild(borderPanelVC!)
        borderPanelVC!.view.frame = opacityRatioView.bounds
        opacityRatioView.addSubview(borderPanelVC!.view)
        borderPanelVC!.didMove(toParent: self)
        borderPanelVC?.borderPanelDelegate = self
    }

    // Implement this function in your presented view controllers to handle the "Done" button.
    // When the "Done" button is tapped, the presented view will be removed from the parent view controller, and the overlay will be removed.
    @objc func doneButtonTapped() {
        removeOverlay()
    }

    
    func createBackgroundView(){
        backgroundView = UIView()
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
        backgroundView?.backgroundColor = UIColor(named: "DefaultColor")
        backgroundView!.addSubview(imageView!)
    }
    //MARK: -Create Save Button on Navigation Bar
    func createSaveButtonOnNavigationBar(){
        // Create a custom UIBarButtonItem with a title
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(SaveButton))
        saveButton.tintColor = UIColor(named: "ThemeColor")
        // Add the UIBarButtonItem to the right side of the navigation bar
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc func SaveButton() {
        savePhotoToGallery(dataModel: viewModel.dataModel!)
//        showPrompt()
    }
    
    //MARK: - Save photo in gallery function.
    func savePhotoToGallery(dataModel: AppModel) {
        var flippedImage = dataModel.image!
        if(dataModel.imageFlipData!.horizontally){
            flippedImage = flippedImage.imageFlippedHorizontally(dataModel.imageFlipData!.horizontally)
        }
        if(dataModel.imageFlipData!.vertically){
            flippedImage = flippedImage.imageFlippedVertically(dataModel.imageFlipData!.vertically)
        }
        let adjustedImageWithAspectRatio = flippedImage.drawOnContext(dataModel: dataModel, contextSize: CGSize(width: 1000, height: 1000))
        // Save the adjusted image to the Camera Roll
        shareImage(image: adjustedImageWithAspectRatio!)
    //    UIImageWriteToSavedPhotosAlbum(adjustedImageWithAspectRatio!, nil, nil, nil)
    }
    func shareImage(image: UIImage) {
       let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)

       // Exclude specific activities if needed (e.g., AirDrop)
       activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop]

       // Present the activity view controller
        self.present(activityViewController, animated: true, completion: nil)
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
        originalScale = (viewModel.dataModel?.scale)!
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
                  viewModel.setScaledWidthNHeight(scale: clampedScale)

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
    
    //MARK: - All Binder Activation Function
    func activateBinder(){
        viewModel.onBinderDidFrameChanged = { frame in
        
        }
        viewModel.onBinderModelUpdate = { [self] opacity in
            imageView?.alpha = opacity
        }
        viewModel.onBindAspectRatio = { [self] aspectRatio in
            viewModel.setReferenceSize(size: (placeHolder?.frame.size)!, aspectRatio: aspectRatio!)
        }
        viewModel.onBindOpacity = { opacity in
        }
        viewModel.onBinderDidPlaceholderFrameChanged = { [self] frame in
            backgroundView!.frame = frame
        }
        viewModel.onBinderDidImageViewFrameChanged = { [self] frame in
            imageView?.frame = frame
        }
        viewModel.onBinderDidFlipNRotationModelChanged = { [self] model in

            if (model?.horizontally == true || model?.vertically == true) {
                let flippedHorizontally = model?.horizontally ?? false
                let flippedVertically = model?.vertically ?? false

                let scaleX: CGFloat = flippedHorizontally ? -1.0 : 1.0
                let scaleY: CGFloat = flippedVertically ? -1.0 : 1.0
                // Reset the imageView's transform to the identity transform (original state)
                imageView?.transform = CGAffineTransform.identity
                var transform = CGAffineTransform(scaleX:  (viewModel.dataModel?.scale)!, y:  (viewModel.dataModel?.scale)!)
                transform = transform.scaledBy(x: scaleX, y: scaleY)
                transform = transform.rotated(by: model!.radian)
                imageView?.transform = transform
                imageView?.center = CGPoint(x: (viewModel.dataModel?.centerX)!, y: (viewModel.dataModel?.centerY)!)
            }

            else{
                // Reset the imageView's transform to the identity transform (original state)
                imageView?.transform = CGAffineTransform.identity
                var transform = CGAffineTransform(scaleX: (viewModel.dataModel?.scale)!, y:  (viewModel.dataModel?.scale)!)
                transform = transform.scaledBy(x: viewModel.dataModel!.imageFlipData!.horizontally ? -1 : 1 , y: viewModel.dataModel!.imageFlipData!.vertically ? -1 : 1)
                transform = transform.rotated(by: model!.radian)
                imageView?.transform = transform
                
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
        viewModel.updateOpacityNRatio(model : viewModel.getOpacityNRatioDataModel())
        doneButtonTapped()
    }
    func didORViewDismissWithData(model: OpacityRatioModel) {
        viewModel.updateOpacityNRatioModel(model : model)
        doneButtonTapped()
    }
}
//MARK: - FlipNRotation Delegate Func Implementation
extension EditorVC : FlipNRotationDelegate{
    func didFlipNRitationModelChange(model: ImageFlipModel) {
        viewModel.updateFlipNRotate(model: model)
    }
    
    func didTransformViewDismissWithData(model: ImageFlipModel) {
        viewModel.updateFlipNRotationModel(model: model)
        doneButtonTapped()
    }
    
    func didTransformViewDismissWithoutData(){
        let model = viewModel.dataModel?.imageFlipData
        viewModel.updateFlipNRotate(model: model!)
        doneButtonTapped()
    }

}

//MARK: - BorderPanelDelegate Delegate Func Implementation
extension EditorVC : BorderPanelDelegate{
    func didBorderPanelModelChanged(model: BorderPanelModel){
        viewModel.updateBorderWidthNColor(model: model)
    }
    func didBorderPanelViewDismissWithoutData() {
        viewModel.updateBorderWidthNColor(model: viewModel.getBorderPanelDataModel())
        doneButtonTapped()
    }
    
    func didBorderPanelViewDismissWithData(model: BorderPanelModel) {
        viewModel.updateBorderPanelModel(model: model)
        doneButtonTapped()
    }
}
