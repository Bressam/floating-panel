//
//  SecondViewController.swift
//  SwipeUpFloatingPanel
//
//  Created by Giovanne Bressam on 30/01/22.
//

import UIKit

class SecondViewController: UIViewController, CardContaibable {
    // CardContainable
    typealias viewController = ContentViewController
    var handleHeight: CGFloat = 30
    var cardDefaultY: CGFloat = 300
    var contentViewController: ContentViewController!
    var cardViewController: FloatingCardViewController!
    

    // MARK: Functions
    func setupCardView() {
        // content view
        contentViewController = ContentViewController()
        
        //Create card
        cardViewController = FloatingCardViewController(containedController: contentViewController, cardHeight: self.view.frame.height)
        
        // add to current view
        let cardY: CGFloat = self.view.bounds.height - (view.safeAreaInsets.bottom + handleHeight + cardDefaultY)
        let cardDefaultRect: CGRect = .init(x: 0,
                                                y: cardY,
                                                width: self.view.bounds.width,
                                                height: self.view.bounds.height)
        add(cardViewController, frame:  cardDefaultRect)
        
        // configure it to moving state
        cardViewController.configureView(to: .moving)
    }
    
    
    
    @IBAction func addFloatingPanelTapped(_ sender: UIButton) {
        if cardViewController != nil {
            cardViewController.remove()
            cardViewController = nil
        }
        self.setupCardView()
    }
    
}

@nonobjc extension UIViewController {
    func add(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)

        if let frame = frame {
            child.view.frame = frame
        }

        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
