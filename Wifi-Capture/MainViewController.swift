import SnapKit
import Foundation
import UIKit
import AVFoundation
import Photos
// MLkit
import MLKitTextRecognitionKorean
import MLKitVision
// Indicator View
import NVActivityIndicatorView


class MainViewController: UIViewController {
    var didCall = false
    var imageToDeliver: UIImage?
    var phoneNumber: String? = nil
    // CIContext 를 만드는건 코스트가 많이 들어서 처음에 선언하고 재사용 하는 것이 좋다.
    let ciContext = CIContext()
    var testCount = 1
    
    let elementBoxDrawing = ElementBoxDrawing()
    let textRecognize = TextRecognizing()
    
    
    enum UserStates {
        case beforeTakePictures
        case afterTakePictures
    }
    
    var userState: UserStates?
    var didSetupConstraints = false
    
    var captureDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var deviceInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    var setting: AVCapturePhotoSettings?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    let mainDispatchQueue = DispatchQueue.main
    let globalDispatchQueue = DispatchQueue.global()
    
    
    var videoOutput: AVCaptureVideoDataOutput?
    var orientation: AVCaptureVideoOrientation = .portrait
    let videoQueue = DispatchQueue(label: "Video Camera Queue")
    
    
    var recognizedPhotoScale: CGFloat = 1.0
    let maxPhotoScale: CGFloat = 3.0
    let minPhotoScale: CGFloat = 1.0
     
    
    // safe area
    let safetyArea: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    // 카메라 들어갈 뷰
    let cameraView: UIImageView = {
        let view = UIImageView()
        //view.image = UIImage(named: "cute_cat")
        
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
    
    // footer 에 왼쪽, 중간, 오른쪽 뷰
    let footerLeftView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    let footerCenterView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let footerRightView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    // footer 에 들어갈 전면, 후면 반전 버튼
    let galleryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("갤러리", for: .normal)
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    let cameraShootButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("촬영", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let turnButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("화면 전환", for: .normal)
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    

    var frameSublayer = CALayer()

    var recognizeResult: Text? {
        didSet {
            frameSublayer.setNeedsDisplay()
        }
    }
    
    lazy var cameraViewCenterX: CGFloat = cameraView.frame.width / 2
    lazy var cameraViewCenterY: CGFloat = cameraView.frame.height / 2
    lazy var loadingIndicator = NVActivityIndicatorView(frame: CGRect(x: cameraViewCenterX, y: cameraViewCenterY, width: 50, height: 50), type: .ballScaleMultiple, color: .black, padding: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 상단 네비게이션 바 세팅
        self.setNavigationBar()
        
        // UI 세팅
        self.setUI()
        
        //self.cameraView.drawRect(imageView: self.cameraView)
        
        // 앨범에 접근할 권한 요청
        self.getPhotoLibraryAuthorization()
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(_:)))
        let tapFocus = UITapGestureRecognizer(target: self, action: #selector(self.tapFocus(_:)))
        
        view.addGestureRecognizer(pinch)
        view.addGestureRecognizer(tapFocus)
        
        cameraShootButton.addTarget(self, action: #selector(tapCameraShootButton(_:)), for: .touchDown)
        galleryButton.addTarget(self, action: #selector(tapGalleryButton), for: .touchDown)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    
    
    // AVFoundation camera setting
    func setCamera() {
        print("setting Camera")
        guard let captureDevice = getDefaultCamera() else {
            return
        }
        
        self.captureDevice = captureDevice
        
        do {
            captureSession = AVCaptureSession()
            captureSession?.sessionPreset = .photo
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            photoOutput = AVCapturePhotoOutput()
            setting = AVCapturePhotoSettings()
            
            // video 추가
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA)]

            // 공식문서를 읽고 추가한 코드
            videoOutput?.alwaysDiscardsLateVideoFrames = true
            
            // Sets the sample buffer delegate and the queue for invoking callbacks.
            videoOutput?.setSampleBufferDelegate(self, queue: videoQueue)
            guard let videoOutput = videoOutput else { return }
            
            captureSession?.addOutput(videoOutput)
            
            
            guard let input = deviceInput, let output = photoOutput else {return}
            
            captureSession?.addInput(input)
            captureSession?.addOutput(output)
            
            guard let session = captureSession else {return}
            
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            guard let previewLayer = previewLayer else {
                return
            }
            
            // 이렇게 하는게 맞나 ..?
            previewLayer.addSublayer(frameSublayer)
            
            // startRunning 은 UI 쓰레드를 방해할 수 있기 때문에 다른 쓰레드에 담아줌
            globalDispatchQueue.async {
                // 재 촬영 버튼을 누른다면 다시 start 해주도록 나중에 구현해야 함.
                session.startRunning()
            }
            
            mainDispatchQueue.async {
                previewLayer.frame = self.cameraView.frame
                self.cameraView.layer.addSublayer(previewLayer)
                
            }
            
        } catch {
            print("setting Camera Error")
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // user state 세팅
        self.userState = .beforeTakePictures
        // 카메라 불러오기
        self.setCamera()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        globalDispatchQueue.async {
            self.captureSession?.stopRunning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    static func instance() -> MainViewController {
        let mainViewController = MainViewController()
        return mainViewController
    }

}


// 익스텐션
extension MainViewController: AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // 네비게이션 바 세팅
    func setNavigationBar() {
        self.navigationItem.title = "와캡"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = .white
        view.backgroundColor = .black
        
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: nil)
        let informationButton = UIBarButtonItem(image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: nil)
        
        navigationItem.rightBarButtonItem = settingButton
        navigationItem.leftBarButtonItem = informationButton
    }
        
    // UI 배치, StackView 배치
    func setUI() {
        safetyArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safetyArea)
        
        cameraView.layer.addSublayer(frameSublayer)
        
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
        

        safetyArea.addSubview(cameraView)
        safetyArea.addSubview(footerView)
        
        footerView.addArrangedSubview(footerLeftView)
        footerView.addArrangedSubview(footerCenterView)
        footerView.addArrangedSubview(footerRightView)
        
        footerLeftView.addSubview(galleryButton)
        footerCenterView.addSubview(cameraShootButton)
        footerRightView.addSubview(turnButton)
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        cameraView.addSubview(self.loadingIndicator)
        
        view.setNeedsUpdateConstraints()
    }
    
    // SnapKit 으로 Constraint 설정
    override func updateViewConstraints() {
        if (!didSetupConstraints) {
            cameraView.snp.makeConstraints { (make) in
                make.top.equalTo(safetyArea)
                make.top.left.right.equalTo(safetyArea)
                //print("value = \(view.frame.width * 4/3)")
                make.height.equalTo(view.frame.width * 4/3)
                make.bottom.equalTo(self.footerView.snp.top)
            }

            footerView.snp.makeConstraints { (make) in
                //make.height.equalTo(200)
                make.bottom.left.right.equalTo(safetyArea)
                make.top.equalTo(self.cameraView.snp.bottom)
            }
            
            footerLeftView.snp.makeConstraints { make in
                make.width.equalTo(self.view).multipliedBy(0.30)
            }
            
            footerCenterView.snp.makeConstraints { make in
                make.width.equalTo(self.view).multipliedBy(0.30)
            }
            
            footerRightView.snp.makeConstraints { make in
                make.width.equalTo(self.view).multipliedBy(0.30)
            }
            
            galleryButton.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            cameraShootButton.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            turnButton.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        
            
            didSetupConstraints = true
        }
        
        print("main camera view")
        print(cameraView.bounds.size.width)
        print(cameraView.bounds.size.height)

        super.updateViewConstraints()

    }
    
    // iphone 버전 별로 Camera Type 이 다르기 때문에 버전 별로 최적의 device camera 찾기
    // https://developer.apple.com/documentation/avfoundation/avcapturedevice/2361508-default
    func getDefaultCamera() -> AVCaptureDevice? {
        
        var deviceTypes: [AVCaptureDevice.DeviceType]!
        if #available(iOS 11.1, *)
        { deviceTypes = [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera] }
        else
        { deviceTypes = [.builtInDualCamera, .builtInWideAngleCamera] }
        let discoverySession = AVCaptureDevice.DiscoverySession( deviceTypes: deviceTypes, mediaType: .video, position: .unspecified )
        let devices = discoverySession.devices
        guard !devices.isEmpty else { fatalError("Missing capture devices.")}
        
        return devices.first(where: { device in device.position == .back })!
        
        
//        if let device = AVCaptureDevice.default(.builtInDualCamera,for: AVMediaType.video,position: .back) {
//            return device
//        }
//        else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video,position: .back) {
//            return device
//        }
//        else { return nil }
    }
    
    

    // 사진 앨범 접근 권한 요청
    func getPhotoLibraryAuthorization() {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("not authorized error")
                // 나중에 "앱을 다시 시작해보세요" 같은 에러 처리 구현해줘야겠다.
                return
            }
        }
    }
    
