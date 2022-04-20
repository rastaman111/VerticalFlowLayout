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

public class VerticalView: UIView {

    /// The collectionView where all the magic happens.
    public var verticalCollectionView: VerticalCollectionView!

    /// The inset (spacing) at the top for the cells. Default is 40.
    @IBInspectable public var topInset: CGFloat = 40 {
        didSet {
            setupEdgeInsets()
        }
    }
    /// The inset (spacing) at each side of the cells. Default is 20.
    @IBInspectable public var sideInset: CGFloat = 20 {
        didSet {
            setupEdgeInsets()
        }
    }
    /// Sets how much of the next cellshould be visible. Default is 50.
    @IBInspectable public var visibleNextCellHeight: CGFloat = 50 {
        didSet {
            setupEdgeInsets()
        }
    }
    /// Vertical spacing between the focussed cell and the bottom (next) cell. Default is 40.
    @IBInspectable public var cellSpacing: CGFloat = 40 {
        willSet {
            flowLayout.minimumLineSpacing = newValue
        }
        didSet {
            setupEdgeInsets()
        }
    }
    /// The transform animation that is shown on the top cell when scrolling through the cells. Default is 0.05.
    @IBInspectable public var firstItemTransform: CGFloat = 0.05 {
        willSet {
            flowLayout.firstItemTransform = newValue
        }
    }
    /// Allows you to enable/disable the stacking effect. Default is `true`.
    @IBInspectable public var isStackingEnabled: Bool = true {
        willSet {
            flowLayout.isStackingEnabled = newValue
        }
    }
    /// Allows you to set the view to Stack at the Top or at the Bottom. Default is `true`.
    @IBInspectable public var isStackOnBottom: Bool = true {
        willSet {
            flowLayout.isStackOnBottom = newValue
        }
    }
    /// Sets how many cells of the stack are visible in the background. Default is 1.
    @IBInspectable public var stackedCellsCount: Int = 1 {
        willSet {
            flowLayout.stackedCellCount = newValue
        }
    }
    /**
     Returns an array of indexes (as Int) that are currently visible in the `VerticalCollectionView`.
     This includes cells that are stacked (behind the focussed cell).
     */
    public var indexesForVisibleCells: [Int] {
        var indexes: [Int] = []
      
        for cellIndexPath in self.verticalCollectionView.indexPathsForVisibleItems {
            indexes.append(cellIndexPath.row)
        }
        
        return indexes.sorted()
    }
    
    /// The currently focussed cell index.
    public var focussedCellIndex: Int? {
        let center = self.convert(self.verticalCollectionView.center, to: self.verticalCollectionView)
        if let indexPath = self.verticalCollectionView.indexPathForItem(at: center) {
            return indexPath.row
        }
        
        return nil
    }

    public weak var delegate: VerticalCollectionViewDelegate?
    public weak var datasource: VerticalCollectionViewDataSource?

    /// The flowlayout used in the collectionView.
    fileprivate lazy var flowLayout: VerticalFlowLayout = {
        let flowLayout = VerticalFlowLayout()
        flowLayout.firstItemTransform = firstItemTransform
        flowLayout.minimumLineSpacing = cellSpacing
        flowLayout.isPagingEnabled = true
        
        return flowLayout
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupInit()
    }

    /// Inserts new cells at the specified indexes.
    public func insertCells(at indexes: [Int]) {
        self.performUpdates {
            self.verticalCollectionView.insertItems(at: indexes.map { (index) -> IndexPath in
                return convertIndexToIndexPath(for: index)
            })
        }
    }

    /// Deletes cells at the specified indexes.
    public func deleteCells(at indexes: [Int]) {
        self.performUpdates {
            self.verticalCollectionView.deleteItems(at: indexes.map { (index) -> IndexPath in
                return self.convertIndexToIndexPath(for: index)
            })
        }
    }

