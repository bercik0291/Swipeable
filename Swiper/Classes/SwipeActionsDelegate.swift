//
//  SwipeActionsDelegate.swift
//  Swipper
//
//  Created by Hubert Drąg on 31.01.2017.
//  Copyright © 2017 Hubert Drąg. All rights reserved.
//

import Foundation

protocol SwipeActionsDelegate {
    func didHideActions(cell: SwipeableCell)
    func didInvokeAction(cell: SwipeableCell, at index: Int)
}
