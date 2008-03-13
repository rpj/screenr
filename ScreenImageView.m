//
//  ScreenImageView.m
//  Screenr
//
//  Created by Jacob Farkas on 3/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ScreenImageView.h"
#import <QuartzCore/QuartzCore.h>

#define NSRectFromCGRect(rect) NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)

@implementation ScreenImageView

@synthesize screenImage = mScreenImage;

- (void)drawRect:(NSRect)rect
{
    if (mScreenImage) {
        [mScreenImage drawInRect:rect fromRect:NSRectFromCGRect([mScreenImage extent]) operation:NSCompositeCopy fraction:1.0];
    }
}

@end
