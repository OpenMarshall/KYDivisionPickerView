//
//  KYDivisionPickerView.swift
//  Administrative Division
//
//  Created by 徐开源 on 16/8/25.
//  Copyright © 2016年 kyxu. All rights reserved.
//

import UIKit

// 通过这个协议向 KYDivisionPickerView 的代理传递地址
protocol KYDivisionPickerViewDelegate {
    func didGetAddressFromPickerView(
        provinceName:String?,
        cityName:String?,
        countyName:String?, streetName:String?)
}


class KYDivisionPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // 可配置项
    var adjustsFontSizeToFitWidth = false
    var fontSize: CGFloat = 14
    var textColor: UIColor = UIColor.black
    
    // 代理传值
    var divisionDelegate: KYDivisionPickerViewDelegate? = nil
    
    // 数据来源
    private let provinces = DivisionData.provinces()
    private var cities    = DivisionData.cities(provinceNum: 110000) // 默认传参北京市
    private var counties  = DivisionData.counties(cityNum: 110000) // 默认传参北京市
    private var streets   = DivisionData.streets(countyNum: 110101) // 默认传参（北京市）东城区
    
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4 // 省、市、区、街道
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return provinces.count
        case 1:
            return cities.count
        case 2:
            return counties.count
        case 3:
            return streets.count
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 8, y: 0, width: self.frame.width/4 - 16, height: 30))
        label.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textColor = textColor
        label.textAlignment = .center
        
        switch component {
        case 0:
            if row < provinces.count { label.text = provinces[row].name }
        case 1:
            if row < cities.count    { label.text = cities[row].name }
        case 2:
            if row < counties.count  { label.text = counties[row].name }
        case 3:
            if row < streets.count   { label.text = streets[row].name }
        default:
            break
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            if row < provinces.count { updateComponentForCity(provinceNum: provinces[row].num) }
        case 1:
            if row < cities.count    { updateComponentForCounty(cityNum: cities[row].num) }
        case 2:
            if row < counties.count  { updateComponentForStreet(countyNum: counties[row].num) }
        case 3:
            passAddressStr()
        default:
            break
        }
    }
    
    
    // MARK: - Update
    private func updateComponentForCity(provinceNum:Int) { // 修改省，更新市、县、街道
        cities = DivisionData.cities(provinceNum: provinceNum)
        self.reloadComponent(1)
        self.selectRow(0, inComponent: 1, animated: true)
        if cities.count != 0 {
            updateComponentForCounty(cityNum: cities[0].num)
        }else {
            counties.removeAll()
            streets.removeAll()
            self.reloadComponent(2)
            self.reloadComponent(3)
            passAddressStr()
        }
    }
    
    private func updateComponentForCounty(cityNum:Int) { // 修改市，更新县、街道
        counties = DivisionData.counties(cityNum: cityNum)
        self.reloadComponent(2)
        self.selectRow(0, inComponent: 2, animated: true)
        if counties.count != 0 {
            updateComponentForStreet(countyNum: counties[0].num)
        }else {
            streets.removeAll()
            self.reloadComponent(3)
            passAddressStr()
        }
    }
    
    private func updateComponentForStreet(countyNum:Int) { // 修改县，更新街道
        streets = DivisionData.streets(countyNum: countyNum)
        self.reloadComponent(3)
        self.selectRow(0, inComponent: 3, animated: true)
        passAddressStr()
    }
    
    private func passAddressStr() {
        var provinceStr: String? = nil
        var row = self.selectedRow(inComponent: 0)
        if row < 0 { row = 0 }
        if row < provinces.count {
            provinceStr = provinces[row].name
        }
        
        var cityStr: String? = nil
        row = self.selectedRow(inComponent: 1)
        if row < 0 { row = 0 }
        if row < cities.count {
            cityStr = cities[row].name
        }
        
        
        var countyStr: String? = nil
        row = self.selectedRow(inComponent: 2)
        if row < 0 { row = 0 }
        if row < counties.count {
            countyStr = counties[row].name
        }
        
        var streetStr: String? = nil
        row = self.selectedRow(inComponent: 3)
        if row < 0 { row = 0 }
        if row < streets.count {
            streetStr = streets[row].name
        }
        
        if let delegate = self.divisionDelegate {
            // 代理方法传出 PickerView 对应的地址字符串
            delegate.didGetAddressFromPickerView(
                provinceName: provinceStr, cityName: cityStr,
                countyName: countyStr, streetName: streetStr)
        }
    }
    
}


