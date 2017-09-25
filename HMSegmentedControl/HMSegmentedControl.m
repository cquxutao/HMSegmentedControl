//
//  HMSegmentedControl.m
//  HMSegmentedControl
//
//  Created by Hesham Abd-Elmegid on 23/12/12.
//  Copyright (c) 2012-2015 Hesham Abd-Elmegid. All rights reserved.
//

#import "HMSegmentedControl.h"
#import <QuartzCore/QuartzCore.h>
#import <math.h>

@interface HMScrollView : UIScrollView
@end

@interface HMSegmentedControl () <UIScrollViewDelegate> {
    NSDictionary *_selectedTitleTextAttributes;
    CGFloat _relatedPageWidth; // The width of related page. Default is equal to the UIScreen's bound's width
    CGSize _screenSize;
    BOOL _enableSelectEffectForSingleSegment; // Default is NO. Set to YES if you want select effect for single segment
    /**
     When the total width of all section is smaller than the self.frame.size.width.
     Default is YES. Set to NO if you don't want this effect.
     */
    BOOL _centerWhenNecessary;
    /**
     A flag that indicate whether the releated scroll view scrolled by user.
     If scrolled by user pan gesture: YES
     If scrolled by tap the segment: NO
     */
    BOOL _doesScrolledByUserPanGesture;
    
    NSMutableDictionary *_titleLayerDictionary;
    CGFloat _selectedRed;
    CGFloat _selectedGreen;
    CGFloat _selectedBlue;
    CGFloat _selectedAlpha;
    CGFloat _normalRed;
    CGFloat _normalGreen;
    CGFloat _normalBlue;
    CGFloat _noramlAlpha;
    UITapGestureRecognizer *_doubleTapGesture;
}

@property (nonatomic, strong) CALayer *selectionIndicatorStripLayer;
@property (nonatomic, strong) CALayer *selectionIndicatorBoxLayer;
@property (nonatomic, strong) CALayer *selectionIndicatorArrowLayer;
@property (nonatomic, readwrite) CGFloat segmentWidth;
@property (nonatomic, readwrite) NSArray<NSNumber *> *segmentWidthsArray;
@property (nonatomic, strong) HMScrollView *scrollView;

@property (nonatomic, strong) UIImageView *leftMaskImageView;
@property (nonatomic, strong) UIImageView *rightMaskImageView;

@end

@implementation HMScrollView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.dragging) {
        [self.nextResponder touchesBegan:touches withEvent:event];
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.dragging) {
        [self.nextResponder touchesMoved:touches withEvent:event];
    } else{
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.dragging) {
        [self.nextResponder touchesEnded:touches withEvent:event];
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

@end

@implementation HMSegmentedControl

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithSectionTitles:(NSArray<NSString *> *)sectiontitles {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self commonInit];
        self.sectionTitles = sectiontitles;
        self.type = HMSegmentedControlTypeText;
    }
    
    return self;
}

- (id)initWithSectionImages:(NSArray<UIImage *> *)sectionImages sectionSelectedImages:(NSArray<UIImage *> *)sectionSelectedImages {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self commonInit];
        self.sectionImages = sectionImages;
        self.sectionSelectedImages = sectionSelectedImages;
        self.type = HMSegmentedControlTypeImages;
    }
    
    return self;
}

- (instancetype)initWithSectionImages:(NSArray<UIImage *> *)sectionImages sectionSelectedImages:(NSArray<UIImage *> *)sectionSelectedImages titlesForSections:(NSArray<NSString *> *)sectiontitles {
	self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self commonInit];
		
		if (sectionImages.count != sectiontitles.count) {
			[NSException raise:NSRangeException format:@"***%s: Images bounds (%ld) Don't match Title bounds (%ld)", sel_getName(_cmd), (unsigned long)sectionImages.count, (unsigned long)sectiontitles.count];
        }
        
        self.sectionImages = sectionImages;
        self.sectionSelectedImages = sectionSelectedImages;
        self.sectionTitles = sectiontitles;
        self.type = HMSegmentedControlTypeTextImages;
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.segmentWidth = 0.0f;
}

- (void)commonInit {
    self.scrollView = [[HMScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    _backgroundColor = [UIColor whiteColor];
    self.opaque = NO;
    _selectionIndicatorColor = [UIColor colorWithRed:52.0f/255.0f green:181.0f/255.0f blue:229.0f/255.0f alpha:1.0f];
    _selectionIndicatorBoxColor = _selectionIndicatorColor;

    self.selectedSegmentIndex = 0;
    self.segmentEdgeInset = UIEdgeInsetsMake(0, 5, 0, 5);
    self.selectionIndicatorHeight = 5.0f;
    self.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationUp;
    self.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    self.userDraggable = YES;
    self.touchEnabled = YES;
    self.verticalDividerEnabled = NO;
    self.type = HMSegmentedControlTypeText;
    self.verticalDividerWidth = 1.0f;
    _verticalDividerColor = [UIColor blackColor];
    self.borderColor = [UIColor blackColor];
    self.borderWidth = 1.0f;
    
    self.shouldAnimateUserSelection = YES;
    
    self.selectionIndicatorArrowLayer = [CALayer layer];
    self.selectionIndicatorStripLayer = [CALayer layer];
    self.selectionIndicatorBoxLayer = [CALayer layer];
    self.selectionIndicatorBoxLayer.opacity = self.selectionIndicatorBoxOpacity;
    self.selectionIndicatorBoxLayer.borderWidth = 1.0f;
    self.selectionIndicatorBoxOpacity = 0.2;
    
    self.contentMode = UIViewContentModeRedraw;
    
    _enableSelectEffectForSingleSegment = NO;
    _centerWhenNecessary = YES;
    _makeHorizonSpaceEqualEqualityIfPossible = NO;
    _relatedPageWidth = UIScreen.mainScreen.bounds.size.width;
    _screenSize = CGSizeMake(_relatedPageWidth, UIScreen.mainScreen.bounds.size.height);
    _titleLayerDictionary = @{}.mutableCopy;
    
    _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
    _doubleTapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:_doubleTapGesture];
}

- (void)dealloc {
    [self.relatedScrollView.panGestureRecognizer removeTarget:self action:@selector(scrollViewPanGestureRecognizerAction:)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_relatedPageWidth == UIScreen.mainScreen.bounds.size.width || _relatedPageWidth == UIScreen.mainScreen.bounds.size.height) {
        _relatedPageWidth = UIScreen.mainScreen.bounds.size.width;
    }
    _screenSize = CGSizeMake(_relatedPageWidth, UIScreen.mainScreen.bounds.size.height);
    
    [self updateSegmentsRects];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self updateSegmentsRects];
}

