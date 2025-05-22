//
//  Utils.m
//  EmployeeNetworking
//
//  Created by Zeeshan Shakeel on 22/05/2025.
//

#import "Utils.h"
#import "ModuleConstants.h"

NS_ASSUME_NONNULL_BEGIN

@implementation Utils

+ (id)parseStringValueForKey:(NSString *)key fromDictionary:(NSDictionary *)dictionary {
    id value = dictionary[key];
    
    return value != nil ? value : @"";
}

@end

NS_ASSUME_NONNULL_END
