//
//  AppDelegate.swift
//  ImageList
//
//  Created by Nochnoy Anton on 27/08/2019.
//  Copyright © 2019 nochnoy. All rights reserved.
//

import UIKit

class ImageViewer: UIViewController {
  public let id: Int

  init(with data: ImageViewerData) {
    self.id = data.id
    super.init(nibName: nil, bundle: nil)

    let image = data.image ?? UIImage(named: "image_notUp.png")
    self.imageView = UIImageView(image: image)
    self.view.backgroundColor = .white
    self.title = data.date ?? "Unknown"
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func update(image: UIImage?, date: String?) {
    self.imageView?.image = image
    self.title = date
    self.view.setNeedsDisplay()
  }
    
  override func viewWillLayoutSubviews() {
    self.view.addSubview(self.imageView!)
    imageView?.contentMode = .scaleAspectFit
    imageView?.frame = self.view.bounds
  }

  private var imageView: UIImageView?
}

struct ImageViewerData {
    let id: Int
    let image: UIImage?
    let date: String?
    
    init(id: Int, image: UIImage?, date: String?) {
        self.id = id
        self.image = image
        self.date = date
    }
}
