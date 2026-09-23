# 迁移到 Weblate

把 FlCroc 的翻译流程从「改 JSON + 提 PR」迁到 Weblate 的操作手册。
涉及的文件、配置字段名都按 **Weblate 2026.10** 的界面原文标注，便于逐项对照。

---

## 0. 先看清要迁的是什么

仓库里跟 i18n 相关的文件分三类，**只有前两类该进 Weblate**：

| 路径 | 内容 | 进 Weblate？ |
|------|------|--------------|
| `assets/bundles/*.json` | App UI 文案。扁平 key→string，含 4 个头部键 + `_comment_*` 分组标记 | ✅ 组件 A |
| `assets/docs/*.json` | README 的内容块。**嵌套**对象（`feat_table` / `headings` / `arch_tree` / `stack_tree` / `ack_tree`） | ✅ 组件 B |
| `assets/templates/*.md` | `README.md` 与 `i18n.md` 的模板，含 `{{placeholder}}` | ❌ 留 git，模板不是译文 |
| `assets/.i18n_config/i18n.yml` | `root_lang` 配置 | ❌ 留 git |

当前语言：`en` / `zh` / `zh-Hant` / `ja` / `fr`，`en` 是 base。

---

## 1. 动手前必须确认的三个风险点

**① `langRegionCode` 是字符串数组。**
`assets/bundles/*.json` 的头部有 `"langRegionCode": ["US", "GB"]` 这样的数组值。
Weblate 的 JSON 格式文档只承诺「简单 key/value」和「嵌套 key」，**没有承诺字符串数组**，
也没有 `Supports plural`（JSON 格式明确是 `No`）。它可能被当成复数形式、被拆成多个值、
或直接报错。**导入试运行后第一件事就是核对这个键**；若处理不了，见第 6 节的方案 B。

**② 头部键和 `_comment_*` 会被当成可翻译字符串。**
JSON 格式的 `Supports read-only strings` 是 **`No`**，只能靠后天的 `read-only` flag 模拟
（见第 4 节）。共 4 个头部键（`lang` / `langCode` / `langRegion` / `langRegionCode`）
+ 若干 `_comment_*`，每语言都要处理一遍。

**③ Weblate 直接推 `main` 会触发完整构建。**
`release.yml` 的 `paths-ignore` 刻意**不包含** `assets/**`，所以任何 bundle 改动都会
跑一遍「测试 → i18n 重生成 → 出包 → 更新 nightly」。翻译提交会让 nightly 被反复覆盖。
**强烈建议用 PR 方式而不是直接推送**（见第 5 节），让翻译改动走人工合并。

---

## 2. 建项目，建两个组件

先建项目（比如 `FlCroc`），再在项目里建两个组件。

### 组件 A —— App UI 文案

| 字段 | 值 |
|------|-----|
| Component name | `App strings` |
| Source code repository | `https://github.com/576576/FlCroc.git` |
| Repository branch | `main` |
| File mask | `assets/bundles/*.json` |
| Monolingual base language file | `assets/bundles/en.json` |
| File format | **JSON file**（API id: `json`） |
| Edit base file | **关闭** —— 英文源串只从 git 改，避免 Weblate 里改出分歧 |
| Template for new translations | 留空；想让新语言一上来就有全套 key，可填 `assets/bundles/en.json` |
| Language filter | 留空（或按需只列要开放的语言） |

> 扁平文件用 `JSON file`。`JSON nested structure file` 也能读同样的文件，两者唯一区别是
> **新增 key 时**的写入位置 —— 扁平文件没有嵌套可猜，用 `json` 更贴合。

### 组件 B —— README 内容块

| 字段 | 值 |
|------|-----|
| Component name | `README content` |
| Source code repository | 同上 |
| Repository branch | `main` |
| File mask | `assets/docs/*.json` |
| Monolingual base language file | `assets/docs/en.json` |
| File format | **JSON nested structure file**（API id: `json-nested`） |
| Edit base file | 关闭 |
| Translation flags | `md-text` |

