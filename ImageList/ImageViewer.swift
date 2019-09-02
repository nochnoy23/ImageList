//
//  AppDelegate.swift
//  ImageList
//
//  Created by Nochnoy Anton on 27/08/2019.
//  Copyright © 2019 nochnoy. All rights reserved.
//

import UIKit

class ImageViewer: UIViewController {
  init(with data: ShowImageData?, id: Int) {
    self.id = id
    super.init(nibName: nil, bundle: nil)

    let image = data?.image ?? UIImage(named: "image_notUp.png")
    self.imageView = UIImageView(image: image)
    self.view.backgroundColor = .white
    self.title = data?.date ?? "Unknown"
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewWillLayoutSubviews() {
    self.view.addSubview(self.imageView!)
    imageView?.contentMode = .scaleAspectFit
    imageView?.frame = self.view.bounds
  }

  public var imageView: UIImageView?
  public let id: Int
}
