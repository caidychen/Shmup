//
//  Constants.swift
//  ShmupTest
//
//  Created by CHEN KAIDI on 6/5/18.
//  Copyright © 2018 CHEN KAIDI. All rights reserved.
//

import UIKit



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


