//
//  extensions.swift
//  ImageList
//
//  Created by Nochnoy Anton on 27/08/2019.
//  Copyright © 2019 nochnoy. All rights reserved.
//

import Foundation
import UIKit

public enum Anchor {
  case leading
  case trailing
  case top
  case bottom
}

public extension UIView {
  func add(subview: UIView, with anchors: [Anchor]) {
    self.addSubview(subview)
    subview.translatesAutoresizingMaskIntoConstraints = false
    for anchor in anchors {
      applyAnchor(anchor: anchor, view: subview)
    }
  }

  func getStackView(with heightMultiplier: CGFloat, sideIndent: CGFloat = 10) -> UIView {
    let view = UIView(frame: .zero)

    self.addSubview(view)
    view.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      view.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: heightMultiplier),
      view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: sideIndent),
      view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -sideIndent)
    ])

    return view
  }

  func addToCenter(subview: UIView) {
    self.addSubview(subview)
    subview.translatesAutoresizingMaskIntoConstraints = false
    subview.contentMode = .scaleAspectFit

    NSLayoutConstraint.activate([
      subview.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      subview.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      subview.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1)
    ])
  }
}

public extension String {
  func substring(for index: Int) -> String {
    return String(self[..<self.index(self.startIndex, offsetBy: index)])
  }
}

public extension Array where Element: Equatable {
  mutating func removeItem(for item: Element) {
    self = self.filter { $0 != item }
  }
}

private func applyAnchor(anchor: Anchor, view: UIView) {
  switch anchor {
  case .leading:
    view.leadingAnchor.constraint(equalTo: view.superview!.safeAreaLayoutGuide.leadingAnchor).isActive = true
  case .trailing:
    view.trailingAnchor.constraint(equalTo: view.superview!.safeAreaLayoutGuide.trailingAnchor).isActive = true
  case .top:
    view.topAnchor.constraint(equalTo: view.superview!.safeAreaLayoutGuide.topAnchor).isActive = true
  case .bottom:
    view.bottomAnchor.constraint(equalTo: view.superview!.safeAreaLayoutGuide.bottomAnchor).isActive = true
  }
}
