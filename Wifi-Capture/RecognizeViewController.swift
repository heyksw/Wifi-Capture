// 문자인식을 담당하는 뷰 컨트롤러
import UIKit
import Foundation

import MLKitTextRecognitionKorean
import VisionKit
import MLKitVision
import SnapKit

import NetworkExtension
import SystemConfiguration.CaptiveNetwork
import CoreLocation
import SystemConfiguration

struct ExtractedResult {
    var ID: String
    var PW: String
}


class RecognizeViewController: UIViewController {
    let elementBoxDrawing = ElementBoxDrawing()
    let textRecognize = TextRecognize()
    
    // 와이파이 연결을 처리할 global Queue. attribute 를 주지 않으면 serial Queue 가 됨.
    let wifiDispatchQueue = DispatchQueue(label: "WiFi")
    
    //let koreanOptions = KoreanTextRecognizerOptions()
    var locationManager: CLLocationManager?
    let locationManagerDispatchQueue = DispatchQueue.global()
    
    let safetyArea: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    var receivedImage: UIImage?
    let scrollView = UIScrollView()
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    // 하단 버튼들이 들어갈 footer 스택 뷰
    let footerView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alignment = .fill
        view.distribution = .equalSpacing
        return view
    }()
    
    let textView: UITextView = {
        let view = UITextView()
        view.text = "[ 머신러닝 - 문자를 인식한 결과입니다. ] \n \n"
        view.backgroundColor = .black
        view.textColor = .white
        view.contentMode = .scaleAspectFit
        view.font = UIFont.systemFont(ofSize: 18)
        view.textAlignment = NSTextAlignment.center
        return view
    }()
    
    // 인식된 글자 프레임들이 이 레이어 위에 그려짐
    var frameSublayer = CALayer()

    let textReconize = TextRecognizer()
    var recognizedResult: Text?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setUI()
        // escaping closure
        textRecognize.recognizeText(image: receivedImage) { [weak self] result in
            guard let self = self else { return }
            guard let result = result else { return }
            self.recognizedResult = result
            self.drawAllElement(result: self.recognizedResult)
            self.textView.text += result.text
        }
        
        let tapGetPosition = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        view.addGestureRecognizer(tapGetPosition)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //removeFrames()
        self.elementBoxDrawing.removeFrames(layer: frameSublayer)
    }
    
}


extension RecognizeViewController: UIScrollViewDelegate, CLLocationManagerDelegate {
    
    func setNavigationBar() {
        self.navigationController?.navigationBar.tintColor = .white
        view.backgroundColor = .black
    }
    
    func setUI() {
        safetyArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safetyArea)
        imageView.layer.addSublayer(frameSublayer)
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            safetyArea.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
            safetyArea.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
            safetyArea.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
            safetyArea.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
            
        } else {
            safetyArea.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
            safetyArea.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor).isActive = true
            safetyArea.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            safetyArea.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        
        safetyArea.addSubview(scrollView)
        safetyArea.addSubview(footerView)
        
        footerView.addArrangedSubview(textView)
        
        scrollView.addSubview(imageView)

        imageView.image = receivedImage
        
        scrollView.delegate = self 
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(safetyArea)
            make.top.left.right.equalTo(safetyArea)
            make.height.equalTo(view.frame.width * (4/3))
            make.bottom.equalTo(self.footerView.snp.top)
        }
        
        textView.snp.makeConstraints { make in
            make.width.equalTo(self.view)
        }
        
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        footerView.snp.makeConstraints { (make) in
            //make.height.equalToSuperview()
            make.bottom.left.right.equalTo(safetyArea)
            make.top.equalTo(self.scrollView.snp.bottom)
        }
        
        super.updateViewConstraints()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    
    func drawAllElement(result: Text?) {
        print("---- drawAllElement 호출 ----")
        guard let result = result else {
            print("--- result 에러 ----")
            return }
        guard let image = imageView.image else {
            print("--- image 에러 ----")
            return
        }
        for block in result.blocks {
            for line in block.lines {
                for element in line.elements {
                    self.elementBoxDrawing.addElementFrame(featureFrame: element.frame, imageSize: image.size, viewFrame: imageView.frame, layer: frameSublayer)
                }
            }
        }
    }
    
