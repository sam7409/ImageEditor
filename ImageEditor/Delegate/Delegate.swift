import UIKit

protocol EditorDelegate{
    func didChangeModel(model: OpacityRatioModel)
    func didORViewDismissWithData(model : OpacityRatioModel)
    func didORViewDismissWithoutData()
}

protocol FlipNRotationDelegate{
    func didFlipNRitationModelChange(model: ImageFlipModel)
    func didTransformViewDismissWithData(model : ImageFlipModel)
    func didTransformViewDismissWithoutData()
}

protocol BorderPanelDelegate{
    func didBorderPanelModelChanged(model: BorderPanelModel)
    func didBorderPanelViewDismissWithoutData()
    func didBorderPanelViewDismissWithData(model : BorderPanelModel)
}
