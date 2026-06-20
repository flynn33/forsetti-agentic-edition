cmake_minimum_required(VERSION 3.21)
project(ForsettiGovernance VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_library(forsetti_governance_core
    src/Core/SHA256.cpp
    src/Core/Result.cpp
    src/Core/BundleVerifier.cpp
)

target_include_directories(forsetti_governance_core
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

add_executable(forsetti-governance
    src/CLI/main.cpp
)

target_link_libraries(forsetti-governance
    PRIVATE forsetti_governance_core
)

enable_testing()

add_executable(forsetti_governance_tests
    tests/result_tests.cpp
)

target_link_libraries(forsetti_governance_tests
    PRIVATE forsetti_governance_core
)

add_test(NAME forsetti_governance_tests COMMAND forsetti_governance_tests)
