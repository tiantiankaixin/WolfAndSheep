//
//  UIView+Extension.m
//  CustomLib
//
//  Created by freeblow on 13-10-23.
//  Copyright (c) 2013年 freeblow. All rights reserved.
//

#import "UIView+Extension.h"

#import <QuartzCore/QuartzCore.h>

@interface UIView (Private)
-(void) resetAndRemoveFromSuperView;
@end

@implementation UIView (Extension)
-(void) removeAllSubviews {
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

-(void) removeAllSubviewsExceptSubview:(UIView*)subview {
    
    for (UIView* view in [self subviews]) {
        if (view!=subview) {
            [view removeFromSuperview];
        }
    }
}

-(void)clearAllSubviewWith:(UIColor*)color{
    NSArray *subviews = [self subviews];
    if ([subviews count] == 0) {
        return;
    }else{
        for (UIView *aView in subviews) {
            [aView setBackgroundColor:color];
            [self clearAllSubviewWith:color];
        }
    }
}


- (UIView*)descendantOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls])
        return self;
    
    for (UIView* child in self.subviews) {
        UIView* it = [child descendantOrSelfWithClass:cls];
        if (it)
            return it;
    }
    
    return nil;
}

+ (void)flipFromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration
{
    [UIView flipFromView:fromView toView:toView withType:UIViewFlipAnimationTypeFlipFromLeft duration:duration];
}

+ (void)flipFromView:(UIView *)fromView toView:(UIView *)toView withType:(UIViewFlipAnimationType)animationType duration:(NSTimeInterval)duration
{
    
    CABasicAnimation *moveFront;
    moveFront=[CABasicAnimation animationWithKeyPath:@"shadowOffset"];
    moveFront.delegate = self;
    moveFront.duration = duration/2;
    moveFront.repeatCount = 0;
    moveFront.removedOnCompletion = FALSE;
    moveFront.fillMode = kCAFillModeForwards;
    moveFront.autoreverses = NO;
    moveFront.fromValue = [NSValue valueWithCGSize:CGSizeMake(3,3)];
    moveFront.toValue = [NSValue valueWithCGSize:CGSizeMake(50,50)];
    moveFront.beginTime = 0.0;
    
    CABasicAnimation *rotateFirstHalf;
    rotateFirstHalf=[CABasicAnimation animationWithKeyPath:@"transform"];
    rotateFirstHalf.delegate = self;
    rotateFirstHalf.duration = duration/2;
    rotateFirstHalf.repeatCount = 0;
    rotateFirstHalf.removedOnCompletion = FALSE;
    rotateFirstHalf.fillMode = kCAFillModeForwards;
    rotateFirstHalf.autoreverses = NO;
    rotateFirstHalf.beginTime = 0.0;
    
    if (animationType==UIViewFlipAnimationTypeFlipFromRight) {
        rotateFirstHalf.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(1.0f * M_PI/2, 0, 1, 0)];
        
    } else {
        rotateFirstHalf.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-1.0f * M_PI/2, 0, 1, 0)];
    }
    
    CABasicAnimation *moveBack;
    moveBack=[CABasicAnimation animationWithKeyPath:@"shadowOffset"];
    moveBack.delegate = self;
    moveBack.duration = duration/2;
    moveBack.repeatCount = 0;
    moveBack.removedOnCompletion = FALSE;
    moveBack.fillMode = kCAFillModeForwards;
    moveBack.autoreverses = NO;
    moveBack.fromValue = [NSValue valueWithCGSize:CGSizeMake(50,50)];
    moveBack.toValue = [NSValue valueWithCGSize:CGSizeMake(3,3)];
    moveBack.beginTime = duration/2;
    
    CABasicAnimation *rotateSecondHalf;
    rotateSecondHalf=[CABasicAnimation animationWithKeyPath:@"transform"];
    rotateSecondHalf.delegate = self;
    rotateSecondHalf.duration = duration/2;
    rotateSecondHalf.repeatCount = 0;
    rotateSecondHalf.removedOnCompletion = FALSE;
    rotateSecondHalf.fillMode = kCAFillModeForwards;
    rotateSecondHalf.autoreverses = NO;
    rotateSecondHalf.beginTime = duration/2;
    
    if (animationType==UIViewFlipAnimationTypeFlipFromLeft) {
        rotateSecondHalf.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-1.0f * M_PI/2, 0, 1, 0)];
        rotateSecondHalf.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, M_PI, 1, 0)];
        
    } else {
        rotateSecondHalf.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(1.0f * M_PI/2, 0, 1, 0)];
        rotateSecondHalf.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, M_PI, 1, 0)];
    }
    
    CAAnimationGroup *firstGroup = [CAAnimationGroup animation];
    [firstGroup setAnimations:@[moveFront,rotateFirstHalf]];
    [firstGroup setDuration:duration];
    [firstGroup setRemovedOnCompletion:NO];
    [firstGroup setFillMode:kCAFillModeForwards];
    
    CAAnimationGroup *secondGroup = [CAAnimationGroup animation];
    [secondGroup setAnimations:@[moveBack,rotateSecondHalf]];
    [secondGroup setDuration:duration];
    [secondGroup setRemovedOnCompletion:NO];
    [secondGroup setFillMode:kCAFillModeForwards];
    
    toView.frame=fromView.frame;
    toView.layer.transform = CATransform3DMakeRotation(-M_PI/2,0,1,0);
    toView.layer.shadowOffset = CGSizeMake(50,50);
    [[fromView superview] addSubview:toView];
    
    [fromView.layer addAnimation:firstGroup forKey:@"flip_animation"];
    [toView.layer addAnimation:secondGroup forKey:@"flip_animation"];
    
    //Schedule a callback to reset and remove superview after animation finishes
    NSMethodSignature * mySignature = [UIView instanceMethodSignatureForSelector:@selector(resetAndRemoveFromSuperView)];
    NSInvocation * myInvocation = [NSInvocation invocationWithMethodSignature:mySignature];
    [myInvocation setTarget:fromView];
    [myInvocation setSelector:@selector(resetAndRemoveFromSuperView)];
    NSTimer *timer = [NSTimer timerWithTimeInterval:duration invocation:myInvocation repeats:NO];
    if (timer) {
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
}

