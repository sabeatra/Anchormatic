public protocol Anchorable {
    var cgFloat: CGFloat { get }
}

public extension Anchorable {
    var leading: Anchor { return .constant(.leading, cgFloat) }
    var trailing: Anchor { return .constant(.trailing, cgFloat) }
    var top: Anchor { return .constant(.top, cgFloat) }
    var bottom: Anchor { return .constant(.bottom, cgFloat) }
    var leadingTrailing: Anchor { return .constant(.leadingTrailing, cgFloat) }
    var trailingLeading: Anchor { return .constant(.trailingLeading, cgFloat) }
    var topBottom: Anchor { return .constant(.topBottom, cgFloat) }
    var bottomTop: Anchor { return .constant(.bottomTop, cgFloat) }
    var centerX: Anchor { return .constant(.centerX, cgFloat) }
    var centerY: Anchor { return .constant(.centerY, cgFloat) }
    var center: Anchor { return .constant(.center, cgFloat) }
    var topCenter: Anchor { return .constant(.topCenter, cgFloat) }
    var centerTop: Anchor { return .constant(.centerTop, cgFloat) }
    var leadingCenter: Anchor { return .constant(.leadingCenter, cgFloat) }
    var centerLeading: Anchor { return .constant(.centerLeading, cgFloat) }
    var trailingCenter: Anchor { return .constant(.trailingCenter, cgFloat) }
    var centerTrailing: Anchor { return .constant(.centerTrailing, cgFloat) }
    var horizontal: Anchor { return .constant(.horizontal, cgFloat) }
    var vertical: Anchor { return .constant(.vertical, cgFloat) }
    var edges: Anchor { return .constant(.edges, cgFloat) }
    var height: Anchor { return .multiplier(.height, cgFloat) }
    var width: Anchor { return .multiplier(.width, cgFloat) }
    var widthHeight: Anchor { return .multiplier(.widthHeight, cgFloat) }
    var heightWidth: Anchor { return .multiplier(.heightWidth, cgFloat) }
    
    func safe(_ anchor: Anchor) -> Anchor { return .safe(anchor) }
    func low(_ anchor: Anchor) -> Anchor { return .low(anchor) }
    func high(_ anchor: Anchor) -> Anchor { return .high(anchor) }
    func priority(_ anchor: Anchor) -> Anchor { return .priority(anchor, Float(cgFloat)) }
    func lessOrEqual(_ anchor: Anchor) -> Anchor { return .lessOrEqual(anchor) }
    func greaterOrEqual(_ anchor: Anchor) -> Anchor { return .greaterOrEqual(anchor) }
    
    func multiply(anchor: Anchor) -> Anchor {
        switch anchor {
        case .height, .width, .widthHeight, .heightWidth:
            return .multiplier(anchor, cgFloat)
        case .low(let anchor):
            return .low(multiply(anchor: anchor))
        case .high(let anchor):
            return .high(multiply(anchor: anchor))
        case .lessOrEqual(let anchor):
            return .lessOrEqual(multiply(anchor: anchor))
        case .greaterOrEqual(let anchor):
            return .greaterOrEqual(multiply(anchor: anchor))
        case .priority(let anchor, let priority):
            return .priority(multiply(anchor: anchor), priority)
        case .constant(let anchor, let constant):
            return .constant(anchor, constant * cgFloat)
        case .multiplier(let anchor, let multiplier):
            return .multiplier(anchor, multiplier * cgFloat)
        default:
            return .constant(anchor, cgFloat)
        }
    }
}

extension Float: Anchorable {
    
    public var cgFloat: CGFloat {
        return CGFloat(self)
    }
}

extension CGFloat: Anchorable {
    
    public var cgFloat: CGFloat {
        return self
    }
}

extension Double: Anchorable {
    
    public var cgFloat: CGFloat {
        return CGFloat(self)
    }
}

extension Int: Anchorable {
    
    public var cgFloat: CGFloat {
        return CGFloat(self)
    }
}
