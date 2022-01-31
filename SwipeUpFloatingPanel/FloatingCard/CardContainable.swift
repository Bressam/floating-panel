//
//  CardContainable.swift
//  SwipeUpFloatingPanel
//
//  Created by Giovanne Bressam on 31/01/22.
//

import UIKit

// Views that want to show a card must implement this protocol
protocol CardContaibable {
    associatedtype viewController: UIViewController
    var handleHeight: CGFloat { get set }
    var contentViewController: viewController! { get set }
    var cardDefaultY: CGFloat { get set }
    var cardViewController: FloatingCardViewController! { get set }
}
