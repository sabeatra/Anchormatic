import XCTest
@testable import Kit

extension NSLayoutConstraint {
    
    static func == (lhs: NSLayoutConstraint, rhs: NSLayoutConstraint) -> Bool {
        return lhs.firstItem === rhs.firstItem && rhs.secondItem === lhs.secondItem && lhs.firstAnchor === rhs.firstAnchor &&
            lhs.secondAnchor === rhs.secondAnchor && lhs.constant == rhs.constant && lhs.multiplier == rhs.multiplier &&
            lhs.relation == rhs.relation && lhs.priority == rhs.priority
    }
}

extension Array where Element == NSLayoutConstraint {
    
    func contains(_ element: NSLayoutConstraint) -> Bool {
        return filter({ element == $0 }).isEmpty == false
    }
    
    static func == (lhs: [NSLayoutConstraint], rhs: [NSLayoutConstraint]) -> Bool {
        return lhs.filter({ !rhs.contains($0) }).isEmpty && rhs.filter({ !lhs.contains($0) }).isEmpty
    }
}

class AnchorOperatorsTests: XCTestCase {
    
    let view1 = UIView()
    let view2 = UIView()
    let mainView = UIView()
    
    override func setUp() {
        Anchor.currentView = mainView
    }
    
    override func tearDown() {
        Anchor.currentView = nil
        Anchor.removePendingConstraints()
    }
    
    func testNSLayoutAnchor() {
        let pair1 = view1.leadingAnchor .+ 10
        XCTAssert(pair1.0 == view1.leadingAnchor && pair1.1.cgFloat == CGFloat(10))
        
        let pair2 = view1.leadingAnchor .- 10
        XCTAssert(pair2.0 == view1.leadingAnchor && pair2.1.cgFloat == -CGFloat(10))

        XCTAssert((view1.leadingAnchor -~> (view2.trailingAnchor, 10)) == [view1.leadingAnchor.constraint(equalTo: view2.trailingAnchor, constant: 10)])
        XCTAssert((view1.leadingAnchor ~~> (view2.trailingAnchor, 10)) == [view1.leadingAnchor.constraint(equalTo: view2.trailingAnchor, constant: 10)])
        
        XCTAssert((view1.leadingAnchor -~> view2.trailingAnchor) == [view1.leadingAnchor.constraint(equalTo: view2.trailingAnchor)])
        XCTAssert((view1.leadingAnchor ~~> view2.trailingAnchor) == [view1.leadingAnchor.constraint(equalTo: view2.trailingAnchor)])
    }
    
    func testNSLayoutDimension() {
        let pair = view1.heightAnchor .* 10
        XCTAssert(pair.0 == view1.heightAnchor && pair.1.cgFloat == CGFloat(10))

        XCTAssert((view1.heightAnchor -~> 10) == [view1.heightAnchor.constraint(equalToConstant: 10)])
        XCTAssert((view1.heightAnchor ~~> 10) == [view1.heightAnchor.constraint(equalToConstant: 10)])

        XCTAssert((view1.heightAnchor -~> (view2.widthAnchor, 10)) == [view1.heightAnchor.constraint(equalTo: view2.widthAnchor, multiplier: 10)])
        XCTAssert((view1.heightAnchor ~~> (view2.widthAnchor, 10)) == [view1.heightAnchor.constraint(equalTo: view2.widthAnchor, multiplier: 10)])
    }
    
    func testUIView() {
        XCTAssert((view1 -~> view2) == (view1 ~~> view2))
        XCTAssert((view1 ~~> view2) == [
            view1.leadingAnchor.constraint(equalTo: view2.leadingAnchor),
            view1.topAnchor.constraint(equalTo: view2.topAnchor),
            view1.bottomAnchor.constraint(equalTo: view2.bottomAnchor),
            view1.trailingAnchor.constraint(equalTo: view2.trailingAnchor),
        ])
        
        let view = UIView()
        let descriptor = AnchorsDescriptor(pairs: [(view1, .leading), (view2, .top)], anchors: [10.width, 20.height])
        XCTAssert((view -~> descriptor) == (view ~~> descriptor))
        XCTAssert((view ~~> descriptor) == [
            view.leadingAnchor.constraint(equalTo: view1.leadingAnchor),
            view.topAnchor.constraint(equalTo: view2.topAnchor),
            view.heightAnchor.constraint(equalToConstant: 20),
            view.widthAnchor.constraint(equalToConstant: 10)
        ])
        
        XCTAssert((view1 -~> 10.height) == (view1 ~~> 10.height))
        XCTAssert((view1 ~~> 10.height) == [view1.heightAnchor.constraint(equalToConstant: 10)])
        
        XCTAssert((view1 -~> AnchorsDescriptor(pairs: [(view2, .leading), (view2, .top)], anchors: [10.width])) == [
            view1.leadingAnchor.constraint(equalTo: view2.leadingAnchor),
            view1.topAnchor.constraint(equalTo: view2.topAnchor),
            view1.widthAnchor.constraint(equalToConstant: 10)
        ])
        XCTAssert((view1 ~~> view2) == (view1 -~> view2))
        
        XCTAssert((view1 -~> 10.width) == [view1.widthAnchor.constraint(equalToConstant: 10)])
        XCTAssert((view1 -~> 10.width) == (view1 ~~> 10.width))
        
        XCTAssert((view1 -~> [10.width, 20.height]) == [view1.widthAnchor.constraint(equalToConstant: 10), view1.heightAnchor.constraint(equalToConstant: 20)])
        XCTAssert((view1 -~> [10.width, 20.height]) == (view1 ~~> [10.width, 20.height]))
        
        XCTAssert(view1 .* [.leading, .trailing] == AnchorsDescriptor(pairs: [(view1, .leading), (view1, .trailing)], anchors: []))
        XCTAssert(view1 .* 10.width == AnchorsDescriptor(pairs: [(view1, 10.width)], anchors: []))
        XCTAssert(10.width .* view1 == view1 .* 10.width)

        XCTAssert([.leading, .trailing] .* view1 == view1 .* [.leading, .trailing])
        XCTAssert(view1 .* .leading == .leading .* view1)
        
        XCTAssert([view1, view2] .* .leading == AnchorsDescriptor(pairs: [(view1, .leading), (view2, .leading)], anchors: []))
        XCTAssert(.leading .* [view1, view2] == [view1, view2] .* .leading)
    }
    
