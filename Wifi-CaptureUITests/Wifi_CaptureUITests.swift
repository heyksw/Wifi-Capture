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
    
    
    // UserDefaults 설정에 맞춰서 초기 box On Off 버튼 세팅 설정
    func test_boxOnOff() {
        let defaults = UserDefaults.standard

        // "BoxOn 으로 앱 시작"으로 설정 돼있으면
        if defaults.bool(forKey: "startWithBoxON") {
            let elementsQuery = app.scrollViews.otherElements
            // 1. given
            let boxOnImageButton = elementsQuery.buttons["boxOnImage"]
            boxOnImageButton.tap()

            // 2. when
            let existBoxOffImageButton = elementsQuery.buttons["boxOffImage"]
                .exists

            // 3. then
            XCTAssertTrue(existBoxOffImageButton)
        }
        // "BoxOff 로 앱 시작"으로 설정 돼있으면
        else {
            let elementsQuery = app.scrollViews.otherElements
            // 1. given
            let boxOffImageButton = elementsQuery.buttons["boxOffImage"]
            boxOffImageButton.tap()

            // 2. when
            let existBoxOnImageButton = elementsQuery.buttons["boxOnImage"]
                .exists

            // 3. then
            XCTAssertTrue(existBoxOnImageButton)
        }

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
    
    
//    func test_test() {
//
//        let app = app2
//        app.buttons["galleryImage"].tap()
//
//        let app2 = app
//        app2/*@START_MENU_TOKEN@*/.scrollViews/*[[".otherElements[\"사진\"].scrollViews",".scrollViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.otherElements.otherElements["사진, 2월 18일, 오전 12:34, 스크린샷, 2월 17일, 오후 6:32, 사진, 2월 16일, 오후 3:32, 사진, 2월 16일, 오전 12:17, 사진, 2월 15일, 오후 11:48, 스크린샷, 2월 15일, 오후 11:36, 사진, 2월 15일, 오후 11:35, 사진, 2월 15일, 오후 4:04, 스크린샷, 2월 14일, 오후 8:07, 스크린샷, 2월 14일, 오후 8:07, 사진, 2월 14일, 오후 3:05, 사진, 2월 14일, 오후 2:34, 사진, 2월 14일, 오후 2:33, 사진, 2월 14일, 오후 2:33, 사진, 2월 14일, 오후 2:32, 사진, 2월 14일, 오후 2:31, 사진, 2월 13일, 오전 11:14, 사진, 2월 13일, 오전 11:13"].children(matching: .image).matching(identifier: "사진, 2월 14일, 오후 2:33").element(boundBy: 0).tap()
//        app2/*@START_MENU_TOKEN@*/.scrollViews.otherElements.images["사진, 2월 15일, 오후 11:35"]/*[[".otherElements[\"사진\"].scrollViews.otherElements",".otherElements[\"사진, 2월 18일, 오전 12:34, 스크린샷, 2월 17일, 오후 6:32, 사진, 2월 16일, 오후 3:32, 사진, 2월 16일, 오전 12:17, 사진, 2월 15일, 오후 11:48, 스크린샷, 2월 15일, 오후 11:36, 사진, 2월 15일, 오후 11:35, 사진, 2월 15일, 오후 4:04, 스크린샷, 2월 14일, 오후 8:07, 스크린샷, 2월 14일, 오후 8:07, 사진, 2월 14일, 오후 3:05, 사진, 2월 14일, 오후 2:34, 사진, 2월 14일, 오후 2:33, 사진, 2월 14일, 오후 2:33, 사진, 2월 14일, 오후 2:32, 사진, 2월 14일, 오후 2:31, 사진, 2월 13일, 오전 11:14, 사진, 2월 13일, 오전 11:13\"].images[\"사진, 2월 15일, 오후 11:35\"]",".images[\"사진, 2월 15일, 오후 11:35\"]",".scrollViews.otherElements"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
//
//        let crossimageButton = app.buttons["crossImage"]
//        crossimageButton.tap()
//        crossimageButton.tap()
//        crossimageButton.tap()
//
//        let elementsQuery = app.scrollViews.otherElements
//        let selectallimageButton = elementsQuery.buttons["selectAllImage"]
//        selectallimageButton.tap()
//        selectallimageButton.tap()
//
//        let copyimageButton = elementsQuery.buttons["copyImage"]
//        copyimageButton.tap()
//        copyimageButton.tap()
//
//        let shareimageButton = elementsQuery.buttons["shareImage"]
//        shareimageButton.tap()
//        shareimageButton.tap()
//        crossimageButton.tap()
//        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element/*@START_MENU_TOKEN@*/.swipeLeft()/*[[".swipeUp()",".swipeLeft()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        app2/*@START_MENU_TOKEN@*/.icons["ZZik_Call"]/*[[".otherElements[\"Home screen icons\"]",".icons.icons[\"ZZik_Call\"]",".icons[\"ZZik_Call\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
//
//    }
}
