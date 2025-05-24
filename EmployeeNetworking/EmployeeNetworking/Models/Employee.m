//
//  Employee.m
//  EmployeeNetworking
//
//  Created by Zeeshan Shakeel on 22/05/2025.
//

#import "Employee.h"
#import "ModuleConstants.h"
#import "Utils.h"


NS_ASSUME_NONNULL_BEGIN

@implementation Employee

- (EmployeeType)parseEmployeeTypeForKey:(NSString *)key fromDictionary:(NSDictionary *)dictionary {
    NSString* typeString = dictionary[key];
    
    if (typeString == nil)
    {
        return EmployeeTypeUnknown;
    }
    
    if ([typeString isEqualToString:EmployeeTypeFullTimeString]) {
        return EmployeeTypeFullTime;
    } else if ([typeString isEqualToString:EmployeeTypePartTimeString]) {
        return EmployeeTypePartTime;
    } else if ([typeString isEqualToString:EmployeeTypeContractorString]) {
        return EmployeeTypeContractor;
    } else {
        return EmployeeTypeUnknown;
    }
}

- (instancetype) initWithDictionary:(NSDictionary* )dictionary {
    self  = [super init];
    
    if(self) {
        _uuid = [Utils parseStringValueForKey:EmployeeUUIDKey fromDictionary:dictionary];
        _fullName = [Utils parseStringValueForKey:EmployeeFullNameKey fromDictionary:dictionary];
        _emailAddress = [Utils parseStringValueForKey:EmployeeEmailAddressKey fromDictionary:dictionary];
        _team = [Utils parseStringValueForKey:EmployeeTeamKey fromDictionary:dictionary];
        _phoneNumber = [Utils parseStringValueForKey:EmployeePhoneNumberKey fromDictionary:dictionary];
        _biography = [Utils parseStringValueForKey:EmployeeBiographyKey fromDictionary:dictionary];
        _photoUrlSmall = [Utils parseStringValueForKey:EmployeePhotoURLSmallKey fromDictionary:dictionary];
        _photoUrlLarge = [Utils parseStringValueForKey:EmployeePhotoURLLargeKey fromDictionary:dictionary];
        
        _employeeType = [self parseEmployeeTypeForKey:EmployeeTypeKey fromDictionary:dictionary];
    }
    
    return self;
}

- (BOOL)isValidEmployee {
    // Based on your requirement: If any employee is malformed, it is fine to invalidate the entire list of employees in the response - "Lets assume if any employee doesn’t have the Full Name, Team, or Email", then it is invalid and the whole list later will be considered malformed.
    return (self.fullName.length > 0 &&
            self.team.length > 0 &&
            self.emailAddress.length > 0);
}

@end

NS_ASSUME_NONNULL_END
