//
//  ZFDemoViewController.swift
//  ZFTabMenu
//
//  Created by Flying on 2020/5/8.
//  Copyright © 2020 mflywork. All rights reserved.
//

import Foundation

class ZFDemoViewController: UIViewController {
    
    private lazy var headerView: ZFCollectionHeaderView = {
        let headerView = ZFCollectionHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 270.0))
        return headerView
    }()
    
    private lazy var menuView: ZFMultipleTabView = {
        let menuConfig = ZFMultipleTabViewConfig()
        let menuView = ZFMultipleTabView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40), titles: ["热点", "推荐", "周边"], config: menuConfig)
        menuView.delegate = self
        return menuView
    }()
    
    // 悬浮控制器
    private lazy var commonTabVC: ZFMultiTabPageViewController = {
        let commonTabVC = ZFMultiTabPageViewController(tabCount: 3, headerView: headerView, tabView: menuView, titleBarHeight: 64.0)
        commonTabVC.delegate = self
        commonTabVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        // 处理右滑退出手势冲突
        if let navi = self.navigationController {
            commonTabVC.handlePopGestureRecognizer(navi: navi)
        }
        addChild(commonTabVC)
        commonTabVC.move(to: 0, animated: false)
        return commonTabVC
    }()
    
    private var childVCDic: [Int: ZFMultiTabChildPageViewController] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
    }
    
    private func configViews() {
        self.addChild(commonTabVC)
        self.view.addSubview(commonTabVC.view)
    }
    
}


extension ZFDemoViewController: ZFMultiTabPageDelegate {
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, mainScrollViewDidScroll scrollView: UIScrollView) {

    }
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, pageScrollViewDidScroll scrollView: UIScrollView) {
        menuView.pagerDidScroll(pager: scrollView)
    }
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, pageScrollViewDidEndDecelerating scrollView: UIScrollView) {
        if scrollView.bounds.size.width > 0 {
            menuView.pagerDidEndDecelerating(pager: scrollView)
        }
    }
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, pageScrolllViewDidEndScrollingAnimation scrollView: UIScrollView) {
        if scrollView.bounds.size.width > 0 {
            menuView.pagerDidEndScrollingAnimation(pager: scrollView)
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
        self.commonTabVC.move(to: selectedIndex, animated: false)
    }
}
