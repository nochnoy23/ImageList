//
//  ViewController.swift
//  ImageList
//
//  Created by Nochnoy Anton on 27/08/2019.
//  Copyright © 2019 nochnoy. All rights reserved.
//

import UIKit

protocol ListView: class {
  func updateCell(for row: Int)
}

class TableView: UIViewController {
  public var presenter: Presenter?

  init() {
    self.tableView = UITableView(frame: .zero, style: .plain)

    super.init(nibName: nil, bundle: nil)

    self.tableView.dataSource = self
    self.tableView.delegate = self

    self.tableView.register(CustomCell.self, forCellReuseIdentifier: "cell")
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.estimatedRowHeight = 0
    self.tableView.estimatedSectionFooterHeight = 0
    self.tableView.estimatedSectionHeaderHeight = 0

    self.view.backgroundColor = .white

    self.tableView.separatorStyle = .none

    self.title = "List"
  }

  override func viewWillLayoutSubviews() {
    self.view.add(subview: self.tableView, with: [.bottom, .top, .leading, .trailing])
  }

  /**
  Счетчик количества ячеек в таблицы.
  Имеет возможность динамически увеличиваться в зависимости от скрола.
  */
  private var count = 20
  private let tableView: UITableView
}

extension TableView: ListView {
  func updateCell(for row: Int) {
    guard let indexPaths = self.tableView.indexPathsForVisibleRows,
      indexPaths.contains(where: { $0.row == row }) == true else { return }

    DispatchQueue.main.async {
      self.tableView.beginUpdates()
      self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
      self.tableView.endUpdates()
    }
  }
}

extension TableView: UITableViewDataSource {
  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CustomCell
      ?? CustomCell(style: .default, reuseIdentifier: "cell")

    let data = presenter?.getValue(for: indexPath.row)
    cell.showImageView.image = data?.image ?? UIImage(named: "image_notUp.png")
    cell.label.text = data?.title ?? "Image not uploaded"

    return cell
  }
}

extension TableView: UITableViewDelegate {
  /**
   При достижении нижней ячейки происходит добавление 20 новых ячеек.
   */
  func tableView(_ tableView: UITableView, willDisplay _: UITableViewCell, forRowAt indexPath: IndexPath) {
    DispatchQueue.main.async {
      if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
        self.count += 20
        self.tableView.reloadData()
      }
    }
  }

  func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
    return 200
  }

  func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.presenter?.pushView(for: indexPath.row)
  }
}

class CustomCell: UITableViewCell {
  public var showImageView: UIImageView
  public var label: UILabel

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.showImageView = UIImageView(image: nil)
    self.label = UILabel(frame: .zero)

    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none

    let topView = self.getStackView(with: 0.7)
    let bottomView = self.getStackView(with: 0.2)

    NSLayoutConstraint.activate([
      topView.topAnchor.constraint(equalTo: self.topAnchor),
      bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
    ])

    topView.addToCenter(subview: showImageView)
    bottomView.addToCenter(subview: label)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
