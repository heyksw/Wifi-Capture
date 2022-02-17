import SnapKit
import Foundation
import UIKit
import AVFoundation
import Photos
import PhotosUI
// MLkit
import MLKitTextRecognitionKorean
import MLKitVision

// 전화 모드, 기본 모드
enum AppMode {
    case callingMode
    case normalMode
}



// MARK: - MainViewController
class MainViewController: UIViewController {
    var isCalledSetNavigationBar = false
    
    // about class instance
    let elementBoxDrawing = ElementBoxDrawing()
    let textRecognize = TextRecognizing()
    
    // about contents, userDefaults
    var currentAppMode: AppMode = .callingMode
    var currentBoxOnOff: Bool = false
    var imageToDeliver: UIImage?
    var phoneNumber: String? = nil
    
    // about image
    let cameraShootImage = UIImage(named: "cameraShootImage")
    let changeModeImage = UIImage(named: "changeModeImage")
    let galleryImage = UIImage(named: "galleryImage")
    let callingModeImage = UIImage(named: "callingModeImage")
    let normalModeImage = UIImage(named: "normalModeImage")
    let boxOnImage = UIImage(named: "boxOnImage")
    let boxOffImage = UIImage(named: "boxOffImage")
    lazy var callingModeImageView = UIImageView(image: callingModeImage)
    lazy var normalModeImageView = UIImageView(image: normalModeImage)

    // about avfoundation camera
    var captureDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var deviceInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    var setting: AVCapturePhotoSettings?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var videoOutput: AVCaptureVideoDataOutput?
    var orientation: AVCaptureVideoOrientation = .portrait
    let videoQueue = DispatchQueue(label: "Video Camera Queue")
    var recognizedPhotoScale: CGFloat = 1.0
    let maxPhotoScale: CGFloat = 3.0
    let minPhotoScale: CGFloat = 1.0
    
    // CIContext를 만드는건 코스트가 많이 들어서 처음에 선언하고 재사용 하는 것이 좋다.
    let ciContext = CIContext()
    var framePreviewSubLayer = CALayer()
    
    // about dispatch queue
    let mainDispatchQueue = DispatchQueue.main
    let globalDispatchQueue = DispatchQueue.global()
    
    // about phpicker photo gallery
    lazy var phPickerConfiguration = PHPickerConfiguration()
    lazy var picker = PHPickerViewController(configuration: phPickerConfiguration)
    
    // about UI
    // safetyArea > cameraSuperScrollView > cameraView, boxOnOffView
    // safetyArea > footerView > footerLeftView, footerMiddleView, footerRightView > buttons
    var didSetupConstraints = false
    
