//
//  AmmoManager.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 6/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit

struct PlayerBullet {
    var id: Int
    var bulletNode: SKSpriteNode
}

class AmmoManager {
    static let shared = AmmoManager()
    var magazine: [SKSpriteNode] = []

    func loadAmmo(capacity: Int) {
        magazine.removeAll()
        for _ in 0..<capacity {
            magazine.append(SKSpriteNode(imageNamed: "bullet.png"))
        }
    }
    
}


