//
//  ShotSystem.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 13/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit

class ShotSystem: FrameUpdateProtocol {
    
    
    var frameDidUpdate: ((CFTimeInterval, SKScene) -> Void)?
    var parentRotation: CGFloat?
    
    private weak var motherShip: Ship?
    private weak var baseNode: SKSpriteNode?
    private weak var parentScene: SKScene?
    private var timeSinceLastBulletShoot: CFTimeInterval = 0
    private var activated = false
    
    func prepareShot(for baseNode: SKSpriteNode,
                     motherShip: Ship?,
                     parentScene: SKScene,
                     bulletTrackList: [BulletTrack]) {
        self.baseNode = baseNode
        self.motherShip = motherShip
        frameDidUpdate = {[weak self] (timeSinceLastUpdate, scene) in
            guard let `self` = self else {return}
            if !self.activated {return}
            self.timeSinceLastBulletShoot += timeSinceLastUpdate
            if self.timeSinceLastBulletShoot > bulletReloadTime {
                self.timeSinceLastBulletShoot = 0
                bulletTrackList.forEach({ (bulletTrack) in
                    let mainShipPosition = motherShip?.shipNode.position ?? .zero
                    self.autoShoot(parentScene: scene,
                                   range: scene.size.height,
                                   from: bulletTrack,
                                   from: mainShipPosition,
                                   parentRotation: self.parentRotation)
                })
            }
        }
    }
    
    func activate(_ state: Bool) {
        activated = state
    }
    
     private func autoShoot(parentScene: SKNode ,
                   range: CGFloat,
                   from bulletTrack: BulletTrack,
                   from mainShipPosition: CGPoint,
                   parentRotation: CGFloat?) {
        
        guard let bullet = AmmoManager.shared.magazine.first else {return}
        guard let baseNode = baseNode else {return}
        
        AmmoManager.shared.magazine.removeFirst()
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.texture!.size())
        bullet.physicsBody?.categoryBitMask = Constants.Collision.playerBulletHitCategory
        bullet.physicsBody?.contactTestBitMask = Constants.Collision.enemyHitCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.anchorPoint = CGPoint(x: 0.5, y: 0.3)
        bullet.xScale = 1.5
        bullet.yScale = 2.0
        if let parentRotation = parentRotation {
            bullet.zRotation = parentRotation
        } else {
            bullet.zRotation = bulletTrack.rotation
        }
        bullet.position = mainShipPosition + baseNode.position + baseNode.convertPosition(from: bulletTrack.startPoint) + CGPoint(x: -tan(bullet.zRotation) * 50, y: 50)
        bullet.zPosition = Constants.zPosition.playerWeapon
        parentScene.addChild(bullet)
        let vector = CGVector(dx: -tan(bullet.zRotation) * range, dy: range)
        let shootAction = SKAction.move(by: vector, duration: bulletTravelDuration)
        let scaleAction = SKAction.scaleX(to: 3.0, y: 8.0, duration: bulletTravelDuration)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([shootAction, removeAction])
        bullet.run(scaleAction)
        bullet.run(sequence) {
            bullet.setScale(1.0)
            AmmoManager.shared.magazine.append(bullet)
        }
    }

}