- (void)setSectionTitles:(NSArray<NSString *> *)sectionTitles {
    _sectionTitles = sectionTitles;
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setSectionImages:(NSArray<UIImage *> *)sectionImages {
    _sectionImages = sectionImages;
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setSelectionIndicatorLocation:(HMSegmentedControlSelectionIndicatorLocation)selectionIndicatorLocation {
    _selectionIndicatorLocation = selectionIndicatorLocation;
    
    if (selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationNone) {
        self.selectionIndicatorHeight = 0.0f;
    }
}

- (void)setSelectionIndicatorBoxOpacity:(CGFloat)selectionIndicatorBoxOpacity {
    _selectionIndicatorBoxOpacity = selectionIndicatorBoxOpacity;
    
    self.selectionIndicatorBoxLayer.opacity = _selectionIndicatorBoxOpacity;
}

- (void)setSegmentWidthStyle:(HMSegmentedControlSegmentWidthStyle)segmentWidthStyle {
    // Force HMSegmentedControlSegmentWidthStyleFixed when type is HMSegmentedControlTypeImages.
    if (self.type == HMSegmentedControlTypeImages) {
        _segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    } else {
        _segmentWidthStyle = segmentWidthStyle;
    }
}

- (void)setBorderType:(HMSegmentedControlBorderType)borderType {
    _borderType = borderType;
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (CGSize)measureTitleAtIndex:(NSUInteger)index {
    if (index >= self.sectionTitles.count) {
        return CGSizeZero;
    }
    
    id title = self.sectionTitles[index];
    CGSize size = CGSizeZero;
    BOOL selected = (index == self.selectedSegmentIndex) ? YES : NO;
    if ([title isKindOfClass:[NSString class]] && !self.titleFormatter) {
        NSDictionary *titleAttrs = selected ? [self resultingSelectedTitleTextAttributes] : [self resultingTitleTextAttributes];
        size = [(NSString *)title sizeWithAttributes:titleAttrs];
    } else if ([title isKindOfClass:[NSString class]] && self.titleFormatter) {
        size = [self.titleFormatter(self, title, index, selected) size];
    } else if ([title isKindOfClass:[NSAttributedString class]]) {
        size = [(NSAttributedString *)title size];
    } else {
        NSAssert(title == nil, @"Unexpected type of segment title: %@", [title class]);
        size = CGSizeZero;
    }
    return CGRectIntegral((CGRect){CGPointZero, size}).size;
}

- (NSAttributedString *)attributedTitleAtIndex:(NSUInteger)index {
    id title = self.sectionTitles[index];
    BOOL selected = (index == self.selectedSegmentIndex) ? YES : NO;
    
    if ([title isKindOfClass:[NSAttributedString class]]) {
        return (NSAttributedString *)title;
    } else if (!self.titleFormatter) {
        NSDictionary *titleAttrs = selected ? [self resultingSelectedTitleTextAttributes] : [self resultingTitleTextAttributes];
        
        // the color should be cast to CGColor in order to avoid invalid context on iOS7
        UIColor *titleColor = titleAttrs[NSForegroundColorAttributeName];
        
        if (titleColor) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:titleAttrs];
            
            dict[NSForegroundColorAttributeName] = (id)titleColor.CGColor;
            
            titleAttrs = [NSDictionary dictionaryWithDictionary:dict];
        }
        
        return [[NSAttributedString alloc] initWithString:(NSString *)title attributes:titleAttrs];
    } else {
        return self.titleFormatter(self, title, index, selected);
    }
}

- (void)drawRect:(CGRect)rect {
    [self.backgroundColor setFill];
    UIRectFill([self bounds]);
    
    self.selectionIndicatorArrowLayer.backgroundColor = self.selectionIndicatorColor.CGColor;
    
    self.selectionIndicatorStripLayer.backgroundColor = self.selectionIndicatorColor.CGColor;
    
    self.selectionIndicatorBoxLayer.backgroundColor = self.selectionIndicatorBoxColor.CGColor;
    self.selectionIndicatorBoxLayer.borderColor = self.selectionIndicatorBoxColor.CGColor;
    
    // Remove all sublayers to avoid drawing images over existing ones
    self.scrollView.layer.sublayers = nil;
    [_titleLayerDictionary removeAllObjects];
    CGRect oldRect = rect;
    
    if (self.type == HMSegmentedControlTypeText) {
        [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop) {
            
            CGFloat stringWidth = 0;
            CGFloat stringHeight = 0;
            CGSize size = [self measureTitleAtIndex:idx];
            stringWidth = size.width;
            stringHeight = size.height;
            CGRect rectDiv = CGRectZero;
            CGRect fullRect = CGRectZero;
            
            // Text inside the CATextLayer will appear blurry unless the rect values are rounded
            BOOL locationUp = (self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationUp);
            BOOL selectionStyleNotBox = (self.selectionStyle != HMSegmentedControlSelectionStyleBox);
            
            CGFloat y = roundf((CGRectGetHeight(self.frame) - selectionStyleNotBox * self.selectionIndicatorHeight) / 2 - stringHeight / 2 + self.selectionIndicatorHeight * locationUp);
            CGRect rect;
            if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed) {
                rect = CGRectMake((self.segmentWidth * idx) + (self.segmentWidth - stringWidth) / 2, y, stringWidth, stringHeight);
                rectDiv = CGRectMake((self.segmentWidth * idx) - (self.verticalDividerWidth / 2), self.selectionIndicatorHeight * 2, self.verticalDividerWidth, self.frame.size.height - (self.selectionIndicatorHeight * 4));
                fullRect = CGRectMake(self.segmentWidth * idx, 0, self.segmentWidth, oldRect.size.height);
            } else {
                // When we are drawing dynamic widths, we need to loop the widths array to calculate the xOffset
                CGFloat xOffset = 0;
                NSInteger i = 0;
                for (NSNumber *width in self.segmentWidthsArray) {
                    if (idx == i)
                        break;
                    xOffset = xOffset + [width floatValue];
                    i++;
                }
                CGFloat totalWidth = [self totalSegmentedControlWidth];
                if (self.makeHorizonSpaceEqualEqualityIfPossible && totalWidth < self.frame.size.width) {
                    CGFloat horizonSpace = (self.frame.size.width - totalWidth) / ([self sectionCount] + 1);
                    xOffset = (idx + 1) * horizonSpace;
                    for (NSInteger index = idx - 1; index >= 0; --index) {
                        xOffset += [self.segmentWidthsArray[index] floatValue];
                    }
                } else if (_centerWhenNecessary) {
                    if (totalWidth < self.frame.size.width) {
                        CGFloat totalLeftMargin = (self.frame.size.width - totalWidth) / 2;
                        xOffset += totalLeftMargin;
                    }
                    
                }
                
                y = roundf((CGRectGetHeight(self.frame)) / 2 - stringHeight / 2);
                
                CGFloat widthForIndex = [[self.segmentWidthsArray objectAtIndex:idx] floatValue];
                rect = CGRectMake(xOffset, y, widthForIndex, stringHeight);
                fullRect = CGRectMake(self.segmentWidth * idx, 0, widthForIndex, oldRect.size.height);
                rectDiv = CGRectMake(xOffset - (self.verticalDividerWidth / 2), self.selectionIndicatorHeight * 2, self.verticalDividerWidth, self.frame.size.height - (self.selectionIndicatorHeight * 4));
            }
            
            // Fix rect position/size to avoid blurry labels
            rect = CGRectMake(ceilf(rect.origin.x), ceilf(rect.origin.y), ceilf(rect.size.width), ceilf(rect.size.height));
            
            CATextLayer *titleLayer = [CATextLayer layer];
            titleLayer.frame = rect;
            titleLayer.alignmentMode = kCAAlignmentCenter;
            if ([UIDevice currentDevice].systemVersion.floatValue < 10.0 ) {
                titleLayer.truncationMode = kCATruncationEnd;
            }
            titleLayer.string = [self attributedTitleAtIndex:idx];
            titleLayer.contentsScale = [[UIScreen mainScreen] scale];
            
            [self.scrollView.layer addSublayer:titleLayer];
            
            // Vertical Divider
            if (self.isVerticalDividerEnabled && idx > 0) {
                CALayer *verticalDividerLayer = [CALayer layer];
                verticalDividerLayer.frame = rectDiv;
                verticalDividerLayer.backgroundColor = self.verticalDividerColor.CGColor;
                
                [self.scrollView.layer addSublayer:verticalDividerLayer];
            }
            
            [self addBackgroundAndBorderLayerWithRect:fullRect];
            
            _titleLayerDictionary[titleString] = titleLayer;
        }];
    } else if (self.type == HMSegmentedControlTypeImages) {
        [self.sectionImages enumerateObjectsUsingBlock:^(id iconImage, NSUInteger idx, BOOL *stop) {
            UIImage *icon = iconImage;
            CGFloat imageWidth = icon.size.width;
            CGFloat imageHeight = icon.size.height;
            CGFloat y = roundf(CGRectGetHeight(self.frame) - self.selectionIndicatorHeight) / 2 - imageHeight / 2 + ((self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationUp) ? self.selectionIndicatorHeight : 0);
            CGFloat x = self.segmentWidth * idx + (self.segmentWidth - imageWidth)/2.0f;
            CGRect rect = CGRectMake(x, y, imageWidth, imageHeight);
            
            CALayer *imageLayer = [CALayer layer];
            imageLayer.frame = rect;
            
            if (self.selectedSegmentIndex == idx) {
                if (self.sectionSelectedImages) {
                    UIImage *highlightIcon = [self.sectionSelectedImages objectAtIndex:idx];
                    imageLayer.contents = (id)highlightIcon.CGImage;
                } else {
                    imageLayer.contents = (id)icon.CGImage;
                }
            } else {
                imageLayer.contents = (id)icon.CGImage;
            }
            
            [self.scrollView.layer addSublayer:imageLayer];
            // Vertical Divider
            if (self.isVerticalDividerEnabled && idx>0) {
                CALayer *verticalDividerLayer = [CALayer layer];
                verticalDividerLayer.frame = CGRectMake((self.segmentWidth * idx) - (self.verticalDividerWidth / 2), self.selectionIndicatorHeight * 2, self.verticalDividerWidth, self.frame.size.height-(self.selectionIndicatorHeight * 4));
                verticalDividerLayer.backgroundColor = self.verticalDividerColor.CGColor;
                
                [self.scrollView.layer addSublayer:verticalDividerLayer];
            }
            
            [self addBackgroundAndBorderLayerWithRect:rect];
        }];
    } else if (self.type == HMSegmentedControlTypeTextImages){
        [self.sectionImages enumerateObjectsUsingBlock:^(id iconImage, NSUInteger idx, BOOL *stop) {
            UIImage *icon = iconImage;
            CGFloat imageWidth = icon.size.width;
            CGFloat imageHeight = icon.size.height;
            
            CGFloat stringHeight = [self measureTitleAtIndex:idx].height;
            CGFloat yOffset = roundf(((CGRectGetHeight(self.frame) - self.selectionIndicatorHeight) / 2) - (stringHeight / 2));
            
            CGFloat imageXOffset = self.segmentEdgeInset.left; // Start with edge inset
            CGFloat textXOffset  = self.segmentEdgeInset.left;
            CGFloat textWidth = 0;
            
            if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed) {
                imageXOffset = (self.segmentWidth * idx) + (self.segmentWidth / 2.0f) - (imageWidth / 2.0f);
                textXOffset = self.segmentWidth * idx;
                textWidth = self.segmentWidth;
            } else if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
                // When we are drawing dynamic widths, we need to loop the widths array to calculate the xOffset
                CGFloat xOffset = 0;
                NSInteger i = 0;
                
                for (NSNumber *width in self.segmentWidthsArray) {
                    if (idx == i) {
                        break;
                    }
                    
                    xOffset = xOffset + [width floatValue];
                    i++;
                }
                
                imageXOffset = xOffset + ([self.segmentWidthsArray[idx] floatValue] / 2.0f) - (imageWidth / 2.0f); //(self.segmentWidth / 2.0f) - (imageWidth / 2.0f)
                textXOffset = xOffset;
                textWidth = [self.segmentWidthsArray[idx] floatValue];
            }
            
            CGFloat imageYOffset = roundf((CGRectGetHeight(self.frame) - self.selectionIndicatorHeight) / 2.0f);
            CGRect imageRect = CGRectMake(imageXOffset, imageYOffset, imageWidth, imageHeight);
            CGRect textRect = CGRectMake(textXOffset, yOffset, textWidth, stringHeight);
            
            // Fix rect position/size to avoid blurry labels
            textRect = CGRectMake(ceilf(textRect.origin.x), ceilf(textRect.origin.y), ceilf(textRect.size.width), ceilf(textRect.size.height));
            
            CATextLayer *titleLayer = [CATextLayer layer];
            titleLayer.frame = textRect;
            titleLayer.alignmentMode = kCAAlignmentCenter;
            titleLayer.string = [self attributedTitleAtIndex:idx];
            if ([UIDevice currentDevice].systemVersion.floatValue < 10.0 ) {
                titleLayer.truncationMode = kCATruncationEnd;
            }
            CALayer *imageLayer = [CALayer layer];
            imageLayer.frame = imageRect;
            
            if (self.selectedSegmentIndex == idx) {
                if (self.sectionSelectedImages) {
                    UIImage *highlightIcon = [self.sectionSelectedImages objectAtIndex:idx];
                    imageLayer.contents = (id)highlightIcon.CGImage;
                } else {
                    imageLayer.contents = (id)icon.CGImage;
                }
            } else {
                imageLayer.contents = (id)icon.CGImage;
            }
            
            [self.scrollView.layer addSublayer:imageLayer];
            titleLayer.contentsScale = [[UIScreen mainScreen] scale];
            [self.scrollView.layer addSublayer:titleLayer];
            
            [self addBackgroundAndBorderLayerWithRect:imageRect];
            
            _titleLayerDictionary[self.sectionTitles[idx]] = titleLayer;
        }];
    }
    
    if ([self sectionCount] == 0) {
        return;
    }
    
    // Add the selection indicators
    if ([self sectionCount] == 1 && !_enableSelectEffectForSingleSegment) {
        return;
    }
    
    if (self.selectedSegmentIndex != HMSegmentedControlNoSegment) {
        if (self.selectionStyle == HMSegmentedControlSelectionStyleArrow) {
            if (!self.selectionIndicatorArrowLayer.superlayer) {
                [self setArrowFrame];
                [self.scrollView.layer addSublayer:self.selectionIndicatorArrowLayer];
            }
        } else {
            if (!self.selectionIndicatorStripLayer.superlayer) {
                self.selectionIndicatorStripLayer.frame = [self frameForSelectionIndicator];
                [self.scrollView.layer addSublayer:self.selectionIndicatorStripLayer];
                
                if (self.selectionStyle == HMSegmentedControlSelectionStyleBox && !self.selectionIndicatorBoxLayer.superlayer) {
                    self.selectionIndicatorBoxLayer.frame = [self frameForFillerSelectionIndicator];
                    [self.scrollView.layer insertSublayer:self.selectionIndicatorBoxLayer atIndex:0];
                }
            }
        }
    }
    
    // Show left or right mask image
    // Just add for dynamic text type.
    // TODO: support other type, other type need calculate the toal content size.
    if (self.type == HMSegmentedControlTypeText && self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
        [self updateLeftMaskImageFrame];
        [self updateRightMaskImageFrame];
    }
}

