//
//  ImageTableManager.swift
//  ImageTable
//
//  Created by amacou on 2015/07/19.
//  Copyright (c) 2015年 amacou. All rights reserved.
//

import Foundation
import RealmSwift
import TWMessageBarManager

final class ImageTableManager {
  let fileManager = NSFileManager.defaultManager()
  let basePath = Realm.defaultPath.stringByDeletingLastPathComponent
  var cachedFileNames:[String]!
  
  private init() {
    
  }
  static let defaultManager = ImageTableManager()
  
  func filePath(name:String) -> String
  {
    return "\(basePath)/\(name)"
  }
  
  func copyPath(originPath:String) -> String
  {
    let additionalName = "のコピー"
    var extention = originPath.pathExtension
    var newPath = originPath
    
    while (fileManager.fileExistsAtPath(newPath)) {
      newPath = "\(newPath.stringByDeletingPathExtension)\(additionalName).\(extention)"
    }

    return newPath
  }
  
  func create(name: String) -> ImageTable?
  {
    if fileManager.fileExistsAtPath(filePath(name)) {
      TWMessageBarManager.sharedInstance().showMessageWithTitle("同名の画面があるようです", description: nil, type: TWMessageBarMessageType.Error)
      return nil
    } else {
      var imageTable = ImageTable()
      imageTable.title = name
      var realm = Realm(path: filePath(name))
      realm.write {
        realm.add(imageTable)
      }
      self.cachedFileNames = nil

      return imageTable
    }
  }

  func delete(name: String)
  {
    if fileManager.fileExistsAtPath(filePath(name)) {
      fileManager.removeItemAtPath(filePath(name), error: nil)
    }
    self.cachedFileNames = nil
  }
  
  func copy(name: String)
  {
    if fileManager.fileExistsAtPath(filePath(name)) {
      fileManager.copyItemAtPath(filePath(name), toPath: copyPath(filePath(name)), error: nil)
    }
    self.cachedFileNames = nil
  }
  
  func rename(originName:String, to:String) {
    
    if fileManager.fileExistsAtPath(filePath(originName)) {
      if fileManager.fileExistsAtPath(filePath(to)) {
        TWMessageBarManager.sharedInstance().showMessageWithTitle("同名の画面があるようです", description: nil, type: TWMessageBarMessageType.Error)
      } else {
        fileManager.moveItemAtPath(filePath(originName), toPath: filePath(to), error: nil)
        if let imageTable = self.find(filePath(to)) {
          imageTable.realm?.write {
            imageTable.title = to.stringByDeletingPathExtension
          }
        }
      }
    }
    self.cachedFileNames = nil
  }
  func find(name: String) -> ImageTable?
  {
    if fileManager.fileExistsAtPath(filePath(name)) {
      let realm = Realm(path: filePath(name))
      return realm.objects(ImageTable).first
    }
    return nil
  }
  
  func allNames() -> [String]
  {
    if cachedFileNames != nil{
      return cachedFileNames
    }
    
    let fileNames = fileManager.contentsOfDirectoryAtPath(basePath, error: nil)
    var list = [String]()
    if let fileNames = fileNames {
      list = fileNames.filter({ (fileName: AnyObject) -> Bool in
        if let fileName = fileName as? String {
          return fileName.pathExtension  == "realm"
        }
        return false
      }) as! [String]
    }
    
    self.cachedFileNames = list
    
    return list
  }
}


