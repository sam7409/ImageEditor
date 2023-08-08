import UIKit
import CoreImage

//MARK: - End Save Photo gallery  function.

func flipImage(image: UIImage) -> UIImage? {
    // Convert the UIImage to a CIImage
    guard let ciImage = CIImage(image: image) else {
        return nil
    }

    // Flip the image horizontally using a transformation
    let flippedImage = ciImage.transformed(by: CGAffineTransform(scaleX: -1.0, y: 1.0))

    // Create a new UIImage from the flipped CIImage
    let context = CIContext(options: nil)
    guard let cgImage = context.createCGImage(flippedImage, from: flippedImage.extent) else {
        return nil
    }

    let flippedUIImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)

    return flippedUIImage
}

extension UIImage {
        func imageFlippedHorizontally(_ flipped: Bool) -> UIImage {
            if flipped {
                return UIImage(cgImage: cgImage!, scale: scale, orientation: .upMirrored)
            } else {
                return self
            }
        }

        func imageFlippedVertically(_ flipped: Bool) -> UIImage {
            if flipped {
                return UIImage(cgImage: cgImage!, scale: scale, orientation: .downMirrored)
            } else {
                return self
            }
        }
       
    func drawOnContext(dataModel: AppModel, contextSize: CGSize) -> UIImage? {
        let aspectRatio: CGFloat = (dataModel.opacityRatio?.aspectRatio)!
        guard aspectRatio > 0 else {
            return nil // Aspect ratio should be greater than zero to avoid division by zero.
        }

        let targetSize = calculateViewFrame(size: contextSize, aspectRatio: aspectRatio)

        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil // Failed to create graphics context.
        }

        // Fill the context with the background color (red in this case).
        context.setFillColor(UIColor(named: "SecondaryColor")!.cgColor)
        context.fill(CGRect(origin: .zero, size: targetSize))

        context.saveGState()

        let imageSize = reCalculateSize(
            currentChildSize: CGSize(width: dataModel.width! * dataModel.scale!, height: dataModel.height! * dataModel.scale!),
            currentParentSize: dataModel.referenceSize!,
            newParentSize: targetSize
        )
        var imageCenter = CGPoint.zero
        imageCenter = reCalculateCenter(
            CGPoint(x: dataModel.centerX!, y: dataModel.centerY!),
            currentSize: dataModel.referenceSize!,
            newSize: targetSize
        )
        if dataModel.imageFlipData?.radian != 0.0 {
            //  Translate the context to the center of the image
            context.translateBy(x: imageCenter.x, y: imageCenter.y)
            // Apply the rotation transform to the context
            let angleInRadians = dataModel.imageFlipData?.radian
            context.rotate(by: angleInRadians!)
        }

        // Draw the original image on the context with adjusted opacity
        var imageRect = CGRect()
        if(dataModel.imageFlipData?.radian == 0.0 || dataModel.scale != 1.0){
            
            imageRect = CGRect(x: imageCenter.x - imageSize.width / 2, y: imageCenter.y - imageSize.height / 2, width: imageSize.width, height: imageSize.height)
        }
        else{
            imageRect = CGRect(x: -imageSize.width / 2, y: -imageSize.height / 2, width: imageSize.width, height: imageSize.height)
        }
        self.draw(in: imageRect)
        if(dataModel.imageFlipData?.radian != 1.0){
            context.restoreGState()
        }


        context.setShouldAntialias(true)
        // Add border to the adjusted image
        let borderPath = UIBezierPath(rect: CGRect(origin: .zero, size: targetSize))
        dataModel.borderPanelData.borderColor.setStroke()
        var borderWidth : CGFloat
        if(targetSize.width > targetSize.height){
             borderWidth = (targetSize.height) * (dataModel.borderPanelData.borderWidth)/100
        }
        else{
            borderWidth = (targetSize.width)*(dataModel.borderPanelData.borderWidth)/100
        }
            
        borderPath.lineWidth = borderWidth
        borderPath.stroke()

