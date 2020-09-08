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
    // 向外部索要 tab child vc
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
    
    // MARK: - Public Property
    var isHeaderViewHidden: Bool = false {
        didSet {
            if isHeaderViewHidden {
                mainScrollView.contentOffset = CGPoint(x: 0, y: headerView.frame.height - titleBarHeight)
            }
        }
    }
    
    var isBounces: Bool = false {
        didSet {
            self.mainScrollView.bounces = isBounces
        }
    }
    
    // 是否吸顶，并不允许垂直滑动
    var isCeiling: Bool = false {
        didSet {
            if isCeiling {
                mainScrollView.contentOffset = CGPoint(x: 0, y: headerView.frame.height - titleBarHeight)
            } else {
                mainScrollView.contentOffset = CGPoint(x: 0, y: 0)
            }
            mainScrollView.isScrollEnabled = !isCeiling
        }
    }
    
    // 是否允许横向滑动
    var isHorizontalScrollEnable: Bool = true {
        didSet {
            self.collectionView.isScrollEnabled = isHorizontalScrollEnable
        }
    }
    
    // 是否允许垂直滑动滑动
    var isVerticalScrollEnable: Bool = true {
        didSet {
            self.mainScrollView.isScrollEnabled = isVerticalScrollEnable
        }
    }
    
    // 是否需要重新布局
    var needRelayout: Bool = false {
        didSet {
            if (needRelayout) {
                self.view.setNeedsLayout()
            }
        }
    }
    
    // MARK: - Public Methods
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
    init(tabCount: Int, headerView: UIView, tabView: UIView, titleBarHeight: CGFloat, defaultIndex: Int = 0, isHiddenHeaderView: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.tabCount = tabCount
        self.headerView = headerView
        self.tabView = tabView
        self.titleBarHeight = titleBarHeight
        if defaultIndex < tabCount, defaultIndex >= 0 {
            self.currentIndex = defaultIndex
        }
        self.isHiddenHeaderView = isHiddenHeaderView
    }
    
    // 处理右滑退出手势冲突问题
    func handlePopGestureRecognizer(navi: UINavigationController) {
        if let popGestureRecognizer = navi.interactivePopGestureRecognizer {
            collectionView.panGestureRecognizer.require(toFail: popGestureRecognizer)
        }
    }

    func resetChildViewControllers(tabCount: Int) {
        // 清空原来的父控制器
        childVCDic.forEach { (dic: (key: Int, value: ZFMultiTabChildPageViewController)) in
            dic.value.removeFromParent()
        }
        mainScrollView.scrollViewWhites?.removeAll()
        self.childVCDic.removeAll()
        self.tabCount = tabCount
        self.collectionView.reloadData()
    }
    
    func move(to: Int, animated: Bool) {
        self.currentIndex = to
        mIsClickTitle = true
        view.isUserInteractionEnabled = false
        collectionView.scrollToItem(at: IndexPath.init(row: to, section: 0), at: .centeredHorizontally, animated: false)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.view.isUserInteractionEnabled = true
            self.mainScrollView.isScrollEnabled = true
            self.collectionView.isScrollEnabled = true
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isVerticalScrollEnable {
            isVerticalScrollEnable = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 左滑退出过程中禁止页面内上下滑动
        if isVerticalScrollEnable {
            isVerticalScrollEnable = false
        }
    }
    
    // 此方法是为了防止框架使用方（父view）的frame有改变时本view的frame无法同步改变
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainScrollView.frame = view.bounds
        mainScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        mainScrollView.contentSize = CGSize(width: 0, height: mainScrollView.frame.height + headerView.frame.height)
        tabView.frame.origin.y = headerView.frame.maxY
        collectionView.frame.origin.y = tabView.frame.maxY
        collectionView.frame.size = CGSize(width: view.frame.width, height: mainScrollView.frame.height - titleBarHeight - tabView.frame.height)
        if self.isHiddenHeaderView {
            mainScrollView.contentOffset = CGPoint(x: 0, y: headerView.frame.height - titleBarHeight)
            self.isHiddenHeaderView = false
        }
    }
    
    private func configViews() {
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(headerView)
        mainScrollView.addSubview(tabView)
        mainScrollView.addSubview(collectionView)
        mainScrollView.frame = view.bounds
        mainScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        mainScrollView.contentSize = CGSize(width: 0, height: mainScrollView.frame.height + headerView.frame.height)
        tabView.frame.origin.y = headerView.frame.maxY
        collectionView.frame.origin.y = tabView.frame.maxY
        collectionView.frame.size = CGSize(width: view.frame.width, height: mainScrollView.frame.height - titleBarHeight - tabView.frame.height)
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
        mainScrollView.isScrollEnabled = true
        collectionView.isScrollEnabled = true
        self.mIsClickTitle = false
        self.startOffsetX = scrollView.contentOffset.x
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        mainScrollView.isScrollEnabled = true
        collectionView.isScrollEnabled = true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        mainScrollView.isScrollEnabled = true
        collectionView.isScrollEnabled = true
        currentIndex = collectionView.indexPathsForVisibleItems.first?.row ?? 0
        if scrollView == collectionView {
            delegate?.multiTabPageViewController(self, pageScrollViewDidEndDecelerating: scrollView)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        mainScrollView.isScrollEnabled = true
        collectionView.isScrollEnabled = true
        if scrollView == collectionView {
            delegate?.multiTabPageViewController(self, pageScrolllViewDidEndScrollingAnimation: scrollView)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainScrollView {
            mainScrollView.isScrollEnabled = true
            collectionView.isScrollEnabled = false
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
            mainScrollView.isScrollEnabled = false
            collectionView.isScrollEnabled = true
            if !mIsClickTitle {
                delegate?.multiTabPageViewController(self, pageScrollViewDidScroll: scrollView)
            }
        }
    }
}