> 组件 B 必须是 nested 格式：`feat_table` / `headings` / `arch_tree` / `stack_tree` / `ack_tree`
> 都是嵌套对象。
>
> 加 `md-text` 是因为这些值里含 Markdown 链接（如
> `[i18n.md](docs/i18n.md)`）。它按「文件扩展名是 .md」自动挂载，这里是 `.json`，
> 所以要手动在 **Component configuration → Translation flags** 里补上，否则 Weblate
> 不会校验译文把链接改坏。

两个组件的 **Version control system** 都先选 `Git`，第 5 节再改成 `GitHub pull requests`。

---

## 3. 语言代码映射

仓库用的是 `zh-Hant`（连字符），Weblate 的规范代码是 `zh_Hant`（下划线）。

在 **项目配置 → Language aliases** 里加映射：

```
zh-Hant:zh_Hant
```

要点：

* 语言代码匹配**区分大小写**，必须和文件名里的写法完全一致 —— 写 `zh-hant` 无效。
* 再把 **项目配置 → Language code style** 设为 `BCP`，这样 Weblate 新建语言文件时
  会生成 `zh-Hant.json` 而不是 `zh_Hant.json`，与现有文件命名保持一致。
  （该设置只影响**新建**文件，不影响解析既有文件。）
* 导入完成后逐个核对 5 种语言都正确识别，尤其确认 `zh` 和 `zh-Hant` 没有被合并成同一个。

---

## 4. 把不可翻译的键设为只读

JSON 格式不支持文件内嵌只读标记，用 Weblate 的 `read-only` flag 补：

1. 进入组件 → **Source strings**。
2. 用搜索过滤出这些 key：`lang`、`langCode`、`langRegion`、`langRegionCode`、以及所有
   `_comment_*`（搜索框支持按 key 过滤）。
3. 全选 → **Bulk edit** → 在 **Flags** 字段填 `read-only` → 保存。

标记后这些串仍会显示，但译者改不动，文件里的原值会被原样保留。

> 组件级 / 项目级的 **Translation flags** 是**全局生效**的，不能按 key 匹配 ——
> 所以 `read-only` 只能走上面的批量编辑，或通过 API 逐串设置。

---

## 5. 双向同步

### 仓库 → Weblate（让 Weblate 及时拉取）

**方式一（推荐）：GitHub webhook。**
在 GitHub 仓库 **Settings → Webhooks → Add webhook**：

* **Payload URL**：Weblate 站点地址 + `/hooks/github/`
  （Hosted Weblate 即 `https://hosted.weblate.org/hooks/github/`；自建则换成自己的域名）
* **Content type**：`application/json`
* 触发事件：`push`（以及需要的话 `pull_request`）

前提是项目配置里的 **Enable hooks** 已打开，否则钩子会被忽略。
Hosted Weblate 若用官方 GitHub App 接入，webhook 由 App 自动管理，**不需要**手工加。

**方式二：CI 里主动触发拉取。**
在 `release.yml` 的 i18n 提交之后追加一步（用 secret 存 token）：

```bash
curl -sS -X POST \
  -H "Authorization: Token ${WEBLATE_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"operation":"pull"}' \
  "https://hosted.weblate.org/api/components/flcroc/app-strings/repository/"
```

组件级端点是 `/api/components/<project>/<component>/repository/`，
`operation` 可选 `pull` / `push` / `commit` / `reset` / `cleanup` / `file-sync` / `file-scan`，
加 `"background": true` 走异步并返回 `task_url`。

### Weblate → 仓库

在 **Component configuration** 里按目的选组合：

| 想要的效果 | Version control system | Repository push URL | Push branch |
|---|---|---|---|
| 不推送 | `Git` | 留空 | 留空 |
| 直接推主干（**不推荐**，见风险 ③） | `Git` | SSH URL | 留空 |
| 推到独立分支 | `Git` | SSH URL | 分支名，如 `l10n` |
| **从分支开 GitHub PR**（推荐） | `GitHub pull requests` | SSH URL | 分支名，如 `l10n` |
| 从 fork 开 GitHub PR | `GitHub pull requests` | 留空 | 留空 |

