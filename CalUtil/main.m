//
//  main.m
//  CalUtil
//
//  Created by Roger Herikstad on 15/1/12.
//  Copyright 2012 NUS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CalendarStore/CalendarStore.h>

int main (int argc, const char * argv[])
{

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //parse the input parameters
    //user userDefaults for that
    NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
    NSString *calName = [args stringForKey:@"calName"];
    //get the defaults calendar
    NSArray *calendars = [[CalCalendarStore defaultCalendarStore] calendars];
    //check if the requested calendar exists
    NSArray *matches = [calendars filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"title==%@",calName]];
    //did we find one
    if([matches count]==0)
    {
        printf("No calendar matching %s found. Exiting...\n",[calName UTF8String]);
        [pool drain];
        return 0;
    }
    //select the first match
    CalCalendar *cal = [matches objectAtIndex:0];
    //get the date
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateFormat: @"dd/MM/yyyy 'at' hh:mm"];
    NSString *sdate = [args stringForKey:@"startDate"];
    //NSLog(@"Start date: %@",[dateFormat stringFromDate: [dateFormat dateFromString:sdate]]);
    NSString *edate = [args stringForKey:@"endDate"];
    //NSLog(@"End date: %@",edate);
    //get the title
    NSString *stitle = [args stringForKey:@"title"];
    NSString *loc = [args stringForKey:@"location"];
    //create the event
    CalEvent *event = [CalEvent event];
    event.calendar = cal;
    event.title = stitle;
    event.startDate = [dateFormat dateFromString:sdate];
    event.endDate = [dateFormat dateFromString:edate];
    event.location = loc;
    //save the event
    NSError *calError;
    if ([[CalCalendarStore defaultCalendarStore] saveEvent:event span:CalSpanThisEvent error:&calError] == NO)
    {
        printf("Could not save event\n");
    }
    else
    {
        printf("Event created\n");
    }
    [pool drain];
    return 0;
}

