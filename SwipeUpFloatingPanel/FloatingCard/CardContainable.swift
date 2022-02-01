//
//  CardContainable.swift
//  SwipeUpFloatingPanel
//
//  Created by Giovanne Bressam on 31/01/22.
//

import UIKit

// Views that want to show a card must implement this protocol
protocol CardContainable {
    associatedtype viewController: UIViewController
    var handleHeight: CGFloat { get }
    var cardDefaultY: CGFloat { get }    
    func contentViewController(for panel: FloatingCardViewController) -> viewController
    func addFloatingPanel()
}