#pragma mark -
#pragma mark FrameHelpers

- (CGFloat)left {
    return self.frame.origin.x;
}


- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}


- (CGFloat)top {
    return self.frame.origin.y;
}


- (void)setTop:(CGFloat)y {
    
    if (y!=self.top) {
        CGRect frame = self.frame;
        frame.origin.y = y;
        self.frame = frame;
    }
}


- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}


- (void)setRight:(CGFloat)right {
    
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}


- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}


- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}


- (CGFloat)width {
    return self.frame.size.width;
}


- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}


- (CGFloat)height {
    return self.frame.size.height;
}


- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)boundWidth {
    return self.bounds.size.width;
}

- (void)setBoundWidth:(CGFloat)width {
    CGRect bounds = self.bounds;
    bounds.size.width = width;
    self.bounds = bounds;
}

- (CGFloat)boundHeight {
    return self.bounds.size.height;
}

- (void)setBoundHeight:(CGFloat)height {
    CGRect bounds = self.frame;
    bounds.size.height = height;
    self.bounds = bounds;
}

- (CGPoint)origin {
    return self.frame.origin;
}


- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}


#pragma mark -
#pragma mark Private

-(void) resetAndRemoveFromSuperView
{
    self.layer.shadowOffset = CGSizeMake(3,3);
    self.layer.transform = CATransform3DMakeRotation(0,0,1,0);
    [self removeFromSuperview];
}

@end




#pragma mark - AutoLayout

#define nameOfVar(x) [NSString stringWithFormat:@"%s", #x]

static inline CGRect CGRectRound(CGRect rect) {return CGRectMake((NSInteger)rect.origin.x, (NSInteger)rect.origin.y, (NSInteger)rect.size.width, (NSInteger)rect.size.height); }
static NSString * const UIVIEW_HELPERS_FRAME_KVO_KEY = @"frame";

@implementation UIView (AutoLayout)

#pragma mark -
#pragma mark Init

- (id)initWithSize:(CGSize)size
{
    self = [self init];
    if (self)
    {
        [self setFrameSize:size];
    }
    return self;
}

