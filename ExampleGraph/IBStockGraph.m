//
//  IBGraph.m
//  ExampleGraph
//
//  Created by Ian Butler on 2015-08-13.
//  Copyright (c) 2015 ianbutler. All rights reserved.
//

#import "IBStockGraph.h"

@implementation IBStockGraph{
	NSDictionary * dataPoints;
	NSUInteger minPriceInCents;
	NSUInteger maxPriceInCents;
	NSArray * sortedKeys;
	NSAnimation * theAnim;
	NSMutableArray * yAxisLabels;
}
- (id)init{
	self = [super init];
	if (self){
		self.yAxisMarkers = 4;
		theAnim = [[NSAnimation alloc] initWithDuration:5.0
										 animationCurve:NSAnimationEaseIn];
		[theAnim setFrameRate:60.0];
		[theAnim setAnimationBlockingMode:NSAnimationNonblocking];
		[theAnim setDelegate:self];
	}
	return self;

}
-(id)initWithFrame:(NSRect)frameRect{
	self = [super initWithFrame:frameRect];
	if (self){
		self.yAxisMarkers = 4;
		theAnim = [[NSAnimation alloc] initWithDuration:5.0
										 animationCurve:NSAnimationEaseIn];
		[theAnim setFrameRate:60.0];
		[theAnim setAnimationBlockingMode:NSAnimationNonblocking];
		[theAnim setDelegate:self];
	}
	return self;
}
-(id)initWithCoder:(NSCoder *)coder{
	self = [super initWithCoder:coder];
	if (self){
		self.yAxisMarkers = 4;
		theAnim = [[NSAnimation alloc] initWithDuration:5.0
										 animationCurve:NSAnimationEaseIn];
		[theAnim setFrameRate:60.0];
		[theAnim setAnimationBlockingMode:NSAnimationNonblocking];
		[theAnim setDelegate:self];
	}
	return self;
}
- (float)getAxisNormalizedValue: (NSUInteger) scale atPosition: (NSUInteger) position{
	return ((0.9*scale)/self.yAxisMarkers)*(position);
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
	const NSUInteger axisOffset = 32;
	if (dataPoints != nil){
		NSUInteger xAxisLength = self.frame.size.width - (axisOffset*2);
		NSUInteger yAxisLength = self.frame.size.height - (axisOffset*2);
		NSUInteger dataPointCount = [[dataPoints allKeys] count];
		NSGraphicsContext* theContext = [NSGraphicsContext currentContext];
		// compute and draw axis and labels if needed by dirtyRect
		if (dirtyRect.origin.x <= axisOffset || dirtyRect.origin.y <= axisOffset){



			NSPoint yAxisMarkerPoints[self.yAxisMarkers];
			[NSBezierPath setDefaultLineWidth:1.0];
			[theContext setShouldAntialias:YES];
			for (uint i = 0; i < self.yAxisMarkers; i++) {
				yAxisMarkerPoints[i] = NSMakePoint(axisOffset, axisOffset+([self getAxisNormalizedValue:yAxisLength atPosition:i+1]));
				NSPoint destPoint = NSMakePoint(axisOffset + xAxisLength, yAxisMarkerPoints[i].y);
				[NSBezierPath strokeLineFromPoint:yAxisMarkerPoints[i] toPoint:destPoint];
				NSString * label = yAxisLabels[i];
				NSPoint labelPoint = NSMakePoint(2, yAxisMarkerPoints[i].y - 6);
				[label drawAtPoint:labelPoint withAttributes:nil];
			}

			NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
			style.alignment = NSCenterTextAlignment;
			NSDictionary *attr = [NSDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];

			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

			uint i = 0;
			for (NSString * dateStr in sortedKeys) {
				[dateFormat setDateFormat:@"yyyy-MM-dd"];
				NSDate *date = [dateFormat dateFromString:dateStr];
				[dateFormat setDateFormat:@"M/d"];
				NSString * dateLabel = [dateFormat stringFromDate:date];
				[dateLabel drawAtPoint:NSMakePoint(axisOffset + (i*(xAxisLength/dataPointCount)), axisOffset-16) withAttributes:attr];
				i++;
			}



			[NSBezierPath setDefaultLineWidth:3.0];
			[NSBezierPath strokeLineFromPoint:NSMakePoint(axisOffset, axisOffset) toPoint:NSMakePoint(axisOffset+xAxisLength, axisOffset)];
			// We subtract one from the origin here since lines are drawn centered
			[NSBezierPath strokeLineFromPoint:NSMakePoint(axisOffset, axisOffset-1) toPoint:NSMakePoint(axisOffset, axisOffset+yAxisLength)];

		}
		// draw points
		uint i = 0;
		NSPoint graphPoints[dataPointCount];
		for (id key in sortedKeys) {
			NSString * price = [dataPoints valueForKey:key];
			NSUInteger centValue = [price floatValue]*100;
			NSUInteger range = (maxPriceInCents-minPriceInCents);
			NSPoint point = NSMakePoint(axisOffset + (i*(xAxisLength/dataPointCount)), axisOffset + ((centValue-minPriceInCents)*((float)yAxisLength/range)));
			[NSBezierPath strokeRect:NSMakeRect(point.x, point.y, 2.0, 2.0)];
			
			graphPoints[i] = point;
			i++;
		}



		// draw/animate lines
		for (uint i = 0; i < dataPointCount-1; i++){
			[NSBezierPath setDefaultLineWidth:2.0];
			[NSBezierPath strokeLineFromPoint:graphPoints[i] toPoint:graphPoints[i+1]];
		}
	}

}
-(void) setData: (NSDictionary *)dataSet{
	dataPoints = dataSet;
	minPriceInCents = NSUIntegerMax;
	maxPriceInCents = 0;
	// TODO: more proper currency handling
	for (NSString * price in [dataSet allValues]) {
		NSUInteger centValue = [price floatValue]*100;
		if (centValue < minPriceInCents){
			minPriceInCents = centValue;
		}
		if (centValue > maxPriceInCents){
			maxPriceInCents = centValue;
		}
	}
	yAxisLabels = [[NSMutableArray alloc]initWithCapacity:self.yAxisMarkers];
	NSUInteger valueRangeInCents = maxPriceInCents-minPriceInCents;
	for (uint i = 0; i < self.yAxisMarkers; i++){
		float priceAtLabel = ([self getAxisNormalizedValue:valueRangeInCents atPosition:i+1] + minPriceInCents)/100;
		yAxisLabels[i] = [NSString stringWithFormat:@"$%.0f",priceAtLabel];

	}
	sortedKeys = [[dataPoints allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
	dispatch_async( dispatch_get_main_queue(), ^{
		[self setNeedsDisplay:YES];
	});

}

@end
