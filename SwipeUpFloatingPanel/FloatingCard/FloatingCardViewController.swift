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
    @IBOutlet var cardHandleArea: UIView!
    @IBOutlet var horizontalLine: HorizontalLineRoundedCorners!
    @IBOutlet var dismissButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