    lazy var safetyArea: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.blueBlackBackgroundColor
        return view
    }()

    let cameraSuperScrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .black
        return view
    }()

    let cameraView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .black
        return view
    }()

    let boxOnOffView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        return view
    }()

    lazy var boxOnOffButton: UIButton = {
       let button = UIButton()
        button.setImage(boxOffImage, for: .normal)
        button.alpha = 0.9
        return button
    }()

    lazy var footerView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.blueBlackBackgroundColor
        view.alignment = .fill
        view.distribution = .equalSpacing
        return view
    }()
    
    lazy var footerLeftView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.blueBlackBackgroundColor
        return view
    }()

    lazy var footerCenterView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.blueBlackBackgroundColor
        return view
    }()
    
    lazy var footerRightView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.blueBlackBackgroundColor
        return view
    }()

    lazy var galleryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(galleryImage, for: .normal)
        return button
    }()

    lazy var cameraShootButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(cameraShootImage, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = Constants.blueBlackBackgroundColor
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var changeModeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(changeModeImage, for: .normal)
        button.backgroundColor = Constants.blueBlackBackgroundColor
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .dark
        
        setUserDefaults()
        
        setNavigationBar()
        
        setUI()
        
        setPHPicker()

        getPhotoLibraryAuthorization()
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(_:)))
        let tapFocus = UITapGestureRecognizer(target: self, action: #selector(self.tapCameraFocusing(_:)))
        
        view.addGestureRecognizer(pinch)
        view.addGestureRecognizer(tapFocus)
        
        cameraShootButton.addTarget(self, action: #selector(tapCameraShootButton(_:)), for: .touchDown)
        galleryButton.addTarget(self, action: #selector(tapGalleryButton), for: .touchDown)
        changeModeButton.addTarget(self, action: #selector(tapChangeModeButton), for: .touchDown)
        boxOnOffButton.addTarget(self, action: #selector(tapBoxOnOffButton), for: .touchDown)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    
    // AVFoundation camera setting
    func setCamera() {
        guard let captureDevice = getDefaultCamera() else {
            showUnknownErrorAlert()
            return
        }
        self.captureDevice = captureDevice
        
        do {
            captureSession = AVCaptureSession()
            captureSession?.sessionPreset = .photo
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            photoOutput = AVCapturePhotoOutput()
            setting = AVCapturePhotoSettings()
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA)]
            videoOutput?.alwaysDiscardsLateVideoFrames = true
            
            // Sets the sample buffer delegate and the queue for invoking callbacks.
            videoOutput?.setSampleBufferDelegate(self, queue: videoQueue)
            guard let videoOutput = videoOutput else { return }
            guard let input = deviceInput, let output = photoOutput else { return }
            
            captureSession?.addOutput(videoOutput)
            captureSession?.addInput(input)
            captureSession?.addOutput(output)
            guard let session = captureSession else { return }
        
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            guard let previewLayer = previewLayer else { return }
            
            framePreviewSubLayer.frame = self.cameraView.frame
            previewLayer.addSublayer(framePreviewSubLayer)
            previewLayer.session = captureSession
            
            // startRunning 은 UI 쓰레드를 방해할 수 있기 때문에 다른 쓰레드에 담아줌
            globalDispatchQueue.async {
                session.startRunning()
            }
            
            mainDispatchQueue.async {
                previewLayer.frame = self.cameraView.frame
                self.cameraView.layer.addSublayer(previewLayer)
            }
            
        } catch { showUnknownErrorAlert() }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUserDefaults()
        self.setCamera()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        overrideUserInterfaceStyle = .dark
        mainDispatchQueue.async {
            self.elementBoxDrawing.removeFrames(layer: self.framePreviewSubLayer)
        }
        globalDispatchQueue.async {
            self.captureSession?.stopRunning()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // 유저 앱 기본 설정
    func setUserDefaults() {
        let defaults = UserDefaults.standard
        // 전화모드로 앱 시작
        if defaults.bool(forKey: "startWithCallingMode") {
            self.currentAppMode = .callingMode
        }
        else {
            self.currentAppMode = .normalMode
        }
        // 글자 감지 박스 ON 으로 앱 시작
        self.currentBoxOnOff = defaults.bool(forKey: "startWithBoxON")
        if currentBoxOnOff {
            self.boxOnOffButton.setImage(boxOnImage, for: .normal)
        }
        else {
            self.boxOnOffButton.setImage(boxOffImage, for: .normal)
        }
    }
}



// MARK: - UI setting
extension MainViewController {
    
    // 네비게이션 바 세팅
    func setNavigationBar() {
        isCalledSetNavigationBar = true
        self.navigationController?.navigationBar.barStyle = .black
        if currentAppMode == .callingMode {
            self.navigationController?.navigationBar.topItem?.titleView = callingModeImageView
        }
        else {
            self.navigationController?.navigationBar.topItem?.titleView = normalModeImageView
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = .white
        view.backgroundColor = Constants.blueBlackBackgroundColor
        
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(tapSettingButton))
        let informationButton = UIBarButtonItem(image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: #selector(tapInformationButton))
        
        navigationItem.rightBarButtonItem = settingButton
        navigationItem.leftBarButtonItem = informationButton
    }
    
    
    // UI 배치, StackView 배치
    func setUI() {
        safetyArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safetyArea)
        view.backgroundColor = Constants.blueBlackBackgroundColor
        
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
        
        safetyArea.addSubview(cameraSuperScrollView)
        safetyArea.addSubview(footerView)

        cameraSuperScrollView.addSubview(cameraView)
        cameraSuperScrollView.addSubview(boxOnOffView)
        
        boxOnOffView.addSubview(boxOnOffButton)

        footerView.addArrangedSubview(footerLeftView)
        footerView.addArrangedSubview(footerCenterView)
        footerView.addArrangedSubview(footerRightView)
        
        footerLeftView.addSubview(galleryButton)
        footerCenterView.addSubview(cameraShootButton)
        footerRightView.addSubview(changeModeButton)
        
        view.setNeedsUpdateConstraints()
    }
    
    // SnapKit AutoLayout Constraints
    override func updateViewConstraints() {
        if (!didSetupConstraints) {
            cameraSuperScrollView.snp.makeConstraints{ make in
                make.top.left.right.equalTo(safetyArea)
                make.height.equalTo(view.frame.width * 4/3)
            }
            
            cameraView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview()
                make.width.equalToSuperview()
                make.height.equalToSuperview()
            }
        
            boxOnOffView.snp.makeConstraints { make in
                make.bottom.left.right.equalTo(cameraSuperScrollView.frameLayoutGuide)
                make.height.equalTo(100)
            }
            
            boxOnOffButton.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-10)
            }
            
            footerView.snp.makeConstraints { (make) in
                make.bottom.left.right.equalTo(safetyArea)
                make.top.equalTo(self.cameraSuperScrollView.snp.bottom)
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
            
            changeModeButton.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }

            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
}



// MARK: - about Notification
extension MainViewController {
    // 앱이 백그라운드 상태로 들어가면 카메라 중단
    @objc func didEnterBackground() {
        globalDispatchQueue.async {
            self.captureSession?.stopRunning()
        }
    }
    // 다시 포어그라운드로 오면 카메라 실행
    @objc func willEnterForeground() {
        self.setCamera()
    }
}



// MARK: - AVCapturePhotoCaptureDelegate
extension MainViewController: AVCapturePhotoCaptureDelegate {
    // iPhone 버전 별로 Camera Type 이 다르기 때문에 버전 별로 최적의 device camera 찾기
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
    }
    
    // 사진을 찍고나서 호출되는 delegate 메서드
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            showUnknownErrorAlert()
            return
        }
        guard let imageData = photo.fileDataRepresentation() else {
            showUnknownErrorAlert()
            return
        }
        let outputImage = UIImage(data: imageData)
        guard let outputImage = outputImage else {
            showUnknownErrorAlert()
            return
        }
        self.imageToDeliver = outputImage
        
        // globalQueue 에서 Session stop
        globalDispatchQueue.async {
            self.captureSession?.stopRunning()
        }
        
        self.elementBoxDrawing.removeFrames(layer: self.framePreviewSubLayer)
        
        // mainQueue 쓰레드에서 UI 작업
        mainDispatchQueue.async {
            self.cameraView.layer.contents = outputImage
            // 보내줄 때 scale 1로 초기화
            self.recognizedPhotoScale = 1.0
        }
        
        // 유저 설정이 저장이면 사진 저장수행
        if UserDefaults.standard.bool(forKey: "doPhotoSave") {
            // 사진을 찍으면 저장
            // Asynchronously runs a block that requests changes to the photo library.
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: imageData, options: nil)
            }, completionHandler: nil)
        }
        
        // 전화 모드 일때
        if currentAppMode == .callingMode {
            // 전화번호를 인식했으면 전화를 건다.
            globalDispatchQueue.async {
                self.textRecognize.recognizeText(uiImage: outputImage) { [weak self] result in
                    guard let result = result else { return }
                    self?.phoneNumber = self?.textRecognize.getPhoneNumber(result)
                    
                    self?.mainDispatchQueue.async {
                        // 전화번호를 인식했으면
                        if let number = self?.phoneNumber {
                            self?.call(phoneNumber: number, outputImage: outputImage)
                            self?.pushToNextPageWithOutputImage()
                        }
                        // 전화번호를 인식 못했으면
                        else {
                            let alert = UIAlertController(title:"전화를 걸 수 없습니다", message: "인식한 전화번호가 없어요.", preferredStyle: .alert)
                            let okButton = UIAlertAction(title: "확인", style: .default) { (action) in
                                self?.dismiss(animated: true, completion: nil)
                                self?.pushToNextPageWithOutputImage()
                            }
                            alert.addAction(okButton)
                            self?.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        // 기본 모드 일때
        else { self.pushToNextPageWithOutputImage() }
        
    }
    
    
    // 촬영한 이미지를 가지고 다음 페이지로 넘기는 함수
    func pushToNextPageWithOutputImage() {
        guard let outputImage = self.imageToDeliver else {
            return
        }
        // 넘어가기
        let recognizeViewController = RecognizeViewController()
        recognizeViewController.receivedImage = outputImage
        self.navigationController?.pushViewController(recognizeViewController, animated: true)
    }

    
    // 사진 앨범 접근 권한 요청
    func getPhotoLibraryAuthorization() {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                self.mainDispatchQueue.async {
                    self.showAccessAuthorization()
                }
                return
            }
        }
    }

}



// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension MainViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait

        // 박스 On 일때
        if currentBoxOnOff {
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let ciImage: CIImage = CIImage(cvImageBuffer: imageBuffer)
            guard let cgImage: CGImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return }
            let uiImage: UIImage = UIImage(cgImage: cgImage)
            
            textRecognize.recognizeText(uiImage: uiImage) { [weak self] result in
                guard let result = result else { return }
                self?.mainDispatchQueue.async {
                    self?.elementBoxDrawing.removeFrames(layer: self?.framePreviewSubLayer)
                    self?.drawAllElement(result: result, imageSize: uiImage.size)
                }
            }
        }
        // box Off 일때
        else {
            self.mainDispatchQueue.async {
                self.elementBoxDrawing.removeFrames(layer: self.framePreviewSubLayer)
            }
        }
    }
    
    
    // 문자 인식 박스 그리기
    func drawAllElement(result: Text?, imageSize: CGSize) {
        guard let result = result else {
            showUnknownErrorAlert()
            return
        }
 
        for block in result.blocks {
            for line in block.lines {
                for element in line.elements {
                    let scaledElementBoxSize = elementBoxDrawing.scaleElementBoxSize(elementFrame: element.frame, imageSize: imageSize, viewFrame: cameraView.frame)
                    let colorType = Constants.colorTypeArray[UserDefaults.standard.integer(forKey: "camera_recognizeBox_colorType_index")]
                    elementBoxDrawing.drawElementBox(scaledElementBoxSize, framePreviewSubLayer, colorType)
                }
            }
        }
    }
}



