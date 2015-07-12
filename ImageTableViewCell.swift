//
//  ImageTableViewCell.swift
//  ImageTable
//
//  Created by amacou on 2015/07/05.
//  Copyright (c) 2015年 amacou. All rights reserved.
//

import UIKit

class ImageTableViewCell : UITableViewCell {
  @IBOutlet var cellImageView:UIImageView!
  var longPresGesture:UILongPressGestureRecognizer! {
    willSet(newGesture) {
      if let oldGesture = longPresGesture {
        self.removeGestureRecognizer(longPresGesture)
      }
    }
    didSet {
      self.addGestureRecognizer(longPresGesture)
    }
  }
}
