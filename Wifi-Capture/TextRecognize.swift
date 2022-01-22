import Foundation
import MLKitTextRecognitionKorean
import VisionKit
import MLKitVision

class TextRecognize {
    let textRecognizer: TextRecognizer
    let koreanOptions = KoreanTextRecognizerOptions()
    
    init() {
        textRecognizer = TextRecognizer.textRecognizer(options: koreanOptions)
    }
    
    // 아이폰 세로 이미지 회전 문제로 인한 함수
    func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) { return img }
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
         
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    
    // 문자 인식
    func recognizeText(image: UIImage?, completion: @escaping (Text?) -> Void) {
        guard var image = image else { return }
        var resultText: Text?
        image = fixOrientation(img: image)

        let vImage = VisionImage(image: image)
        vImage.orientation = image.imageOrientation
        
        textRecognizer.process(vImage) { result, error in
            guard error == nil, let result = result else { return }
            resultText = result
            completion(resultText)
        }
    }
}
