import UIKit

class ElementBoxDrawing: NSObject, CALayerDelegate {
    lazy var layer = CALayer()

    // 이미지에 인식된 frame box 사이즈를 view 사이즈에 맞게 조정하는 함수
    func scaleElementBoxSize(elementFrame: CGRect, imageSize: CGSize, viewFrame: CGRect) -> CGRect {
        let viewSize = viewFrame.size
        
        // 비율 처리
        let rView = viewSize.width / viewSize.height
        let rImage = imageSize.width / imageSize.height
        
        // 비율 계산
        var scale: CGFloat
        if rView > rImage { scale = viewSize.height / imageSize.height }
        else { scale = viewSize.width / imageSize.width }
        
        // scale 을 고려한 element size
        let scaledElementWidth = elementFrame.size.width * scale
        let scaledElementHeight = elementFrame.size.height * scale
        
        // scale 을 고려한 image size
        let scaledImageWidth = imageSize.width * scale
        let scaledImageHeight = imageSize.height * scale
        
        // scale 을 고려한 image 좌표
        let scaledImagePointX = (viewSize.width - scaledImageWidth) / 2
        let scaledImagePointY = (viewSize.height - scaledImageHeight) / 2
        
        // sclae 을 고려한 frame 좌표
        let scaledElementPointX = scaledImagePointX + elementFrame.origin.x * scale
        let scaledElementPointY = scaledImagePointY + elementFrame.origin.y * scale
        
        // 모든 계산을 끝낸 frame box
        let scaledElementFrameBox = CGRect(x: scaledElementPointX,
                                       y: scaledElementPointY,
                                       width: scaledElementWidth,
                                       height: scaledElementHeight)
        
        return scaledElementFrameBox
//        drawElementFrameBox(scaledElementFrameBox, layer)
    }
    
    
    // 추가한 Frame 을 Layer 위에 그려주는 함수
    func drawElementBox(_ frameBoxRect: CGRect, _ layer: CALayer) {
        let newFrameBoxSublayer = CALayer()
        newFrameBoxSublayer.frame = frameBoxRect
        newFrameBoxSublayer.borderColor = Constants.greenLineColor
        newFrameBoxSublayer.backgroundColor = Constants.greenFillColor
        newFrameBoxSublayer.borderWidth = Constants.lineWidth
        self.layer = newFrameBoxSublayer
        
        layer.addSublayer(newFrameBoxSublayer)
        //return newFrameBoxSublayer
    }
    
    
    func getElementBoxLayer() -> CALayer {
        return self.layer
    }
    
    
    // Layer 에서 그렸던 모든 Frame 을 삭제해주는 함수
    func removeFrames(layer: CALayer?) {
        guard let layer = layer else { return }
        guard let sublayers = layer.sublayers else { return }
        for sublayer in sublayers {
            guard let frameLayer = sublayer as CALayer? else { continue }
            frameLayer.removeFromSuperlayer()
        }
    }
    
    // 박스가 선택됐을 때 색상을 변경하는 함수
    func changeBoxColor_Select(_ frameBoxLayer: CALayer) {
//        frameBoxLayer.borderColor = Constants.yellowLineColor
//        frameBoxLayer.backgroundColor = Constants.yellowFillColor
        frameBoxLayer.borderColor = Constants.yellowLineColor2
        frameBoxLayer.backgroundColor = Constants.yellowFillColor2
    }
    
    func changeBoxColor_Unselect(_ frameBoxLayer: CALayer) {
        frameBoxLayer.borderColor = Constants.greenLineColor
        frameBoxLayer.backgroundColor = Constants.greenFillColor
//        frameBoxLayer.borderColor = Constants.blueBlackLineColor
//        frameBoxLayer.backgroundColor = Constants.blueBlackFillColor
    }
    
}



enum Constants {
    static let blueBlackBackgroundColor = UIColor(red: 7/255, green: 13/255, blue: 56/255, alpha: 1.0)
    static let deepDarkGrayColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
    
    static let labelConfidenceThreshold: Float = 0.75
    static let lineWidth: CGFloat = 2
    
    static let yellowLineColor = UIColor(red: 1, green: 0.9804, blue: 0, alpha: 0.4).cgColor
    static let yellowFillColor = UIColor(red: 1, green: 0.9882, blue: 0.6784, alpha: 0.3).cgColor

    // 연두로 선택하기로 했음 선택지 1
    static let greenLineColor = UIColor(red: 0, green: 1, blue: 0.4471, alpha: 0.45).cgColor
    static let greenFillColor = UIColor(red: 0, green: 1, blue: 0.4471, alpha: 0.3).cgColor
    
    
    // 바꾼 색상
    
    static let skyblueLineColor = UIColor(red: 0.3882, green: 0.698, blue: 0.9412, alpha: 0.4).cgColor
    static let skyblueFillColor = UIColor(red: 0.3882, green: 0.698, blue: 0.9412, alpha: 0.3).cgColor
    
    static let blueBlackLineColor = UIColor(red: 34/255, green: 96/255, blue: 167/255, alpha: 0.4).cgColor
    static let blueBlackFillColor = UIColor(red: 34/255, green: 96/255, blue: 167/255, alpha: 0.3).cgColor
    
    static let yellowLineColor2 = UIColor(red: 255/255, green: 251/255, blue: 53/255, alpha: 0.6).cgColor
    static let yellowFillColor2 = UIColor(red: 255/255, green: 251/255, blue: 53/255, alpha: 0.4).cgColor
//    static let lineColor = UIColor(red: 0.3647, green: 0.9569, blue: 0.3922, alpha: 0.45).cgColor
//    static let fillColor = UIColor(red: 0.3647, green: 0.9569, blue: 0.3922, alpha: 0.3).cgColor
    
//    // 보라
    
//    static let lineColor = UIColor(red: 1, green: 0, blue: 0.9647, alpha: 0.45).cgColor
//    static let fillColor = UIColor(red: 1, green: 0, blue: 0.9647, alpha: 0.35).cgColor
}