用 `GitHub pull requests` 后端需要配置 `GITHUB_CREDENTIALS`（API host 用 `api.github.com`），
token 需具备 **读写仓库内容** + **创建 Pull Request** 权限。

**推荐「从分支开 GitHub PR」**：翻译改动只落在一个 PR 上，人工 review 后再合进 `main`，
既不会反复触发 nightly 构建，也让 `assets/**` 的改动留下可追溯的评审记录。

另外把 **Push on commit** 按需打开或关闭：关掉后可以在
**Repository maintenance** 里手动推送，或走 `wlc push`。

---

## 6. 和现有 CI 的关系

**i18n job 保留，不用改逻辑。** 它按 `assets/bundles`、`assets/docs`、`assets/templates`
的 git subtree id 判断是否需要重生成 `docs/i18n.md` 与各语言 README。Weblate 的提交同样会
改这些子树，所以流程自洽 —— 只是触发源从「人改 JSON」变成了「Weblate 提交」。

需要注意的三点：

1. **`docs/i18n.md` 的覆盖率表和 Weblate 的统计会重复。** 保留它没坏处（它同时驱动
   README 的重生成），但也可以把 `assets/templates/i18n.md` 里的表格换成
   Weblate 的覆盖率徽章 + 项目链接。改 `assets/templates/` 会改变 templates hash，
   于是**下一次 CI 会自动重生成全部 README**，不需要手工改任何生成物。
2. **`assets/templates/i18n.md` 的 Contributing 段必须改。** 现在写的是
   「复制 `en.json` → 翻译 → 提 PR」，迁移后应指向 Weblate 项目地址，否则新人会绕过 Weblate
   直接改 JSON，产生两边冲突。
3. **翻译提交不会推进 build 号。** build 号由本地 `.githooks/pre-commit` 维护，
   Weblate 上不跑钩子，所以纯翻译提交的 `pubspec.yaml` 不变。对 nightly 而言是好事
   （翻译不必占用构建号），但如果某次翻译提交恰好是 `push main`，它会**触发**一次
   构建并覆盖 nightly tag，而构建号没变 —— 应用内的 nightly 更新通道按构建号比较，
   不会提示更新。这是预期行为。

### 方案 B：把头部键挪出 bundles（可选，更干净）

如果导入时 `langRegionCode` 数组确实处理不了，或者就是不想让元数据出现在翻译界面：
把这 4 个头部键从 `assets/bundles/*.json` 挪到独立的
`assets/.i18n_config/langs/<code>.json`，改 `lib/` 里读 `lang`/`langCode`/`langRegion`
的那处代码。好处是 bundles 变成纯译文，Weblate 侧不需要任何只读标记；
代价是动一次 Dart 代码 + 一次数据迁移。

---

## 7. 收尾清单

- [ ] 两个组件导入成功，5 种语言全部识别（`zh` 与 `zh-Hant` 未混淆）
- [ ] `langRegionCode` 数组在 Weblate 里显示正常（或已按方案 B 挪走）
- [ ] 4 个头部键 + 全部 `_comment_*` 已批量标记 `read-only`
- [ ] 组件 B 的 `md-text` flag 已加
- [ ] Language aliases 里有 `zh-Hant:zh_Hant`，Language code style = `BCP`
- [ ] 推送策略 = `GitHub pull requests` + `Push branch: l10n`（而非直接推 main）
- [ ] GitHub webhook 指向 `<weblate>/hooks/github/`，项目 Enable hooks 已开
- [ ] `assets/templates/i18n.md` 的 Contributing 段已指向 Weblate
- [ ] 在 Weblate 改一个词 → 确认 PR 生成 → 合并 → 确认 CI 的 i18n job 正常重生成

**回滚**：翻译文件始终是仓库里的 JSON，Weblate 只是编辑它们的一个前端。
停用组件、撤掉 webhook、把 `assets/templates/i18n.md` 改回原文案即可，
不涉及任何代码或数据结构变更（除非采用了方案 B）。
