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
    if( argc == 1 )
    {
        //print a usage method
        printf("Usage: calutil -list | -calName <calname> -title <event title> -startDate <start date of event> [ -endDate <end date of event> ] -location <location> [ -repeats daily | weekly | monthly | yearly ] \n");
        return 0;
    }
    NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
    //get the available calendars
    NSArray *calendars = [[CalCalendarStore defaultCalendarStore] calendars];
    //check if we are just asking to list available calendars
    NSArray *pargs = [[NSProcessInfo processInfo] arguments];
    if([pargs containsObject:@"-list"])
    {
        printf("Available calendars:\n");
        for( CalCalendar *_cal in calendars )
        {
            printf("\t%s\n",[[_cal title] UTF8String]);
        }
        [pool drain];
        return 0;
    }
    NSString *calName = [args stringForKey:@"calName"];
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
    NSString *sdate = [args stringForKey:@"startDate"];
    NSString *edate = [args stringForKey:@"endDate"];
    NSDate *startDate,*endDate;
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    //alternative: use NSDataDetector
    NSError *dataError;
     NSDataDetector *dateDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:&dataError];
    if(sdate)
    {
        matches = [dateDetector matchesInString:sdate options:0 range:NSMakeRange(0, [sdate length])];
    
        for (NSTextCheckingResult *match in matches) 
        {
            startDate = match.date;
        }
    }
    else
    {
        printf("No start date given. Aborting...\n");
        [pool drain];
        return 0;
    }
    if(edate)
    {
        matches = [dateDetector matchesInString:edate options:0 range:NSMakeRange(0, [edate length])];
        for (NSTextCheckingResult *match in matches) 
        {
            endDate = match.date;
        }
    }
    else
    {
        //assume we want a 1 hour event
        endDate = [startDate dateByAddingTimeInterval:3600];
    }
    [dateFormat setDateFormat: @"dd/MM/yyyy 'at' hh:mm"];
    
    //NSLog(@"Start date: %@",[dateFormat stringFromDate: [dateFormat dateFromString:sdate]]);
    
    //NSLog(@"End date: %@",edate);
    //get the title
    NSString *stitle = [args stringForKey:@"title"];
    NSString *loc = [args stringForKey:@"location"];
    NSString *repeats = [args stringForKey:@"repeats"];
    
    //create the event
    CalEvent *event = [CalEvent event];
    event.calendar = cal;
    event.title = stitle;
    event.startDate = startDate;//[dateFormat dateFromString:sdate];
    event.endDate = endDate;//[dateFormat dateFromString:edate];
    event.location = loc;
    if(repeats)
    {
        //check whether we chose daily, weekly, monthly or yearly
        if([repeats isEqualToString:@"daily"])
        {
            event.recurrenceRule = [[[CalRecurrenceRule alloc] initDailyRecurrenceWithInterval:1 end:nil] autorelease];
        }
        else if( [repeats isEqualToString:@"weekly"] )
        {
            event.recurrenceRule = [[[CalRecurrenceRule alloc] initWeeklyRecurrenceWithInterval:1 end:nil] autorelease];
        }
        else if( [repeats isEqualToString:@"monthly"] )
        {
            event.recurrenceRule = [[[CalRecurrenceRule alloc] initMonthlyRecurrenceWithInterval:1 end:nil] autorelease];
        }
        else if( [repeats isEqualToString:@"yearly"] )
        {
            event.recurrenceRule = [[[CalRecurrenceRule alloc] initYearlyRecurrenceWithInterval:1 end:nil] autorelease];
        }
    }
    //save the event
    NSError *calError;
    if ([[CalCalendarStore defaultCalendarStore] saveEvent:event span:CalSpanThisEvent error:&calError] == NO)
    {
        printf("Could not save event\n");
        printf("Error code was %d\n", (int)[calError code]);
    }
    else
    {
        printf("Event created\n");
    }
    [pool drain];
    return 0;
}

