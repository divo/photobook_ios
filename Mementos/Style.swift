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
    return Color(uiColor: UIColor(red: 90, green: 85, blue: 239, alpha: 1))
  }
  
  static func secondaryColor() -> Color {
    return Color(uiColor: UIColor(hue: 0.66, saturation: 0.94, brightness: 0.81, alpha: 1.0))
  }
}
