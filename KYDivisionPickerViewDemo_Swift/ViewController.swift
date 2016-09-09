//
//  ViewController.swift
//  KYDivisionPickerView
//
//  Created by 徐开源 on 16/8/26.
//  Copyright © 2016年 kyxu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, KYDivisionPickerViewDelegate {
    
    let divisionLabel = UILabel(frame: CGRect(
        x: 16, y: UIScreen.main.bounds.height*0.3,
        width: UIScreen.main.bounds.width-32, height: 21))
    let divisionPicker = KYDivisionPickerView(frame: CGRect(
        x: 0, y: UIScreen.main.bounds.height*0.4,
        width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.6))
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        divisionLabel.text = "KYDivisionPickerViewDemo"
        divisionLabel.textAlignment = .center
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
    func didGetAddressFromPickerView(provinceName: String?, cityName: String?, countyName: String?, streetName: String?) {
        var result = ""
        if let pro = provinceName { result += pro }
        if let cit = cityName, cityName != provinceName { result += " | " + cit } // 防止直辖市的省级、市级行政单位名称重合
        if let cou = countyName { result += " | " + cou }
        if let str = streetName { result += " | " + str }
        divisionLabel.text = result
    }
}

