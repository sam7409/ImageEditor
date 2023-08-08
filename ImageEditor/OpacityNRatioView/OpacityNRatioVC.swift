//
//  OpacityNRatioVC.swift
//  ImageEditor
//
//  Created by HIMANSHU SINGH on 25/07/23.
//

import UIKit

class OpacityNRatioVC: UIViewController {

    @IBOutlet var opacitySlider: UISlider!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var minSliderLabel: UILabel!
    var color : UIColor?
    var prevCell: AspectRatioCell?
    var editorDelegate : EditorDelegate?
    var viewModel : OpacityNRatioVM
    init(viewModel: OpacityNRatioVM) {
        self.viewModel = viewModel
        super.init(nibName: "OpacityNRatioVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        activateBinder()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        // Assuming you have a reference to your collection view
        collectionView.register(UINib(nibName: "AspectRatioCell", bundle: nil), forCellWithReuseIdentifier: "AspectRatioCell")
        opacitySlider.maximumValue = 1.0
        opacitySlider.minimumValue = 0.0
        minSliderLabel.text = "0.0"
        opacitySlider.value = Float(viewModel.getOpacity())
        
        cancelButton.layer.cornerRadius = 10
        doneButton.layer.cornerRadius = 10
    }
    
    @IBAction func didOpacityChanged(_ sender: Any) {
        viewModel.setOpacity(opacity: CGFloat(opacitySlider.value))
        editorDelegate?.didChangeModel(model: viewModel.dataModel)
    }
    
    @IBAction func didCancelButtonClicked(_ sender: Any) {
        viewModel.updateCurrentModelToPreviousModel()
        editorDelegate?.didORViewDismissWithoutData()
    }
    
    @IBAction func didDoneButtonClicked(_ sender: Any) {
        editorDelegate?.didORViewDismissWithData(model: viewModel.getModelData())
    }
    func activateBinder(){
        viewModel.onBindOpacity = { [weak self] opacity in
            if let value = opacity{
                self?.opacitySlider.value = Float(value)
                self?.minSliderLabel.text =  String(format: "%.2f", Float(value))
            }
        }
    }
}



//MARK: - Extensions
extension OpacityNRatioVC : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getCountOfRatios()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AspectRatioCell", for: indexPath) as! AspectRatioCell
        let text = viewModel.getRatioTextForCurrentIndex(index: indexPath.row)
        cell.aspectRatioLabel.text = text
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 4.0
        cell.layer.borderColor = UIColor(named: "DefaultColor")?.cgColor
        if(text == "1:1"){
            cell.layer.borderColor = UIColor(named: "ThemeColor")?.cgColor
            prevCell = cell
        }
        return cell
    }
    }

extension OpacityNRatioVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width : CGFloat =  80
        let height : CGFloat = 40
        return CGSize(width: width, height: height)


    }
}

extension OpacityNRatioVC : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as? AspectRatioCell
        selectedCell!.layer.borderColor = UIColor(named: "ThemeColor")?.cgColor
        prevCell?.layer.borderColor =  UIColor(named: "DefaultColor")?.cgColor
        prevCell = selectedCell
        // Access the text property of the selected cell
        let selectedText = selectedCell?.aspectRatioLabel.text
        let aspectRatioValue = viewModel.getRatioValueForCurrentIndex(selectedRatio: selectedText!)
        viewModel.setAspectRatio(aspectRatio: aspectRatioValue)
        editorDelegate?.didChangeModel(model: viewModel.dataModel)
    }

}

