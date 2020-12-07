//
//  QTRadarView.m
//  QTRadarView
//
//  Created by QT on 2020/12/7.
//

#import "QTRadarView.h"

@interface QTRadarView ()

@property(nonatomic,assign) CGPoint centerPoint;

@property(nonatomic,strong) NSArray *maxLengthArr;

@property(nonatomic,strong) CAShapeLayer *baseRadarShapeLayer;

@property(nonatomic,strong) CAShapeLayer *mineRadarShapeLayer;

@property(nonatomic,strong) NSMutableArray *labelArr;

@end

@implementation QTRadarView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.centerPoint = CGPointMake(main_Width / 2, 300*kWidthScale);
        
        [self setupUI];
    }
    return self;
}

#pragma mark - setter

- (void)setModelArr:(NSArray *)modelArr {
    
    _modelArr = modelArr;
    
    self.baseRadarShapeLayer.path = [self baseRectPathWith:modelArr.count];
    [self.layer addSublayer:self.baseRadarShapeLayer];
    
    NSMutableArray *myLengthArr = [NSMutableArray arrayWithCapacity:modelArr.count];

    NSInteger index = 0;

    NSArray *coordinates = [self converCoordinateFromLength:_maxLengthArr center:_centerPoint];

    for (QTRadarModel *model in modelArr) {

        [myLengthArr addObject:model.my];
        
        NSDictionary *dic = [self calculateLabelCenterWithTitle:model.name topPointValue:coordinates[index]];
        
        UILabel *label = [[UILabel alloc] init];
        
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:23*kWidthScale];
        label.text = model.name;
        
        CGFloat labelWidth = [dic[@"labelWidth"] floatValue];
        CGFloat labelHeight = [self heightOfString:model.name font:[UIFont systemFontOfSize:23*kWidthScale] width:labelWidth];

        label.frame = CGRectMake(0, 0, labelWidth, labelHeight);
        label.center = [dic[@"center"] CGPointValue];
        label.textAlignment = [dic[@"textAlignment"] integerValue];
        
        [self addSubview:label];

        index++;
    }
    
    if (myLengthArr.count) {

        //我的
        self.mineRadarShapeLayer.path = [self rectPathWith:myLengthArr];
        [self.layer addSublayer:self.mineRadarShapeLayer];

        //画圆点
        [self drawDotWithLengthArr:myLengthArr];
    }
}


#pragma mark - 设置界面
- (void)setupUI {
    
    self.backgroundColor = [UIColor grayColor];
}

#pragma mark - private

/**
 可变的雷达图的路径
 */
- (CGPathRef)rectPathWith:(NSArray *)lengthArr {
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    [self drawRectWithPath:bezierPath lengthArr:lengthArr];
    
    return bezierPath.CGPath;
}

/**
 画顶点圆点
 */
- (void)drawDotWithLengthArr:(NSArray *)lengthArr {
    
    NSArray *coordinates = [self converCoordinateFromLength:lengthArr center:_centerPoint];
    
    for (int i = 0; i < [coordinates count]; i++) {
        
        CGPoint point = [[coordinates objectAtIndex:i] CGPointValue];

        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:point radius:5*kWidthScale startAngle:0 endAngle:2 * M_PI clockwise:YES];

        CAShapeLayer *dotLayer = [CAShapeLayer layer];

        dotLayer.strokeColor = [UIColor blueColor].CGColor;
        dotLayer.fillColor = [UIColor blueColor].CGColor;
        
        dotLayer.path = bezierPath.CGPath;
        [self.layer addSublayer:dotLayer];
    }
}

/**
 底部多边形的路径
 */
