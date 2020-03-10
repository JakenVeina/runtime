include(clrfeatures.cmake)

# If set, indicates that this is not an officially supported release
# Keep in sync with IsPrerelease in dir.props
set(PRERELEASE 1)

# Features we're currently flighting, but don't intend to ship in officially supported releases
if (PRERELEASE)
  add_definitions(-DFEATURE_UTF8STRING)
  # add_definitions(-DFEATURE_XXX)
endif (PRERELEASE)

add_compile_definitions($<$<BOOL:$<TARGET_PROPERTY:DAC_COMPONENT>>:DACCESS_COMPILE>)
add_compile_definitions($<$<BOOL:$<TARGET_PROPERTY:CROSSGEN_COMPONENT>>:CROSSGEN_COMPILE>)
add_compile_definitions($<$<BOOL:$<TARGET_PROPERTY:CROSSGEN_COMPONENT>>:CROSS_COMPILE>)
add_compile_definitions($<$<BOOL:$<TARGET_PROPERTY:CROSSGEN_COMPONENT>>:FEATURE_NATIVE_IMAGE_GENERATION>)
add_compile_definitions($<$<BOOL:$<TARGET_PROPERTY:CROSSGEN_COMPONENT>>:SELF_NO_HOST>)

if (CLR_CMAKE_TARGET_ARCH_ARM64)
  if (CLR_CMAKE_TARGET_UNIX)
    add_definitions(-DFEATURE_EMULATE_SINGLESTEP)
  endif()
  add_definitions(-DFEATURE_MULTIREG_RETURN)
elseif (CLR_CMAKE_TARGET_ARCH_ARM)
  if (CLR_CMAKE_HOST_WIN32 AND NOT DEFINED CLR_CROSS_COMPONENTS_BUILD)
    # Set this to ensure we can use Arm SDK for Desktop binary linkage when doing native (Arm32) build
    add_definitions(-D_ARM_WINAPI_PARTITION_DESKTOP_SDK_AVAILABLE)
    add_definitions(-D_ARM_WORKAROUND_)
  endif (CLR_CMAKE_HOST_WIN32 AND NOT DEFINED CLR_CROSS_COMPONENTS_BUILD)
  add_definitions(-DFEATURE_EMULATE_SINGLESTEP)
endif (CLR_CMAKE_TARGET_ARCH_ARM64)

if (CLR_CMAKE_TARGET_UNIX)

  if(CLR_CMAKE_TARGET_DARWIN)
    add_definitions(-D_XOPEN_SOURCE)
    add_definitions(-DFEATURE_DATATARGET4)
  endif(CLR_CMAKE_TARGET_DARWIN)

  if (CLR_CMAKE_TARGET_ARCH_AMD64)
    add_definitions(-DUNIX_AMD64_ABI)
  elseif (CLR_CMAKE_TARGET_ARCH_ARM)
    add_definitions(-DUNIX_ARM_ABI)
  elseif (CLR_CMAKE_TARGET_ARCH_I386)
    add_definitions(-DUNIX_X86_ABI)
  endif()

endif(CLR_CMAKE_TARGET_UNIX)

if(CLR_CMAKE_TARGET_ALPINE_LINUX)
  # Alpine Linux doesn't have fixed stack limit, this define disables some stack pointer
  # sanity checks in debug / checked build that rely on a fixed stack limit
  add_definitions(-DNO_FIXED_STACK_LIMIT)
endif(CLR_CMAKE_TARGET_ALPINE_LINUX)

add_definitions(-D_BLD_CLR)
add_definitions(-DDEBUGGING_SUPPORTED)
add_compile_definitions($<$<NOT:$<BOOL:$<TARGET_PROPERTY:DAC_COMPONENT>>>:PROFILING_SUPPORTED>)
add_compile_definitions($<$<BOOL:$<TARGET_PROPERTY:DAC_COMPONENT>>:PROFILING_SUPPORTED_DATA>)

if(CLR_CMAKE_HOST_WIN32)
  add_definitions(-DWIN32)
  add_definitions(-D_WIN32)
  add_definitions(-DWINVER=0x0602)
  add_definitions(-D_WIN32_WINNT=0x0602)
  add_definitions(-DWIN32_LEAN_AND_MEAN)
  add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif(CLR_CMAKE_HOST_WIN32)
