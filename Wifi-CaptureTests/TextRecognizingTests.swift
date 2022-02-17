import XCTest
@testable import Wifi_Capture

class TextRecognizingTests: XCTestCase {
    
    // system under test
    var sut: TextRecognizing!

    override func setUp() {
        super.setUp()
        sut = TextRecognizing()
    }

    // AI 가 '0', 'o', 'O' 등을 헷갈려 하기 때문에, 이를 고려한 파싱이 잘 일어나는지에 대한 테스트.
    func test_refineElemNumber() {
        // 1. given
        let elems: [String] = ["o0O-ㅇOㅇ-0O0o", "01o-1234-5678", "ㅇ8ㅇ-000-oooo", "01O.1111.2O20"]
        let answers: [String] = ["0000000000", "01012345678", "0800000000", "01011112020"]
        // 2. when
        for i in 0..<elems.count {
            let refinedElem = sut.refineElemNumber(elems[i])
            // 3. Then
            XCTAssertEqual(refinedElem, answers[i])
        }
    }
    
    
    // '.', '-' 이 전화번호를 파싱할때 잘 무시되는지에 대한 테스트
    func test_isConsideredAsNumber() {
        // 1. given
        let symbols: [Character] = ["o", "O", "ㅇ", "-", "."]
        // 2. when
        for symbol in symbols {
            let result = sut.isConsideredAsNumber(symbol)
            // 3. then
            XCTAssertTrue(result)
        }
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

}
