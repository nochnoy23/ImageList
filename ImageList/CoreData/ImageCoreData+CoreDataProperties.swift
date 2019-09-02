//
//  ImageCoreData+CoreDataProperties.swift
//  ImageList
//
//  Created by Anton  on 28/08/2019.
//  Copyright © 2019 nochnoy. All rights reserved.
//
//

import CoreData
import Foundation

extension ImageCoreData {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageCoreData> {
    return NSFetchRequest<ImageCoreData>(entityName: "ImageCoreData")
  }

  @NSManaged public var id: Int64
  @NSManaged public var image: NSData?
  @NSManaged public var date: NSDate?
  @NSManaged public var title: String?
}
