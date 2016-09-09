//
//  ViewController.m
//  KYDivisionPickerViewDemo_ObjC
//
//  Created by 徐开源 on 16/9/4.
//  Copyright © 2016年 kyxu. All rights reserved.
//

#import "ViewController.h"
#import "KYDivisionPickerView.h"

@interface ViewController ()

@property(nonatomic, strong) UILabel *divisionLabel;
@property(nonatomic, strong) KYDivisionPickerView *divisionPicker;

@end

@implementation ViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _divisionLabel = [[UILabel alloc] initWithFrame:
                      CGRectMake(16, [UIScreen mainScreen].bounds.size.height*0.3,
                                 [UIScreen mainScreen].bounds.size.width-32, 21)];
    _divisionPicker = [[KYDivisionPickerView alloc] initWithFrame:
                      CGRectMake(0, [UIScreen mainScreen].bounds.size.height*0.4,
                                 [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height*0.6)];
    
    _divisionLabel.text = @"KYDivisionPickerViewDemo";
    _divisionLabel.textAlignment = NSTextAlignmentCenter;
    _divisionLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:_divisionLabel];
    
    /*
     _divisionPicker.adjustsFontSizeToFitWidth default is false
     _divisionPicker.fontSize default is 14
     _divisionPicker.textColor default is UIColor.blackColor()
     */
    _divisionPicker.textColor = [UIColor greenColor];
    _divisionPicker.divisionDelegate = self;
    [self.view addSubview:_divisionPicker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - KYDivisionPickerViewDelegate
-(void)didGetAddressFromPickerViewWithProvinceName:(NSString *)provinceName cityName:(NSString *)cityName countyName:(NSString *)countyName streetName:(NSString *)streetName {
    
    NSMutableString* result = [[NSMutableString alloc] initWithString:@""];
    [result appendString:provinceName];
    if (![cityName isEqualToString:provinceName]) { [result appendFormat:@" | %@", cityName]; }
    if (countyName.length != 0) { [result appendFormat:@" | %@", countyName]; }
    if (streetName.length != 0) { [result appendFormat:@" | %@", streetName]; }
    _divisionLabel.text = result;
}

@end
