//
//  FDGridItemView.swift
//  FGBase
//
//  Created by kun wang on 2019/09/06.
//

import UIKit

@objc public enum PullToRefreshState: Int {
    case stopped
    case triggered
    case loading
    case all
}

@objc public class FGPullToRefreshView: UIView {

    var handler: (()->Void)?
    @objc public fileprivate(set) var state: PullToRefreshState = .stopped {
        didSet {
            if state == oldValue {
                return
            }

            setNeedsLayout()

            switch state {
            case .stopped:
                resetScrollViewContentInset()
            case .triggered:
                break
            case .loading:
                setScrollViewContentInsetForLoading()
                if oldValue == .triggered {
                    handler?()
                }
            default:
                break
            }
        }
    }

    var titles = [PullToRefreshState.loading: "Loading".baseTablelocalized,
                  PullToRefreshState.triggered: "Release to load...".baseTablelocalized]
    var subTitles = [PullToRefreshState: String]()
    var viewForState = [PullToRefreshState: UIView]()

    weak var scrollView: UIScrollView?

    var originalTopInset: CGFloat = 0

    var wasTriggeredByUser: Bool = false

    var showsPullToRefresh: Bool = false
    var isObserving: Bool = false
    var subTitleIsDate: Bool = true
    var lastUpdatedDate: Date? {
        didSet {
            subTitleIsDate = true
            let tips: String
            if let date = lastUpdatedDate {
                tips = "Last update:".baseTablelocalized + dateFormatter.string(from: date)
            } else {
                tips = "Never".baseTablelocalized
            }
            subtitleLabel.text = tips
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleWidth
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func willMove(toSuperview newSuperview: UIView?) {
        if let scrollView = superview as? UIScrollView, newSuperview == nil {
            if isObserving {
                scrollView.removeObserver(self, forKeyPath: "contentOffset")
                scrollView.removeObserver(self, forKeyPath: "frame")
                isObserving = false
            }
        }
    }

    override public func layoutSubviews() {

        for otherView in viewForState {
            otherView.value.removeFromSuperview()
        }

        let customView = viewForState[state]
        let hasCustomView = customView != nil

        titleLabel.isHidden = hasCustomView
        subtitleLabel.isHidden = hasCustomView
        imageView.isHidden = hasCustomView

        if let customView = customView {
            addSubview(customView)
            let viewBounds = customView.bounds
            let origin = CGPoint(x: round((bounds.size.width - viewBounds.size.width) / 2),
                                 y: round((bounds.size.height - viewBounds.size.height) / 2))
            customView.frame = CGRect(x: origin.x, y: origin.y, width: viewBounds.size.width, height: viewBounds.size.height)
        } else {
            let screenWidth = UIScreen.main.bounds.size.width
            let subtitle = subTitles[state]
            titleLabel.text = titles[state]
            titleLabel.sizeToFit()
            var titleFrame = titleLabel.frame
            titleFrame.origin.x = ceil(screenWidth / 2 - titleFrame.size.width / 2)
            titleFrame.origin.y = bounds.size.height - (subtitle != nil ? 48 : 40)
            titleFrame.size.height = 20
            titleLabel.frame = titleFrame

            var subtitleFrame = subtitleLabel.frame
            subtitleFrame.origin.x = ceil(screenWidth / 2 - subtitleFrame.size.width / 2)
            subtitleFrame.origin.y = titleFrame.size.height + titleFrame.origin.y
            subtitleLabel.frame = subtitleFrame
            subtitleLabel.text = subtitle

            var arrowFrame = imageView.frame
            arrowFrame.origin.x = ceil(titleFrame.origin.x - arrowFrame.size.width - 10)
            arrowFrame.origin.y = titleFrame.origin.y
            imageView.frame = arrowFrame

            switch state {
            case .triggered:
                startSpin()
            default:
                break
            }
        }
    }

    // MARK: - Actions
    @objc public func startAnimating() {
        guard let scrollView = scrollView else { return }
        if abs(scrollView.contentOffset.y) < .ulpOfOne {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: -frame.size.height), animated: true)
            wasTriggeredByUser = false
        } else {
            wasTriggeredByUser = true
        }
        state = .loading
    }

