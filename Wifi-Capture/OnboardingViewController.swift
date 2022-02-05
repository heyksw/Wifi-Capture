// 앱 첫 실행시 보여주는 튜토리얼 온보딩 화면

import UIKit
import Foundation

class OnboardingViewController: UIViewController {
    // 상단 네비뷰
    lazy var navigationView: UIView = {
           let view = UIView()
           view.backgroundColor = .black

           return view
       }()
    
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
        vc.view.backgroundColor = .lightGray
        return vc
    }()
    
    // 페이지 3
    lazy var vc3: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .darkGray
        return vc
    }()
    
    // 페이지 4
    lazy var vc4: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .black
        return vc
    }()
    
    let startButton: UIButton = {
        let button = UIButton()
        button.setTitle("시작 하기", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 10
        return button
    }()
    
    // 페이지 배열
    lazy var vcArray: [UIViewController] = {
        return [vc1, vc2, vc3, vc4]
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
        if let firstVC = vcArray.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        setupDelegate()
        startButton.addTarget(self, action: #selector(tapStartButton(_:)), for: .touchDown)
    }
    
    @IBAction func tapStartButton(_ sender: UIButton) {
        let mainViewController = MainViewController()
        present(mainViewController, animated: false, completion: nil)
    }
}


extension OnboardingViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    // UI 세팅
    func setUI() {
        view.addSubview(navigationView)
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        vc4.view.addSubview(startButton)
        
        navigationView.snp.makeConstraints { make in
                    make.width.top.equalToSuperview()
                    make.height.equalTo(100)
                }
        pageViewController.view.snp.makeConstraints{ make in
            make.top.equalTo(navigationView.snp.bottom)
            make.bottom.left.right.equalToSuperview()
        }
        startButton.snp.makeConstraints{ make in
            make.center.equalToSuperview()
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

