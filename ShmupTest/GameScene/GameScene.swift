//
//  GameScene.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 5/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: BaseGameScene {
    
    var focusModeDidToggle: (() -> Void)!
    private let ship = Ship.shared
    
    
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        loadShip()
        loadEnemy()
        
        didUpdateWIthTimeSinceLastUpdate = {[weak self] time, scene in
            guard let `self` = self else {return}
            self.ship.frameDidUpdate?(time, scene)
            
            
        }
    }
    
    func loadEnemy() {
        let enemy = EWKEnemy(imageNamed: "Spaceship.jpg")
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = Constants.Collision.enemyHitCategory
        enemy.physicsBody?.collisionBitMask = 0
        enemy.position = CGPoint(x: size.width / 2, y: size.height - 180)
        addChild(enemy)
    }
    
    func loadShip() {
        focusModeDidToggle = {[weak self] in
            guard let `self` = self else {return}
            self.ship.focusMode = !self.ship.focusMode
        }
        ship.shipNode.position = CGPoint(x: size.width / 2, y: ship.shipNode.size.height * 1.25)
        ship.shipNode.zPosition = Constants.zPosition.player
        addChild(ship.shipNode)
        ship.prepare(parentScene: self)
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        ship.shipNode.position = ship.shipNode.position + touchMovedDelta
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        if firstBody.categoryBitMask == Constants.Collision.enemyHitCategory && secondBody.categoryBitMask == Constants.Collision.playerBulletHitCategory {
            let playerBullet = secondBody.node as! SKSpriteNode
            playerBullet.removeAllActions()
            playerBullet.removeFromParent()
            playerBullet.setScale(1.0)
            AmmoManager.shared.magazine.append(playerBullet)
        }
    }
}

