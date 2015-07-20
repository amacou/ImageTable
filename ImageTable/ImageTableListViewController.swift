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

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.tableView.reloadData()
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return ImageTableManager.defaultManager.allNames().count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("ImageTableCell") as! UITableViewCell
    cell.textLabel!.text = ImageTableManager.defaultManager.allNames()[indexPath.row].stringByDeletingPathExtension

    var gesture = UILongPressGestureRecognizer(target: self, action: "showLongPressMenu:")
    cell.addGestureRecognizer(gesture)
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let name = ImageTableManager.defaultManager.allNames()[indexPath.row]
    if let imageTable = ImageTableManager.defaultManager.find(name) {
      self.show(imageTable)
    }
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
          var imageTable = ImageTableManager.defaultManager.create("\(textField.text).realm")
          if let imageTable = imageTable {
            self.show(imageTable)
          }
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
  
  func showLongPressMenu(gesture:UILongPressGestureRecognizer) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "複製", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let cell = gesture.view as? UITableViewCell {
        var indexPath = self.tableView.indexPathForCell(cell)
        var name = ImageTableManager.defaultManager.allNames()[indexPath!.row]
        ImageTableManager.defaultManager.copy(name)
        self.tableView.reloadData()
      }
    })
    alert.addAction(UIAlertAction(title: "削除", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let cell = gesture.view as? UITableViewCell {
        var indexPath = self.tableView.indexPathForCell(cell)
        var name = ImageTableManager.defaultManager.allNames()[indexPath!.row]
        ImageTableManager.defaultManager.delete(name)
        self.tableView.reloadData()
      }
    })
    alert.addAction(UIAlertAction(title: "名前を変更", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let cell = gesture.view as? UITableViewCell {
        var indexPath = self.tableView.indexPathForCell(cell)
        var name = ImageTableManager.defaultManager.allNames()[indexPath!.row]
        self.rename(name)
      }
      })
    

    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  func rename(imageTableName:String)
  {
    let alert = UIAlertController(title: "タイトル", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
      println(textField.text)
      textField.text = imageTableName.stringByDeletingPathExtension
    }
    alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "変更", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let textField = alert.textFields?.first as! UITextField! {
        if !textField.text.isEmpty {
          ImageTableManager.defaultManager.rename(imageTableName, to:"\(textField.text).realm")
          self.tableView.reloadData()
        }
      }
      })
    
    self.presentViewController(alert, animated: true, completion: nil)
  }

}
