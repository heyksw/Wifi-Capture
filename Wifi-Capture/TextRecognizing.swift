import Foundation
import MLKitTextRecognitionKorean
import MLKitVision
import QuartzCore


class TextRecognizing {
    let textRecognizer: TextRecognizer
    let koreanOptions = KoreanTextRecognizerOptions()
    var resultText: Text?
    
    let consideredAsNumber: Array<Character> = Array<Character>(["o", "O", "ㅇ", "-", "."])
    let confusingWithZero: Array<Character> = Array<Character>(["o", "O", "ㅇ"])
    
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


// about phone number
extension TextRecognizing {

    func isConsideredAsNumber(_ x: Character) -> Bool {
        if consideredAsNumber.contains(x) || x.isNumber {
            return true
        }
        else {
            return false
        }
    }

    func elemIsNumber(_ elem: String) -> Bool {
        var result: Bool = true
        for x in elem {
            if !isConsideredAsNumber(x) {
                result = false
                break
            }
        }
        return result
    }

    func refineElemNumber(_ number: String) -> String {
        var result: String = ""
        for x in number {
            if x.isNumber {
                result += String(x)
            }
            else if confusingWithZero.contains(x) {
                result += "0"
            }
        }
        return result
    }
    
    func textToStringArray(_ resultText: Text?) -> Array<String>? {
        guard let result = resultText else { return nil }
        var arr: Array<String> = Array<String>()
        for block in result.blocks {
            for line in block.lines {
                for elem in line.elements {
                    arr.append(elem.text)
                }
            }
        }
        return arr
    }

    // 결과적으로 전화번호를 리턴하는 함수.
    func getPhoneNumber(_ result: Text?) -> String? {
        guard let elements = textToStringArray(result) else { return nil }
        print("======== getPhoneNumber 호출 ========")
        var answer: String = ""
        for elem in elements {
            if elemIsNumber(elem) {
                answer += refineElemNumber(elem)
            }
            else {
                answer = ""
            }
            
            if 10 <= answer.count && answer.count <= 11 {
                break
            }
        }
        if answer.count < 10 || answer.count > 11 {
            return nil
        }
        return answer
    }

}


// 인식 화면에서, 인식한 element box 들을 인스턴스화 하기 위한 클래스.
class ElementBoxInfo {
    lazy var idx = -1
    lazy var layer = CALayer()
    lazy var text = String()
    var tapped: Bool = false

    init(idx: Int, layer: CALayer, text: String) {
        self.idx = idx
        self.layer = layer
        self.text = text
    }
}
