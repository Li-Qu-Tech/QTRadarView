//
//  QTRadarModel.m
//  QTRadarView
//
//  Created by QT on 2020/12/7.
//

#import "QTRadarModel.h"

@implementation QTRadarModel

- (NSNumber *)length {
    
    if (_length) {
        
        return _length;
    }
    
    NSNumber *totalLength = @(186*kWidthScale);
    
    _length = @(_my.floatValue * totalLength.floatValue / _total.floatValue);
    
    return _length;
    
}

@end
