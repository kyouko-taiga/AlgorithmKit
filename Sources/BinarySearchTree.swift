public struct BinarySearchTree<T: Comparable> {

    public init() {}

    public init<S: Sequence>(_ sequence: S) where S.Iterator.Element == T {
        for member in sequence {
            self.insert(member)
        }
    }

    public init(_ members: T...) {
        self.init(members)
    }

    public var isEmpty: Bool {
        return self.root == nil
    }

    public var count: Int {
        guard self.root != nil else {
            return 0
        }

        var result = 0
        var stack  = [self.root!]

        while let node = stack.popLast() {
            result += 1
            if let left = node.left {
                stack.append(left)
            }
            if let right = node.right {
                stack.append(right)
            }
        }

        return result
    }

    /// Inserts the given element in the tree if it is not already present.
    @discardableResult
    public mutating func insert(_ newMember: T) -> (inserted: Bool, memberAfterInsert: T) {
        let ins = self.update(with: newMember)
        return ins == nil
            ? (inserted: true , memberAfterInsert: newMember)
            : (inserted: false, memberAfterInsert: ins!)
    }

    /// Inserts the given element into the set unconditionally.
    @discardableResult
    public mutating func update(with newMember: T) -> T? {
        guard var node = self.root else {
            self.root = BinarySearchTreeNode(newMember)
            return nil
        }

        while true {
            if newMember == node.value {
                node.value = newMember
                return newMember
            }

            if newMember < node.value {
                if node.left != nil {
                    node = node.left!
                } else {
                    node.left = BinarySearchTreeNode(newMember)
                    return nil
                }
            } else {
                if node.right != nil {
                    node = node.right!
                } else {
                    node.right = BinarySearchTreeNode(newMember)
                    return nil
                }
            }
        }
    }

    /// Removes the given element and any elements subsumed by the given element.
    @discardableResult
    public mutating func remove(_ member: T) -> T? {
        guard var node = self.root else {
            return nil
        }

        // The root is a special case.
        if self.root!.value == member {
            if let right = self.root!.right {
                right.leftMost = self.root!.left
                self.root = right
            } else {
                self.root = self.root!.left
            }
            return member
        }

        while true {
            if member < node.value {
                if let left = node.left {
                    if member == left.value {
                        if let leftRight = left.right {
                            node.left = leftRight
                            node.leftMost = left.left
                        } else {
                            node.left = left.left
                        }
                        return member
                    } else {
                        node = left
                    }
                } else {
                    return nil
                }
            } else {
                if let right = node.right {
                    if member == right.value {
                        if let rightLeft = right.left {
                            node.right = rightLeft
                            node.rightMost = right.right
                        } else {
                            node.right = right.right
                        }
                        return member
                    } else {
                        node = right
                    }
                } else {
                    return nil
                }
            }
        }
    }

    fileprivate var root: BinarySearchTreeNode<T>? = nil

}

extension BinarySearchTree: Equatable {

    public static func ==(lhs: BinarySearchTree<T>, rhs: BinarySearchTree<T>) -> Bool {
        let leftIterator  = lhs.makeIterator()
        let rightIterator = rhs.makeIterator()

        while let leftValue = leftIterator.next() {
            if leftValue != rightIterator.next() {
                return false
            }
        }

        return rightIterator.next() == nil
    }
    
}

//extension BinarySearchTree: SetAlgebra {
//
//    /// Returns a new tree with the elements of both this and the given tree.
//    public func union(_ other: BinarySearchTree<T>) -> BinarySearchTree<T> {
//        var result = self
//        for member in other {
//            result.insert(member)
//        }
//        return result
//    }
//
//    /// Adds the elements of the given tree to the tree.
//    public mutating func formUnion(_ other: BinarySearchTree<T>) {
//        for member in other {
//            self.insert(member)
//        }
//    }
//
//    /// Returns a new tree with the elements that are common to both this set
//    /// and the given tree.
//    public func intersection(_ other: BinarySearchTree<T>) -> BinarySearchTree<T> {
//        var result = BinarySearchTree<T>()
//
//        let leftIterator  = self.makeIterator()
//        var leftValue     = leftIterator.next()
//        let rightIterator = other.makeIterator()
//        var rightValue    = rightIterator.next()
//
//        while (leftValue != nil) && (rightValue != nil) {
//            if leftValue == rightValue {
//                result.insert(leftValue!)
//                leftValue = leftIterator.next()
//                rightValue = rightIterator.next()
//            } else if leftValue! < rightValue! {
//                leftValue = leftIterator.next()
//            } else {
//                rightValue = rightIterator.next()
//            }
//        }
//
//        return result
//    }
//
//    /// Removes the elements of this tree that aren't also in the given tree.
//    public mutating func formIntersection(_ other: BinarySearchTree<T>) {
//        self.root = self.intersection(other).root
//    }
//
//}

extension BinarySearchTree: Sequence {

    public func makeIterator() -> AnyIterator<T> {
        guard self.root != nil else {
            return AnyIterator { nil }
        }

        // Look for the left most child of the tree, effectively representing
        // the smallest element of the tree.
        var stack = [self.root!]
        while let child = stack.last!.left {
            stack.append(child)
        }

        return AnyIterator {
            // Finish iterating as soon as the stack is empty.
            guard !stack.isEmpty else {
                return nil
            }

            // The last node of the stack represent the current position of
            // the iterator.
            let node   = stack.popLast()!
            let result = node.value

            // Look for the left most child of the right child of the current
            // node, effectively representing the next element.
            if node.right != nil {
                stack.append(node.right!)
                while let child = stack.last!.left {
                    stack.append(child)
                }
            }

            return result
        }
    }

}

// ---------------------------------------------------------------------------

fileprivate class BinarySearchTreeNode<T: Comparable> {

    init(
        _ value: T,
        left   : BinarySearchTreeNode<T>? = nil,
        right  : BinarySearchTreeNode<T>? = nil)
    {
        self.value = value
        self.left  = left
        self.right = right
    }

    var value: T

    var left    : BinarySearchTreeNode<T>?
    var right   : BinarySearchTreeNode<T>?

    var leftMost: BinarySearchTreeNode<T>? {
        get {
            var node = self
            while node.left != nil {
                node = node.left!
            }
            return node
        }

        set {
            var node = self
            while node.left != nil {
                node = node.left!
            }
            node.left = newValue
        }
    }

    var rightMost: BinarySearchTreeNode<T>? {
        get {
            var node = self
            while node.right != nil {
                node = node.right!
            }
            return node
        }

        set {
            var node = self
            while node.right != nil {
                node = node.right!
            }
            node.right = newValue
        }
    }

}
