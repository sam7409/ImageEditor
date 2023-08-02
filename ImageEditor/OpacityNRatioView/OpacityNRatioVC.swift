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
    var color : UIColor?
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
        opacitySlider.thumbTintColor = .black
        opacitySlider.maximumValue = 1.0
        opacitySlider.minimumValue = 0.0
        opacitySlider.tintColor = .white
        opacitySlider.value = Float(viewModel.getOpacity())
        
        cancelButton.layer.cornerRadius = 10
        doneButton.layer.cornerRadius = 10
    }
    
    @IBAction func didOpacityChanged(_ sender: Any) {
        viewModel.setOpacity(opacity: CGFloat(opacitySlider.value))
        editorDelegate?.didChangeModel(model: viewModel.dataModel)
    }
    
    @IBAction func didCancelButtonClicked(_ sender: Any) {
        editorDelegate?.didORViewDismissWithoutData()
    }
    
    @IBAction func didDoneButtonClicked(_ sender: Any) {
        editorDelegate?.didORViewDismissWithData(model: viewModel.getModelData())
    }
    func activateBinder(){
        viewModel.onBindOpacity = { [weak self] opacity in
            if let value = opacity{
                self?.opacitySlider.value = Float(value)
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
        cell.aspectRatioLabel.text = viewModel.getRatioTextForCurrentIndex(index: indexPath.row)
        if let color = color {
            cell.backgroundColor = color
        }
        cell.layer.cornerRadius = 10
        return cell
    }
    }

extension OpacityNRatioVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width : CGFloat =  90
        let height : CGFloat = 80
        return CGSize(width: width, height: height)


    }
}

extension OpacityNRatioVC : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as? AspectRatioCell

        // Access the text property of the selected cell
        let selectedText = selectedCell?.aspectRatioLabel.text
        let aspectRatioValue = viewModel.getRatioValueForCurrentIndex(selectedRatio: selectedText!)
        viewModel.setAspectRatio(aspectRatio: aspectRatioValue)
        editorDelegate?.didChangeModel(model: viewModel.dataModel)
    }

}

