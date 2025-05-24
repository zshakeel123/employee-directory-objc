//
//  Employee.h
//  EmployeeNetworking
//
//  Created by Zeeshan Shakeel on 22/05/2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EmployeeType){
    EmployeeTypeFullTime,
    EmployeeTypePartTime,
    EmployeeTypeContractor,
    EmployeeTypeUnknown
};

@interface Employee : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong, nullable) NSString *phoneNumber;
@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong, nullable) NSString *biography;
@property (nonatomic, strong, nullable) NSString *photoUrlSmall;
@property (nonatomic, strong, nullable) NSString *photoUrlLarge;
@property (nonatomic, strong) NSString *team;
@property (nonatomic, assign) EmployeeType employeeType;

// initializer to easily create an Employee object from a dictionary
- (instancetype) initWithDictionary:(NSDictionary* )dictionary;

// Utility functions
- (EmployeeType)parseEmployeeTypeForKey:(NSString *)key fromDictionary:(NSDictionary *)dictionary;

/**
 * @brief Checks if the employee object has all required fields for display.
 * @return YES if all required fields are present and valid, NO otherwise.
 */
- (BOOL)isValidEmployee;

@end

NS_ASSUME_NONNULL_END
