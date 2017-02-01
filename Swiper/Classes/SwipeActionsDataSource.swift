//
//  SwipeActionsDataSource.swift
//  Swipper
//
//  Created by Hubert Drąg on 31.01.2017.
//  Copyright © 2017 Hubert Drąg. All rights reserved.
//

import Foundation
import UIKit

protocol SwipeActionsDataSource {
    func numberOfActions() -> Int
    func viewForSwipeAction(at index: Int) -> UIView
    func widthForSwipeAction(at index: Int) -> CGFloat
}