    func testAnchorable() {
        let descriptor = AnchorsDescriptor(pairs: [(view1, .leading), (view2, .trailing)], anchors: [.width, .height])
        XCTAssert(10 .* descriptor == AnchorsDescriptor(pairs: [(view1, 10.leading), (view2, 10.trailing)], anchors: [10.width, 10.height]))
        XCTAssert(descriptor .* 10 == 10 .* descriptor)
        XCTAssert(10 .* .leading == [10.leading])
        XCTAssert(10 .* [.leading, .trailing] == [10.leading, 10.trailing])
        XCTAssert(10 .* .leading == .leading .* 10)
        XCTAssert([.leading, .trailing] .* 10 == [10.leading, 10.trailing])
    }
    
    func testAnchor() {
        XCTAssert(20.leading .+ 10.trailing == [20.leading, 10.trailing])
        XCTAssert(20.leading .+ [10.trailing, .center] == [20.leading, 10.trailing, .center])
        XCTAssert([10.trailing, .center] .+ 10.leading == [10.trailing, .center, 10.leading])
        XCTAssert(20.leading .- 10.trailing == [20.leading, .-10.trailing])
        XCTAssert(10.leading .- [20.trailing, 5.center] == [10.leading, .-20.trailing, .-5.center])
        XCTAssert([20.trailing, 5.center] .- 10.leading == [20.trailing, 5.center, .-10.leading])
        XCTAssert(.-10.leading == (-1).multiply(anchor: 10.leading))
        XCTAssert(.-[10.leading, 20.trailing] == [.-10.leading, .-20.trailing])
        XCTAssert([10.leading] .- [20.trailing, 30.center] == [10.leading, .-20.trailing, .-30.center])
    }
    
    func testAnchorsDescriptor() {
        let a = AnchorsDescriptor(pairs: [(view1, 10.leading)], anchors: [10.width])
        let b = AnchorsDescriptor(pairs: [(view2, 10.centerY)], anchors: [10.height])
        XCTAssert(a .+ b == AnchorsDescriptor(pairs: [(view1, 10.leading), (view2, 10.centerY)], anchors: [10.width, 10.height]))
        XCTAssert(a .- b == AnchorsDescriptor(pairs: [(view1, 10.leading), (view2, (-10).centerY)], anchors: [10.width, (-10).height]))
        XCTAssert([.leading, .trailing] .+ a == AnchorsDescriptor(pairs: [(view1, 10.leading)], anchors: [10.width, .leading, .trailing]))
        XCTAssert(a .+ [.leading, .trailing] == [.leading, .trailing] .+ a)
        XCTAssert(a .- [10.leading, 10.trailing] == AnchorsDescriptor(pairs: [(view1, 10.leading)], anchors: [10.width, (-10).leading, (-10).trailing]))
        XCTAssert(.leading .+ a == [.leading] .+ a)
        XCTAssert(a .+ .leading == [.leading] .+ a)
        XCTAssert(a .- .leading == a .- [.leading])
    }
    
