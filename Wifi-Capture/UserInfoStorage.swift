// 유저 정보를 저장할 storage
import Foundation

class UserInfoStorage {
    
    // 유저가 앱을 처음 실행했는지
    static func isUserFirstTime() -> Bool {
        if UserDefaults.standard.object(forKey: "isUserFirstTime") == nil {
            // 튜토리얼 끝나고, 앱 시작하기 버튼을 누르면 No 로 바뀌도록
            //UserDefaults.standard.set("No", forKey: "isUserFirstTime")
            UserDefaults.standard.set(true, forKey: "doPhotoSave")
            UserDefaults.standard.set(true, forKey: "startWithCallingMode")
            UserDefaults.standard.set(false, forKey: "startWithBoxON")
            UserDefaults.standard.set(0, forKey: "camera_recognizeBox_colorType_index")
            UserDefaults.standard.set(3, forKey: "selectBox_colorType_index")
            UserDefaults.standard.set(0, forKey: "unselectBox_colorType_index")
            
            return true
        }
        else {
            return false
        }
    }

}
