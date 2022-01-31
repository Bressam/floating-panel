//
//  FloatingCardViewController.swift
//  SwipeUpFloatingPanel
//
//  Created by Giovanne Bressam on 18/12/21.
//

import UIKit

enum FloatingCardState {
    case moving, fullScreen
}

class FloatingCardViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet var cardHandleArea: UIView!
    @IBOutlet var horizontalLine: HorizontalLineRoundedCorners!
    @IBOutlet var dismissButton: UIButton!
    
    // MARK: Properties
    var containedController: UIViewController
    var visualEffectView: UIVisualEffectView = .init(effect: UIBlurEffect(style: .dark))

    // layout configuration
    var cardHeight: CGFloat = 300
    let cardHandlerAreaHeight: CGFloat = 30
    let defaultOriginY: CGFloat = 300
    var isCardVisible: Bool = false
    
    init(containedController: UIViewController, cardHeight: CGFloat) {
        self.containedController = containedController
        self.cardHeight = cardHeight
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        configureBlur()
        configureContentView()
        configureGestures()
    }

    func configureContentView() {
        addChild(containedController)
        containedController.view.frame = .init(x: 0, y: 0 + cardHandlerAreaHeight, width: view.frame.width, height: view.frame.height - cardHandlerAreaHeight)
        view.addSubview(containedController.view)
        containedController.didMove(toParent: self)
    }
    
    func configureBlur() {
        if let superView = parent?.view {
            // Add blur under floating panel on parent
            visualEffectView.frame = superView.bounds
            visualEffectView.isHidden = true
            superView.addSubview(visualEffectView)
            
            // Bring floating panel in front of blur
            superView.bringSubviewToFront(self.view)
        }
    }
    
    func configureView(to state: FloatingCardState) {
        switch state {
        case .moving:
            horizontalLine.isHidden = false
            dismissButton.isHidden = true
        case .fullScreen:
            horizontalLine.isHidden = true
            dismissButton.isHidden = false
        }
    }
    
    func configureGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapCard(recognizer:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanCard(recognizer:)))
        cardHandleArea.addGestureRecognizer(tapGesture)
        cardHandleArea.addGestureRecognizer(panGesture)
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
    }
    
    //MARK: Card gesture handlers
    @objc func dismissTapped() {
        if let superView = parent?.view {
            let lowerBound = superView.frame.height - (superView.safeAreaInsets.bottom + cardHandlerAreaHeight)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: .curveEaseOut) { [weak self] in
                guard let self = self  else { return }
                self.view.frame.origin = .init(x: self.view.frame.origin.x, y: lowerBound)
                self.visualEffectView.alpha = 0
                self.configureView(to: .moving)
                self.remove()
            }
        }
    }
    
    @objc func handleTapCard(recognizer: UITapGestureRecognizer) {
        print("Tap")
//        self.animateTransitionIfNeeded(nextState: self.nextState, duration: 0.9)
    }
    
    @objc func handlePanCard(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        
        if let superView = parent?.view {
            // Get the percentagem of current position related to current view's top
            let percentage = (superView.frame.height - view.frame.origin.y)/superView.frame.height
            visualEffectView.isHidden = (percentage < 0.6)

            // Check if moving view is inside safearea to avoid going out of it
            var newOriginY = view.frame.origin.y + translation.y
            let higherBound = superView.safeAreaInsets.top
            let lowerBound = superView.frame.height - (superView.safeAreaInsets.bottom + cardHandlerAreaHeight)
            newOriginY = newOriginY < higherBound ? higherBound : newOriginY
            newOriginY = newOriginY > lowerBound ? lowerBound : newOriginY

            switch recognizer.state {
            case .changed:
                // Move anywhere when changed
                view.frame.origin = .init(x: view.frame.origin.x, y: newOriginY)

                // blur background
                visualEffectView.alpha = percentage
            case .ended:
                // When ended, check if is over certain position and anchor it with animation
                newOriginY = percentage > 0.6 ? higherBound : newOriginY
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseIn) { [weak self] in
                    guard let self = self else { return }
                    self.view.frame.origin = .init(x: self.view.frame.origin.x, y: newOriginY)
                } completion: { [weak self] _ in
                    guard let self = self else { return }
                    if percentage > 0.6 {
                        self.visualEffectView.isHidden = true
                        self.configureView(to: .fullScreen)
                    }
                }

            case .cancelled:
                fallthrough
            default:
                break
            }
            // Reset gesture speed
            recognizer.setTranslation(.zero, in: self.view)
        }
//
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
}
