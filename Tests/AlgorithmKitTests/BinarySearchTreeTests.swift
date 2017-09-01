import XCTest
import AlgorithmKit


class BinarySearchTreeTests: XCTestCase {

    func testInsert() {
        var bst = BinarySearchTree<Int>()

        for x in [5, 3, 4, 7, 6] {
            var ins = bst.insert(x)
            XCTAssertTrue (ins.inserted)
            XCTAssertEqual(ins.memberAfterInsert, x)

            ins = bst.insert(x)
            XCTAssertFalse(ins.inserted)
            XCTAssertEqual(ins.memberAfterInsert, x)
        }
    }

    func testUpdate() {
        var bst = BinarySearchTree<Int>()

        for x in [5, 3, 4, 7, 6] {
            XCTAssertNil  (bst.update(with: x))
            XCTAssertEqual(bst.update(with: x), x)
        }
    }

    func testRemove() {
        let seq = [24, 12, 36, 6, 18, 30, 42, 3, 9, 15, 21, 27, 33, 39, 45]

        var bst = BinarySearchTree(seq)
        for x in seq.reversed() {
            XCTAssertEqual(bst.remove(x), x)
            XCTAssertNil  (bst.remove(x))
        }

        bst = BinarySearchTree(seq)
        XCTAssertEqual(bst.remove(24), 24)
        XCTAssertNil  (bst.remove(24))

        bst = BinarySearchTree(seq)
        XCTAssertEqual(bst.remove(12), 12)
        XCTAssertNil  (bst.remove(12))

        bst = BinarySearchTree(seq)
        XCTAssertEqual(bst.remove(36), 36)
        XCTAssertNil  (bst.remove(36))
    }

    func testIsEmpty() {
        XCTAssertTrue (BinarySearchTree<Int>()  .isEmpty)
        XCTAssertFalse(BinarySearchTree(1, 2, 3).isEmpty)
    }

    func testCount() {
        XCTAssertEqual(BinarySearchTree<Int>()  .count, 0)
        XCTAssertEqual(BinarySearchTree(1)      .count, 1)
        XCTAssertEqual(BinarySearchTree(1, 2, 3).count, 3)
    }

    func testEqual() {
        XCTAssertEqual(BinarySearchTree<Int>()  , BinarySearchTree<Int>())
        XCTAssertEqual(BinarySearchTree(1)      , BinarySearchTree(1))
        XCTAssertEqual(BinarySearchTree(1, 2, 3), BinarySearchTree(1, 2, 3))
        XCTAssertEqual(BinarySearchTree(1, 2, 3), BinarySearchTree(2, 1, 3))
    }

    static var allTests = [
        ("testInsert", testInsert),
    ]

}
