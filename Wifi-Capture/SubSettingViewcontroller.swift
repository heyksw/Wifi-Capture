import UIKit
import Foundation
import GoogleMobileAds


// RecognizeViewController 에서 설정을 눌렀을 때의 페이지
class SubSettingViewController: UIViewController {
    var selectbox_colorType_index: Int = UserDefaults.standard.integer(forKey: "selectBox_colorType_index")
    var unselectbox_colorType_index: Int = UserDefaults.standard.integer(forKey: "unselectBox_colorType_index")
    
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
    
    
    let view1: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.deepDarkGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    let label1: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "선택된 텍스트 박스 색상"
        return label
    }()
    
    let colorTypeButton1: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.layer.borderWidth = Constants.lineWidth
        return button
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
        label.text = "선택되지 않은 텍스트 박스 색상"
        return label
    }()
    
    let colorTypeButton2: UIButton = {
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
        colorTypeButton1.addTarget(self, action: #selector(tapColorTypeButton1(_:)), for: .touchDown)
        colorTypeButton2.addTarget(self, action: #selector(tapColorTypeButton2(_:)), for: .touchDown)
        
        bannerView.adUnitID = "ca-app-pub-5182976255138770/5334041980"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    
    func setUserDefaults() {
        selectbox_colorType_index = UserDefaults.standard.integer(forKey: "selectBox_colorType_index")
        unselectbox_colorType_index = UserDefaults.standard.integer(forKey: "unselectBox_colorType_index")
        
        colorTypeButton1.layer.borderColor = Constants.colorTypeArray[selectbox_colorType_index].lineColor
        colorTypeButton1.layer.backgroundColor = Constants.colorTypeArray[selectbox_colorType_index].fillColor
        
        colorTypeButton2.layer.borderColor = Constants.colorTypeArray[unselectbox_colorType_index].lineColor
        colorTypeButton2.layer.backgroundColor = Constants.colorTypeArray[unselectbox_colorType_index].fillColor
        
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
        
        stackView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(50)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(104)    // 50 * 2 + 4 * 1
        }
        
        stackView.addArrangedSubview(view1)
        stackView.addArrangedSubview(view2)
        
        view1.snp.makeConstraints{ make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        view2.snp.makeConstraints{ make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        view1.addSubview(label1)
        view1.addSubview(colorTypeButton1)
        view2.addSubview(label2)
        view2.addSubview(colorTypeButton2)
        
        label1.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        label2.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        colorTypeButton1.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(30)
            make.width.equalTo(50)
        }
        
        colorTypeButton2.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(30)
            make.width.equalTo(50)
        }
        
    }
    
    @objc func tapColorTypeButton1(_ sender: UIButton) {
        selectbox_colorType_index = (selectbox_colorType_index + 1) % 4
        self.colorTypeButton1.layer.borderColor = Constants.colorTypeArray[selectbox_colorType_index].lineColor
        self.colorTypeButton1.layer.backgroundColor = Constants.colorTypeArray[selectbox_colorType_index].fillColor
        UserDefaults.standard.set(selectbox_colorType_index, forKey: "selectBox_colorType_index")
    }
    
    @objc func tapColorTypeButton2(_ sender: UIButton) {
        unselectbox_colorType_index = (unselectbox_colorType_index + 1) % 4
        self.colorTypeButton2.layer.borderColor = Constants.colorTypeArray[unselectbox_colorType_index].lineColor
        self.colorTypeButton2.layer.backgroundColor = Constants.colorTypeArray[unselectbox_colorType_index].fillColor
        UserDefaults.standard.set(unselectbox_colorType_index, forKey: "unselectBox_colorType_index")
    }
}

extension SubSettingViewController: GADBannerViewDelegate {
    func addBannerViewToView(_ bannerView: GADBannerView, parentView: UIView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(bannerView)
        
        bannerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(4)
            make.centerX.equalToSuperview()
            //make.width.equalToSuperview()
        }
    }
    
    // 광고가 수신되었을 때
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceivedAd")
        addBannerViewToView(self.bannerView, parentView: self.mainSuperView)
    }
}
