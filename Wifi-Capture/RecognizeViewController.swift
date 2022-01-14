// 문자인식을 담당하는 뷰 컨트롤러
import UIKit
import Foundation
import MLKitTextRecognition
import VisionKit
import MLKitVision
import SnapKit


class RecognizeViewController: UIViewController {
    let textRecognizer = TextRecognizer.textRecognizer()
    let safetyArea: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    var receivedImage: UIImage?
    let scrollView = UIScrollView()
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
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
    
    let textView: UITextView = {
        let view = UITextView()
        view.text = "[ 머신러닝 - 문자를 인식한 결과입니다. ] \n \n"
        view.backgroundColor = .black
        view.textColor = .white
        view.contentMode = .scaleAspectFit
        view.font = UIFont.systemFont(ofSize: 18)
        view.textAlignment = NSTextAlignment.center
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setUI()
        recognizeText(image: receivedImage)
    }
    
    
    
}

extension RecognizeViewController: UIScrollViewDelegate {
    
    func setNavigationBar() {
        self.navigationController?.navigationBar.tintColor = .white
        view.backgroundColor = .black
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
        
        safetyArea.addSubview(scrollView)
        safetyArea.addSubview(footerView)
        
        footerView.addArrangedSubview(textView)
        
        scrollView.addSubview(imageView)

        imageView.image = receivedImage
        
        scrollView.delegate = self 
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(safetyArea)
            make.top.left.right.equalTo(safetyArea)
            make.bottom.equalTo(self.footerView.snp.top)
        }

        footerView.snp.makeConstraints { (make) in
            make.height.equalTo(200)
            make.bottom.left.right.equalTo(safetyArea)
            make.top.equalTo(self.scrollView.snp.bottom)
        }
        
        textView.snp.makeConstraints { make in
            make.width.equalTo(self.view)
        }
        
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        super.updateViewConstraints()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func recognizeText(image: UIImage?){
        guard let image = image else {
            return
        }
        
        let vImage = VisionImage(image: image)
        vImage.orientation = image.imageOrientation
        
        textRecognizer.process(vImage) { result, error in
            guard error == nil, let result = result else {
                print("text recognizing error !")
                return
            }
            
            let resultText = result.text
            
            print("resultText = \(resultText)")
            for block in result.blocks {
                let blockText = block.text
                let blockFrame = block.frame
                let type = type(of: block)
                print("block type = \(type)")
                print("blockText = \(blockText)")
                let blockCorner = block.cornerPoints
                print("blockCornerPoints = \(block.cornerPoints)")
                print("blockFramge = \(blockFrame)")

                
                for line in block.lines {
                    let lineText = line.text
                    print("lineText = \(lineText)")
                    
                    for element in line.elements {
                        let elementText = element.text
                        print("elementText = \(element.text)")

                        
                    }
                }

            }
            
            self.textView.text += resultText
        }
        
        
    }
    
    
    
}
