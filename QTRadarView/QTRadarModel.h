//
//  QTRadarModel.h
//  QTRadarView
//
//  Created by QT on 2020/12/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QTRadarModel : NSObject

@property(nonatomic,copy) NSString *name;

@property(nonatomic,copy) NSString *total;

@property(nonatomic,copy) NSString *my;

@property(nonatomic,strong) NSNumber *length;


@end

NS_ASSUME_NONNULL_END
