//
//  Style.swift
//  Mementos
//
//  Created by Steven Diviney on 15/06/2023.
//

import Foundation
import SwiftUI
import UIKit

struct Style {
  // TODO: Color values from reails app don't look right here, must be some other effects applied
  static func primaryColor() -> Color {
    return Color(red: 90 / 255, green: 85 / 255, blue: 239 / 255)
  }
  
  static func secondaryColor() -> Color {
    return Color(red: 61 / 255, green: 164 / 255, blue: 252 / 255)
  }
  
  static func primary9() -> Color {
    return Color(red: 230 / 255, green: 230 / 255, blue: 255 / 255)
  }
  
  static func primary6() -> Color {
    return Color(red: 112 / 255, green: 105 / 255, blue: 250 / 255)
  }
}
