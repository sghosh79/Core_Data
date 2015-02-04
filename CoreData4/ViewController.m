//
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initModelcontext];
    [self reloadDataFromContext];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark CoreData operations

-(void)initModelcontext {
    
    self.model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    //An NSManagedObjectModel object describes a schema—a collection of entities (data models) that you use in your application.
    //mergedModelFromBundles returns a model created by merging all the models found in given bundles. Parameter: An array of instances of NSBundle to search. If you specify nil, then the main bundle is searched.
    
    self.psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    //initWithManagedObjectModel initializes the receiver with a managed object model. Parameters: a managed object model. Returns: The receiver, initialized with model.
    
    
    NSArray *documentsDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [documentsDirectories objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"store.data"];
   
    NSLog(@"Path is %@", path);
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    
    if (![self.psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
      //- (NSPersistentStore *)addPersistentStoreWithType:(NSString *)storeType configuration:(NSString *)configuration URL:(NSURL *)storeURL options:(NSDictionary *)options error:(NSError **)error
    // Description: Adds a new persistent store of a specified type at a given location, and returns the new store.
        
        //Parameters:storeType - A string constant (such as NSSQLiteStoreType) that specifies the store type—see Store Types for possible values.
        //    configuration - The name of a configuration in the receiver's managed object model that will be used by the new store. The configuration can be nil, in which case no other configurations are allowed.
        //  storeURL - The file location of the persistent store.
        //    options - A dictionary containing key-value pairs that specify whether the store should be read-only, and whether (for an XML store) the XML file should be validated against the DTD before it is read. For key definitions, see “Store Options” and “Migration Options”. This value may be nil.
        //  error - If a new store cannot be created, upon return contains an instance of NSError that describes the problem
         //   If a new store cannot be created, upon return contains an instance of NSError that describes the problem

        //Returns: The newly-created store or, if an error occurs, nil.
        
        
     //NSSQLiteStoreType description: The SQLite database store type.
        
        [NSException raise:@"Open Failed" format:@"Reason: %@",[error localizedDescription]];
    } //localizedDescription: Returns a string containing the localized description of the error. This method can be overridden by subclasses to present customized error strings.
    
    self.context = [[NSManagedObjectContext alloc] init];
    self.context.undoManager = [[NSUndoManager alloc] init];
    self.context.persistentStoreCoordinator = self.psc;
}

-(void)reloadDataFromContext {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    //An instance of NSFetchRequest describes search criteria used to retrieve data from a persistent store.
    
    //NSEntityDescription - An NSEntityDescription object describes an entity in Core Data. Entities are to managed objects what Class is to id, or—to use a database analogy—what tables are to rows. An instance specifies an entity’s name, its properties (its attributes and relationships, expressed by instances of NSAttributeDescription and NSRelationshipDescription) and the class by which it is represented.
    
    NSEntityDescription *entity = [[self.model entitiesByName] objectForKey:@"Employee"];
    request.entity = entity;
    
    //Declaration: var entitiesByName: NSDictionary! { get }
    //Description: Returns the entities of the receiver in a dictionary.
    //Returns: The entities of the receiver in a dictionary, where the keys in the dictionary are the names of the corresponding entities.
    
    
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortByName];
  
    //Description: an instance of NSSortDescriptor describes a basis for ordering objects by specifying the property to use to compare the objects, the method to use to compare the properties, and whether the comparison should be ascending or descending. Instances of NSSortDescriptor are immutable

    //- (instancetype)initWithKey:(NSString *)keyPath ascending:(BOOL)ascending: Description returns an NSSortDescriptor object initialized with a given property key path and sort order, and with the default comparison selector.
    //Parameters: keyPath - the property key to use when performing a comparison. In the comparison, the property is accessed using key-value coding (see Key-Value Coding Programming Guide).  ascending- YES if the receiver specifies sorting in ascending order, otherwise NO.
    
    //var sortDescriptors: AnyObject[] - Description: sets the array of sort descriptors of the receiver. Parameters: sortDescriptors - the array of sort descriptors of the receiver. nil specifies no sort descriptors.
    //Returns - The sort descriptors of the receiver.
    
    NSError *error = nil;
    NSArray *result = [self.context executeFetchRequest:request error:&error];

    //executeFetchRequest: - (NSArray *)executeFetchRequest:(NSFetchRequest *)request error:(NSError **)error
    //Description: Returns an array of objects that meet the criteria specified by a given fetch request. Returned objects are registered with the receiver.
    //Parameters: request - a fetch request that specifies the search criteria for the fetch. error - If there is a problem executing the fetch, upon return contains an instance of NSError that describes the problem.
    //Returns: An array of objects that meet the criteria specified by request fetched from the receiver and from the persistent stores associated with the receiver’s persistent store coordinator. If an error occurs, returns nil. If no objects match the criteria specified by request, returns an empty array.
    
    
    if (!result) {
        [NSException raise:@"Fetch failed." format:@"Reason: %@",[error localizedDescription]];
    }
    
    self.employees = [[NSMutableArray alloc] initWithArray:result];
    self.educationRecords = [[NSMutableArray alloc] init];
    
    //id is a pointer to an instance of a class.
    for (id emp in self.employees) {
        [self.educationRecords addObject:[emp relationship]];
    }
    
    [self.tableView reloadData];
    [self.tableViewEducation reloadData];
}

