//
//  PlaceholderView.swift
//  PlayPa
//
//  Created by wmkj on 2022/7/29.
//

import UIKit
import SnapKit

public enum PlaceholderViewType: Int{
    case networkError = 0
    case other
}

public enum PlaceholderImage: RawRepresentable{
    public init?(rawValue: String) {
        switch rawValue{
        case "pp_empty_icon":
            self = .common
        case "pp_network_error_icon":
            self = .network_faile
        case "common_order_empty_icon":
            self = .order
        default:
            return nil
        }
    }
    
    case common
    case network_faile
    case order
    case other(img: UIImage)
    
    public typealias RawValue = String
    public var rawValue: RawValue{
        switch self {
        case .common:
            return "common_placeholder_img"
        case .network_faile:
            return "pp_network_error_icon"
        case .order:
            return "common_order_empty_icon"
        case .other:
            return "img"
        }
    }
}

open class PlaceholderView: UIView {

    private var placeHolderIcon: PlaceholderImage = .common
    private var offsetY: Double = 0
    private var placeHolderText: String = ""
    private var refreshBlock: (()->())?
    
    @discardableResult
   public convenience init(size: CGSize = .zero, offsetY: Double = 0, placeHolderIcon icon: PlaceholderImage = .common, placeHolderText text: String = "暂无数据~", refreshBlock:(()->())? = nil) {
        self.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        self.placeHolderIcon = icon
        self.placeHolderText = text
        self.offsetY = offsetY
        self.refreshBlock = refreshBlock
        initDatas()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        placeHolderView.snp.makeConstraints { make in
            make.top.equalTo(offsetY)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(dtSize(150))
        }
        
        placeHolderLabel.snp.makeConstraints { make in
            make.top.equalTo(placeHolderView.snp.bottom).offset(dtSize(20))
            make.centerX.width.equalToSuperview()
            make.height.equalTo(dtSize(20))
        }
       
        refreshBtn.snp.makeConstraints { make in
            make.top.equalTo(placeHolderLabel.snp.bottom).offset(dtSize(20))
            make.centerX.equalToSuperview()
            make.width.equalTo(dtSize(110))
            make.height.equalTo(dtSize(40))
        }
    }
    
    func initViews(){
        self.addSubview(placeHolderView)
        self.addSubview(placeHolderLabel)
        self.addSubview(refreshBtn)
        
        self.refreshBtn.isHidden = true
    }
    
    // MARK: private method
    private func dtSize(_ width: CGFloat) -> CGFloat {
        if self.frame.size.width == 0 {
            return width
        }
        return width * (self.frame.size.width / UIScreen.main.bounds.size.width)
    }
    
    func initDatas(){
        switch self.placeHolderIcon {
        case .other(let img):
            placeHolderView.image = img
        default:
            placeHolderView.image = loadImageBundle(named: self.placeHolderIcon.rawValue)
        }
        placeHolderLabel.text = self.placeHolderText
    }
    
    // MARK: event response
    @objc func didClickRefreshBtnAction() {
        self.refreshBlock?()
    }
    
    // MARK: public method
    public func updateText(text: String) {
        placeHolderLabel.text = text
    }
    
    public func updateIcon(icon: PlaceholderImage) {
        switch self.placeHolderIcon {
        case .other(let img):
            placeHolderView.image = img
        default:
            placeHolderView.image = loadImageBundle(named: self.placeHolderIcon.rawValue)
        }
    }
    
    private var placeholderViewType: PlaceholderViewType = .other
    public func updatePlaceholderViewType(type: PlaceholderViewType) {
        if type == .other, self.placeholderViewType == .networkError {
            updateText(text: self.placeHolderText)
            return
        }
        switch type {
        case .networkError:
            self.refreshBtn.isHidden = false
            updateText(text: "通往\(UIDevice.appName)的网络故障了～")
            updateIcon(icon: .network_faile)
        case .other:
            self.refreshBtn.isHidden = true
            updateText(text: self.placeHolderText)
            updateIcon(icon: self.placeHolderIcon)
            
        }
        self.placeholderViewType = type
    }
    
    
    // MARK: private method
    
    // MARK: set
    
    // MARK: get
    private lazy var placeHolderView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    private lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: dtSize(14), weight: .regular)
        label.textColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var refreshBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(red: 21/255, green: 120/255, blue: 255/255, alpha: 1)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = 10
        btn.titleLabel?.text = "点击刷新"
        btn.addTarget(self, action: #selector(didClickRefreshBtnAction), for: .touchUpInside)
        return btn
    }()
    
    internal func loadImageBundle(named name: String) -> UIImage {
        let primaryBundle = Bundle(for: PlaceholderView.self)
        if let image = UIImage(named: name, in: .module, compatibleWith: nil) {
            // Load image from SPM if available
            return image
        } else if let image = UIImage(named: name, in: primaryBundle, compatibleWith: nil) {
            // Load image in cases where PKHUD is directly integrated
            return image
        } else if
            let subBundleUrl = primaryBundle.url(forResource: "PlaceholderView", withExtension: "bundle"),
            let subBundle = Bundle(url: subBundleUrl),
            let image = UIImage(named: name, in: subBundle, compatibleWith: nil)
        {
            return image
        }

        return UIImage()
    }
}
