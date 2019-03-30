import UIKit

public protocol ViewHierarchyDescriptor {
    func addSubviews(to view: UIView)
}

extension Array: ViewHierarchyDescriptor where Element: Any {
    
    public func addSubviews(to view: UIView) {
        for element in self {
            Kit.addSubviews(descriptor: element, view: view)
        }
    }
}

public struct ViewHierarchy: ViewHierarchyDescriptor {
    public let view: UIView
    public let descriptor: ViewHierarchyDescriptor
    
    public init(_ view: UIView, _ descriptor: ViewHierarchyDescriptor) {
        self.view = view
        self.descriptor = descriptor
    }
    
    public func addSubviews(to view: UIView) {
        descriptor.addSubviews(to: self.view)
        self.view.addSubviews(to: view)
    }
}

extension UIView: ViewHierarchyDescriptor {
    
    public func createViewHierarchy(_ descriptor: @autoclosure () -> ViewHierarchyDescriptor, activateConstraints: Bool = true) {
        let currentView = Anchor.currentView
        if activateConstraints {
            Anchor.currentView = self
        }
        let descriptor = descriptor()
        descriptor.addSubviews(to: self)
        if activateConstraints {
            Anchor.activatePendingConstraints(forView: self)
            if currentView != nil {
                Anchor.currentView = currentView
            }
        }
    }
    
    public func addSubviews(to view: UIView) {
        guard view != self else { return }
        if let stackView = view as? UIStackView {
            stackView.addArrangedSubview(self)
        } else {
            view.addSubview(self)
        }
    }
}

private func addSubviews(descriptor: Any, view: UIView) {
    switch descriptor {
    case let aView as UIView:
        aView.addSubviews(to: view)
    case let array as [Any]:
        array.addSubviews(to: view)
    case let hierarchy as ViewHierarchy:
        hierarchy.addSubviews(to: view)
    default:
        return assertionFailure()
    }
}


