import UIKit
import Foundation

class DeveloperInfoViewController: UIViewController {
    
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
        view.backgroundColor = Constants.deepDarkGrayColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    let label1: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "김상우  Kim Sang Woo"
        return label
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
        label.text = "heyksw0208@gmail.com"
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
            make.height.equalTo(104)    // 50 * 2 + 4 * 1
        }
        
        stackView.addArrangedSubview(view1)
        stackView.addArrangedSubview(view2)
        
        view1.addSubview(label1)
        view2.addSubview(label2)
        
        view1.snp.makeConstraints{ make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        view2.snp.makeConstraints{ make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        label1.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        label2.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
    }
    
}

