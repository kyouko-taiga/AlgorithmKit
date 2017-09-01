import XCTest
import AlgorithmKit


class AVLTreeTests: XCTestCase {

    func testSubscript() {
        var avl = AVLTree<Int, Int>()

        for i in Array(0 ..< 100) {
            XCTAssertNil(avl[i])
            avl[i] = i
            XCTAssertEqual(avl[i], i)
        }
    }
    
    static var allTests = [
        ("testSubscript", testSubscript),
    ]
    
}
