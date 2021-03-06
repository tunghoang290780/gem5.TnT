#!/usr/bin/env bash

# Copyright (c) 2019, University of Kaiserslautern
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Author: Éder F. Zulian

DIR="$(cd "$(dirname "$0")" && pwd)"
TOPDIR=$DIR/../..
source $TOPDIR/common/defaults.in
source $TOPDIR/common/util.in
currtime=$(date "+%Y.%m.%d-%H.%M.%S")

arch="ALPHA"
mode="opt"
gem5_elf="build/$arch/gem5.$mode"

pushd $ROOTDIR/gem5
if [[ ! -e $gem5_elf ]]; then
	build_gem5 $arch $mode
fi
popd

sys='m5_system_2.0b3'
tarball="${sys}.tar.bz2"
if [[ ! -e $tarball ]]; then
	wgethis=("$FSDIRALPHA:http://www.m5sim.org/dist/current/$tarball")
	wget_into_dir wgethis[@]
fi

pushd ${FSDIRALPHA}
if [[ ! -d ${sys} ]]; then
	tar -xaf ${tarball}
fi
popd

syspath="$FSDIRALPHA/${sys}"
diskpath="${syspath}/disks"
disk="${diskpath}/linux-latest.img"
kernel="${syspath}/binaries/vmlinux"
cfgscript="configs/example/fs.py"
disk_opt="--disk-image=${disk}"
kernel_opt="--kernel=${kernel}"
#script_opt="--script=$DIR/boot-linux.rcS"

pushd $ROOTDIR/gem5
git checkout configs/common/FSConfig.py
output_dir="alpha_linux_$currtime"
mkdir -p ${output_dir}
logfile=${output_dir}/gem5.log
export M5_PATH="${syspath}":${M5_PATH}
$gem5_elf -d $output_dir $cfgscript $tlm_options $kernel_opt $disk_opt $script_opt 2>&1 | tee $logfile
popd