    // photoCapture process 가 끝날 떄 호출되는 delegate 메서드
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("photoOutput")
        
        guard error == nil else {
            print("Photo Output Error !")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("imageData Error")
            return}
        
        let outputImage = UIImage(data: imageData)
        guard let outputImage = outputImage else { return }
        self.imageToDeliver = outputImage
        
        // globalQueue 에서 Session stop
        globalDispatchQueue.async {
            self.captureSession?.stopRunning()
        }
        
        self.elementBoxDrawing.removeFrames(layer: self.frameSublayer)
        
        // mainQueue 쓰레드에서 UI 작업
        mainDispatchQueue.async {
            self.cameraView.layer.contents = outputImage
            // 보내줄 때 scale 1로 초기화
            self.recognizedPhotoScale = 1.0
        }
        
        // 사진을 찍으면 자동으로 저장
        // Asynchronously runs a block that requests changes to the photo library.
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: imageData, options: nil)
        }, completionHandler: nil)
        
        userState = .afterTakePictures
        
        
        
        // 전화번호를 인식했으면 전화를 건다.
        globalDispatchQueue.async {
            self.textRecognize.recognizeText(uiImage: outputImage) { [weak self] result in
                guard let result = result else { return }
                self?.phoneNumber = self?.textRecognize.getPhoneNumber(result)
                
                self?.mainDispatchQueue.async {
                    print("=================== 주목 =====================")
                    // 여기에 화면 블러처리도 넣으면 좋을듯
                    
                    
                    // 전화번호를 인식했으면
                    if let number = self?.phoneNumber {
                        // call 에 completion handler로 pushToNextPage 를 넣었음
                        self?.call(phoneNumber: number, outputImage: outputImage)
                        self?.pushToNextPage()
                    }
                    else {
                        // 인식한 전화번호가 없습니다.
                        print("인식한 전화번호가 없습니다.")
                        let alert = UIAlertController(title:"인식 에러", message: "인식한 전화번호가 없습니다.", preferredStyle: .alert)
                        let okButton = UIAlertAction(title: "확인", style: .default) { (action) in
                            self?.dismiss(animated: true, completion: nil)
                            self?.pushToNextPage()
                        }
                        alert.addAction(okButton)
                        self?.present(alert, animated: true, completion: nil)
                    }

                }
            }
        }
        
        
        //pushToNextPage(outputImage)
 
    }
    
    // 촬영한 이미지를 가지고 다음 페이지로 넘기는 함수
    func pushToNextPage() {
        guard let outputImage = self.imageToDeliver else {
            return
        }
        // 넘어가기
        let recognizeViewController = RecognizeViewController()
        print("다음 페이지로 넘길 때 height, width \(outputImage.size.height) , \(outputImage.size.width)")

        recognizeViewController.receivedImage = outputImage
        self.navigationController?.pushViewController(recognizeViewController, animated: true)
    }
    
    // 전화를 마치고 다음 페이지로 넘기기 위한 함수
    // 앱이 background 상태로 넘어갔을 때 실행
