//
//  PieChartView.m
//  GZPieChartView_2
//
//  Created by armada on 2016/11/25.
//  Copyright © 2016年 com.zlot.gz. All rights reserved.
//

#import "GZPieChartView.h"

#define kIntervalDegree 2.0f
#define kOuterCircleIntervalDegree 8.0f
#define kDotCircleRadius 3.0f
#define kIncrement 8.0f

#define kDashLineLength 60
#define kDashCornerRadius 20.0f

#define kCATextLayerWidth 60
#define kCATextLayerHeight 15
#define kCATextLayerFontSize 12

#define kItemsTitles @[@"车险分期类",@"消费分期类",@"逾期债权",@"提前还款"]
#define toDeg(rad) (rad/(M_PI*2)*360)
#define toRad(deg) ((deg/360.0)*M_PI*2)

@interface GZPieChartView()

@property(nonatomic,strong) NSArray<NSNumber *> *portions;

@property(nonatomic,strong) NSArray<UIColor *> *portionColors;

@property(nonatomic,strong) NSMutableArray<NSNumber *> *percents;

@property(nonatomic,strong) NSMutableArray<NSNumber *> *halfRadianOfPortions;

@property(nonatomic,strong) NSMutableArray<NSValue *> *dotCircleCenters;

@property(nonatomic,strong) NSMutableArray<NSValue *> *dashLineCenters;

@property(nonatomic,strong) NSArray<NSString *> *values;

@property(nonatomic,assign) CGFloat radius;

@property(nonatomic,assign) CGFloat lineWidth;

@end

@implementation GZPieChartView

