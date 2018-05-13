//
//  Ship.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 5/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit
import SceneKit

class Ship: Shootable {
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
            wingmanSqard.updateAllWingmanRotation()
            laserSystem.targetPosition = targetPosition
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
    
    var bulletTrackList = WeaponSystemManager.shared.bulletTrackList
    private let textureNode = SKSpriteNode(texture: TextureManager.shared.shipTexture)

    private let wingmanSqard = WingmanSquard()
    
    private var shootSparkNode = SKSpriteNode()
    private var laserSystem = LaserSystem()
    
    private var timeSinceLastBulletShoot: CFTimeInterval = 0
    private var parentSceneSize: CGSize = .zero
    weak private var parentScene: SKScene?
    
    
    func prepare(parentScene: SKScene) {
        self.parentScene = parentScene
        parentSceneSize = parentScene.size
        AmmoManager.shared.loadAmmo(capacity: 200)
        shipNode.addChild(textureNode)
        textureNode.zPosition = Constants.zPosition.player
        prepareWingman()
        prepareLaser()
        prepareShoot()
        
    }
    
    private func toggleFocusMode() {
        laserSystem.activate(focusMode)
        wingmanSqard.updateAllWingmanRotation()
    }
    
    private func prepareWingman() {
        wingmanSqard.prepareWingman(for: self, parentScene: parentScene!)
    }
    private func prepareLaser() {
        laserSystem.prepareLaser(motherShip: self, parentScene: parentScene!)
    }
    
    private func prepareShoot() {
        frameDidUpdate = {[weak self] (timeSinceLastUpdate, scene) in
            guard let `self` = self else {return}
            self.checkLineOfSight()
            self.wingmanSqard.frameDidUpdate?(timeSinceLastUpdate, scene)
            self.laserSystem.frameDidUpdate?(timeSinceLastUpdate, scene)
            if !self.focusMode {
         
                self.timeSinceLastBulletShoot += timeSinceLastUpdate
                if self.timeSinceLastBulletShoot > bulletReloadTime {
                    self.timeSinceLastBulletShoot = 0
                    for bulletTrack in self.bulletTrackList {
                        self.shoot(parentNode: scene, range: scene.size.height, from: bulletTrack, from: .zero, parentRotation: nil)
                    }
                }
            }
        }
    }
    
    private func isTargetVisibleAtAngle(distance: CGFloat) -> CGPoint? {
        guard let parentScene = parentScene else {return nil}
        let rayStart = shipNode.position
        let rayEnd = CGPoint(x: shipNode.position.x,
                             y: shipNode.position.y + distance)
        var targetPoint: CGPoint? = nil
        
        parentScene.physicsWorld.enumerateBodies(alongRayStart: rayStart, end: rayEnd) { (body, point, vector, _) in
            if body.categoryBitMask == Constants.Collision.enemyHitCategory{
                targetPoint = point
                body.node?.name = Constants.SpriteName.lockTarget
            }
        }
        
        return targetPoint
    }
    
    private func checkLineOfSight() {
        guard let parentScene = parentScene else {return}
        if let targetPoint = isTargetVisibleAtAngle(distance: parentScene.size.height) {
            let range = targetPoint - shipNode.position - CGPoint(x: 0, y: 20)
            laserSystem.targetRange = range.y
            if focusMode {
                targetPosition = parentScene.childNode(withName: Constants.SpriteName.lockTarget)?.position
            }
            print("\(range.y) Line of sight detected")
        } else {
            laserSystem.targetRange = parentScene.size.height
        }
    }
    
}


