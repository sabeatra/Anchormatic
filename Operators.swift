/*
 Copyright 2019 Eduardo Perez-Rico
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

infix operator ~~>: AssignmentPrecedence
infix operator -~>: AssignmentPrecedence
infix operator .+: AdditionPrecedence
infix operator .-: AdditionPrecedence
infix operator .*: MultiplicationPrecedence
prefix operator .-

public struct AnchorsDescriptor: Equatable {
    let pairs: [(view: UIView, anchor: Anchor)]
    let anchors: [Anchor]
    
    public static func == (lhs: AnchorsDescriptor, rhs: AnchorsDescriptor) -> Bool {
        guard lhs.pairs.count == rhs.pairs.count, lhs.anchors == rhs.anchors else { return false }
        for i in 0 ..< lhs.pairs.count {
            if lhs.pairs[i].view != rhs.pairs[i].view || lhs.pairs[i].anchor != rhs.pairs[i].anchor {
                return false
            }
        }
        return true
    }
}

public func .+ <T: AnyObject>(lhs: NSLayoutAnchor<T>, rhs: Anchorable) -> (NSLayoutAnchor<T>, Anchorable) {
    return (lhs, rhs.cgFloat)
}

public func .- <T: AnyObject>(lhs: NSLayoutAnchor<T>, rhs: Anchorable) -> (NSLayoutAnchor<T>, Anchorable) {
    return (lhs, -rhs.cgFloat)
}

@discardableResult public func -~> <T: AnyObject>(lhs: NSLayoutAnchor<T>, rhs: (NSLayoutAnchor<T>, Anchorable)) -> [NSLayoutConstraint] {
    return [lhs.constraint(equalTo: rhs.0, constant: rhs.1.cgFloat)]
}
@discardableResult public func ~~> <T: AnyObject>(lhs: NSLayoutAnchor<T>, rhs: (NSLayoutAnchor<T>, Anchorable)) -> [NSLayoutConstraint] {
    return Anchor.add(lhs -~> rhs)
}

@discardableResult public func -~> <T: AnyObject>(lhs: NSLayoutAnchor<T>, rhs: NSLayoutAnchor<T>) -> [NSLayoutConstraint] {
    return [lhs.constraint(equalTo: rhs)]
}
@discardableResult public func ~~> <T: AnyObject>(lhs: NSLayoutAnchor<T>, rhs: NSLayoutAnchor<T>) -> [NSLayoutConstraint] {
    return Anchor.add(lhs -~> rhs)
}

public extension NSLayoutDimension {
    
    static func .* (lhs: NSLayoutDimension, rhs: Anchorable) -> (NSLayoutDimension, Anchorable) {
        return (lhs, rhs)
    }
    
    @discardableResult static func -~> (lhs: NSLayoutDimension, rhs: Anchorable) -> [NSLayoutConstraint] {
        return [lhs.constraint(equalToConstant: rhs.cgFloat)]
    }
    @discardableResult static func ~~> (lhs: NSLayoutDimension, rhs: Anchorable) -> [NSLayoutConstraint] {
        return Anchor.add(lhs -~> rhs)
    }

    @discardableResult static func -~> (lhs: NSLayoutDimension, rhs: (NSLayoutDimension, Anchorable)) -> [NSLayoutConstraint] {
        return [lhs.constraint(equalTo: rhs.0, multiplier: rhs.1.cgFloat)]
    }
    @discardableResult static func ~~> (lhs: NSLayoutDimension, rhs: (NSLayoutDimension, Anchorable)) -> [NSLayoutConstraint] {
        return Anchor.add(lhs -~> rhs)
    }
}

public extension UIView {
    
    @discardableResult static func -~> (lhs: UIView, rhs: UIView) -> [NSLayoutConstraint] {
        return [Anchor.leading, .trailing, .top, .bottom].reduce([]) {
            $0 + $1.constraints(view1: lhs, view2: rhs, relation: .equal, useSafeArea: false)
        }
    }
    @discardableResult static func ~~> (lhs: UIView, rhs: UIView) -> [NSLayoutConstraint] {
        return Anchor.add(lhs -~> rhs)
    }

    @discardableResult static func -~> (lhs: UIView, rhs: AnchorsDescriptor) -> [NSLayoutConstraint] {
        assert(rhs.anchors.allSatisfy { $0.isSingleView })
        let pairsConstraints = rhs.pairs.reduce([]) { $0 + $1.anchor.constraints(view1: lhs, view2: $1.view, relation: .equal, useSafeArea: false) }
        let anchorsConstraints = rhs.anchors.reduce([]) { $0 + $1.constraints(view1: lhs, view2: nil, relation: .equal, useSafeArea: false) }
        return pairsConstraints + anchorsConstraints
    }
    @discardableResult static func ~~> (lhs: UIView, rhs: AnchorsDescriptor) -> [NSLayoutConstraint] {
        return Anchor.add(lhs -~> rhs)
    }

    @discardableResult static func -~> (lhs: UIView, rhs: Anchor) -> [NSLayoutConstraint] {
        assert(rhs.isSingleView)
        return rhs.constraints(view1: lhs, view2: nil, relation: .equal, useSafeArea: false)
    }
    @discardableResult static func ~~> (lhs: UIView, rhs: Anchor) -> [NSLayoutConstraint] {
        return Anchor.add(lhs -~> rhs)
    }

    @discardableResult static func -~> (lhs: UIView, rhs: [Anchor]) -> [NSLayoutConstraint] {
        assert(rhs.allSatisfy { $0.isSingleView })
        return rhs.reduce([]) { $0 + $1.constraints(view1: lhs, view2: nil, relation: .equal, useSafeArea: false) }
    }
    @discardableResult static func ~~> (lhs: UIView, rhs: [Anchor]) -> [NSLayoutConstraint] {
        return Anchor.add(lhs -~> rhs)
    }

    static func .* (lhs: UIView, rhs: [Anchor]) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: rhs.map { (lhs, $0) }, anchors: [])
    }
    
    static func .* (lhs: UIView, rhs: Anchor) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: [(lhs, rhs)], anchors: [])
    }
    
    static func .* (lhs: [Anchor], rhs: UIView) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: lhs.map { (rhs, $0) }, anchors: [])
    }
    
    static func .+ (lhs: UIView, rhs: UIView) -> [UIView] {
        return [lhs, rhs]
    }
}

public extension Anchor {
    
    static func .* (lhs: [UIView], rhs: Anchor) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: lhs.map { ($0, rhs) }, anchors: [])
    }
    
    static func .* (lhs: Anchor, rhs: [UIView]) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: rhs.map { ($0, lhs) }, anchors: [])
    }
    
    static func .* (lhs: Anchor, rhs: UIView) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: [(rhs, lhs)], anchors: [])
    }
}

public extension Array where Element == Anchor {
    
    var safe: [Anchor] {
        return map { .safe($0) }
    }
}

public extension AnchorsDescriptor {
    static func .* (lhs: Anchorable, rhs: AnchorsDescriptor) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: rhs.pairs.map { ($0.view, lhs.multiply(anchor: $0.anchor)) }, anchors: rhs.anchors.map { lhs.multiply(anchor: $0) })
    }
    
    static func .* (lhs: AnchorsDescriptor, rhs: Anchorable) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: lhs.pairs.map { ($0.view, rhs.multiply(anchor: $0.anchor)) }, anchors: lhs.anchors.map { rhs.multiply(anchor: $0) })
    }
}

public func .* (lhs: Anchorable, rhs: Anchor) -> [Anchor] {
    return [lhs.multiply(anchor: rhs)]
}

public func .* (lhs: Anchorable, rhs: [Anchor]) -> [Anchor] {
    return rhs.map { lhs.multiply(anchor: $0) }
}

public func .* (lhs: [Anchor], rhs: Anchorable) -> [Anchor] {
    return lhs.map { rhs.multiply(anchor: $0) }
}

public func .* (lhs: Anchor, rhs: Anchorable) -> [Anchor] {
    return [rhs.multiply(anchor: lhs)]
}

public func .* (lhs: Anchor, rhs: [Anchorable]) -> [Anchor] {
    return rhs.map { $0.multiply(anchor: lhs) }
}

public extension Anchor {
    
    static func .+ (lhs: Anchor, rhs: Anchor) -> [Anchor] {
        return [lhs, rhs]
    }
    
    static func .+ (lhs: Anchor, rhs: [Anchor]) -> [Anchor] {
        return [lhs] + rhs
    }
    
    static func .+ (lhs: [Anchor], rhs: Anchor) -> [Anchor] {
        return lhs + [rhs]
    }
    
    static func .- (lhs: Anchor, rhs: Anchor) -> [Anchor] {
        return [lhs, .-rhs]
    }
    
    static func .- (lhs: Anchor, rhs: [Anchor]) -> [Anchor] {
        return [lhs] + .-rhs
    }
    
    static func .- (lhs: [Anchor], rhs: Anchor) -> [Anchor] {
        return lhs + [.-rhs]
    }
    
    static prefix func .- (anchor: Anchor) -> Anchor {
        return (-1).multiply(anchor: anchor)
    }
}

public extension Array where Element == Anchor {
    
    static prefix func .- (array: [Anchor]) -> [Anchor] {
        return array.map { .-$0 }
    }
    
    static func .- (lhs: [Anchor], rhs: [Anchor]) -> [Anchor] {
        return lhs + rhs.map { .-$0 }
    }
}

public extension AnchorsDescriptor {
    static func .+ (lhs: AnchorsDescriptor, rhs: AnchorsDescriptor) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: lhs.pairs + rhs.pairs, anchors: lhs.anchors + rhs.anchors)
    }
    
    static func .- (lhs: AnchorsDescriptor, rhs: AnchorsDescriptor) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: lhs.pairs + rhs.pairs.map { ($0.view, .-$0.anchor) }, anchors: lhs.anchors .- rhs.anchors)
    }
    
    static func .+ (lhs: [Anchor], rhs: AnchorsDescriptor) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: rhs.pairs, anchors: rhs.anchors + lhs)
    }
    
    static func .+ (lhs: AnchorsDescriptor, rhs: [Anchor]) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: lhs.pairs, anchors: lhs.anchors + rhs)
    }
    
    static func .- (lhs: AnchorsDescriptor, rhs: [Anchor]) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: lhs.pairs, anchors: lhs.anchors .- rhs)
    }
    
    static func .+ (lhs: Anchor, rhs: AnchorsDescriptor) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: rhs.pairs, anchors: rhs.anchors + [lhs])
    }
    
    static func .+ (lhs: AnchorsDescriptor, rhs: Anchor) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: lhs.pairs, anchors: lhs.anchors + [rhs])
    }
    
    static func .- (lhs: AnchorsDescriptor, rhs: Anchor) -> AnchorsDescriptor {
        return AnchorsDescriptor(pairs: lhs.pairs, anchors: lhs.anchors .- [rhs])
    }
}

