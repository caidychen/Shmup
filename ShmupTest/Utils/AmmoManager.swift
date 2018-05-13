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

class WeaponSystemManager {
    static let shared = WeaponSystemManager()
    
    let bulletTrackList: [BulletTrack] = [
        BulletTrack(startPoint: NormalisedPoint(x: 0, y: 1), rotation: 0),
        BulletTrack(startPoint: NormalisedPoint(x: -0.8, y: 0.8), rotation: CGFloat.pi / 64),
        BulletTrack(startPoint: NormalisedPoint(x: 0.8, y: 0.8), rotation: -CGFloat.pi / 64),
        BulletTrack(startPoint: NormalisedPoint(x: -1.4, y: 0.6), rotation: CGFloat.pi / 32),
        BulletTrack(startPoint: NormalisedPoint(x: 1.4, y: 0.6), rotation: -CGFloat.pi / 32)
    ]
    
    var linkPositionFocused: [NormalisedPoint] = [
        NormalisedPoint(x: 4, y: 0),
        NormalisedPoint(x: 7, y: 0),
        NormalisedPoint(x: 10, y: -1),
        NormalisedPoint(x: -4, y: 0),
        NormalisedPoint(x: -7, y: 0),
        NormalisedPoint(x: -10, y: -1)
    ]
    var linkPositionUnfocused: [NormalisedPoint] = [
        NormalisedPoint(x: 2.5, y: 0),
        NormalisedPoint(x: 3.5, y: -2),
        NormalisedPoint(x: 4.5, y: -1),
        NormalisedPoint(x: -2.5, y: 0),
        NormalisedPoint(x: -3.5, y: -2),
        NormalisedPoint(x: -4.5, y: -1)
    ]
    
    var wingmanAngle: [CGFloat] = [
        -CGFloat.pi/16,
       -CGFloat.pi/10,
       -CGFloat.pi/6,
       CGFloat.pi/16,
       CGFloat.pi/10,
       CGFloat.pi/6
    ]
    
}
