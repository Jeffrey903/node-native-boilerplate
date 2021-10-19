#include "functions.h"

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
  info.GetReturnValue().Set(1);
}
