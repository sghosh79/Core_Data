//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Employee.h"
#import "Education.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    BOOL editingMode;
    BOOL selectedEmployeeIndex;
}

//text fields
@property (weak, nonatomic) IBOutlet UITextField *textName;
@property (weak, nonatomic) IBOutlet UITextField *textNameEdit;
@property (weak, nonatomic) IBOutlet UITextField *textLocation;
@property (weak, nonatomic) IBOutlet UITextField *textLocationEdit;

//buttons
@property (weak, nonatomic) IBOutlet UIButton *editListButton;


//switches
@property (weak, nonatomic) IBOutlet UISwitch *switchHighSchool;
@property (weak, nonatomic) IBOutlet UISwitch *switchUndergraduate;
@property (weak, nonatomic) IBOutlet UISwitch *switchGraduate;
@property (weak, nonatomic) IBOutlet UISwitch *switchDoctorate;

//table view
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *tableViewEducation;

//core data
@property(nonatomic)NSManagedObjectModel *model;
//An NSManagedObjectModel object describes a schema—a collection of entities (data models) that you use in your application.
@property(nonatomic)NSManagedObjectContext *context;
//An instance of NSManagedObjectContext represents a single “object space” or scratch pad in an application. Its primary responsibility is to manage a collection of managed objects. These objects form a group of related model objects that represent an internally consistent view of one or more persistent stores. A single managed object instance exists in one and only one context, but multiple copies of an object can exist in different contexts. Thus object uniquing is scoped to a particular context.
@property(nonatomic)NSPersistentStoreCoordinator *psc;
//Instances of NSPersistentStoreCoordinator associate persistent stores (by type) with a model (or more accurately, a configuration of a model) and serve to mediate between the persistent store or stores and the managed object context or contexts. Instances of NSManagedObjectContext use a coordinator to save object graphs to persistent storage and to retrieve model information.
@property(nonatomic)NSMutableArray *employees;
@property(nonatomic)NSMutableArray *educationRecords;


-(void)initModelcontext;
-(void)reloadDataFromContext;
-(void)createEmployeeWithEmpID:(NSNumber*)empID name:(NSString*)name location:(NSString*)location;


- (IBAction)addEmployee:(id)sender;
- (IBAction)submitChanges:(id)sender;
- (IBAction)editList:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;
- (IBAction)rollbackAll:(id)sender;
- (IBAction)saveEmployeesToDisk:(id)sender;
- (IBAction)removeAllEmployees:(id)sender;



@end
