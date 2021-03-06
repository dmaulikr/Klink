//
//  LeavesCache.m
//  Reader
//
//  Created by Tom Brow on 5/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LeavesCache.h"


@implementation LeavesCache

@synthesize dataSource, pageSize;

- (id) initWithPageSize:(CGSize)aPageSize
{
    self = [super init];
	if (self) {
		pageSize = aPageSize;
		pageCache = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[pageCache release];
	[super dealloc];
}



- (CGImageRef) imageForPageIndex:(NSUInteger)pageIndex {
	CGFloat scale = [[UIScreen mainScreen] scale];  // we need to size the graphics context according to the device scale
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, 
												 pageSize.width*scale, 
												 pageSize.height*scale, 
												 8,						/* bits per component*/
												 pageSize.width*scale * 4, 	/* bytes per row */
												 colorSpace, 
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpace);
    CGContextClipToRect(context, CGRectMake(0, 0, pageSize.width*scale, pageSize.height*scale));
    
    CGContextScaleCTM(context, scale, scale);
	
	[dataSource renderPageAtIndex:pageIndex inContext:context];
    
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
    
    [UIImage imageWithCGImage:image];
	//[UIImage imageWithCGImage:image scale:scale orientation:UIImageOrientationUp];
	CGImageRelease(image);
	
	return image;
}

- (CGImageRef) cachedImageForPageIndex:(NSUInteger)pageIndex {
	NSNumber *pageIndexNumber = [NSNumber numberWithInt:pageIndex];
	UIImage *pageImage;
	@synchronized (pageCache) {
		pageImage = [pageCache objectForKey:pageIndexNumber];
	}
	if (!pageImage) {
		CGImageRef pageCGImage = [self imageForPageIndex:pageIndex];
		pageImage = [UIImage imageWithCGImage:pageCGImage];
        //CGFloat scale = [[UIScreen mainScreen] scale];
        //pageImage = [UIImage imageWithCGImage:pageCGImage scale:scale orientation:UIImageOrientationUp];
		@synchronized (pageCache) {
			[pageCache setObject:pageImage forKey:pageIndexNumber];
		}
	}
	return pageImage.CGImage;
}

- (void) precacheImageForPageIndexNumber:(NSNumber *)pageIndexNumber {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self cachedImageForPageIndex:[pageIndexNumber intValue]];
	[pool release];
}

- (void) precacheImageForPageIndex:(NSUInteger)pageIndex {
	[self performSelectorInBackground:@selector(precacheImageForPageIndexNumber:)
						   withObject:[NSNumber numberWithInt:pageIndex]];
}

- (void) minimizeToPageIndex:(NSUInteger)pageIndex viewMode:(LeavesViewMode)viewMode {
	/* Uncache all pages except previous, current, and next. */
	@synchronized (pageCache) {
        int cutoffValueFromPageIndex = 2;
        if (viewMode == LeavesViewModeFacingPages) {
            cutoffValueFromPageIndex = 3;
        }
		for (NSNumber *key in [pageCache allKeys])
			if (ABS([key intValue] - (int)pageIndex) > cutoffValueFromPageIndex)
				[pageCache removeObjectForKey:key];
	}
}

- (void) flush {
	@synchronized (pageCache) {
		[pageCache removeAllObjects];
	}
}

#pragma mark accessors

- (void) setPageSize:(CGSize)value {
	pageSize = value;
	[self flush];
}

@end
