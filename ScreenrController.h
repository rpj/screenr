//
//  ScreenrController.h
//  Screenr
//
//  Created by Ryan Joseph on 3/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ScreenImageView;

@interface ScreenrController : NSObject {	
	IBOutlet NSButton*		mSaveButton;
    
	NSString*				mSavePath;

    float mDiv;
    float mMod;
    
    CIFilter *mFilter;
    IBOutlet ScreenImageView *mImageView;
}

@property (assign) float div;
@property (assign) float mod;

- (void) awakeFromNib;

- (void) updateScreenshot;
- (IBAction) saveImage: (id) sender;

- (IBAction) quitAction: (id) sender;

@end
