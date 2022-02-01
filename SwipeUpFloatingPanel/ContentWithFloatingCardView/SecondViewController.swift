//
//  SecondViewController.swift
//  SwipeUpFloatingPanel
//
//  Created by Giovanne Bressam on 30/01/22.
//

import UIKit

class SecondViewController: UIViewController {
    var cardViewController: FloatingCardViewController?
    
    // MARK: Functions
    func setupCardView() {
        cardViewController = FloatingCardViewController()
        cardViewController!.configureTo(self)
        cardViewController!.addTo(self)
    }

    @IBAction func addFloatingPanelTapped(_ sender: UIButton) {
        addFloatingPanel()
    }
    
}

extension SecondViewController: CardContainable {
    typealias viewController = ContentViewController
    var handleHeight: CGFloat {
        30
    }
    
    var cardDefaultY: CGFloat {
        300
    }
    
    func contentViewController(for panel: FloatingCardViewController) -> ContentViewController {
        return ContentViewController()
    }
    
    func addFloatingPanel() {
        if cardViewController != nil {
            cardViewController!.remove()
            cardViewController = nil
        }
        self.setupCardView()
    }
}

@nonobjc extension UIViewController {
    func addChildController(_ child: UIViewController, to controller: UIViewController, frame: CGRect? = nil) {
        controller.addChild(child)

        if let frame = frame {
            child.view.frame = frame
        }

        controller.view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