+ (CGRect)alignRect:(CGRect)startingRect toRect:(CGRect)referenceRect withAlignment:(UIViewAlignment)alignment insets:(UIEdgeInsets)insets andReferenceIsSuperView:(BOOL)isReferenceSuperView
{
    CGRect newRect = startingRect;
    
    // X alignments
    if (alignment & UIViewAlignmentLeft)
    {
        newRect.origin.x += CGRectGetMinX(referenceRect) - (CGRectGetWidth(startingRect) + insets.right);
    }
    else if (alignment & UIViewAlignmentRight)
    {
        newRect.origin.x = CGRectGetMaxX(referenceRect) + insets.left;
    }
    else if (alignment & UIViewAlignmentLeftEdge)
    {
        if (isReferenceSuperView)
        {
            newRect.origin.x = insets.left;
        }
        else
        {
            newRect.origin.x = referenceRect.origin.x + insets.left;
        }
    }
    else if (alignment & UIViewAlignmentRightEdge)
    {
        if (isReferenceSuperView)
        {
            newRect.origin.x = CGRectGetWidth(referenceRect) - (CGRectGetWidth(startingRect) + insets.right);
        }
        else
        {
            newRect.origin.x = CGRectGetMaxX(referenceRect) - (CGRectGetWidth(startingRect) + insets.right);
        }
    }
    else if (alignment & UIViewAlignmentHorizontalCenter)
    {
        if (isReferenceSuperView)
        {
            newRect.origin.x = (((CGRectGetWidth(referenceRect) - CGRectGetWidth(startingRect))) / 2.0f);
        }
        else
        {
            newRect.origin.x = CGRectGetMinX(referenceRect) +
            (((CGRectGetWidth(referenceRect) - CGRectGetWidth(startingRect))) / 2.0f);
        }
    }
    
    // Y alignments
    if (alignment & UIViewAlignmentTop)
    {
        newRect.origin.y = CGRectGetMinY(referenceRect) - (CGRectGetHeight(startingRect) + insets.bottom);
    }
    else if (alignment & UIViewAlignmentBottom)
    {
        newRect.origin.y = CGRectGetMaxY(referenceRect) + insets.top;
    }
    else if (alignment & UIViewAlignmentBottomEdge)
    {
        if (isReferenceSuperView)
        {
            newRect.origin.y = CGRectGetHeight(referenceRect) - (CGRectGetHeight(startingRect) + insets.bottom);
        }
        else
        {
            newRect.origin.y = CGRectGetMaxY(referenceRect) - (CGRectGetHeight(startingRect) + insets.bottom);
        }
    }
    else if (alignment & UIViewAlignmentTopEdge)
    {
        if (isReferenceSuperView)
        {
            newRect.origin.y = insets.top;
        }
        else
        {
            newRect.origin.y = CGRectGetMinY(referenceRect) + insets.top;
        }
    }
    else if (alignment & UIViewAlignmentVerticalCenter)
    {
        if (isReferenceSuperView)
        {
            newRect.origin.y = ((CGRectGetHeight(referenceRect) - CGRectGetHeight(startingRect)) / 2.0f) + insets.top - insets.bottom;
        }
        else
        {
            newRect.origin.y = CGRectGetMinY(referenceRect) +
            ((CGRectGetHeight(referenceRect) - CGRectGetHeight(startingRect)) / 2.0f) + insets.top - insets.bottom;
        }
    }
    
    return CGRectIntegral(newRect);
}

- (void)alignRelativeToView:(UIView*)alignView withAlignment:(UIViewAlignment)alignment andInsets:(UIEdgeInsets)insets
{
    [self setFrame:[UIView alignRect:[self frame]
                              toRect:[alignView frame]
                       withAlignment:alignment
                              insets:insets
             andReferenceIsSuperView:NO]];
}

- (void)alignRelativeToSuperView:(UIView*)alignView withAlignment:(UIViewAlignment)alignment andInsets:(UIEdgeInsets)insets
{
    [self setFrame:[UIView alignRect:[self frame]
                              toRect:[alignView frame]
                       withAlignment:alignment
                              insets:insets
             andReferenceIsSuperView:YES]];
}


#pragma mark -
#pragma mark Alignment

- (void)centerAlignHorizontalForView:(UIView *)view
{
    [self centerAlignHorizontalForView:view offset:0];
}

- (void)centerAlignVerticalForView:(UIView *)view
{
    [self centerAlignVerticalForView:view offset:0];
}

- (void)centerAlignHorizontalForSuperView
{
    [self centerAlignHorizontalForView:[self superview]];
}

- (void)centerAlignVerticalForSuperView
{
    [self centerAlignVerticalForView:[self superview]];
}

