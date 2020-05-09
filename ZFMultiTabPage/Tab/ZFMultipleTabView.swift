//
//  ZFMultipleTabView.swift
//  FortuneCatApp
//
//  Created by Flying on 2020/5/8.
//  Copyright © 2020 mflywork. All rights reserved.
//

protocol ZFMultipleTabViewDelegate: NSObjectProtocol {
    func selectedIndexInMultipleTabView(multipleTabView: ZFMultipleTabView, selectedIndex: Int)
}

import UIKit

class ZFMultipleTabView: UIView {
    
    // MARK: - Public Preproty
    weak var delegate: ZFMultipleTabViewDelegate?
    
    // MARK: - Private Preproty
    private lazy var scrollView: UIScrollView = {
        let scrollV = UIScrollView(frame: self.bounds)
        scrollV.showsHorizontalScrollIndicator = false
        return scrollV
    }()
    
    // 底部分隔线
    private lazy var separatorLine: UIView = {
        let separatorLine = UIView(frame: CGRect(x: 0, y: self.height - 1, width: self.width, height: 1))
        separatorLine.backgroundColor = .white
        return separatorLine
    }()
    
    // 追踪器
    private lazy var indicatorView: UIView = {
        let indicatorView = UIView(frame: CGRect(x: 0, y: scrollView.height - (self.config?.indicatorBottomDistance ?? 5.0), width: 0, height: self.config?.indicatorHeight ?? 3.0))
        indicatorView.layer.cornerRadius = self.config?.indicatorCorner ?? 2
        indicatorView.backgroundColor = self.config?.indicatorColor
        return indicatorView
    }()
    
    //标题数组
    private var titles = [String]()
    //存储标题按钮的数组
    private var btnArr = [UIButton]()
    //选中标题按钮下标，默认为 0
    private var selectedIndex: Int = 0
    //按钮的总宽度
    private var allBtnWidth: CGFloat = 0
    private var lastBtn: UIButton?
    private var totalExtraWidth: CGFloat = 0
    private var indicatorViewWidth: CGFloat = 25.0
    private let buttonExpand: CGFloat = 15.0
    // tab的配置
    private var config: ZFMultipleTabViewConfig!
        
    init(frame: CGRect, titles: [String], config: ZFMultipleTabViewConfig, defaultIndex: Int = 0) {
        super.init(frame: frame)
        self.backgroundColor = .white
        if titles.count < 1 {
            return
        }
        self.titles = titles
        self.config = config
        if defaultIndex < titles.count, defaultIndex >= 0 {
            self.selectedIndex = defaultIndex
        }
        configViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //选中按钮下标初始值
        let lastBtn: UIButton = self.btnArr.last!
        if lastBtn.tag >= selectedIndex && selectedIndex >= 0 {
            btnDidClick(sender: self.btnArr[selectedIndex])
        }else {
            return
        }
    }
    
    // MARK: - Private Methods
    private func configViews() {
        //处理偏移量
        let tempView = UIView(frame: CGRect.zero)
        self.addSubview(tempView)
        self.addSubview(scrollView)
        if self.config.showBottomSeparator {
            self.addSubview(separatorLine)
        }
        scrollView.insertSubview(indicatorView, at: 0)
        configButtons()
    }
    
