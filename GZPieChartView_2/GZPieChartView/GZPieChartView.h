//
//  PieChartView.h
//  GZPieChartView_2
//
//  Created by armada on 2016/11/25.
//  Copyright © 2016年 com.zlot.gz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GZPieChartView : UIView

/*!
 * @brief intializer
 * @param frame Origin and size of GZPieChartView
 * @param portions Values of portions
 * @param portionColors Colors of portions.Default is black.
 * @param radius Radius of pie view
 * @param lineWidth LineWidth of stroke
 * @return An instance of GZPieChartView
 */

- (instancetype)initWithFrame:(CGRect)frame portions:(NSArray *)portions portionColors:(NSArray *)portionColors radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth values:(NSArray *)values;

@end
