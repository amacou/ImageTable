//
//  ImageTableListViewController.swift
//  ImageTable
//
//  Created by amacou on 2015/07/05.
//  Copyright (c) 2015年 amacou. All rights reserved.
//

import UIKit
import RealmSwift

class ImageTableListViewController: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let imageTables = Realm().objects(ImageTable)
    return imageTables.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("ImageTableCell") as! UITableViewCell
    cell.textLabel!.text = Realm().objects(ImageTable)[indexPath.row].title
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let imageTable = Realm().objects(ImageTable)[indexPath.row]
    self.show(imageTable)
  }
  
  @IBAction func addButtonClicked()
  {
    let alert = UIAlertController(title: "新しい画面のタイトル", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
      println(textField.text)
    }
    alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "作成", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let textField = alert.textFields?.first as! UITextField! {
        if !textField.text.isEmpty {
          var imageTable = ImageTable()
          imageTable.title = textField.text
          var realm = Realm()
          realm.write {
            realm.add(imageTable)
          }
          self.show(imageTable)
        }
      }
    })
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  
  func show(imageTable:ImageTable) {
    if let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("ImageTableViewController") as? ImageTableViewController {
      viewController.imageTable = imageTable
      self.presentViewController(viewController, animated: true, completion: nil)
    }
  }
}