    @objc public func stopAnimating() {
        state = .stopped
        guard let scrollView = scrollView else { return }
        if !wasTriggeredByUser && scrollView.contentOffset.y < -originalTopInset {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: -originalTopInset), animated: true)
        }

        if subTitleIsDate {
            lastUpdatedDate = Date()
        }
        stopSpin()
    }

    @objc public func endDataAnimating() {
        state = .stopped
         guard let scrollView = scrollView else { return }
        if !wasTriggeredByUser && scrollView.contentOffset.y < -originalTopInset {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: -originalTopInset), animated: true)
        }

        if subTitleIsDate {
            subtitleLabel.text = "没有更多的数据了"
        }
        stopSpin()
    }

    // MARK: - Scroll View
    func resetScrollViewContentInset() {
        var currentInsets = scrollView?.contentInset
        currentInsets?.top = originalTopInset
        setScrollViewContentInset(currentInsets)
    }

    func setScrollViewContentInsetForLoading() {
        guard let scrollView = scrollView else { return }
        let offset = max(scrollView.contentOffset.y * -1, 0)
        var currentInsets = scrollView.contentInset
        currentInsets.top = min(offset, originalTopInset + bounds.size.height)
        setScrollViewContentInset(currentInsets)
    }

    func setScrollViewContentInset(_ contentInset: UIEdgeInsets?) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.scrollView?.contentInset = contentInset ?? .zero
            self.scrollView?.setContentOffset(CGPoint(x: 0, y: -(contentInset?.top ?? 0.0)), animated: false)
        })
    }

    // MARK: - Observing
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "contentOffset") {
            if let point = change?[.newKey] as? NSValue {
                scrollViewDidScroll(point.cgPointValue)
            }
        } else if (keyPath == "frame") {
            layoutSubviews()
        }
    }

    func scrollViewDidScroll(_ contentOffset: CGPoint) {
        guard let scrollView = scrollView else { return }
        if state != .loading {
            let scrollOffsetThreshold: CGFloat = frame.origin.y - originalTopInset

            if !scrollView.isDragging && state == .triggered {
                state = .loading
            } else if contentOffset.y < scrollOffsetThreshold && scrollView.isDragging && state == .stopped {
                state = .triggered
            } else if contentOffset.y >= scrollOffsetThreshold && state != .stopped {
                state = .stopped
            }
            //        NSLog(@"contentOffset.y is %f scrollOffsetThreshold is %f \n self.scrollView.isDragging is %d state is %d", contentOffset.y, scrollOffsetThreshold, self.scrollView.isDragging , self.state);
        } else {
            var offset = max(scrollView.contentOffset.y * -1, 0.0)
            offset = min(offset, originalTopInset + bounds.size.height)
            let contentInset = scrollView.contentInset
            scrollView.contentInset = UIEdgeInsets(top: offset, left: contentInset.left, bottom: contentInset.bottom, right: contentInset.right)
        }
    }

    // MARK: - Setter
    @objc public func setTitle(_ title: String?, for state: PullToRefreshState) {
        guard let title = title else { return }
        if state == .all {
            titles[.loading] = title
            titles[.triggered] = title
            titles[.stopped] = title
        } else {
            titles[state] = title
        }
        setNeedsLayout()
    }

    @objc public func setSubtitle(_ subtitle: String?, for state: PullToRefreshState) {
        guard let subtitle = subtitle else { return }
        if state == .all {
            subTitles[.loading] = subtitle
            subTitles[.triggered] = subtitle
            subTitles[.stopped] = subtitle
        } else {
            subTitles[state] = subtitle
        }
        setNeedsLayout()
    }

    @objc public func setCustomView(_ view: UIView?, for state: PullToRefreshState) {
        guard let view = view else { return }
        if state == .all {
            viewForState[.loading] = view
            viewForState[.triggered] = view
            viewForState[.stopped] = view
        } else {
            viewForState[state] = view
        }
        setNeedsLayout()
    }

    @objc override public var tintColor: UIColor! {
        didSet {
            titleLabel.textColor = tintColor
            subtitleLabel.textColor = tintColor
            imageView.tintColor = tintColor
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        }
    }

    // MARK: - Animations
    func startSpin() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = NSNumber(value: -Double.pi)
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        imageView.layer.add(animation, forKey: "AnimatedKey")

        let monkeyAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        monkeyAnimation.toValue = NSNumber(value: 2.0 * .pi)
        monkeyAnimation.duration = 0.8
        monkeyAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        monkeyAnimation.isCumulative = false
        monkeyAnimation.isRemovedOnCompletion = false //No Remove
        monkeyAnimation.repeatCount = Float.greatestFiniteMagnitude
        imageView.layer.add(monkeyAnimation, forKey: "AnimatedKey")

        let group = CAAnimationGroup()
        group.duration = 100
        group.animations = [animation, monkeyAnimation]
        imageView.layer.add(group, forKey: nil)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: {
            self.imageView.image = "fg_ic_pull_load".baseImage
        })

    }

    func stopSpin() {
        imageView.image = "fg_ic_pull_arrow".baseImage
        imageView.transform = CGAffineTransform(rotationAngle: .pi)
        imageView.layer.removeAllAnimations()
    }



    // MARK: - Views
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.contentMode = .center
        imageView.image = "fg_ic_pull_arrow".baseImage
        imageView.transform = CGAffineTransform(rotationAngle: .pi)
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 210, height: 20))
        label.text = "Pull to refresh...".baseTablelocalized
        label.font = .systemFont(ofSize: 11)
        label.backgroundColor = .clear
        label.textColor = UIColor(displayP3Red: 0.471, green: 0.510, blue: 0.569, alpha: 1.00)
        return label
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
        label.font = .systemFont(ofSize: 12)
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = UIColor(displayP3Red: 0.184, green: 0.239, blue: 0.325, alpha: 1.00)
        return label
    }()

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = .current
        return formatter
    }()
}