- (CGPathRef)baseRectPathWith:(NSInteger)num {
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    NSNumber *length = @(186*kWidthScale);
    
    NSMutableArray *lengthArr = [NSMutableArray arrayWithCapacity:num];
    
    for (NSInteger i = 0; i < num; i++) {
        
        [lengthArr addObject:length];
    }
    
    _maxLengthArr = lengthArr.copy;
    
    //画最大的多边形
    [self drawRectWithPath:bezierPath lengthArr:lengthArr];
    
    //画线
    [self drawLineWithPath:bezierPath lengthArr:lengthArr];
    
    //画中间的多边形
    length = @(124*kWidthScale);
    
    [lengthArr removeAllObjects];
    
    for (NSInteger i = 0; i < num; i++) {
        
        [lengthArr addObject:length];
    }

    [self drawRectWithPath:bezierPath lengthArr:lengthArr];
    
    //画最小的多边形
    length = @(62*kWidthScale);
    
    [lengthArr removeAllObjects];
    
    for (NSInteger i = 0; i < num; i++) {
        
        [lengthArr addObject:length];
    }
    
    [self drawRectWithPath:bezierPath lengthArr:lengthArr];

    return bezierPath.CGPath;
}

/**
 画多边形
 */
- (void)drawRectWithPath:(UIBezierPath *)bezierPath lengthArr:(NSArray *)lengthArr {
    
    NSArray *coordinates = [self converCoordinateFromLength:lengthArr center:_centerPoint];
    
    for (int i = 0; i < [coordinates count]; i++) {
        
        CGPoint point = [[coordinates objectAtIndex:i] CGPointValue];
        
        if (i == 0) {
            [bezierPath moveToPoint:point];
        } else {
            [bezierPath addLineToPoint:point];
        }
    }
    
    [bezierPath closePath];
}

/**
 画线
 */
- (void)drawLineWithPath:(UIBezierPath *)bezierPath lengthArr:(NSArray *)lengthArr {
    
    NSArray *coordinateArr = [self converCoordinateFromLength:lengthArr center:_centerPoint];
    
    for (int i = 0; i < coordinateArr.count; i++) {
        
        CGPoint point = [[coordinateArr objectAtIndex:i] CGPointValue];
        
        [bezierPath moveToPoint:_centerPoint];
        [bezierPath addLineToPoint:point];
    }
}

/**
 以中心为参考点，计算每一个顶点的坐标，简单的三角函数应用
 */
- (NSArray *)converCoordinateFromLength:(NSArray *)lengthArray center:(CGPoint)center {
    
    NSMutableArray *tempArr = [NSMutableArray array];
    
    double avg = 2 * M_PI / lengthArray.count; //把360度均分
    double angle = 2 * M_PI / 4; //从y轴上半轴开始，逆时针排列
    
    for (int i = 0; i < lengthArray.count ; i++) {
        
        double length = [[lengthArray objectAtIndex:i] doubleValue];
        
        CGFloat x = center.x + cos(angle) * length;
        CGFloat y = center.y - sin(angle) * length;
        
        CGPoint point = CGPointMake(x, y);
        
        [tempArr addObject:[NSValue valueWithCGPoint:point]];
        
        angle += avg;
    }
    
    return tempArr.copy;
}

/**
 以中心为参考点，计算每一个label的中心坐标
 */
