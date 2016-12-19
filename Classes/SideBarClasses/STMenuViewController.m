//
//  STMenuViewController.m
//  MobileBanking
//
//  Created by Kurochkin on 20/01/14.
//  Copyright (c) 2014 BPC. All rights reserved.
//

#import "STMenuViewController.h"
#import "DSPF_SideMenuCell.h"

@interface MutableBooleanStorage : NSObject
@property (nonatomic, assign) BOOL boolValue;
@end

@implementation MutableBooleanStorage
@end

@interface STMenuViewController ()

@end

@implementation STMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)dealloc
{
    [_menuCell release];
    [_tableView release];
    [_layoutView release];
    [_viewConstraint release];
    [_menuDataSource release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        _viewConstraint.constant = 0;
        _layoutView.hidden = YES;

    }
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bok_menu_bg.png"]];
        self.tableView.backgroundView = backgroundImage;
    }
    
    self.tableView.tableHeaderView = self.menuDataSource.headerView;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)viewDidUnload
{
    [_itemsMyBanking release];
    [_itemsTools release];
    [self setMenuCell:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menuDataSource.cells.count;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( section == 0 && _itemsMyBanking.count == 0 )
        return 0;
    if ( section == 1 && _itemsTools.count == 0 )
        return 0;
    return 25.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 8.0f;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   // if ( section == 0 && _itemsMyBanking.count > 0 )
     //   return NSLocalizedString(@"My Banking", @"Menu sections");
    //else
      //  if ( section == 1 && _itemsTools.count > 0 )
        //    return NSLocalizedString(@"Tools", @"Menu sections");
    
    return Nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *headerIdentifier = @"TWMenuHeader";
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    
    // Configure the cell...
    if (header == nil)
    {
        header = [[[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerIdentifier] autorelease];
        //header.tintColor = self.tableView.backgroundColor;
        //header.contentView.backgroundColor = [UIColor colorWithRed:62/255.0 green:69/255.0 blue:88/255.0 alpha:1.0];
        header.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sidebar-bg-header"]] autorelease];
        header.textLabel.textColor = [UIColor colorWithRed:155.0/255.0 green:164.0/255.0 blue:178.0/255.0 alpha:1.0];
        header.textLabel.shadowOffset = CGSizeMake(1, 1);
        header.textLabel.shadowColor = [UIColor blackColor];
        header.textLabel.adjustsFontSizeToFitWidth = NO;
        header.textLabel.font = [UIFont systemFontOfSize:6.0];
        
        NSString *sectionTitle = nil;
        if (section == 0)
            sectionTitle = [NSLocalizedString(@"My Banking", @"Menu sections") uppercaseString];
        else
            sectionTitle = [NSLocalizedString(@"Tools", @"Menu sections") uppercaseString];
        

        UILabel *label = [[[UILabel alloc] init] autorelease];
        label.frame = CGRectMake(20, 0, 284, 23);
        label.textColor = [UIColor colorWithRed:155.0/255.0 green:164.0/255.0 blue:178.0/255.0 alpha:1.0];
        label.font = [UIFont fontWithName:@"HelveticaNeue-thin" size:19];
        label.text = sectionTitle;
        label.backgroundColor = [UIColor clearColor];
        [header.contentView addSubview:label];
        
        if (section == 0)
        {
            UIView *upperSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 258, 1)];
            upperSeparator.backgroundColor = [UIColor colorWithRed:36.0/255.0 green:42.0/255.0 blue:55.0/255.0 alpha:1.0];
            [header addSubview:upperSeparator];
            [upperSeparator release];
        }
        
        UIView *downSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 25, 258, 1)];
        downSeparator.backgroundColor = [UIColor colorWithRed:36.0/255.0 green:42.0/255.0 blue:55.0/255.0 alpha:1.0];
        [header addSubview:downSeparator];
        [downSeparator release];
    
    }
    return header;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    static NSString *footerIdentifier = @"STMenuFooter";
    UITableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerIdentifier];
    
    // Configure the cell...
    if (footer == nil)
    {
        footer = [[[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:footerIdentifier] autorelease];
        //footer.tintColor = self.tableView.backgroundColor;
        footer.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sidebar-bg-footer.png"]] autorelease];
    }
    return footer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _menuDataSource.cells[indexPath.row];
}


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DSPF_SideMenuCell *sideCell = (DSPF_SideMenuCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (sideCell.cellAction)
        sideCell.cellAction();
}


@end
