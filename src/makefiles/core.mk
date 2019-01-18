CC = $(ARTIST_SDK)/toolchain/prebuilts/clang/host/linux-x86/clang-2690385/bin/clang++
INCLUDES = $(ARTIST_SDK)/include

ARCH_ARM = armeabi-v7a
ARCH_X86 = x86
OUT_ARM = out/lib/$(ARCH_ARM)
OUT_X86 = out/lib/$(ARCH_X86)
OBJECTS_ARM = $(patsubst src/%.cc,out/obj/$(ARCH_ARM)/%.o,$(wildcard src/*.cc))
OBJECTS_X86 = $(patsubst src/%.cc,out/obj/$(ARCH_X86)/%.o,$(wildcard src/*.cc))
CODELIB = $(wildcard codelib.apk)

# ANDROID_VERSION can be BUILD_MARSHMALLOW, BUILD_NOUGAT or BUILD_OREO
ANDROID_VERSION = BUILD_NOUGAT

define output
      @echo $1
endef

define colored 
      @tput setaf $2 
      $(call output,$1)
      @tput sgr0
endef

define success
      $(call colored,$1,2)
endef


.PHONY: all
all: arm x86


.PHONY: arm
arm: $(OUT_ARM)/artist-module.so Manifest.json
	mkdir -p out/zip
	cp -r Manifest.json $(CODELIB) out/lib out/zip/
	cd out/zip && zip -r ../artist-module-arm.zip Manifest.json $(CODELIB) lib
	$(call success,"Successfully built module for arm ($(ANDROID_VERSION)).")

.PHONY: x86
x86: $(OUT_X86)/artist-module.so Manifest.json
	mkdir -p out/zip
	cp -r Manifest.json $(CODELIB) out/lib out/zip/
	cd out/zip && zip -r ../artist-module-x86.zip Manifest.json $(CODELIB) lib
	$(call success,"Successfully built module for x86 ($(ANDROID_VERSION)).")



out/lib/armeabi-v7a/artist-module.so: $(OBJECTS_ARM)
	$(CC) -nostdlib -Wl,-soname,artist-module.so -Wl,--gc-sections -shared  \
	-L$(ARTIST_SDK)/toolchain/out/target/product/generic/obj/lib \
	$(ARTIST_SDK)/toolchain/out/target/product/generic/obj/lib/crtbegin_so.o \
	$(OBJECTS_ARM)            -Wl,--whole-archive   -Wl,--no-whole-archive   \
	$(ARTIST_SDK)/toolchain/out/target/product/generic/obj/STATIC_LIBRARIES/libunwind_llvm_intermediates/libunwind_llvm.a \
	$(ARTIST_SDK)/toolchain/out/target/product/generic/obj/STATIC_LIBRARIES/libcompiler_rt-extras_intermediates/libcompiler_rt-extras.a \
	$(ARTIST_SDK)/toolchain/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/../lib/gcc/arm-linux-androideabi/4.9/../../../../arm-linux-androideabi/lib/armv7-a/libatomic.a \
	$(ARTIST_SDK)/toolchain/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/../lib/gcc/arm-linux-androideabi/4.9/armv7-a/libgcc.a \
	-lart -llz4 -llzma -lvixl -lcutils -lc++ -ldl -lc -lm \
	$(ARTIST_SDK)/toolchain/out/target/product/generic/obj/lib/libart-compiler.so \
	-o $(OUT_ARM)/artist-module.so   \
	-Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--build-id=md5 -Wl,--warn-shared-textrel -Wl,--fatal-warnings \
	-Wl,--icf=safe -Wl,--hash-style=gnu -Wl,--no-undefined-version -Wl,--fix-cortex-a8    \
	-target arm-linux-androideabi \
	-B$(ARTIST_SDK)/toolchain/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/arm-linux-androideabi/bin   \
	-Wl,--exclude-libs,libunwind_llvm.a \
	-Wl,--no-undefined $(ARTIST_SDK)/toolchain/out/target/product/generic/obj/lib/crtend_so.o

out/lib/x86/artist-module.so: $(OBJECTS_X86)
	echo $(OBJECTS_X86)
	$(CC) -nostdlib -Wl,-soname,artist-module.so -Wl,--gc-sections -shared  \
	-L$(ARTIST_SDK)/toolchain/out/target/product/generic_x86/obj/lib \
	$(ARTIST_SDK)/toolchain/out/target/product/generic_x86/obj/lib/crtbegin_so.o \
	$(OBJECTS_X86)            -Wl,--whole-archive   -Wl,--no-whole-archive   \
	$(ARTIST_SDK)/toolchain/out/target/product/generic_x86/obj/STATIC_LIBRARIES/libcompiler_rt-extras_intermediates/libcompiler_rt-extras.a \
	$(ARTIST_SDK)/toolchain/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9/bin/../lib/gcc/x86_64-linux-android/4.9/../../../../x86_64-linux-android/lib/libatomic.a \
	$(ARTIST_SDK)/toolchain/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9/bin/../lib/gcc/x86_64-linux-android/4.9/libgcc.a \
	-lart -llz4 -llzma -lvixl -lcutils -lc++ -ldl -lc -lm \
	$(ARTIST_SDK)/toolchain/out/target/product/generic_x86/obj/lib/libart-compiler.so \
	-o $(OUT_X86)/artist-module.so   \
	-Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--build-id=md5 -Wl,--warn-shared-textrel -Wl,--fatal-warnings \
	-Wl,--icf=safe -Wl,--hash-style=gnu -Wl,--no-undefined-version -Wl,--fix-cortex-a8    \
	-target i686-linux-android \
	-B$(ARTIST_SDK)/toolchain/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9/x86_64-linux-android/bin   \
	-Wl,--exclude-libs,libunwind_llvm.a \
	-Wl,--no-undefined $(ARTIST_SDK)/toolchain/out/target/product/generic_x86/obj/lib/crtend_so.o

out/obj/armeabi-v7a/%.o: src/%.cc
	mkdir -p $(OUT_ARM)
	mkdir -p out/obj/$(ARCH_ARM)
	$(CC) \
	-I $(INCLUDES)/external/valgrind \
	-I $(INCLUDES)/external/valgrind/include \
	-I $(INCLUDES)/bionic/libc/private \
	-I $(INCLUDES)/art/runtime \
	-I $(INCLUDES)/art/compiler \
	-I $(INCLUDES)/art/compiler/optimizing \
	-I $(INCLUDES)/libnativehelper/include/nativehelper \
	-I $(INCLUDES)/external/libcxx/include \
	-isystem $(INCLUDES)/bionic/libc/arch-arm/include \
	-isystem $(INCLUDES)/bionic/libc/include \
	-isystem $(INCLUDES)/bionic/libc/kernel/uapi \
	-isystem $(INCLUDES)/bionic/libc/kernel/uapi/asm-arm \
	-isystem $(INCLUDES)/bionic/libm/include \
	-c    -fno-exceptions -Wno-multichar -msoft-float -ffunction-sections -fdata-sections -funwind-tables -fstack-protector-strong -Wa,--noexecstack -Werror=format-security \
	-D_FORTIFY_SOURCE=2 -fno-short-enums -no-canonical-prefixes -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 \
	-DANDROID -fmessage-length=0 -W -Wall -Wno-unused -Winit-self -Wpointer-arith -Werror=non-virtual-dtor \
	-Werror=address -Werror=sequence-point -Werror=date-time -DNDEBUG -g -Wstrict-aliasing=2 -DNDEBUG -UDEBUG  -D__compiler_offsetof=__builtin_offsetof \
	-Werror=int-conversion -Wno-reserved-id-macro -Wno-format-pedantic -Wno-unused-command-line-argument -fcolor-diagnostics \
	-nostdlibinc -target arm-linux-androideabi -Bbuild/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/arm-linux-androideabi/bin    \
	-fvisibility-inlines-hidden -Wsign-promo  -Wno-inconsistent-missing-override \
	-mthumb -Os -fomit-frame-pointer -fno-strict-aliasing  -fno-rtti -DBUILD_NOUGAT -fno-rtti -ggdb3 -Werror \
	-Wextra -Wstrict-aliasing -fstrict-aliasing -Wunreachable-code -Wredundant-decls -Wunused -fvisibility=protected \
	-DART_DEFAULT_GC_TYPE_IS_CMS -DIMT_SIZE=64 -DART_TARGET -DART_BASE_ADDRESS=0x70000000 -DART_ENABLE_CODEGEN_arm \
	-DART_ENABLE_CODEGEN_arm64 -DART_ENABLE_CODEGEN_mips -DART_ENABLE_CODEGEN_mips64 -DART_ENABLE_CODEGEN_x86 \
	-DART_ENABLE_CODEGEN_x86_64 -DART_BASE_ADDRESS_MIN_DELTA=-0x1000000 -DART_BASE_ADDRESS_MAX_DELTA=0x1000000 -O2 \
	-DDYNAMIC_ANNOTATIONS_ENABLED=1 -UNDEBUG -D$(ANDROID_VERSION) -fPIC -D_USING_LIBCXX -Wthread-safety -Wthread-safety-negative -Wimplicit-fallthrough \
	-Wfloat-equal -Wint-to-void-pointer-cast -Wused-but-marked-unused -Wdeprecated -Wunreachable-code-break \
	-Wunreachable-code-return -Wmissing-noreturn -std=gnu++14  -Werror=int-to-pointer-cast -Werror=pointer-to-int-cast  \
	-Werror=address-of-temporary -Werror=null-dereference -Werror=return-type  -Wno-error=return-type-c-linkage  \
	-o $@ $<

out/obj/x86/%.o: src/%.cc
	mkdir -p $(OUT_X86)
	mkdir -p out/obj/$(ARCH_X86)
	$(CC) \
	-I $(INCLUDES)/external/valgrind \
	-I $(INCLUDES)/external/valgrind/include \
	-I $(INCLUDES)/bionic/libc/private \
	-I $(INCLUDES)/art/runtime \
	-I $(INCLUDES)/art/compiler \
	-I $(INCLUDES)/art/compiler/optimizing \
	-I $(INCLUDES)/libnativehelper/include/nativehelper \
	-I $(INCLUDES)/external/libcxx/include \
	-isystem $(INCLUDES)/bionic/libc/arch-arm/include \
	-isystem $(INCLUDES)/bionic/libc/include \
	-isystem $(INCLUDES)/bionic/libc/kernel/uapi \
	-isystem $(INCLUDES)/bionic/libc/kernel/uapi/asm-arm \
	-isystem $(INCLUDES)/bionic/libm/include \
	-c    -fno-exceptions -Wno-multichar -msoft-float -ffunction-sections -fdata-sections -funwind-tables -fstack-protector-strong -Wa,--noexecstack -Werror=format-security \
	-D_FORTIFY_SOURCE=2 -fno-short-enums -no-canonical-prefixes -march=i686 -mfloat-abi=softfp -mfpu=vfpv3-d16 \
	-DANDROID -fmessage-length=0 -W -Wall -Wno-unused -Winit-self -Wpointer-arith -Werror=non-virtual-dtor \
	-Werror=address -Werror=sequence-point -Werror=date-time -DNDEBUG -g -Wstrict-aliasing=2 -DNDEBUG -UDEBUG  -D__compiler_offsetof=__builtin_offsetof \
	-Werror=int-conversion -Wno-reserved-id-macro -Wno-format-pedantic -Wno-unused-command-line-argument -fcolor-diagnostics \
	-nostdlibinc -target i686-linux-android -Bbuild/prebuilts/gcc/linux-x86/x86/x86-linux-android-4.9/x86-linux-android/bin    \
	-fvisibility-inlines-hidden -Wsign-promo  -Wno-inconsistent-missing-override \
	-mthumb -Os -fomit-frame-pointer -fno-strict-aliasing  -fno-rtti -DBUILD_NOUGAT -fno-rtti -ggdb3 -Werror \
	-Wextra -Wstrict-aliasing -fstrict-aliasing -Wunreachable-code -Wredundant-decls -Wunused -fvisibility=protected \
	-DART_DEFAULT_GC_TYPE_IS_CMS -DIMT_SIZE=64 -DART_TARGET -DART_BASE_ADDRESS=0x70000000 -DART_ENABLE_CODEGEN_arm \
	-DART_ENABLE_CODEGEN_arm64 -DART_ENABLE_CODEGEN_mips -DART_ENABLE_CODEGEN_mips64 -DART_ENABLE_CODEGEN_x86 \
	-DART_ENABLE_CODEGEN_x86_64 -DART_BASE_ADDRESS_MIN_DELTA=-0x1000000 -DART_BASE_ADDRESS_MAX_DELTA=0x1000000 -O2 \
	-DDYNAMIC_ANNOTATIONS_ENABLED=1 -UNDEBUG -D$(ANDROID_VERSION) -fPIC -D_USING_LIBCXX -Wthread-safety -Wthread-safety-negative -Wimplicit-fallthrough \
	-Wfloat-equal -Wint-to-void-pointer-cast -Wused-but-marked-unused -Wdeprecated -Wunreachable-code-break \
	-Wunreachable-code-return -Wmissing-noreturn -std=gnu++14  -Werror=int-to-pointer-cast -Werror=pointer-to-int-cast  \
	-Werror=address-of-temporary -Werror=null-dereference -Werror=return-type  -Wno-error=return-type-c-linkage  \
	-o $@ $<

.PHONY: clean
clean:
	rm -r out


.DEFAULT_GOAL := all
