//
//  ScreenrController.m
//  Screenr
//
//  Created by Ryan Joseph on 3/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ScreenrController.h"
#import "ScreenImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ScreenrController

- (float) mod { return mMod; }
- (void) setMod:(float)value;
{
    mMod = value;
    [self updateScreenshot];
}

- (float) div { return mDiv; }
- (void) setDiv:(float)value;
{
    mDiv = value;
    [self updateScreenshot];
}

- (void) awakeFromNib;
{
    mDiv = 11;
    mMod = 5.5;

    mFilter = [CIFilter filterWithName: @"CIPerspectiveTransform"];
	[mFilter setDefaults];
    
	[self updateScreenshot];
}

- (void) dealloc;
{
    [mFilter release];
    [super dealloc];
}

- (void) updateScreenshot;
{  
    //NSLog(@"mod: %f div: %f", mMod, mDiv);
    
	// get the screenshot
	CGImageRef screenie = CGWindowListCreateImage(CGRectInfinite, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
	
	CGFloat sWidth = (CGFloat)CGImageGetWidth(screenie);
	CGFloat sHeight = (CGFloat)CGImageGetHeight(screenie);
	
	CGFloat sWidthD = sWidth / mDiv;
	CGFloat sHeightD = sHeight / mDiv;
	
	CIImage* cImg = [[CIImage alloc] initWithCGImage: screenie];
	[mFilter setValue:cImg forKey: @"inputImage"];
    [cImg release];
    CGImageRelease(screenie);
	
	CIVector* topRight = [CIVector vectorWithX: sWidth + (sWidthD * mMod) Y: sHeight + (sHeightD * mMod)];
	CIVector* topLeft = [CIVector vectorWithX: 0 Y: sHeight];
	CIVector* botRight = [CIVector vectorWithX: sWidth Y: (sHeightD * mMod)];
	CIVector* botLeft = [CIVector vectorWithX: (sWidthD * mMod) Y: 0];
	
	[mFilter setValue: topLeft forKey: @"inputTopLeft"];
	[mFilter setValue: topRight forKey: @"inputTopRight"];
	[mFilter setValue: botRight forKey: @"inputBottomRight"];
	[mFilter setValue: botLeft forKey: @"inputBottomLeft"];
	
	//CIFilter* gFilter = [CIFilter filterWithName: @"CIGloom"];
	//[gFilter setDefaults];
	//[gFilter setValue: [filter valueForKey: @"outputImage"] forKey: @"inputImage"];
		
	CIImage* resImg = [[mFilter valueForKey: @"outputImage"] 
					   imageByCroppingToRect: CGRectMake(sWidthD * (mMod + 1), 
														 sHeightD * (mMod + 1), 
														 sWidth - (sWidthD * (mMod + 1)), 
														 sHeight - (sHeightD * (mMod + 1)))];
    
    mImageView.screenImage = resImg;
    [mImageView setNeedsDisplay:YES];
}

- (IBAction) saveImage: (id) sender;
{
	static UInt32 saveCount = 0;
	
	if (mImageView.screenImage)
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
		
        NSBitmapImageRep *bmpRep = [[NSBitmapImageRep alloc] initWithCIImage:mImageView.screenImage];
        
		NSData* jpegRep = [bmpRep representationUsingType: NSJPEGFileType 
													  properties: [NSDictionary dictionaryWithObjectsAndKeys:
																   [NSNumber numberWithBool: YES], NSImageProgressive, nil]];
        [bmpRep release];
		
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
	return NSTerminateNow;
}
@end