- (void)addBackgroundAndBorderLayerWithRect:(CGRect)fullRect {
    // Background layer
    CALayer *backgroundLayer = [CALayer layer];
    backgroundLayer.frame = fullRect;
    [self.layer insertSublayer:backgroundLayer atIndex:0];
    
    // Border layer
    if (self.borderType & HMSegmentedControlBorderTypeTop) {
        CALayer *borderLayer = [CALayer layer];
        borderLayer.frame = CGRectMake(0, 0, fullRect.size.width, self.borderWidth);
        borderLayer.backgroundColor = self.borderColor.CGColor;
        [backgroundLayer addSublayer: borderLayer];
    }
    if (self.borderType & HMSegmentedControlBorderTypeLeft) {
        CALayer *borderLayer = [CALayer layer];
        borderLayer.frame = CGRectMake(0, 0, self.borderWidth, fullRect.size.height);
        borderLayer.backgroundColor = self.borderColor.CGColor;
        [backgroundLayer addSublayer: borderLayer];
    }
    if (self.borderType & HMSegmentedControlBorderTypeBottom) {
        CALayer *borderLayer = [CALayer layer];
        borderLayer.frame = CGRectMake(0, fullRect.size.height - self.borderWidth, fullRect.size.width, self.borderWidth);
        borderLayer.backgroundColor = self.borderColor.CGColor;
        [backgroundLayer addSublayer: borderLayer];
    }
    if (self.borderType & HMSegmentedControlBorderTypeRight) {
        CALayer *borderLayer = [CALayer layer];
        borderLayer.frame = CGRectMake(fullRect.size.width - self.borderWidth, 0, self.borderWidth, fullRect.size.height);
        borderLayer.backgroundColor = self.borderColor.CGColor;
        [backgroundLayer addSublayer: borderLayer];
    }
}

