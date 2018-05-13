//
//  Wingman.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 5/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit
import SceneKit

class Wingman: Shootable {
    var bulletTrackList: [BulletTrack]
    var shipNode = SKSpriteNode(imageNamed: "wingman.png")
    var frameDidUpdate: ((CFTimeInterval, SKScene) -> Void)?
    var shootHitSparkEmitter: SKEmitterNode!
    weak var parentScene: SKScene?
    var targetPosition: CGPoint?{
        didSet {
            if oldValue == targetPosition {return}
            if let targetPosition = targetPosition {
                shootHitSparkEmitter.position = targetPosition
                DispatchQueue.main.asyncAfter(deadline:.now() + 0.3, execute: {
                    self.shootHitSparkEmitter.particleBirthRate = 20
                })
            } else {
                shootHitSparkEmitter.particleBirthRate = 0.0
            }
        }
    }
    private var shootSparkNode = SKSpriteNode()
    
    weak private var mainShip: Ship?
    private var timeSinceLastBulletShoot: CFTimeInterval = 0
    
    
    init(bulletTrackList: [BulletTrack], from mainShip: Ship) {
        self.bulletTrackList = bulletTrackList
        self.mainShip = mainShip
    }
    
    func prepareShoot() {
        frameDidUpdate = {[weak self] (timeSinceLastUpdate, scene) in
            guard let `self` = self else {return}
            guard let mainShip = self.mainShip else {return}
            self.timeSinceLastBulletShoot += timeSinceLastUpdate
            if self.timeSinceLastBulletShoot > bulletReloadTime {
                self.timeSinceLastBulletShoot = 0
                if mainShip.focusMode && self.targetPosition == nil {
                    return
                }
                for bulletTrack in self.bulletTrackList {
                    self.shoot(parentNode: scene, range: scene.size.height, from: bulletTrack, from: mainShip.shipNode.position, parentRotation: self.shipNode.zRotation)
                }
                
            }
        }
    }
    
    func preparingSparkAnimation() {
        let firstSparkFrameTexture = TextureManager.shared.shootSparkFrames[0]
        shootSparkNode = SKSpriteNode(texture: firstSparkFrameTexture)
        shootSparkNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        shootSparkNode.position = CGPoint(x: 0, y: 0)
        shipNode.addChild(shootSparkNode)
        shootSparkNode.alpha = 0.9
        animateSparkAnimation()
        prepareFocusShootHitSpark()
    }
    
    func animateSparkAnimation() {
        shootSparkNode.run(SKAction.repeatForever(
            SKAction.animate(with: TextureManager.shared.shootSparkFrames, timePerFrame: 0.05, resize: false, restore: true)
        ))
    }
    
    func prepareFocusShootHitSpark() {
        let laserHitSparkPath = Bundle.main.path(forResource: "ShootHitSpark", ofType: "sks")!
        shootHitSparkEmitter = NSKeyedUnarchiver.unarchiveObject(withFile: laserHitSparkPath)
            as! SKEmitterNode
        shootHitSparkEmitter.targetNode = parentScene
        parentScene?.addChild(shootHitSparkEmitter)
        shootHitSparkEmitter.particleBirthRate = 0.0
    }
}
