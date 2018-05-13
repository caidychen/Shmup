//
//  WeaponSystemManager.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 13/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import SpriteKit

struct BulletTrack {
    var startPoint: NormalisedPoint
    var rotation: CGFloat
}


class WeaponSystemManager {
    static let shared = WeaponSystemManager()
    
    let shotPowerUnfocused: CGFloat = 20
    let shotPowerFocused: CGFloat = 1   // Multiplied by 6 wingmen
    let laserPower: CGFloat = 50
    
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
