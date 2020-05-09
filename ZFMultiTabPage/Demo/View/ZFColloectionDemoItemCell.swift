//
//  ZFColloectionDemoItemCell.swift
//  ZFTabMenu
//
//  Created by Flying on 2020/5/8.
//  Copyright © 2020 mflywork. All rights reserved.
//

import Foundation

class ZFColloectionDemoItemCell: UICollectionViewCell {
    
    func configView(color: UIColor?) {
        colorView.backgroundColor = color
    }
    
    private lazy var colorView: UIView = {
        var colorView = UIView()
        return colorView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        colorView.backgroundColor = .clear
    }
    
    private func initViews() {
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(colorView)
        colorView.mas_makeConstraints { [weak self] (make: MASConstraintMaker!) in
            make.edges.equalTo()(self?.contentView)
        }
    }
}
