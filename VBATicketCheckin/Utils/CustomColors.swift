//
//  CustomColors.swift
//  VBATicketCheckin
//
//  Created by ngoclam on 3/6/18.
//  Copyright © 2018 Dinosys. All rights reserved.
//

import Foundation
import UIKit
import Hue

extension UIColor {
    static var main: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_MAIN)
        }
    }
    
    static var viewBackground: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_VIEW_BACKGROUND)
        }
    }
    
    static var viewBackgroundTwo: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_VIEW_BACKGROUND_TWO)
        }
    }
    
    static var coolGrey: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_COOLGREY)
        }
    }
    
    static var black: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_BLACK)
        }
    }
    
    static var squash: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_SQUASH)
        }
    }
    
    static var pumpkinOrange: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_PUMPKIN_ORANGE)
        }
    }
    
    static var wheat: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_WHEAT)
        }
    }
    
    static var darkBlueGreyTwo: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_DARK_BLUE_GREY_TWO)
        }
    }
    
    static var reddish: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_REDDISH)
        }
    }
    
    static var darkBlueGrey: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_DARK_BLUE_GREY)
        }
    }
    
    static var gunmetal: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_GUNMETAL)
        }
    }
    
    static var dustyOrange: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_DUSTY_ORANGE)
        }
    }
    
    static var tomato: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_TOMATO)
        }
    }
    
    static var mediumGreen: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_MEDIUM_GREEN)
        }
    }
    
    static var darkishGreen: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_DARKISH_GREEN)
        }
    }
    
    static var cobalt: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_COBALT)
        }
    }
    
    static var lightNavy: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_LIGHT_NAVY)
        }
    }
    
    static var reddishOrange: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_REDDISH_ORANGE)
        }
    }
    
    static var fadedRed: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_FADED_RED)
        }
    }
    
    static var blueberry: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_BLUE_BERRY)
        }
    }
    
    static var blueberryTwo: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_BLUE_BERRY_TWO)
        }
    }
    
    static var pinkishRed: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_PINKISH_RED)
        }
    }
    
    static var rouge: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_ROUGE)
        }
    }
    
    static var blueberryThree: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_BLUE_BERRY_THREE)
        }
    }
    
    static var blueberryFour: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_BLUE_BERRY_FOUR)
        }
    }
    
    static var grape: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_GRAPE)
        }
    }
    
    static var grapeTwo: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_GRAPE_TWO)
        }
    }
    
    static var watermelon: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_WATERMELON)
        }
    }
    
    static var lipstick: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_LIPSTICK)
        }
    }
    
    static var topaz: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_TOPAZ)
        }
    }
    
    static var niceBlue: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_NICE_BLUE)
        }
    }
    
    static var seaweedGreen: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_SEAWEED_GREEN)
        }
    }
    
    static var darkSeaGreen: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_DARKSEA_GREEN)
        }
    }
    
    static var yellowTan: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_YELLOW_TAN)
        }
    }
    
    static var maize: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_MAIZE)
        }
    }
    
    static var blueGrey: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_BLUE_GREY)
        }
    }
    
    static var blueGreyTwo: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_BLUE_GREY_TWO)
        }
    }
    
    static var darkBlueGreyThree: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_DARK_BLUE_GREY_THREE)
        }
    }
    
    static var twilightBlue: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_TWILIGHT_BLUE)
        }
    }
    
    static var twilightBlueTwo: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_TWILIGHT_BLUE_TWO)
        }
    }
    
    static var peacockBlue: UIColor {
        get {
            return UIColor(hex: Constants.COLOR_PEACOCK_BLUE)
        }
    }
    
    // MARK: - Color with alpha
    static func color(_ color: UIColor, alpha: CGFloat) -> UIColor {
        return color.withAlphaComponent(alpha)
    }
}
