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
    let textRecognize = TextRecognizing()
    var recognizedResultText: Text? = nil
    
    let mainDispatchQueue = DispatchQueue.main
    // 와이파이 연결을 처리할 global Queue. attribute 를 주지 않으면 serial Queue 가 됨.
    let wifiDispatchQueue = DispatchQueue(label: "WiFi")
    
    let textRecognizeDispatchQueue = DispatchQueue.global()
    
    let safetyArea: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let topSuperView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let topTextView: UITextView = {
        let view = UITextView()
        view.autocorrectionType = .no
        return view
    }()
    
    var receivedImage: UIImage?
    let scrollView = UIScrollView()
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let bottomSuperView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // 하단 버튼들이 들어갈 footer 스택 뷰
    let bottomStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alignment = .fill
        view.distribution = .equalSpacing
        return view
    }()

    
    let bottomLeftView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let bottomMiddleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let bottomRightView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let bottomLeftButton: UIButton = {
        let button = UIButton()
        button.setTitle("다시 찍기", for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 10
        return button
    }()
    
    let bottomMiddleButton: UIButton = {
        let button = UIButton()
        button.setTitle("십자 버튼", for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 10
        return button
    }()
    
    let bottomRightButton: UIButton = {
        let button = UIButton()
        button.setTitle("전화 버튼", for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 10
        return button
    }()
    
    // 인식된 글자 프레임들이 이 레이어 위에 그려짐
    var frameSublayer = CALayer()
    
    
    override func viewDidLoad() {
        print("---------- 다음 페이지로 넘어왔음 -------------")
        
        super.viewDidLoad()
        setNavigationBar()
        setUI()
        
        // 키보드 등장 이슈
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        
        recognizeReceivedImage()

        let tapGetPosition = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        self.view.addGestureRecognizer(tapGetPosition)
        
        bottomLeftButton.addTarget(self, action: #selector(tapBottomLeftButton), for: .touchDown)
        bottomRightButton.addTarget(self, action: #selector(tapBottomRightButton), for: .touchDown)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //removeFrames()
        // removeFrames 의 layer 는 옵셔널 타입인데, 옵셔널 바인딩 안하고 왜 에러가 안나지?
        self.elementBoxDrawing.removeFrames(layer: frameSublayer)
        
        // 메모리 해제
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}


extension RecognizeViewController: UIScrollViewDelegate, CLLocationManagerDelegate {
    
    func setNavigationBar() {
        // https://zeddios.tistory.com/864
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationController?.navigationBar.backgroundColor = .black
        self.navigationController?.navigationBar.isTranslucent = false
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
        
        safetyArea.addSubview(topSuperView)
        topSuperView.addSubview(topTextView)
        
        safetyArea.addSubview(scrollView)
        safetyArea.addSubview(bottomSuperView)
        
        bottomSuperView.addSubview(bottomStackView)
        
        bottomStackView.addArrangedSubview(bottomLeftView)
        bottomStackView.addArrangedSubview(bottomMiddleView)
        bottomStackView.addArrangedSubview(bottomRightView)
        
        bottomLeftView.addSubview(bottomLeftButton)
        bottomMiddleView.addSubview(bottomMiddleButton)
        bottomRightView.addSubview(bottomRightButton)
        
        scrollView.addSubview(imageView)
        imageView.layer.addSublayer(frameSublayer)

        imageView.contentMode = .scaleAspectFit
        imageView.image = receivedImage
        
        scrollView.delegate = self 
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        topSuperView.snp.makeConstraints { (make) in
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
            make.top.equalTo(topSuperView.snp.bottom)
            make.left.right.equalTo(safetyArea)
            //make.height.equalTo(view.frame.width * (4/3))
            make.bottom.equalTo(self.bottomStackView.snp.top)
        }
        
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        bottomSuperView.snp.makeConstraints { (make) in
            //make.height.equalToSuperview()
//            make.bottom.left.right.equalTo(safetyArea)
//            make.top.equalTo(self.scrollView.snp.bottom)
            
            make.left.right.bottom.equalTo(safetyArea)
            make.height.equalTo(100)
        }
        
        bottomStackView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        bottomLeftView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view).multipliedBy(0.30)
        }
        
        bottomMiddleView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view).multipliedBy(0.30)
        }
        
        bottomRightView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view).multipliedBy(0.30)
        }
        
        bottomLeftButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        bottomMiddleButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        bottomRightButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        super.updateViewConstraints()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func recognizeReceivedImage() {
        textRecognizeDispatchQueue.async {
            guard let receivedImage = self.receivedImage else {
                return
            }
            let vImage = VisionImage(image: receivedImage)
            vImage.orientation = receivedImage.imageOrientation
            self.textRecognize.recognizeText(uiImage: receivedImage) { [weak self] result in
                guard let result = result else { return }
                self?.recognizedResultText = result
                
                self?.mainDispatchQueue.async {
                    self?.drawAllElement(result: result)
                    self?.topTextView.text += result.text
                }
                
            }
        }
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
    
}



extension RecognizeViewController {
    
    // 키보드가 올라올 때 footer view 도 같이 올라가도록
    @objc
    func keyboardWillShow(_ sender: Notification) {
        
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keybaordRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keybaordRectangle.height
            
            if bottomSuperView.frame.origin.y == safetyArea.frame.height - 100 {
                bottomSuperView.frame.origin.y -= (keyboardHeight - view.safeAreaInsets.bottom)
            }
          }
        
    }
    
    // 키보드가 내려갈 때 footer view 도 다시 같이 내려감
    @objc
    func keyboardWillHide(_ sender: Notification) {

        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keybaordRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keybaordRectangle.height
            
            if bottomSuperView.frame.origin.y == safetyArea.frame.height - 100 - (keyboardHeight - view.safeAreaInsets.bottom) {
                bottomSuperView.frame.origin.y += (keyboardHeight - view.safeAreaInsets.bottom)
            }
            
          }
        
    }
    
    // 탭 했을때 호출되는 함수
    // super view 에서의 좌표와 image view 에서의 좌표는 다르다. convert 해줘야 함.
    @objc
    func handleTap(gestureRecognizer: UITapGestureRecognizer){
        // 뷰를 탭하면 키보드가 내려감
        self.topTextView.resignFirstResponder()
        
        print("---- handleTap 함수 호출 ! ----")
        if gestureRecognizer.state == UIGestureRecognizer.State.recognized
        {
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            print("[location] x = \(location.x), y = \(location.y)")
            let imageLocation = self.view.convert(location, to: imageView)
            print("[imageLocation] x = \(imageLocation.x), y = \(imageLocation.y)")
        }
        //view.endEditing(true)
    }
    
    // 다시찍기 버튼
    @IBAction func tapBottomLeftButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    

    // 전화걸기 버튼
    //https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/PhoneLinks/PhoneLinks.html#//apple_ref/doc/uid/TP40007899-CH6-SW1 이거 읽어보니까 안되는듯.
    @IBAction func tapBottomRightButton(_ sender: UIButton) {
        guard let resultText = self.recognizedResultText else {
            showThereIsNoPhoneNumberAlert()
            return
        }
        if let number = textRecognize.getPhoneNumber(resultText) {
            if let url = NSURL(string: "tel:\(number)"), UIApplication.shared.canOpenURL(url as URL) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
            else {
                showUnknownErrorAlert()
            }
        }
        else {
            showThereIsNoPhoneNumberAlert()
        }
    }
    
//    // 인식한 전화번호가 없을 때
//    func showThereIsNoPhoneNumberAlert() {
//        let alert = UIAlertController(title:"인식 에러", message: "인식한 전화번호가 없습니다.", preferredStyle: .alert)
//        let okButton = UIAlertAction(title: "확인", style: .default) { (action) in
//            self.dismiss(animated: true, completion: nil)
//        }
//        alert.addAction(okButton)
//        self.present(alert, animated: true, completion: nil)
//    }
    
//    // 알 수 없는 에러 처리
//    func showUnknownErrorAlert() {
//        let alert = UIAlertController(title:"죄송합니다", message: "알 수 없는 에러가 발생했습니다.", preferredStyle: .alert)
//        let okButton = UIAlertAction(title: "확인", style: .default) { (action) in
//            self.dismiss(animated: true, completion: nil)
//        }
//        alert.addAction(okButton)
//        self.present(alert, animated: true, completion: nil)
//    }
    
}
