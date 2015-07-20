//
//  ImageTableObjectView.swift
//  ImageTable
//
//  Created by amacou on 2015/07/12.
//  Copyright (c) 2015年 amacou. All rights reserved.
//

import UIKit
import RealmSwift

class ImageTableObjectView: UIView {
  var object:ImageTableObject?
  var longPressGesture:UILongPressGestureRecognizer! {
    willSet(newGesture) {
      if let oldGesture = longPressGesture {
        self.removeGestureRecognizer(oldGesture)
      }
    }
    didSet {
      self.addGestureRecognizer(longPressGesture)
    }
  }
  var panGesture:UIPanGestureRecognizer! {
    willSet(newGesture) {
      if let oldGesture = panGesture {
        self.removeGestureRecognizer(oldGesture)
      }
    }
    didSet {
      self.addGestureRecognizer(panGesture)
    }
  }
  var pinchGesture:UIPinchGestureRecognizer! {
    willSet(newGesture) {
      if let oldGesture = pinchGesture {
        self.removeGestureRecognizer(oldGesture)
      }
    }
    didSet {
      self.addGestureRecognizer(pinchGesture)
    }
  }
  
  init(object obj:ImageTableObject) {

    let frame = CGRectMake(0, 0, obj.backgroundImage.size.width * CGFloat(obj.scale), obj.backgroundImage.size.height * CGFloat(obj.scale))
    super.init(frame: frame)
    self.center = obj.center
    self.object = obj
    self.panGesture = UIPanGestureRecognizer(target: self, action: "didPan:")
    self.pinchGesture = UIPinchGestureRecognizer(target: self, action: "didPinch:")
    self.addGestureRecognizer(panGesture)
    self.addGestureRecognizer(pinchGesture)
    self.userInteractionEnabled = true
    let imageView = UIImageView(image: object?.backgroundImage)
    imageView.frame = frame
    self.addSubview(imageView)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.panGesture = UIPanGestureRecognizer(target: self, action: "didMove:")
    self.pinchGesture = UIPinchGestureRecognizer(target: self, action: "didPinch:")
  }
  
  func didPan(gesture:UIPanGestureRecognizer) {
    var translation  = gesture.translationInView(self.superview!)
    
    if let oldCenter = object?.center {
      var center = CGPointMake(oldCenter.x + translation.x, oldCenter.y + translation.y)
     
      if gesture.state == UIGestureRecognizerState.Ended {
        let maxX = CGRectGetMaxX(self.frame)
        if maxX > CGRectGetWidth(self.superview!.frame) {
          center.x = CGRectGetWidth(self.superview!.frame) - CGRectGetWidth(self.frame) / 2
        }
        
        let minX = CGRectGetMinX(self.frame)
        if minX < 0 {
          center.x = CGRectGetWidth(self.frame) / 2
        }
        
        let maxY = CGRectGetMaxY(self.frame)
        if maxY > CGRectGetHeight(self.superview!.frame) {
          center.y = CGRectGetHeight(self.superview!.frame) - CGRectGetHeight(self.frame) / 2
        }
        
        let minY = CGRectGetMinY(self.frame)
        if minY < 0 {
          center.y = CGRectGetHeight(self.frame) / 2
        }

        object?.realm?.write {
          self.object?.center = center
        }
      }
      
      self.center = center
    }
  }
  
  func didPinch(gesture:UIPinchGestureRecognizer) {
    if gesture.state == UIGestureRecognizerState.Began || gesture.state == UIGestureRecognizerState.Changed {
      var scale = gesture.scale
      if CGRectGetHeight(self.frame) * scale > CGRectGetHeight(self.superview!.frame) {
        scale = CGRectGetHeight(self.superview!.frame) / (CGRectGetHeight(self.frame) * scale)
      }
      
      if CGRectGetWidth(self.frame) * scale > CGRectGetWidth(self.superview!.frame) {
        scale = CGRectGetWidth(self.superview!.frame) / (CGRectGetWidth(self.frame) * scale)
      }

      gesture.view!.transform = CGAffineTransformScale(gesture.view!.transform, scale, scale)
      gesture.scale = 1
      
      var center = self.center
      
      let maxX = CGRectGetMaxX(self.frame)
      if maxX > CGRectGetWidth(self.superview!.frame) {
        center.x = CGRectGetWidth(self.superview!.frame) - CGRectGetWidth(self.frame) / 2
      }
      
      let minX = CGRectGetMinX(self.frame)
      if minX < 0 {
        center.x = CGRectGetWidth(self.frame) / 2
      }
      
      let maxY = CGRectGetMaxY(self.frame)
      if maxY > CGRectGetHeight(self.superview!.frame) {
        center.y = CGRectGetHeight(self.superview!.frame) - CGRectGetHeight(self.frame) / 2
      }
      
      let minY = CGRectGetMinY(self.frame)
      if minY < 0 {
        center.y = CGRectGetHeight(self.frame) / 2
      }
      
      
      object?.realm?.write {
        self.object!.scale = Float(self.frame.width) / Float(self.object!.backgroundImage.size.width)
        self.object!.center = self.center
      }
    }
  }
}
