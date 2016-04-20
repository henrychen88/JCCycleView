//
//  CycleScrollView.m
//  Just
//
//  Created by Henry on 14-7-2.
//  Copyright (c) 2014年 Surwin. All rights reserved.
//

#import "JCCycleView.h"

@interface JCCycleView ()<UIScrollViewDelegate>
/**
 *  上一个索引
 */
@property(nonatomic, assign) NSInteger previousIndex;
/**
 *  总数
 */
@property(nonatomic, assign, readwrite) NSInteger totalCount;
/**
 *  用于显示在scrollView上的数据元素 最多包含三个元素
 */
@property(nonatomic, strong) NSMutableArray *displayViews;

@property(nonatomic, strong) UIScrollView *scrollView;

/**
 *  滑动显示上一个界面元素为YES 滑动显示下一个界面元素为NO
 */
@property(nonatomic) BOOL directionFormLeftToRight;

/** 
    YES 表示是设置currentIndex引起的scrollView的位置变化
    NO  表示是人为拖动引起的scrollView的位置变化
 */
@property(nonatomic, assign) BOOL flag;

/**
 *  保存 setCurrentIndex: animated: 方法的第一个参数
 */
@property(nonatomic, assign) NSInteger tempIndex;

/** 保存删除的View索引,删除当前显示的View需要在动画结束后再删 */
@property(nonatomic, assign) NSInteger deleteIndex;

@end

@implementation JCCycleView

#pragma mark - 初始化

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initial];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame views:(NSMutableArray *)childViews
{
    if (self = [super initWithFrame:frame]) {
        [self initial];
        [self setChildViews:childViews];
    }
    return self;
}

- (void)initial
{
    self.autoresizesSubviews = YES;
    self.deleteIndex = -1;
    _childViews = [NSMutableArray new];
    [self addSubview:self.scrollView];
}

/**
 *  超过3页的数据如果出现异常请用下一个方法
 */
- (void)setChildViews:(NSMutableArray *)childViews
{
    if (!childViews || childViews.count == 0) {
        NSLog(@"设置的数据不能为空");
        return;
    }
    
    _childViews = childViews;
    
//    self.totalCount = childViews.count;
    
    [self resetViews];
}

- (void)resetViews
{
    if (self.totalCount == 1) {
        [self resetWithOneView];
    }else if(self.totalCount == 2){
        [self resetWithTwoViews];
    }else{
        [self resetWithMoreViews];
    }
}

#pragma mark - Setter && Getter

- (NSInteger)totalCount
{
    return self.childViews.count;
}

- (void)setScrollViewContentSize
{
    CGSize size    = self.scrollView.contentSize;
    NSInteger unit = self.totalCount == 1 ? 1 : 3;
    size.width     = unit * self.scrollView.frame.size.width;
    self.scrollView.contentSize = size;
}

#pragma mark - 改变当前索引

- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated
{
    if (_currentIndex == currentIndex)   return;
    if (currentIndex < 0)                return;
    if (currentIndex >= self.totalCount) return;
    
    self.flag = YES;
    if (animated) {
        self.tempIndex = currentIndex;
        if (self.totalCount == 2) {
            if (currentIndex == 0 && _currentIndex == 1) {
                
                UIView *view = [self.displayViews lastObject];
                CGRect frame = view.frame;
                frame.origin = CGPointMake(0, 0);
                view.frame = frame;
                [self.scrollView setContentOffset:CGPointZero    animated:YES];
            } else if (currentIndex == 1 && _currentIndex == 0) {
//                NSLog(@"Here!!!!!!!!!!!!");
                UIView *view = [self.displayViews lastObject];
                CGRect frame = view.frame;
                frame.origin = CGPointMake(640, 0);
                view.frame = frame;
                [self.scrollView setContentOffset:CGPointMake(640, 0)    animated:YES];
            }
        } else if (self.totalCount > 2) {
            UIView *view = self.childViews[currentIndex];
            CGPoint point = CGPointZero;
            if (currentIndex > _currentIndex) {
                //显示在右边
                point = CGPointMake(640, 0);
            }
            CGRect frame = view.frame;
            frame.origin = point;
            view.frame = frame;
            [self.scrollView addSubview:view];
            [self.scrollView setContentOffset:point animated:YES];
        }
    } else {
        [self setCurrentIndex:currentIndex];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    [self resetViews];
}

#pragma mark - 增加childView

- (void)addChildView:(UIView *)view
{
    [self addView:view atIndex:self.childViews.count show:NO];
}

- (void)addChildView:(UIView *)view atIndex:(NSInteger)index
{
    [self addView:view atIndex:index show:NO];
}

- (void)addAndShowView:(UIView *)view
{
    [self addView:view atIndex:self.childViews.count show:YES];
}

- (void)addAndShowView:(UIView *)view atIndex:(NSInteger)index
{
    [self addView:view atIndex:index show:YES];
}

- (void)addView:(UIView *)view
        atIndex:(NSInteger)index
           show:(BOOL)show
{
    if (![self isNewView:view]) return;
    
    [self.childViews insertObject:view atIndex:index];
    
    
    if (index == _currentIndex) show = YES;
    
    if (self.totalCount == 1) {
        [self resetWithOneView];
        return;
    } else if (self.totalCount == 2 && show) {
        _currentIndex = 1 - index;
        [self resetWithTwoViews];
    } else if (self.totalCount > 2 && show) {
        _currentIndex = [self getValidIndexFromIndex:index + 1];
        [self resetWithMoreViews];
//        [self.scrollView setContentOffset:CGPointZero];
    }
    
//    return;
    
    
    if (show) {
        [self setCurrentIndex:index animated:YES];
    } else {
        if (self.totalCount == 2) {
            if (index < _currentIndex) {
                [self setCurrentIndex:_currentIndex + 1];
            } else {
                [self setCurrentIndex:_currentIndex];
            }
        } else if (self.totalCount > 2) {
            if (index < _currentIndex) {
                [self setCurrentIndex:_currentIndex + 1];
            } else {
                [self setCurrentIndex:_currentIndex];
            }
        }
        
    }
}

/**
 *  判断view是否可添加
 */
- (BOOL)isNewView:(UIView *)view
{
    if (view == nil) return NO;
    for (UIView *v in self.childViews) {
        if (v == view) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 替换childView

- (BOOL)replaceView:(UIView *)oldView withNewView:(UIView *)newView
{
    NSInteger index = [self.childViews indexOfObject:oldView];
    return [self replaceAtIndex:index withNewView:newView];
}

- (BOOL)replaceAtIndex:(NSInteger)index withNewView:(UIView *)newView
{
    if (index < 0 || index >= self.totalCount) return NO;
    if ([self.childViews containsObject:newView]) return NO;
    
    UIView *oldView = self.childViews[index];
    
    [self.childViews replaceObjectAtIndex:index withObject:newView];
    if ([self.displayViews containsObject:oldView]) {
        //显示在scrollView中
        newView.frame = oldView.frame;
        
        index = [self.displayViews indexOfObject:oldView];
        [self.displayViews replaceObjectAtIndex:index withObject:newView];
        [self.scrollView addSubview:newView];
    }
    
    return YES;
}

#pragma mark - 删除childView

- (BOOL)deleteChildView:(UIView *)view
{
    NSInteger index = [self.childViews indexOfObject:view];
    return [self deleteChildViewAtIndex:index];
}

- (BOOL)deleteChildViewAtIndex:(NSInteger)index
{
    if (index < 0 || index >= self.totalCount) return NO;
    
    if (self.totalCount == 1) {
        [self.childViews removeAllObjects];
        [self.displayViews removeAllObjects];
        [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    } else if (self.totalCount > 1) {
        if (index == _currentIndex) {
            //删除当前显示的View
            //先显示前一个View
            self.flag = YES;
            self.deleteIndex = index;
            if (self.totalCount == 2) {
                NSArray *array = self.scrollView.subviews;
                UIView *view = [array objectAtIndex:1];
                CGRect frame = view.frame;
                frame.origin = CGPointMake(0, 0);
                view.frame = frame;
            }
            [self.scrollView setContentOffset:CGPointZero animated:YES];
        } else {
            [self.childViews removeObjectAtIndex:index];
            if (index > _currentIndex) {
                self.currentIndex = _currentIndex;
            } else {
                NSInteger preIndex = [self getValidIndexFromIndex:_currentIndex - 1];
                self.currentIndex = preIndex;
            }
        }
    }
    
    return YES;
}

#pragma mark - 初始化界面元素

#pragma mark 只有一个界面元素
- (void)resetWithOneView
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.displayViews removeAllObjects];
    
    self.scrollView.contentSize = self.scrollView.bounds.size;
    UIView *view = [_childViews firstObject];
    CGRect frame = view.frame;
    frame.origin = CGPointMake(0, 0);
    view.frame = frame;
    [self.scrollView addSubview:view];
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
}

#pragma mark 只有两个界面元素
- (void)resetWithTwoViews
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.displayViews removeAllObjects];
    
    self.scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    NSInteger nextIndex = 1 - self.currentIndex;
    
    self.scrollView.bounces = NO;
    
    //当前显示的视图第一个被添加
    [self.displayViews addObject:[self.childViews objectAtIndex:_currentIndex]];
    [self.displayViews addObject:[self.childViews objectAtIndex:nextIndex]];
    
    //当前显示的视图放在scrollView的中间
    UIView *centerView = [self.displayViews firstObject];
    CGRect centerRect = centerView.frame;
    centerRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
    centerView.frame = centerRect;
    [self.scrollView addSubview:centerView];
    
    //另外一个视图放在显示视图的右侧
    _directionFormLeftToRight = NO;
    
    UIView *lateralView = [self.displayViews lastObject];
    CGRect lateralRect = centerView.frame;
    lateralRect.origin = _directionFormLeftToRight ? CGPointMake(0, 0) : CGPointMake(CGRectGetWidth(self.scrollView.frame) * 2, 0);
    lateralView.frame = lateralRect;
    [self.scrollView addSubview:lateralView];
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
}

