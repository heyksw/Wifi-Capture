import UIKit
import Foundation

class HelpInfoViewController: UIViewController {
    
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
        view.layer.cornerRadius = 10
        return view
    }()
    
    let view1: UIView = {
        let view = UIView()
        //view.backgroundColor = Constants.deepDarkGrayColor
        view.backgroundColor = Constants.deepDarkGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    let titleLabel1: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "1. \"글자를 제대로 인식하지 않아요.\""
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    lazy var contentLabel1: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        let text = """
        먼저, 사용에 불편함을 드려 죄송합니다.
        다음의 3가지 유의사항을 지켰는지 확인해주세요.
          1. 사진이 흔들리지 않을수록 정확하게 인식합니다.
          2. 글자를 크게 찍을수록 정확하게 인식합니다.
          3. 손글씨보다 프린팅된 글씨를 잘 인식합니다.
        그리고 찍콜은 한글과 영어를 인식합니다. 일본어, 중국어 등의 외국어는 인식하지 못합니다.
        """
        label.attributedText = getAttributedText(text: text)
        return label
    }()
    
    let view2: UIView = {
        let view = UIView()
        //view.backgroundColor = Constants.deepDarkGrayColor
        view.backgroundColor = Constants.deepDarkGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    let titleLabel2: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "2. \"전화번호를 제대로 인식하지 않아요\""
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    lazy var contentLabel2: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        let text = """
        위의 3가지 유의사항을 지켰음에도, 전화번호를 인식하지 않는다면 제가 짠 전화번호 탐색 알고리즘의 문제입니다. \
        찍은 사진에 숫자가 너무 많이 등장하는 경우에는 정확하게 전화번호만 뽑아내기 힘들 수 있습니다. 그리고, 사진에 \
        전화번호가 2개 이상일 경우에는 제일 첫번째로 인식한 전화번호로 전화를 겁니다. '안심콜'에 초점을 맞췄기 때문에 \
        그렇게 설계했는데, 필요한 경우엔 업데이트 하겠습니다.
        """
        label.attributedText = getAttributedText(text: text)
        return label
    }()
    
    let view3: UIView = {
        let view = UIView()
        //view.backgroundColor = Constants.deepDarkGrayColor
        view.layer.cornerRadius = 10
        view.backgroundColor = .yellow
        return view
    }()
    
    let titleLabel3: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "3. 카메라가 켜지지 않아요"
        return label
    }()
    
    let contentLabel3: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.text = """
        찍콜은 사진, 카메라의 앱 접근 권한을 허용했을 때 정상 실행할 수 있습니다. \n
        아이폰 기본 설정 -> 찍콜 -> 사진, 카메라 접근을 허용해주세요.
        """
        return label
    }()
    
    let view4: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.deepDarkGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    let titleLabel4: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "4. 그 외 피드백이나 문의사항은 개발자 메일로 연락바랍니다."
        return label
    }()
    
    let contentLabel4: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.text = """
        heyksw0208@gmail.com (김상우)
        """
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
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
            make.height.equalTo(600)    // 100 * 4 + 4 * 3
        }
        
        stackView.addArrangedSubview(view1)
        stackView.addArrangedSubview(view2)
        stackView.addArrangedSubview(view3)
        stackView.addArrangedSubview(view4)
        
        view1.addSubview(titleLabel1)
        view1.addSubview(contentLabel1)
        
        view2.addSubview(titleLabel2)
        view2.addSubview(contentLabel2)
        
        view3.addSubview(titleLabel3)
        view3.addSubview(contentLabel3)
        
        view4.addSubview(titleLabel4)
        view4.addSubview(contentLabel4)
        
        view1.snp.makeConstraints{ make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(240)
        }
        
        view2.snp.makeConstraints{ make in
            make.left.right.equalToSuperview()
            make.height.equalTo(220)
        }
        
        view3.snp.makeConstraints{ make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        view4.snp.makeConstraints{ make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        titleLabel1.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(14)
        }
        
        contentLabel1.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(titleLabel1.snp.bottom).offset(16)
        }
        
        titleLabel2.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(14)
        }
        
        contentLabel2.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(titleLabel2.snp.bottom).offset(16)
        }
        
        titleLabel3.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
        }
        
        contentLabel3.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(20)
        }
        
        titleLabel4.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
        }
        
        contentLabel4.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(20)
        }
    }
    
    
    // Text 행간 조절
    func getAttributedText(text: String) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        return attrString
    }
    
}

