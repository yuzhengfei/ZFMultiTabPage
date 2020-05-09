//
//  ZFCollectionHeaderView.swift
//  ZFTabMenu
//
//  Created by Flying on 2020/5/8.
//  Copyright © 2020 mflywork. All rights reserved.
//

import Foundation

class ZFCollectionHeaderView: UIView {
    
    private lazy var bgView: UIImageView = {
        var bgView = UIImageView()
        bgView.image = UIImage(named: "header_bg")
        bgView.contentMode = .scaleToFill
        return bgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configViews() {
        self.addSubview(bgView)
        bgView.mas_makeConstraints { [weak self] (make: MASConstraintMaker!) in
            make.edges.equalTo()(self)
        }
    }
}
