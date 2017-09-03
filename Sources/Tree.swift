public protocol BinarySearchTree: Collection {

    associatedtype Node: BinarySearchTreeNode

    var root: Node? { get }

    // FIXME: Looks like adding this subscript requirement and/or providing a
    // default implementation for makes it impossible to typecheck conformance
    // Collection's conformance in conforming types.
    // subscript(key: Node.Key) -> Node.Value? { get }

}

// MARK: Default implementation for the value-by-key lookup.

extension BinarySearchTree {

    // public subscript(key: Node.Key) -> Node.Value? {
    //     return self.findNode(withKey: key)?.value
    // }

    func findNode(withKey key: Node.Key) -> Node? {
        guard var node = self.root else {
            return nil
        }

        while true {
            if key == node.key {
                return node
            } else if key < node.key {
                if node.left == nil {
                    return nil
                } else {
                    node = node.left!
                }
            } else {
                if node.right == nil {
                    return nil
                } else {
                    node = node.right!
                }
            }
        }
    }

}

// MARK: Default implementation for the Sequence conformance.

extension BinarySearchTree {

    public func makeIterator() -> AnyIterator<(key: Node.Key, value: Node.Value)> {
        var stack = Array<Self.Node>()
        if self.root != nil {
            stack.append(self.root!)
        }

        // Look for the left most child of the tree, effectively representing
        // the smallest element of the tree.
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
            let result = (node.key, node.value)

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

// MARK: Default implementation for the Collection conformance.

extension BinarySearchTree {

    public var startIndex: BinarySearchTreeIndex<Node> {
        guard let root = self.root else {
            return BinarySearchTreeIndex()
        }

        var stack = [(node: root, shouldFollowRight: true)]
        while let child = stack.last!.node.left {
            stack.append((node: child, shouldFollowRight: true))
        }

        return BinarySearchTreeIndex(stack: stack)
    }

    public var endIndex: BinarySearchTreeIndex<Node> {
        return BinarySearchTreeIndex(stack: [])
    }

    public func index(after i: BinarySearchTreeIndex<Node>) -> BinarySearchTreeIndex<Node> {

        guard let last = i.stack.last else {
            return i
        }

        guard (last.shouldFollowRight) && (last.node.right != nil) else {
            // The right branch was already visited or doesn't exist, hence
            // we're finished with the current node.
            return BinarySearchTreeIndex(stack: Array(i.stack.dropLast()))
        }

        // We follow the right branch of the current node.
        var stack = i.stack
        stack[stack.count - 1].shouldFollowRight = false
        stack.append((node: last.node.right!, shouldFollowRight: true))
        while let child = last.node.left {
            stack.append((node: child, shouldFollowRight: true))
        }

        return BinarySearchTreeIndex(stack: stack)
    }

    public subscript(index: BinarySearchTreeIndex<Node>) -> (key: Node.Key, value: Node.Value) {
        return (index.stack.last!.node.key, index.stack.last!.node.value)
    }

}

// ---

public protocol BinarySearchTreeNode {

    associatedtype Key: Comparable
    associatedtype Value

    var left : Self? { get }
    var right: Self? { get }
    var key  : Key   { get }
    var value: Value { get }

}

extension BinarySearchTreeNode {

    var leftMost: Self {
        var node = self
        while node.left != nil {
            node = node.left!
        }
        return node
    }

    var rightMost: Self {
        var node = self
        while node.right != nil {
            node = node.right!
        }
        return node
    }

}

// ---

public struct BinarySearchTreeIndex<Node: BinarySearchTreeNode>: Comparable {

    // The idea of the Index's implementation is to reproduce the behaviour of
    // an LNR traversal. We use a stack to store the state of such traversal,
    // so that we can keep track of what branches were visited, and what nodes
    // are left to visit. The last element of a non-empty stack always
    // represents the "current node", while an empty stack represents the
    // "past-the-end" index.

    fileprivate let stack: [(node: Node, shouldFollowRight: Bool)]

    fileprivate init(stack: [(node: Node, shouldFollowRight: Bool)] = []) {
        self.stack = stack
    }

    public static func ==(lhs: BinarySearchTreeIndex, rhs: BinarySearchTreeIndex) -> Bool {
        return true
    }

    public static func <(lhs: BinarySearchTreeIndex, rhs: BinarySearchTreeIndex) -> Bool {
        return true
    }

}
