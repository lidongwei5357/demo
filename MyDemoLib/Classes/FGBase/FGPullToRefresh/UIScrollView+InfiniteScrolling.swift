//
//  UIScrollView+InfiniteScrolling.swift
//  FGBase
//
//  Created by kun wang on 2019/09/05.
//

import UIKit

let kFGInfiniteScrollingViewHeight: CGFloat = 60;

@objc public enum InfiniteScrollingState: Int {
    case stopped = 0
    case triggered = 1
    case loading = 2
    case all = 10
}

@objc public class FGInfiniteScrollingView: UIView {
    @objc public private(set) var state: InfiniteScrollingState = .stopped {
        didSet {
            if state == oldValue { return } //相同的设置不应该重复执行下面的逻辑
            for otherView in viewForState {
                otherView.value.removeFromSuperview()
            }

            if let customView = viewForState[state] {
                addSubview(customView)
                let viewBounds = customView.bounds
                let origin = CGPoint(x: round((bounds.size.width - viewBounds.size.width) / 2),
                                     y: round((bounds.size.height - viewBounds.size.height) / 2))
                customView.frame = CGRect(x: origin.x, y: origin.y, width: viewBounds.size.width, height: viewBounds.size.height)
            } else {
                let viewBounds = activityIndicatorView.bounds
                let origin = CGPoint(x: round((UIScreen.main.bounds.size.width - viewBounds.size.width) / 2 - 40),
                                     y: round((bounds.size.height - viewBounds.size.height) / 2))
                activityIndicatorView.frame = CGRect(x: origin.x, y: origin.y, width: viewBounds.size.width, height: viewBounds.size.height)
                tipsLabel.center = CGPoint(x: activityIndicatorView.frame.origin.x + activityIndicatorView.frame.size.width + 10 + tipsLabel.frame.size.width / 2, y: bounds.size.height / 2)

                switch state {
                case .stopped:
                    stopIndicatorAnimating()
                    tipsLabel.isHidden = true
                    activityIndicatorView.isHidden = true
                case .triggered:
                    tipsLabel.isHidden = false
                    activityIndicatorView.isHidden = false
                    tipsLabel.text = "Loading...".baseTablelocalized
                    startIndicatorAnimating()
                case .loading:
                    tipsLabel.isHidden = false
                    tipsLabel.text = "Loading...".baseTablelocalized
                default:
                    break
                }
            }

            if oldValue == .triggered && state == .loading && enabled {
                handler?()
            }

        }
    }
    let enabled: Bool = true

    fileprivate var viewForState = [InfiniteScrollingState: UIView]()
    weak var scrollView: UIScrollView?

