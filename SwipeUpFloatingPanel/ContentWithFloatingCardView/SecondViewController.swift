//
//  SecondViewController.swift
//  SwipeUpFloatingPanel
//
//  Created by Giovanne Bressam on 30/01/22.
//

import UIKit

class SecondViewController: UIViewController {

    enum CardState {
        case collapsed
        case expanded
    }
    
    var cardViewController: FloatingCardViewController!
    var visualEffectView: UIVisualEffectView!
    
    var cardHeight: CGFloat = 300
    let cardHandlerAreaHeight: CGFloat = 30
    let defaultOriginY: CGFloat = 300
    var isCardVisible: Bool = false
    
    var nextState: CardState {
        return isCardVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardHeight = self.view.frame.height
    }
    
    
    func setupCardView() {
        //Setup blur
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.bounds
        visualEffectView.effect = UIBlurEffect(style: .dark)
        visualEffectView.isHidden = true
        self.view.addSubview(visualEffectView)
        
        //Create card
        cardViewController = FloatingCardViewController(nibName: "FloatingCardViewController", bundle: nil)
        cardViewController.view.frame = CGRect(x: 0, y: self.view.bounds.height - (view.safeAreaInsets.bottom + self.cardHandlerAreaHeight + defaultOriginY), width: self.view.bounds.width, height: self.view.bounds.height)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        cardViewController.view.clipsToBounds = true
        cardViewController.configureView(to: .moving)
        
        //Create gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapCard(recognizer:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanCard(recognizer:)))
        self.cardViewController.cardHandleArea.addGestureRecognizer(tapGesture)
        self.cardViewController.cardHandleArea.addGestureRecognizer(panGesture)
        cardViewController.dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        
        
        let mainVC = ContentViewController(nibName: "ContentViewController", bundle: nil)
        cardViewController.addChild(mainVC)
        mainVC.view.frame = .init(x: 0, y: 0 + cardHandlerAreaHeight, width: cardViewController.view.frame.width, height: cardViewController.view.frame.height - cardHandlerAreaHeight)
        cardViewController.view.addSubview(mainVC.view)
        mainVC.didMove(toParent: cardViewController)
    }
    
    //MARK: Card gesture handlers
    @objc func dismissTapped() {
        let lowerBound = view.frame.height - (view.safeAreaInsets.bottom + cardHandlerAreaHeight)
        if let viewToDrag = cardViewController.view {
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: .curveEaseOut) { [weak self] in
                viewToDrag.frame.origin = .init(x: viewToDrag.frame.origin.x, y: lowerBound)
                self?.visualEffectView.alpha = 0
                self?.cardViewController.configureView(to: .moving)
                self?.cardViewController.remove()
            }
        }
    }
    
    @objc func handleTapCard(recognizer: UITapGestureRecognizer) {
        print("Tap")
//        self.animateTransitionIfNeeded(nextState: self.nextState, duration: 0.9)
    }
    
    @objc func handlePanCard(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        
        if let viewToDrag = cardViewController.view {
            // Get the percentagem of current position related to current view's top
            let percentage = (view.frame.height - viewToDrag.frame.origin.y)/view.frame.height
            visualEffectView.isHidden = (percentage < 0.6)
            
            // Check if moving view is inside safearea to avoid going out of it
            var newOriginY = viewToDrag.frame.origin.y + translation.y
            let higherBound = view.safeAreaInsets.top
            let lowerBound = view.frame.height - (view.safeAreaInsets.bottom + cardHandlerAreaHeight)
            newOriginY = newOriginY < higherBound ? higherBound : newOriginY
            newOriginY = newOriginY > lowerBound ? lowerBound : newOriginY
            
            switch recognizer.state {
            case .changed:
                // Move anywhere when changed
                viewToDrag.frame.origin = .init(x: viewToDrag.frame.origin.x, y: newOriginY)
                
                // blur background
                visualEffectView.alpha = percentage
            case .ended:
                // When ended, check if is over certain position and anchor it with animation
                newOriginY = percentage > 0.6 ? higherBound : newOriginY
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseIn) {
                    viewToDrag.frame.origin = .init(x: viewToDrag.frame.origin.x, y: newOriginY)
                } completion: { [weak self] _ in
                    if percentage > 0.6 {
                        self?.visualEffectView.isHidden = true
                        self?.cardViewController.configureView(to: .fullScreen)
                    }
                }

            case .cancelled:
                fallthrough
            default:
                break
            }
            // Reset gesture speed
            recognizer.setTranslation(.zero, in: viewToDrag)
        }
        
//        if let viewToDrag = cardViewController.view {
//            // Get the percentagem related to current view's top
//            let percentage = (view.frame.height - viewToDrag.frame.origin.y)/view.frame.height
//            visualEffectView.isHidden = (percentage < 0.4)
//
//            // Check if moving view is inside safearea
//            var newOriginY = viewToDrag.frame.origin.y + translation.y
//            let higherBound = view.safeAreaInsets.top
//            let lowerBound = view.frame.height - (view.safeAreaInsets.bottom + cardHandlerAreaHeight)
//            newOriginY = newOriginY < higherBound ? higherBound : newOriginY
//            newOriginY = newOriginY > lowerBound ? lowerBound : newOriginY
//
//            // Check if new position fits next anchor
//            let topAnchor: CGFloat = 200
//            newOriginY = newOriginY < topAnchor ? higherBound : newOriginY
//            viewToDrag.frame.origin = .init(x: viewToDrag.frame.origin.x, y: newOriginY)
//            recognizer.setTranslation(.zero, in: viewToDrag)
//
//
//            // blur background
//            visualEffectView.alpha = percentage
//        }
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
