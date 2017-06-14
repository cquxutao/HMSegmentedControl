//
//  ViewController.m
//  HMSegmentedControlExample
//
//  Created by Hesham Abd-Elmegid on 23/12/12.
//  Copyright (c) 2012 Hesham Abd-Elmegid. All rights reserved.
//

#import "ViewController.h"
@import HMSegmentedControl;

@interface ViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl4;
@property (nonatomic) CGPoint beginLocation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"HMSegmentedControl Demo";
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    
    // Minimum code required to use the segmented control with the default styling.
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Trending", @"News", @"Library"]];
    segmentedControl.frame = CGRectMake(0, 20, viewWidth, 40);
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    
    
    // Segmented control with scrolling
    HMSegmentedControl *segmentedControl1 = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"One", @"Two", @"Three", @"Four", @"Five", @"Six", @"Seven", @"Eight"]];
    segmentedControl1.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    segmentedControl1.frame = CGRectMake(0, 60, viewWidth, 40);
    segmentedControl1.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    segmentedControl1.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    segmentedControl1.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl1.verticalDividerEnabled = YES;
    segmentedControl1.verticalDividerColor = [UIColor blackColor];
    segmentedControl1.verticalDividerWidth = 1.0f;
    [segmentedControl1 setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor blueColor]}];
        return attString;
    }];
    [segmentedControl1 addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl1];
    
    
    // Segmented control with images
    NSArray<UIImage *> *images = @[[UIImage imageNamed:@"1"],
                        [UIImage imageNamed:@"2"],
                        [UIImage imageNamed:@"3"],
                        [UIImage imageNamed:@"4"]];
    
    NSArray<UIImage *> *selectedImages = @[[UIImage imageNamed:@"1-selected"],
                                [UIImage imageNamed:@"2-selected"],
                                [UIImage imageNamed:@"3-selected"],
                                [UIImage imageNamed:@"4-selected"]];
    
    HMSegmentedControl *segmentedControl2 = [[HMSegmentedControl alloc] initWithSectionImages:images sectionSelectedImages:selectedImages];
    segmentedControl2.frame = CGRectMake(0, 120, viewWidth, 50);
    segmentedControl2.selectionIndicatorHeight = 4.0f;
    segmentedControl2.backgroundColor = [UIColor clearColor];
    segmentedControl2.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl2.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    [segmentedControl2 addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl2];

    
//     Segmented control with more customization and indexChangeBlock
    HMSegmentedControl *segmentedControl3 = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"One", @"Two", @"Three", @"4", @"Five"]];
    [segmentedControl3 setFrame:CGRectMake(0, 180, viewWidth, 50)];
    [segmentedControl3 setIndexChangeBlock:^(NSInteger index) {
        NSLog(@"Selected index %ld (via block)", (long)index);
    }];
    segmentedControl3.selectionIndicatorHeight = 4.0f;
    segmentedControl3.backgroundColor = [UIColor colorWithRed:0.1 green:0.4 blue:0.8 alpha:1];
    segmentedControl3.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    segmentedControl3.selectionIndicatorColor = [UIColor colorWithRed:0.5 green:0.8 blue:1 alpha:1];
    segmentedControl3.selectionIndicatorBoxColor = [UIColor blackColor];
    segmentedControl3.selectionIndicatorBoxOpacity = 1.0;
    segmentedControl3.selectionStyle = HMSegmentedControlSelectionStyleBox;
    segmentedControl3.selectedSegmentIndex = HMSegmentedControlNoSegment;
    segmentedControl3.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl3.shouldAnimateUserSelection = NO;
    segmentedControl3.tag = 2;
    [self.view addSubview:segmentedControl3];
    
    // Tying up the segmented control to a scroll view
    self.segmentedControl4 = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 260, viewWidth, 45.0)];
//    self.segmentedControl4.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
//    self.segmentedControl4.sectionTitles = @[@"热门", @"发现", @"关注", @"热门22", @"发现22", @"关注22", @"热门33", @"发现33", @"关注33"];
    self.segmentedControl4.sectionTitles = @[@"人气周榜", @"点赞周榜", @"粉丝贡献"];
//    self.segmentedControl4.sectionTitles = @[@"热门发现"];
//    self.segmentedControl4.sectionTitles = @[@"直播回看", @"粉丝贡献榜"];
    self.segmentedControl4.selectedSegmentIndex = self.segmentedControl4.sectionTitles.count / 2;
    self.segmentedControl4.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    self.segmentedControl4.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:0 blue:0 alpha:1],NSFontAttributeName : [UIFont systemFontOfSize:17]};
    UIColor *selectedColor = [UIColor colorWithRed:255. / 255. green:148. / 255. blue:49. / 255. alpha:1];
    self.segmentedControl4.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : selectedColor,NSFontAttributeName : [UIFont systemFontOfSize:17]};
    self.segmentedControl4.selectionIndicatorColor = selectedColor;
    self.segmentedControl4.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl4.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(5.0, 0, 5.0, 0);
    self.segmentedControl4.selectionIndicatorHeight = 2.0;
    self.segmentedControl4.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentedControl4.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
  
    self.segmentedControl4.tag = 3;

#if 1 // box with round corner
    self.segmentedControl4.selectionStyle = HMSegmentedControlSelectionStyleBox;
    self.segmentedControl4.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:17]};
    self.segmentedControl4.selectionIndicatorBoxColor = selectedColor;
    self.segmentedControl4.selectionIndicatorBoxOpacity = 1;
    self.segmentedControl4.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
    
    // Following two set the box width
    self.segmentedControl4.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(5.0, -20, 5.0, -20);
    self.segmentedControl4.segmentEdgeInset = UIEdgeInsetsMake(0, 20, 0, 20);
    
    self.segmentedControl4.roundSelectionBox = YES;
    self.segmentedControl4.selectionBoxHeight = 36;
    
#endif
  
    __weak typeof(self) weakSelf = self;
    [self.segmentedControl4 setIndexChangeBlock:^(NSInteger index) {
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(viewWidth * index, 0, viewWidth, 200) animated:NO];
    }];
  
    [self.view addSubview:self.segmentedControl4];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 305, viewWidth, 210)];
    self.scrollView.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(viewWidth * self.segmentedControl4.sectionTitles.count, 200);
    self.scrollView.delegate = self;
    [self.scrollView scrollRectToVisible:CGRectMake(viewWidth * self.segmentedControl4.selectedSegmentIndex, 0, viewWidth, 200) animated:NO];
    [self.view addSubview:self.scrollView];
    self.segmentedControl4.relatedScrollView = self.scrollView;

  
    self.segmentedControl4.shouldAnimateDuringUserScrollTheRelatedScrollView = YES;
    
    for (NSInteger index = 0; index < self.segmentedControl4.sectionTitles.count; ++index) {
        NSString *title = self.segmentedControl4.sectionTitles[index];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth * index, 0, viewWidth, 210)];
        [self setApperanceForLabel:label];
        label.text = title;
        [self.scrollView addSubview:label];
    }    
}

- (void)setApperanceForLabel:(UILabel *)label {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    label.backgroundColor = color;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:21.0f];
    label.textAlignment = NSTextAlignmentCenter;
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
}

- (void)uisegmentedControlChangedValue:(UISegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld", (long)segmentedControl.selectedSegmentIndex);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"offset: %.4f", scrollView.contentOffset.x);
    [self.segmentedControl4 scrollViewDidScroll:scrollView];
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
}
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = scrollView.contentOffset.x / pageWidth;
    
    [self.segmentedControl4 setSelectedSegmentIndex:page animated:YES];
}

@end