//    @objc
//    func didEnterBackground() {
//        if didCall { pushToNextPage() }
//    }

    // 촬영 버튼 클릭 이벤트
    @IBAction func tapCameraShootButton(_ sender: UIButton) {
        guard let setting = setting else {return}
        photoOutput?.capturePhoto(with: setting, delegate: self)
        
    }
    
    // 갤러리 버튼 클릭 이벤트 -> 앨범에 접근, 근데 현재 딜레이가 좀 있음.
    // https://developer.apple.com/documentation/uikit/uiimagepickercontroller
    @IBAction func tapGalleryButton(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()

        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) else {
            showUnknownErrorAlert()
            return
        }

        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        globalDispatchQueue.async {
            self.captureSession?.stopRunning()
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 앨범에서 사진을 선택한 뒤 실행되는 delegate 메서드
    // https://developer.apple.com/documentation/uikit/uiimagepickercontrollerdelegate/1619126-imagepickercontroller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            // 문자 인식 페이지로 넘어감
            let recognizeViewController = RecognizeViewController()
            recognizeViewController.receivedImage = image
            
            dismiss(animated: true, completion: nil)
            self.navigationController?.pushViewController(recognizeViewController, animated: false)
            
        }
    }
    
    // 갤러리 픽을 취소했을때
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        globalDispatchQueue.async {
            self.captureSession?.startRunning()
        }
        dismiss(animated: true, completion: nil)
    }
    

    
    func drawAllElement(result: Text?, imageSize: CGSize) {
        //print("----- drawAllElement 호출")
        guard let result = result else {
            print("result 에러")
            return }
 
        for block in result.blocks {
            for line in block.lines {
//                self.elementBoxDrawing.addBlockFrame(featureFrame: block.frame, imageSize: image.size, viewFrame: cameraView.frame, layer: self.frameSublayer)
                for element in line.elements {
                    print("1 element = \(element.text)")
                    print("1 element Frame = \(element.frame)")
                    self.elementBoxDrawing.addElementFrame(featureFrame: element.frame, imageSize: imageSize, viewFrame: cameraView.frame, layer: self.frameSublayer)
                }
            }
        }
    }
}



