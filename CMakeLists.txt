cmake_minimum_required(VERSION 3.16)

project(GPUConsole VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(QT_QML_NO_PLUGIN_IMPORT ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)

qt_standard_project_setup(REQUIRES 6.8)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

qt_add_executable(GPUConsoleApp
    src/main.cpp
    src/core/GpuInfo.h
    src/core/GpuManager.h
    src/core/GpuManager.cpp
    src/core/GpuController.h
    src/core/GpuController.cpp
    src/providers/IGpuProvider.h
    src/providers/NvidiaProvider.h
    src/providers/NvidiaProvider.cpp
)

qt_add_qml_module(GPUConsoleApp
    URI GPUConsole
    VERSION 1.0
    QML_FILES qml/Main.qml
)

target_include_directories(GPUConsoleApp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(GPUConsoleApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    /usr/lib/x86_64-linux-gnu/libnvidia-ml.so
)

set_target_properties(GPUConsoleApp PROPERTIES
    OUTPUT_NAME "gpuconsole"
)




include(GNUInstallDirs)

install(TARGETS GPUConsoleApp
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(FILES
    packaging/linux/GPUConsole.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
)

install(FILES
    packaging/linux/gpuconsole.svg
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps
)

set(CPACK_PACKAGE_NAME "gpuconsole")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "NVIDIA GPU monitoring dashboard")
set(CPACK_PACKAGE_CONTACT "userusv")
set(CPACK_GENERATOR "DEB")
set(CPACK_DEBIAN_PACKAGE_SECTION "utils")
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)

include(CPack)
