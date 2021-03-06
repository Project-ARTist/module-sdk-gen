#!/bin/bash
set -e

ssh_config=~/.artist-sdk/ssh-config
if [ ! -f $ssh_config ]; then
	echo "~/.artist-sdk/ssh-config file doesn't exist."
	exit
fi

. $ssh_config
if [ -z ${ssh_identity+x} ] ||  [ -z ${aosp_root_path+x} ]; then
	echo "ssh_identity or aosp_root_path not set in $ssh_config."
	exit
fi


if [ -z ${archs} ]; then
    echo "archs not set, defaulting to arm"
    archs=(arm)
fi


include_folders=(
	"art/compiler/"
	"external/libcxx/include"
	"bionic/libc/include"
	"bionic/libc/kernel/uapi/linux"
	"bionic/libc/kernel/uapi/asm-arm/asm"
	"bionic/libc/kernel/uapi/asm-generic"
	"bionic/libc/arch-arm/include"
	"bionic/libc/private"
	"bionic/libm/include"
)

for i in ${include_folders[@]}; do
	echo "Fetching $i"
	mkdir -p include/$i
	rsync -aSz $ssh_identity:$aosp_root_path/$i/ include/$i/
done

include_headers=(
	"external/valgrind/include/valgrind.h"
	"external/valgrind/memcheck/memcheck.h"
	"art/runtime/base/*.h"
	"art/runtime/*.h"
	"art/runtime/arch/*.h"
	"art/runtime/entrypoints/quick/*.h"
	"art/runtime/entrypoints/jni/*.h"
	"art/runtime/mirror/*.h"
	"art/runtime/gc/*.h"
	"art/runtime/gc/collector/*.h"
	"art/runtime/gc/space/*.h"
	"art/runtime/gc/accounting/*.h"
	"art/runtime/gc/allocator/*.h"
	"art/runtime/quick/*.h"
	"art/runtime/jit/*.h"
	"libnativehelper/include/nativehelper/jni.h"
	"external/dlmalloc/malloc.h"
	"art/compiler/trampolines/trampoline_compiler.h"
	"art/compiler/*.h"
	"art/compiler/dex/quick/*.h"
	"art/compiler/dex/quick_compiler_callbacks.h"
	"art/compiler/dex/*.h"
	"art/compiler/optimizing/artist/api/env/*.h"
	"art/compiler/optimizing/artist/api/filtering/*.h"
	"art/compiler/optimizing/artist/api/injection/*.h"
	"art/compiler/optimizing/artist/api/io/*.h"
	"art/compiler/optimizing/artist/api/modules/*.h"
	"art/compiler/optimizing/artist/api/utils/*.h"
	"art/compiler/linker/*.h"
	"art/compiler/linker/x86/relative_patcher_x86_base.h"
	"art/compiler/linker/x86/relative_patcher_x86.h"
	"art/compiler/linker/arm/relative_patcher_thumb2.h"
	"art/compiler/linker/arm/relative_patcher_arm_base.h"
	"art/compiler/linker/x86_64/relative_patcher_x86_64.h"
	"art/compiler/linker/arm64/relative_patcher_arm64.h"
	"art/compiler/driver/*.h"
	"art/compiler/jit/jit_compiler.h"
	"art/compiler/utils/mips/managed_register_mips.h"
	"art/compiler/utils/mips/constants_mips.h"
	"art/compiler/utils/mips/assembler_mips.h"
	"art/compiler/utils/mips64/managed_register_mips64.h"
	"art/compiler/utils/mips64/constants_mips64.h"
	"art/compiler/utils/mips64/assembler_mips64.h"
	"art/compiler/utils/x86/assembler_x86.h"
	"art/compiler/utils/x86/managed_register_x86.h"
	"art/compiler/utils/x86/constants_x86.h"
	"art/compiler/utils/arm/managed_register_arm.h"
	"art/compiler/utils/arm/assembler_arm_test.h"
	"art/compiler/utils/arm/assembler_arm32.h"
	"art/compiler/utils/arm/assembler_thumb2.h"
	"art/compiler/utils/arm/constants_arm.h"
	"art/compiler/utils/arm/assembler_arm.h"
	"art/compiler/utils/x86_64/constants_x86_64.h"
	"art/compiler/utils/x86_64/assembler_x86_64.h"
	"art/compiler/utils/x86_64/managed_register_x86_64.h"
	"art/compiler/utils/*.h"
	"art/compiler/utils/arm64/managed_register_arm64.h"
	"art/compiler/utils/arm64/constants_arm64.h"
	"art/compiler/utils/arm64/assembler_arm64.h"
	"art/compiler/debug/*.h"
	"art/compiler/debug/dwarf/*.h"
	"art/compiler/jni/quick/mips/calling_convention_mips.h"
	"art/compiler/jni/quick/mips64/calling_convention_mips64.h"
	"art/compiler/jni/quick/*.h"
	"art/compiler/jni/quick/x86/calling_convention_x86.h"
	"art/compiler/jni/quick/arm/calling_convention_arm.h"
	"art/compiler/jni/quick/x86_64/calling_convention_x86_64.h"
	"art/compiler/jni/quick/arm64/calling_convention_arm64.h"
)
for i in ${include_headers[@]}; do
	echo "Fetching $i"
	rsync -aSzR $ssh_identity:$aosp_root_path/./$i include/
done

build_toolchain_dirs=(
	"prebuilts/clang/host/linux-x86/clang-2690385"
)
i=1

for arch in ${archs[@]}; do
    if [ "$arch" == "arm" ]; then
        build_toolchain_dirs[i]="prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9"
        let i=i+1
    fi
    if [ "$arch" == "x86" ]; then
        build_toolchain_dirs[i]="prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9"
        let i=i+1
    fi
done

for i in ${build_toolchain_dirs[@]}; do
	echo "Fetching $i"
	mkdir -p toolchain/$i
	rsync -a $ssh_identity:$aosp_root_path/$i/ toolchain/$i/
done

out_prefix="out/target/product/"

libs=(
	"/obj/lib/crtbegin_so.o"
	"/obj/lib/crtend_so.o"
	"/obj/lib/libart.so"
	"/obj/lib/liblz4.so"
	"/obj/lib/liblzma.so"
	"/obj/lib/libvixl.so"
	"/obj/lib/libcutils.so"
	"/obj/lib/libc++.so"
	"/obj/lib/libdl.so"
	"/obj/lib/libc.so"
	"/obj/lib/libm.so"
	"/obj/lib/libart-compiler.so"
	"/obj/STATIC_LIBRARIES/libcompiler_rt-extras_intermediates/libcompiler_rt-extras.a"
)

libs_arm=(
	"/obj/STATIC_LIBRARIES/libunwind_llvm_intermediates/libunwind_llvm.a"
)



for arch in ${archs[@]}; do
    target="generic"
    if [ "$arch" == "arm" ]; then
	merged_libs=("${libs[@]}" "${libs_arm[@]}")
        mkdir -p toolchain/out/target/product/$target/obj/STATIC_LIBRARIES/libunwind_llvm_intermediates
    elif [ "$arch" == "x86" ]; then
        target=$target"_x86"
	merged_libs=("${libs[@]}")
    fi

    mkdir -p toolchain/out/target/product/$target/obj/lib
    mkdir -p toolchain/out/target/product/$target/obj/STATIC_LIBRARIES/libcompiler_rt-extras_intermediates

    for lib in ${merged_libs[@]}; do
        lib=$out_prefix$target$lib
        echo "Fetching $lib"
        rsync -a $ssh_identity:$aosp_root_path/$lib toolchain/$lib
    done

done

