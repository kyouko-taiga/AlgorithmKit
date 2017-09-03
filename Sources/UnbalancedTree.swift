public struct UnbalancedTree<Key: Comparable, Value>: BinarySearchTree {

    public private(set) var root: UnbalancedTreeNode<Key, Value>? = nil

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
                self.root = UnbalancedTreeNode(key: key, value: value)
                return
            }

            while true {
                if key == node.key {
                    node.value = value
                    return
                } else if key < node.key {
                    if node.left == nil {
                        node.left = UnbalancedTreeNode(key: key, value: value)
                        break
                    } else {
                        node = node.left!
                    }
                } else {
                    if node.right == nil {
                        node.right = UnbalancedTreeNode(key: key, value: value)
                        break
                    } else {
                        node = node.right!
                    }
                }
            }
        }
    }

    /// Removes the given element and any elements subsumed by the given element.
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        guard var node = self.root else {
            return nil
        }

        // The root is a special case.
        if node.key == key {
            if let right = node.right {
                right.leftMost.left = node.left
                self.root = right
            } else {
                self.root = node.left
            }
            return node.value
        }

        while true {
            if key < node.key {
                if let left = node.left {
                    if key == left.key {
                        if let leftRight = left.right {
                            node.left = leftRight
                            node.leftMost.left = left.left
                        } else {
                            node.left = left.left
                        }
                        return node.value
                    } else {
                        node = left
                    }
                } else {
                    return nil
                }
            } else {
                if let right = node.right {
                    if key == right.key {
                        if let rightLeft = right.left {
                            node.right = rightLeft
                            node.rightMost.right = right.right
                        } else {
                            node.right = right.right
                        }
                        return node.value
                    } else {
                        node = right
                    }
                } else {
                    return nil
                }
            }
        }
    }

}

extension UnbalancedTree: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (Node.Key, Node.Value)...) {
        self.init(uniqueKeysWithValues: elements)
    }

}

extension UnbalancedTree: CustomStringConvertible {

    public var description: String {
        guard !self.isEmpty else {
            return "[:]"
        }

        let content = self.map({ String(describing: $0) + ": " + String(describing: $1) })
            .joined(separator: ",")
        return "[\(content)]"
    }
    
}

// ---------------------------------------------------------------------------

public final class UnbalancedTreeNode<K: Comparable, V>: BinarySearchTreeNode {

    public fileprivate(set) var key  : K
    public fileprivate(set) var value: V
    public fileprivate(set) var left : UnbalancedTreeNode? = nil
    public fileprivate(set) var right: UnbalancedTreeNode? = nil

    fileprivate init(key: Key, value: Value) {
        self.key    = key
        self.value  = value
    }

}
