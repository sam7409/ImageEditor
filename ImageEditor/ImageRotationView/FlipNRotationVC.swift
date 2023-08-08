import UIKit

class FlipNRotationVC: UIViewController {

    @IBOutlet var rotationSlider: UISlider!
    
    @IBOutlet var horizontalFlipButton: UIButton!
    
    @IBOutlet var verticalFlipButton: UIButton!
    
    @IBOutlet var cancelButton: UIButton!
    
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var minSliderLabel: UILabel!

    var viewModel : FlipNRotationVM?
    var flipNRotaionDelegate : FlipNRotationDelegate?
    init(viewModel: FlipNRotationVM? = nil) {
        self.viewModel = viewModel
        super.init(nibName: "FlipNRotationVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        rotationSlider.value = Float((viewModel?.getRotaionRadian())!)
        rotationSlider.minimumValue = 0.0
        rotationSlider.maximumValue = 6.28
        horizontalFlipButton.layer.cornerRadius = 12
        verticalFlipButton.layer.cornerRadius = 12
        cancelButton.layer.cornerRadius = 10
        doneButton.layer.cornerRadius = 10
        minSliderLabel.text = "0.0"
        activateBinder()
    }
    
    @IBAction func didChangeHorizontalFlip(_ sender: Any) {
        let bool = viewModel!.getHorizontalFlip()
        if(bool){
            viewModel?.updateHorizontalFlip(bool: false)

        }
        else{
            viewModel?.updateHorizontalFlip(bool: true)
        }
        flipNRotaionDelegate?.didFlipNRitationModelChange(model: (viewModel?.getDataModel())!)
    }
    
    @IBAction func didChangeVerticalFlip(_ sender: Any) {
        let bool = viewModel!.getVerticallyFlip()
        if(bool){
            viewModel?.updateVerticalFlip(bool: false)
        }
        else{
            viewModel?.updateVerticalFlip(bool: true)
        }
        flipNRotaionDelegate?.didFlipNRitationModelChange(model: (viewModel?.getDataModel())!)
    }
    
    @IBAction func didChangeRotation(_ sender: Any) {
        let angle = rotationSlider.value
        rotateImage(angle: CGFloat(angle))
    }
    func rotateImage(angle: CGFloat) {
        viewModel?.updateRotation(radian: CGFloat(rotationSlider.value))
        flipNRotaionDelegate?.didFlipNRitationModelChange(model: (viewModel?.getDataModel())!)

    }
    
    @IBAction func didCancelButtonClicked(_ sender: Any) {
        viewModel!.updateCurrentModelToPreviousModel()
        flipNRotaionDelegate?.didTransformViewDismissWithoutData()
    }
    
    @IBAction func didDoneButtonClicked(_ sender: Any) {
        flipNRotaionDelegate?.didTransformViewDismissWithData(model: viewModel!.getDataModel())
    }
    func activateBinder(){
        viewModel?.onBindRotation = { [self] radian in
            rotationSlider.value = Float(radian!)
            let  degree = radian! * (180.0 / .pi)
            self.minSliderLabel.text =  String(format: "%.2f", Float(degree))
        }
    }
}