- (void)setArrowFrame {
    [self setArrowFrameWithFrame:[self frameForSelectionIndicator]];
}

- (void)setArrowFrameWithFrame:(CGRect)frameForSelectionIndicator {
    self.selectionIndicatorArrowLayer.frame = frameForSelectionIndicator;
    
    self.selectionIndicatorArrowLayer.mask = nil;
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointZero;
    CGPoint p3 = CGPointZero;
    
    if (self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationDown) {
        p1 = CGPointMake(self.selectionIndicatorArrowLayer.bounds.size.width / 2, 0);
        p2 = CGPointMake(0, self.selectionIndicatorArrowLayer.bounds.size.height);
        p3 = CGPointMake(self.selectionIndicatorArrowLayer.bounds.size.width, self.selectionIndicatorArrowLayer.bounds.size.height);
    }
    
    if (self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationUp) {
        p1 = CGPointMake(self.selectionIndicatorArrowLayer.bounds.size.width / 2, self.selectionIndicatorArrowLayer.bounds.size.height);
        p2 = CGPointMake(self.selectionIndicatorArrowLayer.bounds.size.width, 0);
        p3 = CGPointMake(0, 0);
    }
    
    [arrowPath moveToPoint:p1];
    [arrowPath addLineToPoint:p2];
    [arrowPath addLineToPoint:p3];
    [arrowPath closePath];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.selectionIndicatorArrowLayer.bounds;
    maskLayer.path = arrowPath.CGPath;
    self.selectionIndicatorArrowLayer.mask = maskLayer;
}


- (CGRect)frameForSelectionIndicator {
    return [self frameForSelectionIndicatorWithSelectedSegmentIndex:self.selectedSegmentIndex];
}

- (CGRect)frameForSelectionIndicatorWithSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    CGFloat indicatorYOffset = 0.0f;
    
    if (self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationDown) {
        indicatorYOffset = self.bounds.size.height - self.selectionIndicatorHeight + self.selectionIndicatorEdgeInsets.bottom;
    }
    
    if (self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationUp) {
        indicatorYOffset = self.selectionIndicatorEdgeInsets.top;
    }
    
    CGFloat sectionWidth = 0.0f;
    CGFloat sectionHeight = 0.0f;
    
    if (self.type == HMSegmentedControlTypeText) {
        CGSize textSize = [self measureTitleAtIndex:selectedSegmentIndex];
        sectionWidth = textSize.width;
        sectionHeight = textSize.height;
    } else if (self.type == HMSegmentedControlTypeImages) {
        UIImage *sectionImage = [self.sectionImages objectAtIndex:selectedSegmentIndex];
        CGFloat imageWidth = sectionImage.size.width;
        sectionWidth = imageWidth;
    } else if (self.type == HMSegmentedControlTypeTextImages) {
        CGFloat stringWidth = [self measureTitleAtIndex:selectedSegmentIndex].width;
        UIImage *sectionImage = [self.sectionImages objectAtIndex:selectedSegmentIndex];
        CGFloat imageWidth = sectionImage.size.width;
        sectionWidth = MAX(stringWidth, imageWidth);
    }
    
    if (self.selectionStyle == HMSegmentedControlSelectionStyleArrow) {
        CGFloat widthToEndOfSelectedSegment = (self.segmentWidth * selectedSegmentIndex) + self.segmentWidth;
        CGFloat widthToStartOfSelectedIndex = (self.segmentWidth * selectedSegmentIndex);
        
        CGFloat x = widthToStartOfSelectedIndex + ((widthToEndOfSelectedSegment - widthToStartOfSelectedIndex) / 2) - (self.selectionIndicatorHeight/2);
        return CGRectMake(x - (self.selectionIndicatorHeight / 2), indicatorYOffset, self.selectionIndicatorHeight * 2, self.selectionIndicatorHeight);
    } else {
        if (self.selectionStyle == HMSegmentedControlSelectionStyleTextWidthStripe &&
            sectionWidth <= self.segmentWidth &&
            self.segmentWidthStyle != HMSegmentedControlSegmentWidthStyleDynamic) {
            CGFloat widthToEndOfSelectedSegment = (self.segmentWidth * selectedSegmentIndex) + self.segmentWidth;
            CGFloat widthToStartOfSelectedIndex = (self.segmentWidth * selectedSegmentIndex);
            
            CGFloat x = ((widthToEndOfSelectedSegment - widthToStartOfSelectedIndex) / 2) + (widthToStartOfSelectedIndex - sectionWidth / 2);
            return CGRectMake(x + self.selectionIndicatorEdgeInsets.left, indicatorYOffset, sectionWidth - self.selectionIndicatorEdgeInsets.right, self.selectionIndicatorHeight);
        } else {
            if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
                CGFloat selectedSegmentOffset = 0.0f;
                
                NSInteger i = 0;
                for (NSNumber *width in self.segmentWidthsArray) {
                    if (selectedSegmentIndex == i)
                        break;
                    selectedSegmentOffset = selectedSegmentOffset + [width floatValue];
                    i++;
                }
                
                if (self.type == HMSegmentedControlTypeText) {
                    CGFloat totalWidth = [self totalSegmentedControlWidth];
                    if (self.makeHorizonSpaceEqualEqualityIfPossible && totalWidth < self.frame.size.width) {
                        CGFloat horizonSpace = (self.frame.size.width - totalWidth) / ([self sectionCount] + 1);
                        selectedSegmentOffset = (selectedSegmentIndex + 1) * horizonSpace;
                        for (NSInteger index = selectedSegmentIndex - 1; index >= 0; --index) {
                            selectedSegmentOffset += [self.segmentWidthsArray[index] floatValue];
                        }
                    } else if (_centerWhenNecessary && totalWidth < self.frame.size.width) {
                        CGFloat totalLeftMargin = (self.frame.size.width - totalWidth) / 2;
                        selectedSegmentOffset += totalLeftMargin;
                    }
                    
                    if (self.type == HMSegmentedControlTypeText) {
                        if (self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationDown) {
                            indicatorYOffset = roundf((CGRectGetHeight(self.frame) - sectionHeight) / 2 + sectionHeight + self.selectionIndicatorEdgeInsets.top);
                        } else if (self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationUp) {
                            indicatorYOffset = roundf((CGRectGetHeight(self.frame) - sectionHeight) / 2 - self.selectionIndicatorEdgeInsets.bottom - self.selectionIndicatorHeight);
                        }
                        
                        if (self.selectionIndicatorInEdgeBorder) {
                            if (self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationDown) {
                                indicatorYOffset = roundf((CGRectGetHeight(self.frame) - self.selectionIndicatorHeight));
                            } else if (self.selectionIndicatorLocation == HMSegmentedControlSelectionIndicatorLocationUp) {
                                indicatorYOffset = 0;
                            }
                        }
                    }
                    
                    CGRect rect = CGRectMake(selectedSegmentOffset + self.selectionIndicatorEdgeInsets.left, indicatorYOffset, [[self.segmentWidthsArray objectAtIndex:selectedSegmentIndex] floatValue] - self.selectionIndicatorEdgeInsets.right - self.selectionIndicatorEdgeInsets.left, self.selectionIndicatorHeight);
                    
                    if ((_centerWhenNecessary || self.makeHorizonSpaceEqualEqualityIfPossible)) {
                        rect.origin.x += (rect.size.width - sectionWidth) / 2;
                        rect.size.width = sectionWidth;
                    }
                    
                    CGFloat adjustWidth = (rect.size.width - self.selectionIndicatorEdgeInsets.left - self.selectionIndicatorEdgeInsets.right);
                    rect.origin.x += self.selectionIndicatorEdgeInsets.left;
                    rect.size.width = adjustWidth;
                    
                    return rect;
                } else {
                    return CGRectMake(selectedSegmentOffset + self.selectionIndicatorEdgeInsets.left, indicatorYOffset, [[self.segmentWidthsArray objectAtIndex:selectedSegmentIndex] floatValue] - self.selectionIndicatorEdgeInsets.right, self.selectionIndicatorHeight);
                }
            }
            
            return CGRectMake((self.segmentWidth + self.selectionIndicatorEdgeInsets.left) * selectedSegmentIndex, indicatorYOffset, self.segmentWidth - self.selectionIndicatorEdgeInsets.right, self.selectionIndicatorHeight);
        }
    }
}

