//
//  GameViewController.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 5/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    private lazy var focusToggleButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 100, width: 100, height: 100))
        button.setTitle("FOCUS", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return button
    }()
    let scene = GameScene(size: UIScreen.main.bounds.size)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = self.view as! SKView
        skView.isMultipleTouchEnabled = false
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        skView.addSubview(focusToggleButton)
        focusToggleButton.addTarget(self, action: #selector(focusToggleButtonAction), for: .touchUpInside)
    }

    @objc func focusToggleButtonAction() {
        scene.focusModeDidToggle()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