// MARK: - about Tap Button @IBAction
extension MainViewController {
    @objc func tapSettingButton(_ sender: UIButton) {
        let mainSettingViewController = MainSettingViewController()
        self.navigationController?.pushViewController(mainSettingViewController, animated: true)
    }
    
    
    @objc func tapInformationButton(_ sender: UIButton) {
        let infoViewController = InfoViewController()
        self.navigationController?.pushViewController(infoViewController, animated: true)
    }
    

    @IBAction func tapCameraShootButton(_ sender: UIButton) {
        guard let setting = setting else { return }
        photoOutput?.capturePhoto(with: setting, delegate: self)
    }
    
    
    @IBAction func tapGalleryButton(_ sender: UIButton) {
        globalDispatchQueue.async {
            self.captureSession?.stopRunning()
        }
        
        self.picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true, completion: nil)
    }
    
    // 카메라 줌 인, 줌 아웃 구현
    // device.videoZoomFactor 에 접근하려면 configuration lock / unlock 과정이 필요함
    @objc func handlePinch(_ pinch: UIPinchGestureRecognizer) {
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
            showUnknownErrorAlert()
            return
            
        }
        device.unlockForConfiguration()
    }
    
    
    // 카메라 포커싱 메서드, 왼쪽 위가 (0, 0) 이고 오른쪽 아래가 (1, 1) 인 좌표계를 사용한다.
    @objc func tapCameraFocusing(_ sender: UITapGestureRecognizer) {
        guard let device = self.captureDevice else {
            showUnknownErrorAlert()
            return
        }

        if (sender.state == .ended) {
            let thisFocusPoint = sender.location(in: cameraView)
            focusAnimationAt(thisFocusPoint)

            let focus_x = thisFocusPoint.x / cameraView.frame.size.width
            let focus_y = thisFocusPoint.y / cameraView.frame.size.height
            
            if (device.isFocusModeSupported(.autoFocus) && device.isFocusPointOfInterestSupported) {
                do {
                    try device.lockForConfiguration()
                    device.focusMode = .autoFocus
                    device.focusPointOfInterest = CGPoint(x: focus_x, y: focus_y)

                    if (device.isExposureModeSupported(.autoExpose) && device.isExposurePointOfInterestSupported) {
                        device.exposureMode = .autoExpose;
                        device.exposurePointOfInterest = CGPoint(x: focus_x, y: focus_y);
                     }

                    device.unlockForConfiguration()
                } catch {
                    showUnknownErrorAlert()
                }
            }
        }
    }
    
    
    // 카메라 포커싱 애니메이션
    func focusAnimationAt(_ point: CGPoint) {
        let focusView = UIImageView(image: UIImage(named: "aim"))
        focusView.center = point
        cameraView.addSubview(focusView)
        
        focusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }) { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
            }) { (success) in
                focusView.removeFromSuperview()
            }
        }
    }
    
    
    @objc func tapBoxOnOffButton(_ sender: UIButton) {
        if currentBoxOnOff {
            currentBoxOnOff = false
            self.boxOnOffButton.setImage(boxOffImage, for: .normal)
            showBoxOffToast()
        }
        else {
            currentBoxOnOff = true
            self.boxOnOffButton.setImage(boxOnImage, for: .normal)
            showBoxOnToast()
        }
    }
    
    
    @objc func tapChangeModeButton(_ sender: UIButton) {
        if currentAppMode == .callingMode {
            currentAppMode = .normalMode
            mainDispatchQueue.async {
                self.navigationController?.navigationBar.topItem?.titleView = self.normalModeImageView
                self.showNormalModeToast()
            }
        }
        else {
            currentAppMode = .callingMode
            mainDispatchQueue.async {
                self.navigationController?.navigationBar.topItem?.titleView = self.callingModeImageView
                self.showCallingModeToast()
            }
        }
    }
}



