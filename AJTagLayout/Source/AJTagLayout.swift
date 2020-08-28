//
//  AJTagLayout.swift
//  AJTagLayout
//
//  Created by Robot Amiee on 2020/8/27.
//  Copyright © 2020 Amiee. All rights reserved.
//

import UIKit

public class AJTagLayout: UICollectionViewFlowLayout {
    public enum HorizontalAlignment {
        case leading
        case center
        case trailing
        case justified
        case fill
    }
    
    var horizontalAlignment = HorizontalAlignment.leading
    var fillIgnoreFirst = false
    
    private typealias Align = (lastItem: Int, itemsCount: Int, maxY: CGFloat, fillSpacing: CGFloat)
    private var currentCellAttributes = [UICollectionViewLayoutAttributes]()
    private var cachedCellAttributes = [UICollectionViewLayoutAttributes]()
    private var contentWidth = CGFloat.zero
    private var contentHeight = CGFloat.zero
    private var aligns = [Align]()
    private var rowContentWidth = CGFloat.zero
    private var insertedIndexPaths = [IndexPath]()
    private var deletedIndexPaths = [IndexPath]()

    // MARK: - Preparation
    
    public override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else {
            return
        }
        
        cachedCellAttributes = currentCellAttributes
        
        // Clear
        contentWidth = collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
        contentHeight = .zero
        currentCellAttributes.removeAll()
        aligns.removeAll()
        rowContentWidth = .zero
        insertedIndexPaths.removeAll()
        deletedIndexPaths.removeAll()
        
        var x: CGFloat = sectionInset.left
        var y: CGFloat = sectionInset.top
        
        let maxCellWidth = collectionView.bounds.size.width - collectionView.contentInset.left - collectionView.contentInset.right - sectionInset.left - sectionInset.right
        let maxContentWidth = collectionView.bounds.size.width - collectionView.contentInset.left - collectionView.contentInset.right
        
        let count = collectionView.numberOfItems(inSection: 0)
        