    private func configButtons() {
        var totalTextWidth: CGFloat = 0

        for title in self.titles {
            // 计算所有按钮的文字宽度
            let tempWidth = title.strWidth(font: self.config.titleFont, size: CGSize(width: 0, height: 0))
            totalTextWidth += tempWidth
        }
        
        // 所有按钮文字宽度 ＋ 按钮之间的间隔
        self.allBtnWidth = (self.config.spacingBetweenButtons) * (CGFloat)(self.titles.count + 1) + totalTextWidth
        
        let count: CGFloat = CGFloat(self.titles.count)
        if self.allBtnWidth <= self.bounds.width {
            var btnX: CGFloat = 0
            let btnY: CGFloat = 0
            let btnH: CGFloat = self.bounds.height
            
            for (index, title) in self.titles.enumerated() {
                var btnW: CGFloat = self.bounds.width / count
                let tempWidth = title.strWidth(font: (self.config.titleFont), size: CGSize(width: 0, height: 0)) + (self.config.spacingBetweenButtons)
                if tempWidth > btnW {
                    let extraWidth = tempWidth - btnW
                    btnW = tempWidth
                    totalExtraWidth += extraWidth
                }
                
                let btn = UIButton(type: .custom)
                btn.frame = CGRect(x: btnX, y: btnY, width: btnW, height: btnH)
                btnX += btnW
                btn.tag = index
                btn.setTitle(title, for: .normal)
                btn.setTitleColor(self.config.titleColor, for: .normal)
                btn.setTitleColor(self.config.titleSelectedColor, for: .selected)
                btn.titleLabel?.font = self.config.titleFont
                btn.addTarget(self, action: #selector(btnDidClick(sender:)), for: .touchUpInside)
                scrollView.addSubview(btn)
                btnArr.append(btn)
            }
        
            scrollView.contentSize = CGSize(width: self.bounds.width + totalExtraWidth, height: 0)
            
        }else {
            
            var btnX: CGFloat = 0
            let btnY: CGFloat = 0
            let btnH: CGFloat = self.bounds.height
            
            for (index, title) in self.titles.enumerated() {
                let btnW = title.strWidth(font: (self.config.titleFont), size: CGSize(width: 0, height: 0)) + (self.config.spacingBetweenButtons)
                let btn = UIButton(type: .custom)
                btn.frame = CGRect(x: btnX, y: btnY, width: btnW, height: btnH)
                btnX += btnW
                btn.tag = index
                btn.setTitle(title, for: .normal)
                btn.setTitleColor(self.config.titleColor, for: .normal)
                btn.setTitleColor(self.config.titleSelectedColor, for: .selected)
                btn.titleLabel?.font = self.config.titleFont
                btn.addTarget(self, action: #selector(btnDidClick(sender:)), for: .touchUpInside)
                scrollView.addSubview(btn)
                btnArr.append(btn)
            }
            let scrollViewWidth = scrollView.subviews.last?.frame.maxX
            scrollView.contentSize = CGSize(width: scrollViewWidth!, height: 0)
        }
        
    }
    
    private func adjustTrackerFrame(_ pagerOffseX: CGFloat, pageWidth: CGFloat) {
        var rect = indicatorView.frame
        if (pagerOffseX >= 0 && pagerOffseX <= pageWidth * CGFloat(btnArr.count-1)) {
            var progress = pagerOffseX / pageWidth
            let leftIndex = Int(floor(progress))
            let rightIndex = Int(ceil(progress))
            if leftIndex == rightIndex {
                rect.size.width = indicatorViewWidth
                rect.origin.x = btnArr[leftIndex].center.x - rect.size.width / 2
            } else {
                progress -= floor(progress)
                let middleX = btnArr[leftIndex].center.x
                if (progress > 0.5) {
                    let startW = indicatorViewWidth
                    let startX = btnArr[rightIndex].center.x - startW * 0.5
                    rect.origin.x = startX + (middleX - startX) * (1 - progress) * 2
                    rect.size.width = indicatorViewWidth
                } else {
                    let startW = indicatorViewWidth
                    let startX = btnArr[leftIndex].center.x - startW * 0.5
                    rect.origin.x = startX + (middleX - startX) * progress * 2
                    rect.size.width = indicatorViewWidth
                }
            }
        }
        indicatorView.frame = rect
    }
    
    private func adjustTabScrollView(animated: Bool) {
        var contentOffset = scrollView.contentOffset
        let offsetX = max(0, min(scrollView.contentSize.width - scrollView.bounds.size.width, indicatorView.center.x - scrollView.bounds.size.width / 2))
        contentOffset.x = offsetX
        if (animated) {
            UIView.animate(withDuration: 0.25, animations: { () in
                self.scrollView.contentOffset = contentOffset
            })
        } else {
            scrollView.contentOffset = contentOffset
        }
    }
    
    private func adjustTabButtonFont(pagerOffsetX: CGFloat, pageWidth: CGFloat) {
        if (pagerOffsetX >= 0 && pagerOffsetX <= pageWidth * CGFloat(btnArr.count-1)) {
            var progress = pagerOffsetX / pageWidth
            let leftIndex = Int(floor(progress))
            let rightIndex = Int(ceil(progress))
            if leftIndex != rightIndex && leftIndex >= 0 && leftIndex < btnArr.count && rightIndex >= 0 && rightIndex < btnArr.count {
                progress -= floor(progress)
            }
        }
    }
    
    /// 选中的button和非选中状态的button字体不一样，需要调整frame
    private func adjustButtonAtScrollEnd(offsetX: CGFloat, pageWidth: CGFloat) {
        let index = Int(offsetX / pageWidth + 0.5)
        let oldIndex = selectedIndex
        selectedIndex = index

        if oldIndex >= 0 && oldIndex < btnArr.count {
            let oldButton = btnArr[oldIndex]
            adjustButton(oldButton, selected: false)
        }

        if (selectedIndex >= 0 && selectedIndex < btnArr.count) {
            let selectedButton = btnArr[selectedIndex]
            adjustButton(selectedButton, selected: true)

            var rect = indicatorView.frame
            rect.size.width = indicatorViewWidth //(selectedButton.bounds.size.width - SSMSegmentTabView.buttonExpand) * trackerWidthRate
            rect.origin.x = selectedButton.center.x - rect.size.width / 2
            UIView.animate(withDuration: 0.5) {[weak self] in
                self?.indicatorView.frame = rect
            }
        }
    }
    
    private func adjustButton(_ button: UIButton, selected: Bool) {
        if (selected) {
            button.titleLabel?.font = config.titleSelectedFont
            button.setTitleColor(config.titleSelectedColor, for: .normal)
        } else {
            button.titleLabel?.font = config.titleFont
            button.setTitleColor(config.titleColor, for: .normal)
        }
        var size = button.titleLabel?.sizeThatFits(UIScreen.main.bounds.size) ?? .zero
        size = CGSize(width: ceil(size.width + buttonExpand), height: ceil(self.height))
        let center = button.center
        var rect = button.frame
        rect.size = size
        button.frame = rect
        button.center = center
    }
    
    // MARK: - Action
    @objc private func btnDidClick(sender:UIButton) {
        if let index = btnArr.firstIndex(of: sender) {
            let oldIndex = selectedIndex
            selectedIndex = index
            var rect = indicatorView.frame
            if oldIndex >= 0 && oldIndex < btnArr.count {
                let oldButton = btnArr[oldIndex]
                adjustButton(oldButton, selected: false)
            }
            if (selectedIndex >= 0 && selectedIndex < btnArr.count) {
                let selectedButton = btnArr[selectedIndex]
                adjustButton(selectedButton, selected: true)
            }
            
            rect.size.width = indicatorViewWidth
            rect.origin.x = sender.center.x - rect.size.width / 2
            UIView.animate(withDuration: 0.25, animations: { () in
                self.indicatorView.frame = rect
                self.adjustTabScrollView(animated: false)
            })
            delegate?.selectedIndexInMultipleTabView(multipleTabView: self, selectedIndex: selectedIndex)
        }
        
    }

}

// MARK: - Public Methos 对外提供的方法
extension ZFMultipleTabView {
    
    /// 视图滑动时调用
    /// - Parameter pager: 滑动的子view
    public func pagerDidScroll(pager: UIScrollView) {
        let offsetX = pager.contentOffset.x
        let pageWidth = pager.bounds.size.width
        adjustTrackerFrame(offsetX, pageWidth: pageWidth)
        adjustTabScrollView(animated: false)
        adjustTabButtonFont(pagerOffsetX: offsetX, pageWidth: pageWidth)
    }
    
    /// 视图滑动开始减速调用
    /// - Parameter pager: 滑动的子view
    public func pagerDidEndDecelerating(pager: UIScrollView) {
        let offsetX = pager.contentOffset.x
        let pageWidth = pager.bounds.size.width
        adjustButtonAtScrollEnd(offsetX: offsetX, pageWidth: pageWidth)
    }
    
    /// 视图动画完成后调用
    /// - Parameter pager: 滑动的子view
    public func pagerDidEndScrollingAnimation(pager: UIScrollView) {
        let offsetX = pager.contentOffset.x
        let pageWidth = pager.bounds.size.width
        adjustButtonAtScrollEnd(offsetX: offsetX, pageWidth: pageWidth)
    }
    
}