// MARK: - PHPickerViewControllerDelegate
extension MainViewController: PHPickerViewControllerDelegate {
    func setPHPicker() {
        self.phPickerConfiguration.selectionLimit = 1
        self.phPickerConfiguration.filter = .images
        self.picker.delegate = self
    }
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProvider = results.first?.itemProvider
        // 이미지를 선택했을 때
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                self.mainDispatchQueue.async {
                    // 문자 인식 페이지로 넘어감
                    let recognizeViewController = RecognizeViewController()
                    recognizeViewController.receivedImage = image as? UIImage
                    picker.dismiss(animated: true, completion: nil)
                    self.navigationController?.pushViewController(recognizeViewController, animated: false)
                }
            }
            
        }
        // 이미지를 선택하지 않았거나, 오류가 났을 때
        else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}


extension MainViewController {
    // 전화 걸기 메서드
    func call(phoneNumber: String, outputImage: UIImage) {
        if let url = NSURL(string: "tel:\(phoneNumber)"), UIApplication.shared.canOpenURL(url as URL) {
            // completion handler 가 전화가 종료된 다음 호출되는게 아니다. url 을 찾았을 때 호출됨.
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
}


extension UINavigationController {
    open override var childForStatusBarHidden: UIViewController? {
        return visibleViewController
    }
    open override var childForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
}
