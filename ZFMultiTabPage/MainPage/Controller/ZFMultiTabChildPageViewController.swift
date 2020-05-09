//
//  ZFMultiTabChildPageViewController.swift
//  FortuneCatApp
//
//  Created by Flying on 2020/4/28.
//  Copyright © 2020 mflywork. All rights reserved.
//

import Foundation

protocol ZFMultiTabChildPageDelegate: NSObjectProtocol {
    func commonTabChildViewController(_ viewController: ZFMultiTabChildPageViewController, scrollViewDidScroll scrollView: UIScrollView)
}

class ZFMultiTabChildPageViewController: UIViewController {

    // 主要用来控制mainScrollView在上下滑动的时候在没到阈值的时候让child view相对静止
    public var offsetY: CGFloat = 0.0
    public var isCanScroll: Bool = false
    public weak var scrollDelegate: ZFMultiTabChildPageDelegate?
    public func getScrollView () -> UIScrollView? {
        return nil
    }
}