- (void)centerAlignHorizontalForSuperView:(CGFloat)offset
{
    [self centerAlignHorizontalForView:[self superview] offset:offset];
}

- (void)centerAlignVerticalForSuperView:(CGFloat)offset
{
    [self centerAlignVerticalForView:[self superview] offset:offset];
}

- (void)centerAlignHorizontalForView:(UIView *)view offset:(CGFloat)offset
{
    [self setFrame:CGRectRound(CGRectMake((CGRectGetWidth([view frame]) / 2.0f) - (CGRectGetWidth([self frame]) / 2.0f) + offset, CGRectGetMinY([self frame]), CGRectGetWidth([self frame]), CGRectGetHeight([self frame])))];
}

- (void)centerAlignVerticalForView:(UIView *)view offset:(CGFloat)offset
{
    [self setFrame:CGRectRound(CGRectMake(CGRectGetMinX([self frame]), (CGRectGetHeight([view frame]) / 2.0f) - (CGRectGetHeight([self frame]) / 2.0f) + offset, CGRectGetWidth([self frame]), CGRectGetHeight([self frame])))];
}

- (void)leftAlignForView:(UIView *)view
{
    [self leftAlignForView:view offset:0];
}

- (void)rightAlignForView:(UIView *)view
{
    [self rightAlignForSuperViewOffset:0];
}

- (void)topAlignForView:(UIView *)view
{
    [self topAlignForView:view offset:0];
}

- (void)bottomAlignForView:(UIView *)view
{
    [self bottomAlignForView:view offset:0];
}

- (void)leftAlignForView:(UIView *)view offset:(CGFloat)offset
{
    [self setFrame:CGRectRound(CGRectMake(CGRectGetMinX([view frame]) + offset, CGRectGetMinY([self frame]), CGRectGetWidth([self frame]), CGRectGetHeight([self frame])))];
}

- (void)rightAlignForView:(UIView *)view offset:(CGFloat)offset
{
    [self setFrame:CGRectRound(CGRectMake(CGRectGetMaxX([view frame]) - CGRectGetWidth([self frame]) - offset, CGRectGetMinY([self frame]), CGRectGetWidth([self frame]), CGRectGetHeight([self frame])))];
}

- (void)topAlignForView:(UIView *)view offset:(CGFloat)offset
{
    [self setFrame:CGRectRound(CGRectMake(CGRectGetMinX([self frame]), [view frame].origin.y + offset, CGRectGetWidth([self frame]), CGRectGetHeight([self frame])))];
}

- (void)bottomAlignForView:(UIView *)view offset:(CGFloat)offset
{
    [self setFrame:CGRectRound(CGRectMake(CGRectGetMinX([self frame]), CGRectGetMaxY([view frame]) - CGRectGetHeight([self frame]) - offset, CGRectGetWidth([self frame]), CGRectGetHeight([self frame])))];
}

- (void)topAlignForSuperViewOffset:(CGFloat)offset
{
    [self setFrameOriginY:offset];
}

- (void)bottomAlignForSuperViewOffset:(CGFloat)offset
{
    [self setFrameOriginY:[[self superview] frameSizeHeight] - [self frameSizeHeight] - offset];
}

- (void)leftAlignForSuperViewOffset:(CGFloat)offset
{
    [self setFrameOriginX:offset];
}

- (void)rightAlignForSuperViewOffset:(CGFloat)offset
{
    [self setFrameOriginX:[[self superview] frameSizeWidth] - [self frameSizeWidth] - offset];
}

- (void)topAlignForSuperView
{
    [self topAlignForSuperViewOffset:0];
}

- (void)bottomAlignForSuperView
{
    [self bottomAlignForSuperViewOffset:0];
}

- (void)leftAlignForSuperView
{
    [self leftAlignForSuperViewOffset:0];
}

- (void)rightAlignForSuperView
{
    [self rightAlignForSuperViewOffset:0];
}

- (void)centerAlignForView:(UIView *)view
{
    [self centerAlignHorizontalForView:view];
    [self centerAlignVerticalForView:view];
}

- (void)centerAlignForSuperview
{
    [self centerAlignForView:[self superview]];
}

#pragma mark -
#pragma mark Convenience Getters

- (CGPoint)frameOrigin
{
    return [self frame].origin;
}

