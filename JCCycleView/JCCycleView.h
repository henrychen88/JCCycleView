//
//  CycleScrollView.h
//  Just
//
//  Created by Henry on 14-7-2.
//  Copyright (c) 2014年 Surwin. All rights reserved.
//

/**
 只有两个界面元素的时候，最好使界面元素的宽和scrollView的宽保持一致
 如果界面元素的宽大于scrollView的宽，滑动的时候会产生某个界面元素覆盖另一个界面元素的现象
 */

#import <UIKit/UIKit.h>

/**
 *  页面改变的block
 *
 *  @param currentPageIdnex  当前页 范围[0, totalPageCount - 1]
 *  @param previousPageIndex 前一页 范围[0, totalPageCount - 1]
 *  @param totalPageCount    总共的页数
 */
typedef void (^ViewChangedBlock)(NSInteger currentIndex, NSInteger previousIndex, NSInteger totalCount);

/**
 *  可循环滚动 View
 */
@interface JCCycleView : UIView

/**
 *  当前页 范围[0, totalPageCount - 1]
 */
@property(nonatomic, assign) NSInteger currentIndex;

/**
 *  总页数
 */
@property(nonatomic, assign, readonly) NSInteger totalCount;

/**
 *  展示的数据源
 */
@property(nonatomic, strong) NSMutableArray *childViews;

/**
 *  页面改变的block
 */
@property(nonatomic, copy) ViewChangedBlock viewChangedBlock;
- (void)setViewChangedBlock:(ViewChangedBlock)viewChangedBlock;

/**
 *  初始化方法
 */
- (instancetype)initWithFrame:(CGRect)frame
                        views:(NSMutableArray *)childViews;

/**
 *  设置当前索引，带动画
 */
- (void)setCurrentIndex:(NSInteger)currentIndex
               animated:(BOOL)animated;


/**
 *  增加一个childView位于最后的位置
 */
- (BOOL)addChildView:(UIView *)view;

/**
 *  增加一个childView位于index
 */
- (BOOL)addChildView:(UIView *)view atIndex:(NSInteger)index;

/**
 *  增加一个childView位于最后的位置,并显示这个View
 */
- (BOOL)addAndShowView:(UIView *)view;

/**
 *  增加一个childView位于index,并显示这个View
 */
- (BOOL)addAndShowView:(UIView *)view atIndex:(NSInteger)index;

/**
 *  删除childView
 *
 *  @param view 将要被删除的View
 *
 *  @return YES表示删除成功
            NO表示删除失败(view不存在)
 */
- (BOOL)deleteChildView:(UIView *)view;

/**
 *  根据索引删除childView
 *
 *  @param index 索引
 *
 *  @return YES表示删除成功
            NO表示删除失败(index不在childViews索引范围内)
 */
- (BOOL)deleteChildViewAtIndex:(NSInteger)index;

/**
 *  替换view
 *
 *  @param oldView 将要被替换的View
 *  @param newView 替换的View
 *
 *  @return YES表示替换成功
            NO表示替换失败(oldView不存在)
 */
- (BOOL)replaceView:(UIView *)oldView
        withNewView:(UIView *)newView;

/**
 *  根据索引替换
 *
 *  @param index   索引
 *  @param newView 替换的View
 *
 *  @return YES表示删除成功
            NO表示删除失败(index不在childViews索引范围内)
 */
- (BOOL)replaceAtIndex:(NSInteger)index
           withNewView:(UIView *)newView;

@end