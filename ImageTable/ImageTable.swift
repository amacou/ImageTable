//
//  ImageTable.swift
//  ImageTable
//
//  Created by amacou on 2015/07/05.
//  Copyright (c) 2015年 amacou. All rights reserved.
//

import Foundation

import RealmSwift

class ImageTable: Object {
  dynamic var title = ""
  dynamic var headerData:NSData = NSData()
  dynamic var headerObjects = List<ImageTableObject>()
  dynamic var footerObjects = List<ImageTableObject>()
  dynamic var footerData:NSData = NSData()
  dynamic var headerImage:UIImage! {
    get {
      if self.headerData.length > 0 {
        return UIImage(data:self.headerData)
      }
      return nil
    }
    set(image) {
      if let image = image {
        self.headerData = UIImagePNGRepresentation(image)
      } else {
        self.headerData = NSData()
      }
    }
  }

  dynamic var footerImage:UIImage! {
    get {
      if footerData.length > 0 {
        return UIImage(data:self.footerData)
      }
      return nil
    }
    set(image) {
      if let image = image {
        self.footerData = UIImagePNGRepresentation(image)
      } else {
        self.footerData = NSData()
      }
    }
  }

  var cells = List<ImageTableCell>()
  
  override static func indexedProperties() -> [String] {
    return ["title"]
  }
  
  override static func ignoredProperties() -> [String] {
    return ["headerImage","footerImage"]
  }
}

class ImageTableCell: Object {
  dynamic var backgroundData = NSData()
  dynamic var backgroundImage:UIImage! {
    get {
      if backgroundData.length > 0 {
        return UIImage(data:self.backgroundData)
      }
      return nil
    }
    set(image) {
      self.backgroundData = UIImagePNGRepresentation(image)
    }
  }
  
  var objects = List<ImageTableObject>()
  
  override static func ignoredProperties() -> [String] {
    return ["backgroundImage"]
  }
}

class ImageTableObject: Object {
  dynamic var backgroundData = NSData()
  dynamic var scale:Float = 1.0
  dynamic var centerX:Float = 0
  dynamic var centerY:Float = 0
  dynamic var center:CGPoint {
    get {
      return CGPointMake(CGFloat(centerX), CGFloat(centerY))
    }
    set(point) {
      self.centerX = Float(point.x)
      self.centerY = Float(point.y)
    }
  }
  
  dynamic var backgroundImage:UIImage! {
    get {
      if backgroundData.length > 0 {
        return UIImage(data:self.backgroundData)
      }
      return nil
    }
    set(image) {
      self.backgroundData = UIImagePNGRepresentation(image)
    }
  }
  
  override static func ignoredProperties() -> [String] {
    return ["backgroundImage", "center"]
  }
}