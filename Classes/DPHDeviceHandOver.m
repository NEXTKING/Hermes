//
//  DPHDeviceHandOver.m
//  dphHermes
//
//  Created by Tomasz Krasnyk on 08.10.15.
//
//

#import "DPHDeviceHandOver.h"
#import "DSPF_Error.h"
#import "DSPF_StatusReady.h"
#import "DSPF_Synchronisation.h"
#import "DSPF_Finish.h"

static NSString * const DPHDeviceHandOverProcessingDeviceHandOverKey = @"processingDeviceHandOver";
static NSString * const DPHUploadResponseDeviceHasPendingPushNotifcations = @"DEVICE_HAS_PENDING_PUSHNOTIFICATIONS";
static NSString * const DPHUploadResponseDeviceHasPendingDeviceSynchronisations = @"DEVICE_HAS_PENDING_DEVICESYNCHRONIZATIONS";
static NSString * const DPHUploadResponseDeviceHasErrorsInDeviceSynchronisations = @"DEVICE_HAS_ERRORS_IN_DEVICESYNCHRONIZATIONS";

@interface DPHDeviceHandOver()
@property (nonatomic, assign) BOOL processingDeviceHandOver;
@property (nonatomic, strong) DSPF_Activity *activityView;
@end

@implementation DPHDeviceHandOver
@synthesize processingDeviceHandOver;
@synthesize activityView;

- (instancetype)init {
    if ((self = [super init])) {
        self.processingDeviceHandOver = NO;
        
        [[AppDelegate() syncDataManager] addObserver:self forKeyPath:SVR_SyncDataManagerStatusKey
                                                  options:NSKeyValueObservingOptionNew context:(__bridge void *)(SVR_SyncDataManagerStatusKey)];
        [self addObserver:self forKeyPath:DPHDeviceHandOverProcessingDeviceHandOverKey
                  options:NSKeyValueObservingOptionNew context:(__bridge void *)(DPHDeviceHandOverProcessingDeviceHandOverKey)];
    }
    return self;
}

