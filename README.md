# KYDivisionPickerView
一个四列的 UIPickerView，可以滑动选择精确到街道的中国行政区划信息，并返回地址，使用简单。
<br>![ScreenShot](https://github.com/OpenMarshall/KYDivisionPickerView/raw/master/ScreenShot.png)

## Xcode 8 GM
提供 Swift 3 版本和 Objective-C 版本

## 如何使用
项目本身是使用 Demo，直接 Download ZIP，然后拷贝项目中的 <code>KYDivisionPickerView</code> 文件夹到你的项目中，即可使用 <code>KYDivisionPickerView</code> 类，与使用 <code>UIPickerView</code> 没有区别。

希望在滑动 <code>PickerView</code> 选择了地址之后，拿到地址字符串，需要遵守协议 <code>KYDivisionPickerViewDelegate</code>，实现协议中的方法 <br><code>func didGetAddressFromPickerView(provinceName provinceName:String?, cityName:String?, countyName:String?, streetName:String?)</code>
<br>方法中的四个参数即是 <code>KYDivisionPickerView</code> 选择的省、市、县、街道的名称字符串。

## 可配置项
    divisionPicker.adjustsFontSizeToFitWidth = true // default: false
    divisionPicker.fontSize = 12 // default: 14
    divisionPicker.textColor = UIColor.redColor() // default: UIColor.blackColor()

## 其他
数据来源于 [mumuy/data_location](https://github.com/mumuy/data_location)，感谢~
<br>Swift JSON 处理使用 [SwiftyJSON](https://github.com/IBM-Swift/SwiftyJSON)，已直接拷贝 <code>SwiftyJSON.swift</code> 文件到项目中。
