//
//  UICollectionView+Swipper.swift
//  SwipperExample
//
//  Created by Hubert Drag on 01.02.2017.
//  Copyright © 2017 AppUnite. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    func hideActions() {
        for cell in visibleCells {
            guard let cell = cell as? SwipeableCell else { continue }
            cell.hideActions()
        }
    }
}
