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
    var areButtonsFloated = false
    var areButtonsMoving = false
    
    let elementBoxDrawing = ElementBoxDrawing()
    let textRecognize = TextRecognizing()
    var recognizedResultText: Text? = nil
    var elementBoxesInfo: [ElementBoxInfo] = []
    let textLinkedList = LinkedList()
    
    let mainDispatchQueue = DispatchQueue.main
    let textRecognizeDispatchQueue = DispatchQueue.global()
    
    let thereIsNoText = "사진에서 아무 글자도 인식하지 못했어요."
    let clickTheBoxes = "텍스트 박스를 클릭해보세요!"
    
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
    
    lazy var topTextView: UITextView = {
        let view = UITextView()
        view.autocorrectionType = .no
        view.layer.borderWidth = 2.5
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 5
        view.font = .systemFont(ofSize: 15)
        view.delegate = self
        return view
    }()
    
    var receivedImage: UIImage?
    
    let imageSuperScrollView = UIScrollView()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    // imageView 를 어둡게 만들어줄 dimView
    let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        view.isHidden = true
        return view
    }()

    let floatingView: UIStackView  = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        view.alignment = .fill
        view.distribution = .equalSpacing
        return view
    }()
    
    
    let floatingLeftView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        return view
    }()
    
    let floatingMiddleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        return view
    }()
    
    let floatingRightView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        return view
    }()
    
    let searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("검색 버튼", for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 10
        button.alpha = 0
        return button
    }()
    
    let copyButton: UIButton = {
        let button = UIButton()
        button.setTitle("복사 버튼", for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 10
        button.alpha = 0
        return button
    }()
    
    let shareButton: UIButton = {
        let button = UIButton()
        button.setTitle("공유 버튼", for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 10
        button.alpha = 0
        return button
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
        button.setTitle("갤러리", for: .normal)
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
        

        // 뷰 터치 이벤트
        let tapGetPosition = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        self.view.addGestureRecognizer(tapGetPosition)
        
        // 버튼 터치 이벤트
        bottomLeftButton.addTarget(self, action: #selector(tapBottomLeftButton), for: .touchDown)
        bottomMiddleButton.addTarget(self, action: #selector(tapBottomMiddleButton), for: .touchDown)
        bottomRightButton.addTarget(self, action: #selector(tapBottomRightButton), for: .touchDown)
        
        searchButton.addTarget(self, action: #selector(tapSearchButton(_:)), for: .touchDown)
        copyButton.addTarget(self, action: #selector(tapCopyButton(_:)), for: .touchDown)
        shareButton.addTarget(self, action: #selector(tapShareButton(_:)), for: .touchDown)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        super.viewWillAppear(animated)
        
        setNavigationBar()
         
        setUI()
        
        // 키보드 등장 이슈 처리
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        
        // 넘겨 받은 이미지 문자 인식, 박스 그리기
        recognizeReceivedImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.elementBoxDrawing.removeFrames(layer: imageViewLayer)
        
        // 메모리 해제
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        recognizedResultText = nil
        elementBoxesInfo = []
        textLinkedList.removeAllNodes()
        
        floatingButtonsDown()
        hideDimView()
    }
    
}


extension RecognizeViewController: UIScrollViewDelegate {
    
    func setNavigationBar() {
           self.navigationController?.navigationBar.tintColor = .white
           self.navigationController?.navigationBar.barTintColor = .black
           self.navigationController?.navigationBar.backgroundColor = .black
           self.navigationController?.navigationBar.isTranslucent = false
       }
    
    
    func hideNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }

    
    func showNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    
    // imageSuperScrollView zoom
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
        
        // safetyArea
        safetyArea.addSubview(topSuperView)
        safetyArea.addSubview(imageSuperScrollView)
        safetyArea.addSubview(bottomSuperView)
        
        // topSuperView
        topSuperView.addSubview(topTextView)
        //topTextView.text = "텍스트 박스를 클릭해보세요."
        
        // imageSuperScrollView
        imageSuperScrollView.addSubview(imageView)
        imageSuperScrollView.addSubview(floatingView)
        
        imageSuperScrollView.delegate = self
        imageSuperScrollView.zoomScale = 1.0
        imageSuperScrollView.minimumZoomScale = 1.0
        imageSuperScrollView.maximumZoomScale = 3.0
        
        imageView.layer.addSublayer(imageViewLayer)
        imageView.contentMode = .scaleAspectFit
        imageView.image = receivedImage
        imageView.addSubview(dimView)

        floatingView.addArrangedSubview(floatingLeftView)
        floatingView.addArrangedSubview(floatingMiddleView)
        floatingView.addArrangedSubview(floatingRightView)
        
        floatingLeftView.addSubview(searchButton)
        floatingMiddleView.addSubview(copyButton)
        floatingRightView.addSubview(shareButton)

        // bottomSuperView
        bottomSuperView.addSubview(bottomStackView)
        
        bottomStackView.addArrangedSubview(bottomLeftView)
        bottomStackView.addArrangedSubview(bottomMiddleView)
        bottomStackView.addArrangedSubview(bottomRightView)
        
        bottomLeftView.addSubview(bottomLeftButton)
        bottomMiddleView.addSubview(bottomMiddleButton)
        bottomRightView.addSubview(bottomRightButton)
        
        view.setNeedsUpdateConstraints()
    }
    
    
    override func updateViewConstraints() {
        topSuperView.snp.makeConstraints { (make) in
            make.top.equalTo(safetyArea.snp.top)
            make.height.equalTo(80)
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
        
        dimView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        floatingView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(imageSuperScrollView.frameLayoutGuide)
            make.height.equalTo(100)
        }
        
        floatingLeftView.snp.makeConstraints { make in
            make.width.equalTo(self.view).multipliedBy(0.30)
        }
        
        floatingMiddleView.snp.makeConstraints { make in
            make.width.equalTo(self.view).multipliedBy(0.30)
        }
        
        floatingRightView.snp.makeConstraints { make in
            make.width.equalTo(self.view).multipliedBy(0.30)
        }
        
        searchButton.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
        
        copyButton.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
        
        shareButton.snp.makeConstraints{ make in
            make.center.equalToSuperview()
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

    
    // 넘겨받은 이미지 문자 인식하고, element frame box 그리는 함수
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
                    
                    if result.text == "" {
                        self?.topTextView.text = self?.thereIsNoText
                    }
                    else {
                        self?.topTextView.text = self?.clickTheBoxes
                    }
                    self?.topTextView.textColor = .lightGray
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


// about button actions
extension RecognizeViewController {
    // 키보드가 올라올 때 footer view 도 같이 올라가도록
    @objc
    func keyboardWillShow(_ sender: Notification) {
        
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keybaordRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keybaordRectangle.height
            
            if bottomSuperView.frame.origin.y == safetyArea.frame.height - 100 {
                bottomSuperView.frame.origin.y -= (keyboardHeight - view.safeAreaInsets.bottom)
                
                // 도전 ! ! !
                floatingView.frame.origin.y -= (keyboardHeight - view.safeAreaInsets.bottom)
                
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
                
                // 도전 !
                floatingView.frame.origin.y += (keyboardHeight - view.safeAreaInsets.bottom)
                
                
            }
            
          }
        else { showUnknownErrorAlert() }
    }
    
    
    // 탭 했을때 호출되는 함수
    @objc
    func handleTap(gestureRecognizer: UITapGestureRecognizer){
        // bottomSuperView 를 클릭한건 무시
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        if location.y >= (self.safetyArea.frame.height - 100) {
            return
        }
        
        // 뷰를 탭하면 키보드가 내려감
        self.topTextView.resignFirstResponder()
        
        if gestureRecognizer.state == UIGestureRecognizer.State.recognized {
            // 플로딩 버튼이 띄워져 있다면 내림
            if areButtonsFloated && !areButtonsMoving {
                floatingButtonsDown()
                hideDimView()
            }
            
            // 플로팅 버튼이 띄워져 있지 않다면 박스를 클릭 가능하게 함
            if !areButtonsFloated {
                // super view 에서의 좌표와 image view 에서의 좌표는 다르다. convert 해줘야 함.
                let imageViewLocation = self.view.convert(location, to: imageView)
                
                // 어느 박스가 클릭되었는지
                guard let tappedElementBox = getWhichElementBoxTapped(imageViewLocation) else { return }
                if !tappedElementBox.tapped {
                    elementBoxDrawing.changeBoxColorToYellow(tappedElementBox.layer)
                    tappedElementBox.tapped = true
                    textLinkedList.append(elementBoxInfo: tappedElementBox)
                    self.topTextView.text = textLinkedList.getTextWithLinkedList()
                    self.topTextView.textColor = .black
                }
                else {
                    elementBoxDrawing.changeBoxColorToGreen(tappedElementBox.layer)
                    tappedElementBox.tapped = false
                    textLinkedList.remove(elementBoxInfo: tappedElementBox)
                    self.topTextView.text = textLinkedList.getTextWithLinkedList()
                }
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
    
    
    // 십자 플로팅 버튼
    @IBAction func tapBottomMiddleButton(_ sender: UIButton) {
        // 버튼들이 플로팅 되지 않은 상태이고, 움직이고 있지 않다면
        if !areButtonsFloated && !areButtonsMoving {
            floatingButtonsUp()
            showDimView()
        }
        
        // 버튼들이 플로팅 되어있고, 움직이고 있지 않다면
        else if areButtonsFloated && !areButtonsMoving {
            floatingButtonsDown()
            hideDimView()
        }
    }
    
    
    // 플로팅 버튼 올리기
    func floatingButtonsUp() {
        let gap = self.floatingLeftView.frame.width
        areButtonsMoving = true
        
        // copyButton
        self.searchButton.alpha = 0
        self.searchButton.transform = CGAffineTransform(translationX: +gap, y: 0)
        UIView.animate(withDuration: 0.1) {
            self.searchButton.transform = CGAffineTransform(translationX: +(gap/2), y: 0)
        }
        UIView.animate(withDuration: 0.3) {
            self.searchButton.alpha = 1
            self.searchButton.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        
        // wifiButton
        self.copyButton.alpha = 0
        self.copyButton.transform = CGAffineTransform(translationX: 0, y: +100)
        UIView.animate(withDuration: 0.3) {
            self.copyButton.alpha = 1
            self.copyButton.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        
        // shareButton
        self.shareButton.alpha = 0
        self.shareButton.transform = CGAffineTransform(translationX: -gap, y: 0)
        UIView.animate(withDuration: 0.1) {
            self.shareButton.transform = CGAffineTransform(translationX: -(gap/2), y: 0)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.shareButton.alpha = 1
            self.shareButton.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { finished in
            self.areButtonsFloated = true
            self.areButtonsMoving = false
        })
    }
    
    
    // 플로팅 버튼 내리기
    func floatingButtonsDown() {
        let gap = self.floatingLeftView.frame.width
        areButtonsMoving = true
        
        // searchButton
        UIView.animate(withDuration: 0.1) {
            self.searchButton.transform = CGAffineTransform(translationX: +(gap/2), y: 0)
        }
        UIView.animate(withDuration: 0.3) {
            self.searchButton.alpha = 0
            self.searchButton.transform = CGAffineTransform(translationX: +(gap), y: 0)
        }
        
        // copyButton
        UIView.animate(withDuration: 0.3) {
            self.copyButton.alpha = 0
            self.copyButton.transform = CGAffineTransform(translationX: 0, y: +100)
        }
        
        // shareButton
        UIView.animate(withDuration: 0.1) {
            self.shareButton.transform = CGAffineTransform(translationX: -(gap/2), y: 0)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.shareButton.alpha = 0
            self.shareButton.transform = CGAffineTransform(translationX: -(gap), y: 0)
        }, completion: { finished in
            self.areButtonsFloated = false
            self.areButtonsMoving = false
        })
    }
    
    
    // dimView 를 띄워서 이미지뷰를 어둡게 만듬
    func showDimView() {
        if self.dimView.isHidden {
            self.dimView.isHidden = false
        }
    }
    
    
    // dimView 를 숨겨서 이미지뷰를 다시 밝게 만듬
    func hideDimView() {
        self.dimView.isHidden = true
    }

    // 복사 버튼
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


// about imagePickerController
extension RecognizeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 갤러리 버튼
    @IBAction func tapBottomLeftButton(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = .fullScreen

        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) else {
            showUnknownErrorAlert()
            return
        }

        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    // 앨범에서 사진을 선택한 뒤 실행되는 delegate 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.receivedImage = image
            dismiss(animated: false, completion: nil)
        }
        else { showUnknownErrorAlert() }
    }
    
    
    // 갤러리 픽을 취소했을때
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


// about textview placeholder
extension RecognizeViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            guard let resultText = self.recognizedResultText else {
                showUnknownErrorAlert()
                return
            }
            if resultText.text == "" {
                textView.text = thereIsNoText
            }
            else {
                textView.text = clickTheBoxes
            }
            textView.textColor = UIColor.lightGray
        }
    }
}


// about floating buttons
extension RecognizeViewController {
    
    // 검색 버튼
    @IBAction func tapSearchButton(_ sender: UIButton) {
        guard let text = topTextView.text else {
            showUnknownErrorAlert()
            return
        }
        if let url = URL() {
            UIApplication.shared.open(url, options: [:])
        }
        else {
            showUnknownErrorAlert()
        }
    }
    
    
    // 복사 버튼
    @IBAction func tapCopyButton(_ sender: UIButton) {
        if topTextView.textColor == UIColor.lightGray || topTextView.text == "" {
            showNoCopyToast()
        }
        else {
            UIPasteboard.general.string = topTextView.text
            showCopyToastt(copiedText: topTextView.text)
        }
    }
    
    
    // 공유 버튼
    @IBAction func tapShareButton(_ sender: UIButton) {
        var shareObject = [Any]()
        shareObject.append(topTextView.text ?? "")
        
        let activityViewController = UIActivityViewController(activityItems: shareObject, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
 
}
