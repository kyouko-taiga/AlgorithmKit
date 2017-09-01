
public protocol Tree {

    associatedtype Node: TreeNode

    var root: Node? { get }

    var isEmpty: Bool { get }
    var count  : Int  { get }
    var height : Int  { get }

}

extension Tree {

    public var isEmpty: Bool {
        return self.root == nil
    }

    public var count: Int {
        guard self.root != nil else {
            return 0
        }

        var stack  = [self.root!]
        var result = 0
        while let node = stack.popLast() {
            result += 1
            stack.append(contentsOf: node.children)
        }

        return result
    }

    public var height: Int {
        guard self.root != nil else {
            return 0
        }

        var stack  = [(node: self.root!, height: 1)]
        var result = 0
        while let (node, height) = stack.popLast() {
            result = Swift.max(result, height)
            stack.append(contentsOf: node.children.map { ($0, height + 1) })
        }

        return result
    }

}

// ---

public protocol TreeNode {

    var children: [Self] { get }

}

// ---------------------------------------------------------------------------

public struct AVLTree<Key: Comparable, Value>: Tree {

    public private(set) var root: AVLTreeNode<Key, Value>? = nil

    /// Creates an empty search tree.
    public init() {}

    /// Creates a search tree from the key-value pairs in the given sequence.
    ///
    /// - parameters:
    ///     - keysAndValues: A sequence of key-value pairs to insert in the
    ///       search tree. Every key in `keysAndValues` must be unique.
    ///
    /// - Note: key-value pairs are inserted sequentially, meaning that only
    ///   that last value associated with duplicated keys will be stored. If
    ///   your sequence might have duplicate keys, prefer the
    ///   `AVLTree(_:uniquingKeysWith)` initializer.
    public init<S: Sequence>(uniqueKeysWithValues keysAndValues: S)
        where S.Iterator.Element == (Key, Value)
    {
        for (key, value) in keysAndValues {
            self[key] = value
        }
    }

    /// Creates a search tree from the key-value pairs in the given sequence,
    /// using a combining closure to determine the value for any duplicate
    /// keys.
    ///
    /// - parameters:
    ///     - keysAndValues: A sequence of key-value pairs to insert in the
    ///       search tree.
    ///     - combine: A closre that is called with the values for any
    ///       duplicatekeys that are encountered. The close returns the
    ///       desired value for the final search tree.
    public init<S: Sequence>(
        _ keysAndValues         : S,
        uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows
        where S.Iterator.Element == (Key, Value)
    {
        for (key, value) in keysAndValues {
            if let oldValue = self[key] {
                self[key] = try combine(oldValue, value)
            } else {
                self[key] = value
            }
        }
    }

    public func contains(_ key: Key) -> Bool {
        return true
    }

    public subscript(key: Key) -> Value? {
        get {
            return self.findNode(withKey: key)?.value
        }

        set {
            guard let value = newValue else {
                self.removeValue(forKey: key)
                return
            }

            guard var node = self.root else {
                self.root = AVLTreeNode(key: key, value: value)
                return
            }

            while true {
                if key == node.key {
                    node.value = value
                    return
                } else if key < node.key {
                    if node.left == nil {
                        node.left = AVLTreeNode(key: key, value: value, parent: node)
                        break
                    } else {
                        node = node.left!
                    }
                } else {
                    if node.right == nil {
                        node.right = AVLTreeNode(key: key, value: value, parent: node)
                        break
                    } else {
                        node = node.right!
                    }
                }
            }

            self.rebalance(from: node)
        }
    }

    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        guard var node = self.findNode(withKey: key) else {
            return nil
        }

        let value = node.value

        // Check if we should remove the tree's root.
        guard let parent = node.parent else {
            self.root = nil
            return value
        }

        if (node.left == nil) || (node.right == nil) {
            // If either of the children is not present, we replace the
            // current node by the other one.
            if parent.left === node {
               parent.left = node.left ?? node.right
            } else {
                parent.right = node.left ?? node.right
            }
        } else {
            // Since both children are present, we'd better replace the
            // current node's data rather than removing it.
            var replacement = node.right!
            while let child = replacement.left {
                replacement = child
            }

            node.key   = replacement.key
            node.value = replacement.value

            // Remove the node we copied the key-value pair from.
            if replacement.parent!.left === replacement {
                replacement.parent!.left = nil
            } else {
                replacement.parent!.right = nil
            }

            // Use the replacement's parent as the starting node for the
            // rebalancing.
            node = replacement.parent!
        }

        // Rebalance the tree.
        self.rebalance(from: node)
        return value
    }

    private func findNode(withKey key: Key) -> AVLTreeNode<Key, Value>? {
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

    private mutating func rebalance(from startNode: AVLTreeNode<Key, Value>) {
        var node = startNode
        while let parent = node.parent {
            if let grandparent = parent.parent {
                if grandparent.left === parent {
                    grandparent.left = parent.rebalanced()
                } else {
                    grandparent.right = parent.rebalanced()
                }
            } else {
                self.root = parent.rebalanced()
            }
            node = parent
        }
    }

}

extension AVLTree: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(uniqueKeysWithValues: elements)
    }
    
}

// ---

public final class AVLTreeNode<Key: Comparable, Value>: TreeNode {

    public var children: [AVLTreeNode] {
        var result = [AVLTreeNode]()
        if let child = self.left {
            result.append(child)
        }
        if let child = self.right {
            result.append(child)
        }
        return result
    }

    fileprivate var key  : Key
    fileprivate var value: Value

    fileprivate weak var parent: AVLTreeNode?

    fileprivate var left: AVLTreeNode? = nil {
        didSet {
            self.height         = Swift.max(self.left?.height ?? 0, self.right?.height ?? 0) + 1
            self.parent?.height = Swift.max(self.height + 1, self.parent?.height ?? 0)
        }
    }
    fileprivate var right: AVLTreeNode? = nil {
        didSet {
            self.height         = Swift.max(self.left?.height ?? 0, self.right?.height ?? 0) + 1
            self.parent?.height = Swift.max(self.height + 1, self.parent?.height ?? 0)
        }
    }

    fileprivate var height = 1

    fileprivate var balance: Int {
        return (self.left?.height ?? 0) - (self.right?.height ?? 0)
    }

    fileprivate init(key: Key, value: Value, parent: AVLTreeNode? = nil) {
        self.key    = key
        self.value  = value
        self.parent = parent
    }

    fileprivate func rebalanced() -> AVLTreeNode {
        if (self.balance > 1) {
            if self.left!.balance < 0 {
                self.left = self.left!.rotatedLeft()
            }
            return self.rotatedRight()
        } else if (self.balance < -1) {
            if self.right!.balance > 0 {
                self.right = self.right!.rotatedRight()
            }
            return self.rotatedLeft()
        }

        return self
    }

    fileprivate func rotatedLeft() -> AVLTreeNode {
        let a = self
        let b = a.right!

        b.parent        = a.parent
        a.right         = b.left
        a.right?.parent = a
        b.left          = a
        a.parent        = b

        return b
    }

    fileprivate func rotatedRight() -> AVLTreeNode {
        let a = self
        let b = a.left!
        
        b.parent        = a.parent
        a.left          = b.right
        a.left?.parent  = a
        b.right         = a
        a.parent        = b
        
        return b
    }
    
}