- (CGRect)frameForFillerSelectionIndicator {
    return [self frameForFillerSelectionIndicatorWithSelectedSegmentIndex:self.selectedSegmentIndex];
}

- (CGRect)frameForFillerSelectionIndicatorWithSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
        CGFloat selectedSegmentOffset = 0.0f;
        
        NSInteger i = 0;
        for (NSNumber *width in self.segmentWidthsArray) {
            if (selectedSegmentIndex == i) {
                break;
            }
            selectedSegmentOffset = selectedSegmentOffset + [width floatValue];
            
            i++;
        }
        
        if (self.type == HMSegmentedControlTypeText) {
            CGFloat totalWidth = [self totalSegmentedControlWidth];
            if (self.makeHorizonSpaceEqualEqualityIfPossible && totalWidth < self.frame.size.width) {
                CGFloat horizonSpace = (self.frame.size.width - totalWidth) / ([self sectionCount] + 1);
                selectedSegmentOffset = (selectedSegmentIndex + 1) * horizonSpace;
                for (NSInteger index = selectedSegmentIndex - 1; index >= 0; --index) {
                    selectedSegmentOffset += [self.segmentWidthsArray[index] floatValue];
                }
            } else if (_centerWhenNecessary && totalWidth < self.frame.size.width) {
                CGFloat totalLeftMargin = (self.frame.size.width - totalWidth) / 2;
                selectedSegmentOffset += totalLeftMargin;
            }
            
            CGRect rect = CGRectMake(selectedSegmentOffset + self.selectionIndicatorEdgeInsets.left, 0, [[self.segmentWidthsArray objectAtIndex:selectedSegmentIndex] floatValue] - self.selectionIndicatorEdgeInsets.right - self.selectionIndicatorEdgeInsets.left, CGRectGetHeight(self.frame));
            
            CGFloat sectionWidth = [self measureTitleAtIndex:selectedSegmentIndex].width;
            
            if (_centerWhenNecessary || self.makeHorizonSpaceEqualEqualityIfPossible) {
                rect.origin.x += (rect.size.width - sectionWidth) / 2;
                rect.size.width = sectionWidth;
            }
            
            CGFloat adjustWidth = (rect.size.width - self.selectionIndicatorEdgeInsets.left - self.selectionIndicatorEdgeInsets.right);
            rect.origin.x += self.selectionIndicatorEdgeInsets.left;
            rect.size.width = adjustWidth;
            
            return rect;
        } else {
            return CGRectMake(selectedSegmentOffset, 0, [[self.segmentWidthsArray objectAtIndex:selectedSegmentIndex] floatValue], CGRectGetHeight(self.frame));
        }
    }
    return CGRectMake(self.segmentWidth * selectedSegmentIndex, 0, self.segmentWidth, CGRectGetHeight(self.frame));
}

- (void)updateSegmentsRects {
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    if ([self sectionCount] > 0) {
        self.segmentWidth = self.frame.size.width / [self sectionCount];
    }
    
    if (self.type == HMSegmentedControlTypeText && self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed) {
        [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop) {
            CGFloat stringWidth = [self measureTitleAtIndex:idx].width + self.segmentEdgeInset.left + self.segmentEdgeInset.right;
            self.segmentWidth = MAX(stringWidth, self.segmentWidth);
        }];
    } else if (self.type == HMSegmentedControlTypeText && self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
        NSMutableArray *mutableSegmentWidths = [NSMutableArray array];
        
        [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop) {
            CGFloat stringWidth = [self measureTitleAtIndex:idx].width + self.segmentEdgeInset.left + self.segmentEdgeInset.right;
            [mutableSegmentWidths addObject:[NSNumber numberWithFloat:stringWidth]];
        }];
        self.segmentWidthsArray = [mutableSegmentWidths copy];
    } else if (self.type == HMSegmentedControlTypeImages) {
        for (UIImage *sectionImage in self.sectionImages) {
            CGFloat imageWidth = sectionImage.size.width + self.segmentEdgeInset.left + self.segmentEdgeInset.right;
            self.segmentWidth = MAX(imageWidth, self.segmentWidth);
        }
    } else if (self.type == HMSegmentedControlTypeTextImages && self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed){
        //lets just use the title.. we will assume it is wider then images...
        [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop) {
            CGFloat stringWidth = [self measureTitleAtIndex:idx].width + self.segmentEdgeInset.left + self.segmentEdgeInset.right;
            self.segmentWidth = MAX(stringWidth, self.segmentWidth);
        }];
    } else if (self.type == HMSegmentedControlTypeTextImages && self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
        NSMutableArray *mutableSegmentWidths = [NSMutableArray array];
        
        int i = 0;
        [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop) {
            CGFloat stringWidth = [self measureTitleAtIndex:idx].width + self.segmentEdgeInset.right;
            UIImage *sectionImage = [self.sectionImages objectAtIndex:i];
            CGFloat imageWidth = sectionImage.size.width + self.segmentEdgeInset.left;
            
            CGFloat combinedWidth = MAX(imageWidth, stringWidth);
            
            [mutableSegmentWidths addObject:[NSNumber numberWithFloat:combinedWidth]];
        }];
        self.segmentWidthsArray = [mutableSegmentWidths copy];
    }
    
    self.scrollView.scrollEnabled = self.isUserDraggable;
    self.scrollView.contentSize = CGSizeMake([self totalSegmentedControlWidth], self.frame.size.height);
}

- (NSUInteger)sectionCount {
    if (self.type == HMSegmentedControlTypeText) {
        return self.sectionTitles.count;
    } else if (self.type == HMSegmentedControlTypeImages ||
               self.type == HMSegmentedControlTypeTextImages) {
        return self.sectionImages.count;
    }
    
    return 0;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // Control is being removed
    if (newSuperview == nil)
        return;
    
    if (self.sectionTitles || self.sectionImages) {
        [self updateSegmentsRects];
    }
}

