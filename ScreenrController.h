//
//  ScreenrController.h
//  Screenr
//
//  Created by Ryan Joseph on 3/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ScreenrController : NSObject {
	IBOutlet NSImageView*	mImageView;
	
	IBOutlet NSSlider*		mDivSlider;
	IBOutlet NSSlider*		mModSlider;
	
	IBOutlet NSButton*		mSaveButton;
	
	NSBitmapImageRep*		mLastImageRep;
	NSString*				mSavePath;
}

- (void) awakeFromNib;

- (void) updateScreenshot;
- (IBAction) saveImage: (id) sender;

- (IBAction) quitAction: (id) sender;

@end
