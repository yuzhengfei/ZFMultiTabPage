//
//  ZFMultiTabPageViewController.swift
//  FortuneCatApp
//
//  Created by Flying on 2020/4/27.
//  Copyright © 2020 mflywork. All rights reserved.
//

import Foundation

@objc protocol ZFMultiTabPageDelegate: NSObjectProtocol {
    // 横向collectionView滑动
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, pageScrollViewDidScroll scrollView: UIScrollView)
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, pageScrollViewDidEndDecelerating scrollView: UIScrollView)
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, pageScrolllViewDidEndScrollingAnimation scrollView: UIScrollView)
    // mainScrollView 滑动
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, mainScrollViewDidScroll scrollView: UIScrollView)
    // 向外部要tab child vc
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, childViewController index: Int) -> ZFMultiTabChildPageViewController?
    // 子列表将要显示
    @objc optional func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, willDisplay index: Int)
    // 子列表显示
    @objc optional func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, displaying index: Int)
    // 子列已经显示
    @objc optional func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, didEndDisplaying index: Int)
}

class ZFMultiTabPageViewController: UIViewController {
    
    // MARK: - Public Preproty
    weak var delegate: ZFMultiTabPageDelegate?
    
    // MARK: - Private Preproty
    private lazy var mainScrollView: ZFCommonTabScrollView = {
        let mainScrollView = ZFCommonTabScrollView()
        mainScrollView.delegate = self
        mainScrollView.bounces = false
        mainScrollView.showsVerticalScrollIndicator = false
        return mainScrollView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.register(ZFCommonTabItemCell.self, forCellWithReuseIdentifier: NSStringFromClass(ZFCommonTabItemCell.self))
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    private var headerView: UIView!
    private var tabView: UIView!
    private var tabCount: Int = 0
    private var currentIndex: Int = 0
    private var titleBarHeight: CGFloat = 0.0
    private var isHiddenHeaderView: Bool = false
    //记录刚开始时的偏移量
    private var startOffsetX: CGFloat = 0
    // 缓存所有的子列表，避免重复向调用方去索要
    private var childVCDic: [Int: ZFMultiTabChildPageViewController] = [:]
    // 判断是否点击title来滚动页面
    private var mIsClickTitle: Bool = false
    // 页面的高度偏移量
    private var offsetHeight: CGFloat = 0
    
    /// 初始化方法
    /// - Parameters:
    ///   - tabCount: tab数量
    ///   - headerView: 头部视图
    ///   - tabView: tab视图
    ///   - titleBarHeight: titleBar的高度
    init(tabCount: Int, headerView: UIView, tabView: UIView, titleBarHeight: CGFloat) {
        super.init(nibName: nil, bundle: nil)
        self.tabCount = tabCount
        self.headerView = headerView
        self.tabView = tabView
        self.titleBarHeight = titleBarHeight
    }
    
    
    /// 初始化方法
    /// - Parameters:
    ///   - tabCount: tab数量
    ///   - headerView: 头部视图
    ///   - tabView: tab视图
    ///   - titleBarHeight: titleBar的高度
    ///   - defaultIndex: 可选参数，默认显示的子tab的索引，默认显示第一个
    ///   - isHiddenHeaderView: 可选参数，是否隐藏头部视图，默认显示
    ///   - offsetHeight: 可选参数，主视图的偏移量，默认 = 0
    init(tabCount: Int, headerView: UIView, tabView: UIView, titleBarHeight: CGFloat, defaultIndex: Int = 0, isHiddenHeaderView: Bool = false, offsetHeight: CGFloat = 0) {
        super.init(nibName: nil, bundle: nil)
        self.tabCount = tabCount
        self.headerView = headerView
        self.tabView = tabView
        self.titleBarHeight = titleBarHeight
        if defaultIndex < tabCount, defaultIndex >= 0 {
            self.currentIndex = defaultIndex
        }
        self.isHiddenHeaderView = isHiddenHeaderView
        self.offsetHeight = offsetHeight
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var isHeaderViewHidden: Bool = false {
        didSet {
            if isHeaderViewHidden {
                mainScrollView.contentOffset = CGPoint(x: 0, y: headerView.frame.height - titleBarHeight)
            }
        }
    }
    
    var isHorizontalScrollEnable: Bool = true {
        didSet {
            self.collectionView.isScrollEnabled = isHorizontalScrollEnable
        }
    }
    
    var isBounces: Bool = false {
        didSet {
            self.mainScrollView.bounces = isBounces
        }
    }

    public func move(to: Int, animated: Bool) {
        self.currentIndex = to
        mIsClickTitle = true
        view.isUserInteractionEnabled = false
        collectionView.scrollToItem(at: IndexPath.init(row: to, section: 0), at: .centeredHorizontally, animated: false)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.view.isUserInteractionEnabled = true
        }
    }
    
    // 处理右滑退出手势冲突问题
    public func handlePopGestureRecognizer(navi: UINavigationController) {
        if let popGestureRecognizer = navi.interactivePopGestureRecognizer {
            collectionView.panGestureRecognizer.require(toFail: popGestureRecognizer)
        }
    }

    public func resetChildViewControllers(tabCount: Int) {
        // 清空原来的父控制器
        childVCDic.forEach { (dic: (key: Int, value: ZFMultiTabChildPageViewController)) in
            dic.value.removeFromParent()
        }
        mainScrollView.scrollViewWhites?.removeAll()
        self.childVCDic.removeAll()
        self.tabCount = tabCount
        self.collectionView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
        if #available(iOS 11.0, *) {
            mainScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    private func configViews() {
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(headerView)
        mainScrollView.addSubview(tabView)
        mainScrollView.addSubview(collectionView)
        mainScrollView.frame = view.bounds
        mainScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - self.offsetHeight)
        mainScrollView.contentSize = CGSize(width: 0, height: mainScrollView.frame.height + headerView.frame.height)
        tabView.frame.origin.y = headerView.frame.maxY
        collectionView.frame.origin.y = tabView.frame.maxY
        collectionView.frame.size = CGSize(width: view.frame.width, height: mainScrollView.contentSize.height - tabView.frame.maxY)
        if self.isHiddenHeaderView {
            mainScrollView.contentOffset = CGPoint(x: 0, y: headerView.frame.height - titleBarHeight)
            self.isHiddenHeaderView = false
        }
    }

    // 预取，暂定预取前1和后1
    private func prefetchChildVC(currentIndex: Int) {
        let preIndex = max(0, currentIndex - 1)
        let afterIndex = min(tabCount - 1, currentIndex + 1)
        if self.childVCDic[preIndex] == nil {
            getChildVC(index: preIndex)
        }
        if self.childVCDic[afterIndex] == nil {
            getChildVC(index: afterIndex)
        }
    }
    
    private func getChildVC(index: Int) {
        if let childVC = delegate?.multiTabPageViewController(self, childViewController: index) {
            self.addChild(childVC)
            childVC.scrollDelegate = self
            childVCDic[index] = childVC
            if let scrollView = childVC.getScrollView() {
                mainScrollView.scrollViewWhites?.insert(scrollView)
            }
        }
    }
}

extension ZFMultiTabPageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var resultCell = UICollectionViewCell()
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ZFCommonTabItemCell.self), for: indexPath) as? ZFCommonTabItemCell {
            if let childVC = self.childVCDic[indexPath.row] {
                cell.configView(view: childVC.view)
                resultCell = cell
            } else {
                if let vc = delegate?.multiTabPageViewController(self, childViewController: indexPath.row) {
                    self.addChild(vc)
                    vc.scrollDelegate = self
                    childVCDic[indexPath.row] = vc
                    if let scview = vc.getScrollView() {
                        mainScrollView.scrollViewWhites?.insert(scview)
                    }
                    cell.configView(view: vc.view)
                    resultCell = cell
                }
            }
            
        }
        if indexPath.row < tabCount {
            delegate?.multiTabPageViewController?(self, displaying: indexPath.row)
        }
        return resultCell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row < tabCount {
            delegate?.multiTabPageViewController?(self, willDisplay: indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row < tabCount {
            delegate?.multiTabPageViewController?(self, didEndDisplaying: indexPath.row)
        }
    }
        
}

