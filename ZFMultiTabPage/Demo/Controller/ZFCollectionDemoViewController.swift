//
//  FCWaterfallViewController.swift
//  FortuneCatApp
//
//  Created by Flying on 2019/11/4.
//  Copyright © 2020 mflywork. All rights reserved.
//

import UIKit

protocol ZFCollectionDemoViewControllerDelegate: NSObjectProtocol {
    func waterfallViewController(_ viewController: ZFCollectionDemoViewController, scrollViewDidScroll scrollView: UIScrollView)
}

class ZFCollectionDemoViewController: ZFMultiTabChildPageViewController {

    var collectionViewTopPadding: CGFloat = 0
    var beginPoint: CGPoint = CGPoint.zero // 记录开始滑动的起始点
    weak var delegate: ZFCollectionDemoViewControllerDelegate?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        let frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        return collectionView
    }()

    //MARK: - Private Property
    private var toIndex: Int = 0
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    deinit {
        
    }
    
    //MARK: - Public Mehtods
    
    //MARK: - Override FCCommonTabChildViewController
    override var offsetY: CGFloat {
        set {
            collectionView.contentOffset = CGPoint(x: 0, y: newValue)
        }
        get {
            return collectionView.contentOffset.y
        }
    }
    
    override var isCanScroll: Bool {
        didSet{
            if isCanScroll {
                collectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
            }
        }
    }
    
    override func getScrollView() -> UIScrollView? {
        return collectionView
    }

    //MARK: - Data
    public func loadData() {
        
    }

    private func loadMoreData() {
        
    }
    
    //MARK: - Private Mehtods
    private func configSubviews() {
        self.view.backgroundColor = .white
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ZFColloectionDemoItemCell.self, forCellWithReuseIdentifier: NSStringFromClass(ZFColloectionDemoItemCell.self))
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
    }
    
}
extension ZFCollectionDemoViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        beginPoint = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.commonTabChildViewController(self, scrollViewDidScroll: scrollView)
        delegate?.waterfallViewController(self, scrollViewDidScroll: scrollView)
    }
}

extension ZFCollectionDemoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ZFColloectionDemoItemCell.self), for: indexPath) as? ZFColloectionDemoItemCell {
            cell.configView(color: .randomColor)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: (UIScreen.main.bounds.size.width - 40) / 2, height: 200.0)
        return size
    }
}


extension UIColor {
    //返回随机颜色
    class var randomColor: UIColor {
        get
        {
            let red = CGFloat(arc4random() % 256) / 255.0
            let green = CGFloat(arc4random() % 256) / 255.0
            let blue = CGFloat(arc4random() % 256) / 255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}
