//
//  EmployeeListResponse.m
//  EmployeeNetworking
//
//  Created by Zeeshan Shakeel on 22/05/2025.
//

#import "EmployeeListResponse.h"
#import "Employee.h"
#import "ModuleConstants.h"

NS_ASSUME_NONNULL_BEGIN

@implementation EmployeeListResponse

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        NSArray *empJSONList = dictionary[EmployeeListResponseEmployeesKey];
        if (empJSONList && [empJSONList isKindOfClass:[NSArray class]]) {
            NSMutableArray *empList = [NSMutableArray array];
            for (NSDictionary *empJSONObj in empJSONList) {
                Employee *employee = [[Employee alloc] initWithDictionary:empJSONObj];
                [empList addObject:employee];
            }
            _employees = [empList copy];
        }
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
