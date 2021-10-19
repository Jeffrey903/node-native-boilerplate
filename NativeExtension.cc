#include "functions.h"

using v8::FunctionTemplate;

// NativeExtension.cc represents the top level of the module.
// C++ constructs that are exposed to javascript are exported here

NAN_MODULE_INIT(InitAll) {
  Nan::Set(target, Nan::New("show").ToLocalChecked(),
    Nan::GetFunction(Nan::New<FunctionTemplate>(show)).ToLocalChecked());
  Nan::Set(target, Nan::New("hide").ToLocalChecked(),
    Nan::GetFunction(Nan::New<FunctionTemplate>(hide)).ToLocalChecked());
}

NODE_MODULE(NativeExtension, InitAll)