// 用这个类从 JSON 文件中获取内容
private class DivisionData {
    
    private struct Location {
        var num: Int
        var name: String
    }
    
    private class func divisionJson() -> JSON? {
        guard let divisionJsonFile = Bundle.main.path(forResource: "KYDivisionPickerView_list", ofType: "json")
            else {return nil}
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: divisionJsonFile))
            else {return nil}
        let json = JSON(data: data)
        return json
    }
    
    class func provinces() -> [Location] {
        guard let json = DivisionData.divisionJson() else {return [Location]()}
        var provincesArr = [Location]()
        // 添加数据
        for (index,subJson):(String, JSON) in json {
            if index.hasSuffix("0000") {
                if let num = Int(index) {
                    let loc = Location(num: num, name: String(describing: subJson.rawString))
                    provincesArr.append(loc)
                }
            }
        }
        provincesArr.sort(by: {$0.num < $1.num})
        return provincesArr
    }
    
    class func cities(provinceNum:Int) -> [Location] {
        guard let json = DivisionData.divisionJson() else {return [Location]()}
        // 确定索引
        let provinceNumPrefix = (String(provinceNum) as NSString).substring(to: 2)
        var citiesArr = [Location]()
        // 添加数据
        for (index,subJson):(String, JSON) in json {
            if index.hasPrefix(provinceNumPrefix) && !index.hasSuffix("0000") && index.hasSuffix("00") {
                if let num = Int(index) {
                    let loc = Location(num: num, name: String(describing: subJson.rawString))
                    citiesArr.append(loc)
                }
            }
        }
        if citiesArr.count != 0 {
            citiesArr.sort(by: {$0.num < $1.num})
        }else {
            // 直辖市会获取不到下属的地级市，这时以直辖市本身作为地级市返回
            let index = provinceNumPrefix + "0000"
            if let num = Int(index) {
                let loc = Location(num: num, name: String(describing: json[index].rawString))
                citiesArr.append(loc)
            }
        }
        return citiesArr
    }
    
    class func counties(cityNum:Int) -> [Location] {
        guard let json = DivisionData.divisionJson() else {return [Location]()}
        // 确定索引
        let cityNumStr = String(cityNum)
        let cityNumPrefix: String
        if cityNumStr.hasSuffix("0000") { // 直辖市
            cityNumPrefix = (cityNumStr as NSString).substring(to: 2)
        }else { // 地级市
            cityNumPrefix = (cityNumStr as NSString).substring(to: 4)
        }
        var countiesArr = [Location]()
        // 添加数据
        for (index,subJson):(String, JSON) in json {
            if index.hasPrefix(cityNumPrefix) && !index.hasSuffix("0") {
                if let num = Int(index) {
                    let loc = Location(num: num, name: String(describing: subJson.rawString))
                    countiesArr.append(loc)
                }
            }
        }
        countiesArr.sort(by: {$0.num < $1.num})
        return countiesArr
    }
    
    class func streets(countyNum:Int) -> [Location] {
        guard let divisionJsonFile = Bundle.main.path(forResource: "KYDivisionPickerView_\(countyNum)", ofType: "json")
            else {return [Location]()}
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: divisionJsonFile))
            else {return [Location]()}
        let json = JSON(data: data)
        var streetsArr = [Location]()
        // 添加数据
        for (index,subJson):(String, JSON) in json {
            if let num = Int(index) {
                let loc = Location(num: num, name: String(describing: subJson.rawString))
                streetsArr.append(loc)
            }
        }
        streetsArr.sort(by: {$0.num < $1.num})
        return streetsArr
    }

}
