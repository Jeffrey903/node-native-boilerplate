#include "functions.h"
#import <Cocoa/Cocoa.h>

NAN_METHOD(nothing) {
}

NAN_METHOD(aString) {
    info.GetReturnValue().Set(Nan::New("This is a thing.").ToLocalChecked());
}

NAN_METHOD(aBoolean) {
    info.GetReturnValue().Set(false);
}

NAN_METHOD(aNumber) {
    info.GetReturnValue().Set(1.75);
}

NAN_METHOD(anObject) {
    v8::Local<v8::Object> obj = Nan::New<v8::Object>();
    Nan::Set(obj, Nan::New("key").ToLocalChecked(), Nan::New("value!!").ToLocalChecked());
    info.GetReturnValue().Set(obj);
}

NAN_METHOD(anArray) {
    v8::Local<v8::Array> arr = Nan::New<v8::Array>(3);
    Nan::Set(arr, 0, Nan::New(1));
    Nan::Set(arr, 1, Nan::New(2));
    Nan::Set(arr, 2, Nan::New(3));
    info.GetReturnValue().Set(arr);
}

NAN_METHOD(callback) {
    v8::Local<v8::Function> callbackHandle = info[0].As<v8::Function>();
    Nan::AsyncResource* resource = new Nan::AsyncResource(Nan::New<v8::String>("MyObject:CallCallback").ToLocalChecked());
    resource->runInAsyncScope(Nan::GetCurrentContext()->Global(), callbackHandle, 0, 0);
}

NAN_METHOD(callbackWithParameter) {
    v8::Local<v8::Function> callbackHandle = info[0].As<v8::Function>();
    Nan::AsyncResource* resource = new Nan::AsyncResource(Nan::New<v8::String>("MyObject:CallCallbackWithParam").ToLocalChecked());
    int argc = 1;
    v8::Local<v8::Value> argv[] = {
        Nan::New("parameter test").ToLocalChecked()
    };
    resource->runInAsyncScope(Nan::GetCurrentContext()->Global(), callbackHandle, argc, argv);
}

// Wrapper Impl

Nan::Persistent<v8::Function> MyObject::constructor;

NAN_MODULE_INIT(MyObject::Init) {
  v8::Local<v8::FunctionTemplate> tpl = Nan::New<v8::FunctionTemplate>(New);
  tpl->SetClassName(Nan::New("MyObject").ToLocalChecked());
  tpl->InstanceTemplate()->SetInternalFieldCount(1);

  Nan::SetPrototypeMethod(tpl, "plusOne", PlusOne);

  constructor.Reset(Nan::GetFunction(tpl).ToLocalChecked());
  Nan::Set(target, Nan::New("MyObject").ToLocalChecked(), Nan::GetFunction(tpl).ToLocalChecked());
}

MyObject::MyObject(double value) : value_(value) {
}

MyObject::~MyObject() {
}

NAN_METHOD(MyObject::New) {
  if (info.IsConstructCall()) {
    double value = info[0]->IsUndefined() ? 0 : Nan::To<double>(info[0]).FromJust();
    MyObject *obj = new MyObject(value);
    obj->Wrap(info.This());
    info.GetReturnValue().Set(info.This());
  } else {
    const int argc = 1;
    v8::Local<v8::Value> argv[argc] = {info[0]};
    v8::Local<v8::Function> cons = Nan::New(constructor);
    info.GetReturnValue().Set(Nan::NewInstance(cons, argc, argv).ToLocalChecked());
  }
}

NAN_METHOD(MyObject::PlusOne) {
  MyObject* obj = Nan::ObjectWrap::Unwrap<MyObject>(info.This());
  obj->value_ += 1;
  info.GetReturnValue().Set(obj->value_);
}

//

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

@end

@implementation BorderWindowController

+ (instancetype)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

// - (void)dealloc
// {
//   NSLog(@"AAAZZZ dealloc");
// }

- (instancetype)init
{
    BorderViewController *borderViewController = [[BorderViewController alloc] init];
    NSWindow *window = [NSWindow windowWithContentViewController:borderViewController];
    window.level = NSFloatingWindowLevel;
    // window.styleMask = NSWindowStyleMaskBorderless;
    // window.opaque = NO;
    // window.backgroundColor = [NSColor clearColor];
    // window.collectionBehavior = NSWindowCollectionBehaviorTransient;

    self = [super initWithWindow:window];
    return self;
}