        for item in 0..<count {
            let indexPath = IndexPath(item: item, section: 0)
            var size = itemSize
            if let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout, delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))) {
                size = delegate.collectionView!(collectionView, layout: self, sizeForItemAt: indexPath)
            }
            if size.width > maxCellWidth {
                size.width = maxCellWidth
            }
            var frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            x += size.width + minimumInteritemSpacing
            rowContentWidth += frame.width
            let lastContentHeight = contentHeight
            contentHeight = max(contentHeight, frame.maxY)
            if x > maxContentWidth {
                x = sectionInset.left
                y = lastContentHeight + minimumLineSpacing
                frame = CGRect(x: x, y: y, width: size.width, height: size.height)
                x += size.width + minimumInteritemSpacing
                
                var lastLastItem = 0
                var itemsCount = 1
                if let lastAlgin = aligns.last {
                    lastLastItem = lastAlgin.lastItem
                    itemsCount = item - lastLastItem - 1
                } else {
                    itemsCount = item - lastLastItem
                }
                
                let totalSpacing: CGFloat = contentWidth - sectionInset.left - sectionInset.right - (rowContentWidth - frame.width) - minimumInteritemSpacing * CGFloat(itemsCount - 1)
                var fillSpacing: CGFloat = totalSpacing / CGFloat(itemsCount)
                if horizontalAlignment == .fill, fillIgnoreFirst, lastLastItem == -1 {
                    fillSpacing = 0
                }
                let algin: Align = (lastItem: item - 1, itemsCount: itemsCount, maxY: contentHeight, fillSpacing: fillSpacing)
                aligns.append(algin)
                rowContentWidth = frame.width
            }
            
            contentHeight = max(contentHeight, frame.maxY)
            
            if item == count - 1 {
                var lastLastItem = 0
                var itemsCount = 1
                if let lastAlgin = aligns.last {
                    lastLastItem = lastAlgin.lastItem
                    itemsCount = item - lastLastItem
                } else {
                    itemsCount = item - lastLastItem + 1
                }
                
                let totalSpacing: CGFloat = contentWidth - sectionInset.left - sectionInset.right - rowContentWidth - minimumInteritemSpacing * CGFloat(itemsCount - 1)
                var fillSpacing: CGFloat = totalSpacing / CGFloat(itemsCount)
                if horizontalAlignment == .fill, fillIgnoreFirst, lastLastItem == -1 {
                    fillSpacing = 0
                }
                let algin: Align = (lastItem: item, itemsCount: itemsCount, maxY: contentHeight, fillSpacing: fillSpacing)
                aligns.append(algin)
            }
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            currentCellAttributes.append(attributes)
        }
        
        contentHeight += sectionInset.bottom
        
        x = sectionInset.left
        
        currentCellAttributes.forEach { attributes in
            switch horizontalAlignment {
            case .leading:
                break
            case .center:
                if let algin = aligns.filter({ $0.lastItem >= attributes.indexPath.item }).first {
                    if algin.lastItem - attributes.indexPath.item == algin.itemsCount - 1 {
                        x += algin.fillSpacing * CGFloat(algin.itemsCount) / 2
                    }
                    attributes.frame.origin.x = x
                    x += attributes.frame.size.width + minimumInteritemSpacing
                    
                    if attributes.indexPath.item == algin.lastItem {
                        x = sectionInset.left
                    }
                }
            case .trailing:
                if let algin = aligns.filter({ $0.lastItem >= attributes.indexPath.item }).first {
                    if algin.lastItem - attributes.indexPath.item == algin.itemsCount - 1 {
                        x += algin.fillSpacing * CGFloat(algin.itemsCount)
                    }
                    attributes.frame.origin.x = x
                    x += attributes.frame.size.width + minimumInteritemSpacing
                    
                    if attributes.indexPath.item == algin.lastItem {
                        x = sectionInset.left
                    }
                }
            case .justified:
                if let algin = aligns.filter({ $0.lastItem >= attributes.indexPath.item }).first {
                    if algin.itemsCount == 1 {
                        x += algin.fillSpacing * CGFloat(algin.itemsCount) / 2
                        attributes.frame.origin.x = x
                    } else {
                        let newSpacing = algin.fillSpacing * CGFloat(algin.itemsCount) / CGFloat(algin.itemsCount - 1) + minimumInteritemSpacing
                        attributes.frame.origin.x = x
                        x += attributes.frame.size.width + newSpacing
                    }
                    
                    if attributes.indexPath.item == algin.lastItem {
                        x = sectionInset.left
                    }
                }
            case .fill:
                if let algin = aligns.filter({ $0.lastItem >= attributes.indexPath.item }).first {
                    if fillIgnoreFirst, attributes.indexPath.item == 0 {
                        x += attributes.frame.size.width + minimumInteritemSpacing
                    } else {
                        attributes.frame.origin.x = x
                        attributes.frame.size.width += algin.fillSpacing
                        x += attributes.frame.size.width + minimumInteritemSpacing
                    }
                    
                    if attributes.indexPath.item == algin.lastItem {
                        x = sectionInset.left
                    }
                }
            }
        }
        
        NSLog("cachedCellAttributes:\n\(cachedCellAttributes.map({ "\($0.indexPath.item)-\($0.frame)"}).joined(separator: "\n"))")
        NSLog("currentCellAttributes:\n\(currentCellAttributes.map({ "\($0.indexPath.item)-\($0.frame)"}).joined(separator: "\n"))")
    }
    
    // MARK: - Layout Attributes
    
    public override var scrollDirection: UICollectionView.ScrollDirection {
        didSet {
            scrollDirection = .vertical
            NSLog("Do not support horizontal scroll direction")
        }
    }
    
    public override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        NSLog("showItem++++++:\(itemIndexPath.item)")
        var attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        if insertedIndexPaths.contains(itemIndexPath) {
            attributes?.transform3D = CATransform3DMakeScale(0.2, 0.2, 1.0)
            cachedCellAttributes = currentCellAttributes
        } else {
            attributes = cachedCellAttributes[itemIndexPath.item]
        }
        return attributes
    }
            
    public override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        NSLog("dissItem---:\(itemIndexPath.item)")
        var attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        if deletedIndexPaths.contains(itemIndexPath) {
            attributes = cachedCellAttributes[itemIndexPath.item]
            attributes?.transform3D = CATransform3DMakeScale(0.2, 0.2, 1.0)
            attributes?.alpha = 0
            cachedCellAttributes = currentCellAttributes
        }

        return attributes
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView, indexPath.item < collectionView.numberOfItems(inSection: 0) else {
            return nil
        }
        
        return currentCellAttributes[indexPath.item]
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return currentCellAttributes.filter { rect.intersects($0.frame) }
    }
    
    public override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        insertedIndexPaths.removeAll()
        deletedIndexPaths.removeAll()
        
        updateItems.forEach { updateItem in
            switch updateItem.updateAction {
            case .insert:
                if let indexPath = updateItem.indexPathAfterUpdate {
                    NSLog("prepareInsert:\(indexPath.item)")
                    insertedIndexPaths.append(indexPath)
                }
            case .delete:
                if let indexPath = updateItem.indexPathBeforeUpdate {
                    NSLog("prepareDelete:\(indexPath.item)")
                    deletedIndexPaths.append(indexPath)
                }
            case .move:
                deletedIndexPaths.append(updateItem.indexPathBeforeUpdate!)
                insertedIndexPaths.append(updateItem.indexPathAfterUpdate!)
            default:
                break
            }
        }
    }
    
    public override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        
        insertedIndexPaths.removeAll()
        deletedIndexPaths.removeAll()
    }
    
    // MARK: - Invalidation
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let oldBounds = collectionView?.bounds, !oldBounds.size.equalTo(newBounds.size) {
            return true
        }
        
        return false
    }
    
    // MARK: - Collection View Info
    
    public override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
}