- (NSDictionary *)calculateLabelCenterWithTitle:(NSString *)title topPointValue:(NSValue *)topPointValue {

    CGPoint point = topPointValue.CGPointValue;
    CGFloat margin = 30*kWidthScale;
    
    CGFloat labelHeight = 25*kWidthScale;
    CGFloat labelWidth = [self widthOfString:title font:[UIFont systemFontOfSize:23*kWidthScale] height:labelHeight];
    
    //允许的最大宽度
    CGFloat leftMaxLabelW = point.x - 2*margin;
    CGFloat rightMaxLabelW = main_Width - point.x - 2*margin;

    CGPoint center = CGPointZero;
    NSTextAlignment textAlignment = NSTextAlignmentCenter;
    
    double absX = fabs(point.x - _centerPoint.x);
    double absY = fabs(point.y - _centerPoint.y);
    
    if (absX < 0.001 && point.y < _centerPoint.y) {//在中心y轴上 上半部分
        
        CGFloat y = point.y - margin - labelHeight / 2;
        
        center = CGPointMake(point.x, y);
    }
    else if (absX < 0.001 && point.y > _centerPoint.y) {//在中心y轴上 下半部分
        
        CGFloat y = point.y + margin + labelHeight / 2;
        
        center = CGPointMake(point.x, y);
    }
    else if (absY < 0.001 && point.x < _centerPoint.x) {//在中心x轴上 左半部分
        
        if (labelWidth > leftMaxLabelW) {
            
            labelWidth = leftMaxLabelW;
        }
        
        CGFloat x = point.x - margin - labelWidth / 2;
        
        center = CGPointMake(x, point.y);
        textAlignment = NSTextAlignmentRight;
    }
    else if (absY < 0.001 && point.x > _centerPoint.x) {//在中心x轴上 右半部分
        
        if (labelWidth > rightMaxLabelW) {
            
            labelWidth = rightMaxLabelW;
        }
        
        CGFloat x = point.x + margin + labelWidth / 2;
        
        center = CGPointMake(x, point.y);
        textAlignment = NSTextAlignmentLeft;
    }
    else if (point.x > _centerPoint.x && point.y < _centerPoint.y) {//在第一象限
        
        if (labelWidth > rightMaxLabelW) {
            
            labelWidth = rightMaxLabelW;
        }
        
        CGFloat x = point.x + margin + labelWidth / 2;
        CGFloat y = point.y - margin / 2;
        
        center = CGPointMake(x, y);
        textAlignment = NSTextAlignmentLeft;
    }
    else if (point.x < _centerPoint.x && point.y < _centerPoint.y) {//在第二象限
        
        if (labelWidth > leftMaxLabelW) {
            
            labelWidth = leftMaxLabelW;
        }
        
        CGFloat x = point.x - margin - labelWidth / 2;
        CGFloat y = point.y - margin / 2;
        
        center = CGPointMake(x, y);
        textAlignment = NSTextAlignmentRight;
    }
    else if (point.x < _centerPoint.x && point.y > _centerPoint.y) {//在第三象限
        
        if (labelWidth > leftMaxLabelW) {
            
            labelWidth = leftMaxLabelW;
        }
        
        CGFloat x = point.x - margin - labelWidth / 2;
        CGFloat y = point.y + margin / 2;
        
        center = CGPointMake(x, y);
        textAlignment = NSTextAlignmentRight;
    }
    else if (point.x > _centerPoint.x && point.y > _centerPoint.y) {//在第四象限
        
        if (labelWidth > rightMaxLabelW) {
            
            labelWidth = rightMaxLabelW;
        }
        
        CGFloat x = point.x + margin + labelWidth / 2;
        CGFloat y = point.y + margin / 2;
        
        center = CGPointMake(x, y);
        textAlignment = NSTextAlignmentLeft;
    }

    NSDictionary *dic = @{
        @"labelWidth":@(labelWidth),
        @"textAlignment":@(textAlignment),
        @"center":[NSValue valueWithCGPoint:center],
    };
    
    return dic;
}

- (CGFloat)widthOfString:(NSString *)string font:(UIFont *)font height:(CGFloat)height {
    
    NSDictionary * dict=[NSDictionary dictionaryWithObject: font forKey:NSFontAttributeName];
    CGRect rect=[string boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return rect.size.width;
}

- (CGFloat)heightOfString:(NSString *)string font:(UIFont *)font width:(CGFloat)width{
    CGRect bounds;
    NSDictionary * parameterDict=[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    bounds=[string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:parameterDict context:nil];
    
    return bounds.size.height;
}

#pragma mark - 懒加载

- (CAShapeLayer *)baseRadarShapeLayer {
    
    if (_baseRadarShapeLayer == nil) {
        
        _baseRadarShapeLayer = [CAShapeLayer layer];
        
        _baseRadarShapeLayer.backgroundColor = [UIColor whiteColor].CGColor;
        _baseRadarShapeLayer.strokeColor = [UIColor blackColor].CGColor;
        _baseRadarShapeLayer.fillColor = [UIColor whiteColor].CGColor;
    }
    return _baseRadarShapeLayer;
}

- (CAShapeLayer *)mineRadarShapeLayer {
    
    if (_mineRadarShapeLayer == nil) {
        
        _mineRadarShapeLayer = [CAShapeLayer layer];
        
        _mineRadarShapeLayer.strokeColor = [UIColor blueColor].CGColor;
        _mineRadarShapeLayer.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.2].CGColor;
    }
    return _mineRadarShapeLayer;
}

@end
