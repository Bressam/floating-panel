//
//  MainViewController.swift
//  SwipeUpFloatingPanel
//
//  Created by Giovanne Bressam on 18/12/21.
//

import UIKit

class MainViewController: UIViewController {

    enum CardState {
        case collapsed
        case expanded
    }
    
    var cardViewController: FloatingCardViewController!
    var visualEffectView: UIVisualEffectView!
    
    let cardHeight: CGFloat = 300
    let cardHandlerAreaHeight: CGFloat = 30
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
        self.setupCardView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func setupCardView() {
        //Setup blur
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.bounds
        self.view.addSubview(visualEffectView)
        
        //Create card
        cardViewController = FloatingCardViewController(nibName: "FloatingCardViewController", bundle: nil)
        cardViewController.view.frame = CGRect(x: 0, y: (self.view.bounds.height-self.cardHandlerAreaHeight), width: self.view.bounds.width, height: self.cardHeight)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        cardViewController.view.clipsToBounds = true
        
        //Create gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapCard(recognizer:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanCard(recognizer:)))
        self.cardViewController.cardHandleArea.addGestureRecognizer(tapGesture)
        self.cardViewController.cardHandleArea.addGestureRecognizer(panGesture)
    }
    
    //MARK: Card gesture handlers
    @objc func handleTapCard(recognizer: UITapGestureRecognizer) {
        self.animateTransitionIfNeeded(nextState: self.nextState, duration: 0.9)
    }
    
    @objc func handlePanCard(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            self.startInteractiveAnimation(state: self.nextState, duration: 0.9)
        case .changed:
            //check direction
            let translation = recognizer.translation(in: self.cardViewController.cardHandleArea)
            var fractionCompleted = translation.y / self.cardHeight
            fractionCompleted = isCardVisible ? fractionCompleted : -fractionCompleted
            self.updateInteractiveAnimation(fractionCompleted: fractionCompleted)
        case .ended:
            self.continueInteractiveAnimation()
        default:
            break
        }

    }
    
    //MARK: Card animations
    func animateTransitionIfNeeded(nextState: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            // Frame position
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) { [weak self] in
                guard let self = self else { return }
                switch nextState {
                case .collapsed:
                    // collapse
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandlerAreaHeight
                case .expanded:
                    // expand
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                }
            }
            frameAnimator.addCompletion { [weak self] _ in
                guard let self = self else { return }
                self.isCardVisible.toggle()
                self.runningAnimations.removeAll()
            }
            
            // Corner Radius
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) { [weak self] in
                guard let self = self else { return }
                switch nextState {
                case .collapsed:
                    self.cardViewController.view.layer.cornerRadius = 0
                case .expanded:
                    self.cardViewController.view.layer.cornerRadius = 12
                }
            }
            
            // Blur
            let blurEffectAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) { [weak self] in
                guard let self = self else { return }
                switch nextState {
                case .collapsed:
                    self.visualEffectView.effect = nil
                case .expanded:
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                }
            }
            frameAnimator.startAnimation()
            cornerRadiusAnimator.startAnimation()
            blurEffectAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            runningAnimations.append(cornerRadiusAnimator)
            runningAnimations.append(blurEffectAnimator)
        }
    }
    
    func startInteractiveAnimation(state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            //run
            animateTransitionIfNeeded(nextState: state, duration: duration)
        }
        // pause animations
        for animation in runningAnimations {
            animation.pauseAnimation()
            animationProgressWhenInterrupted = animation.fractionComplete
        }
    }
    
    func updateInteractiveAnimation(fractionCompleted: CGFloat) {
        for animation in runningAnimations {
            animation.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
        
    }
    
    func continueInteractiveAnimation() {
        for animation in runningAnimations {
            // 0  uses remaining time on animation
            animation.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
}
