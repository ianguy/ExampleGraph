//
//  AppDelegate.m
//  ExampleGraph
//
//  Created by Ian Butler on 2015-08-12.
//  Copyright (c) 2015 ianbutler. All rights reserved.
//

#import "AppDelegate.h"
#import "IBStockGraph.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet IBStockGraph *graph;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"stockprices" ofType:@"json"];
	NSDictionary * dataSet = [self loadPrices:filePath];
	self.graph.yAxisMargin = 400;
	[self.graph setData:dataSet];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

/**
 Converts the source data at dataPath to a dictionary with date keys and price values
 */
- (NSDictionary *)loadPrices:(NSString *)dataPath{
	NSData *priceSourceData = [NSData dataWithContentsOfFile:dataPath];
	NSError *error = nil;
	id pricesObject = [NSJSONSerialization
				 JSONObjectWithData:priceSourceData
				 options:0
				 error:&error];
	if(error) {
		// TODO: alert
	}

	if([pricesObject isKindOfClass:[NSDictionary class]])
	{

		NSArray * prices = [pricesObject valueForKey:@"stockdata"];
		NSMutableDictionary * results = [[NSMutableDictionary alloc] initWithCapacity:[prices count]];
		for (NSDictionary *price in prices) {
			[results setObject:[price valueForKey:@"close"] forKey:[price valueForKey:@"date"]];
		}
		return results;

	}
	return nil;
}

@end