#pragma mark - Touch

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    CGRect enlargeRect =   CGRectMake(self.bounds.origin.x - self.enlargeEdgeInset.left,
                                      self.bounds.origin.y - self.enlargeEdgeInset.top,
                                      self.bounds.size.width + self.enlargeEdgeInset.left + self.enlargeEdgeInset.right,
                                      self.bounds.size.height + self.enlargeEdgeInset.top + self.enlargeEdgeInset.bottom);
    
    if (CGRectContainsPoint(enlargeRect, touchLocation)) {
        NSInteger segment = 0;
        if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed) {
            segment = (touchLocation.x + self.scrollView.contentOffset.x) / self.segmentWidth;
        } else if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
            // To know which segment the user touched, we need to loop over the widths and substract it from the x position.
            CGFloat widthLeft = (touchLocation.x + self.scrollView.contentOffset.x);
            
            CGFloat totalWidth = [self totalSegmentedControlWidth];
            if (self.type == HMSegmentedControlTypeText && self.makeHorizonSpaceEqualEqualityIfPossible && totalWidth < self.frame.size.width) {
                CGFloat horizonSpace = (self.frame.size.width - totalWidth) / ([self sectionCount] + 1);
                segment = -1;
                for (NSInteger index = 0; index < self.segmentWidthsArray.count; ++index) {
                    CGFloat selectedSegmentOffset = (index + 1) * horizonSpace;
                    for (NSInteger innerIndex = index - 1; innerIndex >= 0; --innerIndex) {
                        selectedSegmentOffset += [self.segmentWidthsArray[innerIndex] floatValue];
                    }
                    if (widthLeft >= selectedSegmentOffset && widthLeft <= (selectedSegmentOffset + [self.segmentWidthsArray[index] floatValue])) {
                        segment = index;
                        break;
                    } else if (widthLeft < selectedSegmentOffset) {
                        break;
                    }
                }
            } else if (self.type == HMSegmentedControlTypeText && _centerWhenNecessary && totalWidth < self.frame.size.width) {
                CGFloat totalLeftMargin = (self.frame.size.width - totalWidth) / 2;
                CGFloat segmentOffset = totalLeftMargin;
                
                if (widthLeft < segmentOffset) { // The point's X is in the left of the most left segment after centerlized
                    return;
                }
                
                if (widthLeft > segmentOffset + totalWidth) { // The point's X is in the right of the most right segment after centerlized
                    return;
                }
                
                segment = -1;
                for (NSNumber *segmentWidth in self.segmentWidthsArray) {
                    segmentOffset += [segmentWidth floatValue];
                    ++segment;
                    if (widthLeft < segmentOffset) {
                        break;
                    }
                }
            } else {
                for (NSNumber *width in self.segmentWidthsArray) {
                    widthLeft = widthLeft - [width floatValue];
                    
                    // When we don't have any width left to substract, we have the segment index.
                    if (widthLeft <= 0)
                        break;
                    
                    segment++;
                }
            }
        }
        
        NSUInteger sectionsCount = 0;
        
        if (self.type == HMSegmentedControlTypeImages) {
            sectionsCount = [self.sectionImages count];
        } else if (self.type == HMSegmentedControlTypeTextImages || self.type == HMSegmentedControlTypeText) {
            sectionsCount = [self.sectionTitles count];
        }
        
//        if (segment != self.selectedSegmentIndex && segment < sectionsCount) {
        if (segment < sectionsCount) {
            // Check if we have to do anything with the touch event
            if (self.isTouchEnabled) {
                _doesScrolledByUserPanGesture = NO;
                [self setSelectedSegmentIndex:segment animated:self.shouldAnimateUserSelection notify:YES];
            }
        }
    }
}

#pragma mark - Scrolling

- (CGFloat)totalSegmentedControlWidth {
    if (self.type == HMSegmentedControlTypeText && self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed) {
        return self.sectionTitles.count * self.segmentWidth;
    } else if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
        return [[self.segmentWidthsArray valueForKeyPath:@"@sum.self"] floatValue];
    } else {
        return self.sectionImages.count * self.segmentWidth;
    }
}

- (void)scrollToSelectedSegmentIndex:(BOOL)animated {
    if ([self sectionCount] != self.segmentWidthsArray.count) {
        [self updateSegmentsRects];
    }
    CGRect rectForSelectedIndex = CGRectZero;
    CGFloat selectedSegmentOffset = 0;
    if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed) {
        rectForSelectedIndex = CGRectMake(self.segmentWidth * self.selectedSegmentIndex,
                                          0,
                                          self.segmentWidth,
                                          self.frame.size.height);
        
        selectedSegmentOffset = (CGRectGetWidth(self.frame) / 2) - (self.segmentWidth / 2);
    } else {
        NSInteger i = 0;
        CGFloat offsetter = 0;
        for (NSNumber *width in self.segmentWidthsArray) {
            if (self.selectedSegmentIndex == i)
                break;
            offsetter = offsetter + [width floatValue];
            i++;
        }
        
        rectForSelectedIndex = CGRectMake(offsetter,
                                          0,
                                          [[self.segmentWidthsArray objectAtIndex:self.selectedSegmentIndex] floatValue],
                                          self.frame.size.height);
        
        selectedSegmentOffset = (CGRectGetWidth(self.frame) / 2) - ([[self.segmentWidthsArray objectAtIndex:self.selectedSegmentIndex] floatValue] / 2);
    }
    
    
    CGRect rectToScrollTo = rectForSelectedIndex;
    rectToScrollTo.origin.x -= selectedSegmentOffset;
    rectToScrollTo.size.width += selectedSegmentOffset * 2;
    [self.scrollView scrollRectToVisible:rectToScrollTo animated:animated];
}

#pragma mark - Index Change

- (void)setSelectedSegmentIndex:(NSInteger)index {
    [self setSelectedSegmentIndex:index animated:NO notify:NO];
}

- (void)setSelectedSegmentIndex:(NSUInteger)index animated:(BOOL)animated {
    [self setSelectedSegmentIndex:index animated:animated notify:NO];
}

- (void)setSelectedSegmentIndex:(NSUInteger)index animated:(BOOL)animated notify:(BOOL)notify {
    _selectedSegmentIndex = index;
    [self setNeedsDisplay];
    if ([self sectionCount] == 0) {
        return;
    }
    
    // In init, force update mask image
    [self segmentDidScroll:self.scrollView];
    
    if (index == HMSegmentedControlNoSegment) {
        [self.selectionIndicatorArrowLayer removeFromSuperlayer];
        [self.selectionIndicatorStripLayer removeFromSuperlayer];
        [self.selectionIndicatorBoxLayer removeFromSuperlayer];
    } else {
        [self scrollToSelectedSegmentIndex:animated];
        
        if (animated) {
            // If the selected segment layer is not added to the super layer, that means no
            // index is currently selected, so add the layer then move it to the new
            // segment index without animating.
            if(self.selectionStyle == HMSegmentedControlSelectionStyleArrow) {
                if ([self.selectionIndicatorArrowLayer superlayer] == nil) {
                    [self.scrollView.layer addSublayer:self.selectionIndicatorArrowLayer];
                    
                    [self setSelectedSegmentIndex:index animated:NO notify:YES];
                    return;
                }
            }else {
                if ([self.selectionIndicatorStripLayer superlayer] == nil) {
                    [self.scrollView.layer addSublayer:self.selectionIndicatorStripLayer];
                    
                    if (self.selectionStyle == HMSegmentedControlSelectionStyleBox && [self.selectionIndicatorBoxLayer superlayer] == nil)
                        [self.scrollView.layer insertSublayer:self.selectionIndicatorBoxLayer atIndex:0];
                    
                    [self setSelectedSegmentIndex:index animated:NO notify:YES];
                    return;
                }
            }
            
            if (notify)
                [self notifyForSegmentChangeToIndex:index];
            
            // Restore CALayer animations
            self.selectionIndicatorArrowLayer.actions = nil;
            self.selectionIndicatorStripLayer.actions = nil;
            self.selectionIndicatorBoxLayer.actions = nil;
            
            // Animate to new position
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.15f];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [self setArrowFrame];
            self.selectionIndicatorBoxLayer.frame = [self frameForSelectionIndicator];
            self.selectionIndicatorStripLayer.frame = [self frameForSelectionIndicator];
            self.selectionIndicatorBoxLayer.frame = [self frameForFillerSelectionIndicator];
            [CATransaction commit];
        } else {
            // Disable CALayer animations
            NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"position", [NSNull null], @"bounds", nil];
            self.selectionIndicatorArrowLayer.actions = newActions;
            [self setArrowFrame];
            
            self.selectionIndicatorStripLayer.actions = newActions;
            self.selectionIndicatorStripLayer.frame = [self frameForSelectionIndicator];
            
            self.selectionIndicatorBoxLayer.actions = newActions;
            self.selectionIndicatorBoxLayer.frame = [self frameForFillerSelectionIndicator];
            
            if (notify)
                [self notifyForSegmentChangeToIndex:index];
        }
    }
}

