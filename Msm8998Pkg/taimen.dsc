[Defines]
  PLATFORM_NAME                  = Msm8998Pkg
  PLATFORM_GUID                  = 28f1a3bf-193a-47e3-a7b9-5a435eaab2ee
  PLATFORM_VERSION               = 0.1
  DSC_SPECIFICATION              = 0x00010019
  OUTPUT_DIRECTORY               = Build/$(PLATFORM_NAME)
  SUPPORTED_ARCHITECTURES        = AARCH64
  BUILD_TARGETS                  = DEBUG|RELEASE
  SKUID_IDENTIFIER               = DEFAULT
  FLASH_DEFINITION               = Msm8998Pkg/taimen.fdf

!include Msm8998Pkg/Msm8998Pkg.dsc

[PcdsFixedAtBuild.common]
  gArmTokenSpaceGuid.PcdSystemMemorySize|0x77359400 # 2GB RAM allocated

  gMsm8998PkgTokenSpaceGuid.PcdMipiFrameBufferWidth|1440
  gMsm8998PkgTokenSpaceGuid.PcdMipiFrameBufferHeight|2280