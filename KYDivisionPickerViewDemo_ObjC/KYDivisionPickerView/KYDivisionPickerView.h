//
//  KYDivisionPickerView.h
//  KYDivisionPickerViewDemo
//
//  Created by 徐开源 on 16/9/4.
//  Copyright © 2016年 kyxu. All rights reserved.
//

#import <UIKit/UIKit.h>

// 通过这个协议向 KYDivisionPickerView 的代理传递地址
@protocol KYDivisionPickerViewDelegate
- (void)didGetAddressFromPickerViewWithProvinceName: (NSString*) provinceName
                           cityName: (NSString*) cityName
                           countyName: (NSString*) countyName
                           streetName: (NSString*) streetName;
@end


@interface KYDivisionPickerView : UIPickerView <UIPickerViewDelegate, UIPickerViewDataSource>

// 可配置项
@property(nonatomic, assign) BOOL adjustsFontSizeToFitWidth;
@property(nonatomic, assign) CGFloat fontSize;
@property(nonatomic, strong) UIColor* textColor;

// 代理传值
@property(nonatomic, weak) id<KYDivisionPickerViewDelegate> divisionDelegate;

@end