- (CGSize)frameSize
{
    return [self frame].size;
}

- (CGFloat)frameOriginX
{
    return [self frame].origin.x;
}

- (CGFloat)frameOriginY
{
    return [self frame].origin.y;
}

- (CGFloat)frameSizeWidth
{
    return [self frame].size.width;
}

- (CGFloat)frameSizeHeight
{
    return [self frame].size.height;
}

#pragma mark -
#pragma mark Frame Adjustments

- (void)setFrameOrigin:(CGPoint)origin
{
    [self setFrameOriginY:origin.y];
    [self setFrameOriginX:origin.x];
}

- (void)setFrameSize:(CGSize)size
{
    [self setFrame:CGRectMake(CGRectGetMinX([self frame]), CGRectGetMinY([self frame]), size.width, size.height)];
}

- (void)setFrameOriginY:(CGFloat)y
{
    [self setFrame:CGRectRound(CGRectMake(CGRectGetMinX([self frame]), y, CGRectGetWidth([self frame]), CGRectGetHeight([self frame])))];
}

- (void)setFrameOriginX:(CGFloat)x
{
    [self setFrame:CGRectRound(CGRectMake(x, CGRectGetMinY([self frame]), CGRectGetWidth([self frame]), CGRectGetHeight([self frame])))];
}

- (void)setFrameSizeWidth:(CGFloat)width
{
    [self setFrame:CGRectRound(CGRectMake(CGRectGetMinX([self frame]), CGRectGetMinY([self frame]), width, CGRectGetHeight([self frame])))];
}

- (void)setFrameSizeHeight:(CGFloat)height
{
    [self setFrame:CGRectRound(CGRectMake(CGRectGetMinX([self frame]), CGRectGetMinY([self frame]), CGRectGetWidth([self frame]), height))];
}

#pragma mark -
#pragma mark Positioning Relative to View

- (void)setFrameOriginYBelowView:(UIView *)view
{
    [self setFrameOriginYBelowView:view offset:0];
}

- (void)setFrameOriginYAboveView:(UIView *)view
{
    [self setFrameOriginYAboveView:view offset:0];
}

- (void)setFrameOriginXRightOfView:(UIView *)view
{
    [self setFrameOriginXRightOfView:view offset:0];
}

- (void)setFrameOriginXLeftOfView:(UIView *)view
{
    [self setFrameOriginXLeftOfView:view offset:0];
}

- (void)setFrameOriginYBelowView:(UIView *)view offset:(CGFloat)offset
{
    CGRect frame = [self frame];
    CGRect viewFrame = [view frame];
    
    [self setFrame:CGRectRound(CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(viewFrame) + offset, CGRectGetWidth(frame), CGRectGetHeight(frame)))];
}

- (void)setFrameOriginYAboveView:(UIView *)view offset:(CGFloat)offset
{
    CGRect frame = [self frame];
    CGRect viewFrame = [view frame];
    
    [self setFrame:CGRectRound(CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(viewFrame) - CGRectGetHeight([self frame]) - offset, CGRectGetWidth(frame), CGRectGetHeight(frame)))];
}

- (void)setFrameOriginXRightOfView:(UIView *)view offset:(CGFloat)offset
{
    CGRect frame = [self frame];
    CGRect viewFrame = [view frame];
    
    [self setFrame:CGRectRound(CGRectMake(CGRectGetMaxX(viewFrame) + offset, CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame)))];
}

- (void)setFrameOriginXLeftOfView:(UIView *)view offset:(CGFloat)offset
{
    CGRect frame = [self frame];
    CGRect viewFrame = [view frame];
    
    [self setFrame:CGRectRound(CGRectMake(CGRectGetMinX(viewFrame) - CGRectGetWidth(frame) - offset, CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame)))];
}

#pragma mark -
#pragma mark Resizing

- (void)setFrameSizeToImageSize
{
    if ([self isKindOfClass:[UIButton class]])
    {
        UIImage *image = [(UIButton *)self imageForState:UIControlStateNormal];
        
        if (!image)
        {
            image = [(UIButton *)self backgroundImageForState:UIControlStateNormal];
        }
        
        if (image)
        {
            [self setFrame:CGRectMake(CGRectGetMinX([self frame]), CGRectGetMinY([self frame]), [image size].width, [image size].height)];
        }
    }
    else if ([self isKindOfClass:[UIImageView class]])
    {
        UIImage *image = [(UIImageView *)self image];
        if (image)
        {
            [self setFrame:CGRectMake(CGRectGetMinX([self frame]), CGRectGetMinY([self frame]), [image size].width, [image size].height)];
        }
    }
}