if(CLR_CMAKE_TARGET_WIN32)
  if(CLR_CMAKE_TARGET_ARCH_AMD64 OR CLR_CMAKE_TARGET_ARCH_I386)
    # Only enable edit and continue on windows x86 and x64
    # exclude Linux, arm & arm64
    add_compile_definitions($<$<NOT:$<BOOL:$<TARGET_PROPERTY:CROSSGEN_COMPONENT>>>:EnC_SUPPORTED>)
  endif(CLR_CMAKE_TARGET_ARCH_AMD64 OR CLR_CMAKE_TARGET_ARCH_I386)
endif(CLR_CMAKE_TARGET_WIN32)

# Features - please keep them alphabetically sorted
if(CLR_CMAKE_TARGET_WIN32)
  add_definitions(-DFEATURE_APPX)
  if(NOT CLR_CMAKE_TARGET_ARCH_I386)
    add_definitions(-DFEATURE_ARRAYSTUB_AS_IL)
    add_definitions(-DFEATURE_MULTICASTSTUB_AS_IL)
  endif()
else(CLR_CMAKE_TARGET_WIN32)
  add_definitions(-DFEATURE_ARRAYSTUB_AS_IL)
  add_definitions(-DFEATURE_MULTICASTSTUB_AS_IL)
endif(CLR_CMAKE_TARGET_WIN32)

if(NOT CLR_CMAKE_TARGET_ARCH_I386)
  add_definitions(-DFEATURE_PORTABLE_SHUFFLE_THUNKS)
endif()

if(CLR_CMAKE_TARGET_UNIX OR NOT CLR_CMAKE_TARGET_ARCH_I386)
  add_definitions(-DFEATURE_INSTANTIATINGSTUB_AS_IL)
endif()

add_compile_definitions($<$<NOT:$<BOOL:$<TARGET_PROPERTY:CROSSGEN_COMPONENT>>>:FEATURE_CODE_VERSIONING>)
add_definitions(-DFEATURE_COLLECTIBLE_TYPES)

if(CLR_CMAKE_TARGET_WIN32)
    add_definitions(-DFEATURE_COMWRAPPERS)
    add_definitions(-DFEATURE_CLASSIC_COMINTEROP)
    add_definitions(-DFEATURE_COMINTEROP)
    add_definitions(-DFEATURE_COMINTEROP_APARTMENT_SUPPORT)
    add_definitions(-DFEATURE_COMINTEROP_UNMANAGED_ACTIVATION)
    add_definitions(-DFEATURE_COMINTEROP_WINRT_MANAGED_ACTIVATION)
endif(CLR_CMAKE_TARGET_WIN32)

add_definitions(-DFEATURE_BASICFREEZE)
add_definitions(-DFEATURE_CORECLR)
add_definitions(-DFEATURE_CORESYSTEM)
add_definitions(-DFEATURE_CORRUPTING_EXCEPTIONS)
if(FEATURE_DBGIPC)
  add_definitions(-DFEATURE_DBGIPC_TRANSPORT_DI)
  add_definitions(-DFEATURE_DBGIPC_TRANSPORT_VM)
endif(FEATURE_DBGIPC)
add_definitions(-DFEATURE_DEFAULT_INTERFACES)
if(FEATURE_EVENT_TRACE)
    add_compile_definitions($<$<NOT:$<BOOL:$<TARGET_PROPERTY:CROSSGEN_COMPONENT>>>:FEATURE_EVENT_TRACE>)
    add_definitions(-DFEATURE_PERFTRACING)
else(FEATURE_EVENT_TRACE)
    add_custom_target(eventing_headers) # add a dummy target to avoid checking for FEATURE_EVENT_TRACE in multiple places
endif(FEATURE_EVENT_TRACE)
if(FEATURE_GDBJIT)
    add_definitions(-DFEATURE_GDBJIT)
endif()
if(FEATURE_GDBJIT_FRAME)
    add_definitions(-DFEATURE_GDBJIT_FRAME)
endif(FEATURE_GDBJIT_FRAME)
if(FEATURE_GDBJIT_LANGID_CS)
    add_definitions(-DFEATURE_GDBJIT_LANGID_CS)
endif(FEATURE_GDBJIT_LANGID_CS)
if(FEATURE_GDBJIT_SYMTAB)
    add_definitions(-DFEATURE_GDBJIT_SYMTAB)
endif(FEATURE_GDBJIT_SYMTAB)
if(CLR_CMAKE_TARGET_UNIX)
    add_definitions(-DFEATURE_EVENTSOURCE_XPLAT)
