//
//  SwipeActionCell.swift
//  Swipper
//
//  Created by Hubert Drąg on 31.01.2017.
//  Copyright © 2017 Hubert Drąg. All rights reserved.
//

import Foundation
import UIKit

class SwipeActionCell: UICollectionViewCell {
    weak private(set) var actionView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func add(swipeActionView: UIView) {
        if let actionView = actionView  {
            actionView.removeFromSuperview()
        }
        
        swipeActionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(swipeActionView)
        actionView = swipeActionView
        
        setupConstraints()
        
    }
    
    private func setupConstraints() {
        let views = ["actionView" : actionView]
        
        // vertical
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[actionView]-0-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
        
        // horizontal
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[actionView]-0-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
    }
}
