//
//  FullScreenSlideshowViewController.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 31.08.15.
//

import UIKit

@objcMembers
open class FullScreenSlideshowViewController: UIViewController {

    open var slideshow: ImageSlideshow = {
        let slideshow = ImageSlideshow()
        slideshow.zoomEnabled = true
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill
        slideshow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
        // turns off the timer
        slideshow.slideshowInterval = 0
        slideshow.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]

        return slideshow
    }()

    /// Close button 
    open var closeButton = UIButton()


    /// Close button frame
    open var closeButtonFrame: CGRect?

    /// Title label
    open var titleLabel = UILabel()

    /// Title label
    open var titleLabelFont: UIFont? {
        didSet {
            titleLabel.font = titleLabelFont ?? titleLabelDefaultFont
        }
    }

    /// Closure called on page selection
    open var pageSelected: ((_ page: Int) -> Void)?

    /// Index of initial image
    open var initialPage: Int = 0

    /// Input sources to 
    open var inputs: [InputSource]?

    /// Background color
    open var backgroundColor = UIColor.black

    /// Enables/disable zoom
    open var zoomEnabled = true {
        didSet {
            slideshow.zoomEnabled = zoomEnabled
        }
    }

    fileprivate var isInit = true
    fileprivate let titleLabelDefaultFont = UIFont.systemFont(ofSize: 18.0)

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = backgroundColor
        slideshow.frame = view.frame
        slideshow.backgroundColor = backgroundColor
        slideshow.currentPageChanged = { [weak self] index in
            self?.setPhotoTitle(currentPhoto: index)
        }

        if let inputs = inputs {
            slideshow.setImageInputs(inputs)
        }

        view.addSubview(slideshow)

        // close button configuration
        closeButton.setImage(UIImage(named: "ic_cross_white", in: Bundle(for: type(of: self)), compatibleWith: nil), for: UIControlState())
        closeButton.addTarget(self, action: #selector(FullScreenSlideshowViewController.close), for: UIControlEvents.touchUpInside)
        view.addSubview(closeButton)

        // title label configuration
        titleLabel.font = titleLabelFont ?? titleLabelDefaultFont
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        setPhotoTitle(currentPhoto: initialPage)
    }

    override open var prefersStatusBarHidden: Bool {
        return true
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isInit {
            isInit = false
            slideshow.setCurrentPage(initialPage, animated: false)
        }
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        slideshow.slideshowItems.forEach { $0.cancelPendingLoad() }
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
    }

    open override func viewDidLayoutSubviews() {
        if !isBeingDismissed {
            let safeAreaInsets: UIEdgeInsets
            if #available(iOS 11.0, *) {
                safeAreaInsets = view.safeAreaInsets
            } else {
                safeAreaInsets = UIEdgeInsets.zero
            }
            
            closeButton.frame = closeButtonFrame ?? CGRect(x: max(10, safeAreaInsets.left), y: max(10, safeAreaInsets.top), width: 40, height: 40)

            let xOffset = closeButton.frame.origin.x + closeButton.frame.size.width + 10
            let width = view.frame.size.width - (2 * xOffset)
            titleLabel.frame = CGRect(x: xOffset, y: max(10, safeAreaInsets.top), width: width, height: 40)
        }

        slideshow.frame = view.frame
    }

    @objc func canRotate() -> Void {}

    private func setPhotoTitle(currentPhoto: Int) {
        let photos = inputs?.count ?? 0
        titleLabel.text = "\(currentPhoto + 1)/\(photos) Photos"
    }

    @objc func close() {
        // if pageSelected closure set, send call it with current page
        if let pageSelected = pageSelected {
            pageSelected(slideshow.currentPage)
        }

        dismiss(animated: true, completion: nil)
    }
}