#pragma mark - Corners and Masks

- (void)roundCornersTopLeft:(CGFloat)topLeft topRight:(CGFloat)topRight bottomLeft:(CGFloat)bottomLeft bottomRight:(CGFloat)bottomRight
{
    UIImage *mask = createRoundedCornerMask([self bounds], topLeft, topRight, bottomLeft, bottomRight);
    CALayer *layerMask = [CALayer layer];
    [layerMask setFrame:[self bounds]];
    [layerMask setContents:(id)[mask CGImage]];
    [[self layer] setMask:layerMask];
}

- (void)setVerticalFadeMaskWithTopOffset:(CGFloat)topOffset bottomOffset:(CGFloat)bottomOffset
{
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    
    UIColor *outerColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
    UIColor *innerColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
    [maskLayer setColors:@[
                           (id)[outerColor CGColor],
                           (id)[innerColor CGColor],
                           (id)[innerColor CGColor],
                           (id)[outerColor CGColor]
                           ]];
    [maskLayer setLocations:@[
                              @(0.0f),
                              @(topOffset),
                              @(1.0f - bottomOffset),
                              @(1.0f)
                              ]];
    [maskLayer setStartPoint:CGPointMake(0.5f, 1.0f)];
    [maskLayer setEndPoint:CGPointMake(0.5f, 0.0f)];
    [maskLayer setBounds:[self bounds]];
    [maskLayer setAnchorPoint:CGPointZero];
    [[self layer] setMask:maskLayer];
}

- (void)setHorizontalFadeMaskWithLeftOffset:(CGFloat)leftOffset rightOffset:(CGFloat)rightOffset
{
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    
    UIColor *outerColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
    UIColor *innerColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
    [maskLayer setColors:@[
                           (id)[outerColor CGColor],
                           (id)[innerColor CGColor],
                           (id)[innerColor CGColor],
                           (id)[outerColor CGColor]
                           ]];
    [maskLayer setLocations:@[
                              @(0.0f),
                              @(leftOffset),
                              @(1.0f - rightOffset),
                              @(1.0f)
                              ]];
    [maskLayer setStartPoint:CGPointMake(0.0f, 0.5f)];
    [maskLayer setEndPoint:CGPointMake(1.0f, 0.5f)];
    [maskLayer setBounds:[self bounds]];
    [maskLayer setAnchorPoint:CGPointZero];
    [[self layer] setMask:maskLayer];
}

static inline UIImage* createRoundedCornerMask(CGRect rect, CGFloat radius_tl, CGFloat radius_tr, CGFloat radius_bl, CGFloat radius_br)
{
    CGContextRef context;
    CGColorSpaceRef colorSpace;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    float scaleFactor = [[UIScreen mainScreen] scale];
    context = CGBitmapContextCreate( NULL,
                                    rect.size.width * scaleFactor,
                                    rect.size.height * scaleFactor,
                                    8,
                                    rect.size.width * scaleFactor * 4,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedLast );
    
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL)
    {
        return NULL;
    }
    
    CGContextScaleCTM(context, scaleFactor, scaleFactor);
    
    CGFloat minx = CGRectGetMinX( rect ), midx = CGRectGetMidX( rect ), maxx = CGRectGetMaxX( rect );
    CGFloat miny = CGRectGetMinY( rect ), midy = CGRectGetMidY( rect ), maxy = CGRectGetMaxY( rect );
    
    CGContextBeginPath( context );
    CGContextSetGrayFillColor( context, 1.0, 0.0 );
    CGContextAddRect( context, rect );
    CGContextClosePath( context );
    CGContextDrawPath( context, kCGPathFill );
    
    CGContextSetGrayFillColor( context, 1.0, 1.0 );
    CGContextBeginPath( context );
    CGContextMoveToPoint( context, minx, midy );
    CGContextAddArcToPoint( context, minx, miny, midx, miny, radius_bl );
    CGContextAddArcToPoint( context, maxx, miny, maxx, midy, radius_br );
    CGContextAddArcToPoint( context, maxx, maxy, midx, maxy, radius_tr );
    CGContextAddArcToPoint( context, minx, maxy, minx, midy, radius_tl );
    CGContextClosePath( context );
    CGContextDrawPath( context, kCGPathFill );
    
    CGImageRef bitmapContext = CGBitmapContextCreateImage( context );
    CGContextRelease( context );
    
    UIImage *mask = [UIImage imageWithCGImage:bitmapContext];
    
    CGImageRelease(bitmapContext);
    
    return mask;
}

