//
//  KYDivisionPickerView.m
//  KYDivisionPickerViewDemo
//
//  Created by 徐开源 on 16/9/4.
//  Copyright © 2016年 kyxu. All rights reserved.
//

#import "KYDivisionPickerView.h"

@interface Location : NSObject
@property(nonatomic, assign) int num;
@property(nonatomic, strong) NSString* name;
@end
@implementation Location @end


@interface DivisionData : NSObject @end
@implementation DivisionData

+(NSDictionary*) divisionJson {
    
    NSString* path  = [[NSBundle mainBundle] pathForResource:@"KYDivisionPickerView_list" ofType:@"json"];
    // 将文件内容读取到字符串中，注意编码NSUTF8StringEncoding 防止乱码
    NSString* jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    // 将字符串写到缓冲区
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError* jsonError;
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
    return dic;
}

+(NSArray*) provinces {
    NSDictionary* dic = [DivisionData divisionJson];
    NSMutableArray* provincesArr = [[NSMutableArray alloc] init];
    // 添加数据
    NSEnumerator *enumerator = [dic keyEnumerator];
    NSString* key;
    while ((key = [enumerator nextObject])) {
        if ([key hasSuffix:@"0000"]) {
            Location* loc = [[Location alloc] init];
            loc.num = [key intValue];
            loc.name = [dic objectForKey: key];
            [provincesArr addObject: loc];
        }
    }
    [provincesArr sortUsingComparator:^NSComparisonResult(Location* obj1, Location* obj2) {
        return [obj1 num] > [obj2 num];
    }];
    return provincesArr;
}

+(NSMutableArray*) citiesWithProvinceNum:(int)provinceNum {
    NSDictionary* dic = [DivisionData divisionJson];
    // 确定索引
    NSString* provinceNumStr = [NSString stringWithFormat:@"%d", provinceNum];
    NSString* provinceNumPrefix = [provinceNumStr substringToIndex:2];
    NSMutableArray* citiesArr = [[NSMutableArray alloc] init];
    // 添加数据
    NSEnumerator *enumerator = [dic keyEnumerator];
    NSString* key;
    while ((key = [enumerator nextObject])) {
        if (([key hasPrefix:provinceNumPrefix]) && !([key hasSuffix:@"0000"]) && ([key hasSuffix:@"00"])) {
            Location* loc = [[Location alloc] init];
            loc.num = [key intValue];
            loc.name = [dic objectForKey: key];
            [citiesArr addObject: loc];
        }
    }
    if (citiesArr.count != 0) {
        [citiesArr sortUsingComparator:^NSComparisonResult(Location* obj1, Location* obj2) {
            return [obj1 num] > [obj2 num];
        }];
    }else {
        // 直辖市会获取不到下属的地级市，这时以直辖市本身作为地级市返回
        NSString* key = [provinceNumPrefix stringByAppendingString: @"0000"];
        Location* loc = [[Location alloc] init];
        loc.num = [key intValue];
        loc.name = [dic objectForKey: key];
        [citiesArr addObject: loc];
    }
    return citiesArr;
}

+(NSMutableArray*) countiesWithCityNum:(int)cityNum {
    NSDictionary* dic = [DivisionData divisionJson];
    // 确定索引
    NSString* cityNumStr = [NSString stringWithFormat:@"%d", cityNum];
    NSString* cityNumPrefix = [[NSString alloc] init];
    if ([cityNumStr hasSuffix: @"0000"]) { // 直辖市
        cityNumPrefix = [cityNumStr substringToIndex: 2];
    }else { // 地级市
        cityNumPrefix = [cityNumStr substringToIndex: 4];
    }
    NSMutableArray* countiesArr = [[NSMutableArray alloc] init];
    // 添加数据
    NSEnumerator *enumerator = [dic keyEnumerator];
    NSString* key;
    while ((key = [enumerator nextObject])) {
        if (([key hasPrefix:cityNumPrefix]) && !([key hasSuffix:@"00"])) {
            Location* loc = [[Location alloc] init];
            loc.num = [key intValue];
            loc.name = [dic objectForKey: key];
            [countiesArr addObject: loc];
        }
    }
    [countiesArr sortUsingComparator:^NSComparisonResult(Location* obj1, Location* obj2) {
        return [obj1 num] > [obj2 num];
    }];
    return countiesArr;
}

+(NSMutableArray*) streetsWithCountyNum:(int)countyNum {
    
    NSMutableArray* streetsArr = [[NSMutableArray alloc] init];
    
    // JSON
    NSString* jsonFileName = [NSString stringWithFormat:@"KYDivisionPickerView_%d", countyNum];
    NSString* path  = [[NSBundle mainBundle] pathForResource: jsonFileName ofType:@"json"];
    if (!path) {
        return streetsArr;
    }
    // 将文件内容读取到字符串中，注意编码NSUTF8StringEncoding 防止乱码
    NSString* jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    // 将字符串写到缓冲区
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError* jsonError;
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
    
    // 添加数据
    NSEnumerator *enumerator = [dic keyEnumerator];
    NSString* key;
    while ((key = [enumerator nextObject])) {
        Location* loc = [[Location alloc] init];
        loc.num = [key intValue];
        loc.name = [dic objectForKey: key];
        [streetsArr addObject: loc];
    }
    [streetsArr sortUsingComparator:^NSComparisonResult(Location* obj1, Location* obj2) {
        return [obj1 num] > [obj2 num];
    }];
    return streetsArr;
}

