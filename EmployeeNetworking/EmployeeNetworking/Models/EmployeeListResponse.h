//
//  EmployeeListResponse.h
//  EmployeeNetworking
//
//  Created by Zeeshan Shakeel on 22/05/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmployeeListResponse : NSObject

@property (nonatomic, strong) NSArray *employees;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