#pragma mark - Snapshotting

- (UIImageView *)createSnapshot
{
    UIGraphicsBeginImageContextWithOptions([self bounds].size, YES, 0);
    
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -[self bounds].origin.x, -[self bounds].origin.y);
    
    [[self layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *snapshot = [[UIImageView alloc] initWithImage:image];
    [snapshot setFrame:[self frame]];
    
    return snapshot;
}

- (UIImage *)snapshotImage
{
    UIGraphicsBeginImageContextWithOptions([self bounds].size, YES, 0);
    
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -[self bounds].origin.x, -[self bounds].origin.y);
    
    [[self layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIView *)snapshotImageView
{
    UIView *snapshot;
    
    if ([self respondsToSelector:@selector(snapshotView)])
    {
        snapshot = [self performSelector:@selector(snapshotView)];
    }
    
    else
    {
        UIImage *image = [self snapshotImage];
        snapshot = [[UIImageView alloc] initWithImage:image];
        [snapshot setFrame:[self bounds]];
    }
    
    return snapshot;
}

#pragma mark - Debugging

- (void)showDebugFrame
{
    [self showDebugFrame:NO];
}

- (void)hideDebugFrame
{
    [[self layer] setBorderColor:nil];
    [[self layer] setBorderWidth:0.0f];
}

- (void)showDebugFrame:(BOOL)showInRelease
{
    [self performInRelease:showInRelease
                     block:^{
                         
                         [[self layer] setBorderColor:[[UIColor redColor] CGColor]];
                         [[self layer] setBorderWidth:1.0f];
                         
                     }];
    
}

- (void)logFrameChanges
{
    [self performInDebug:^{
        
        [self frameDidChange];
        [self addObserver:self forKeyPath:UIVIEW_HELPERS_FRAME_KVO_KEY options:0 context:0];
        
    }];
}

- (void)frameDidChange
{
    [self performInDebug:^{
        
        NSLog(@"%@ <%@: %p; frame = %@>", nameOfVar(self),
              NSStringFromClass([self class]),
              self,
              NSStringFromCGRect([self frame]));
        
    }];
}

#pragma mark - LayoutHelpers

- (BOOL)isViewVisible
{
    BOOL isViewHidden = [self isHidden] || [self alpha] == 0 || CGRectIsEmpty([self frame]);
    return !isViewHidden;
}

+ (CGFloat)alignVertical:(VerticalLayoutType)type
                   views:(NSArray*)views
             withSpacing:(CGFloat)spacing
                  inView:(UIView*)view
      shrinkSpacingToFit:(BOOL)shrinkSpacingToFit
{
    __block CGFloat height = 0;
    __block int numVisibleViews = 0;
    
    if (type == VerticalLayoutTypeCenter || (shrinkSpacingToFit && spacing > 0))
    {
        [views enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
            if ([obj isViewVisible]) {
                height += [obj frameSizeHeight] + ((idx > 0) ? spacing : 0);
                numVisibleViews += 1;
            }
        }];
        
        if (numVisibleViews == 0)
        {
            return 0;
        }
        
        if (shrinkSpacingToFit && height > [view frameSizeHeight])
        {
            CGFloat d = (height - [view frameSizeHeight]) / (CGFloat)(numVisibleViews-1);
            d  = MIN(spacing, d);
            spacing -= d;
            height -= (d * (CGFloat)(numVisibleViews-1));
        }
    }
    
    __block CGFloat y = 0;
    if (type == VerticalLayoutTypeCenter)
    {
        y = ([view frameSizeHeight] - height) * 0.5;
    } else if (type == VerticalLayoutTypeBottom)
    {
        y = [view frameSizeHeight];
    }
    
    CGFloat startY = y;
    [views enumerateObjectsWithOptions:(type == VerticalLayoutTypeBottom ? NSEnumerationReverse : 0)
                            usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                
                                if (type == VerticalLayoutTypeBottom)
                                {
                                    CGFloat height = [obj frameSizeHeight];
                                    [obj setFrameOriginY: y-height];
                                    if ([obj isViewVisible])
                                    {
                                        y -= height+spacing;
                                    }
                                }
                                else
                                {
                                    [obj setFrameOriginY:y];
                                    if ([obj isViewVisible])
                                    {
                                        y += [obj frameSizeHeight]+spacing;
                                    }
                                }
                            }];
    
    CGFloat ret = ABS(y - startY)-spacing;
    return ret;
}

