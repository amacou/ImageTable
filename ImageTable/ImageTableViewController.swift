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
  case headerObject
  case footerObject
  case bodyObject
}

class ImageTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  var imageTable:ImageTable!
  var imageAppendMode = ImageAppendMode.body
  var objectAppendTarget:AnyObject!
  
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
      var headerView = UIImageView(image: image)
      
      for headerObject in self.imageTable.headerObjects {
        var objectView = ImageTableObjectView(object: headerObject)
        objectView.longPressGesture = UILongPressGestureRecognizer(target: self, action: "showObjectMenu:")
        headerView.addSubview(objectView)
      }
      
      var longpressGesture = UILongPressGestureRecognizer(target: self, action: "showHeaderMenu:")
      headerView.addGestureRecognizer(longpressGesture)
      headerView.userInteractionEnabled = true
      headerView.clipsToBounds = true
      return headerView
    }
    return nil
  }
  
  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    if let image = self.imageTable.footerImage {
      var footerView = UIImageView(image: image)
      for headerObject in self.imageTable.footerObjects {
        var objectView = ImageTableObjectView(object: headerObject)
        objectView.longPressGesture = UILongPressGestureRecognizer(target: self, action: "showObjectMenu:")
        footerView.addSubview(objectView)
      }
      
      var longpressGesture = UILongPressGestureRecognizer(target: self, action: "showFooterMenu:")
      footerView.addGestureRecognizer(longpressGesture)
      footerView.userInteractionEnabled = true
      footerView.clipsToBounds = true
      return footerView
    }
    return nil
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("ImageCell") as! ImageTableViewCell
    var imageTableCell = self.imageTable.cells[indexPath.row]
    
    cell.cellImageView.image = imageTableCell.backgroundImage
    cell.longPresGesture = UILongPressGestureRecognizer(target: self, action: "showCellMenu:")
    
    for cellObject in imageTableCell.objects {
      var objectView = ImageTableObjectView(object: cellObject)
      objectView.longPressGesture = UILongPressGestureRecognizer(target: self, action: "showObjectMenu:")
      cell.cellImageView.addSubview(objectView)
    }
    
    return cell
  }
  
  func showObjectMenu(sender:AnyObject) {
    let action = UIAlertAction(title: "このパーツを削除", style: UIAlertActionStyle.Destructive) { (action) -> Void in
      if let view = sender.view as? ImageTableObjectView {
        view.removeFromSuperview()
        let realm = self.imageTable.realm
        realm?.write {
          realm?.delete(view.object!)
        }
        self.tableView.reloadData()
      }
    }
    
    showMenu(actions: [action])
  }
 
  func showHeaderMenu(sender:AnyObject) {
    let action = UIAlertAction(title: "ヘッダーにパーツを追加", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let view = sender.view {
        self.imageAppendMode = ImageAppendMode.headerObject
        self.objectAppendTarget = self.imageTable
        self.addImage()
      }
    }
    
    showMenu(actions: [action])
  }
  
  func showFooterMenu(sender:AnyObject) {
    let action = UIAlertAction(title: "フッターにパーツを追加", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let view = sender.view {
        self.imageAppendMode = ImageAppendMode.footerObject
        self.objectAppendTarget = self.imageTable
        self.addImage()
      }
    }
    
    showMenu(actions: [action])
  }
  
  @IBAction func showCellMenu(sender:AnyObject) {
    let addObjectAction = UIAlertAction(title: "Viewにパーツを追加", style: UIAlertActionStyle.Default) { (action) -> Void in
      if let view = sender.view {
        self.imageAppendMode = ImageAppendMode.bodyObject
        let indexPath = self.tableView.indexPathForCell(view as! UITableViewCell)
        let cell = self.imageTable.cells[indexPath!.row]
        self.objectAppendTarget = view
        self.addImage()
      }
    }
    
    let deleteCellAction = UIAlertAction(title: "このViewを削除", style: UIAlertActionStyle.Destructive) { (action) -> Void in
      if let view = sender.view {
        let indexPath = self.tableView.indexPathForCell(view as! UITableViewCell)
        let cell = self.imageTable.cells[indexPath!.row]
        let realm = self.imageTable.realm
        realm?.write {
          cell.objects.removeAll()
          realm?.delete(cell)
        }
        self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation:UITableViewRowAnimation.Automatic)
      }
    }
    
    showMenu(actions: [addObjectAction, deleteCellAction])
  }
  
  @IBAction func showTableMenu(sender:AnyObject) {
    self.showMenu()
  }

  func showMenu(actions:[UIAlertAction]? = nil) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: nil))

    alert.addAction(UIAlertAction(title: "画面一覧に戻る", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.dismissViewControllerAnimated(true, completion: nil)
    })
    
    if self.imageTable.headerImage != nil {
      alert.addAction(UIAlertAction(title: "ヘッダーを削除", style: UIAlertActionStyle.Destructive) { (action) -> Void in
        self.imageTable.realm?.write {
          self.imageTable.headerImage = nil;
          self.imageTable.headerObjects.removeAll()
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
        self.imageTable.realm?.write {
          self.imageTable.footerImage = nil
          self.imageTable.footerObjects.removeAll()
        }
        self.tableView.reloadData()
      })
    } else {
      alert.addAction(UIAlertAction(title: "フッターを追加", style: UIAlertActionStyle.Default) { (action) -> Void in
        self.imageAppendMode = ImageAppendMode.footer
        self.addImage()
      })
    }

    alert.addAction(UIAlertAction(title: "Viewを追加", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.imageAppendMode = ImageAppendMode.body
      self.addImage()
    })
    if let actions = actions {
      for action in actions  {
        alert.addAction(action)
      }
    }
    
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

    self.imageTable.realm?.write {
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
          
        case ImageAppendMode.headerObject:
          let object = ImageTableObject()
          object.backgroundImage = image
          let sectionHeight = self.tableView(self.tableView, heightForHeaderInSection:0)
          let sectionWidth = self.tableView.frame.size.width

          object.center = CGPointMake(sectionWidth/2, sectionHeight/2)
          
          var scale:Float = 1
          if image.size.height > image.size.width {
            if sectionHeight < image.size.height {
              scale = (Float(sectionHeight) * 0.8) / Float(image.size.height)
            }
          } else {
            if sectionWidth < image.size.width {
              scale = (Float(sectionWidth) * 0.8) / Float(image.size.width)
            }
          }
          object.scale = scale
          self.imageTable.headerObjects.append(object)
          
        case ImageAppendMode.footerObject:
          let object = ImageTableObject()
          object.backgroundImage = image
          let sectionHeight = self.tableView(self.tableView, heightForFooterInSection:0)
          let sectionWidth = self.tableView.frame.size.width
          
          object.center = CGPointMake(sectionWidth/2, sectionHeight/2)
          
          var scale:Float = 1
          if image.size.height > image.size.width {
            if sectionHeight < image.size.height {
              scale = (Float(sectionHeight) * 0.8) / Float(image.size.height)
            }
          } else {
            if sectionWidth < image.size.width {
              scale = (Float(sectionWidth) * 0.8) / Float(image.size.width)
            }
          }
          object.scale = scale
          self.imageTable.footerObjects.append(object)
        case ImageAppendMode.bodyObject:
          if let cell = self.objectAppendTarget as? UITableViewCell {

            let object = ImageTableObject()
            object.backgroundImage = image

            let indexPath = self.tableView.indexPathForCell(cell)
            let cellHeight = self.tableView(self.tableView, heightForRowAtIndexPath:indexPath!)
            let cellWidth = self.tableView.frame.size.width
            
            object.center = CGPointMake(cellWidth/2, cellHeight/2)
            
            var scale:Float = 1
            if image.size.height > image.size.width {
              if cellHeight < image.size.height {
                scale = (Float(cellHeight) * 0.8) / Float(image.size.height)
              }
            } else {
              if cellWidth < image.size.width {
                scale = (Float(cellWidth) * 0.8) / Float(image.size.width)
              }
            }
            object.scale = scale
            
            let imageTableCell = self.imageTable.cells[indexPath!.row]
            imageTableCell.objects.append(object)
          }
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
