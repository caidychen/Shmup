//
//  ExplosionAnimator.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 13/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit

class ExplosionAnimator {
    static func playExplosion(on parentNode: SKScene, position: CGPoint, scale: CGFloat) {
        let animationNode = SKSpriteNode(texture: TextureManager.shared.explosionPop[0])
        animationNode.xScale = scale
        animationNode.yScale = scale
        parentNode.addChild(animationNode)
        animationNode.position = position
        animationNode.run(SKAction.animate(with: TextureManager.shared.explosionPop, timePerFrame: 0.05)) {
            animationNode.removeFromParent()
        }
    }
}