    func testRandom() {
        let view3 = UIView()
        let view4 = UIView()
        
        let padding = CGFloat(10)
        
        let anchor = .-padding.bottom
        switch anchor {
        case .constant(let anchor, let constant):
            XCTAssert(anchor == .bottom && constant == -padding)
        default:
            break
        }
        
        XCTAssert((view1 ~~> 20.height) == [view1.heightAnchor.constraint(equalToConstant: CGFloat(20))])
        
        XCTAssert((view1 ~~> (10.height .+ 20.width)) == [
            view1.heightAnchor.constraint(equalToConstant: CGFloat(10)),
            view1.widthAnchor.constraint(equalToConstant: CGFloat(20))
            ])
        
        XCTAssert((view1 ~~> view2 .* (.leading .+ .trailing .+ .centerY)) == [
            view1.leadingAnchor.constraint(equalTo: view2.leadingAnchor),
            view1.trailingAnchor.constraint(equalTo: view2.trailingAnchor),
            view1.centerYAnchor.constraint(equalTo: view2.centerYAnchor)
            ])
        
        XCTAssert((.leading .+ .top .- padding.bottom) == [.leading, .top, .constant(.bottom, -padding)])
        
        XCTAssert((view1 ~~> (padding .* (.leading .+ .top .- .bottom) .* view2)) == [
            view1.leadingAnchor.constraint(equalTo: view2.leadingAnchor, constant: padding),
            view1.topAnchor.constraint(equalTo: view2.topAnchor, constant: padding),
            view1.bottomAnchor.constraint(equalTo: view2.bottomAnchor, constant: -padding),
            ])
        
        XCTAssert(.leading .+ .top .- .bottom == [.leading, .top, .-Anchor.bottom])
        XCTAssert(padding .* (.leading .+ .top .- .bottom) == [padding.leading, padding.top, .-padding.bottom])
        XCTAssert((view1 ~~> view2 .* padding.vertical) == (view1 ~~> view2 .* [padding.top, .-padding.bottom]))
        XCTAssert((view1 ~~> view2 .* padding.horizontal) == (view1 ~~> view2 .* [padding.leading, .-padding.trailing]))
        
        let widthConstraint1 = view1.widthAnchor.constraint(equalTo: view3.widthAnchor)
        let widthConstraint2 = view1.widthAnchor.constraint(equalTo: view4.widthAnchor)
        widthConstraint1.priority = .defaultLow
        widthConstraint2.priority = .defaultLow
        
        XCTAssert((view1 ~~> padding .* (.leading .+ .vertical) .* view2 .+ .low(.width) .* (view3 .+ view4)) == [
            view1.leadingAnchor.constraint(equalTo: view2.leadingAnchor, constant: padding),
            view1.topAnchor.constraint(equalTo: view2.topAnchor, constant: padding),
            view1.bottomAnchor.constraint(equalTo: view2.bottomAnchor, constant: -padding),
            widthConstraint1,
            widthConstraint2,
            ])
        
        XCTAssert((view1 ~~> view2 .* (.centerY .+ .centerX .+ .lessOrEqual(0.95.width))) == [
            view1.centerYAnchor.constraint(equalTo: view2.centerYAnchor),
            view1.centerXAnchor.constraint(equalTo: view2.centerXAnchor),
            view1.widthAnchor.constraint(lessThanOrEqualTo: view2.widthAnchor, multiplier: 0.95),
            ])
        
        XCTAssert((view1 ~~> 10.height .* 10) == [view1.heightAnchor.constraint(equalToConstant: 100)])
        
        XCTAssert(view1 .+ view2 == [view1, view2])
    }
}


class ViewHierarchyTests : XCTestCase {
    let view = UIView()
    let view1 = UIView()
    let view2 = UIView()
    let view3 = UIView()
    let view4 = UIView()
    
    override func tearDown() {
        [view, view1, view2, view3, view4].forEach { $0.removeFromSuperview() }
    }

    func testSubviews1() {
        view.createViewHierarchy(view1)
        XCTAssert(view.subviews == [view1])
    }
    
    func testSubviews2() {
        view.createViewHierarchy([view1, view2])
        XCTAssert(view.subviews == [view1, view2])
    }
    
    func testSubviews3() {
        view.createViewHierarchy([view1, ViewHierarchy(view2, view3)])
        XCTAssert(view.subviews == [view1, view2])
        XCTAssert(view2.subviews == [view3])
    }

    func testSubviews4() {
        view.createViewHierarchy(ViewHierarchy(view1, [ViewHierarchy(view2, [view3]), view4]))
        XCTAssert(view.subviews == [view1])
        XCTAssert(view1.subviews == [view2, view4])
        XCTAssert(view2.subviews == [view3])
        XCTAssert(view4.subviews == [])
    }
    
    func testConstraints1() {
        var constraint: NSLayoutConstraint?
        let f: () -> ViewHierarchyDescriptor = { [weak self] in
            guard let self = self else { return [] }
            constraint = (self.view1 ~~> self.view2 .* .leading).first
            return [self.view1, self.view2]
        }
        view.createViewHierarchy(f())
        XCTAssert(view.constraints.contains(constraint!))
        XCTAssert(constraint?.isActive == true)
    }
    
    func testConstraints2() {
        var constraint: NSLayoutConstraint?
        let f: () -> ViewHierarchyDescriptor = { [weak self] in
            guard let self = self else { return [] }
            constraint = (self.view1 -~> self.view2 .* .leading).first
            return [self.view1, self.view2]
        }
        view.createViewHierarchy(f())
        XCTAssert(view.constraints.isEmpty)
        XCTAssert(constraint?.isActive == false)
    }
}
