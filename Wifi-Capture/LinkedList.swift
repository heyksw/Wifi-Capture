import Foundation

class Node {
    var elementBoxInfo: ElementBoxInfo
    var next: Node?
    
    init(elementBoxInfo: ElementBoxInfo, next: Node? = nil){
        self.elementBoxInfo = elementBoxInfo
        self.next = next
    }
}


class LinkedList {
    var head: Node?
    
    // tail 에 추가
    func append(elementBoxInfo: ElementBoxInfo) {
        if head == nil {
            head = Node(elementBoxInfo: elementBoxInfo)
            return
        }
        
        var tempNode = head
        while tempNode?.next != nil {
            tempNode = tempNode?.next
        }
        tempNode?.next = Node(elementBoxInfo: elementBoxInfo)
    }
    
    
    // 중간 노드 삭제
    func remove(elementBoxInfo: ElementBoxInfo) {
        if head == nil { return }
        
        // head 를 삭제할 경우
        if head?.elementBoxInfo.idx == elementBoxInfo.idx {
            head = head?.next
            return
        }
        
        var tempNode = head
        while tempNode?.next?.elementBoxInfo.idx != elementBoxInfo.idx {
            tempNode = tempNode?.next
        }
        
        tempNode?.next = tempNode?.next?.next
    }
    
    
    // topTextView 에 띄워줄 String 리턴 함수
    func getTextWithLinkedList() -> String? {
        if head == nil { return nil }
        
        var resultText: String = ""
        var tempNode = head
        while tempNode != nil {
            guard let tempText = tempNode?.elementBoxInfo.text else { return nil }
            resultText += tempText + " "
            tempNode = tempNode?.next
        }
        
        resultText.removeLast()
        return resultText
    }
    
}
