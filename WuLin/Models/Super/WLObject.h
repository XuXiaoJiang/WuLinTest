//
//  WLObject.h
//  WuLin
//
//  Created by Xu Xiaojiang on 21/11/12.
//  Copyright (c) 2012 must2334. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface WLObject : NSObject

@property (nonatomic, strong) NSString *name;

- (void)configureWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionaryWithNullValue:(BOOL)useNull

@end
