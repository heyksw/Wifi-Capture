import XCTest
@testable import Wifi_Capture

class RecognizeViewControllerTests: XCTestCase {
    
    // system under test
    var sut: RecognizeViewController!

    override func setUp() {
        super.setUp()
        sut = RecognizeViewController()
    }

    
    // 플로팅 버튼이 올라오지 않은 상태에서 십자 버튼을 누른면 dimView show
    func test_tapCrossButton_when_buttons_are_not_floated() {
        // 1. given
        sut.areButtonsFloated = false
        // 2. when
        sut.tapCrossButton(sut.crossButton)
        // 3. then
        XCTAssertFalse(sut.dimView.isHidden)
    }
    
    
    // 플로팅 버튼이 올라간 상태에서 십자 버튼을 누르면 dimView hide
    func test_tapCrossButton_when_buttons_are_floated() {
        // 1. given
        sut.areButtonsFloated = true
        // 2. when
        sut.tapCrossButton(sut.crossButton)
        // 3. then
        XCTAssertTrue(sut.dimView.isHidden)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

}
