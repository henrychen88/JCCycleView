//
//  ViewController.m
//  CycleView
//
//  Created by Henry on 16/4/13.
//  Copyright © 2016年 Henry. All rights reserved.
//

#import "ViewController.h"

#import "JCCycleView.h"

@interface ViewController ()
/**  */
@property(nonatomic, strong) JCCycleView *cycleView;

@property(nonatomic, strong) UIToolbar *toolBar;

/**  */
@property(nonatomic, strong) UIView *indexView;

/**  */
@property(nonatomic, assign) NSInteger index;

/**  */
@property(nonatomic, assign) NSInteger titleIndex;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"JCCyleView Test";
    self.navigationController.navigationBar.translucent = NO;
    
    [self.view addSubview:self.cycleView];
    
    [self.cycleView setViewChangedBlock:^(NSInteger currentIndex, NSInteger previousIndex, NSInteger totalCount) {
        NSLog(@"viewChanged\ncurrent:%d,previous:%d,total:%d", currentIndex, previousIndex, totalCount);
    }];
    
    [self reset:nil];
    
    [self addToolBar];
    
    [self setupIndexView];
    
    self.index = 1;
}

- (void)setupIndexView
{
    _indexView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    _indexView.backgroundColor = [UIColor lightGrayColor];
    
    CGFloat originX = 0;
    CGFloat originY = 0;
    CGFloat width   = self.view.frame.size.width / 4.0f;
    CGFloat height  = 40;
    
    for (NSInteger i = 0; i < 8; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(originX, originY, width, height)];
        [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAct:) forControlEvents:UIControlEventTouchUpInside];
        
        [button setTag:i + 1];
        [_indexView addSubview:button];
        
        originX = (originX + width);
        if (i == 3) {
            originX = 0;
            originY = 40;
        }
    }
    
    [self.view addSubview:_indexView];
}

- (void)addToolBar
{
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    _toolBar.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_toolBar];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"ADD" style:UIBarButtonItemStylePlain target:self action:@selector(addButtonAct)];
    
    UIBarButtonItem *flexLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"DELETE" style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonAct)];
    
    UIBarButtonItem *flexRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *replaceButton = [[UIBarButtonItem alloc] initWithTitle:@"REPLACE" style:UIBarButtonItemStylePlain target:self action:@selector(replaceButtonAct)];
    
    _toolBar.items = @[addButton, flexLeft, deleteButton, flexRight, replaceButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect frame = _toolBar.frame;
    frame.origin.y = CGRectGetHeight(self.view.frame) - 44;
    _toolBar.frame = frame;
    
    frame = _indexView.frame;
    frame.origin.y = CGRectGetHeight(self.view.frame) - 44 - 130;
    _indexView.frame = frame;
}

- (void)setIndex:(NSInteger)index
{
    if (_index == index) {
        return;
    }
    
    if (_index > 0) {
        UIButton *button = (UIButton *)[_indexView viewWithTag:_index];
        [button setBackgroundColor:[UIColor lightGrayColor]];
    }
    
    UIButton *button = (UIButton *)[_indexView viewWithTag:index];
    [button setBackgroundColor:[UIColor orangeColor]];
    
    _index = index;
}

- (void)addButtonAct
{
    [self.cycleView addChildView:[self randomViewWithIndex:self.titleIndex++] atIndex:self.index - 1];
}

- (void)deleteButtonAct
{
    BOOL flag = [self.cycleView deleteChildViewAtIndex:self.index - 1];
    if (flag) {
        NSLog(@"Delete Done");
    }
}

- (void)replaceButtonAct
{
    BOOL flag = [self.cycleView replaceAtIndex:self.index - 1 withNewView:[self randomViewWithIndex:self.titleIndex++]];
    if (flag) {
        NSLog(@"@Replace Done");
    }
}

- (void)buttonAct:(UIButton *)button
{
    self.index = button.tag;
}


- (IBAction)reset:(id)sender
{
    NSInteger count = 0;
    NSMutableArray *vs = [NSMutableArray new];
    for (NSInteger i = 0; i < count; i++) {
        UILabel *view = [self randomViewWithIndex:self.titleIndex++];
        
        [vs addObject:view];
    }
    
    [self.cycleView setChildViews:vs];
}

- (UILabel *)randomViewWithIndex:(NSInteger)index
{
    UILabel *view = [[UILabel alloc] initWithFrame:self.cycleView.bounds];
    view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255) / 255.0f green:arc4random_uniform(255) / 255.0f blue:arc4random_uniform(255) / 255.0f alpha:1];
    view.text = [NSString stringWithFormat:@"%ld", (long)index];
    view.textAlignment = NSTextAlignmentCenter;
    view.font = [UIFont systemFontOfSize:100];
    view.textColor = [UIColor whiteColor];
    
    return view;
}

- (JCCycleView *)cycleView
{
    if (!_cycleView) {
        _cycleView = [[JCCycleView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 320)];
    }
    return _cycleView;
}

@end