@end



@interface KYDivisionPickerView ()

@property(nonatomic, strong) NSArray* provinces;
@property(nonatomic, strong) NSMutableArray* cities;
@property(nonatomic, strong) NSMutableArray* counties;
@property(nonatomic, strong) NSMutableArray* streets;

@end

@implementation KYDivisionPickerView

#pragma mark - Life Cycle
-(instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        _adjustsFontSizeToFitWidth = NO;
        _fontSize  = 14;
        _textColor = [UIColor blackColor];
        
        _provinces = [DivisionData provinces];
        _cities    = [DivisionData citiesWithProvinceNum: 110000]; // 默认传参北京市
        _counties  = [DivisionData countiesWithCityNum: 110000]; // 默认传参北京市
        _streets   = [DivisionData streetsWithCountyNum: 110101]; // 默认传参（北京市）东城区
        
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    return self;
}


#pragma mark - UIPickerView
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 4; // 省、市、区、街道
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return _provinces.count;
            break;
        case 1:
            return _cities.count;
            break;
        case 2:
            return _counties.count;
            break;
        case 3:
            return _streets.count;
            break;
        default:
            return 0;
            break;
    }
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {

    UILabel* label = [[UILabel alloc] initWithFrame: CGRectMake(8, 0, self.frame.size.width/4 - 16, 30)];
    label.adjustsFontSizeToFitWidth = _adjustsFontSizeToFitWidth;
    label.font = [UIFont systemFontOfSize: _fontSize];
    label.textAlignment = NSTextAlignmentCenter;
    Location* loc = [[Location alloc] init];
    
    switch (component) {
        case 0:
            if (row < _provinces.count) { loc = _provinces[row]; }
            break;
        case 1:
            if (row < _cities.count) { loc = _cities[row]; }
            break;
        case 2:
            if (row < _counties.count) { loc = _counties[row]; }
            break;
        case 3:
            if (row < _streets.count) { loc = _streets[row]; }
            break;
        default:
            break;
    }
    
    if (loc.name.length != 0) { label.text = loc.name; }
    return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:
            if (row < _provinces.count) {
                Location* loc = _provinces[row];
                [self updateComponentForCityWithProvinceNum:loc.num];
            }
            break;
        case 1:
            if (row < _cities.count) {
                Location* loc = _cities[row];
                [self updateComponentForCountyWithCityNum:loc.num];
            }
            break;
        case 2:
            if (row < _counties.count) {
                Location* loc = _counties[row];
                [self updateComponentForStreetWithCountyNum:loc.num];
            }
            break;
        case 3:
            [self passAddressStr];
            break;
        default:
            break;
    }
}


#pragma mark - Update
-(void)updateComponentForCityWithProvinceNum:(int)provinceNum { // 修改省，更新市、县、街道
    _cities = [DivisionData citiesWithProvinceNum: provinceNum];
    [self reloadComponent: 1];
    [self selectRow:0 inComponent:1 animated:YES];
    if (_cities.count != 0) {
        Location* loc = _cities[0];
        [self updateComponentForCountyWithCityNum: loc.num];
    }else {
        [_counties removeAllObjects];
        [_streets removeAllObjects];
        [self reloadComponent: 2];
        [self reloadComponent: 3];
        [self passAddressStr];
    }
}

-(void)updateComponentForCountyWithCityNum:(int)cityNum { // 修改市，更新县、街道
    _counties = [DivisionData countiesWithCityNum: cityNum];
    [self reloadComponent:2];
    [self selectRow:0 inComponent:2 animated:YES];
    if (_counties.count != 0) {
        Location* loc = _counties[0];
        [self updateComponentForStreetWithCountyNum:loc.num];
    }else {
        [_streets removeAllObjects];
        [self reloadComponent:3];
        [self passAddressStr];
    }
}

-(void)updateComponentForStreetWithCountyNum:(int)countyNum { // 修改县，更新街道
    _streets = [DivisionData streetsWithCountyNum:countyNum];
    [self reloadComponent:3];
    [self selectRow:0 inComponent:3 animated:YES];
    [self passAddressStr];
}

-(void)passAddressStr {
    NSString* provinceStr = [[NSString alloc] init];
    NSInteger row = [self selectedRowInComponent:0];
    if (row < 0) { row = 0;}
    if (row < _provinces.count) {
        Location* loc = _provinces[row];
        provinceStr = loc.name;
    }
    
    NSString* cityStr = [[NSString alloc] init];
    row = [self selectedRowInComponent:1];
    if (row < 0) { row = 0;}
    if (row < _cities.count) {
        Location* loc = _cities[row];
        cityStr = loc.name;
    }
    
    NSString* countyStr = [[NSString alloc] init];
    row = [self selectedRowInComponent:2];
    if (row < 0) { row = 0;}
    if (row < _counties.count) {
        Location* loc = _counties[row];
        countyStr = loc.name;
    }
    
    NSString* streetStr = [[NSString alloc] init];
    row = [self selectedRowInComponent:3];
    if (row < 0) { row = 0;}
    if (row < _streets.count) {
        Location* loc = _streets[row];
        streetStr = loc.name;
    }
    
    if (_divisionDelegate != nil) {
        // 代理方法传出 PickerView 对应的地址字符串
        [_divisionDelegate didGetAddressFromPickerViewWithProvinceName:provinceStr
                                                                  cityName:cityStr
                                                                countyName:countyStr
                                                                streetName:streetStr];
    }
}

@end




