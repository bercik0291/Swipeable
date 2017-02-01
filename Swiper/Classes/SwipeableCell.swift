//
//  SwipeableCell.swift
//  Swipper
//
//  Created by Hubert Drąg on 31.01.2017.
//  Copyright © 2017 Hubert Drąg. All rights reserved.
//

import Foundation
import UIKit

enum SwipeDirection {
    case toLeft
    case toRight
}

class SwipeableCell: UICollectionViewCell {
    weak private(set) var collectionView: UICollectionView!
    weak private(set) var swipeableContentView: UIView!
    weak private(set) var collectionViewWC: NSLayoutConstraint!
    weak private(set) var collectionViewLC: NSLayoutConstraint!
    
    var dataSource: SwipeActionsDataSource? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var delegate: SwipeActionsDelegate?
    var direction: SwipeDirection = .toLeft {
        didSet {
            if direction == .toLeft {
                var scalingTransform : CGAffineTransform!
                scalingTransform = CGAffineTransform(scaleX: -1, y: 1);
                collectionView.transform = scalingTransform
            } else {
                collectionView.transform = CGAffineTransform.identity
            }
        }
    }
    
    fileprivate lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        gesture.delegate = self
        return gesture
    }()
    
    fileprivate var panStartPoint: CGPoint = .zero
    fileprivate var startingLeftLayoutConstraintConstant: CGFloat = 0.0
    fileprivate var startingRightLayoutConstraintConstant: CGFloat = 0.0
    
    fileprivate var leftConstraint: NSLayoutConstraint!
    fileprivate var rightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //
        setup()
        setupConstraints()
        
        //
        addGestureRecognizer(panGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        
        //
        let layout = SwipeLayout()
        layout.delegate = self
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .red
        var scalingTransform : CGAffineTransform!
        scalingTransform = CGAffineTransform(scaleX: -1, y: 1);
        collectionView.transform = scalingTransform
        addSubview(collectionView)
        self.collectionView = collectionView
        
        collectionView.register(SwipeActionCell.self, forCellWithReuseIdentifier: "SwipeActionCell")
        
        //
        let swipeableContentView = UIView()
        swipeableContentView.backgroundColor = .blue
        swipeableContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(swipeableContentView)
        self.swipeableContentView = swipeableContentView
    }
    
    private func setupConstraints() {
        
        rightConstraint = swipeableContentView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0.0)
        rightConstraint.isActive = true
        swipeableContentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        //
        swipeableContentView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0).isActive = true
        swipeableContentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0).isActive = true
        
        //
        let views = ["collectionView" : collectionView]
        
        // vertical
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[collectionView]-0-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
        
        // horizontal
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[collectionView]-0-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: views
            )
        )
    }
    
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            _beginSwipe(with: gesture)
            break
            
        case .changed:
            _changeSwipe(with: gesture)
            break
            
        case .cancelled, .failed, .ended:
            _endSwipe(with: gesture)
            break
            
        default:
            break
            
        }

    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if swipeableContentView.frame.contains(point) {
            hideActions()
            return swipeableContentView
        }
        
        return super.hitTest(point, with: event)
    }
}

extension SwipeableCell {
    
    fileprivate var maximumInset: CGFloat {
        if collectionView.contentSize.width > bounds.width {
            return bounds.width - 24.0
        }
        
        return collectionView.contentSize.width
    }
    
    fileprivate func _beginSwipe(with gesture: UIPanGestureRecognizer) {
        if (collectionView.collectionViewLayout as! SwipeLayout).cellsWidth > bounds.width {
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 24.0)
        }
        
