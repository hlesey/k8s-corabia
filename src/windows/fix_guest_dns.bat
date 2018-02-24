@echo off

REM fixing the bug when the host OS gues into sleep/hibernation:
REM https://www.virtualbox.org/ticket/14374
REM =============================================================================================

set vbox_manage="C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

set vm_name="master"
echo "fixing DNS for %vm_name%..."
%vbox_manage% controlvm %vm_name% setlinkstate1 off
%vbox_manage% controlvm %vm_name% setlinkstate1 on

set vm_name="node01"
echo "fixing DNS for %vm_name%..."
%vbox_manage% controlvm %vm_name% setlinkstate1 off
%vbox_manage% controlvm %vm_name% setlinkstate1 on

set vm_name="node02"
echo "fixing DNS for %vm_name%..."
%vbox_manage% controlvm %vm_name% setlinkstate1 off
%vbox_manage% controlvm %vm_name% setlinkstate1 on

set vm_name="dockerhost"
echo "fixing DNS for %vm_name%..."
%vbox_manage% controlvm %vm_name% setlinkstate1 off
%vbox_manage% controlvm %vm_name% setlinkstate1 on