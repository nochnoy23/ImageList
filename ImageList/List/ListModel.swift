//
//  ListModel.swift
//  ImageList
//
//  Created by Anton  on 29/08/2019.
//  Copyright © 2019 nochnoy. All rights reserved.
//

import CoreData
import Foundation
import UIKit

protocol Model: class {
  func getValue(for id: Int) -> ShowImageData?
}

class ListProvider: Model {
  public weak var presenter: Presenter?

  /**
   Получение данных из CoreData
   - Parameter id: Уникальный индетификатор.
   - Returns: Данные для отображения на экране.
   - Функция проверяет, были ли ранее загружены данные,
   если да - то считывает и возращает данные,
   если нет - вызывает функцию загрузки json с данными о картике.
   */
  public func getValue(for id: Int) -> ShowImageData? {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
    let context = appDelegate.persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<ImageCoreData> = ImageCoreData.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %d", id)

    guard
      let data = try? context.fetch(fetchRequest),
      let currentData = data.first else {
        
      self.loadJson(for: id, completion: downloadImage)
      return nil
    }

    return ShowImageData(for: currentData)
  }

  /**
   Получение данных из сети.
   - Parameter id: Уникальный индетификатор.
   - Parameter completion: Замыкание, вызываемое после успешного парса скаченных данных,
   на вход которого приходят эти самые данные.
   - Функция вызывает скачивание данных, затем происходит декодирование полученных данных.
   При успешном итоге вызывается completion. В функции проверяется loadingDataArray на наличие
   запущенных скачиваний. В случае неудачного скачивания или декодирования данных,
   удаляется id скачивания для возможности повторного вызова скачивания.
   */
  private func loadJson(for id: Int, completion: @escaping (PhotoInfo) -> Void) {
    if self.loadingDataArray.contains(where: { $0 == id }) { return }

    let path = String(format: "https://jsonplaceholder.typicode.com/photos?id=%d", id)
    guard let url = URL(string: path) else { return }

    let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
      guard let data = data,
        error == nil else {
            
        self?.loadingDataArray.removeItem(for: id)
        return
      }

      let decoder = JSONDecoder()
      do {
        if let model = (try decoder.decode([PhotoInfo].self, from: data)).first {
          completion(model)
        }
      } catch {
        self?.loadingDataArray.removeItem(for: id)
        print("Error = \(error.localizedDescription)")
      }
    }

    self.loadingDataArray.append(id)
    task.resume()
  }

  /**
   Скачивания изображения.
   - Parameter data: Данные, получения из json.
   - Функция вызывает скачивание изображения.
   При успешном скачивании вызывается сохранение data и скаченного изображения в CoreData.
   При неудачном - удаляется id скачивания для возможности повторного вызова скачивания.
   */
  private func downloadImage(for data: PhotoInfo) {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      do {
        guard let image = UIImage(data: try Data(contentsOf: data.url)) else { return }
        self?.save(for: data, with: image, completion: self?.presenter?.update ?? { _ in })
      } catch {
        self?.loadingDataArray.removeItem(for: data.id)
        print("Error = \(error.localizedDescription)")
      }
    }
  }

  /**
   Сохранение данных в CoreData
   - Parameter data: Данные, получения из json.
   - Parameter image: Скаченное изображение.
   - Parameter completion: Замыкание, вызываемое после успешного сохранения данных.
   - Функция сохраняет скаченные данные в CoreData.
   При успешном и неуспешном сохранении данных происходит удаление id скачивания
   для уменьшения элементов массива/возможности повторного вызова скачивания.
   */
  private func save(for data: PhotoInfo, with image: UIImage, completion: @escaping (Int) -> Void) {
    DispatchQueue.main.async { [weak self] in
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
      let context = appDelegate.persistentContainer.viewContext

      guard let entity = NSEntityDescription.entity(forEntityName: "ImageCoreData", in: context),
        let imageCoreDataObject = NSManagedObject(entity: entity, insertInto: context) as? ImageCoreData,
        let imageData = image.pngData() as NSData? else {
        self?.loadingDataArray.removeItem(for: data.id)
        return
      }

      imageCoreDataObject.id = Int64(data.id)
      imageCoreDataObject.title = data.title
      imageCoreDataObject.date = NSDate()
      imageCoreDataObject.image = imageData

      do {
        try context.save()
        completion(data.id)
      } catch {
        print("Error = \(error.localizedDescription)")
      }
      self?.loadingDataArray.removeItem(for: data.id)
    }
  }

  /**
   Массив, предназначенный для хранения id действующих скачиваний.
   Необходим для того, чтобы проверять было ли раньше вызвано скачивание.
   */
  private var loadingDataArray: [Int] = []
}

struct ShowImageData {
  let id: Int
  let title: String?
  let image: UIImage?
  let date: String?

  init(for data: ImageCoreData) {
    self.id = Int(data.id)
    self.title = data.title?.count ?? 0 > 30
      ? data.title?.substring(for: 30)
      : data.title

    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"

    let dateData = data.date as Date?
    self.date = data.date as Date? == nil
      ? nil
      : formatter.string(from: dateData!)

    let imageData = data.image as Data?
    self.image = imageData == nil
      ? nil
      : UIImage(data: imageData!)
  }
}

private struct PhotoInfo: Codable {
  let id: Int
  let url: URL
  let title: String

  enum CodingKeys: String, CodingKey {
    case id
    case url
    case title
  }
}