+ (CGFloat)alignVertical:(VerticalLayoutType)type
                   views:(NSArray*)views
        withSpacingArray:(NSArray*)spacing
                  inView:(UIView*)view
      shrinkSpacingToFit:(BOOL)shrinkSpacingToFit
{
    __block CGFloat height = 0;
    __block int numVisibleViews = 0;
    CGFloat spacingModifier = 0;
    
    if (type == VerticalLayoutTypeCenter || (shrinkSpacingToFit && spacing > 0))
    {
        __block CGFloat totalSpacing = 0;
        [views enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
            if ([obj isViewVisible])
            {
                CGFloat space = ((idx > 0 && idx-1 < spacing.count) ? [spacing[idx-1] floatValue] : 0);
                totalSpacing += space;
                height += [obj frameSizeHeight] + space;
                numVisibleViews += 1;
            }
        }];
        
        if (numVisibleViews == 0)
        {
            return 0;
        }
        
        if (shrinkSpacingToFit && height > [view frameSizeHeight])
        {
            CGFloat d = MIN(totalSpacing, (height - [view frameSizeHeight]));
            spacingModifier = (d / totalSpacing);
        }
    }
    
    __block CGFloat y = 0;
    if (type == VerticalLayoutTypeCenter)
    {
        y = ([view frameSizeHeight] - height) * 0.5;
    }
    else if (type == VerticalLayoutTypeBottom)
    {
        y = [view frameSizeHeight];
    }
    
    CGFloat startY = y;
    [views enumerateObjectsWithOptions:(type == VerticalLayoutTypeBottom ? NSEnumerationReverse : 0)
                            usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                
                                CGFloat space = ((idx < spacing.count) ? [spacing[idx] floatValue] : 0);
                                space -= (space * spacingModifier);
                                
                                if (type == VerticalLayoutTypeBottom)
                                {
                                    CGFloat height = [obj frameSizeHeight];
                                    [obj setFrameOriginY: y-height];
                                    if ([obj isViewVisible])
                                    {
                                        y -= height+space;
                                    }
                                }
                                else
                                {
                                    [obj setFrameOriginY:y];
                                    if ([obj isViewVisible])
                                    {
                                        y += [obj frameSizeHeight]+space;
                                    }
                                }
                            }];
    
    CGFloat ret = ABS(y - startY);
    return ret;
}

#pragma mark - Subviews

+ (UIView *)firstResponder
{
    UIView *view = [[UIApplication sharedApplication] keyWindow];
    return [view firstResponderInSubviews];
}

- (UIView *)firstResponderInSubviews
{
    UIView *responder;
    
    for (UIView *subview in [self subviews])
    {
        if ([subview isFirstResponder])
        {
            responder = subview;
        }
        else
        {
            responder = [subview firstResponderInSubviews];
        }
        
        if (responder)
        {
            break;
        }
    }
    
    return responder;
}

- (NSArray *)subviewsOfClass:(Class)aClass recursive:(BOOL)recursive
{
    NSMutableArray *subviews = [@[] mutableCopy];
    
    for (UIView *subview in [self subviews])
    {
        if ([subview isKindOfClass:aClass])
        {
            [subviews addObject:subview];
        }
        if (recursive)
        {
            [subviews addObjectsFromArray:[subview subviewsOfClass:aClass recursive:YES]];
        }
    }
    
    return subviews;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:UIVIEW_HELPERS_FRAME_KVO_KEY])
    {
        [self frameDidChange];
    }
}

#pragma mark - Helpers

- (void)performInDebug:(void (^)(void))block
{
    [self performInRelease:NO block:block];
}

- (void)performInRelease:(BOOL)release block:(void (^)(void))block
{
    if (block)
    {
#ifdef DEBUG
        block();
#else
        if (release)
        {
            block();
        }
#endif
    }
}

@end
