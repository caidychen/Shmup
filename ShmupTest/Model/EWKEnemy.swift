//
//  EWKEnemy.swift
//  EnemyWaveKit
//
//  Created by CHEN KAIDI on 12/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit

class EWKEnemy: SKSpriteNode {
   
    var vitality: CGFloat = 0

    func takeHit(damage: CGFloat) {
        
    }
    
    private func die() {
        
    }
    
    func moveToAndStop(targetPosition: CGPoint, speed: CGFloat) -> SKAction {
        let distance = self.position.distanceTo(targetPosition)
        return SKAction.move(to: targetPosition, duration: TimeInterval(distance/speed))
    }
    
    func wait(forDuration: TimeInterval) -> SKAction {
        return SKAction.wait(forDuration: forDuration)
    }
}
