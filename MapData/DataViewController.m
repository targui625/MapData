//
//  DataViewController.m
//  MapData
//
//  Created by Norimichi Takagi on 2016/01/14.
//  Copyright © 2016年 NorimichiTakagi. All rights reserved.
//

#import "DataViewController.h"
#import "CustomAnnotation.h"
#import "MapViewController.h"

@interface DataViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *backbutton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

// 位置記録用
@property (assign, nonatomic) CLLocationDegrees longitude;
@property (assign, nonatomic) CLLocationDegrees latitude;

- (IBAction)backButtonAction:(id)sender;
- (IBAction)editButtonAction:(id)sender;

@property (strong, nonatomic) NSMutableArray *annotationArray;

@end

@implementation DataViewController

- (void)viewDidLoad {
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    NSMutableData *data = [nd objectForKey:@"annotationData"];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    self.annotationArray = [[decoder decodeObjectForKey:@"annotation"] mutableCopy];
    [decoder finishDecoding];
    
    if (self.annotationArray == nil) {
        self.annotationArray = [NSMutableArray arrayWithCapacity:0];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.annotationArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = [self.annotationArray[indexPath.row] title];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.latitude = [self.annotationArray[indexPath.row] coordinate].latitude;
    self.longitude = [self.annotationArray[indexPath.row] coordinate].longitude;
    
    [self performSegueWithIdentifier:@"ExitDataView" sender:self];
}

- (IBAction)backButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editButtonAction:(id)sender {
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.annotationArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [encoder encodeObject:[self.annotationArray copy] forKey:@"annotation"];
        [encoder finishEncoding];
        [nd setObject:data forKey:@"annotationData"];
        [nd synchronize];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ExitDataView"]) {
        
        MapViewController *prevViewController = [segue destinationViewController];
        prevViewController.isLocation = YES;
        prevViewController.latitude = self.latitude;
        prevViewController.longitude = self.longitude;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
