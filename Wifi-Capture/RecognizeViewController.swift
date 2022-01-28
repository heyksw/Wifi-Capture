// 문자인식을 담당하는 뷰 컨트롤러
import UIKit
import Foundation

import MLKitTextRecognitionKorean
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
    
    
    let mainDispatchQueue = DispatchQueue.main
    // 와이파이 연결을 처리할 global Queue. attribute 를 주지 않으면 serial Queue 가 됨.
    let wifiDispatchQueue = DispatchQueue(label: "WiFi")
    
    let textRecognizeDispatchQueue = DispatchQueue.global()
    
    let safetyArea: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let topTextView: UITextView = {
        let view = UITextView()
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
    
    let bottomTextView: UITextView = {
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
    
    
    override func viewDidLoad() {
        print("---------- 다음 페이지로 넘어왔음 -------------")
        
        super.viewDidLoad()
        setNavigationBar()
        setUI()
        
        
        
        textRecognizeDispatchQueue.async {
            
            guard let receivedImage = self.receivedImage else {
                return
            }

            print("받은 이미지 width , height = \(receivedImage.size.width) , \(receivedImage.size.height)")
            
            let vImage = VisionImage(image: receivedImage)
            vImage.orientation = receivedImage.imageOrientation
            
            self.textRecognize.recognizeText(uiImage: receivedImage) { [weak self] result in
                guard let result = result else { return }

                    self?.mainDispatchQueue.async {
                        self?.drawAllElement(result: result)
                        self?.bottomTextView.text += result.text
                }
            }
        }
        
        
        let tapGetPosition = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        view.addGestureRecognizer(tapGetPosition)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //removeFrames()
        // removeFrames 의 layer 는 옵셔널 타입인데, 옵셔널 바인딩 안하고 왜 에러가 안나지?
        self.elementBoxDrawing.removeFrames(layer: frameSublayer)
    }
    
}


extension RecognizeViewController: UIScrollViewDelegate, CLLocationManagerDelegate {
    
    func setNavigationBar() {
        // https://zeddios.tistory.com/864
        // 여기가 아직 문제다.
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.backgroundColor = .black
        navigationAppearance.configureWithOpaqueBackground()
        self.navigationController?.navigationBar.standardAppearance = navigationAppearance
        self.navigationController?.navigationBar.tintColor = .white
        view.backgroundColor = .black
    }
    
    
    func setUI() {
        safetyArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safetyArea)
        
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
        
        safetyArea.addSubview(topContainerView)
        topContainerView.addSubview(topTextView)
        
        safetyArea.addSubview(scrollView)
        safetyArea.addSubview(footerView)
        
        footerView.addArrangedSubview(bottomTextView)
        
        scrollView.addSubview(imageView)
        imageView.layer.addSublayer(frameSublayer)

        imageView.image = receivedImage
        
        scrollView.delegate = self 
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        
        topContainerView.snp.makeConstraints { (make) in
            make.top.equalTo(safetyArea.snp.top)
            make.height.equalTo(60)
            make.left.right.equalTo(safetyArea)
        }
        
        topTextView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
            
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(topContainerView.snp.bottom)
            make.left.right.equalTo(safetyArea)
            make.height.equalTo(view.frame.width * (4/3))
            make.bottom.equalTo(self.footerView.snp.top)
        }
        
        bottomTextView.snp.makeConstraints { make in
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
        guard let image = self.receivedImage else {
            print("--- image 에러 ----")
            return
        }
        
        print("RecognizeViewController draw All Element image width, height = \(image.size.width), \(image.size.height)")
        
        for block in result.blocks {
            for line in block.lines {
                for element in line.elements {
                    print("element = \(element.text)")
                    print("element frame = \(element.frame)")
                    self.elementBoxDrawing.addElementFrame(featureFrame: element.frame, imageSize: image.size, viewFrame: imageView.frame, layer: frameSublayer)
                }
            }
        }
    }
 
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
