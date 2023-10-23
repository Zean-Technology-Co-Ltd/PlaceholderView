//
//  UICollectionView+PlaceholderView.swift
//  NiuNiuRent
//
//  Created by Q Z on 2023/5/4.
//

import UIKit
import FoundationEx

private var PlaceHoldViewKey: UInt8 = 0
private var UIntKey: UInt8 = 0

extension UICollectionView: Swizzling{
    @objc public static func awake() {
        let originalSelectors = [
            #selector(reloadData),
            #selector(reloadItems(at:)),
            #selector(reloadSections),
            #selector(deleteSections),
            #selector(insertSections),
            #selector(deleteItems(at:)),
            #selector(insertItems(at:))
        ]
        
        let swizzledSelectors = [
            #selector(nn_reloadData),
            #selector(nn_reloadItems(at:)),
            #selector(nn_reloadSections),
            #selector(nn_deleteSections),
            #selector(nn_insertSections),
            #selector(nn_deleteItems(at:)),
            #selector(nn_insertItems(at:))
        ]
        for (idx, originalMethod) in originalSelectors.enumerated() {
            swizzlingForClass(self, originalSelector: originalMethod, swizzledSelector: swizzledSelectors[idx])
        }
    }
    
    @objc private func nn_reloadData(){
        self.nn_reloadData()
        self.nn_setupPlaceholdViewStatus()
    }
  
    @objc private func nn_reloadItems(at indexPaths: [IndexPath]){
        self.nn_reloadItems(at: indexPaths)
        self.nn_setupPlaceholdViewStatus()
    }
    
    @objc private func nn_reloadSections(_ sections: IndexSet){
        self.nn_reloadSections(sections)
        self.nn_setupPlaceholdViewStatus()
    }
    
    @objc private func nn_deleteSections(_ sections: IndexSet){
        self.nn_deleteSections(sections)
        self.nn_setupPlaceholdViewStatus()
    }
    @objc private func nn_insertSections(_ sections: IndexSet){
        self.nn_insertSections(sections)
        self.nn_setupPlaceholdViewStatus()
    }
    
    @objc private func nn_deleteItems(at indexPaths: [IndexPath]){
        self.nn_deleteItems(at: indexPaths)
        self.nn_setupPlaceholdViewStatus()
    }
    
    @objc private func nn_insertItems(at indexPaths: [IndexPath]){
        self.nn_insertItems(at: indexPaths)
        self.nn_setupPlaceholdViewStatus()
    }
    
    private func nn_setupPlaceholdViewStatus(){
        self.flag! += 1
        guard let placeHoldView = self.placeHoldView else { return }
        if self.flag! <= 1 || self.flag! == NSNotFound || CGSizeEqualToSize(self.bounds.size, CGSizeZero) {
            placeHoldView.isHidden = true
            return;
        }
        if self.totalDataCount > 0 {
            placeHoldView.isHidden = true
        }else{
            placeHoldView.isHidden = false
        }
    }
    
    private var totalDataCount: Int{
        var totalCount = 0
        for section in 0..<self.numberOfSections {
            let rowsInSection = self.numberOfItems(inSection: section)
            totalCount += rowsInSection
        }
        return totalCount;
    }
    
    public var placeHoldView: PlaceholderView? {
        get {
            return objc_getAssociatedObject(self, &PlaceHoldViewKey) as? PlaceholderView
        }
        set {
            if let newValue = newValue {
                newValue.isHidden = true
                self.backgroundView = newValue
                objc_setAssociatedObject(
                    self, &PlaceHoldViewKey, newValue as PlaceholderView, .OBJC_ASSOCIATION_ASSIGN)
            }
        }
    }
    
    private var flag: UInt? {
        get {
            return objc_getAssociatedObject(self, &UIntKey) as? UInt ?? 0
        }
        set {
            if let newValue = newValue{
                objc_setAssociatedObject(
                    self, &UIntKey, newValue as UInt, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}
