import UIKit

class BorderPanelVC: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var borderWidthSlider: UISlider!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    
    @IBOutlet var colorPickerButton: UIButton!
    var borderPanelDelegate : BorderPanelDelegate?
    @IBOutlet var minSliderLabel: UILabel!
    var prevCell: AspectRatioCell?
    var viewModel : BorderPanelVM?
    
    init(dataModel : BorderPanelVM){
        viewModel = dataModel
        super.init(nibName: "BorderPanelVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        borderWidthSlider.minimumValue = 0
        borderWidthSlider.maximumValue = 10
        borderWidthSlider.value = viewModel!.getBorderWidth()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        // Assuming you have a reference to your collection view
        collectionView.register(UINib(nibName: "AspectRatioCell", bundle: nil), forCellWithReuseIdentifier: "AspectRatioCell")
        colorPickerButton.setImage(UIImage(named: "customcolor"), for: .normal)
        minSliderLabel.text =  "0.0"
        activateBinder()
    }
    
    @IBAction func didColorPanelClicked(_ sender: Any) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        present(colorPicker, animated: true, completion: nil)
        prevCell?.layer.borderColor = UIColor(named: "DefaultColor")?.cgColor
    }
    
    @IBAction func didBorderWidthChanged(_ sender: Any) {
        viewModel!.updateBorderWidth(borderWidth: CGFloat(borderWidthSlider.value))
        borderPanelDelegate?.didBorderPanelModelChanged(model: (viewModel?.getDataModel())!)
    }
    @IBAction func didCancelButtonClicked(_ sender: Any) {
        viewModel!.updateCurrentModelToPreviousModel()
        borderPanelDelegate?.didBorderPanelViewDismissWithoutData()
    }
    
    @IBAction func didDoneButtonClicked(_ sender: Any) {
        borderPanelDelegate?.didBorderPanelViewDismissWithData(model: viewModel!.getDataModel())
    }
    
    func activateBinder(){
        viewModel!.onBindBorderWidth = { [self] borderWidth in
            borderWidthSlider.value = Float(borderWidth!)
            self.minSliderLabel.text =  String(format: "%.2f", borderWidth!)
        }
    }
}

//MARK: - Extensions
extension BorderPanelVC : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (viewModel?.getColorCount())!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AspectRatioCell", for: indexPath) as! AspectRatioCell
        let color = viewModel!.getColorOnCurrentIndex(index: indexPath.row)
        cell.backgroundColor = UIColor(named: "DefaultColor")
        cell.colorCell.backgroundColor = color
        if(color == .systemPink){
            prevCell = cell
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor(named: "ThemeColor")?.cgColor
        }
        return cell
    }
}

extension BorderPanelVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width : CGFloat =  50
        let height : CGFloat = 50
        return CGSize(width: width, height: height)


    }
}

extension BorderPanelVC : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as? AspectRatioCell
        prevCell?.layer.borderColor = UIColor(named: "DefaultColor")?.cgColor
        prevCell = selectedCell
        viewModel?.updateBorderColor(color: (selectedCell?.colorCell.backgroundColor)!)
        borderPanelDelegate?.didBorderPanelModelChanged(model: (viewModel?.getDataModel())!)
        selectedCell!.layer.borderWidth = 3
        selectedCell?.layer.borderColor = UIColor(named: "ThemeColor")?.cgColor
    }

}

extension BorderPanelVC: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        viewModel?.updateBorderColor(color: selectedColor)
        borderPanelDelegate?.didBorderPanelModelChanged(model: (viewModel?.getDataModel())!)
    }
}
