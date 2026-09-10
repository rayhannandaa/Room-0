//
//  GameViewController.swift
//  Room 0
//
//  Created by Rayhan Nanda on 06/09/26.
//

import UIKit
import SwiftUI

class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainMenuView = MainMenuView()
        let hostingController = UIHostingController(rootView: mainMenuView)
        
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