        let finalImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return finalImage
    }
    func reCalculateCenterForScale(_ originalCenter: CGPoint, originalSize: CGSize, scaleFactor: CGFloat, newSize: CGSize) -> CGPoint {
        let newWidth = originalSize.width * scaleFactor
        let newHeight = originalSize.height * scaleFactor

        let widthDifference = newWidth - originalSize.width
        let heightDifference = newHeight - originalSize.height

        let adjustedCenterX = originalCenter.x + (widthDifference / 2)
        let adjustedCenterY = originalCenter.y + (heightDifference / 2)

        let targetWidthDifference = newSize.width - newWidth
        let targetHeightDifference = newSize.height - newHeight

        let newCenterX = adjustedCenterX + (targetWidthDifference / 2)
        let newCenterY = adjustedCenterY + (targetHeightDifference / 2)

        return CGPoint(x: newCenterX, y: newCenterY)
    }


    
    public func reCalculateCenter(_ currentCenter : CGPoint , currentSize : CGSize , newSize: CGSize)->CGPoint{
        
       let newProportionalSize = getProportionalSize(currentSize: currentSize, newSize: newSize)
       
        let newWidth = newProportionalSize.width
        let newHeight = newProportionalSize.height
        
        // calculate what quadrant watermark lies
        var quadrant = WMGridPositions.MIDDLE_MIDDLE
        
        if(currentCenter.x <= currentSize.width/3)
        {
            // This is on Left Side
            // Check Where is Y
            if(currentCenter.y <= currentSize.height/3)
            {
                
                quadrant = .TOP_LEFT
            } else if( currentCenter.y > currentSize.height/3 && currentCenter.y <= currentSize.height * 2/3) {
                         // This is in Center
                
                quadrant = .MIDDLE_LEFT
            } else{
                
                quadrant = .BOTTOM_LEFT
            }
        } else  if(currentCenter.x > currentSize.width/3 && currentCenter.x <= currentSize.width * 2/3)
        {
            // This is in Center
            // Check Where is Y
            if(currentCenter.y <= currentSize.height/3)
            {
                
                quadrant = .TOP_MIDDLE
            } else if( currentCenter.y > currentSize.height/3 && currentCenter.y <= currentSize.height * 2/3) {
                // This is in Center
                
                quadrant = .MIDDLE_MIDDLE
            } else{
                
                quadrant = .BOTTOM_MIDDLE
            }
            
        } else {
            // This is on Right Side
            // Check Where is Y
            
            if(currentCenter.y <= currentSize.height/3)
            {
                
                quadrant = .TOP_RIGHT
            } else if( currentCenter.y > currentSize.height/3 && currentCenter.y <= currentSize.height * 2/3) {
                // This is in Center
                
                quadrant = .MIDDLE_RIGHT
            } else{
                
                quadrant = .BOTTOM_RIGHT
            }
            
        }
        
        
        // now lets calculate newCenter based on quadrant and newWidthHeight
        
        var newCenter = CGPoint.zero
        
        // if Quadrant is one then Reference is from TopLeft
        switch quadrant {
        case .TOP_LEFT:
            let centerX = currentCenter.x * (newWidth/currentSize.width)
            let centerY = currentCenter.y * (newHeight/currentSize.height)
            newCenter = CGPoint(x: centerX, y:centerY)
        case .TOP_MIDDLE:
            // Top Middle
            //  We going to shift from Right
            // Reference is Center X of ReferenceImage
            //
            let proportionateDistanceFromCenterX = (currentCenter.x - currentSize.width/2) * (newWidth/currentSize.width)
            let centerX = newSize.width/2  + proportionateDistanceFromCenterX
            let centerY = currentCenter.y * (newHeight/currentSize.height)
            newCenter = CGPoint(x: centerX, y:centerY)
        case .TOP_RIGHT:
            //  We going to shift from Right
            let centerX = newSize.width - ((currentSize.width - currentCenter.x) * (newWidth/currentSize.width))
            let centerY = currentCenter.y * (newHeight/currentSize.height)
            newCenter = CGPoint(x: centerX, y:centerY)
            
        case .MIDDLE_LEFT:
            let centerX = currentCenter.x * (newWidth/currentSize.width)
            let proportionateDistanceFromCenterY = (currentCenter.y - currentSize.height/2) * (newHeight/currentSize.height)
            let centerY = newSize.height/2  + proportionateDistanceFromCenterY
            newCenter = CGPoint(x: centerX, y:centerY)
        case .MIDDLE_MIDDLE:
            let proportionateDistanceFromCenterX = (currentCenter.x - currentSize.width/2) * (newWidth/currentSize.width)
            let centerX = newSize.width/2  + proportionateDistanceFromCenterX
            let proportionateDistanceFromCenterY = (currentCenter.y - currentSize.height/2) * (newHeight/currentSize.height)
            let centerY = newSize.height/2  + proportionateDistanceFromCenterY
            newCenter = CGPoint(x: centerX, y:centerY)
            
        case .MIDDLE_RIGHT:
            let centerX = newSize.width - ((currentSize.width - currentCenter.x) * (newWidth/currentSize.width))
            let proportionateDistanceFromCenterY = (currentCenter.y - currentSize.height/2) * (newHeight/currentSize.height)
            let centerY = newSize.height/2  + proportionateDistanceFromCenterY
            newCenter = CGPoint(x: centerX, y:centerY)
        case .BOTTOM_LEFT:
            //  We going to shift from left Bottom
            let centerX = currentCenter.x * (newWidth/currentSize.width)
            let centerY = newSize.height - ((currentSize.height - currentCenter.y) * (newHeight/currentSize.height))
            newCenter = CGPoint(x: centerX, y:centerY)
        case .BOTTOM_MIDDLE:
            //  We going to shift from left Bottom
            let proportionateDistanceFromCenterX = (currentCenter.x - currentSize.width/2) * (newWidth/currentSize.width)
            let centerX = newSize.width/2  + proportionateDistanceFromCenterX
            let centerY = newSize.height - ((currentSize.height - currentCenter.y) * (newHeight/currentSize.height))
            newCenter = CGPoint(x: centerX, y:centerY)
            
        case .BOTTOM_RIGHT:
            //  We going to shift from Right & Bottom
            let centerX = newSize.width - ((currentSize.width - currentCenter.x) * (newWidth/currentSize.width))
            let centerY = newSize.height - ((currentSize.height - currentCenter.y) * (newHeight/currentSize.height))
            newCenter = CGPoint(x: centerX, y:centerY)
            
            
        }
        
        // returning newly calculated center for newSize with proportion to currentSize and center
        return newCenter
    }
    
    func getProportionalSize(currentSize:CGSize , newSize:CGSize) -> CGSize {
        var newWidth = CGFloat.zero
        var newHeight = CGFloat.zero
        
        // calculate tempWidth and heights


    // consider width as base
    let tempWidth1 = newSize.width
    // what will be the proportional tempheight?
    let tempHeight1 = tempWidth1*(currentSize.height/currentSize.width)

    // consider height as base
    let tempHeight2 = newSize.height
    // proprotional width would be...
    let tempWidth2 = tempHeight2*(currentSize.width/currentSize.height)

    // check which size lies within boundry wrt current Aspect of refSuze
    if tempHeight1 <= newSize.height {
        newWidth = tempWidth1
        newHeight = tempHeight1
    }else{
        newWidth = tempWidth2
        newHeight = tempHeight2
    }
        
        return CGSize(width: newWidth, height: newHeight)
    }

    enum WMGridPositions {
        case TOP_LEFT
        case TOP_MIDDLE
        case TOP_RIGHT
        case MIDDLE_LEFT
        case MIDDLE_MIDDLE
        case MIDDLE_RIGHT
        case BOTTOM_LEFT
        case BOTTOM_MIDDLE
        case BOTTOM_RIGHT
    }
    
       func calculateViewFrame(size: CGSize , aspectRatio: CGFloat) -> CGSize {
           var viewWidth = size.width
           var viewHeight = size.width / aspectRatio
           
           // If the calculated height exceeds the parent height, adjust the height and width
           if viewHeight > size.height {
               viewHeight = size.height
               viewWidth = viewHeight * aspectRatio
           }
           
           return CGSize(width: viewWidth, height: viewHeight)
       }
    
    func reCalculateSize(currentChildSize : CGSize , currentParentSize : CGSize , newParentSize:CGSize) -> CGSize {
       
        let newProportionalSize = getProportionalSize(currentSize: currentParentSize, newSize: newParentSize)

        
        // Calculate proportional Width
        let waterMarkWidth = currentChildSize.width * (newProportionalSize.width/currentParentSize.width)
        
        // Calculate proportional Height
        
        let waterMarkHeight = currentChildSize.height * (newProportionalSize.height/currentParentSize.height)
       
        // returning newly calculated size for newParentSize with proportion to currentParentSize and childSize
        return CGSize(width: waterMarkWidth, height: waterMarkHeight)
    }
}

