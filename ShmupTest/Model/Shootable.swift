//
//  Shootable.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 5/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit
import SceneKit


struct BulletTrack {
    var startPoint: NormalisedPoint
    var rotation: CGFloat
}

protocol Shootable {
    var shipNode: SKSpriteNode {get}
    var bulletTrackList: [BulletTrack] {get}
    var frameDidUpdate: ((CFTimeInterval, SKScene) -> Void)? {get}
    func shoot(parentNode: SKNode ,
               range: CGFloat,
               from bulletTrack: BulletTrack,
               from mainShipPosition: CGPoint,
               parentRotation: CGFloat?)
}

extension Shootable {
    
    func shoot(parentNode: SKNode ,
               range: CGFloat,
               from bulletTrack: BulletTrack,
               from mainShipPosition: CGPoint,
               parentRotation: CGFloat?) {
        guard let bullet = AmmoManager.shared.magazine.first else {return}
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
        bullet.position = mainShipPosition + shipNode.position + shipNode.convertPosition(from: bulletTrack.startPoint) + CGPoint(x: -tan(bullet.zRotation) * 50, y: 50)
        bullet.zPosition = Constants.zPosition.playerWeapon
        parentNode.addChild(bullet)
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
