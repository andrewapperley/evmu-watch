cmake_minimum_required(VERSION 3.10)

set(EVMU_WATCH_VERSION_MAJOR 0)
set(EVMU_WATCH_VERSION_MINOR 0)
set(EVMU_WATCH_VERSION_PATCH 1)
set(EVMU_WATCH_VERSION
    ${EVMU_WATCH_VERSION_MAJOR}.${EVMU_WATCH_VERSION_MINOR}.${EVMU_WATCH_VERSION_PATCH})

project(evmu-watch VERSION ${EVMU_WATCH_VERSION} DESCRIPTION "The first VMU emulator on your watch! Uses the powerful EVMU emulator core as it's base but adds exclusive Apple Watch features." LANGUAGES C CXX OBJC)

add_subdirectory(evmu-core)

option(EVMU_ENABLE_TESTS "Enable ElysianVmu Watch unit tests" OFF)

if(EVMU_ENABLE_TESTS)
    add_subdirectory(test)
endif(EVMU_ENABLE_TESTS)

