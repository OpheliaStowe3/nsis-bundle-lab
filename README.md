# nsis-bundle-lab

NSIS 捆绑包构建流水线（**仅限授权红队演练使用**）。

- `bundle.nsi` — 捆绑脚本：静默释放载荷 + 官方宿主安装器，先拉起载荷，再 runas 走官方安装流程
- `.github/workflows/build.yml` — Actions 流水线：windows runner 提取 calc.exe 作测试载荷 → ubuntu runner 用 makensis 打包
- `logo.ico` — 产物图标

宿主安装器通过 release `inputs` 传入，不进 git。
