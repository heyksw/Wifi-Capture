import SnapKit
import Foundation
import UIKit

class MainViewController: UIViewController {
    var didSetupConstraints = false

    // safe area
    let safetyArea: UIView = {
           let v = UIView()
           v.backgroundColor = .black
           return v
    }()
       
    
    // 고양이 들어갈 뷰
    let cameraView: UIImageView = {
        let cview = UIImageView()
        cview.image = UIImage(named: "cute_cat")
        
        return cview
    }()
    
    // 하단 버튼들이 들어갈 footer 뷰
    let footerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    
    @IBOutlet weak var bottomFixedView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 상단 네비게이션 바 세팅
        setUpNavigationBar()
 
        // 전체 UI 세팅
        self.setUI()
        
    }
    
}

extension MainViewController {
    func setUpNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = .gray
        self.navigationItem.title = "Cat is cute"
        view.backgroundColor = .white
        
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
        }

        super.updateViewConstraints()

    }

}
