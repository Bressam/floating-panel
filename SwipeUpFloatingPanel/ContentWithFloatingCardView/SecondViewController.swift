//
//  SecondViewController.swift
//  SwipeUpFloatingPanel
//
//  Created by Giovanne Bressam on 30/01/22.
//

import UIKit

class SecondViewController: UIViewController {
    
    var cardViewController: FloatingCardViewController!
    
    func setupCardView() {
        // content view
        let contentView = ContentViewController()
        
        //Create card
        let handleHeight: CGFloat = 30
        cardViewController = FloatingCardViewController(containedController: contentView, cardHeight: self.view.frame.height)
        
        // add to current view
        let cardDefaultY: CGFloat = 300
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
