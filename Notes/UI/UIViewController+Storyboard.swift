import Foundation
import UIKit

protocol StoryboardInitializable {

    static var storyboardName: String { get }
    static var storyboardBundle: Bundle? { get }
    static var storyboardIdentifier: String { get }
    static func makeFromStoryboard() -> Self
}

extension StoryboardInitializable where Self: UIViewController {

    static var storyboardName: String {
        return "Main"
    }

    static var storyboardBundle: Bundle? {
        return nil
    }

    static var storyboardIdentifier: String {
        return String(describing: self)
    }

    static func makeFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)
        if let viewController = storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as? Self {
            return viewController
        } else {
            fatalError("Could not instantiate \(self) from Storyboard (\(storyboardName)) with identifier '\(storyboardIdentifier)'")
        }
    }
}
