//
//  Constants.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 6/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import UIKit

let bulletReloadTime: CFTimeInterval = 0.05
let bulletTravelDuration: CFTimeInterval = 0.2
let laserTravelDuration: CFTimeInterval = 0.4
let modeChangeDuration: CFTimeInterval = 0.1

struct Constants {
    struct SpriteName {
        static let lockTarget = "LockTarget"
    }
    
    struct Collision {
        static let playerBulletHitCategory: UInt32 = 1
        static let enemyHitCategory: UInt32 = 2
    }
    
    struct zPosition {
        static let player: CGFloat = 999999
        static let playerWeapon: CGFloat = 900000
    }
}


