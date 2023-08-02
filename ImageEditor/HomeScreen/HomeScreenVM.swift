import UIKit
class HomeScreenVM{
    var editorVM : EditorVM?
    var dataModel : AppModel?
    func setImage(image : UIImage){
        dataModel = AppModel(image: image)
    }
    func createEditorVMInstance()-> EditorVM? {
        editorVM = EditorVM(dataModel: dataModel)
        return editorVM
    }
}
