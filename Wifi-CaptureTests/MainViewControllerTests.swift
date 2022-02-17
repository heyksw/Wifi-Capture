import XCTest
@testable import Wifi_Capture

class MainViewControllerTests: XCTestCase {
    
    // system under test
    var sut: MainViewController!

    override func setUp() {
        super.setUp()
        sut = MainViewController()
    }

    
    // 앱 실행시 UserDefaults 값이 잘 저장 되는지 확인
    func test_UserDefaults() {
        sut.viewDidLoad()

        XCTAssertTrue(sut.currentAppMode == .callingMode || sut.currentAppMode == .normalMode)
        XCTAssertTrue(sut.currentBoxOnOff == true || sut.currentBoxOnOff == false)
    }
    
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

}
