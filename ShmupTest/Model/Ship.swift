//
//  Ship.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 5/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit
import SceneKit

class Ship: FrameUpdateProtocol {
    static let shared = Ship()
    var frameDidUpdate: ((CFTimeInterval, SKScene) -> Void)?
    var focusMode = false {
        didSet{
            toggleFocusMode()
        }
    }
    var targetPosition: CGPoint? {
        didSet {
            wingmanSqard.targetPosition = targetPosition
        }
    }
    // Base node without texture
    let shipNode = SKSpriteNode(
        color: .clear,
        size: CGSize(
            width: TextureManager.shared.shipTexture.size().width,
            height: TextureManager.shared.shipTexture.size().height
        )
    )
    
    private let textureNode = SKSpriteNode(
        texture: TextureManager.shared.shipTexture
    )

    private let shotSytem = ShotSystem()
    private let laserSystem = LaserSystem()
    private let wingmanSqard = WingmanSquard()
    
    private var parentSceneSize: CGSize = .zero
    weak private var parentScene: SKScene?
    
    
    func prepare(parentScene: SKScene) {
        self.parentScene = parentScene
        parentSceneSize = parentScene.size
        shipNode.addChild(textureNode)
        textureNode.zPosition = Constants.zPosition.player
        setupFrameUpdateBlock()
        initWeaponSystem()
    }
    
    private func initWeaponSystem() {
        AmmoManager.shared.loadAmmo(capacity: 200)
        shotSytem.prepareShot(for: shipNode, motherShip: nil, parentScene: parentScene!, bulletTrackList: WeaponSystemManager.shared.bulletTrackList)
        wingmanSqard.prepareWingman(for: self, parentScene: parentScene!)
        laserSystem.prepareLaser(for: self, parentScene: parentScene!)
        shotSytem.activate(true)
        laserSystem.activate(false)
        wingmanSqard.activate(true)
    }
    
    private func setupFrameUpdateBlock() {
        frameDidUpdate = {[weak self] (timeSinceLastUpdate, scene) in
            guard let `self` = self else {return}
            
            self.wingmanSqard.frameDidUpdate?(timeSinceLastUpdate, scene)
            self.laserSystem.frameDidUpdate?(timeSinceLastUpdate, scene)
            self.shotSytem.frameDidUpdate?(timeSinceLastUpdate, scene)
        }
    }
    
    private func toggleFocusMode() {
        shotSytem.activate(!focusMode)
        laserSystem.activate(focusMode)
    }
    
}