    fileprivate var handler: (()->Void)?
    fileprivate var isObserving: Bool = false
    fileprivate(set) var originalBottomInset: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleWidth
        addSubview(activityIndicatorView)
        addSubview(tipsLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func willMove(toSuperview newSuperview: UIView?) {
        if let scrollView = superview as? UIScrollView, newSuperview == nil {
            if isObserving {
                scrollView.removeObserver(self, forKeyPath: "contentOffset")
                scrollView.removeObserver(self, forKeyPath: "contentSize")
                isObserving = false
            }
        }
    }

    override public func layoutSubviews() {
        activityIndicatorView.center = CGPoint(x: UIScreen.main.bounds.size.width / 2 - 40, y: bounds.size.height / 2)
        tipsLabel.center = CGPoint(x: activityIndicatorView.frame.origin.x + activityIndicatorView.frame.size.width + 10 + tipsLabel.frame.size.width / 2, y: bounds.size.height / 2)
    }

    // MARK: - Scroll View
    func resetScrollViewContentInset() {
        var currentInsets = scrollView?.contentInset
        currentInsets?.bottom = originalBottomInset

        setScrollViewContentInset(currentInsets)
    }

    func setScrollViewContentInsetForInfiniteScrolling() {
        var currentInsets = scrollView?.contentInset
        currentInsets?.bottom = CGFloat(originalBottomInset + kFGInfiniteScrollingViewHeight)
        setScrollViewContentInset(currentInsets)
    }

    func setScrollViewContentInset(_ contentInset: UIEdgeInsets?) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.scrollView?.contentInset = contentInset ?? .zero
        })
    }

    // MARK: - Observing
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let point = change?[.newKey] as? NSValue {
                scrollViewDidScroll(point.cgPointValue)
            }
        } else if keyPath == "contentSize" {
            layoutSubviews()
            frame = CGRect(x: 0,
                           y: scrollView?.contentSize.height ?? 0,
                           width: bounds.size.width,
                           height: kFGInfiniteScrollingViewHeight)
        }
    }

    func scrollViewDidScroll(_ contentOffset: CGPoint) {
        guard let scrollView = scrollView else { return }
        if state != .loading && enabled {

            // To avoid triggering by the bounding motion from PullToRefresh
            if contentOffset.y <= 0 {
                if contentOffset.y < -60 {
                    state = .stopped
                }
                return
            }

            let scrollViewContentHeight = scrollView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.size.height

            if !scrollView.isDragging && state == .triggered {
                state = .loading
            } else if contentOffset.y > scrollOffsetThreshold && state == .stopped && scrollView.isDragging {
                state = .triggered
            }
        }
    }

    lazy var activityIndicatorView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: self.bounds.size.height - 45, width: 20, height: 20))
        view.image = "fg_ic_pull_load".baseImage
        view.contentMode = .center
        view.isHidden = true
        return view
    }()

    lazy var tipsLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        label.textColor = UIColor(red: 0.741, green: 0.741, blue: 0.741, alpha: 1)
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: 13)
        label.isHidden = true
        return label
    }()

    @objc public func setCustom(_ view: UIView, for state: InfiniteScrollingState) {
        if state == .all {
            viewForState[.loading] = view
            viewForState[.stopped] = view
            viewForState[.triggered] = view
        } else {
            viewForState[state] = view
        }
    }

    override public var tintColor: UIColor! {
        didSet {
            tipsLabel.textColor = tintColor
            activityIndicatorView.tintColor = tintColor
            activityIndicatorView.image = activityIndicatorView.image?.withRenderingMode(.alwaysTemplate)
        }
    }

    func triggerRefresh() {
        state = .triggered
        state = .loading
    }

    @objc public func startAnimating() {
        state = .loading
    }

    @objc public func stopAnimating() {
        state = .stopped
    }

    @objc public func endDataAnimating() {
        state = .stopped
        tipsLabel.isHidden = false
        tipsLabel.text = "End page".baseTablelocalized
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.stopIndicatorAnimating()
            self.tipsLabel.isHidden = true
            self.activityIndicatorView.isHidden = true
            self.resetScrollViewContentInset()
        }
    }

    func startIndicatorAnimating() {
        let monkeyAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        monkeyAnimation.toValue = NSNumber(value: 2.0 * .pi)
        monkeyAnimation.duration = 0.8
        monkeyAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        monkeyAnimation.isCumulative = false
        monkeyAnimation.isRemovedOnCompletion = false //No Remove
        monkeyAnimation.repeatCount = Float.greatestFiniteMagnitude
        activityIndicatorView.layer.add(monkeyAnimation, forKey: "AnimatedKey")
    }

    func stopIndicatorAnimating() {
        activityIndicatorView.layer.removeAllAnimations()
    }
}

private var AssociatedInfiniteViewTag: UInt8 = 99

// MARK: - Extension
extension UIScrollView {
    @objc public func addInfiniteScrolling(actionHandler: @escaping () -> Void) {
        let view = FGInfiniteScrollingView(frame: CGRect(x: 0, y: self.contentSize.height, width: self.bounds.size.width, height: kFGInfiniteScrollingViewHeight))
        view.handler = actionHandler
        view.scrollView = self
        view.originalBottomInset = self.contentInset.bottom
        addSubview(view)
        infiniteScrollingView = view
        showsInfiniteScrolling = true
    }

    @objc public func stopInfiniteScrolling() {
        infiniteScrollingView.stopAnimating()
    }

    @objc public private(set) var infiniteScrollingView: FGInfiniteScrollingView {
        get {
            return objc_getAssociatedObject(self, &AssociatedInfiniteViewTag) as! FGInfiniteScrollingView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedInfiniteViewTag, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }

    @objc public var showsInfiniteScrolling: Bool {
        set {
            infiniteScrollingView.isHidden = !newValue
            if !newValue {
                if infiniteScrollingView.isObserving {
                    removeObserver(infiniteScrollingView, forKeyPath: "contentOffset")
                    removeObserver(infiniteScrollingView, forKeyPath: "contentSize")
                    infiniteScrollingView.resetScrollViewContentInset()
                    infiniteScrollingView.isObserving = false
                }
            } else {
                if !infiniteScrollingView.isObserving {
                    addObserver(infiniteScrollingView, forKeyPath: "contentOffset", options: .new, context: nil)
                    addObserver(infiniteScrollingView, forKeyPath: "contentSize", options: .new, context: nil)
                    infiniteScrollingView.setScrollViewContentInsetForInfiniteScrolling()
                    infiniteScrollingView.isObserving = true

                    infiniteScrollingView.setNeedsLayout()
                    infiniteScrollingView.frame = CGRect(x: 0,
                                                         y: contentSize.height,
                                                         width: infiniteScrollingView.bounds.size.width,
                                                         height: kFGInfiniteScrollingViewHeight)
                }
            }


        }
        get {
            return infiniteScrollingView.isHidden
        }

    }
}
