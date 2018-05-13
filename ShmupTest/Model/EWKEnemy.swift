//
//  EWKEnemy.swift
//  EnemyWaveKit
//
//  Created by CHEN KAIDI on 12/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit

class EWKEnemy: SKSpriteNode, FrameUpdateProtocol {
    var frameDidUpdate: ((CFTimeInterval, SKScene) -> Void)?
    private var timeSinceLastMove: CFTimeInterval = 0
    private var movement: CGVector?
    private var chasing = false
    weak var parentScene: SKScene?
    weak var target: SKSpriteNode?
    var invulnerable = false
    var didDie: (() -> Void)?
    var vitality: CGFloat = 0
    
    func prepare() {
        delayCollisionHit()
    }
    
    func takeHit(damage: CGFloat) {
        if invulnerable {return}
        vitality -= damage
        if vitality <= 0 {
            die()
        }

    }
    
    private func die() {
        ExplosionAnimator.playExplosion(on: parentScene!, position: self.position, scale: 1.0)
        removeFromParent()
        didDie?()
    }
    
    func delayCollisionHit() {
        invulnerable = true
        self.afterDelay(0.2) {[weak self] in
            self?.invulnerable = false
        }
    }
    
    func moveToAndStop(targetPosition: CGPoint, speed: CGFloat){
        let distance = self.position.distanceTo(targetPosition)
        self.zRotation = CGVector(point: targetPosition - self.position).angle + CGFloat.pi / 2
         run(SKAction.move(to: targetPosition, duration: TimeInterval(distance/speed)))
    }
    
    func wait(forDuration: TimeInterval) -> SKAction {
        return SKAction.wait(forDuration: forDuration)
    }
    
    func follow(target: SKSpriteNode, speed: CGFloat) {
        self.target = target
        chasing = true
        self.movement = CGVector(point: target.position - self.position)
        frameDidUpdate = {[weak self](time, scene) in
            guard let `self` = self else {return}
            self.timeSinceLastMove += time
            if self.timeSinceLastMove > 0.1 {
                self.timeSinceLastMove = 0
                let distance = CGVector(point: target.position - self.position).length()
                if  distance >= self.parentScene!.size.height / 2 && self.chasing {
                    self.movement = CGVector(point: target.position - self.position)
                } else {
                    self.chasing = false
                    print("Stop Chasing")
                }
                self.zRotation = self.movement!.angle + CGFloat.pi / 2
                self.run(SKAction.move(by: self.movement!.normalized() * 50, duration: 0.1))
                if self.position.y - self.size.height/2 < 0 {
                    self.removeFromParent()
                }
            }
        }
        
    }
}