#pragma mark 3个或以上界面元素
- (void)resetWithMoreViews
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.displayViews removeAllObjects];
    self.scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    
    NSInteger previousIndex = [self getValidIndexFromIndex:self.currentIndex - 1];
    NSInteger nextPageIndex = [self getValidIndexFromIndex:self.currentIndex + 1];
    
    [self.displayViews addObject:[self.childViews objectAtIndex:previousIndex]];
    [self.displayViews addObject:[self.childViews objectAtIndex:_currentIndex]];
    [self.displayViews addObject:[self.childViews objectAtIndex:nextPageIndex]];
    
    NSInteger counter = 0;
    for (UIView *contentView in self.displayViews) {
        contentView.userInteractionEnabled = YES;
        CGRect rightRect = contentView.frame;
        rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * (counter ++), 0);
        contentView.frame = rightRect;
        [self.scrollView addSubview:contentView];
    }
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
}

#pragma mark 获取有效的数据下表索引，用于实现首尾相接的循环
- (NSInteger)getValidIndexFromIndex:(NSInteger)currentIndex
{
    if (currentIndex == -1) {
        return self.totalCount - 1;
    }else if (currentIndex == self.totalCount){
        return 0;
    }else{
        return currentIndex;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.totalCount == 1 || self.totalCount == 0) {
        return;
    }

    if (self.flag) return;
    
    int contentOffsetX = scrollView.contentOffset.x;
    
    if (self.totalCount == 2) {
        if (contentOffsetX < CGRectGetWidth(self.scrollView.frame) && !_directionFormLeftToRight) {
             //从右往左拉
            
            NSArray *array = self.scrollView.subviews;
            UIView *view = [array objectAtIndex:1];
            CGRect frame = view.frame;
            frame.origin = CGPointMake(0, 0);
            view.frame = frame;
            _directionFormLeftToRight = YES;
        }else if (contentOffsetX > CGRectGetWidth(self.scrollView.frame) && _directionFormLeftToRight){
            //从左往右
            
            NSArray *array = self.scrollView.subviews;
            UIView *view = [array objectAtIndex:1];
            CGRect frame = view.frame;
            frame.origin = CGPointMake(2 * CGRectGetWidth(self.scrollView.frame), 0);
            view.frame = frame;
            _directionFormLeftToRight = NO;
        }
        
        if ((contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame))) || (contentOffsetX <= 0)) {
            //增加previous
            _previousIndex = self.currentIndex;
            _currentIndex = 1 - self.currentIndex;
            [self resetWithTwoViews];
        }
    }
    
    if (self.totalCount > 2) {
        if (contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame))) {
            //增加previous
//            NSLog(@"3个View 从右向左滑动");
            self.previousIndex = self.currentIndex;
            _currentIndex = [self getValidIndexFromIndex:self.currentIndex + 1];
            [self resetWithMoreViews];
        }
        
        if (contentOffsetX <= 0) {
            //增加previous
//            NSLog(@"3个 从左向右滑动");
            self.previousIndex = self.currentIndex;
            _currentIndex = [self getValidIndexFromIndex:self.currentIndex - 1];
            [self resetWithMoreViews];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
//    NSLog(@"scrollViewDidEndDecelerating");
    
    // scrollView位置变化结束重置 flag 标记
    self.flag = NO;
    
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
    
    if (self.currentIndex != self.previousIndex) {
        if (self.viewChangedBlock) {
            self.viewChangedBlock(self.currentIndex, self.previousIndex, self.totalCount);
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    self.flag = NO;
}

/**
 *  called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewDidEndScrollingAnimation");
    if (!self.flag) return;
    
    if (self.deleteIndex > -1) {
        [self.childViews removeObjectAtIndex:self.deleteIndex];
        NSInteger preIndex = [self getValidIndexFromIndex:self.deleteIndex - 1];
        self.currentIndex = preIndex;
        self.deleteIndex = -1;
    } else {
        self.currentIndex = self.tempIndex;
    }
    
}

#pragma mark - Lazy Load

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.contentMode = UIViewContentModeCenter;
        _scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        _scrollView.delegate = self;
        _scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (NSMutableArray *)displayViews
{
    if (!_displayViews) {
        _displayViews = [NSMutableArray new];
    }
    return _displayViews;
}

@end
