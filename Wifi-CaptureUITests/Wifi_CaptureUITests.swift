import XCTest
import Wifi_Capture

class Wifi_CaptureUITests: XCTestCase {
    // Unit test 에서는 sut 이었지만, UI test 에서는 app 단위로 테스트.
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        // 테스트 중간에 실패하면 stop
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    
    // 복사 버튼과 공유 버튼은 함께 플로팅 Up, Down 되어야 함
    func test_dimView_show() {
        let elementsQuery = app.scrollViews.otherElements
        let existsCopyButton = elementsQuery.buttons["copyImage"]
            .exists
        let existsShareButton = elementsQuery.buttons["shareImage"]
            .exists
        
        XCTAssertEqual(existsCopyButton, existsShareButton)
    }
    
    
    override func tearDown() {
        super.tearDown()
        app = nil
        
    }
    
}
