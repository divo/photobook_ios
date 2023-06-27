//
//  FloatingButton.swift
//  Mementos
//
//  Created by Steven Diviney on 21/06/2023.
//

import SwiftUI

struct FloatingActionButton<ImageView: View>: ViewModifier {
  let color: Color // background color of the FAB
  let image: ImageView // image shown in the FAB
  let action: () -> Void

  private let size: CGFloat = 60 // size of the FAB circle
  private let margin: CGFloat = 35 // distance from screen edges

  func body(content: Content) -> some View {
    GeometryReader { geo in
      ZStack {
        Color.clear // allows the ZStack to fill the entire screen
        content
        button(geo)
      }
    }
  }

  @ViewBuilder private func button(_ geo: GeometryProxy) -> some View {
    image
      .cornerRadius(10)
      .imageScale(.large)
      .frame(width: size, height: size)
      .shadow(color: .gray, radius: 1, x: 0, y: 1)
      .shadow(color: .gray, radius: 3, x: 0, y: 3)
      .onTapGesture(perform: action)
      .offset(x: 0,
              y: (geo.size.height - size) / 2 - margin)
  }
}

extension View {
  func floatingActionButton<ImageView: View>(
    color: Color,
    image: ImageView,
    action: @escaping () -> Void) -> some View {
    self.modifier(FloatingActionButton(color: color,
                                       image: image,
                                       action: action))
  }
}
