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

enum AnchorType {
    case bottomBound(superView: UIView, cardHandleHeight: CGFloat), upperBound(superView: UIView)
    
    var yPosition: CGFloat {
        switch self {
        case let .bottomBound(superView, cardHandleHeight):
            return superView.frame.height - (superView.safeAreaInsets.bottom + cardHandleHeight)
        case let .upperBound(superView):
            return superView.safeAreaInsets.top
        }
    }
    
    var cardState: FloatingCardState {
        switch self {
        case .upperBound(_): return .fullScreen
        default: return .moving
        }
    }
    
    var anchorViewPercentage: CGFloat {
        switch self {
        case .bottomBound(_, _): return 0.2
        case .upperBound(_): return 0.6
        }
    }
}

class FloatingCardViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet var cardHandleArea: UIView!
    @IBOutlet var horizontalLine: HorizontalLineRoundedCorners!
    @IBOutlet var dismissButton: UIButton!
    
    // MARK: Properties
    private var containedController: UIViewController
    private var visualEffectView: UIVisualEffectView = .init(effect: UIBlurEffect(style: .dark))

    // layout configuration
    private var cardHeight: CGFloat = 300
    private let cardHandlerAreaHeight: CGFloat = 30
    private let defaultOriginY: CGFloat = 300
    private var isCardVisible: Bool = false
    private var topAnchorPercentage: CGFloat = 0.6
    private var lowerAnchorPercentage: CGFloat = 0.2
    private var fullScreenPercentage: CGFloat = 0.9
    
    // States used only to avoid checking for animations all time
    private var previousState: FloatingCardState = .moving
    private var currentState: FloatingCardState = .moving
    
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
        configureView(to: .moving)
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
    
    func configureView(to state: FloatingCardState, animated: Bool = false) {
        previousState = currentState
        currentState = state
        let shouldAnimate = (previousState != currentState) || animated
        UIView.animate(withDuration: shouldAnimate ? 0.4 : 0, delay: 0, options: .curveEaseOut) { [weak self] in
            guard let self = self else { return }
            switch state {
            case .moving:
                self.horizontalLine.alpha = 1
                self.dismissButton.alpha = 0
            case .fullScreen:
                self.horizontalLine.alpha = 0
                self.dismissButton.alpha = 1
            }
        }
    }
    
    func configureGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapCard(recognizer:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanCard(recognizer:)))
        cardHandleArea.addGestureRecognizer(tapGesture)
        cardHandleArea.addGestureRecognizer(panGesture)
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
    }
    
    func moveTo(anchor: AnchorType) {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseIn) { [weak self] in
            guard let self = self else { return }
            self.view.frame.origin = .init(x: self.view.frame.origin.x, y: anchor.yPosition)
            self.configureView(to: anchor.cardState)
        }
    }
    
    //MARK: Card gesture handlers
    @objc func dismissTapped() {
        if let superView = parent?.view {
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: .curveEaseOut) { [weak self] in
                guard let self = self  else { return }
                self.view.frame.origin = .init(x: self.view.frame.origin.x, y: superView.frame.maxY - self.cardHandlerAreaHeight/3)
                self.visualEffectView.alpha = 0
                self.configureView(to: .moving)
            } completion: { [weak self] _ in
                self?.remove()
            }
        }
    }
    
    @objc func handleTapCard(recognizer: UITapGestureRecognizer) {
        guard let superView = parent?.view else { return }
        moveTo(anchor: .upperBound(superView: superView))
    }
    
    @objc func handlePanCard(recognizer: UIPanGestureRecognizer) {
        if let superView = parent?.view {
            let translation = recognizer.translation(in: self.view)
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
                
                // Configure layout
                configureView(to: (percentage > fullScreenPercentage) ? .fullScreen : .moving, animated: true)
                
            case .ended:
                // When ended, check if is over certain position and anchor it with animation
                var anchor: AnchorType? = nil
                anchor = percentage > topAnchorPercentage ? .upperBound(superView: superView) : anchor
                anchor = percentage < lowerAnchorPercentage ? .bottomBound(superView: superView, cardHandleHeight: cardHandlerAreaHeight) : anchor
                if let anchor = anchor {
                    moveTo(anchor: anchor)
                }

            case .cancelled:
                fallthrough
            default:
                break
            }

            // Reset gesture speed
            recognizer.setTranslation(.zero, in: self.view)
        }
    }
}
