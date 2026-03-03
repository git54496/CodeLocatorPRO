# CodeLocatorMCP Workspace

当前目录已按四部分拆分：

1. `core`：核心 locate 代码（原 `CodeLocatorApp`）
2. `plugin`：IDE 插件代码（原 `CodeLocatorPlugin`）
3. `viewer`：Web Viewer 前端资源
4. `mcp`：MCP/CLI 适配层与本地 HTTP 服务

## 目录说明

- `core`
  - Android 侧抓取、分析、协议模型与动作执行核心逻辑。
- `plugin`
  - Android Studio / IntelliJ 插件实现，依赖 `../core/CodeLocatorModel`。
- `viewer`
  - Viewer 前端页面（`index.html`），由 `mcp` 在本地 HTTP 服务中加载。
- `mcp`
  - `grab / inspect / viewer / mcp(stdio)` 统一入口。

## mcp 构建与使用

```bash
cd /Users/yebingyue/code/baron/CodeLocatorMCP/mcp
./gradlew installDist
```

可执行文件：

```bash
/Users/yebingyue/code/baron/CodeLocatorMCP/mcp/build/install/CodeLocatorMCPAdapter/bin/CodeLocatorMCPAdapter
```

常用命令：

```bash
# 读取历史抓取
CodeLocatorMCPAdapter grab file --json

# 实时抓取
CodeLocatorMCPAdapter grab live --json

# 打开 Viewer
CodeLocatorMCPAdapter viewer open --grab-id <grab_id> --json

# 启动 MCP (stdio)
CodeLocatorMCPAdapter mcp
```

## 启动 Viewer 脚本

```bash
cd /Users/yebingyue/code/baron/CodeLocatorMCP
./start_viewer.zsh 49622
```
