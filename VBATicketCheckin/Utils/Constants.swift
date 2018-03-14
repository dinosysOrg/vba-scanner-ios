//
//  Constants.swift
//  VBATicketCheckin
//
//  Created by Bui Minh Duc on 12/18/17.
//  Copyright © 2017 Dinosys. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Beautified print
func log(_ message: String?, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
    let fileName = file.components(separatedBy: Constants.SLASH).last
    let unknownFile = "Unknown file"
    print("--log info [\(Date())]-- [\(fileName ?? unknownFile)], [\(function)], [\(line), \(column)]: \(message ?? Constants.EMPTY_STRING)")
}

struct Constants {
    static let USER_DEFAULTS = UserDefaults.standard
    static let DEVICE_SIZE = UIScreen.main.bounds.size
    static let CURRENT_DEVICE = UIDevice.current.userInterfaceIdiom
    static let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate
    static let STORYBOARD = UIStoryboard(name: "Main", bundle:nil)
    
    // MARK: - API components
    static let BASE_URL = "http://dev.bsp.vn:8081/training-movie"
    
    // MARK: - String
    static let ZERO_STRING = "0"
    static let EMPTY_STRING = ""
    static let HASH = "#"
    static let COMMA = ","
    static let PERIOD = "."
    static let DASH = "-"
    static let SLASH = "/"
    static let QUESTION_MARK = "?"
    static let EQUAL = "="
    
    // MARK: - Default values
    static let DEFAULT_STRING_VALUE = "--"
    static let DEFAULT_NUMBER_VALUE = 0
    static let DEFAULT_POPUPVIEW_WIDTH_RATIO: CGFloat = 0.69
    
    // MARK: - Font
    static let FONTNAME_REGULAR = "Lato-Regular"
    static let FONTNAME_BOLD = "Lato-Bold"
    static let FONTNAME_BLACK = "Lato-Black"
    
    static let FONTSIZE_XS: CGFloat = 10.0
    static let FONTSIZE_S: CGFloat = 12.0
    static let FONTSIZE_M: CGFloat = 14.0
    static let FONTSIZE_L: CGFloat = 15.0
    static let FONTSIZE_XL: CGFloat = 18.0
    static let FONTSIZE_XXL: CGFloat = 24.0
    static let FONTSIZE_XXXL: CGFloat = 32.0
    static let FONTSIZE_XXXXL: CGFloat = 36.0
    static let FONTSIZE_XXXXXL: CGFloat = 64.0
    
    // MARK: - Colors
    static let COLOR_MAIN = "#06A2E7"
    static let COLOR_VIEW_BACKGROUND = "#CDD7DE"
    static let COLOR_VIEW_BACKGROUND_TWO = "#F5F5F5"
    static let COLOR_WHITE = "#FFFFFF"
    static let COLOR_COOLGREY = "#AAB3BB"
    static let COLOR_BLACK = "#333333"
    static let COLOR_SQUASH = "#F7941E"
    static let COLOR_PUMPKIN_ORANGE = "#F77D1E"
    static let COLOR_WHEAT = "#FBC38E"
    static let COLOR_DARK_BLUE_GREY_TWO = "#07111D"
    static let COLOR_REDDISH = "#D33030"
    static let COLOR_DARK_BLUE_GREY = "#1A314E"
    static let COLOR_GUNMETAL = "#4D5762"
    static let COLOR_DUSTY_ORANGE = "#EF7223"
    static let COLOR_TOMATO = "#EF4D23"
    static let COLOR_MEDIUM_GREEN = "#30944B"
    static let COLOR_DARKISH_GREEN = "#1D5C2E"
    static let COLOR_COBALT = "#205894"
    static let COLOR_LIGHT_NAVY = "#124479"
    static let COLOR_REDDISH_ORANGE = "#F75B1A"
    static let COLOR_FADED_RED = "#D13138"
    static let COLOR_BLUE_BERRY = "#4D297F"
    static let COLOR_BLUE_BERRY_TWO = "#653B9B"
    static let COLOR_PINKISH_RED = "#EE1B23"
    static let COLOR_ROUGE = "#BF1E2B"
    static let COLOR_BLUE_BERRY_THREE = "#4D4BB0"
    static let COLOR_BLUE_BERRY_FOUR = "#34338D"
    static let COLOR_GRAPE = "#712F7D"
    static let COLOR_GRAPE_TWO = "#5C2464"
    static let COLOR_WATERMELON = "#FC5056"
    static let COLOR_LIPSTICK = "#E12A30"
    static let COLOR_TOPAZ = "#19B1D7"
    static let COLOR_NICE_BLUE = "#1291B0"
    static let COLOR_SEAWEED_GREEN = "#36B073"
    static let COLOR_DARKSEA_GREEN = "#169854"
    static let COLOR_YELLOW_TAN = "#FFAE2D"
    static let COLOR_MAIZE = "#F78D1E"
    static let COLOR_BLUE_GREY = "#9EB0BF"
    static let COLOR_BLUE_GREY_TWO = "#97ACBE"
    static let COLOR_DARK_BLUE_GREY_THREE = "#0F1F33"
    static let COLOR_TWILIGHT_BLUE = "#0F4372"
    static let COLOR_TWILIGHT_BLUE_TWO = "#093C69"
    static let COLOR_PEACOCK_BLUE = "#005E9D"
    
    static let COLOR_ALPHA_VIEW: CGFloat = 0.75
    static let COLOR_ALPHA_VIEW_SCAN: CGFloat = 0.65
    
    // MARK: - View Controller Identifiers
    static let VIEWCONTROLLER_IDENTIFIER_TAB_BAR = "TabBarController"
    static let VIEWCONTROLLER_IDENTIFIER_LOGIN = "LoginViewController"
    static let VIEWCONTROLLER_IDENTIFIER_MATCHES = "MatchesViewController"
    static let VIEWCONTROLLER_IDENTIFIER_PAYMENT = "PaymentViewController"
    static let VIEWCONTROLLER_IDENTIFIER_MERCHANDISE = "MerchandiseViewController"
    static let VIEWCONTROLLER_IDENTIFIER_SCAN_TICKET = "ScanTicketViewController"
    static let VIEWCONTROLLER_IDENTIFIER_TICKET_PAYMENT = "TicketPaymentDetailViewController"
    static let VIEWCONTROLLER_IDENTIFIER_USER_QRCODE_SCANNING = "UserQRCodeScanningViewController"
    
    // MARK: - Date & Time
}
