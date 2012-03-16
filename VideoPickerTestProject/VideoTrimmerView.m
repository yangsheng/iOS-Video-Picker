//
//  VideoTrimmerView.m
//  VideoPickerTestProject
//
//  Created by Ying Quan Tan on 3/2/12.
//  Copyright (c) 2012 Burning Hollow Technologies. All rights reserved.
//

#define kVideoTrimmerSidePadding 10 /*this ought to also be the distance for the stretchable image left and right caps */
#define kVideoTrimmerHandleWidth 20

#define kVideoTrimmerMinWidth kVideoTrimmerHandleWidth * 2 + 10 

#import "VideoTrimmerView.h"

@implementation VideoTrimmerView

@synthesize overlayImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
 
  self = [super initWithCoder:aDecoder];
  if (self) {
    // Initialization codes
    overlayImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    overlayImageView.image = [UIImage imageNamed:@"bg-drill-button-done"];
    overlayImageView.backgroundColor = [UIColor redColor];
    [self addSubview:overlayImageView];
    
  }
  
  return self;
}

- (void)awakeFromNib {
  
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
  if ([touches count] > 1) {
    return; //do not handle multitouch gestures.
  }
  
  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInView:overlayImageView];

  //find handle locations      
  CGRect leftHandleRect = CGRectMake(0, 0, kVideoTrimmerHandleWidth, overlayImageView.frame.size.height);
  CGRect rightHandleRect = CGRectMake(overlayImageView.frame.size.width - kVideoTrimmerHandleWidth, 0, kVideoTrimmerHandleWidth, overlayImageView.frame.size.height);
    
  //decide what exactly we have grabbed.
  if (CGRectContainsPoint(leftHandleRect, point)) {
    NSLog(@"Point in LEFT: %@", NSStringFromCGPoint(point));
    actionType = VideoTrimmerActionMoveLeftHandle;
  } else if (CGRectContainsPoint(rightHandleRect, point)) {
    actionType = VideoTrimmerActionMoveRightHandle;
    NSLog(@"Point in RIGHT: %@", NSStringFromCGPoint(point));
  } else {
    if (actionType & VideoTrimmerActionMoveLeftHandle || actionType & VideoTrimmerActionMoveRightHandle) {
      //do not allow any actions while the handles are being grabbed
    } else {
      actionType = VideoTrimmerActionPan;
    }
    //NSLog(@"Point in MIDDLE: %@", NSStringFromCGPoint(point));          
  }
    

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  //move touches.
  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInView:overlayImageView];
  CGPoint previousPoint = [touch previousLocationInView:overlayImageView];
  //NSLog(@"touch : %@, previous point : %@", NSStringFromCGPoint(point), NSStringFromCGPoint(previousPoint));

      //get the distance we travelled in absolute points
  CGFloat distance = point.x - previousPoint.x;
  
  CGRect overlayFrame = overlayImageView.frame;
  
  if (actionType & VideoTrimmerActionMoveLeftHandle) { //if we are moving the left handle
    overlayFrame.origin.x += distance;
    overlayFrame.size.width -= distance;
  } else if (actionType & VideoTrimmerActionMoveRightHandle) {
    overlayFrame.size.width += distance;
  } else if (actionType & VideoTrimmerActionPan) {
    overlayFrame.origin.x += distance;
  }
  if (overlayFrame.size.width < kVideoTrimmerMinWidth || CGRectGetMinX(overlayFrame) < 0 || CGRectGetMaxX(overlayFrame) > self.frame.size.width) return; //abort, abort!!!
  overlayImageView.frame = overlayFrame;
  

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { 
  actionType = VideoTrimmerActionNone; //reset
}

- (void)dealloc {
  delegate = nil;
  [overlayImageView release];
  [super dealloc];
}

@end
