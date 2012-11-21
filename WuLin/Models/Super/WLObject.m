//
//  WLObject.m
//  WuLin
//
//  Created by Xu Xiaojiang on 21/11/12.
//  Copyright (c) 2012 must2334. All rights reserved.
//

#import "WLObject.h"

@interface WLObject ()

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSDate *create_date;
@property WLObject *object;

@end

@implementation WLObject

- (void)configureWithDictionary:(NSDictionary *)dict
{
  unsigned int outCount;
  id class = objc_getClass([NSStringFromClass([self class]) UTF8String]);
  Ivar *ivars = class_copyIvarList(class, &outCount);
  NSEnumerator *enumerator = [dict keyEnumerator];
  id key;
  id value;
  while (key = [enumerator nextObject]){
    value = [dict objectForKey:key];
    //If it match our ivar name, then set it
    for (unsigned int i = 0; i < outCount; i++)
    {
      Ivar ivar = ivars[i];
      NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
      NSString *ivarNameTrim = [ivarName substringFromIndex:1];
      NSLog(@"%@, %@", ivarName, ivarNameTrim);
      
      if ([key isEqualToString:ivarNameTrim] == NO)
        continue;
      
      //Empty value
      if ([value isKindOfClass:[NSNull class]] ||
          ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"null"])) {
        continue;
      }
      
      [self setValue:value forKey:ivarName];
    }
  }
  free(ivars);
}

- (id)updateWithObject:(WLObject*)someObject
{
  unsigned int outCount;
  id class = objc_getClass([NSStringFromClass([self class]) UTF8String]);
  Ivar *ivars = class_copyIvarList(class, &outCount);
  
  for (unsigned int i = 0; i < outCount; i++) {
    Ivar ivar = ivars[i];
    NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
    NSString *ivarNameTrim = [ivarName substringFromIndex:1];
    NSString *ivarType = [NSString stringWithCString:ivar_getTypeEncoding(ivar) encoding:NSUTF8StringEncoding];
    
    //Check nil
    if ([ivarType hasPrefix:@"@"])
    {
      id ivarValue = object_getIvar(someObject, ivar);
      if (ivarValue == nil)
        continue;
      
      [self setValue:ivarValue forKey:ivarNameTrim];
    }
  }
  free(ivars);
  return self;
}

- (id)createCopy
{
  return [[[self class] alloc] updateWithObject:self];
}

- (NSDictionary *)toDictionary
{
  return [self toDictionaryWithNullValue:NO];
}

- (NSDictionary *)toDictionaryWithNullValue:(BOOL)useNull
{
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  
  unsigned int count;
  id class = objc_getClass([NSStringFromClass([self class]) UTF8String]);
  Ivar *ivars = class_copyIvarList(class, &count);
  for (unsigned int i = 0 ; i < count ; i ++){
    Ivar ivar = ivars[i];
    NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding ];
    NSString *key = [ivarName substringFromIndex:1];
    NSString *ivarType = [NSString stringWithCString:ivar_getTypeEncoding(ivar) encoding:NSUTF8StringEncoding];
    if ([ivarType hasPrefix:@"@"]){
      id value = object_getIvar(self, ivar);
      
      if (value == nil){
        if (!useNull){
          continue;
        }else {
          value = [NSNull null];
        }
        [dict setValue:value forKey:key];
      }
    }
  }
  return dict;
}

/*
 * Support offline caching with NSKeyArchiver
 */
- (void)encodeWithCoder:(NSCoder *)coder
{
  unsigned int outCount;
  id class = objc_getClass([NSStringFromClass([self class]) UTF8String]);
  Ivar *ivars = class_copyIvarList(class, &outCount);
  
  for (unsigned int i = 0; i < outCount; i++) {
    Ivar ivar = ivars[i];
    NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
    NSString *encoding = [NSString stringWithCString:ivar_getTypeEncoding(ivar) encoding:NSUTF8StringEncoding];
    
    //Check nil
    if ([encoding hasPrefix:@"@"])
    {
      id ivarValue = object_getIvar(self, ivar);
      if (ivarValue == nil)
        continue;
      
      [coder encodeObject:ivarValue forKey:ivarName];
    }
  }
  
  free(ivars);
}

/*
 * Support offline caching with NSKeyArchiver
 */
- (id)initWithCoder:(NSCoder *)coder
{
  self = [super init];
  if (self == nil)
    return self;
  
  unsigned int outCount;
  id class = objc_getClass([NSStringFromClass([self class]) UTF8String]);
  Ivar *ivars = class_copyIvarList(class, &outCount);
  
  for (unsigned int i = 0; i < outCount; i++) {
    Ivar ivar = ivars[i];
    NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
    NSString *encoding = [NSString stringWithCString:ivar_getTypeEncoding(ivar) encoding:NSUTF8StringEncoding];
    
    //Check nil
    if ([encoding hasPrefix:@"@"])
      [self setValue:[coder decodeObjectForKey:ivarName] forKey:ivarName];
  }
  
  free(ivars);
  
  return self;
}

@end
