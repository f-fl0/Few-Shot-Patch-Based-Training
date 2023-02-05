cmake_minimum_required(VERSION 3.1.3)

project(disflow)

find_package(OpenCV REQUIRED)

include_directories(
  ${OpenCV_INCLUDE_DIRS}
)

add_executable(disflow disflow.cpp)
target_link_libraries(disflow ${OpenCV_LIBS})