private var AssociatedPullToRefreshViewTag: UInt8 = 98
private let kFGPullToRefreshViewHeight: CGFloat = 60
extension UIScrollView {
    @objc public private(set) var pullToRefreshView: FGPullToRefreshView {
        get {
            return objc_getAssociatedObject(self, &AssociatedPullToRefreshViewTag) as! FGPullToRefreshView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedPullToRefreshViewTag, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }

    @objc public func addPullToRefresh(actionHandler: @escaping () -> Void) {

        addPulltoRefresh(height: kFGPullToRefreshViewHeight, actionHandler: actionHandler)
    }

    @objc public func addPulltoRefresh(height: CGFloat, actionHandler: @escaping () -> Void) {
        let view = FGPullToRefreshView(frame: CGRect(x: 0, y: -height, width: bounds.size.width, height: height))
        view.handler = actionHandler
        view.scrollView = self
        addSubview(view)

        view.originalTopInset = contentInset.top
        pullToRefreshView = view
        showsPullToRefresh = true
    }

    @objc public func triggerPullToRefresh() {
        pullToRefreshView.state = .triggered
        pullToRefreshView.startAnimating()
    }

    @objc public func stopRefreshing() {
        pullToRefreshView.state = .stopped
        pullToRefreshView.stopAnimating()
    }

    @objc public var showsPullToRefresh: Bool {
        get {
            return self.pullToRefreshView.isHidden
        }
        set {
            pullToRefreshView.isHidden = !newValue
            if !newValue {
                if pullToRefreshView.isObserving {
                    removeObserver(pullToRefreshView, forKeyPath: "contentOffset")
                    removeObserver(pullToRefreshView, forKeyPath: "frame")
                    pullToRefreshView.resetScrollViewContentInset()
                    pullToRefreshView.isObserving = false
                }
            } else {
                if !pullToRefreshView.isObserving {
                    addObserver(pullToRefreshView, forKeyPath: "contentOffset", options: .new, context: nil)
                    addObserver(pullToRefreshView, forKeyPath: "frame", options: .new, context: nil)
                    pullToRefreshView.isObserving = true
                }
            }
        }
    }

}

