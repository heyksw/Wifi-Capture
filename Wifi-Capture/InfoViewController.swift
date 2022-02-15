import UIKit
import Foundation
import GoogleMobileAds


// 메인에서 info 를 눌렀을 때의 페이지
class InfoViewController: UIViewController {
    
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
        label.textColor = .lightGray
        label.text = "* 앱 버전"
        return label
    }()
    
    let label1_value: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = "1.0"
        return label
    }()
    
    let button2: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.deepDarkGrayColor
        button.layer.cornerRadius = 10
        return button
    }()
    
    let label2: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "개발자 정보"
        return label
    }()
    
    let button3: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.deepDarkGrayColor
        button.layer.cornerRadius = 10
        return button
    }()
    
    let label3: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "도움말"
        return label
    }()
    
    let adSize = GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
    lazy var bannerView = GADBannerView(adSize: adSize)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
        button2.addTarget(self, action: #selector(tapButton2(_:)), for: .touchDown)
        button3.addTarget(self, action: #selector(tapButton3(_:)), for: .touchDown)
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
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
            make.height.equalTo(158)    // 50 * 3 + 4 * 2
        }
        
        
        stackView.addArrangedSubview(view1)
        stackView.addArrangedSubview(button2)
        stackView.addArrangedSubview(button3)
        
        view1.snp.makeConstraints{ make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        button2.snp.makeConstraints{ make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        button3.snp.makeConstraints{ make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        
        view1.addSubview(label1)
        view1.addSubview(label1_value)
        
        label1.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        label1_value.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
        
        button2.addSubview(label2)
        label2.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        button3.addSubview(label3)
        label3.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
    }
    
    @IBAction func tapButton2(_ sender: UIButton) {
        let developerInfoViewController = DeveloperInfoViewController()
        self.navigationController?.pushViewController(developerInfoViewController, animated: true)
    }
    
    @IBAction func tapButton3(_ sender: UIButton) {
        let helpInfoViewController = HelpInfoViewController()
        self.navigationController?.pushViewController(helpInfoViewController, animated: true)
    }
    
}

extension InfoViewController: GADBannerViewDelegate {
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
