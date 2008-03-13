//
//  ScreenImageView.h
//  Screenr
//
//  Created by Jacob Farkas on 3/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CIImage;

@interface ScreenImageView : NSView {
    CIImage *mScreenImage;
}

@property (nonatomic, retain) CIImage *screenImage;

@end