- (void)notifyForSegmentChangeToIndex:(NSInteger)index {
    if (self.superview)
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    if (self.indexChangeBlock)
        self.indexChangeBlock(index);
}

#pragma mark - Styling Support

- (NSDictionary *)resultingTitleTextAttributes {
    NSDictionary *defaults = @{
                               NSFontAttributeName : [UIFont systemFontOfSize:19.0f],
                               NSForegroundColorAttributeName : [UIColor blackColor],
                               };
    
    NSMutableDictionary *resultingAttrs = [NSMutableDictionary dictionaryWithDictionary:defaults];
    
    if (self.titleTextAttributes) {
        [resultingAttrs addEntriesFromDictionary:self.titleTextAttributes];
    }
    
    return [resultingAttrs copy];
}

- (NSDictionary *)resultingSelectedTitleTextAttributes {
    NSMutableDictionary *resultingAttrs = [NSMutableDictionary dictionaryWithDictionary:[self resultingTitleTextAttributes]];
    
    if (self.selectedTitleTextAttributes) {
        [resultingAttrs addEntriesFromDictionary:self.selectedTitleTextAttributes];
    }
    
    return [resultingAttrs copy];
}

#pragma mark - Getter & Setter

- (void)setRelatedScrollView:(UIScrollView *)relatedScrollView {
    [_relatedScrollView.panGestureRecognizer removeTarget:self action:@selector(scrollViewPanGestureRecognizerAction:)];
    _relatedScrollView = relatedScrollView;
    [_relatedScrollView.panGestureRecognizer addTarget:self action:@selector(scrollViewPanGestureRecognizerAction:)];
}

- (void)setTitleTextAttributes:(NSDictionary *)titleTextAttributes {
    _titleTextAttributes = titleTextAttributes;
    UIColor *color = _titleTextAttributes[NSForegroundColorAttributeName];
    [color getRed:&_normalRed green:&_normalGreen blue:&_normalBlue alpha:&_noramlAlpha];
}

- (void)setSelectedTitleTextAttributes:(NSDictionary *)selectedTitleTextAttributes {
    _selectedTitleTextAttributes = selectedTitleTextAttributes;
    UIColor *color = _selectedTitleTextAttributes[NSForegroundColorAttributeName];
    [color getRed:&_selectedRed green:&_selectedGreen blue:&_selectedBlue alpha:&_selectedAlpha];
}

- (NSDictionary *)selectedTitleTextAttributes {
    if ([self sectionCount] == 1 && !_enableSelectEffectForSingleSegment) {
        return _titleTextAttributes;
    } else {
        return _selectedTitleTextAttributes;
    }
}

- (UIImageView *)leftMaskImageView {
    if (!_leftMaskImageView) {
        _leftMaskImageView = [[UIImageView alloc] initWithImage:self.leftMaskImage];
        [self updateLeftMaskImageFrame];
        [self addSubview:_leftMaskImageView];
        _leftMaskImageView.hidden = YES;
    }
    return _leftMaskImageView;
}

- (void)updateLeftMaskImageFrame {
    _leftMaskImageView.frame = CGRectMake(0,
                                          (self.frame.size.height - _leftMaskImageView.image.size.height) / 2,
                                          _leftMaskImageView.image.size.width,
                                          _leftMaskImageView.image.size.height);
}

- (UIImageView *)rightMaskImageView {
    if (!_rightMaskImageView) {
        _rightMaskImageView = [[UIImageView alloc] initWithImage:self.rightMaskImage];
        [self updateRightMaskImageFrame];
        [self addSubview:_rightMaskImageView];
        _rightMaskImageView.hidden = YES;
    }
    return _rightMaskImageView;
}

- (void)updateRightMaskImageFrame {
    _rightMaskImageView.frame = CGRectMake(self.frame.size.width - _rightMaskImageView.image.size.width,
                                           (self.frame.size.height - _rightMaskImageView.image.size.height) / 2,
                                           _rightMaskImageView.image.size.width,
                                           _rightMaskImageView.image.size.height);
}

#pragma mark - GestureRecognizer Action

- (void)scrollViewPanGestureRecognizerAction:(UIPanGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            _doesScrolledByUserPanGesture = YES;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            // Do nothing
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            // Do nothing
            break;
        }
        default: {
            // Do nothing
            break;
        }
    }
}

- (void)tapGestureRecognizerAction:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint touchLocation = [gestureRecognizer locationInView:self];
    
    CGRect enlargeRect =   CGRectMake(self.bounds.origin.x - self.enlargeEdgeInset.left,
                                      self.bounds.origin.y - self.enlargeEdgeInset.top,
                                      self.bounds.size.width + self.enlargeEdgeInset.left + self.enlargeEdgeInset.right,
                                      self.bounds.size.height + self.enlargeEdgeInset.top + self.enlargeEdgeInset.bottom);
    
    if (CGRectContainsPoint(enlargeRect, touchLocation)) {
        NSInteger segment = 0;
        if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleFixed) {
            segment = (touchLocation.x + self.scrollView.contentOffset.x) / self.segmentWidth;
        } else if (self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
            // To know which segment the user touched, we need to loop over the widths and substract it from the x position.
            CGFloat widthLeft = (touchLocation.x + self.scrollView.contentOffset.x);
            
            CGFloat totalWidth = [self totalSegmentedControlWidth];
            if (self.type == HMSegmentedControlTypeText && self.makeHorizonSpaceEqualEqualityIfPossible && totalWidth < self.frame.size.width) {
                CGFloat horizonSpace = (self.frame.size.width - totalWidth) / ([self sectionCount] + 1);
                segment = -1;
                for (NSInteger index = 0; index < self.segmentWidthsArray.count; ++index) {
                    CGFloat selectedSegmentOffset = (index + 1) * horizonSpace;
                    for (NSInteger innerIndex = index - 1; innerIndex >= 0; --innerIndex) {
                        selectedSegmentOffset += [self.segmentWidthsArray[innerIndex] floatValue];
                    }
                    if (widthLeft >= selectedSegmentOffset && widthLeft <= (selectedSegmentOffset + [self.segmentWidthsArray[index] floatValue])) {
                        segment = index;
                        break;
                    } else if (widthLeft < selectedSegmentOffset) {
                        break;
                    }
                }
            } else if (self.type == HMSegmentedControlTypeText && _centerWhenNecessary && totalWidth < self.frame.size.width) {
                CGFloat totalLeftMargin = (self.frame.size.width - totalWidth) / 2;
                CGFloat segmentOffset = totalLeftMargin;
                
                if (widthLeft < segmentOffset) { // The point's X is in the left of the most left segment after centerlized
                    return;
                }
                
                if (widthLeft > segmentOffset + totalWidth) { // The point's X is in the right of the most right segment after centerlized
                    return;
                }
                
                segment = -1;
                for (NSNumber *segmentWidth in self.segmentWidthsArray) {
                    segmentOffset += [segmentWidth floatValue];
                    ++segment;
                    if (widthLeft < segmentOffset) {
                        break;
                    }
                }
            } else {
                for (NSNumber *width in self.segmentWidthsArray) {
                    widthLeft = widthLeft - [width floatValue];
                    
                    // When we don't have any width left to substract, we have the segment index.
                    if (widthLeft <= 0)
                        break;
                    
                    segment++;
                }
            }
        }
        
        NSUInteger sectionsCount = 0;
        
        if (self.type == HMSegmentedControlTypeImages) {
            sectionsCount = [self.sectionImages count];
        } else if (self.type == HMSegmentedControlTypeTextImages || self.type == HMSegmentedControlTypeText) {
            sectionsCount = [self.sectionTitles count];
        }
        
        if (self.doubleClickIndexBlock) {
            self.doubleClickIndexBlock(segment);
        }
    }
}

