//
//  ListPreseter.swift
//  ImageList
//
//  Created by Anton  on 29/08/2019.
//  Copyright © 2019 nochnoy. All rights reserved.
//

import Foundation
import UIKit

protocol Presenter: class {
  func getValue(for id: Int) -> ShowImageData?
  func update(for id: Int)
  func pushView(for id: Int)
}

class ListPresenter: Presenter {
  init(view: ListView, model: Model) {
    self.view = view
    self.model = model
  }

  func getValue(for id: Int) -> ShowImageData? {
    return self.model.getValue(for: id)
  }

  /**
   Обновляет данные для tableView и ImageViewer
   */
  func update(for id: Int) {
    self.view.updateCell(for: id)
    self.updateImageViewData(for: id)
  }

  func pushView(for id: Int) {
    let data = self.model.getValue(for: id)
    let controller = ImageViewer(with: ImageViewerData(id: id, image: data?.image, date: data?.date))

    DispatchQueue.main.async {
      if let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
        navController.pushViewController(controller, animated: true)
      }
    }
  }

  private func updateImageViewData(for id: Int) {
    DispatchQueue.main.async { [weak self] in
      if let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
        let imageViewer = navController.topViewController as? ImageViewer,
        imageViewer.id == id {
        
        let data = self?.model.getValue(for: id)
        imageViewer.update(image: data?.image, date: data?.date)
      }
    }
  }

  private unowned let view: ListView
  private let model: Model
}