        panStartPoint = gesture.translation(in: swipeableContentView)
        startingRightLayoutConstraintConstant = rightConstraint.constant
    }
    
    fileprivate func _changeSwipe(with gesture: UIPanGestureRecognizer) {
        let currentPoint = gesture.translation(in: swipeableContentView)
        let deltaX = currentPoint.x - self.panStartPoint.x
        
        //
        let newRightConstant = direction == .toLeft ? min(self.startingRightLayoutConstraintConstant + deltaX, 0) : max(self.startingRightLayoutConstraintConstant + deltaX, 0)
        rightConstraint.constant = newRightConstant;
    }
    
    fileprivate func _endSwipe(with gesture: UIPanGestureRecognizer) {
        let contentSize = collectionView.contentSize
        let width = contentSize.width < bounds.width ? contentSize.width : bounds.width
        
        guard abs(rightConstraint.constant) > width * 0.25 else {
            rightConstraint.constant = 0.0; return;
        }
        
        rightConstraint.constant = direction == .toLeft ? -maximumInset : maximumInset
        
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5.0, options: .curveEaseOut, animations: { 
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func hideActions() {
        rightConstraint.constant = 0.0
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
}

extension SwipeableCell: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let locationInView = gestureRecognizer.location(in: self)
        
        // hide other actions before showing new one
        if !collectionView.frame.contains(locationInView) {
            delegate?.didHideActions(cell: self)
        }
        
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = gestureRecognizer.translation(in: self)
            
            if direction == .toLeft, translation.x < 0, self.swipeableContentView.frame.contains(locationInView) {
                return true
            }
            else if direction == .toRight, translation.x > 0, self.swipeableContentView.frame.contains(locationInView) {
                return true
            }
        }
        
        return false;
    }
}

//MARK: - UICollectionViewDataSource
extension SwipeableCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { return 0 }
        return dataSource.numberOfActions()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SwipeActionCell",
            for: indexPath
        ) as! SwipeActionCell
        
        if direction == .toLeft {
            var scalingTransform : CGAffineTransform!
            scalingTransform = CGAffineTransform(scaleX: -1, y: 1);
            cell.transform = scalingTransform
        }
        
        if let dataSource = dataSource {
            cell.add(swipeActionView: dataSource.viewForSwipeAction(at: indexPath.row))
        }
        
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension SwipeableCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didInvokeAction(cell: self, at: indexPath.row)
    }
}

extension SwipeableCell: SwipeLayoutDelegate {
    func size(_ layout: SwipeLayout, forItemAt index: Int) -> CGSize {
        guard let dataSource = dataSource else { return .zero }
        return CGSize(width: dataSource.widthForSwipeAction(at: index), height: bounds.height)
    }
}

protocol SwipeLayoutDelegate: NSObjectProtocol {
    func size(_ layout: SwipeLayout, forItemAt index: Int) -> CGSize
}

class SwipeLayout: UICollectionViewLayout {
    
    // 
    weak var delegate: SwipeLayoutDelegate?
    
    // colections
    private var sectionsAttributes: [UICollectionViewLayoutAttributes] = []
    private var cellsAttributes: [UICollectionViewLayoutAttributes] = []
    
    //
    var cellsWidth: CGFloat = 0
    
    override public var collectionViewContentSize : CGSize {
        guard let collectionView = self.collectionView else { return .zero}
        
        // calculate content size (headers + cells)
        return CGSize(width: cellsWidth, height: collectionView.bounds.height)
    }
    
    override public func prepare() {
        super.prepare()
        
        // generate layout attributes
        prepareContentCellAttributes()
    }

    // MARK: - Private
    
    private func prepareContentCellAttributes() {
        guard let collectionView = collectionView else { return }
        
        // reset attributes
        self.cellsAttributes = []
        
        // calculate start vertical origin
        var cursor: CGFloat = 0.0
        
        // get count of elements
        let itemCount = collectionView.numberOfItems(inSection: 0)
        
        for itemIndex in 0..<itemCount {
            // create cell attributes
            let indexPath = IndexPath(item: itemIndex, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let itemSize = delegate?.size(self, forItemAt: itemIndex) ?? .zero
            
            // calculate frame of new attribute
            attributes.frame = CGRect(x: cursor, y:0 , width: itemSize.width, height: itemSize.height)
            
            // collect attributes
            cellsAttributes.append(attributes)
            
            // move currsor
            cursor += itemSize.width
        }
        
        // calculate cells hegiht
        self.cellsWidth = cursor
    }

    // MARK: - Layout Attributes - Content Cell
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellsAttributes[indexPath.section]
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {        
        return self.cellsAttributes
            .filter({rect.intersects($0.frame)})
    }
    
    // MARK: - Layout Attributes - Section Header Cell
    
    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return sectionsAttributes[indexPath.row]
    }


}
