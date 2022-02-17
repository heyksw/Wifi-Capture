import XCTest
@testable import Wifi_Capture
import AVFoundation

class LinkedListTests: XCTestCase {
    var sut: LinkedList!
    
    override func setUp() {
        super.setUp()
        sut = LinkedList()
    }
    
    
    // head 를 삭제했을 때 head가 잘 변경 되는지
    func test_remove() {
        // 1. given
        let ll = makeGivenLikedList()
        let afterHeadIdx = ll.head!.next!.elementBoxInfo.idx
        // 2. when
        ll.remove(elementBoxInfo: ll.head!.elementBoxInfo)
        // 3. then
        XCTAssertTrue(ll.head!.elementBoxInfo.idx == afterHeadIdx)
    }
    
    
    // 모든 원소를 삭제했을 때 head 가 nil이 되는지
    func test_removeAllNodes() {
        // 1. given
        let ll = makeGivenLikedList()
        // 2. when
        ll.removeAllNodes()
        // 3. then
        XCTAssertTrue(ll.head == nil)
        XCTAssertNil(sut.getTextWithLinkedList())
    }
    
    
    // 원소 삽입, 삭제가 여러번 일어난 뒤, string 이 제대로 출력되는지
    func test_getTextWithLinkedList() {
        // 1. given
        let ll = makeGivenLikedList()
        let box3 = ElementBoxInfo(idx: 3, layer: CALayer(), text: "3")
        let answer = "1 3"
        ll.append(elementBoxInfo: box3)
        ll.remove(elementBoxInfo: ll.head!.next!.elementBoxInfo)
        // 2. when
        let result = ll.getTextWithLinkedList()
        // 3. then
        XCTAssertEqual(result!, answer)
    }
    
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
}

extension LinkedListTests {
    func makeGivenLikedList() -> LinkedList{
        let ll = LinkedList()
        let box1 = ElementBoxInfo(idx: 1, layer: CALayer(), text: "1")
        let box2 = ElementBoxInfo(idx: 2, layer: CALayer(), text: "2")
        ll.append(elementBoxInfo: box1)
        ll.append(elementBoxInfo: box2)
        return ll
    }
}
