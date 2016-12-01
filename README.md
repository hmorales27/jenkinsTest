
# Key
- `./` - Project Root Folder

# Requirements
- Xcode 7.3.1
- Swift 2.2
- [Fastlane 1.95]
- Cocoapods
- brew install imagemagick
- gem install rmagick
- Homebrew

# Build Script
Create the build using fastlane `fastlane ios enterprise` from `./`.

```sh
fastlane ios enterprise
```

#### Setup (for now)
- **Bundle Identifier:** com.elsevier.jbsm.swift.CELLPRESS
- **Team:** Elsevier, Inc.
- **Provisioning Profile:** JBSM Swift Wildcard
- You will need to update the AppFile which can be found at `./fastlane/Appfile`
- Change the values for `ENV["PRODUCT_NAME"]`, `ENV["APP_SHORT_CODE"]`, and `ENV["BASE_BUNDLE_IDENTIFIER"]` to the appropriate values
-  `AppShortCode` needs to be changed in `info.plist` from within Xcode. There currently is no command line way to do this.

#### Notes
- This will only create one build.
- The build will be an Enterprise Build.
- The Wildcard Provisioning Profile used can be found in `./Profiles/`
- **Cert:** iPhone Distribution: Elsevier, Inc. (expiration March 21, 2019)

[//]: Links
[Fastlane 1.95]: <https://fastlane.tools>