//    // 세로 이미지 회전 문제로 인한 함수
//    func fixOrientation(img: UIImage) -> UIImage {
//        if (img.imageOrientation == .up) {
//            return img
//        }
//
//        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
//        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
//        img.draw(in: rect)
//
//        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//
//        return normalizedImage
//    }
    
    
//    // 문자 인식하기
//    func recognizeText(image: UIImage?){
//        let textRecognizer = TextRecognizer.textRecognizer(options: koreanOptions)
//
//        guard var image = imageView.image else {
//            return
//        }
//
//        image = fixOrientation(img: image)
//
//        let vImage = VisionImage(image: image)
//        vImage.orientation = image.imageOrientation
//
//        textRecognizer.process(vImage) { result, error in
//            guard error == nil, let result = result else {
//                print("문자 인식 과정에서 에러 발생")
//                return }
//
//            for block in result.blocks {
//                for line in block.lines {
//                    for elem in line.elements {
//                        self.elementBoxDrawing.addElementFrame(featureFrame: elem.frame, imageSize: image.size, viewFrame: self.imageView.frame, layer: self.frameSublayer)
//                    }
//                }
//            }
//
//            self.textView.text += result.text
//        }
//
//    }
    
 
    // 와이파이 연결하기
    //https://developer.apple.com/documentation/networkextension/nehotspotconfigurationmanager/2866649-apply
    func connectWifi() {
        print("---- connect Wifi 함수 실행 ----")
        let wifiConfiguration = NEHotspotConfiguration(ssid: "SK_WiFiGIGAD354_5G", passphrase: "ECI3F@6408", isWEP: false)
        
        // 와이파이가 연결 이슈를 끝낸 후에, 현재 와이파이 상태를 탐색해야하므로 sync 로 처리
        // 근데 apply의 완료 해들러는 Wi-Fi의 연결 성공여부를 리턴하지 않음.
        // error값은 Wi-Fi에 연결되지 못하더라도 성공여부 관계 없이 nil로 들어옴.
        wifiDispatchQueue.sync {
            NEHotspotConfigurationManager.shared.apply(wifiConfiguration) { error in
                print("connect Wifi 의 CompletionHandler")
                if error != nil {
                    //
                }
                else {
                    //
                }
            }
        }
        
    }
    
    // 현재 연결된 와이파이 정보 찾기
    func getCurrentWifiInfo() {
        print("---- getCurrentWifiInfo 함수 실행 ----")
        
        // connectWifi 의 일이 끝나길 기다리고, 이 일을 수행하는 것이 많다.
        wifiDispatchQueue.sync {
            NEHotspotNetwork.fetchCurrent(completionHandler: { network in
                if let captiveNetwork = network {
                    print("---- 연결된 와이파이 정보 ----")
                    print(captiveNetwork.ssid)
                } else {
                    print("와이파이에 연결되지 않았습니다")
                }
            })
        }
    }
    
    // 연결가능한 와이파이 리스트 출력
    // 그냥 연결가능한 와이파이의 리스트를 출력할 수는 없다.
    // *** Apple의 리퀘스트 승인을 받아야 함
    func searchConnectiveWifi() {
        
    }
    
    // 탭 했을때 호출되는 함수
    // super view 에서의 좌표와 image view 에서의 좌표는 다르다. convert 해줘야 함.
    @objc
    func handleTap(gestureRecognizer: UITapGestureRecognizer){
        print("---- handleTap 함수 호출 ! ----")
        if gestureRecognizer.state == UIGestureRecognizer.State.recognized
        {
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            print("[location] x = \(location.x), y = \(location.y)")
            let imageLocation = self.view.convert(location, to: imageView)
            print("[imageLocation] x = \(imageLocation.x), y = \(imageLocation.y)")
        }
    }
    
}
