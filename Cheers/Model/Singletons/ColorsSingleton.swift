//
//  ColorsSingleton.swift
//  Cheers
//
//  Created by Will on 4/4/18.
//  Copyright © 2018 University of San Diego. All rights reserved.
//

import Foundation
import ChameleonFramework

class ColorsSingleton {
    static let shared = ColorsSingleton()
    
    let lightColors = [
        FlatRed(), FlatOrange(), FlatYellow(), FlatMagenta(), FlatTeal(), FlatSkyBlue(),
        FlatMint(), FlatForestGreen(), FlatPurple(), FlatPlum(), FlatWatermelon(), FlatLime(),
        FlatPink(), FlatMaroon(), FlatCoffee(), FlatPowderBlue(), FlatBlue()
    ]
    
    let darkColors = [
        FlatRedDark(), FlatOrangeDark(), FlatYellowDark(), FlatMagentaDark(), FlatTealDark(), FlatSkyBlueDark(),
        FlatMintDark(), FlatForestGreenDark(), FlatPurpleDark(), FlatPlumDark(), FlatWatermelonDark(), FlatLimeDark(),
        FlatPinkDark(), FlatMaroonDark(), FlatCoffeeDark(), FlatPowderBlueDark(), FlatBlueDark()
    ]
    
    // dictates what colors can't be paired together b/c they don't look good
    let exclusions: [(Int, Int)] = [
        (0, 13),    // red + maroon
        (13, 1),
        (5, 16),    // sky blue + blue
        (16, 5),
        (5, 15),    // sky blue + powder blue
        (15, 5),
        (15, 16),   // powder blue + blue
        (16, 15),
        (3, 8),     // magenta + purple
        (8, 3),
        (9, 14),    // plum + coffee
        (14, 9)
    ]
    
    func getColorPair() -> [UIColor] {
        let index0 = Int(arc4random_uniform(17))
        var index1 = Int(arc4random_uniform(17))
        repeat {
            if index0 == index1 {
                index1 = Int(arc4random_uniform(17))
            }
            if self.exclusions.contains(where: { (arg0) -> Bool in
                let (test0, test1) = arg0
                return test0 == index0 && test1 == index1
            }) {
                index1 = index0
            }
        } while index0 == index1
        
        let color0 = self.lightColors[index0]
        let color1 = self.darkColors[index1]
        
        return [color0, color1]
    }
}
