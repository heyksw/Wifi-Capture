import Foundation
import UIKit

extension UIViewController {
    // 알 수 없는 에러 처리
    func showUnknownErrorAlert() {
        let alert = UIAlertController(title:"죄송합니다", message: "알 수 없는 에러가 발생했어요.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    // 인식한 전화번호가 없을 때
    func showThereIsNoPhoneNumberAlert() {
        let alert = UIAlertController(title:"전화를 걸 수 없습니다", message: "인식한 전화번호가 없어요.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "확인", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        let detailButton = UIAlertAction(title: "자세히", style: .default) { (action) in
            self.dismiss(animated: false, completion: nil)
            self.showDetailInstructions()
        }
        alert.addAction(okButton)
        alert.addAction(detailButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    // 자세한 설명
    func showDetailInstructions() {
        
    }
}
