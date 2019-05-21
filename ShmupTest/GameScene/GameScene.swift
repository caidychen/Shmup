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
        
        for _ in 0..<5 {
            let action = self.repeatForever(interval: 0.1) {[weak self] in
                self?.loadEnemy()
            }
            self.run(action, withKey: "Enemy")
        }

        loadEnemy()
//        setupDummy()
        didUpdateWIthTimeSinceLastUpdate = {[weak self] time, scene in
            guard let `self` = self else {return}
            self.ship.frameDidUpdate?(time, scene)
            if let allBasicEnemies = (self.children.filter{$0.name?.contains("Basic") ?? false }) as? [EWKEnemy] {
                allBasicEnemies.forEach({ (enemy) in
                    enemy.frameDidUpdate?(time, scene)
                })
            }
            
        }
    }

    func loadEnemy() {
        let enemy = EWKEnemy(imageNamed: "Spaceship.jpg")
        enemy.name = "Basic"
        enemy.parentScene = self
        enemy.vitality = 50
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = Constants.Collision.enemyHitCategory
        enemy.physicsBody?.collisionBitMask = 0
        enemy.position = CGPoint(x: CGFloat(arc4random_uniform(UInt32(size.width))), y: size.height + enemy.size.height/2)
        enemy.delayCollisionHit()
        enemy.follow(target: ship.shipNode, speed: 700)
        addChild(enemy)
    }
    
    func setupDummy() {
        let enemy = EWKEnemy(imageNamed: "Spaceship.jpg")
        enemy.size = CGSize(width: 400, height: 400)
        enemy.name = "Basic"
        enemy.parentScene = self
        enemy.invulnerable = true
        enemy.vitality = 50
        enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
        enemy.physicsBody?.categoryBitMask = Constants.Collision.enemyHitCategory
        enemy.physicsBody?.collisionBitMask = 0
        enemy.position = CGPoint(x: size.width / 2, y: size.height - 400)
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
            guard let enemy = firstBody.node as? EWKEnemy else {return}
            enemy.takeHit(damage: ship.shotPower)
            guard let playerBullet = secondBody.node as? SKSpriteNode else {return}
            playerBullet.removeAllActions()
            playerBullet.removeFromParent()
     
        } else if firstBody.categoryBitMask == Constants.Collision.playerBulletHitCategory && secondBody.categoryBitMask == Constants.Collision.enemyHitCategory {
  
            guard let enemy = secondBody.node as? EWKEnemy else {return}
            enemy.takeHit(damage: ship.shotPower)
            guard let playerBullet = firstBody.node as? SKSpriteNode else {return}
            playerBullet.removeAllActions()
            playerBullet.removeFromParent()
    
        }
    }
}