- (void) tryHandingDeviceOver {
    if ([[AppDelegate() syncDataManager] unsynchronizedTraceLogsCount] > 0 && !self.processingDeviceHandOver) {
        self.processingDeviceHandOver = YES;
        // synchronize everything
        NSDictionary *userInfo = @{ SyncTaskActivityMessageKey : @"" };
        [SVR_SyncDataManager triggerSendingTraceLogDataOnlyWithUserInfo:userInfo];
        [self performSelector:@selector(tryHandingDeviceOver) withObject:nil afterDelay:10];
    } else {
        NSString *messageTitle = NSLocalizedString(@"TITLE_136", @"Gerät-Übergabe");
        if ([[AppDelegate() syncDataManager] unsynchronizedTraceLogsCount] > 0 && self.processingDeviceHandOver) {
            self.processingDeviceHandOver = NO;
            // we tried to synchronize everything but we could not somehow (no internet access or similar)
            NSString *message = NSLocalizedString(@"MESSAGE_053", @"Die Gerät-Übergabe konnte nicht erforlgreich abgeschlossen werden, da nicht alle Daten synchronisiert wurden. Bitte stellen Sie sicher, dass Sie eine Internet-Verbindung haben und versuchen Sie erneut.");
            [DSPF_Error messageTitle:messageTitle messageText:message delegate:nil cancelButtonTitle:NSLocalizedString(@"TITLE_101", @"OK")];
        } else if ([[AppDelegate() syncDataManager] unsynchronizedTraceLogsCount] == 0) {
            NSString *serverURL  = [DSPF_Synchronisation hermesServerURL];
            NSDictionary *syncToServer = [NSDictionary dictionary];
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/upload/device_handover?sn=%@", serverURL, PFDeviceId()]];
            NSMutableURLRequest *request = [SVR_SyncDataManager requestFromDictionary:syncToServer url:url];
            NSHTTPURLResponse *response = nil;
            NSError *error = nil;
            NSData   *returnData   = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            self.processingDeviceHandOver = NO;
            if ([returnString isEqualToString:@"OK"] || [response statusCode] == 200) {
                [NSUserDefaults clearTourDataCache];
                [ctx() deleteObjects:[Transport withPredicate:nil inCtx:ctx()]];
                [ctx() deleteObjects:[Transport_Group withPredicate:nil inCtx:ctx()]];
                [ctx() deleteObjects:[Transport_Box withPredicate:nil inCtx:ctx()]];
                [ctx() saveIfHasChanges];
                [DSPF_Finish finishTourWithDepartures:[Departure departuresOfCurrentlyDrivenTourInCtx:ctx()]];
                
                NSString *message = NSLocalizedString(@"MESSAGE_052", @"Die Gerät-Übergabe wurde erfolgreich abgeschlossen. Sie werden jetzt abgemeldet.");
                [DSPF_StatusReady messageTitle:messageTitle messageText:message item:nil delegate:self
                             cancelButtonTitle:nil otherButtonTitle:NSLocalizedString(@"TITLE_101", @"OK")];
            } else {
                NSString *errorString = [response.allHeaderFields objectForKey:@"X-Hermes-ServiceError"];
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_020", @"ACHTUNG:\nDer Server meldete folgendes Problem: %@!\nDie Daten wurden nicht gespeichert."), returnString];
                if ([errorString isEqualToString:DPHUploadResponseDeviceHasPendingPushNotifcations]) {
                    message = NSLocalizedString(@"ERROR_MESSAGE__022", @"Da das Gerät ausstehende Push-Notifications hat, ist die Gerät-Übergabe nicht möglich. Antworten Sie danach und versuchen erneut.");
                } else if ([errorString isEqualToString:DPHUploadResponseDeviceHasPendingDeviceSynchronisations]) {
                    message = NSLocalizedString(@"ERROR_MESSAGE__023", @"Da noch nicht alle Daten von dem Gerät auf dem Server bearbeitet sind, ist die Gerät-Übergabe nicht möglich. Versuchen Sie in kurzem erneut.");
                } else if ([errorString isEqualToString:DPHUploadResponseDeviceHasErrorsInDeviceSynchronisations]) {
                    message = NSLocalizedString(@"ERROR_MESSAGE__024", @"Da nicht alle Daten von dem Gerät auf dem Server erfolgreich bearbeitet sind, ist die Gerät-Übergabe nicht möglich.";);
                } else {
                    message = [NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_020", @"ACHTUNG:\nDer Server meldete folgendes Problem: %@!\nDie Daten wurden nicht gespeichert."), errorString];
                }
                [DSPF_Error messageTitle:messageTitle messageText:message delegate:nil cancelButtonTitle:NSLocalizedString(@"TITLE_101", @"OK")];
            }
        }
    }
}

- (void) dspf_StatusReady:(DSPF_StatusReady *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )item
          withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) clickedButtonIndex
{
    if ([(UIAlertView*)[sender alertView] cancelButtonIndex] != clickedButtonIndex) {
        HermesAppDelegate *appDelegate = (HermesAppDelegate *) [[UIApplication sharedApplication] delegate];
        UINavigationController *navigationController = (UINavigationController *)[[appDelegate window] rootViewController];
        [navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSAssert([NSThread mainThread] == [NSThread currentThread], @"Ooops, the status updates are not delivered in main thread");
    if (context == (__bridge void *)SVR_SyncDataManagerStatusKey) {
        if ([[AppDelegate() syncDataManager] status] == SVR_SyncDataManagerStatusIdle && self.processingDeviceHandOver) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self tryHandingDeviceOver];
        }
    } else if (context == (__bridge void *)(DPHDeviceHandOverProcessingDeviceHandOverKey)) {
        if (self.processingDeviceHandOver && self.activityView == nil) {
            activityView = [DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_003", @"Datenübertragung") messageText:nil cancelButtonTitle:nil delegate:nil];
        } else if (!self.processingDeviceHandOver && self.activityView) {
            [self.activityView closeActivityInfo];
            self.activityView = nil;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    [[AppDelegate() syncDataManager] removeObserver:self forKeyPath:SVR_SyncDataManagerStatusKey];
    [self removeObserver:self forKeyPath:DPHDeviceHandOverProcessingDeviceHandOverKey];
}

@end
