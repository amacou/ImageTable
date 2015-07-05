//
//  ImageTableViewController.swift
//  ImageTable
//
//  Created by amacou on 2015/07/05.
//  Copyright (c) 2015年 amacou. All rights reserved.
//

import UIKit
import RealmSwift

enum ImageAppendMode {
  case header
  case body
  case footer
}

class ImageTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  var imageTable:ImageTable!
  var imageAppendMode = ImageAppendMode.body
  
  @IBOutlet var tableView:UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.imageTable.cells.count
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if let image = self.imageTable.headerImage {
      var scale = self.view.frame.size.width / image.size.width
      
      return image.size.height * scale
    }
    
    return 0
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var image = self.imageTable.cells[indexPath.row].backgroundImage
    var originalSize = image.size
    var scale = self.view.frame.size.width / originalSize.width

    return originalSize.height * scale
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if let image = self.imageTable.footerImage {
      var scale = self.view.frame.size.width / image.size.width
      
      return image.size.height * scale
    }
    
    return 0
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let image = self.imageTable.headerImage {
      return UIImageView(image: image)
    }
    return nil
  }
  
  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    if let image = self.imageTable.footerImage {
      return UIImageView(image: image)
    }
    return nil
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("ImageCell") as! ImageTableViewCell
    cell.cellImageView.image = self.imageTable.cells[indexPath.row].backgroundImage
    return cell
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == UITableViewCellEditingStyle.Delete {
      var realm = Realm()
      realm.write {
        self.imageTable.cells.removeAtIndex(indexPath.row)
      }
      self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }
  }
  
  @IBAction func showMenu() {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: nil))

    alert.addAction(UIAlertAction(title: "画面一覧に戻る", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.dismissViewControllerAnimated(true, completion: nil)
    })
    
    if self.imageTable.headerImage != nil {
      alert.addAction(UIAlertAction(title: "ヘッダーを削除", style: UIAlertActionStyle.Destructive) { (action) -> Void in
        Realm().write {
          self.imageTable.headerImage = nil;
        }
        self.tableView.reloadData()
      })
    } else {
      alert.addAction(UIAlertAction(title: "ヘッダーを追加", style: UIAlertActionStyle.Default) { (action) -> Void in
        self.imageAppendMode = ImageAppendMode.header
        self.addImage()
      })
    }
    
    if self.imageTable.footerImage != nil {
      alert.addAction(UIAlertAction(title: "フッターを削除", style: UIAlertActionStyle.Destructive) { (action) -> Void in
        Realm().write {
          self.imageTable.footerImage = nil
        }
        self.tableView.reloadData()
      })
    } else {
      alert.addAction(UIAlertAction(title: "フッターを追加", style: UIAlertActionStyle.Default) { (action) -> Void in
        self.imageAppendMode = ImageAppendMode.footer
        self.addImage()
      })
    }

    alert.addAction(UIAlertAction(title: "画面に要素を追加", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.imageAppendMode = ImageAppendMode.body
      self.addImage()
    })
    
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  @IBAction func addImage()
  {
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    imagePickerController.delegate = self
    self.presentViewController(imagePickerController, animated: true, completion: nil)
  }

  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    var obj: AnyObject?  = info[UIImagePickerControllerOriginalImage]

    var realm = Realm()

    realm.write {
      if let image = obj as! UIImage! {
        switch self.imageAppendMode {
        case ImageAppendMode.header:
          self.imageTable.headerImage = image
        case ImageAppendMode.footer:
          self.imageTable.footerImage = image
        case ImageAppendMode.body:
          let imageTableCell = ImageTableCell()
          imageTableCell.backgroundImage = image
          self.imageTable.cells.append(imageTableCell)
        }
      }
    }
    
    picker.dismissViewControllerAnimated(true, completion: nil)
    self.tableView.reloadData()
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController)
  {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
}