- (void)show
{
    NSLog(@"AAAZZZ show");
    [self.window setFrame:NSMakeRect(1000, 500, 300, 300) display:YES];
    [self showWindow:nil];
    // [self.window orderFrontRegardless];
    [self.window makeKeyAndOrderFront:nil];
    NSLog(@"AAAZZZ show done");
}

@end

// Nan::Persistent<v8::Function> WindowController::constructor;

// NAN_MODULE_INIT(WindowController::Init) {
//   v8::Local<v8::FunctionTemplate> tpl = Nan::New<v8::FunctionTemplate>(New);
//   tpl->SetClassName(Nan::New("WindowController").ToLocalChecked());
//   tpl->InstanceTemplate()->SetInternalFieldCount(1);

//   Nan::SetPrototypeMethod(tpl, "show", Show);

//   constructor.Reset(Nan::GetFunction(tpl).ToLocalChecked());
//   Nan::Set(target, Nan::New("WindowController").ToLocalChecked(), Nan::GetFunction(tpl).ToLocalChecked());
// }

// WindowController::WindowController(void *windowController) : windowController_(windowController) {
// }

// WindowController::~WindowController() {
// }

// NAN_METHOD(WindowController::New) {
//   BorderWindowController *windowController = [[BorderWindowController alloc] init];
//   WindowController *obj = new WindowController(windowController);
//   obj->Wrap(info.This());
//   info.GetReturnValue().Set(info.This());

//   // if (info.IsConstructCall()) {
//   //   BorderWindowController *windowController = info[0]->IsUndefined() ? [[BorderWindowController alloc] init] : Nan::To<void *>(info[0]).FromJust();
//   //   WindowController *obj = new WindowController(windowController);
//   //   obj->Wrap(info.This());
//   //   info.GetReturnValue().Set(info.This());
//   // } else {
//   //   const int argc = 1;
//   //   v8::Local<v8::Value> argv[argc] = {info[0]};
//   //   v8::Local<v8::Function> cons = Nan::New(constructor);
//   //   info.GetReturnValue().Set(Nan::NewInstance(cons, argc, argv).ToLocalChecked());
//   // }
// }

Nan::Persistent<v8::Function> WindowController::constructor;

NAN_MODULE_INIT(WindowController::Init) {
  v8::Local<v8::FunctionTemplate> tpl = Nan::New<v8::FunctionTemplate>(New);
  tpl->SetClassName(Nan::New("WindowController").ToLocalChecked());
  tpl->InstanceTemplate()->SetInternalFieldCount(1);

  Nan::SetPrototypeMethod(tpl, "plusOne", PlusOne);
  Nan::SetPrototypeMethod(tpl, "show", Show);

  constructor.Reset(Nan::GetFunction(tpl).ToLocalChecked());
  Nan::Set(target, Nan::New("WindowController").ToLocalChecked(), Nan::GetFunction(tpl).ToLocalChecked());
}

WindowController::WindowController(pid_t windowNumber) : windowNumber_(windowNumber) {
    NSLog(@"AAAZZZ 3 %@", @(windowNumber));
  // WindowController* obj = Nan::ObjectWrap::Unwrap<WindowController>(info.This());
  // obj->windowController_ = [[BorderWindowController alloc] init];
}

WindowController::~WindowController() {
    NSLog(@"AAAZZZ 4");
}

NAN_METHOD(WindowController::New) {
  if (info.IsConstructCall()) {
    pid_t windowNumber = info[0]->IsUndefined() ? 0 : Nan::To<double>(info[0]).FromJust();
    NSLog(@"AAAZZZ 1 %@", @(windowNumber));
    WindowController *obj = new WindowController(windowNumber);
    obj->Wrap(info.This());
    info.GetReturnValue().Set(info.This());
  } else {
    NSLog(@"AAAZZZ 2");
    const int argc = 1;
    v8::Local<v8::Value> argv[argc] = {info[0]};
    v8::Local<v8::Function> cons = Nan::New(constructor);
    info.GetReturnValue().Set(Nan::NewInstance(cons, argc, argv).ToLocalChecked());
  }
}

NAN_METHOD(WindowController::PlusOne) {
  WindowController* obj = Nan::ObjectWrap::Unwrap<WindowController>(info.This());
  obj->windowNumber_ += 1;
  NSLog(@"AAAZZZ PlusOne %@", obj->windowController_);
  info.GetReturnValue().Set(obj->windowNumber_);
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

  // [[BorderWindowController sharedInstance] show];

  // dispatch_after(2.0, dispatch_get_main_queue(), ^{
    info.GetReturnValue().Set(obj->windowNumber_);
  // });
}
