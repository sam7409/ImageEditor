import UIKit

class BorderPanelVC: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var borderWidthSlider: UISlider!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    var borderPanelDelegate : BorderPanelDelegate?
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
        borderWidthSlider.value = viewModel!.getBorderWidth()
        borderWidthSlider.maximumValue = 10
        borderWidthSlider.minimumValue = 0
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        // Assuming you have a reference to your collection view
        collectionView.register(UINib(nibName: "AspectRatioCell", bundle: nil), forCellWithReuseIdentifier: "AspectRatioCell")
        
        cancelButton.layer.cornerRadius = 10
        doneButton.layer.cornerRadius = 10
    }

    @IBAction func didBorderWidthChanged(_ sender: Any) {
        viewModel!.updateBorderWidth(borderWidth: CGFloat(borderWidthSlider.value))
        borderPanelDelegate?.didBorderPanelModelChanged(model: (viewModel?.getDataModel())!)
    }
    @IBAction func didCancelButtonClicked(_ sender: Any) {
        borderPanelDelegate?.didBorderPanelViewDismissWithoutData()
    }
    
    @IBAction func didDoneButtonClicked(_ sender: Any) {
        borderPanelDelegate?.didBorderPanelViewDismissWithData(model: viewModel!.getDataModel())
    }
}



//MARK: - Extensions
extension BorderPanelVC : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (viewModel?.getColorCount())!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AspectRatioCell", for: indexPath) as! AspectRatioCell
        cell.backgroundColor = viewModel!.getColorOnCurrentIndex(index: indexPath.row)
        return cell
    }
}

extension BorderPanelVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width : CGFloat =  90
        let height : CGFloat = 80
        return CGSize(width: width, height: height)


    }
}

extension BorderPanelVC : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as? AspectRatioCell
        viewModel?.updateBorderColor(color: (selectedCell?.backgroundColor)!)
        borderPanelDelegate?.didBorderPanelModelChanged(model: (viewModel?.getDataModel())!)
    }

}


