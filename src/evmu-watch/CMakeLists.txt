cmake_minimum_required(VERSION 3.16)

# Setup iOS App
set(iOS_DEPLOYMENT_TARGET "15.5")
set(DEVELOPMENT_PROJECT_NAME "evmu-watch")                     # <== Set to your project name, e.g. project.xcodeproj
set(DEVELOPMENT_TEAM_ID "AAAAAAAAAA")                       # <== Set to your team ID from Apple
set(APP_NAME "EVMUWatch")                                     # <== Set To your app's name
set(APP_BUNDLE_IDENTIFIER "ca.andrewapperley.evmu-watch")                # <== Set to your app's bundle identifier

# Setup Watch App
set(WATCH_DEPLOYMENT_TARGET "8.5")
set(WATCH_APP_NAME "EVMUWatchWatchKitApp")                                     # <== Set To your app's name
set(WATCH_APP_BUNDLE_IDENTIFIER "ca.andrewapperley.evmu-watch.watchkitapp")                # <== Set to your app's bundle identifier

# Setup Watch App Extension
set(WATCH_APP_EXTENSION_NAME "EVMUWatchWatchKitExtension")                                     # <== Set To your app's name
set(WATCH_APP_EXTENSION_BUNDLE_IDENTIFIER "ca.andrewapperley.evmu-watch.watchkitapp.watchkitextension")                # <== Set to your app's bundle identifier

set(CODE_SIGN_IDENTITY "iPhone Developer")
set(DEVICE_FAMILY "1")                                      # <== Set to "1" to target iPhone, set to "2" to target iPad, set to "4" to target AppleWatch

set(PRODUCT_NAME ${APP_NAME})
set(EXECUTABLE_NAME ${APP_NAME})
set(MACOSX_BUNDLE_EXECUTABLE_NAME ${APP_NAME})
set(MACOSX_BUNDLE_INFO_STRING ${APP_BUNDLE_IDENTIFIER})
set(MACOSX_BUNDLE_GUI_IDENTIFIER ${APP_BUNDLE_IDENTIFIER})
set(MACOSX_BUNDLE_BUNDLE_NAME ${APP_BUNDLE_IDENTIFIER})
set(MACOSX_BUNDLE_ICON_FILE "")
set(MACOSX_BUNDLE_LONG_VERSION_STRING "0.1")
set(MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1")
set(MACOSX_BUNDLE_BUNDLE_VERSION "0.1")
set(MACOSX_BUNDLE_COPYRIGHT "Copyright Andrew Apperley")
set(MACOSX_DEPLOYMENT_TARGET ${iOS_DEPLOYMENT_TARGET})

set(EVMU_WATCH_VERSION_MAJOR 0)
set(EVMU_WATCH_VERSION_MINOR 0)
set(EVMU_WATCH_VERSION_PATCH 1)
set(EVMU_WATCH_VERSION
    ${EVMU_WATCH_VERSION_MAJOR}.${EVMU_WATCH_VERSION_MINOR}.${EVMU_WATCH_VERSION_PATCH})

project(evmu-watch VERSION ${EVMU_WATCH_VERSION} DESCRIPTION "The first VMU emulator on your watch! Uses the powerful EVMU emulator core as it's base but adds exclusive Apple Watch features.")
enable_language(C)
enable_language(CXX)
enable_language(OBJC)

# set(GYRO_PLATFORM GYRO_PLATFORM_iOS)
# add_subdirectory(evmu-core)

# Includes
include_directories(${evmu-watch_SOURCE_DIR})

# Headers
set(EVMU_WATCH_HEADERS
    Watch/Watch\ Extension/ComplicationController.h
    Watch/Watch\ Extension/ExtensionDelegate.h
    Watch/Watch\ Extension/InterfaceController.h
)
set(EVMU_WATCH_IOS_HEADERS
    iOS/AppDelegate.h
    iOS/SceneDelegate.h
    iOS/ViewController.h
)

# Sources
set(EVMU_WATCH_SOURCES
    Watch/Watch\ Extension/ComplicationController.m
    Watch/Watch\ Extension/ExtensionDelegate.m
    Watch/Watch\ Extension/InterfaceController.m
)
set(EVMU_WATCH_IOS_SOURCES
    iOS/AppDelegate.m
    iOS/SceneDelegate.m
    iOS/ViewController.m
    iOS/main.m
)

# Resources
set(EVMU_WATCH_RESOURCES
  ./Watch/Watch\ App/Base.lproj/Interface.storyboard
)

set(EVMU_WATCH_IOS_RESOURCES
  ./iOS/Base.lproj/LaunchScreen.storyboard
  ./iOS/Base.lproj/Main.storyboard
)

# Locate system libraries on iOS and WatchOS
find_library(UIKIT UIKit)
find_library(WATCHKIT WatchKit)
find_library(FOUNDATION Foundation)
find_library(MOBILECORESERVICES MobileCoreServices)
find_library(CFNETWORK CFNetwork)

# Create Watch App Module
# add_library(${WATCH_APP_NAME} MODULE ${EVMU_WATCH_SOURCES})
add_executable(
    ${WATCH_APP_NAME}
    MACOSX_BUNDLE
    ${EVMU_WATCH_HEADERS}
    ${EVMU_WATCH_SOURCES}
    ${EVMU_WATCH_RESOURCES}
)

set_target_properties(${WATCH_APP_NAME} PROPERTIES
  LINKER_LANGUAGE OBJC
  BUNDLE YES
  RESOURCE "${EVMU_WATCH_RESOURCES}"
  XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "NO"
  XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ""
  XCODE_ATTRIBUTE_ENABLE_BITCODE "NO"
  MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Watch/Resources/Info.plist.in"
  MACOSX_BUNDLE_GUI_IDENTIFIER "${WATCH_APP_BUNDLE_IDENTIFIER}"
  XCODE_PRODUCT_TYPE "com.apple.product-type.application.watchapp"
  XCODE_EXPLICIT_FILE_TYPE "wrapper.application"
)

# Create Watch Extension Module
# add_library(${WATCH_APP_EXTENSION_NAME} MODULE ${EVMU_WATCH_SOURCES})
add_executable(
    ${WATCH_APP_EXTENSION_NAME}
    MACOSX_BUNDLE
    ${EVMU_WATCH_HEADERS}
    ${EVMU_WATCH_SOURCES}
    ${EVMU_WATCH_RESOURCES}
)
add_dependencies(${WATCH_APP_NAME} ${WATCH_APP_EXTENSION_NAME})
set_target_properties(${WATCH_APP_EXTENSION_NAME} PROPERTIES
  LINKER_LANGUAGE OBJC
  BUNDLE YES
  RESOURCE "${EVMU_WATCH_RESOURCES}"
  XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "NO"
  XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ""
  XCODE_ATTRIBUTE_ENABLE_BITCODE "NO"
  MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Watch/Resources/Info.plist.in"
  MACOSX_BUNDLE_GUI_IDENTIFIER "${WATCH_APP_EXTENSION_BUNDLE_IDENTIFIER}"
  XCODE_PRODUCT_TYPE "com.apple.product-type.watchkit-extension"
  XCODE_EXPLICIT_FILE_TYPE "wrapper.app-extension"
)

# Create the iOS app target
add_executable(
    ${APP_NAME}
    MACOSX_BUNDLE
    ${EVMU_WATCH_IOS_HEADERS}
    ${EVMU_WATCH_IOS_SOURCES}
    ${EVMU_WATCH_IOS_RESOURCES}
)
add_dependencies(${APP_NAME} ${WATCH_APP_NAME})
set_target_properties(${APP_NAME} PROPERTIES
                      XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT "dwarf-with-dsym"
                      XCODE_ATTRIBUTE_GCC_PREFIX_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/Resources/Prefix.pch"
                      RESOURCE "${EVMU_WATCH_IOS_RESOURCES}"
                      XCODE_ATTRIBUTE_GCC_PRECOMPILE_PREFIX_HEADER "YES"
                      XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET ${iOS_DEPLOYMENT_TARGET}
                      XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ${CODE_SIGN_IDENTITY}
                      XCODE_ATTRIBUTE_DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM_ID}
                      XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY ${DEVICE_FAMILY}
                      MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/iOS/plist.in
                      XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
                      XCODE_ATTRIBUTE_COMBINE_HIDPI_IMAGES NO
                      XCODE_ATTRIBUTE_INSTALL_PATH "$(LOCAL_APPS_DIR)"
                      XCODE_ATTRIBUTE_ENABLE_TESTABILITY YES
                      XCODE_ATTRIBUTE_GCC_SYMBOLS_PRIVATE_EXTERN YES
                      XCODE_EMBED_APP_EXTENSIONS ${WATCH_APP_NAME}
                      XCODE_EMBED_APP_EXTENSIONS ${WATCH_APP_EXTENSION_NAME}
                      MACOSX_BUNDLE_GUI_IDENTIFIER "${APP_BUNDLE_IDENTIFIER}"
                      XCODE_PRODUCT_TYPE "com.apple.product-type.application"
                      XCODE_EXPLICIT_FILE_TYPE "wrapper.application"
)

