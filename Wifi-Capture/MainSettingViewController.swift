import UIKit
import Foundation
import GoogleMobileAds


// 메인에서 설정을 눌렀을 때의 페이지
class MainSettingViewController: UIViewController {
    
    var colorTypeArray_Index: Int = UserDefaults.standard.integer(forKey: "camera_recognizeBox_colorType_index")
    lazy var boxColorType: ColorType? = nil
    
    lazy var safetyArea: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.blueBlackBackgroundColor
        return view
    }()

    let mainSuperView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alignment = .fill
        view.distribution = .equalSpacing
        return view
    }()
    
    let descriptionView1: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.deepDarkGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    let descriptionLabel1: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = "* 전화모드 : 촬영 후, 바로 인식한 번호로 전화 연결합니다."
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let descriptionView2: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.deepDarkGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    let descriptionLabel2: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = "* 기본모드 : 촬영 후, 전화를 연결하지 않습니다."
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let view1: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.deepDarkGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    let label1: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "찍은 사진 저장"
        return label
    }()
    
    let switch1: UISwitch = {
        let swtch = UISwitch()
        swtch.addTarget(self, action: #selector(tapSwitch1), for: .valueChanged)
        return swtch
    }()
    
    let view2: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.deepDarkGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    let label2: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "전화모드로 앱 시작하기"
        return label
    }()
    
    let switch2: UISwitch = {
        let swtch = UISwitch()
        swtch.addTarget(self, action: #selector(tapSwitch2), for: .valueChanged)
        return swtch
    }()
    
    let view3: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.deepDarkGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    let label3: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "글자 감지 ON 으로 앱 시작하기"
        return label
    }()
    
    let switch3: UISwitch = {
        let swtch = UISwitch()
        swtch.addTarget(self, action: #selector(tapSwitch3), for: .valueChanged)
        return swtch
    }()
    
    let view4: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.deepDarkGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    let label4: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "감지 텍스트 박스 색상"
        return label
    }()
    
    let switch4: UISwitch = {
        let swtch = UISwitch()
        return swtch
    }()
    
    let colorTypeButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.layer.borderWidth = Constants.lineWidth
        return button
    }()
    
    let adSize = GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
    lazy var bannerView = GADBannerView(adSize: adSize)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setUserDefaults()
        colorTypeButton.addTarget(self, action: #selector(tapColorTypeButton(_:)), for: .touchDown)
        
        // 테스트 광고 단위 ID. 앱을 등록한뒤엔 변경을 해야 함. 구글 애드몹 홈페이지에서 '스토어 추가'
        bannerView.adUnitID = "ca-app-pub-5182976255138770/5334041980"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setUserDefaults() {
        switch1.isOn = UserDefaults.standard.bool(forKey: "doPhotoSave")
        switch2.isOn = UserDefaults.standard.bool(forKey: "startWithCallingMode")
        switch3.isOn = UserDefaults.standard.bool(forKey: "startWithBoxON")
        
        colorTypeArray_Index = UserDefaults.standard.integer(forKey: "camera_recognizeBox_colorType_index")
        colorTypeButton.layer.borderColor = Constants.colorTypeArray[colorTypeArray_Index].lineColor
        colorTypeButton.layer.backgroundColor = Constants.colorTypeArray[colorTypeArray_Index].fillColor
    }
 
    func setUI() {
        view.addSubview(safetyArea)
        self.navigationController?.navigationBar.backgroundColor = Constants.blueBlackBackgroundColor
        safetyArea.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            safetyArea.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
            safetyArea.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
            safetyArea.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
            safetyArea.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        }
        else {
            safetyArea.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
            safetyArea.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor).isActive = true
            safetyArea.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            safetyArea.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        
        safetyArea.addSubview(mainSuperView)
        
        mainSuperView.snp.makeConstraints{ make in
            make.top.bottom.left.right.equalToSuperview()
        }
                
        mainSuperView.addSubview(stackView)
        mainSuperView.addSubview(descriptionView1)
        mainSuperView.addSubview(descriptionView2)
        
        stackView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(50)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(212)    // 50 * 4 + 4 * 3
        }
        
        descriptionView1.snp.makeConstraints{ make in
            make.top.equalTo(stackView.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
        descriptionView1.addSubview(descriptionLabel1)
        
        descriptionLabel1.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        descriptionView2.snp.makeConstraints{ make in
            make.top.equalTo(descriptionView1.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
        descriptionView2.addSubview(descriptionLabel2)
        
        descriptionLabel2.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        stackView.addArrangedSubview(view1)
        stackView.addArrangedSubview(view2)
        stackView.addArrangedSubview(view3)
        stackView.addArrangedSubview(view4)
        
        view1.snp.makeConstraints{ make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        view2.snp.makeConstraints{ make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        view3.snp.makeConstraints{ make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        view4.snp.makeConstraints{ make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        view1.addSubview(label1)
        view1.addSubview(switch1)
        view2.addSubview(label2)
        view2.addSubview(switch2)
        view3.addSubview(label3)
        view3.addSubview(switch3)
        view4.addSubview(label4)
        view4.addSubview(colorTypeButton)
        
        label1.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        label2.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        label3.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        label4.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        switch1.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
        
        switch2.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
        
        switch3.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
        
        colorTypeButton.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(30)
            make.width.equalTo(50)
        }
        
    }
    
    @objc func tapSwitch1(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "doPhotoSave")
    }
    
    @objc func tapSwitch2(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "startWithCallingMode")
    }
    
    @objc func tapSwitch3(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "startWithBoxON")
    }
    
    @objc func tapColorTypeButton(_ sender: UIButton) {
        colorTypeArray_Index = (colorTypeArray_Index + 1) % 4
        self.colorTypeButton.layer.borderColor = Constants.colorTypeArray[colorTypeArray_Index].lineColor
        self.colorTypeButton.layer.backgroundColor = Constants.colorTypeArray[colorTypeArray_Index].fillColor
        UserDefaults.standard.set(colorTypeArray_Index, forKey: "camera_recognizeBox_colorType_index")
    }
}

extension MainSettingViewController: GADBannerViewDelegate {
    func addBannerViewToView(_ bannerView: GADBannerView, parentView: UIView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(bannerView)
        
        bannerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(4)
            make.centerX.equalToSuperview()
        }
    }
    
    // 광고가 수신되었을 때
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(self.bannerView, parentView: self.mainSuperView)
    }
}
