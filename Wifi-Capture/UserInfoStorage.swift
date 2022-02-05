// 유저 정보를 저장할 storage
import Foundation

class UserInfoStorage {
    // 유저가 앱을 처음 실행했는지
    static func isUserFirstTime() -> Bool {
        if UserDefaults.standard.object(forKey: "isUserFirstTime") == nil {
            // 시작하기 버튼을 누르면 No 로 바뀌도록
            UserDefaults.standard.set("No", forKey: "isUserFirstTime")
            return true
        }
        else {
            return false
            
        }
    }
}
