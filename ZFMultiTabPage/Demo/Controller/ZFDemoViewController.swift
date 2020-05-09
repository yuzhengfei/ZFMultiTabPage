//
//  ZFDemoViewController.swift
//  ZFTabMenu
//
//  Created by Flying on 2020/5/8.
//  Copyright © 2020 mflywork. All rights reserved.
//

import Foundation

class ZFDemoViewController: UIViewController {
    
    struct Constants {
        static let titleBarHeight: CGFloat = 88.0
        static let tabViewHeight: CGFloat = 40.0
    }
    
    private lazy var titleBar: ZFTitleBar = {
        let titleBar = ZFTitleBar()
        titleBar.maxScrollY = 20.0
        return titleBar
    }()
    
    private lazy var headerView: ZFCollectionHeaderView = {
        let headerView = ZFCollectionHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300.0))
        return headerView
    }()
    
    private lazy var tabView: ZFMultipleTabView = {
        let tabConfig = ZFMultipleTabViewConfig()
        let tabView = ZFMultipleTabView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Constants.tabViewHeight), titles: ["热点", "推荐", "周边"], config: tabConfig)
        tabView.delegate = self
        return tabView
    }()
    
    // 悬浮控制器
    private lazy var multiTabPageVC: ZFMultiTabPageViewController = {
        let multiTabPageVC = ZFMultiTabPageViewController(tabCount: 3, headerView: headerView, tabView: tabView, titleBarHeight: Constants.titleBarHeight)
        multiTabPageVC.delegate = self
        multiTabPageVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        // 处理右滑退出手势冲突
        if let navi = self.navigationController {
            multiTabPageVC.handlePopGestureRecognizer(navi: navi)
        }
        addChild(multiTabPageVC)
        multiTabPageVC.move(to: 0, animated: false)
        return multiTabPageVC
    }()
    
    private var childVCDic: [Int: ZFMultiTabChildPageViewController] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
    }
    
    private func configViews() {
        self.view.addSubview(titleBar)
        self.addChild(multiTabPageVC)
        self.view.addSubview(multiTabPageVC.view)
        
        titleBar.mas_makeConstraints { [weak self] (make: MASConstraintMaker!) in
            make.top.left()?.right()?.equalTo()(self?.view)
            make.height.equalTo()(Constants.titleBarHeight)
        }
        
        self.view.bringSubviewToFront(titleBar)
    }
    
}


extension ZFDemoViewController: ZFMultiTabPageDelegate {
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, mainScrollViewDidScroll scrollView: UIScrollView) {
        titleBar.setTransparent(scrollView.contentOffset.y)
    }
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, pageScrollViewDidScroll scrollView: UIScrollView) {
        tabView.pagerDidScroll(pager: scrollView)
    }
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, pageScrollViewDidEndDecelerating scrollView: UIScrollView) {
        if scrollView.bounds.size.width > 0 {
            tabView.pagerDidEndDecelerating(pager: scrollView)
        }
    }
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, pageScrolllViewDidEndScrollingAnimation scrollView: UIScrollView) {
        if scrollView.bounds.size.width > 0 {
            tabView.pagerDidEndScrollingAnimation(pager: scrollView)
        }
    }
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, childViewController index: Int) -> ZFMultiTabChildPageViewController? {
        if let childVC = self.childVCDic[index] {
            return childVC
        }
        let childVC = ZFCollectionDemoViewController.init()
        childVCDic[index] = childVC
        return childVC
    }

    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, willDisplay index: Int) {
        print("yzf ---> willDisplay = \(index)")
    }
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, displaying index: Int) {
        print("yzf ---> displaying = \(index)")
    }

    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, didEndDisplaying index: Int) {
        print("yzf ---> didEndDisplaying = \(index)")
    }
}

extension ZFDemoViewController: ZFMultipleTabViewDelegate {
    func selectedIndexInMultipleTabView(multipleTabView: ZFMultipleTabView, selectedIndex: Int) {
        self.multiTabPageVC.move(to: selectedIndex, animated: false)
    }
}
