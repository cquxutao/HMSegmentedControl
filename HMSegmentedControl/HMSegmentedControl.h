//
//  HMSegmentedControl.h
//  HMSegmentedControl
//
//  Created by Hesham Abd-Elmegid on 23/12/12.
//  Copyright (c) 2012-2015 Hesham Abd-Elmegid. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HMSegmentedControl;

typedef void (^IndexChangeBlock)(NSInteger index);
typedef void (^DoubleClickIndexBlock)(NSInteger index);
typedef NSAttributedString *(^HMTitleFormatterBlock)(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected);

typedef NS_ENUM(NSInteger, HMSegmentedControlSelectionStyle) {
    HMSegmentedControlSelectionStyleTextWidthStripe, // Indicator width will only be as big as the text width
    HMSegmentedControlSelectionStyleFullWidthStripe, // Indicator width will fill the whole segment
    HMSegmentedControlSelectionStyleBox, // A rectangle that covers the whole segment
    HMSegmentedControlSelectionStyleArrow // An arrow in the middle of the segment pointing up or down depending on `HMSegmentedControlSelectionIndicatorLocation`
};

typedef NS_ENUM(NSInteger, HMSegmentedControlSelectionIndicatorLocation) {
    HMSegmentedControlSelectionIndicatorLocationUp,
    HMSegmentedControlSelectionIndicatorLocationDown,
    HMSegmentedControlSelectionIndicatorLocationNone // No selection indicator
};

typedef NS_ENUM(NSInteger, HMSegmentedControlSegmentWidthStyle) {
    HMSegmentedControlSegmentWidthStyleFixed, // Segment width is fixed
    HMSegmentedControlSegmentWidthStyleDynamic, // Segment width will only be as big as the text width (including inset)
};

typedef NS_OPTIONS(NSInteger, HMSegmentedControlBorderType) {
    HMSegmentedControlBorderTypeNone = 0,
    HMSegmentedControlBorderTypeTop = (1 << 0),
    HMSegmentedControlBorderTypeLeft = (1 << 1),
    HMSegmentedControlBorderTypeBottom = (1 << 2),
    HMSegmentedControlBorderTypeRight = (1 << 3)
};

enum {
    HMSegmentedControlNoSegment = -1   // Segment index for no selected segment
};

typedef NS_ENUM(NSInteger, HMSegmentedControlType) {
    HMSegmentedControlTypeText,
    HMSegmentedControlTypeImages,
    HMSegmentedControlTypeTextImages
};

@interface HMSegmentedControl : UIControl

@property (nonatomic, strong) NSArray<NSString *> *sectionTitles;
@property (nonatomic, strong) NSArray<UIImage *> *sectionImages;
@property (nonatomic, strong) NSArray<UIImage *> *sectionSelectedImages;

/**
 Provide a block to be executed when selected index is changed.
 
 Alternativly, you could use `addTarget:action:forControlEvents:`
 */
@property (nonatomic, copy) IndexChangeBlock indexChangeBlock;

/**
 Used to apply custom text styling to titles when set.
 
 When this block is set, no additional styling is applied to the `NSAttributedString` object returned from this block.
 */
@property (nonatomic, copy) HMTitleFormatterBlock titleFormatter;

/**
 Text attributes to apply to item title text.
 */
@property (nonatomic, strong) NSDictionary *titleTextAttributes UI_APPEARANCE_SELECTOR;

/*
 Text attributes to apply to selected item title text.
 
 Attributes not set in this dictionary are inherited from `titleTextAttributes`.
 */
@property (nonatomic, strong) NSDictionary *selectedTitleTextAttributes UI_APPEARANCE_SELECTOR;

/**
 Segmented control background color.
 
 Default is `[UIColor whiteColor]`
 */
