//
//  ZFTitleBar.swift
//  ZFMultiTabPage
//
//  此bar对外提供了做渐隐渐现动效的接口，用户可以自行设置maxScrollY属性的值，来控制主页面在上下滑动的时候bar的透明度
//
//  Created by yuzhengfei on 2020/5/9.
//  Copyright © 2020 mflywork. All rights reserved.
//

import Foundation

class ZFTitleBar: UIView {
    
    //最大上滑距离
    var maxScrollY: CGFloat = 0.0
    
    // 此view主要用来做渐隐渐现的动效
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.alpha = 0.0
        contentView.backgroundColor = .white
        return contentView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "ZFMultiTabPage"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configViews() {
        self.addSubview(contentView)
        contentView.addSubview(titleLabel)
        
        contentView.mas_makeConstraints { [weak self] (make: MASConstraintMaker!) in
            make.edges.equalTo()(self)
        }
        
        titleLabel.mas_makeConstraints { [weak self] (make: MASConstraintMaker!) in
            make.centerX.equalTo()(self)
            make.centerY.equalTo()(self)?.offset()(20.0)
        }
    }
    
}

// MARK: - Public Methods 对外
extension ZFTitleBar {
    func setTransparent(_ offsetY: CGFloat) {
        var alpha = 0.0
        if offsetY > 0, offsetY < maxScrollY {
            alpha = Double(offsetY / maxScrollY)
        } else if offsetY >= maxScrollY {
            alpha = 1.0
        }
        contentView.alpha = CGFloat(alpha)
    }
}