-(void)createEmployeeWithEmpID:(NSNumber*)empID name:(NSString*)name location:(NSString*)location {
    
    Employee *employee = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:self.context];
    employee.empID = empID;
    employee.name = name;
    employee.location = location;
    [self.employees addObject:employee];
    
    Education *educationRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Education" inManagedObjectContext:self.context];
    educationRecord.relationship = employee;
    educationRecord.highSchool = [NSNumber numberWithBool:[self.switchHighSchool isOn]];
    educationRecord.undergraduate = [NSNumber numberWithBool:self.switchUndergraduate.on];
    educationRecord.masters = [NSNumber numberWithBool:self.switchGraduate.on];
    educationRecord.doctorate = [NSNumber numberWithBool:[self.switchDoctorate isOn]];
    
    //+ (NSNumber *)numberWithBool:(BOOL)value - Creates and returns an NSNumber object containing a given value, treating it as a BOOL.
    // Parameters: value - The value for the new number;
    // Returns: An NSNumber object containing value, treating it as a BOOL.
    
    [self.educationRecords addObject:educationRecord];
    
    [self reloadDataFromContext];
}




#pragma mark UIButton methods

- (IBAction)addEmployee:(id)sender {
    
    if (![self.textName.text isEqualToString:@""] && ![self.textLocation.text isEqualToString:@""]) {
        NSNumber *empID = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
        [self createEmployeeWithEmpID:empID name:self.textName.text location:self.textLocation.text];
        [self.view endEditing:YES];
    }
    
    self.textName.text = @"";
    self.textLocation.text = @"";
}

- (IBAction)submitChanges:(id)sender {
    
    if (!editingMode) {
        self.textNameEdit.text = @"";
        self.textLocationEdit.text = @"";
        return;
    }
    Employee *employee = [self.employees objectAtIndex:selectedEmployeeIndex];
    employee.name = self.textNameEdit.text;
    employee.location = self.textLocationEdit.text;
    self.textNameEdit.text = @"";
    self.textLocationEdit.text = @"";
    [self reloadDataFromContext];
    
    editingMode = NO;
    
    [self.view endEditing:YES];
    
    [self reloadDataFromContext];
    
}

- (IBAction)editList:(id)sender {
    
    self.tableView.editing = !self.tableView.editing;
    if ([self.tableView isEditing]) {
        [sender setTitle:@"Done" forState:UIControlStateNormal];
    } else {
        [sender setTitle:@"Edit List" forState:UIControlStateNormal];
    }
    
}

- (IBAction)undo:(id)sender {
    
    [self.context undo];
    [self reloadDataFromContext];
    
}

- (IBAction)redo:(id)sender {
    
    [self.context redo];
    [self reloadDataFromContext];
    
}

- (IBAction)rollbackAll:(id)sender {
    
    [self.context rollback];
    [self reloadDataFromContext];
    
}

- (IBAction)saveEmployeesToDisk:(id)sender {
    
    NSError *error = nil;
    BOOL success;
    success = [self.context save:&error];
    if (!success) {
        [NSException raise:@"Failed to save to disk" format:@"Reason: %@",[error localizedDescription]];
    }
    
}

- (IBAction)removeAllEmployees:(id)sender {
    
    editingMode = NO;
    self.textNameEdit.text = @"";
    self.textLocationEdit.text = @"";
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:self.context];
    NSArray *result = [self.context executeFetchRequest:request error:&error];
    if (!result) {
        [NSException raise:@"Failed to remove all employees" format:@"Reason: %@",[error localizedDescription]];
    }
    
    for (id employee in result) {
        [self.context deleteObject:employee];
    }
    
    [self reloadDataFromContext];
}



#pragma mark table view methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.employees count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusableCell"];
    
    
    if (tableView == self.tableView) {
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reusableCell"];
        }
        Employee *employee = [self.employees objectAtIndex:indexPath.row];
        cell.textLabel.text = employee.name;
        cell.detailTextLabel.text = employee.location;
        
    } else {
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reusableCell"];
        }
        Education *educationRecord = [self.educationRecords objectAtIndex:indexPath.row];

        if ([educationRecord.doctorate boolValue]) {
            cell.textLabel.text = @"Doctorate";
        } else if ([educationRecord.masters boolValue]) {
            cell.textLabel.text = @"Masters";
        } else if ([educationRecord.undergraduate boolValue]) {
            cell.textLabel.text = @"Bachelors";
        } else if ([educationRecord.highSchool boolValue]) {
            cell.textLabel.text = @"High School Diploma";
        } else {
            cell.textLabel.text = @"";
        }
        cell.textLabel.textAlignment = NSTextAlignmentRight;
    }
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    selectedEmployeeIndex = indexPath.row;
    editingMode = YES;
    Employee *employee = [self.employees objectAtIndex:indexPath.row];
    self.textNameEdit.text = employee.name;
    self.textLocationEdit.text = employee.location;
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Employee *employee = [self.employees objectAtIndex:indexPath.row];
        
        self.textNameEdit.text = @"";
        self.textLocationEdit.text = @"";
        editingMode = NO;
        self.tableView.editing = NO;
        [self.editListButton setTitle:@"Edit List" forState:UIControlStateNormal];
        
        [self.context deleteObject:employee];
        
        [self reloadDataFromContext];
    }
    
}

@end












