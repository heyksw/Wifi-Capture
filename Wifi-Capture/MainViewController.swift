import SnapKit
import Foundation
import UIKit
import AVFoundation
import Photos

class MainViewController: UIViewController {
    
    enum UserStates {
        case beforeTakePictures
        case afterTakePictures
    }
    
    var userState: UserStates?
    var didSetupConstraints = false
    
    var captureDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCapturePhotoOutput?
    var setting: AVCapturePhotoSettings?
    var previewLayer: AVCaptureVideoPreviewLayer?
    let mainDispatchQueue = DispatchQueue.main
    let globalDispatchQueue = DispatchQueue.global()
    
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
        view.backgroundColor = .gray
        return view
    }()

    let footerCenterView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    let footerRightView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()

    // footer 에 들어갈 전면, 후면 반전 버튼
    let galleryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("갤러리", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    let cameraShootButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("촬영", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let turnButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("화면 전환", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 상단 네비게이션 바 세팅
        self.setUpNavigationBar()
 
        // UI 세팅
        self.setUI()
        
        // 카메라 불러오기
        self.setCamera()
        
        // 앨범에 접근할 권한 요청
        self.getPhotoLibraryAuthorization()
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(_:)))
        view.addGestureRecognizer(pinch)
        cameraShootButton.addTarget(self, action: #selector(tapCameraShootButton(_:)), for: .touchDown)
        galleryButton.addTarget(self, action: #selector(tapGalleryButton), for: .touchDown)
    }
    
    
    // AVFoundation camera setting
    func setCamera() {
        print("setting Camera")
        guard let captureDevice = getDefaultCamera() else {
            return
        }

//        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
//            print("captureDivce error")
//            return}
        
        do {
            captureSession = AVCaptureSession()
            captureSession?.sessionPreset = .photo
            input = try AVCaptureDeviceInput(device: captureDevice)
            output = AVCapturePhotoOutput()
            setting = AVCapturePhotoSettings()
            
            guard let input = input, let output = output else {return}
            
            captureSession?.addInput(input)
            captureSession?.addOutput(output)
            
            guard let session = captureSession else {return}
            
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            guard let previewLayer = previewLayer else {
                return
            }

            
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
    func setUpNavigationBar() {
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
        
        view.setNeedsUpdateConstraints()
    }
    
    
    // SnapKit 으로 Constraint 설정
    override func updateViewConstraints() {
        if (!didSetupConstraints) {
            cameraView.snp.makeConstraints { (make) in
                make.top.equalTo(safetyArea)
                make.top.left.right.equalTo(safetyArea)
                make.bottom.equalTo(self.footerView.snp.top)
            }

            footerView.snp.makeConstraints { (make) in
                make.height.equalTo(200)
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

        super.updateViewConstraints()

    }
    
    
    
    // 카메라 줌 인, 줌 아웃 구현
    // 사진 줌 인, 줌 아웃 구현
    // device.videoZoomFactor 에 접근하려면 lock / unlock 과정이 필요함
    // https://developer.apple.com/documentation/avfoundation/avcapturedevice
    // https://gist.github.com/yusuke024/3b5a89835deab5b9027efea794b80a45
    @objc
    func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        
        // 사진을 찍기 전, 그러니까 카메라가 실시간으로 보이고 있는 상황에서의 zoom 구현
        if (self.userState == .beforeTakePictures) {
            guard let device = getDefaultCamera() else {return}
            
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
    
    
    // iphone 버전 별로 Camera Type 이 다르기 때문에 버전 별로 최적의 device camera 찾기
    // https://developer.apple.com/documentation/avfoundation/avcapturedevice/2361508-default
    func getDefaultCamera() -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInDualCamera,for: AVMediaType.video,position: .back) {
            return device
        }
        else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video,position: .back) {
            return device
        }
        else { return nil }
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
    
    
    // photoCapture proecess 가 끝날 떄 호출되는 delegate 메서드
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
        
        // globalQueue 에서 Session stop
        globalDispatchQueue.async {
            guard let session = self.captureSession else {
                print("session error at photoOut func")
                return
            }
            session.stopRunning()
        }
        
        // mainQueue 쓰레드에서 UI 작업
        mainDispatchQueue.async {
            //self.cameraView.layer.removeFromSuperlayer()
            print("cameraView to outputImage")
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
        
    }

    // 촬영 버튼 클릭 이벤트
    @IBAction func tapCameraShootButton(_ sender: UIButton) {
        guard let setting = setting else {return}
        output?.capturePhoto(with: setting, delegate: self)
        
    }
    
    // 갤러리 버튼 클릭 이벤트 -> 앨범에 접근
    // https://developer.apple.com/documentation/uikit/uiimagepickercontroller
    @IBAction func tapGalleryButton(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) else {
            print("can't use photo library")
            return
        }
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    // 앨범에서 사진을 선택한 뒤 실행되는 delegate 메서드
    // https://developer.apple.com/documentation/uikit/uiimagepickercontrollerdelegate/1619126-imagepickercontroller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("image Picked")
            // 본격적 문자 인식
            
            
        }
    }
    
}
