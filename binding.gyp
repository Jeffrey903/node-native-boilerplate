# {
#     "targets": [
#         {
#             "target_name": "NativeExtension",
#             "sources": [ "NativeExtension.cc", "functions.mm" ],
#             "include_dirs" : [
#                 "<!(node -e \"require('nan')\")"
#             ]
#         }
#     ],
# }

{
  "targets": [
    { "target_name": "" }
  ],
  "conditions": [
    ['OS=="mac"', {
      "targets": [{
        "target_name": "NativeExtension",
        "sources": ["NativeExtension.cc", "functions.mm"],
        "link_settings": {
          "libraries": [
            "$(SDKROOT)/System/Library/Frameworks/Cocoa.framework",
          ]
        },
        "include_dirs": [
          "<!(node -e \"require('nan')\")"
        ]
      }]
    }]
  ]
}
