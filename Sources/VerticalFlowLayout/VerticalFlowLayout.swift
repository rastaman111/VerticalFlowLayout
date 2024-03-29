// MIT License
//
// Copyright (c) 2022 Alexandr Sibirtsev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

internal class VerticalFlowLayout: UICollectionViewFlowLayout {

    /// This property sets the amount of scaling for the first item.
    internal var firstItemTransform: CGFloat?
    /// This property enables paging per cell. Default is true.
    internal var isPagingEnabled: Bool = true
    /// Stores the height of a Cell.
    internal var cellHeight: CGFloat?
    /// Allows you to enable/disable the stacking effect. Default is `true`.
    internal var isStackingEnabled: Bool = true
    /// Allows you to set the view to Stack at the Top or at the Bottom. Default is `true`.
    internal var isStackOnBottom: Bool = true
    /// Sets how many cells of the stack are visible in the background. Default is 1.
    internal var stackedCellCount: Int = 1

    internal override func prepare() {
        super.prepare()

        assert(collectionView?.numberOfSections == 1, "Number of sections should always be 1.")
        assert(collectionView?.isPagingEnabled == false, "Paging on the collectionview itself should never be enabled. To enable cell paging, use the isPagingEnabled property of the VerticalFlowLayout instead.")
    }

    internal override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView, let cellHeight = cellHeight else { return nil }

        let y = collectionView.bounds.minY - cellHeight * CGFloat(stackedCellCount)
        let newRect = CGRect(x: 0, y: y < 0 ? 0 : y, width: collectionView.bounds.maxX, height: collectionView.bounds.maxY)
        let items = NSArray(array: super.layoutAttributesForElements(in: newRect)!, copyItems: true)

        for object in items {
            if let attributes = object as? UICollectionViewLayoutAttributes {
                self.updateCellAttributes(attributes)
            }
        }
        return items as? [UICollectionViewLayoutAttributes]
    }

    internal override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

        if self.collectionView?.numberOfItems(inSection: 0) == 0 { return nil }

        if let attr = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes {
            self.updateCellAttributes(attr)
            return attr
        }
        
        return nil
    }

    internal override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutAttributesForItem(at: itemIndexPath)
    }

    internal override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutAttributesForItem(at: itemIndexPath)
    }

    internal override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    // Cell paging
    internal override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        guard
            let collectionView = self.collectionView,
            let cellHeight = cellHeight,
            isPagingEnabled
        else {
            let latestOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
            return latestOffset
        }

        // Page height used for estimating and calculating paging.
        let pageHeight = cellHeight + self.minimumLineSpacing

        // Make an estimation of the current page position.
        let approximatePage = collectionView.contentOffset.y/pageHeight

        // Determine the current page based on velocity.
        let currentPage = velocity.y == 0.0 ? round(approximatePage) : (velocity.y < 0.0 ? floor(approximatePage) : ceil(approximatePage))

        // Create custom flickVelocity.
        let flickVelocity = velocity.y * 0.3

        // Check how many pages the user flicked, if <= 1 then flickedPages should return 0.
        let flickedPages = (abs(round(flickVelocity)) <= 1) ? 0 : round(flickVelocity)

        // Calculate newVerticalOffset.
        let newVerticalOffset = ((currentPage + flickedPages) * pageHeight) - collectionView.contentInset.top

        return CGPoint(x: proposedContentOffset.x, y: newVerticalOffset)
    }

    /**
     Updates the attributes.
     Here manipulate the zIndex of the cells here, calculate the positions and do the animations.
     */
    fileprivate func updateCellAttributes(_ attributes: UICollectionViewLayoutAttributes) {

        guard let collectionView = collectionView else { return }

        let cvMinY = collectionView.bounds.minY + collectionView.contentInset.top
        let cellMinY = attributes.frame.minY
        var origin = attributes.frame.origin
        let cellHeight = attributes.frame.height

        let finalY = max(cvMinY, cellMinY)

        let deltaY = (finalY - cellMinY) / cellHeight
        transformAttributes(attributes: attributes, deltaY: deltaY)

        attributes.alpha = 1 - (deltaY - CGFloat(stackedCellCount))

        origin.x = collectionView.frame.width/2 - attributes.frame.width/2 - collectionView.contentInset.left
        origin.y = finalY
        attributes.frame = CGRect(origin: origin, size: attributes.frame.size)
        attributes.zIndex = attributes.indexPath.row
    }

    // Creates and applies a CGAffineTransform to the attributes to recreate the effect of the cell going to the background.
    fileprivate func transformAttributes(attributes: UICollectionViewLayoutAttributes, deltaY: CGFloat) {

        if let itemTransform = firstItemTransform {
            let top = isStackOnBottom ? deltaY : deltaY * -1
            let scale = 1 - deltaY * itemTransform
            let translationScale = CGFloat((attributes.zIndex + 1) * 10)
            var t = CGAffineTransform.identity

            let calculatedScale = scale > 0 ? scale : 0
            t = t.scaledBy(x: calculatedScale, y: 1)
            if isStackingEnabled {
                t = t.translatedBy(x: 0, y: top * translationScale)
            }
            attributes.transform = t
        }
    }
}