endif(CLR_CMAKE_TARGET_UNIX)
# NetBSD doesn't implement this feature
if(NOT CLR_CMAKE_TARGET_NETBSD)
    add_definitions(-DFEATURE_HIJACK)
endif(NOT CLR_CMAKE_TARGET_NETBSD)
add_definitions(-DFEATURE_ICASTABLE)
if (CLR_CMAKE_TARGET_WIN32 AND (CLR_CMAKE_TARGET_ARCH_AMD64 OR CLR_CMAKE_TARGET_ARCH_I386 OR CLR_CMAKE_TARGET_ARCH_ARM64))
    add_definitions(-DFEATURE_INTEROP_DEBUGGING)
endif (CLR_CMAKE_TARGET_WIN32 AND (CLR_CMAKE_TARGET_ARCH_AMD64 OR CLR_CMAKE_TARGET_ARCH_I386 OR CLR_CMAKE_TARGET_ARCH_ARM64))
if(FEATURE_INTERPRETER)
  add_compile_definitions($<$<NOT:$<BOOL:$<TARGET_PROPERTY:CROSSGEN_COMPONENT>>>:FEATURE_INTERPRETER>)
endif(FEATURE_INTERPRETER)
add_definitions(-DFEATURE_ISYM_READER)
if (CLR_CMAKE_TARGET_LINUX OR CLR_CMAKE_TARGET_WIN32)
    add_definitions(-DFEATURE_MANAGED_ETW)
endif(CLR_CMAKE_TARGET_LINUX OR CLR_CMAKE_TARGET_WIN32)
add_definitions(-DFEATURE_MANAGED_ETW_CHANNELS)

if(FEATURE_MERGE_JIT_AND_ENGINE)
  add_definitions(-DFEATURE_MERGE_JIT_AND_ENGINE)
endif(FEATURE_MERGE_JIT_AND_ENGINE)
add_compile_definitions($<$<NOT:$<BOOL:$<TARGET_PROPERTY:CROSSGEN_COMPONENT>>>:FEATURE_MULTICOREJIT>)
if(CLR_CMAKE_TARGET_UNIX)
  add_definitions(-DFEATURE_PAL_ANSI)
endif(CLR_CMAKE_TARGET_UNIX)
if(CLR_CMAKE_TARGET_LINUX AND CLR_CMAKE_HOST_LINUX)
    add_definitions(-DFEATURE_PERFMAP)
endif(CLR_CMAKE_TARGET_LINUX AND CLR_CMAKE_HOST_LINUX)
if(CLR_CMAKE_TARGET_FREEBSD)
    add_compile_definitions($<$<NOT:$<BOOL:$<TARGET_PROPERTY:CROSSGEN_COMPONENT>>>:FEATURE_PERFMAP>)
endif(CLR_CMAKE_TARGET_FREEBSD)
if(FEATURE_PREJIT)
  add_definitions(-DFEATURE_PREJIT)
else()
  add_compile_definitions($<$<BOOL:$<TARGET_PROPERTY:CROSSGEN_COMPONENT>>:FEATURE_PREJIT>)
endif(FEATURE_PREJIT)

add_compile_definitions($<$<AND:$<NOT:$<BOOL:$<TARGET_PROPERTY:CROSSGEN_COMPONENT>>>,$<NOT:$<BOOL:$<TARGET_PROPERTY:DAC_COMPONENT>>>>:FEATURE_PROFAPI_ATTACH_DETACH>)

add_definitions(-DFEATURE_READYTORUN)

add_compile_definitions($<$<BOOL:$<TARGET_PROPERTY:CROSSGEN_COMPONENT>>:FEATURE_READYTORUN_COMPILER>)
set(FEATURE_READYTORUN 1)

add_compile_definitions($<$<NOT:$<BOOL:$<TARGET_PROPERTY:CROSSGEN_COMPONENT>>>:FEATURE_REJIT>)

if (CLR_CMAKE_HOST_UNIX AND CLR_CMAKE_TARGET_UNIX AND NOT CLR_CMAKE_TARGET_DARWIN)
  add_definitions(-DFEATURE_REMOTE_PROC_MEM)
endif (CLR_CMAKE_HOST_UNIX AND CLR_CMAKE_TARGET_UNIX AND NOT CLR_CMAKE_TARGET_DARWIN)