    /// Moves an item from one location to another in the collection view.
    public func moveCell(at atIndex: Int, to toIndex: Int) {
        self.verticalCollectionView.moveItem(at: convertIndexToIndexPath(for: atIndex), to: convertIndexToIndexPath(for: toIndex))
    }

    /// Returns the visible cell object at the specified index.
    public func cellForItem(at index: Int) -> UICollectionViewCell? {
        return self.verticalCollectionView.cellForItem(at: convertIndexToIndexPath(for: index))
    }
    
    /// Reloads all of the data for the VerticalCollectionView.
    public func reloadData() {
        self.verticalCollectionView.reloadData()
    }

    /// Scrolls the collection view contents until the specified item is visible.
    public func scrollToCell(at index: Int, animated: Bool) -> Bool {
        guard
            let cellHeight = flowLayout.cellHeight,
            index >= 0,
            index < verticalCollectionView.numberOfItems(inSection: 0)
            else { return false }
        let y = CGFloat(index) * (cellHeight + flowLayout.minimumLineSpacing) - topInset
        let point = CGPoint(x: verticalCollectionView.contentOffset.x, y: y)
        self.verticalCollectionView.setContentOffset(point, animated: animated)
        
        return true
    }

    private func setupInit() {
        self.setupVerticalCollectionView()
        self.setupConstraints()
        self.setupEdgeInsets()
    }
    
    private func setupVerticalCollectionView() {
        self.verticalCollectionView = VerticalCollectionView(frame: self.frame, collectionViewLayout: flowLayout)
        self.verticalCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        self.verticalCollectionView.backgroundColor = UIColor.clear
        self.verticalCollectionView.showsVerticalScrollIndicator = false
        self.verticalCollectionView.dataSource = self
        self.verticalCollectionView.delegate = self
        
        self.addSubview(verticalCollectionView)
    }

    private func setupConstraints() {
        self.verticalCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.verticalCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.verticalCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.verticalCollectionView.topAnchor.constraint(equalTo: self.topAnchor),
            self.verticalCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    private func setupEdgeInsets() {
        let bottomInset = visibleNextCellHeight + flowLayout.minimumLineSpacing
        verticalCollectionView.contentInset = UIEdgeInsets(top: topInset, left: sideInset, bottom: bottomInset, right: sideInset)
    }

    private func performUpdates(updateClosure: () -> ()) {
        UIView.performWithoutAnimation {
            self.verticalCollectionView.performBatchUpdates({
                updateClosure()
            }, completion: { [weak self] _ in
                self?.verticalCollectionView.collectionViewLayout.invalidateLayout()
            })
        }
    }
    
    /// Takes an index as Int and converts it to an IndexPath with row: index and section: 0.
    internal func convertIndexToIndexPath(for index: Int) -> IndexPath {
        return IndexPath(row: index, section: 0)
    }
}

//MARK: - UICollectionViewDelegate

extension VerticalView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = delegate {
            delegate.didSelectCell(verticalCollectionView: verticalCollectionView, indexPath: indexPath.row)
        }
    }
}

//MARK: - UICollectionViewDataSource

extension VerticalView: UICollectionViewDataSource {

    public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        self.verticalCollectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }

    public func register(nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        self.verticalCollectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource?.numberOfItemsIn(verticalCollectionView: verticalCollectionView) ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = datasource?.cellForItemIn(verticalCollectionView: verticalCollectionView, cellForItemAt: indexPath.row) {
            return cell
        }
        
        return UICollectionViewCell()
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension VerticalView: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemSize = self.calculateItemSize(for: indexPath.row)

        flowLayout.cellHeight = itemSize.height

        return itemSize
    }

    private func calculateItemSize(for index: Int) -> CGSize {

        let xInsets = sideInset * 2
        let yInsets = cellSpacing + visibleNextCellHeight + topInset
        let cellWidth = self.verticalCollectionView.frame.size.width - xInsets
        let cellHeight = self.verticalCollectionView.frame.size.height - yInsets
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
