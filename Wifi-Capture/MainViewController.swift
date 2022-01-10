import SnapKit
import Foundation
import UIKit
import AVFoundation

class MainViewController: UIViewController {
    var didSetupConstraints = false
    
    var captureDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCapturePhotoOutput?
    var setting: AVCapturePhotoSettings?
    var previewLayer: AVCaptureVideoPreviewLayer?
    let mainDispatchQueue = DispatchQueue.main
    let globalDispatchQueue = DispatchQueue.global()
    
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
        self.settingCamera()
        
        cameraShootButton.addTarget(self, action: #selector(tapCameraShootButton(_:)), for: .touchDown)
    }
    
    
    // AVFoundation camera setting
    func settingCamera() {
        print("setting Camera")
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("captureDivce error")
            return}
        
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

extension MainViewController: AVCapturePhotoCaptureDelegate {
    
    func setUpNavigationBar() {
        self.navigationItem.title = "Wifi-Capture"
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

    
    // photoCapture proecess 가 끝날 떄 호출되는 delegate 메서드
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("photoOutput")
        guard let imageData = photo.fileDataRepresentation() else {
            print("imageData Error")
            return}
        let outputImage = UIImage(data: imageData)
        
        
        globalDispatchQueue.async {
            guard let session = self.captureSession else {
                print("session error at photoOut func")
                return
            }
            session.stopRunning()
        }
        
        mainDispatchQueue.async {
            //self.cameraView.layer.removeFromSuperlayer()
            print("cameraView to outputImage")
            self.cameraView.layer.contents = outputImage
        }
    }

    
    @IBAction func tapCameraShootButton(_ sender: UIButton) {
        print("tapCameraShootButton")
        guard let setting = setting else {return}
        output?.capturePhoto(with: setting, delegate: self)
        
    }

}
