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
        cardViewController = FloatingCardViewController(containedController: contentView, cardHeight: self.view.frame.height)
        cardViewController.view.frame = CGRect(x: 0, y: self.view.bounds.height - (view.safeAreaInsets.bottom + 30 + 300), width: self.view.bounds.width, height: self.view.bounds.height)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        cardViewController.didMove(toParent: self)
        cardViewController.view.clipsToBounds = true
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
