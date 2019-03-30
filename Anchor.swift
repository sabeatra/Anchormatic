/*
 Copyright 2019 Eduardo Perez-Rico
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

public indirect enum Anchor: Equatable {
    case leading, trailing, top, bottom
    case leadingTrailing, topBottom, trailingLeading, bottomTop
    case horizontal, vertical, edges
    case centerX, centerY, center
    case topCenter, centerTop, leadingCenter, centerLeading, trailingCenter, centerTrailing
    case height, width
    case heightWidth, widthHeight
    case low(Anchor), high(Anchor), priority(Anchor, Float)
    case constant(Anchor, CGFloat)
    case multiplier(Anchor, CGFloat)
    case lessOrEqual(Anchor), greaterOrEqual(Anchor)
    case safe(Anchor)
}

extension Anchor {
    
    public var isSingleView: Bool {
        switch self {
        case .height, .width, .widthHeight, .heightWidth:
            return true
        case .low(let anchor), .high(let anchor), .lessOrEqual(let anchor), .greaterOrEqual(let anchor):
            return anchor.isSingleView
        case .priority(let anchor, _), .constant(let anchor, _), .multiplier(let anchor, _):
            return anchor.isSingleView
        default:
            return false
        }
    }
    
    private func anchorConstraint<T: AnyObject>(
        firstAnchor: NSLayoutAnchor<T>,
        secondAnchor: NSLayoutAnchor<T>,
        relation: NSLayoutConstraint.Relation) -> NSLayoutConstraint
    {
        switch relation {
        case .greaterThanOrEqual:
            return firstAnchor.constraint(greaterThanOrEqualTo: secondAnchor)
        case .lessThanOrEqual:
            return firstAnchor.constraint(lessThanOrEqualTo: secondAnchor)
        case .equal:
            fallthrough
        @unknown default:
            return firstAnchor.constraint(equalTo: secondAnchor)
        }
    }
    
    private func dimensionConstraint(
        firstAnchor: NSLayoutDimension,
        secondAnchor: NSLayoutDimension? = nil,
        constantOrMultiplier: CGFloat? = nil,
        relation: NSLayoutConstraint.Relation) -> NSLayoutConstraint
    {
        guard let secondAnchor = secondAnchor else {
            let constant = constantOrMultiplier ?? 0
            switch relation {
            case .greaterThanOrEqual:
                return firstAnchor.constraint(greaterThanOrEqualToConstant: constant)
            case .lessThanOrEqual:
                return firstAnchor.constraint(lessThanOrEqualToConstant: constant)
            case .equal:
                fallthrough
            @unknown default:
                return firstAnchor.constraint(equalToConstant: constant)
            }
        }
        
        let multiplier = constantOrMultiplier ?? 1
        switch relation {
        case .greaterThanOrEqual:
            return firstAnchor.constraint(greaterThanOrEqualTo: secondAnchor, multiplier: multiplier)
        case .lessThanOrEqual:
            return firstAnchor.constraint(lessThanOrEqualTo: secondAnchor, multiplier: multiplier)
        case .equal:
            fallthrough
        @unknown default:
            return firstAnchor.constraint(equalTo: secondAnchor, multiplier: multiplier)
        }
    }
    
    func constraints(view1: UIView, view2: UIView?, relation: NSLayoutConstraint.Relation, useSafeArea: Bool) -> [NSLayoutConstraint] {
        let topAnchor = useSafeArea ? view2?.safeAreaLayoutGuide.topAnchor : view2?.topAnchor
        let bottomAnchor = useSafeArea ? view2?.safeAreaLayoutGuide.bottomAnchor : view2?.bottomAnchor
        let leadingAnchor = useSafeArea ? view2?.safeAreaLayoutGuide.leadingAnchor : view2?.leadingAnchor
        let trailingAnchor = useSafeArea ? view2?.safeAreaLayoutGuide.trailingAnchor : view2?.trailingAnchor
        let centerXAnchor = useSafeArea ? view2?.safeAreaLayoutGuide.centerXAnchor : view2?.centerXAnchor
        let centerYAnchor = useSafeArea ? view2?.safeAreaLayoutGuide.centerYAnchor : view2?.centerYAnchor
        
        switch self {
        case .leading:
            guard let leadingAnchor = leadingAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.leadingAnchor, secondAnchor: leadingAnchor, relation: relation)]
        case .trailing:
            guard let trailingAnchor = trailingAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.trailingAnchor, secondAnchor: trailingAnchor, relation: relation)]
        case .top:
            guard let topAnchor = topAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.topAnchor, secondAnchor: topAnchor, relation: relation)]
        case .bottom:
            guard let bottomAnchor = bottomAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.bottomAnchor, secondAnchor: bottomAnchor, relation: relation)]
        case .leadingTrailing:
            guard let trailingAnchor = trailingAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.leadingAnchor, secondAnchor: trailingAnchor, relation: relation)]
        case .topBottom:
            guard let bottomAnchor = bottomAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.topAnchor, secondAnchor: bottomAnchor, relation: relation)]
        case .trailingLeading:
            guard let leadingAnchor = leadingAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.trailingAnchor, secondAnchor: leadingAnchor, relation: relation)]
        case .bottomTop:
            guard let topAnchor = topAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.bottomAnchor, secondAnchor: topAnchor, relation: relation)]
        case .horizontal:
            return horizontalConstraints(view1: view1, leading: leadingAnchor, trailing: trailingAnchor)
        case .vertical:
            return verticalConstraints(view1: view1, top: topAnchor, bottom: bottomAnchor)
        case .edges:
            return horizontalConstraints(view1: view1, leading: leadingAnchor, trailing: trailingAnchor) +
                verticalConstraints(view1: view1, top: topAnchor, bottom: bottomAnchor)
        case .centerX:
            guard let centerXAnchor = centerXAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.centerXAnchor, secondAnchor: centerXAnchor, relation: relation)]
        case .centerY:
            guard let centerYAnchor = centerYAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.centerYAnchor, secondAnchor: centerYAnchor, relation: relation)]
        case .center:
            guard let centerXAnchor = centerXAnchor else { assertionFailure(); return [] }
            guard let centerYAnchor = centerYAnchor else { assertionFailure(); return [] }
            assert(relation == .equal)
            return [
                anchorConstraint(firstAnchor: view1.centerXAnchor, secondAnchor: centerXAnchor, relation: relation),
                anchorConstraint(firstAnchor: view1.centerYAnchor, secondAnchor: centerYAnchor, relation: relation)
            ]
        case .topCenter:
            guard let centerYAnchor = centerYAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.topAnchor, secondAnchor: centerYAnchor, relation: relation)]
        case .centerTop:
            guard let topAnchor = topAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.centerYAnchor, secondAnchor: topAnchor, relation: relation)]
        case .leadingCenter:
            guard let centerXAnchor = centerXAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.leadingAnchor, secondAnchor: centerXAnchor, relation: relation)]
        case .centerLeading:
            guard let leadingAnchor = leadingAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.centerXAnchor, secondAnchor: leadingAnchor, relation: relation)]
        case .trailingCenter:
            guard let centerXAnchor = centerXAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.trailingAnchor, secondAnchor: centerXAnchor, relation: relation)]
        case .centerTrailing:
            guard let trailingAnchor = trailingAnchor else { assertionFailure(); return [] }
            return [anchorConstraint(firstAnchor: view1.centerXAnchor, secondAnchor: trailingAnchor, relation: relation)]
        case .height:
            return [dimensionConstraint(firstAnchor: view1.heightAnchor, secondAnchor: view2?.heightAnchor, relation: relation)]
        case .width:
            return [dimensionConstraint(firstAnchor: view1.widthAnchor, secondAnchor: view2?.widthAnchor, relation: relation)]
        case .heightWidth:
            let widthAnchor = view2?.widthAnchor ?? view1.widthAnchor
            return [dimensionConstraint(firstAnchor: view1.heightAnchor, secondAnchor: widthAnchor, relation: relation)]
        case .widthHeight:
            let heightAnchor = view2?.heightAnchor ?? view1.heightAnchor
            return [dimensionConstraint(firstAnchor: view1.widthAnchor, secondAnchor: heightAnchor, relation: relation)]
        case .low(let anchor):
            let constraints = anchor.constraints(view1: view1, view2: view2, relation: relation, useSafeArea: useSafeArea)
            constraints.forEach { $0.priority = .defaultLow }
            return constraints
        case .high(let anchor):
            let constraints = anchor.constraints(view1: view1, view2: view2, relation: relation, useSafeArea: useSafeArea)
            constraints.forEach { $0.priority = .defaultHigh }
            return constraints
        case .priority(let anchor, let priority):
            let constraints = anchor.constraints(view1: view1, view2: view2, relation: relation, useSafeArea: useSafeArea)
            constraints.forEach { $0.priority = UILayoutPriority(rawValue: priority) }
            return constraints
        case .constant(let anchor, let constant):
            switch anchor {
            case .horizontal:
                return horizontalConstraints(view1: view1, leading: leadingAnchor, trailing: trailingAnchor, constant: constant)
            case .vertical:
                return verticalConstraints(view1: view1, top: topAnchor, bottom: bottomAnchor, constant: constant)
            case .edges:
                return horizontalConstraints(view1: view1, leading: leadingAnchor, trailing: trailingAnchor, constant: constant) +
                    verticalConstraints(view1: view1, top: topAnchor, bottom: bottomAnchor, constant: constant)
            default:
                let constraints = anchor.constraints(view1: view1, view2: view2, relation: relation, useSafeArea: useSafeArea)
                constraints.forEach { $0.constant = constant }
                return constraints
            }
        case .multiplier(let anchor, let multiplier):
            let constraints = anchor.constraints(view1: view1, view2: view2, relation: relation, useSafeArea: useSafeArea)
            return constraints.reduce([]) { array, constraint in
                if let firstAnchor = constraint.firstAnchor as? NSLayoutAnchor<NSLayoutDimension> as? NSLayoutDimension {
                    let secondAnchor = constraint.secondAnchor as? NSLayoutAnchor<NSLayoutDimension> as? NSLayoutDimension
                    return array + [
                        dimensionConstraint(firstAnchor: firstAnchor, secondAnchor: secondAnchor, constantOrMultiplier: constraint.multiplier * multiplier, relation: relation)
                    ]
                } else {
                    constraint.constant *= multiplier
                    return array + [constraint]
                }
            }
        case .lessOrEqual(let anchor):
            return anchor.constraints(view1: view1, view2: view2, relation: .lessThanOrEqual, useSafeArea: useSafeArea)
        case .greaterOrEqual(let anchor):
            return anchor.constraints(view1: view1, view2: view2, relation: .greaterThanOrEqual, useSafeArea: useSafeArea)
        case .safe(let anchor):
            return anchor.constraints(view1: view1, view2: view2, relation: relation, useSafeArea: true)
        }
    }
    
    private func horizontalConstraints(
        view1: UIView,
        leading: NSLayoutXAxisAnchor?, trailing: NSLayoutXAxisAnchor?,
        constant: CGFloat = 0) -> [NSLayoutConstraint] {
        guard let leading = leading, let trailing = trailing else { assertionFailure(); return [] }
        return [
            view1.leadingAnchor.constraint(equalTo: leading, constant: constant),
            view1.trailingAnchor.constraint(equalTo: trailing, constant: -constant)
        ]
    }
    
    private func verticalConstraints(
        view1: UIView,
        top: NSLayoutYAxisAnchor?, bottom: NSLayoutYAxisAnchor?,
        constant: CGFloat = 0) -> [NSLayoutConstraint] {
        guard let top = top, let bottom = bottom else { assertionFailure(); return [] }
        return [
            view1.topAnchor.constraint(equalTo: top, constant: constant),
            view1.bottomAnchor.constraint(equalTo: bottom, constant: -constant)
        ]
    }
}

extension Anchor {
    
    static weak var currentView: UIView?
    
    static func add(_ constraints: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        guard let currentView = currentView else { assertionFailure(); return [] }
        pendingConstraints[currentView] = (pendingConstraints[currentView] ?? []) + constraints.map { WeakConstraint(constraint: $0) }
        return constraints
    }
    
    static func activatePendingConstraints(forView view: UIView) {
        guard let constraints = pendingConstraints[view]?.compactMap({ $0.constraint }) else { return }
        constraints.activate()
        pendingConstraints[view] = nil
    }
    
    static func removePendingConstraints() {
        pendingConstraints.removeAll()
    }
}

private var pendingConstraints = [UIView: [WeakConstraint]]()

private struct WeakConstraint {
    private (set) weak var constraint: NSLayoutConstraint?
}
