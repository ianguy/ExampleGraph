//
//  IBGraph.h
//  ExampleGraph
//
//  Created by Ian Butler on 2015-08-13.
//  Copyright (c) 2015 ianbutler. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IBStockGraph : NSView <NSAnimationDelegate>
@property NSUInteger xAxisMarkers;
@property NSUInteger yAxisMarkers;
-(void) setData: (NSDictionary *)dataSet;
@end
