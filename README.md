### ZFMultiTabPage 组件介绍及使用方法

ZFMultiTabPage框架是采用Swift开发的多Tab框架，实现了：  

> - 可自定义头部视图(可控制显示与隐藏)  
> - 可自定义Tab视图(可个性化设置)  
> - 将一些通用多Tab框架里的由调用方向框架先创建好各个子tab视图再一起传入的机制优化成了==由框架向调用方通过代理方法索要各个子tab的视图，提升了加载速度，防止页面卡顿==  
> - 加入Tab子视图的==缓存机制==，避免了框架向调用方重复索要
> - 对视图滑动的多个回调事件进行了处理，并通过代理方法对面暴露，调用方可以在各种时机做相应的业务处理，例如预加载等等   
> - 解决了左滑退出手势冲突的问题
> - 加入了UIScrollView嵌套滑动手势互斥机制，优化了滑动体验

#### 1.主框架：ZFMultiTabPageViewController.swift 
文件路径：ZFMultiTabPage/MainPage/Controller  

此页面的结构主要包括三部分：
> - mainScrollView: 主view，用来实现整个页面的上下滑动效果
> - headerView: 头部view
> - tabView: 多tab view
> - collectionView: 用来实现每个tab对应的子页面的横滑效果，每个cell的宽度是一屏（bounds.size.width），cell的个数由外部传入，详细使用下面会介绍

具体使用方法如下代码：

```
/// 初始化方法
/// - Parameters:
///   - tabCount: tab数量
///   - headerView: 头部视图
///   - tabView: tab视图
///   - titleBarHeight: titleBar的高度
init(tabCount: Int, headerView: UIView, tabView: UIView, titleBarHeight: CGFloat) {
        
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
        
}
```


==注==：collectionView的cell在重用之前需要将原有的subview清掉，防止重复多次add

```
override func prepareForReuse() {
    super.prepareForReuse()
    for subView in self.contentView.subviews {
        subView.removeFromSuperview()
    }
}
```


#### 2.Tab的子页面：ZFMultiTabChildPageViewController.swift 

文件路径：ZFMultiTabPage/MainPage/Controller 

此VC主要是封装了一个基类，每个tab对应的页面都要继承此基类。

#### 3.多Tab组件：ZFMultipleTabView.swift 

文件路径：ZFMultiTabPage/Tab  

此多Tab组件对外提供了非常方便使用的三个接口，可以配合主框架的代理方法使用：

```
/// 视图滑动时调用
/// - Parameter pager: 滑动的子view
public func pagerDidScroll(pager: UIScrollView) {
        
}
    
/// 视图滑动开始减速调用
/// - Parameter pager: 滑动的子view
public func pagerDidEndDecelerating(pager: UIScrollView) {
        
}
    
/// 视图动画完成后调用
/// - Parameter pager: 滑动的子view
public func pagerDidEndScrollingAnimation(pager: UIScrollView) {
        
}
```
优点：
> - 不需要调用方自行的计算当前视图的此次滑动是滑动到了第几个子tab
> - 不需要调用方计算此次滑动是从第几个子tab滑动了第几个tab，==索引相关的计算都已经由此Tab组件完成==，大大的减轻了调用方的工作量。
> - 并配有如下配置文件（ZFMultipleTabViewConfig.swift），可以让调用方非常方便的自定义Tab按钮的选中和非选中状态下来的字体大小、颜色，以及追踪器的颜色、宽度比例、显示与隐藏：
> - 扩展性强，可以通过config配置文件去扩展现有的功能

```
class ZFMultipleTabViewConfig: NSObject {
    
    /** 是否显示底部分割线，默认为true */
    var showBottomSeparator: Bool = true
    /** 按钮之间的间距，默认为 20.0f */
    var spacingBetweenButtons: CGFloat = 20
    /** 标题文字字号大小，默认 15 号字体 */
    var titleFont: UIFont = UIFont.systemFont(ofSize: 15)
    /** 标题文字选中字号大小，默认 15 号字体 */
    var titleSelectedFont: UIFont = UIFont.systemFont(ofSize: 15)
    /** 普通状态下标题按钮文字的颜色，默认为黑色 */
    var titleColor: UIColor = UIColor.black
    /** 选中状态下标题按钮文字的颜色，默认为红色 */
    var titleSelectedColor: UIColor = UIColor.red
    /** 追踪器颜色，默认为红色 */
    var indicatorColor: UIColor = UIColor.red
    /** 追踪器高度，默认为 3.0f */
    var indicatorHeight: CGFloat = 3.0
    /** 追踪器宽度比，默认为 1.0f，与title同宽 */
    var indicatorWidthRate: CGFloat = 1.0
    /** 追踪器的圆角，默认为 2.0f */
    var indicatorCorner: CGFloat = 2.0
    /** 追踪器距离底部的距离，默认为 5.0f */
    var indicatorBottomDistance: CGFloat = 5.0
    
}
```

#### 4.Title组件：ZFTitleBar.swift 

文件路径：ZFMultiTabPage/Title  

此titleBar对外提供了做渐隐渐现动效的接口，用户可以自行设置maxScrollY属性的值，来控制主页面在上下滑动的时候bar的透明度

```
func setTransparent(_ offsetY: CGFloat) {
       
}
```


