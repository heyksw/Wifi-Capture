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
    var elementBoxesInfo: [ElementBoxInfo] = []
    let textLinkedList = LinkedList()
    
    let mainDispatchQueue = DispatchQueue.main
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
    let imageSuperScrollView = UIScrollView()
    let imageView: UIImageView = {
        let view = UIImageView()
        //view.contentMode = .scaleAspectFit
        return view
    }()
    
    // 인식된 글자 프레임박스들이 이 레이어 위에 그려짐
    var imageViewLayer = CALayer()
    
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
    

    
    override func viewDidLoad() {
        print("---------- 다음 페이지로 넘어왔음 -------------")
        
        super.viewDidLoad()
        setNavigationBar()
        setUI()
        
        // 키보드 등장 이슈 처리
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        
        // 넘겨 받은 이미지 문자 인식, 박스 그리기
        recognizeReceivedImage()

        // 뷰 터치 이벤트
        let tapGetPosition = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        self.view.addGestureRecognizer(tapGetPosition)
        
        // 버튼 터치 이벤트
        bottomLeftButton.addTarget(self, action: #selector(tapBottomLeftButton), for: .touchDown)
        bottomRightButton.addTarget(self, action: #selector(tapBottomRightButton), for: .touchDown)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.elementBoxDrawing.removeFrames(layer: imageViewLayer)
        
        // 메모리 해제
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}


extension RecognizeViewController: UIScrollViewDelegate {
    func setNavigationBar() {
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationController?.navigationBar.backgroundColor = .black
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    // scrollView zoom 
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
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
        
        safetyArea.addSubview(imageSuperScrollView)
        safetyArea.addSubview(bottomSuperView)
        
        bottomSuperView.addSubview(bottomStackView)
        
        bottomStackView.addArrangedSubview(bottomLeftView)
        bottomStackView.addArrangedSubview(bottomMiddleView)
        bottomStackView.addArrangedSubview(bottomRightView)
        
        bottomLeftView.addSubview(bottomLeftButton)
        bottomMiddleView.addSubview(bottomMiddleButton)
        bottomRightView.addSubview(bottomRightButton)
        
        imageSuperScrollView.addSubview(imageView)
        imageView.layer.addSublayer(imageViewLayer)

        imageView.contentMode = .scaleAspectFit
        imageView.image = receivedImage
        
        imageSuperScrollView.delegate = self 
        imageSuperScrollView.zoomScale = 1.0
        imageSuperScrollView.minimumZoomScale = 1.0
        imageSuperScrollView.maximumZoomScale = 3.0
        
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
        
        imageSuperScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(topSuperView.snp.bottom)
            make.left.right.equalTo(safetyArea)
            make.bottom.equalTo(self.bottomStackView.snp.top)
        }
        
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        bottomSuperView.snp.makeConstraints { (make) in
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

    
    // 넘겨받은 이미지 문자 인식하고, frame box 그리는 함수
    func recognizeReceivedImage() {
        textRecognizeDispatchQueue.async {
            guard let receivedImage = self.receivedImage else {
                self.showUnknownErrorAlert()
                return
            }
            let vImage = VisionImage(image: receivedImage)
            vImage.orientation = receivedImage.imageOrientation
            self.textRecognize.recognizeText(uiImage: receivedImage) { [weak self] result in
                guard let result = result else { return }
                self?.recognizedResultText = result
                self?.mainDispatchQueue.async {
                    self?.drawAllElement(result: result)
//                    self?.topTextView.text += result.text
                }
            }
        }
    }
    
    
    // element box 들을 그리면서 elementBoxesInfo 에 저장.
    func drawAllElement(result: Text?) {
        var cnt = 0
        guard let result = result else {
            showUnknownErrorAlert()
            return
        }
        guard let image = self.receivedImage else {
            showUnknownErrorAlert()
            return
        }
        
        for block in result.blocks {
            for line in block.lines {
                for element in line.elements {
                    let scaledElementBoxSize = elementBoxDrawing.scaleElementBoxSize(elementFrame: element.frame, imageSize: image.size, viewFrame: imageView.frame)
                    elementBoxDrawing.drawElementBox(scaledElementBoxSize, imageViewLayer)
                    let elementBoxLayer = elementBoxDrawing.getElementBoxLayer()
                    let elementBoxInfo = ElementBoxInfo(idx: cnt, layer: elementBoxLayer, text: element.text)
                    elementBoxesInfo.append(elementBoxInfo)
                    cnt += 1
                }
            }
        }
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
        else { showUnknownErrorAlert() }
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
        else { showUnknownErrorAlert() }
    }
    
    
    // 탭 했을때 호출되는 함수
    @objc
    func handleTap(gestureRecognizer: UITapGestureRecognizer){
        // 뷰를 탭하면 키보드가 내려감
        self.topTextView.resignFirstResponder()
        
        if gestureRecognizer.state == UIGestureRecognizer.State.recognized
        {
            // super view 에서의 좌표와 image view 에서의 좌표는 다르다. convert 해줘야 함.
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            let imageViewLocation = self.view.convert(location, to: imageView)
            //print("[imageViewLocation] x = \(imageViewLocation.x), y = \(imageViewLocation.y)")
            
            // tap 된 박스가 없으면 리턴.
            guard let tappedElementBox = getWhichElementBoxTapped(imageViewLocation) else { return }
            if !tappedElementBox.tapped {
                elementBoxDrawing.changeBoxColorToYellow(tappedElementBox.layer)
                tappedElementBox.tapped = true
                textLinkedList.append(elementBoxInfo: tappedElementBox)
                self.topTextView.text = textLinkedList.getTextWithLinkedList()
            }
            else {
                elementBoxDrawing.changeBoxColorToGreen(tappedElementBox.layer)
                tappedElementBox.tapped = false
                textLinkedList.remove(elementBoxInfo: tappedElementBox)
                self.topTextView.text = textLinkedList.getTextWithLinkedList()
            }
        }
        
    }
    
    
    // 탭한 위치에 어떤 element box 가 있는지
    func getWhichElementBoxTapped(_ tappedLocation: CGPoint) -> ElementBoxInfo? {
        var resultBox: ElementBoxInfo?
        for box in elementBoxesInfo {
            if (box.layer.frame.minX <= tappedLocation.x && tappedLocation.x <= box.layer.frame.minX + box.layer.frame.width)
                &&
                (box.layer.frame.minY <= tappedLocation.y && tappedLocation.y <= box.layer.frame.minY + box.layer.frame.height) {
                resultBox = box
                break
            }
        }
        return resultBox
    }
    
    
    // 다시찍기 버튼
    @IBAction func tapBottomLeftButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    

    // 전화걸기 버튼
    @IBAction func tapBottomRightButton(_ sender: UIButton) {
        guard let resultText = self.recognizedResultText else {
            showThereIsNoPhoneNumberAlert()
            return
        }
        if let number = textRecognize.getPhoneNumber(resultText) {
            if let url = NSURL(string: "tel:\(number)"), UIApplication.shared.canOpenURL(url as URL) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
            else { showUnknownErrorAlert() }
        }
        else { showThereIsNoPhoneNumberAlert() }
    }
    
}