@property (nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;

/**
 Color for the selection indicator stripe
 
 Default is `R:52, G:181, B:229`
 */
@property (nonatomic, strong) UIColor *selectionIndicatorColor UI_APPEARANCE_SELECTOR;

/**
 Color for the selection indicator box
 
 Default is selectionIndicatorColor
 */
@property (nonatomic, strong) UIColor *selectionIndicatorBoxColor UI_APPEARANCE_SELECTOR;

/**
 Color for the vertical divider between segments.
 
 Default is `[UIColor blackColor]`
 */
@property (nonatomic, strong) UIColor *verticalDividerColor UI_APPEARANCE_SELECTOR;

/**
 Opacity for the seletion indicator box.
 
 Default is `0.2f`
 */
@property (nonatomic) CGFloat selectionIndicatorBoxOpacity;

/**
 Width the vertical divider between segments that is added when `verticalDividerEnabled` is set to YES.
 
 Default is `1.0f`
 */
@property (nonatomic, assign) CGFloat verticalDividerWidth;

/**
 Specifies the style of the control
 
 Default is `HMSegmentedControlTypeText`
 */
@property (nonatomic, assign) HMSegmentedControlType type;

/**
 Specifies the style of the selection indicator.
 
 Default is `HMSegmentedControlSelectionStyleTextWidthStripe`
 */
@property (nonatomic, assign) HMSegmentedControlSelectionStyle selectionStyle;

/**
 Specifies the style of the segment's width.
 
 Default is `HMSegmentedControlSegmentWidthStyleFixed`
 */
@property (nonatomic, assign) HMSegmentedControlSegmentWidthStyle segmentWidthStyle;

/**
 Specifies the location of the selection indicator.
 
 Default is `HMSegmentedControlSelectionIndicatorLocationUp`
 */
@property (nonatomic, assign) HMSegmentedControlSelectionIndicatorLocation selectionIndicatorLocation;

/**
 Only meaningful when selectionStyle is HMSegmentedControlSelectionStyleTextWidthStripe or HMSegmentedControlSelectionStyleFullWidthStripe and type == HMSegmentedControlTypeText.
 Indicate that the selection line will in the top or bottom border, If selectionIndicatorInEdgeBorder set to be true, the selectionIndicatorEdgeInsets property has no sense.
 */
@property (nonatomic) BOOL selectionIndicatorInEdgeBorder;


/*
 Specifies the border type.
 
 Default is `HMSegmentedControlBorderTypeNone`
 */
@property (nonatomic, assign) HMSegmentedControlBorderType borderType;

/**
 Specifies the border color.
 
 Default is `[UIColor blackColor]`
 */
@property (nonatomic, strong) UIColor *borderColor;

/**
 Specifies the border width.
 
 Default is `1.0f`
 */
@property (nonatomic, assign) CGFloat borderWidth;

/**
 Default is YES. Set to NO to deny scrolling by dragging the scrollView by the user.
 */
@property(nonatomic, getter = isUserDraggable) BOOL userDraggable;

/**
 Default is YES. Set to NO to deny any touch events by the user.
 */
@property(nonatomic, getter = isTouchEnabled) BOOL touchEnabled;

/**
 Default is NO. Set to YES to show a vertical divider between the segments.
 */
@property(nonatomic, getter = isVerticalDividerEnabled) BOOL verticalDividerEnabled;

/**
 Index of the currently selected segment.
 */
@property (nonatomic, assign) NSInteger selectedSegmentIndex;

/**
 Height of the selection indicator. Only effective when `HMSegmentedControlSelectionStyle` is either `HMSegmentedControlSelectionStyleTextWidthStripe` or `HMSegmentedControlSelectionStyleFullWidthStripe`.
 
 Default is 5.0
 */
@property (nonatomic, readwrite) CGFloat selectionIndicatorHeight;

/**
 Edge insets for the selection indicator.
 NOTE: This does not affect the bounding box of HMSegmentedControlSelectionStyleBox
 
 When HMSegmentedControlSelectionIndicatorLocationUp is selected, bottom edge insets are not used
 
 When HMSegmentedControlSelectionIndicatorLocationDown is selected, top edge insets are not used
 
 Defaults are top: 0.0f
 left: 0.0f
 bottom: 0.0f
 right: 0.0f
 */
@property (nonatomic, readwrite) UIEdgeInsets selectionIndicatorEdgeInsets;

/**
 Inset left and right edges of segments.
 
 Default is UIEdgeInsetsMake(0, 5, 0, 5)
 */
@property (nonatomic, readwrite) UIEdgeInsets segmentEdgeInset;

@property (nonatomic, readwrite) UIEdgeInsets enlargeEdgeInset;

/**
 Default is YES. Set to NO to disable animation during user selection.
 */
@property (nonatomic) BOOL shouldAnimateUserSelection;

////////////////////////////////////////////////////////////////////////////////////////////////
// Following properties, just work for self.type == HMSegmentedControlTypeText && self.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic

/**
 Defaul is NO. Set to YES if want the indicator animate when scroll the related scroll view.
 If set to YES. You must set the relatedScrollView property and call scrollViewDidScroll: method when the releated UIScrollView scroll
 */
@property(nonatomic) BOOL shouldAnimateDuringUserScrollTheRelatedScrollView;

/**
 The width of related page. Default is equal to the UIScreen's bound's width
 */
@property (nonatomic, assign) CGFloat relatedPageWidth;

/**
 The related UIScrollView.
 */
@property (nonatomic, weak) UIScrollView *relatedScrollView;

/**
 If set to YES, and the total width of the segments < self.frame.size.width,
 Make the horizon space between the segments and margin to be equal.
 Default is NO.
 */
@property (nonatomic) BOOL makeHorizonSpaceEqualEqualityIfPossible;

@property (nonatomic, copy) DoubleClickIndexBlock doubleClickIndexBlock;

// 当segment可滑动时左右的渐变icon
@property (nonatomic, strong) UIImage *leftMaskImage;
@property (nonatomic, strong) UIImage *rightMaskImage;

/**
 Call this when the related UIScrollView did scroll.
 */
- (void)scrollViewDidScroll:(UIScrollView *)relatedScrollView;
////////////////////////////////////////////////////////////////////////////////////////////////

/**
 When the total width of all section is smaller than the self.frame.size.width.
 Default is YES. Set to NO if you don't want this effect.
 */
@property (nonatomic) BOOL centerWhenNecessary;

/**
 Default is NO. Set to YES if you want select effect for single segment
 */
@property (nonatomic) BOOL enableSelectEffectForSingleSegment;
/**
 A flag that indicate whether the releated scroll view scrolled by user.
 If scrolled by user pan gesture: YES
 If scrolled by tap the segment: NO
 */
@property (nonatomic) BOOL doesScrolledByUserPanGesture;

/**
 Default is NO. Set to YES to make the selectin box has a round corner; This property just work when selectionStyle == HMSegmentedControlSelectionStyleBox.
 */
@property (nonatomic) BOOL roundSelectionBox;

/**
 Default is half of the box height. If you set a value bigger than the selection box heigh, it will be half of the selection box height;
 This property just work when selectionStyle == HMSegmentedControlSelectionStyleBox && roundSelectionBox == YES.
 */
@property (nonatomic) CGFloat selectionBoxCornerRadius;
/**
 Default is equal to the segment's height.
 If you set a value which is bigger than segment's height, it will be the segment's height;
 If you set a value which is smaller than the text or image's height of the segment, it will be set to the text or image's height of the segment
 This property just work when selectionStyle == HMSegmentedControlSelectionStyleBox.
 */
@property (nonatomic) CGFloat selectionBoxHeight;

/**
 Default is NO.
 When the segment is the head or the tail, igonre the segmentEdgeInset's left or right value;
 This property just work when type == HMSegmentedControlTypeText && segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic
 */
@property (nonatomic) BOOL ignoreTheHeadAndTheTailLeftAndRightOfSegmentEdgeInset;

- (id)initWithSectionTitles:(NSArray<NSString *> *)sectiontitles;
- (id)initWithSectionImages:(NSArray<UIImage *> *)sectionImages sectionSelectedImages:(NSArray<UIImage *> *)sectionSelectedImages;
- (instancetype)initWithSectionImages:(NSArray<UIImage *> *)sectionImages sectionSelectedImages:(NSArray<UIImage *> *)sectionSelectedImages titlesForSections:(NSArray<NSString *> *)sectiontitles;
- (void)setSelectedSegmentIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)setIndexChangeBlock:(IndexChangeBlock)indexChangeBlock;
- (void)setTitleFormatter:(HMTitleFormatterBlock)titleFormatter;

- (void)updateSegmentsRects;
- (CGFloat)totalSegmentedControlWidth;

@end
