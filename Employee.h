//
//  Employee.h
//  CoreData4
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Education;

@interface Employee : NSManagedObject

@property (nonatomic, retain) NSNumber * empID;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Education *relationship;

@end