extension ZFMultiTabPageViewController: ZFMultiTabChildPageDelegate {

    func commonTabChildViewController(_ viewController: ZFMultiTabChildPageViewController, scrollViewDidScroll scrollView: UIScrollView) {
        if mainScrollView.contentOffset.y < (headerView.frame.height - titleBarHeight) {
            let child = childVCDic[currentIndex]
            child?.offsetY = 0
        }
    }
}

extension ZFMultiTabPageViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.mIsClickTitle = false
        self.startOffsetX = scrollView.contentOffset.x
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        mainScrollView.isScrollEnabled = true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        mainScrollView.isScrollEnabled = true
        currentIndex = collectionView.indexPathsForVisibleItems.first?.row ?? 0
        if scrollView == collectionView {
            delegate?.multiTabPageViewController(self, pageScrollViewDidEndDecelerating: scrollView)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        mainScrollView.isScrollEnabled = true
        if scrollView == collectionView {
            delegate?.multiTabPageViewController(self, pageScrolllViewDidEndScrollingAnimation: scrollView)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainScrollView {
            mainScrollView.isScrollEnabled = true
            if currentIndex < tabCount {
                if let child = childVCDic[currentIndex] {
                    if child.offsetY > 0 || scrollView.contentOffset.y >= headerView.frame.height - titleBarHeight {
                        scrollView.contentOffset = CGPoint(x: 0, y: headerView.frame.height - titleBarHeight)
                    } else {
                        childVCDic.forEach { (dic: (key: Int, value: ZFMultiTabChildPageViewController)) in
                            dic.value.offsetY = 0
                        }
                    }
                }
            }
            delegate?.multiTabPageViewController(self, mainScrollViewDidScroll: mainScrollView)
        } else if scrollView == collectionView {
            if !mIsClickTitle {
                delegate?.multiTabPageViewController(self, pageScrollViewDidScroll: scrollView)
            }
        }
    }
}


