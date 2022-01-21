import UIKit

class ElementBoxDrawing {
    // 인식한 Element 의 Frame 을 추가하는 함수
    func addElementFrame(featureFrame: CGRect, imageSize: CGSize, viewFrame: CGRect, layer: CALayer) {
        let viewSize = viewFrame.size
        
        // resolution
        let rView = viewSize.width / viewSize.height
        let rImage = imageSize.width / imageSize.height
        
        // Define scale based on comparing resolutions
        var scale: CGFloat
        if rView > rImage {
            //scale = viewSize.height / imageSize.height
            scale = viewSize.height / imageSize.height
        }
        else {
            scale = viewSize.width / imageSize.width
        }
        
        // Calculate scaled feature frame size
        let featureWidthScaled = featureFrame.size.width * scale
        let featureHeightScaled = featureFrame.size.height * scale
        
        // Calculate scaled feature frame top-left point
        let imageWidthScaled = imageSize.width * scale
        let imageHeightScaled = imageSize.height * scale
        
        let imagePointXScaled = (viewSize.width - imageWidthScaled) / 2
        let imagePointYScaled = (viewSize.height - imageHeightScaled) / 2
        
        let featurePointXScaled = imagePointXScaled + featureFrame.origin.x * scale
        let featurePointYScaled = imagePointYScaled + featureFrame.origin.y * scale
        
        // Define a rect for scaled feature frame
        let featureRectScaled = CGRect(x: featurePointXScaled,
                                       y: featurePointYScaled,
                                       width: featureWidthScaled,
                                       height: featureHeightScaled)
        
        drawElementFrame(featureRectScaled, layer)
    }
    
    // 추가한 Frame 을 Layer 위에 그려주는 함수
    func drawElementFrame(_ rect: CGRect, _ layer: CALayer) {
        let bpath: UIBezierPath = UIBezierPath(rect: rect)
        let rectLayer: CAShapeLayer = CAShapeLayer()
        rectLayer.path = bpath.cgPath
        rectLayer.strokeColor = Constants.lineColor
        //rectLayer.fillColor = Constants.fillColor
        rectLayer.fillColor = Constants.fillColor
        rectLayer.lineWidth = Constants.lineWidth
        
        layer.addSublayer(rectLayer)
    }
    
    // Layer 에서 그렸던 모든 Frame 을 삭제해주는 함수
    func removeFrames(layer: CALayer) {
        guard let sublayers = layer.sublayers else { return }
        for sublayer in sublayers {
            guard let frameLayer = sublayer as CALayer? else { continue }
            frameLayer.removeFromSuperlayer()
        }
    }
}

enum Constants {
    static let labelConfidenceThreshold: Float = 0.75
    static let lineWidth: CGFloat = 2.5
    static let lineColor = UIColor(red: 1, green: 0.9804, blue: 0, alpha: 0.4).cgColor
    static let fillColor = UIColor(red: 1, green: 0.9882, blue: 0.6784, alpha: 0.3).cgColor
    static let textColor = UIColor.green
    static let textSize: CGFloat = 8
}