if (CLR_CMAKE_TARGET_UNIX OR CLR_CMAKE_TARGET_ARCH_ARM64)
    add_definitions(-DFEATURE_STUBS_AS_IL)
endif ()
if (FEATURE_NGEN_RELOCS_OPTIMIZATIONS)
   add_definitions(-DFEATURE_NGEN_RELOCS_OPTIMIZATIONS)
endif(FEATURE_NGEN_RELOCS_OPTIMIZATIONS)
if (FEATURE_ENABLE_NO_ADDRESS_SPACE_RANDOMIZATION)
  add_definitions(-DFEATURE_ENABLE_NO_ADDRESS_SPACE_RANDOMIZATION)
endif(FEATURE_ENABLE_NO_ADDRESS_SPACE_RANDOMIZATION)
add_definitions(-DFEATURE_SVR_GC)
add_definitions(-DFEATURE_SYMDIFF)
add_compile_definitions($<$<NOT:$<BOOL:$<TARGET_PROPERTY:CROSSGEN_COMPONENT>>>:FEATURE_TIERED_COMPILATION>)
if (CLR_CMAKE_TARGET_WIN32)
    add_definitions(-DFEATURE_TYPEEQUIVALENCE)
endif(CLR_CMAKE_TARGET_WIN32)
if (CLR_CMAKE_TARGET_ARCH_AMD64)
  # Enable the AMD64 Unix struct passing JIT-EE interface for all AMD64 platforms, to enable altjit.
  add_definitions(-DUNIX_AMD64_ABI_ITF)
endif (CLR_CMAKE_TARGET_ARCH_AMD64)
if(CLR_CMAKE_TARGET_UNIX_AMD64)
  add_definitions(-DFEATURE_MULTIREG_RETURN)
endif (CLR_CMAKE_TARGET_UNIX_AMD64)
if(CLR_CMAKE_TARGET_UNIX AND CLR_CMAKE_TARGET_ARCH_AMD64)
  add_definitions(-DUNIX_AMD64_ABI)
endif(CLR_CMAKE_TARGET_UNIX AND CLR_CMAKE_TARGET_ARCH_AMD64)
add_definitions(-DFEATURE_USE_ASM_GC_WRITE_BARRIERS)
if(CLR_CMAKE_TARGET_ARCH_AMD64 OR CLR_CMAKE_TARGET_ARCH_ARM64)
  add_definitions(-DFEATURE_USE_SOFTWARE_WRITE_WATCH_FOR_GC_HEAP)
endif(CLR_CMAKE_TARGET_ARCH_AMD64 OR CLR_CMAKE_TARGET_ARCH_ARM64)
if(CLR_CMAKE_TARGET_ARCH_AMD64 OR CLR_CMAKE_TARGET_ARCH_ARM64)
  add_definitions(-DFEATURE_MANUALLY_MANAGED_CARD_BUNDLES)
endif(CLR_CMAKE_TARGET_ARCH_AMD64 OR CLR_CMAKE_TARGET_ARCH_ARM64)

if(NOT CLR_CMAKE_TARGET_UNIX)
    add_definitions(-DFEATURE_WIN32_REGISTRY)
endif(NOT CLR_CMAKE_TARGET_UNIX)
add_definitions(-DFEATURE_WINMD_RESILIENT)
add_definitions(-D_SECURE_SCL=0)
add_definitions(-DUNICODE)
add_definitions(-D_UNICODE)

if(CLR_CMAKE_TARGET_WIN32)
  if (CLR_CMAKE_TARGET_ARCH_AMD64 OR CLR_CMAKE_TARGET_ARCH_I386)
    add_definitions(-DFEATURE_DATABREAKPOINT)
  endif(CLR_CMAKE_TARGET_ARCH_AMD64 OR CLR_CMAKE_TARGET_ARCH_I386)
endif(CLR_CMAKE_TARGET_WIN32)

if(CLR_CMAKE_TARGET_DARWIN)
  add_definitions(-DFEATURE_WRITEBARRIER_COPY)
endif(CLR_CMAKE_TARGET_DARWIN)

if (NOT CLR_CMAKE_TARGET_ARCH_I386 OR NOT CLR_CMAKE_TARGET_WIN32)
  add_definitions(-DFEATURE_EH_FUNCLETS)
endif (NOT CLR_CMAKE_TARGET_ARCH_I386 OR NOT CLR_CMAKE_TARGET_WIN32)