extension UIImage {
    // 이미지 회전 에러가 났을 때 원래대로 돌려줄 회전 함수
    func rotateImage(radians: Float) -> UIImage? {
            var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
            // Trim off the extremely small float value to prevent core graphics from rounding it up
            newSize.width = floor(newSize.width)
            newSize.height = floor(newSize.height)

            UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
            let context = UIGraphicsGetCurrentContext()!

            // Move origin to middle
            context.translateBy(x: newSize.width/2, y: newSize.height/2)
            // Rotate around middle
            context.rotate(by: CGFloat(radians))
            // Draw the image at its center
            self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage
        }
}



// About Video Image Buffer
extension MainViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // 코드 실행 시간 측정을 위한 함수. 시간을 개선시켜야겠다. -> 지금 현재가 최선인듯하다. 내 역량안에서는.
    public func measureTime(_ closure: () -> ()) {
        let startDate = Date()
        closure()
        print( Date().timeIntervalSince(startDate) )
    }
    
    
    // Methods for receiving sample buffers from, and monitoring the status of, a video data output.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage: CIImage = CIImage(cvImageBuffer: imageBuffer)
        guard let cgImage: CGImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return }
        var uiImage: UIImage = UIImage(cgImage: cgImage)
        // 이미지 회전 에러가 났다면 제대로 다시 돌려줌.
        if uiImage.size.width > uiImage.size.height {
            guard let newImage = uiImage.rotateImage(radians: .pi/2) else { return }
            uiImage = newImage
        }
        
        textRecognize.recognizeText(uiImage: uiImage) { [weak self] result in
            guard let result = result else { return }
            self?.mainDispatchQueue.async {
                self?.elementBoxDrawing.removeFrames(layer: self?.frameSublayer)
                self?.drawAllElement(result: result, imageSize: uiImage.size)
            }
        }
        
    }
}



// About Gesture
extension MainViewController {
    // 카메라 줌 인, 줌 아웃 구현
    // 사진 줌 인, 줌 아웃 구현
    // device.videoZoomFactor 에 접근하려면 lock / unlock 과정이 필요함
    // https://developer.apple.com/documentation/avfoundation/avcapturedevice
    // https://gist.github.com/yusuke024/3b5a89835deab5b9027efea794b80a45
    @objc
    func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        print("====== handlePinch 호출 ======")
        
