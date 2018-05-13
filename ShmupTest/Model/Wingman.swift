//
//  Wingman.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 5/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit
import SceneKit

class Wingman: FrameUpdateProtocol {
    
    let shipNode = SKSpriteNode(imageNamed: "wingman.png")
    var frameDidUpdate: ((CFTimeInterval, SKScene) -> Void)?
    var targetPosition: CGPoint?{
        didSet {
            if oldValue == targetPosition {return}
            if let targetPosition = targetPosition {
                shootHitSparkEmitter.position = targetPosition
                DispatchQueue.main.asyncAfter(deadline:.now() + 0.1, execute: {
                    self.shootHitSparkEmitter.particleBirthRate = 200
                })
            } else {
                DispatchQueue.main.asyncAfter(deadline:.now() + 0.1, execute: {
                    self.shootHitSparkEmitter.particleBirthRate = 0.0
                })
            }
        }
    }
    
    
    weak var parentScene: SKScene?
    weak private var mainShip: Ship?
    private let shotSytem = ShotSystem()
    private var bulletTrackList: [BulletTrack]
    private var shootHitSparkEmitter: SKEmitterNode!
    private var shootSparkNode = SKSpriteNode()
    var thrustEmitter: SKEmitterNode!
    
    init(bulletTrackList: [BulletTrack], from mainShip: Ship, parentScene: SKScene) {
        self.bulletTrackList = bulletTrackList
        self.mainShip = mainShip
        self.parentScene = parentScene
        
    }
    
    func activate(_ state: Bool) {
        shotSytem.activate(state)
    }
    
    func prepare() {
        shotSytem.prepareShot(for: self.shipNode, motherShip: mainShip!, parentScene: parentScene!, bulletTrackList: bulletTrackList)
        frameDidUpdate = {[weak self] (timeSinceLastUpdate, scene) in
            guard let `self` = self else {return}
            self.shotSytem.parentRotation = self.shipNode.zRotation
            if self.targetPosition == nil && self.mainShip!.focusMode {
                self.shootSparkNode.alpha = 0.0
                return
            }
            self.shootSparkNode.alpha = 1.0
            self.shotSytem.frameDidUpdate?(timeSinceLastUpdate, scene)
        }
    }
    
    func preparingSparkAnimation() {
        let firstSparkFrameTexture = TextureManager.shared.shootSparkFrames[0]
        shootSparkNode = SKSpriteNode(texture: firstSparkFrameTexture)
        shootSparkNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        shootSparkNode.position = CGPoint(x: 0, y: 0)
        shipNode.addChild(shootSparkNode)
        shootSparkNode.alpha = 0.9
        prepareThrustEmitter()
        animateSparkAnimation()
        prepareFocusShootHitSpark()
    }
    
    private func animateSparkAnimation() {
        shootSparkNode.run(SKAction.repeatForever(
            SKAction.animate(with: TextureManager.shared.shootSparkFrames, timePerFrame: 0.05, resize: false, restore: true)
        ))
    }
    
    private func prepareFocusShootHitSpark() {
        shootHitSparkEmitter = TextureManager.shared.getEmitter(named: "ShootHitSpark")
        shootHitSparkEmitter.targetNode = parentScene
        parentScene?.addChild(shootHitSparkEmitter)
        shootHitSparkEmitter.particleBirthRate = 0.0
    }
    
    private func prepareThrustEmitter() {
        thrustEmitter = TextureManager.shared.getEmitter(named: "WingmanThrust")
        thrustEmitter.targetNode = parentScene
        shipNode.addChild(thrustEmitter)
    }
}
