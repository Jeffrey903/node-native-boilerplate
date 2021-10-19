#include "functions.h"
#import <Cocoa/Cocoa.h>

@interface BorderViewController : NSViewController

@end

@implementation BorderViewController

- (void)loadView
{
    self.view = [[NSView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSBox *box = [[NSBox alloc] init];
    box.boxType = NSBoxCustom;
    box.borderColor = [NSColor colorWithRed:190.0/255.0 green:250.0/255.0 blue:0.0 alpha:1.0];
    box.borderWidth = 4;
    box.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:box];

    [NSLayoutConstraint activateConstraints:@[
        [box.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [box.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [box.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [box.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

@end

@interface BorderWindowController : NSWindowController

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation BorderWindowController

- (instancetype)init
{
    BorderViewController *borderViewController = [[BorderViewController alloc] init];
    NSWindow *window = [NSWindow windowWithContentViewController:borderViewController];
    window.styleMask = NSWindowStyleMaskBorderless;
    window.opaque = NO;
    window.backgroundColor = [NSColor clearColor];
    window.collectionBehavior = NSWindowCollectionBehaviorTransient;

    self = [super initWithWindow:window];
    if (self) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(positionWindow) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)show
{
    NSLog(@"AAAZZZ show");
    // [self.window setFrame:NSMakeRect(1000, 500, 300, 300) display:YES];
    // [self showWindow:nil];
    // // [self.window orderFrontRegardless];
    // [self.window makeKeyAndOrderFront:nil];
    NSLog(@"AAAZZZ show done");
}

- (void)positionWindow
{
    NSArray<NSDictionary<NSString *, id> *> *windowList = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID));

    NSMutableArray<NSDictionary<NSString *, id> *> *matchingWindows = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *window in windowList) {
        NSString *ownerName = window[(__bridge NSString *)kCGWindowOwnerName];
        if ([ownerName isEqual:@"System Preferences"]) {
            [matchingWindows addObject:window];
        }
    }

    // Find the appropriate System Preferences window (multiple System Preferences windows
    // may exist, such as when a second smaller window is created during user authentication,
    // so choose the largest System Preferences window by overall size)
    [matchingWindows sortedArrayUsingComparator:^NSComparisonResult(NSDictionary<NSString *, id> *window1, NSDictionary<NSString *, id> *window2) {
        CFDictionaryRef bounds1 = (__bridge CFDictionaryRef)(window1[(__bridge NSString *)kCGWindowBounds]);
        CFDictionaryRef bounds2 = (__bridge CFDictionaryRef)(window2[(__bridge NSString *)kCGWindowBounds]);

        CGRect rect1 = CGRectZero;
        CGRect rect2 = CGRectZero;
        CGRectMakeWithDictionaryRepresentation(bounds1, &rect1);
        CGRectMakeWithDictionaryRepresentation(bounds2, &rect2);

        return rect1.size.width * rect1.size.height > rect2.size.width * rect2.size.height ? NSOrderedAscending : NSOrderedDescending;
    }];

    NSDictionary<NSString *, id> *window = matchingWindows.firstObject;
    if (!window) {
        [self close];
        return;
    }

    CFNumberRef windowNumber = (__bridge CFNumberRef)(window[(__bridge NSString *)kCGWindowNumber]);
    CFDictionaryRef bounds = (__bridge CFDictionaryRef)(window[(__bridge NSString *)kCGWindowBounds]);
    CGRect rect = CGRectZero;
    CGRectMakeWithDictionaryRepresentation(bounds, &rect);
    // AAAZZZ update this for multi-monitor
    NSScreen *screen = [NSScreen screens].firstObject;

    CGRect frame = rect;
    // Adjust origin.y from CGRect to NSRect coordinate system
    frame.origin.y = screen.frame.size.height - frame.origin.y - frame.size.height;

    CGRect borderFrame = CGRectInset(frame, -5.0, -5.0);
    if (!CGRectEqualToRect(self.window.frame, borderFrame)) {
        [self.window setFrame:borderFrame display:YES];
    }
    [self showWindow:nil];
    [self.window orderWindow:NSWindowAbove relativeTo:((__bridge NSNumber *)windowNumber).integerValue];
}

@end

//

Nan::Persistent<v8::Function> WindowController::constructor;

NAN_MODULE_INIT(WindowController::Init) {
  v8::Local<v8::FunctionTemplate> tpl = Nan::New<v8::FunctionTemplate>(New);
  tpl->SetClassName(Nan::New("WindowController").ToLocalChecked());
  tpl->InstanceTemplate()->SetInternalFieldCount(1);

  Nan::SetPrototypeMethod(tpl, "show", Show);

  constructor.Reset(Nan::GetFunction(tpl).ToLocalChecked());
  Nan::Set(target, Nan::New("WindowController").ToLocalChecked(), Nan::GetFunction(tpl).ToLocalChecked());
}

WindowController::WindowController(pid_t windowNumber) : windowNumber_(windowNumber) {
}

WindowController::~WindowController() {
}

NAN_METHOD(WindowController::New) {
  if (info.IsConstructCall()) {
    pid_t windowNumber = info[0]->IsUndefined() ? 0 : Nan::To<double>(info[0]).FromJust();
    WindowController *obj = new WindowController(windowNumber);
    obj->Wrap(info.This());
    info.GetReturnValue().Set(info.This());
  } else {
    const int argc = 1;
    v8::Local<v8::Value> argv[argc] = {info[0]};
    v8::Local<v8::Function> cons = Nan::New(constructor);
    info.GetReturnValue().Set(Nan::NewInstance(cons, argc, argv).ToLocalChecked());
  }
}

NAN_METHOD(WindowController::Show) {
  WindowController* obj = Nan::ObjectWrap::Unwrap<WindowController>(info.This());
  // obj->value_ += 1;
  // info.GetReturnValue().Set(obj->value_);
  // [obj->windowController_ show];

  // [[[BorderWindowController alloc] init] show];

  BorderWindowController *bwc = [[BorderWindowController alloc] init];
  obj->windowController_ = bwc;
  [bwc show];

  // dispatch_after(2.0, dispatch_get_main_queue(), ^{
    info.GetReturnValue().Set(obj->windowNumber_);
  // });
}
