// 앱 첫 실행시 보여주는 튜토리얼 온보딩 화면

import UIKit
import Foundation

class OnboardingViewController: UIViewController {
    lazy var vc1illust = UIImageView(image: UIImage(named: "vc1illust"))
    lazy var vc2illust = UIImageView(image: UIImage(named: "vc2illust"))
    lazy var vc3illust = UIImageView(image: UIImage(named: "vc3illust"))
    lazy var vc4illust = UIImageView(image: UIImage(named: "vc4illust"))
    lazy var vc5illust = UIImageView(image: UIImage(named: "vc5illust"))
    
    lazy var vc1indicator = UIImageView(image: UIImage(named: "vc1indicator"))
    lazy var vc2indicator = UIImageView(image: UIImage(named: "vc2indicator"))
    lazy var vc3indicator = UIImageView(image: UIImage(named: "vc3indicator"))
    lazy var vc4indicator = UIImageView(image: UIImage(named: "vc4indicator"))
    lazy var vc5indicator = UIImageView(image: UIImage(named: "vc5indicator"))
    
    // 페이지를 넘길 pageViewController
    lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return vc
    }()
    
    // 페이지 1
    lazy var vc1: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        return vc
    }()
    
    // 페이지 2
    lazy var vc2: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        return vc
    }()
    
    // 페이지 3
    lazy var vc3: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        return vc
    }()
    
    // 페이지 4
    lazy var vc4: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        return vc
    }()
    
    lazy var vc5: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        return vc
    }()
    
    let startButton: UIButton = {
        let button = UIButton()
        button.setTitle("  시작하기  ", for: .normal)
        button.backgroundColor = Constants.onBoardingBackgroundColor
        button.layer.cornerRadius = 10
        return button
    }()
    
    // 페이지 배열
    lazy var vcArray: [UIViewController] = {
        return [vc1, vc2, vc3, vc4, vc5]
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
        print("height")
        print(vc1illust.frame.height)
        print(vc2illust.frame.height)
        print(vc3illust.frame.height)
        print(vc4illust.frame.height)
        print(vc5illust.frame.height)
        
        if let firstVC = vcArray.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        setupDelegate()
        startButton.addTarget(self, action: #selector(tapStartButton(_:)), for: .touchDown)
    }
    
    
    // 시작 버튼을 누르면 rootViewController 변경
    @IBAction func tapStartButton(_ sender: UIButton) {
        UserDefaults.standard.set("No", forKey: "isUserFirstTime")
        let mainViewController = MainViewController()
        let navigationController = UINavigationController(rootViewController: mainViewController)
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        guard let delegate = sceneDelegate else {
            showUnknownErrorAlert()
            return
        }
        delegate.window?.rootViewController = navigationController
        //self.navigationController?.pushViewController(mainViewController, animated: true)
    }
}


extension OnboardingViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    // UI 세팅
    func setUI() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        view.backgroundColor = .white
        
        vc1.view.addSubview(vc1illust)
        vc1.view.addSubview(vc1indicator)
        vc2.view.addSubview(vc2illust)
        vc2.view.addSubview(vc2indicator)
        vc3.view.addSubview(vc3illust)
        vc3.view.addSubview(vc3indicator)
        vc4.view.addSubview(vc4illust)
        vc4.view.addSubview(vc4indicator)
        vc5.view.addSubview(vc5illust)
        vc5.view.addSubview(vc5indicator)
        
        vc5.view.addSubview(startButton)

        pageViewController.view.snp.makeConstraints{ make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        vc1illust.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
        vc2illust.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
        vc3illust.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
        vc4illust.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
        vc5illust.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
        
        vc1indicator.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
        vc2indicator.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            //make.top.equalTo(vc2illust.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-50)
        }
        vc3indicator.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
        vc4indicator.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
        vc5indicator.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
        
        startButton.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalTo(vc5illust.snp.bottom).offset(20)
        }
        pageViewController.didMove(toParent: self)
    }
    
    
    // delegate 세팅
    func setupDelegate() {
        pageViewController.delegate = self
        pageViewController.dataSource = self
    }
    
    
    // 이전 페이지
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = vcArray.firstIndex(of: viewController) else { return nil }
        let beforeIndex = index - 1
        if beforeIndex < 0 { return nil }
        return vcArray[beforeIndex]
    }
    
    
    // 다음 페이지
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = vcArray.firstIndex(of: viewController) else { return nil }
        let afterIndex = index + 1
        if afterIndex == vcArray.count { return nil }
        return vcArray[afterIndex]
    }
    
}

