//
//  UITableView+PlaceholderView.swift
//  NiuNiuRent
//
//  Created by Q Z on 2023/5/4.
//

import FoundationEx
import UIKit

private var PlaceHoldViewKey: UInt8 = 0
private var UIntKey: UInt8 = 0

extension UITableView: Swizzling{
    @objc public static func awake() {
        let originalSelectors = [
            #selector(reloadData),
            #selector(reloadRows(at: with:)),
            #selector(reloadSections(_: with:)),
            #selector(deleteSections(_: with:)),
            #selector(insertSections(_: with:)),
            #selector(deleteRows(at: with:)),
            #selector(insertRows(at: with:))
        ]
        
        let swizzledSelectors = [
            #selector(nn_reloadData),
            #selector(nn_reloadRows(at: with:)),
            #selector(nn_reloadSections(_: with:)),
            #selector(nn_deleteSections(_: with:)),
            #selector(nn_insertSections(_: with:)),
            #selector(nn_deleteRows(at: with:)),
            #selector(nn_insertRows(at: with:))
        ]
        for (idx, originalMethod) in originalSelectors.enumerated() {
            swizzlingForClass(self, originalSelector: originalMethod, swizzledSelector: swizzledSelectors[idx])
        }
    }
    
    @objc private func nn_reloadData(){
        self.nn_reloadData()
        self.nn_setupPlaceholdViewStatus()
    }
  
    @objc private func nn_reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation){
        self.nn_reloadRows(at: indexPaths, with: animation)
        self.nn_setupPlaceholdViewStatus()
    }
    
    @objc private func nn_reloadSections(_ sections: IndexSet, with animation: UITableView.RowAnimation){
        self.nn_reloadSections(sections, with: animation)
        self.nn_setupPlaceholdViewStatus()
    }
    
    @objc private func nn_deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation){
        self.nn_deleteSections(sections, with: animation)
        self.nn_setupPlaceholdViewStatus()
    }
    @objc private func nn_insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation){
        self.nn_insertSections(sections, with: animation)
        self.nn_setupPlaceholdViewStatus()
    }
    
    @objc private func nn_deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation){
        self.nn_deleteRows(at: indexPaths, with: animation)
        self.nn_setupPlaceholdViewStatus()
    }
    
    @objc private func nn_insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation){
        self.nn_insertRows(at: indexPaths, with: animation)
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
            let rowsInSection = self.numberOfRows(inSection: section)
            totalCount += rowsInSection
        }
        return totalCount;
    }
    
    var placeHoldView: PlaceholderView? {
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