- (instancetype)initWithFrame:(CGRect)frame portions:(NSArray *)portions portionColors:(NSArray *)portionColors radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth values:(NSArray *)values{
    
    if(self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        _portions = portions;
        _portionColors = portionColors;
        _radius = radius;
        _lineWidth = lineWidth;
        _values = values;
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    [self calculatePercentsOfPortions];
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGFloat startAngle = -M_PI_2+toRad(kIntervalDegree);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    _halfRadianOfPortions = [NSMutableArray array];
    
    for(int i=0;i<self.percents.count;i++) {
        
        CGFloat increment = M_PI*2*self.percents[i].doubleValue-toRad(kIntervalDegree);
        CGFloat endAngle = startAngle + increment;
        //draw arc of every portion
        CGContextAddArc(ctx, [self centerPoint].x,[self centerPoint].y,self.radius, startAngle, endAngle, 0);
        
        if(i<self.portionColors.count) {
          [self.portionColors[i] setStroke];
        }else {
            [[UIColor blackColor] setStroke];
        }
        CGContextSetLineWidth(ctx, self.lineWidth);
        CGContextSetLineCap(ctx, kCGLineCapButt);
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        CGContextDrawPath(ctx, kCGPathStroke);
        
        //calculate half radians of every portion
        if(i==0 || i==1) {
            CGFloat halfRadians = radiansBetweenAngles(startAngle, endAngle);
            [self.halfRadianOfPortions addObject:[NSNumber numberWithDouble:halfRadians]];
        }else {
            CGFloat radiansOfParts = startAngle+increment/3.0;
            [self.halfRadianOfPortions addObject: [NSNumber numberWithDouble:radiansOfParts]];
            
            radiansOfParts = startAngle+increment/3.0*2;
            [self.halfRadianOfPortions addObject: [NSNumber numberWithDouble:radiansOfParts]];
        }

        
        //calculate next shartAngle
        startAngle += M_PI*2*self.percents[i].doubleValue;
        
        CGContextSaveGState(ctx);
    }

    [self drawOuterCircleInContext:ctx];
    [self drawDotsInOuterCircleInContext:ctx];
    [self drawDashLineForPortionsInContext:ctx];
}

//draw outer circle
- (void)drawOuterCircleInContext:(CGContextRef)ctx {
    
    CGContextSaveGState(ctx);
    
    CGFloat startAngle;
    CGFloat endAngle;
    
    for(int i=0;i<=self.halfRadianOfPortions.count;i++) {
        
        //from direction of 12 o'clock
        if(i==0) {
            startAngle = -M_PI_2;
        }else {
            startAngle = self.halfRadianOfPortions[i-1].doubleValue + toRad(kOuterCircleIntervalDegree)/2;
        }
        
        if(i==self.halfRadianOfPortions.count) {
            endAngle = -M_PI_2+M_PI*2;
        }else {
            endAngle = self.halfRadianOfPortions[i].doubleValue - toRad(kOuterCircleIntervalDegree)/2;
        }
        CGContextAddArc(ctx, [self centerPoint].x, [self centerPoint].y, self.radius+self.lineWidth/2.0+kIncrement, startAngle, endAngle, 0);
        CGContextSetLineWidth(ctx, 1.0);
        CGContextSetLineJoin(ctx, kCGLineJoinRound);
        [[UIColor lightGrayColor] setStroke];
        CGContextDrawPath(ctx, kCGPathStroke);
        
        CGContextSaveGState(ctx);
    }
}

//draw dots in outer circle
- (void)drawDotsInOuterCircleInContext:(CGContextRef)ctx {
    
    _dotCircleCenters = [NSMutableArray array];
    CGContextSaveGState(ctx);
    
    for(int i=0;i<self.halfRadianOfPortions.count;i++) {
        
        CGFloat outerRadius = self.radius + self.lineWidth/2.0 + kIncrement;
        
        CGFloat centerX = [self centerPoint].x + outerRadius*sin(self.halfRadianOfPortions[i].doubleValue+M_PI_2);
        CGFloat centerY = [self centerPoint].y - outerRadius*cos(self.halfRadianOfPortions[i].doubleValue+M_PI_2);
        //store the center of dotCircles
        CGPoint center = CGPointMake(centerX, centerY);
        [self.dotCircleCenters addObject:[NSValue valueWithCGPoint:center]];
    
        CGContextAddArc(ctx, centerX, centerY , kDotCircleRadius, -M_PI_2, M_PI*2-M_PI_2, 0);
        CGContextSetLineWidth(ctx, 2.0f);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        
        if(i<self.portionColors.count) {
            CGContextSetStrokeColorWithColor(ctx, self.portionColors[i].CGColor);
            CGContextSetFillColorWithColor(ctx, self.portionColors[i].CGColor);
        }else {
            CGContextSetStrokeColorWithColor(ctx, self.portionColors[self.portionColors.count-1].CGColor);
            CGContextSetFillColorWithColor(ctx, self.portionColors[self.portionColors.count-1].CGColor);
        }

        CGContextDrawPath(ctx, kCGPathFillStroke);
        CGContextSaveGState(ctx);
    }
}

//draw dash line for every portion
- (void)drawDashLineForPortionsInContext:(CGContextRef)ctx {
    
    _dashLineCenters = [NSMutableArray array];
    
    for(int index=0;index<self.dotCircleCenters.count;index++) {
        
        CGPoint dotCenter = self.dotCircleCenters[index].CGPointValue;
        CGPoint pointInCircle;
        CGPoint cornerPoint;
        CGPoint endPoint;
        
        CGFloat radians = self.halfRadianOfPortions[index].floatValue + M_PI_2;
        
        //set stroke color
        if(index<self.portionColors.count) {
            CGContextSetStrokeColorWithColor(ctx, self.portionColors[index].CGColor);
        }else {
            CGContextSetStrokeColorWithColor(ctx, self.portionColors[self.portionColors.count-1].CGColor);
        }
        
       if(radians>=0 && radians<M_PI_2) {
            
            CGFloat pointX = dotCenter.x + kDotCircleRadius*sin(M_PI/3.0);
            CGFloat pointY = dotCenter.y - kDotCircleRadius*cos(M_PI/3.0);
            pointInCircle = CGPointMake(pointX, pointY);
            
            CGFloat cornerPointX = dotCenter.x + (kDotCircleRadius + kDashCornerRadius)*sin(M_PI/3.0);
            CGFloat cornerPointY = dotCenter.y - (kDotCircleRadius + kDashCornerRadius)*cos(M_PI/3.0);
            cornerPoint = CGPointMake(cornerPointX, cornerPointY);
           
            endPoint = CGPointMake(cornerPoint.x+kDashLineLength, cornerPoint.y);
           
        }else if(radians>=M_PI_2 && radians<M_PI) {
            
            CGFloat pointX = dotCenter.x + kDotCircleRadius*sin(M_PI-M_PI/3.0);
            CGFloat pointY = dotCenter.y - kDotCircleRadius*cos(M_PI-M_PI/3.0);
            pointInCircle = CGPointMake(pointX, pointY);
            
            CGFloat cornerPointX = dotCenter.x + (kDotCircleRadius + kDashCornerRadius)*sin(M_PI-M_PI/3.0);
            CGFloat cornerPointY = dotCenter.y - (kDotCircleRadius + kDashCornerRadius)*cos(M_PI-M_PI/3.0);
            cornerPoint = CGPointMake(cornerPointX, cornerPointY);
            
            endPoint = CGPointMake(cornerPoint.x+kDashLineLength, cornerPoint.y);
            
        }else if(radians>=M_PI && radians<M_PI_2*3) {
            
            CGFloat pointX = dotCenter.x + kDotCircleRadius*sin(M_PI/3.0+M_PI);
            CGFloat pointY = dotCenter.y - kDotCircleRadius*cos(M_PI/3.0+M_PI);
            pointInCircle = CGPointMake(pointX, pointY);
            
            CGFloat cornerPointX = dotCenter.x + (kDotCircleRadius + kDashCornerRadius)*sin(M_PI/3.0+M_PI);
            CGFloat cornerPointY = dotCenter.y - (kDotCircleRadius + kDashCornerRadius)*cos(M_PI/3.0+M_PI);
            cornerPoint = CGPointMake(cornerPointX, cornerPointY);
            
            endPoint = CGPointMake(cornerPoint.x-kDashLineLength, cornerPoint.y);
            
        }else {
            
            CGFloat pointX = dotCenter.x + kDotCircleRadius*sin(-M_PI/3.0);
            CGFloat pointY = dotCenter.y - kDotCircleRadius*cos(-M_PI/3.0);
            pointInCircle = CGPointMake(pointX, pointY);
            
            CGFloat cornerPointX = dotCenter.x + (kDotCircleRadius + kDashCornerRadius)*sin(-M_PI/3.0);
            CGFloat cornerPointY = dotCenter.y - (kDotCircleRadius + kDashCornerRadius)*cos(-M_PI/3.0);
            cornerPoint = CGPointMake(cornerPointX, cornerPointY);
            
            endPoint = CGPointMake(cornerPoint.x-kDashLineLength, cornerPoint.y);
        }
        
        CGFloat lengths[] = {4,4};
        CGContextSetLineDash(ctx, 0, lengths, 2);
   
        CGContextMoveToPoint(ctx, pointInCircle.x, pointInCircle.y);
        CGContextAddLineToPoint(ctx, cornerPoint.x, cornerPoint.y);
        CGContextStrokePath(ctx);
        
        CGContextMoveToPoint(ctx, cornerPoint.x, cornerPoint.y);
        CGContextAddLineToPoint(ctx,endPoint.x, endPoint.y);
        CGContextStrokePath(ctx);
        
        [self.dashLineCenters addObject:[NSValue valueWithCGPoint:midpointBetweenPoints(cornerPoint, endPoint)]];
    }
    
    [self addTextLayer];
}

- (void)addTextLayer {
    
    for(int index=0;index<self.dashLineCenters.count;index++) {
        
        CGPoint dashLineCenter = self.dashLineCenters[index].CGPointValue;
        //create title layers
        CATextLayer *titleTextLayer = [CATextLayer layer];
        titleTextLayer.frame = CGRectMake(0, 0, kCATextLayerWidth, kCATextLayerHeight);
        titleTextLayer.position = CGPointMake(dashLineCenter.x, dashLineCenter.y+kCATextLayerHeight/2.0+3);
        titleTextLayer.alignmentMode = @"center";
        titleTextLayer.string = kItemsTitles[index];
        
        if(index<self.portionColors.count) {
            titleTextLayer.foregroundColor = self.portionColors[index].CGColor;
        }else {
            titleTextLayer.foregroundColor = self.portionColors[self.portionColors.count-1].CGColor;
        }
        titleTextLayer.fontSize = kCATextLayerFontSize;
        [self.layer addSublayer:titleTextLayer];
        //create value layers
        CATextLayer *valueTextLayer = [CATextLayer layer];
        valueTextLayer.frame = CGRectMake(0, 0, kCATextLayerWidth, kCATextLayerHeight);
        valueTextLayer.position = CGPointMake(dashLineCenter.x, dashLineCenter.y-kCATextLayerHeight/2.0-3.0);
        valueTextLayer.alignmentMode = @"center";
        valueTextLayer.string = self.values[index];
        
        if(index<self.portionColors.count) {
            valueTextLayer.foregroundColor = self.portionColors[index].CGColor;
        }else {
            valueTextLayer.foregroundColor = self.portionColors[self.portionColors.count-1].CGColor;
        }
        valueTextLayer.fontSize = kCATextLayerFontSize;
        [self.layer addSublayer:valueTextLayer];
    }
}

//create percent of every portions
- (void)calculatePercentsOfPortions {
    
    double total = 0.0f;
    
    _percents = [NSMutableArray array];
    //calculate total number
    for(int i=0;i<self.portions.count;i++) {
        total += self.portions[i].doubleValue;
    }
    
    //calculate percent of every portions
    for(int i=0;i<self.portions.count;i++) {
        double percent = self.portions[i].doubleValue/total;
        [self.percents addObject:[NSNumber numberWithDouble:percent]];
    }
}

#pragma mark Function Helper
- (CGPoint)centerPoint {
    return CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
}

static inline CGFloat radiansBetweenAngles(CGFloat startAngle,CGFloat endAngle) {
    return startAngle + (endAngle - startAngle)/2.0;
}

static inline CGPoint midpointBetweenPoints(CGPoint start, CGPoint end) {
    
    CGFloat midPointX = start.x + (end.x - start.x)/2;
    CGFloat midPointY = start.y + (end.y - start.y)/2;
    return CGPointMake(midPointX, midPointY);
}

@end