# Link to iOS App
target_link_libraries(${APP_NAME} ${UIKIT})
target_link_libraries(${APP_NAME} ${FOUNDATION})
target_link_libraries(${APP_NAME} ${MOBILECORESERVICES})
target_link_libraries(${APP_NAME} ${CFNETWORK})
# target_link_libraries(${APP_NAME} ${WATCHKIT})

# Link to Watch App
target_link_libraries(${WATCH_APP_NAME} ${WATCHKIT})
target_link_libraries(${WATCH_APP_NAME} ${FOUNDATION})
target_link_libraries(${WATCH_APP_NAME} ${MOBILECORESERVICES})
target_link_libraries(${WATCH_APP_NAME} ${CFNETWORK})

# Link to Watch AppExtension
target_link_libraries(${WATCH_APP_EXTENSION_NAME} ${WATCHKIT})
target_link_libraries(${WATCH_APP_EXTENSION_NAME} ${FOUNDATION})
target_link_libraries(${WATCH_APP_EXTENSION_NAME} ${MOBILECORESERVICES})
target_link_libraries(${WATCH_APP_EXTENSION_NAME} ${CFNETWORK})


# Include framework headers, needed to make "Build" Xcode action work.
# "Archive" works fine just relying on default search paths as it has different
# build product output directory.
target_include_directories(${APP_NAME} PUBLIC 
    "${PROJECT_BINARY_DIR}/cppframework/\${CONFIGURATION}\${EFFECTIVE_PLATFORM_NAME}/${FRAMEWORK_NAME}.framework"
)

# Set the app's linker search path to the default location on iOS
set_target_properties(
    ${APP_NAME}
    PROPERTIES
    XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS
    "@executable_path/Frameworks"
)