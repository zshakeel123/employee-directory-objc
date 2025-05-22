//
//  EmployeeNetworkingConstants.m
//  EmployeeNetworking
//
//  Created by Zeeshan Shakeel on 22/05/2025.
//

#import "ModuleConstants.h"

NS_ASSUME_NONNULL_BEGIN

// Top-level response key
NSString *const EmployeeListResponseEmployeesKey = @"employees";

// Employee object keys
NSString *const EmployeeUUIDKey = @"uuid";
NSString *const EmployeeFullNameKey = @"full_name";
NSString *const EmployeePhoneNumberKey = @"phone_number";
NSString *const EmployeeEmailAddressKey = @"email_address";
NSString *const EmployeeBiographyKey = @"biography";
NSString *const EmployeePhotoURLSmallKey = @"photo_url_small";
NSString *const EmployeePhotoURLLargeKey = @"photo_url_large";
NSString *const EmployeeTeamKey = @"team";
NSString *const EmployeeTypeKey = @"employee_type";

// Employee type string values for enum mapping
NSString *const EmployeeTypeFullTimeString = @"FULL_TIME";
NSString *const EmployeeTypePartTimeString = @"PART_TIME";
NSString *const EmployeeTypeContractorString = @"CONTRACTOR";

NS_ASSUME_NONNULL_END
