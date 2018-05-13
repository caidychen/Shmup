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
    var magazine: [SKSpriteNode] = [] {
        didSet{
            if magazine.count <= 100 {
                loadAmmo(capacity: 2000)
            }
        }
    }

    func loadAmmo(capacity: Int) {
        var magazine: [SKSpriteNode] = []
        for _ in 0..<capacity {
            magazine.append(SKSpriteNode(imageNamed: "bullet.png"))
        }
        self.magazine = magazine
    }
    
}