        // 사진을 찍기 전, 카메라가 실시간으로 보이고 있는 상황에서의 zoom 구현
        if (self.userState == .beforeTakePictures) {
            guard let device = self.captureDevice else {return}
            
            var initialScale: CGFloat = device.videoZoomFactor
            let minAvailableZoomScale = 1.0
            let maxAvailableZoomScale = device.maxAvailableVideoZoomFactor
            
            do {
                try device.lockForConfiguration()
                if(pinch.state == UIPinchGestureRecognizer.State.began){
                    initialScale = device.videoZoomFactor
                }
                else {
                    if(initialScale*(pinch.scale) < minAvailableZoomScale){
                        device.videoZoomFactor = minAvailableZoomScale
                    }
                    else if(initialScale*(pinch.scale) > maxAvailableZoomScale){
                        device.videoZoomFactor = maxAvailableZoomScale
                    }
                    else {
                        device.videoZoomFactor = initialScale * (pinch.scale)
                    }
                }
                pinch.scale = 1.0
            } catch {
                return
            }
            device.unlockForConfiguration()
        }
        // 사진을 찍은 후, 그러니까 사진의 결과가 카메라 뷰에 올라왔을 때의 zoom 구현
        else if (self.userState == .afterTakePictures) {
            mainDispatchQueue.async {

                if (pinch.state == .began || pinch.state == .changed){
                    // 확대
                    if(self.recognizedPhotoScale < self.maxPhotoScale && pinch.scale > 1.0){
                        self.cameraView.transform = self.cameraView.transform.scaledBy(x: pinch.scale, y: pinch.scale)
                        self.recognizedPhotoScale *= pinch.scale
                    }
                    // 축소
                    else if (self.recognizedPhotoScale > self.minPhotoScale && pinch.scale < 1.0) {
                        self.cameraView.transform  = self.cameraView.transform.scaledBy(x: pinch.scale, y: pinch.scale)
                        self.recognizedPhotoScale *= pinch.scale
                    }
                }
                pinch.scale = 1.0
                print(self.recognizedPhotoScale)
            }
        }

    }
    
    
    // https://developer.apple.com/documentation/avfoundation/avcapturedevice/1385853-focuspointofinterest
    // 이 공식문서에 따르면 이 왼쪽 위가 (0, 0) 이고 오른쪽 아래가 (1, 1) 인 좌표계를 사용한다.
    @objc
    func tapFocus(_ sender: UITapGestureRecognizer) {
        guard let device = self.captureDevice else {
            return }

        if (sender.state == .ended) {
            let thisFocusPoint = sender.location(in: cameraView)
            focusAnimationAt(thisFocusPoint)
            
            print("========= tap location : \(thisFocusPoint) ========")
            
            let focus_x = thisFocusPoint.x / cameraView.frame.size.width
            let focus_y = thisFocusPoint.y / cameraView.frame.size.height
            
            print("========== focus_x, focus_y = \(focus_x) , \(focus_y) =========")
            
            if (device.isFocusModeSupported(.autoFocus) && device.isFocusPointOfInterestSupported) {
                do {
                    try device.lockForConfiguration()
                    device.focusMode = .autoFocus
                    device.focusPointOfInterest = CGPoint(x: focus_x, y: focus_y)
                    //device.focusMode = .autoFocus

                    if (device.isExposureModeSupported(.autoExpose) && device.isExposurePointOfInterestSupported) {
                        device.exposureMode = .autoExpose;
                        device.exposurePointOfInterest = CGPoint(x: focus_x, y: focus_y);
                     }

                    device.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func focusAnimationAt(_ point: CGPoint) {
        print("focus Animation 호출")
        let focusView = UIImageView(image: UIImage(named: "aim"))
        focusView.center = point
        cameraView.addSubview(focusView)

        focusView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
//            focusView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            focusView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }) { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
            }) { (success) in
                focusView.removeFromSuperview()
            }
        }
    }
    
    func call(phoneNumber: String, outputImage: UIImage) {
        if let url = NSURL(string: "tel:\(phoneNumber)"), UIApplication.shared.canOpenURL(url as URL) {
            // completion handler 가 전화가 종료된 다음 호출되는게 아니다. url 을 찾았을 때 호출됨.
            // didEnterBackground 활용
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
}
