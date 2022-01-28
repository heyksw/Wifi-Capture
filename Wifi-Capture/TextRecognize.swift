import Foundation
import MLKitTextRecognitionKorean
import MLKitVision

class TextRecognize {
    let textRecognizer: TextRecognizer
    let koreanOptions = KoreanTextRecognizerOptions()
    var resultText: Text?
    
    init() { textRecognizer = TextRecognizer.textRecognizer(options: koreanOptions)}
    
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
    
    
    // mlkit doc: https://developers.google.com/ml-kit/vision/text-recognition/v2/ios
    // 문자 인식. process의 completion Handler 안에 escaping closure 코드 적용
    func recognizeText(uiImage: UIImage, completion: @escaping (Text?) -> Void) {
        let fixedImage = fixOrientation(img: uiImage)
        let vImage = VisionImage(image: fixedImage)
        // 공식문서를 읽고 난 뒤의 코드. 이래야 메모리 에러가 안남.
        do {
            resultText = try textRecognizer.results(in: vImage)
            completion(resultText)
        } catch {
            print("문자 인식 과정에서 에러가 났습니다.")
            return completion(nil)
        }
    }
    
}
