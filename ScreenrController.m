//
//  ScreenrController.m
//  Screenr
//
//  Created by Ryan Joseph on 3/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ScreenrController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ScreenrController
- (void) awakeFromNib;
{
	[mDivSlider setMinValue: 2.0];
	[mDivSlider setMaxValue: 10.0];
	[mDivSlider setNumberOfTickMarks: 16];
	[mDivSlider setAllowsTickMarkValuesOnly: YES];
	[mDivSlider setFloatValue: 4.0];
	[mDivSlider setTarget: self];
	[mDivSlider setAction: @selector(updateScreenshot)];
	
	[mModSlider setMinValue: 1.0];
	[mModSlider setMaxValue: 4.0];	
	[mModSlider setNumberOfTickMarks: 12];	
	[mModSlider setAllowsTickMarkValuesOnly: YES];	
	[mModSlider setFloatValue: 2.0];	
	[mModSlider setTarget: self];	
	[mModSlider setAction: @selector(updateScreenshot)];
	
	[self updateScreenshot];
}

- (void) updateScreenshot;
{	
	[mDivSlider setEnabled: NO];
	[mModSlider setEnabled: NO];
	
	// get the screenshot
	CGImageRef screenie = CGWindowListCreateImage(CGRectInfinite, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
	
	CGFloat sWidth = (CGFloat)CGImageGetWidth(screenie);
	CGFloat sHeight = (CGFloat)CGImageGetHeight(screenie);
	
	CGFloat sWidthD = sWidth / [mDivSlider floatValue];
	CGFloat sHeightD = sHeight / [mDivSlider floatValue];
	
	CGFloat sTimesMod = (CGFloat)[mModSlider floatValue];
	
	CIImage* cImg = [[CIImage alloc] initWithCGImage: screenie];
	
	CIFilter* filter = [CIFilter filterWithName: @"CIPerspectiveTransform"];
	[filter setDefaults];	
	[filter setValue: cImg forKey: @"inputImage"];
	
	CIVector* topRight = [CIVector vectorWithX: sWidth + (sWidthD * sTimesMod) Y: sHeight + (sHeightD * sTimesMod)];
	CIVector* topLeft = [CIVector vectorWithX: 0 Y: sHeight];
	CIVector* botRight = [CIVector vectorWithX: sWidth Y: (sHeightD * sTimesMod)];
	CIVector* botLeft = [CIVector vectorWithX: (sWidthD * sTimesMod) Y: 0];
	
	[filter setValue: topLeft forKey: @"inputTopLeft"];
	[filter setValue: topRight forKey: @"inputTopRight"];
	[filter setValue: botRight forKey: @"inputBottomRight"];
	[filter setValue: botLeft forKey: @"inputBottomLeft"];
	
	//CIFilter* gFilter = [CIFilter filterWithName: @"CIGloom"];
	//[gFilter setDefaults];
	//[gFilter setValue: [filter valueForKey: @"outputImage"] forKey: @"inputImage"];
		
	CIImage* resImg = [[filter valueForKey: @"outputImage"] 
					   imageByCroppingToRect: CGRectMake(sWidthD * (sTimesMod + 1), 
														 sHeightD * (sTimesMod + 1), 
														 sWidth - (sWidthD * (sTimesMod + 1)), 
														 sHeight - (sHeightD * (sTimesMod + 1)))];	
	
	// make an NSImage to display
	[mLastImageRep release];
	mLastImageRep = [[NSBitmapImageRep alloc] initWithCIImage: resImg];
	
	NSImage* img = [[NSImage alloc] init];	
	[img addRepresentation: mLastImageRep];	
	[mImageView setImage: img];
	[img release];
	
	[mDivSlider setEnabled: YES];
	[mModSlider setEnabled: YES];
}

- (IBAction) saveImage: (id) sender;
{
	static UInt32 saveCount = 0;
	
	if (mLastImageRep)
	{
		if (!mSavePath)
		{
			NSSavePanel* sPanel = [NSSavePanel savePanel];
			[sPanel setRequiredFileType: @"jpg"];
			[sPanel setTitle: @"Set filename for export"];
			
			if ([sPanel runModal] == NSFileHandlingPanelOKButton)
			{
				mSavePath = [[sPanel filename] retain];
			}
			else
			{
				mSavePath = [@"~/Desktop/Screenr.jpg" stringByExpandingTildeInPath];
			}
		}
		
		NSData* jpegRep = [mLastImageRep representationUsingType: NSJPEGFileType 
													  properties: [NSDictionary dictionaryWithObjectsAndKeys:
																   [NSNumber numberWithBool: YES], NSImageProgressive, nil]];
		
		NSString* thisSave = [NSString stringWithFormat: @"%@/%@_%03d.%@",
							  [mSavePath stringByDeletingLastPathComponent],
							  [[mSavePath lastPathComponent] stringByDeletingPathExtension],
							  ++saveCount, [mSavePath pathExtension]];
		
		NSLog(@"Saving screenshot to '%@'", thisSave);
		[jpegRep writeToFile: thisSave atomically: NO];
	}
}

- (IBAction) quitAction: (id) sender;
{
	[NSApp terminate: NULL];
}

- (NSApplicationTerminateReply) applicationShouldTerminate: (NSApplication*) sender;
{
	[mLastImageRep release];
	
	return NSTerminateNow;
}
@end