#pragma mark - The related UIScrollView did scroll

- (void)segmentDidScroll:(UIScrollView *)scrollView {
    if (self.type == HMSegmentedControlTypeText && self.segmentWidthStyle == HMSegmentedControlSegmentWidthStyleDynamic) {
        self.leftMaskImageView.hidden = scrollView.contentOffset.x < self.segmentEdgeInset.left;
        self.rightMaskImageView.hidden = scrollView.frame.size.width + scrollView.contentOffset.x + self.segmentEdgeInset.right > [self totalSegmentedControlWidth];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)relatedScrollView {
    if (self.scrollView == relatedScrollView) {
        [self segmentDidScroll:relatedScrollView];
        return;
    }
    if (self.relatedScrollView != relatedScrollView) {
        return;
    }
    CGFloat contentOffsetX;
    if ([relatedScrollView class] == [UIScrollView class]) {
        contentOffsetX = relatedScrollView.contentOffset.x;
    } else {
        contentOffsetX = _screenSize.width * (self.selectedSegmentIndex - 1) + relatedScrollView.contentOffset.x;
    }
    [self relatedScrollViewDidScrollWithContentOffsetX:contentOffsetX];
}

- (void)relatedScrollViewDidScrollWithContentOffsetX:(CGFloat)contentOffsetX {
    if (!self.shouldAnimateDuringUserScrollTheRelatedScrollView || !_doesScrolledByUserPanGesture) {
        return;
    }
    
    CGSize screenSize = _screenSize;
    
    // 实现本页标题颜色渐淡效果，下页渐现效果
    NSInteger curPageIndex = self.selectedSegmentIndex;
    
    // 判断是向右还是向左
    NSInteger destPageIndex = contentOffsetX > (screenSize.width * curPageIndex) ? curPageIndex + 1 : curPageIndex - 1;
    if (destPageIndex < 0 || destPageIndex >= [self sectionCount]) {
        return;
    }
    
    CGRect currentPageRect = [self frameForSelectionIndicatorWithSelectedSegmentIndex:curPageIndex];
    CGRect destinationPageRect = [self frameForSelectionIndicatorWithSelectedSegmentIndex:destPageIndex];
    CGFloat percentToDestination = (contentOffsetX - (screenSize.width * curPageIndex)) / screenSize.width;
    CGFloat nowRectX = percentToDestination * fabs(destinationPageRect.origin.x - currentPageRect.origin.x) + currentPageRect.origin.x;
    CGFloat nowRectSizeWidth = fabs(percentToDestination) * (destinationPageRect.size.width - currentPageRect.size.width) + currentPageRect.size.width;
    
    if (self.selectionStyle == HMSegmentedControlSelectionStyleArrow) {
        [self setArrowFrameWithFrame:CGRectMake(nowRectX, destinationPageRect.origin.y, nowRectSizeWidth, destinationPageRect.size.height)];
    } else {
        self.selectionIndicatorStripLayer.frame = CGRectMake(nowRectX, destinationPageRect.origin.y, nowRectSizeWidth, destinationPageRect.size.height);
        if (self.selectionStyle == HMSegmentedControlSelectionStyleBox) {
            currentPageRect = [self frameForFillerSelectionIndicatorWithSelectedSegmentIndex:curPageIndex];
            destinationPageRect = [self frameForFillerSelectionIndicatorWithSelectedSegmentIndex:destPageIndex];
            percentToDestination = (contentOffsetX - (screenSize.width * curPageIndex)) / screenSize.width;
            nowRectX = percentToDestination * fabs(destinationPageRect.origin.x - currentPageRect.origin.x) + currentPageRect.origin.x;
            nowRectSizeWidth = fabs(percentToDestination) * (destinationPageRect.size.width - currentPageRect.size.width) + currentPageRect.size.width;
            
            self.selectionIndicatorBoxLayer.frame = CGRectMake(nowRectX, destinationPageRect.origin.y, nowRectSizeWidth, destinationPageRect.size.height);
        }
    }
    
    if (self.type == HMSegmentedControlTypeText || self.type == HMSegmentedControlTypeTextImages) {
        // current title: selected color -> normal color
        CGFloat depth = fabs(percentToDestination);
        CGFloat r = (_selectedRed + (_normalRed - _selectedRed) * depth);
        CGFloat g = (_selectedGreen + (_normalGreen - _selectedGreen) * depth);
        CGFloat b = (_selectedBlue + (_normalBlue - _selectedBlue) * depth);
        CGFloat a = (_selectedAlpha + (_noramlAlpha - _selectedAlpha) * depth);
        NSString *currentTitle = self.sectionTitles[curPageIndex];
        CATextLayer *currentTextLayer = _titleLayerDictionary[currentTitle];
        
        UIFont *font = self.selectedTitleTextAttributes[NSFontAttributeName] ? self.selectedTitleTextAttributes[NSFontAttributeName] : [UIFont systemFontOfSize:19.0f];
        NSDictionary *titleAttrs = @{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName : [UIColor colorWithRed:r green:g blue:b alpha:a]
                                     };
        currentTextLayer.string = [[NSAttributedString alloc] initWithString:currentTitle attributes:titleAttrs];
        
        // destination title: normal color -> selected color
        r = (_normalRed + (_selectedRed - _normalRed) * depth);
        g = (_normalGreen + (_selectedGreen - _normalGreen) * depth);
        b = (_normalBlue + (_selectedBlue - _normalBlue) * depth);
        a = (_noramlAlpha + (_selectedAlpha - _noramlAlpha) * depth);
        NSString *destinationTitle = self.sectionTitles[destPageIndex];
        CATextLayer *destinationTextLayer = _titleLayerDictionary[destinationTitle];
        font = self.titleTextAttributes[NSFontAttributeName] ? self.titleTextAttributes[NSFontAttributeName] : [UIFont systemFontOfSize:19.0f];
        titleAttrs = @{
                       NSFontAttributeName : font,
                       NSForegroundColorAttributeName : [UIColor colorWithRed:r green:g blue:b alpha:a]
                       };
        destinationTextLayer.string = [[NSAttributedString alloc] initWithString:destinationTitle attributes:titleAttrs];
    }
}

@end
