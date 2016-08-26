//
//  ViewController.swift
//  KYDivisionPickerView
//
//  Created by 徐开源 on 16/8/26.
//  Copyright © 2016年 kyxu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, KYDivisionPickerViewDelegate {
    
    let divisionLabel = UILabel(frame: CGRectMake(
        16, UIScreen.mainScreen().bounds.height*0.3,
        UIScreen.mainScreen().bounds.width-32, 21))
    let divisionPicker = KYDivisionPickerView(frame: CGRectMake(
        0, UIScreen.mainScreen().bounds.height*0.4,
        UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height*0.6))
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        divisionLabel.text = "KYDivisionPickerViewDemo"
        divisionLabel.textAlignment = .Center
        divisionLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(divisionLabel)
        
        /*
         divisionPicker.adjustsFontSizeToFitWidth default is false
         divisionPicker.fontSize default is 14
         divisionPicker.textColor default is UIColor.blackColor()
         */
        divisionPicker.divisionDelegate = self
        view.addSubview(divisionPicker)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - KYDivisionPickerViewDelegate
    func didGetAddressFromPickerView(provinceName provinceName: String?, cityName: String?, countyName: String?, streetName: String?) {
        var result = ""
        if let pro = provinceName { result += pro }
        if let cit = cityName where cityName != provinceName { result += " | " + cit } // 防止直辖市的省级、市级行政单位名称重合
        if let cou = countyName { result += " | " + cou }
        if let str = streetName { result += " | " + str }
        divisionLabel.text = result
    }
}

