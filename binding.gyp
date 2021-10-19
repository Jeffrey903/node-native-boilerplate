{
  "targets": [
    { "target_name": "" }
  ],
  "conditions": [
    ['OS=="mac"', {
      "targets": [{
        "target_name": "NativeExtension",
        "sources": ["NativeExtension.cc", "functions_mac.mm"],
        "link_settings": {
          "libraries": [
            "$(SDKROOT)/System/Library/Frameworks/Cocoa.framework",
          ]
        },
        "include_dirs": [
          "<!(node -e \"require('nan')\")"
        ]
      }]
    }],
    ['OS!="mac"', {
      "targets": [{
        "target_name": "NativeExtension",
        "sources": ["NativeExtension.cc", "functions_stub.cc"],
        "include_dirs": [
          "<!(node -e \"require('nan')\")"
        ]
      }]
    }],
  ]
}
