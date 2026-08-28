# Rime 底座迁移：雾凇 → 白霜拼音 + 万象语言模型

Date: 2026-08-29

## What changed

Rime 输入方案底座由雾凇拼音切换为
[白霜拼音](https://github.com/gaboolic/rime-frost)（7.4 亿字语料重制词频，评测最佳
的开源词库），并叠加 [万象 LTS 语言模型](https://github.com/amzxyz/RIME-LMDG)
（octagram 语法模型：词库词频不动、按上下文动态加权候选，解决长句分词与联想）。

底座不是 chezmoi 普通文件，而是 `.chezmoiexternals/rime.toml` 里的 archive external
（336h 自动刷新；archive 默认 `exact = false`，刷新不会删除目录内未管理的文件，
因此 userdb / build / gram 等运行时文件安全）。Repo 侧已完成：

- `.chezmoiexternals/rime.toml`：两个目录（`.config/Rime`、`.local/share/rime-ls`）
  的 URL 从雾凇 `full.zip` 换为白霜 `rime-frost-schemas.zip`
  （`releases/latest/download`，nightly 是 prerelease 不会被 latest 命中）；
  exclude 增加 `cn_dicts/tencent.dict.yaml`（白霜 zip 自带但默认不 import，
  不 exclude 会被 external 视为缺失而每次恢复，白删 13MB 磁盘）。
- `dot_config/Rime/` overlay 改名：`rime_ice.custom.yaml` → `rime_frost.custom.yaml`
  （新增 grammar patch）、`rime_ice_custom.dict.yaml` → `rime_frost_custom.dict.yaml`
  （import_tables 换为白霜词库 + 全部 cn_dicts_cell 细胞词库 + 个人 mydict，
  **不再挂 tencent 词向量**，保持白霜词频纯净）、
  `double_pinyin_flypy.custom.yaml` → `rime_frost_double_pinyin_flypy.custom.yaml`
  （全拼/双拼共用 `rime_frost_custom` 词库与 userdb 的 trick 保留）。
- `default.custom.yaml`：schema_list 换为 `rime_frost` + `rime_frost_double_pinyin_flypy`。
- `dot_local/share/rime-ls/` 三个 symlink tmpl 同步改名指向新文件。

Residual（本条目逐台执行的部分）：URL 切换只让 apply 重新下载并解包新 zip，
archive 默认非 exact，**雾凇旧文件会原样残留**；旧 userdb 挂在 `rime_ice_custom`
名下；万象 gram（约 400MB）不在任何 zip 里，需单独下载。

注意：`.external.rime` 默认 false（`.chezmoidata.toml`）。启用 chezmoi 管理 Rime
的机器在本机 `~/.config/chezmoi/chezmoi.toml` 加：

```toml
[data.external]
    rime = true
```

## Impact

- 所有使用 Rime 的机器（Squirrel / fcitx5-rime / ibus-rime / rime-ls）。
- 不执行迁移的后果：schema_list 已指向 `rime_frost*`，但目录里只有雾凇方案，
  输入法不可用；`rime_ice*.custom.yaml`/`rime_ice_custom.dict.yaml` 残留成为孤儿。
- 需要鼠须管 ≥ 1.1.0（1.1.2 起 lua/octagram/predict 插件内置）；Linux 需
  `librime-plugin-octagram`。

## Migration steps

设 `RIME_DIR` 为该机实际用户目录（Squirrel 默认 `~/Library/Rime`，本机是
symlink → `~/.config/Rime`；fcitx5 为 `~/.local/share/fcitx5/rime`）：

```zsh
# 0) 探明目录 + 版本检查（Squirrel ≥ 1.1.0，含 octagram 插件）
ls -ld ~/.config/Rime ~/Library/Rime 2>/dev/null
defaults read /Applications/Squirrel.app/Contents/Info.plist CFBundleShortVersionString
RIME=~/.config/Rime   # 按上一步实际结果调整
```

```zsh
# 1) 备份（运行时文件 + 将要手工清理的雾凇残留都在里面）
cp -a "$RIME" "$RIME.backup-$(date +%Y%m%d)"
```

```zsh
# 2) 换底座：URL 已在 repo 中切换，chezmoi 检测到 external URL 变化会重新下载
chezmoi apply
# 若 external 未刷新（缓存异常），强制：
# chezmoi apply --refresh-externals
# 验证白霜文件已落地：
ls "$RIME/rime_frost.schema.yaml" "$RIME/rime_frost_double_pinyin_flypy.schema.yaml"
```

```zsh
# 3) 清理雾凇残留（archive 非 exact，这些 unmanaged 文件不会自动消失）。
#    zsh 注意：rm 的 glob 用 setopt null_glob，否则 nomatch 会中止整条命令。
#    雾凇 full.zip 与白霜 zip 布局不同：雾凇把字表/部分 lua 放在 root，
#    白霜全部在 cn_dicts/ lua/ opencc/ 下，root 副本全部是残留。
#    保留：squirrel.yaml / weasel.yaml（白霜 zip 不含前端主题，保留维持外观）。
cd "$RIME" && rm -f \
  rime_ice.dict.yaml rime_ice.schema.yaml rime_ice.custom.yaml \
  rime_ice_custom.dict.yaml double_pinyin_flypy.custom.yaml \
  double_pinyin.schema.yaml double_pinyin_abc.schema.yaml \
  double_pinyin_jiajia.schema.yaml double_pinyin_mspy.schema.yaml \
  double_pinyin_sogou.schema.yaml double_pinyin_ziguang.schema.yaml \
  double_pinyin_flypy.schema.yaml \
  t9.schema.yaml symbols_caps_v.yaml recipe.yaml \
  41448.dict.yaml 8105.dict.yaml base.dict.yaml ext.dict.yaml \
  others.dict.yaml others.txt en.dict.yaml en_ext.dict.yaml \
  cn_dicts/tencent.dict.yaml \
  emoji.json emoji.txt \
  cn_en.txt cn_en_abc.txt cn_en_double_pinyin.txt cn_en_flypy.txt \
  cn_en_jiajia.txt cn_en_mspy.txt cn_en_sogou.txt cn_en_ziguang.txt \
  en_dicts/cn_en_jiajia.txt \
  autocap_filter.lua calc_translator.lua corrector.lua date_translator.lua \
  debuger.lua en_spacer.lua force_gc.lua is_in_user_dict.lua \
  long_word_filter.lua lunar.lua number_translator.lua pin_cand_filter.lua \
  reduce_english_filter.lua search.lua select_character.lua t9_preedit.lua \
  unicode.lua v_filter.lua \
  lua/uuid.lua lua/convert_ar_num_to_zh.lua \
  lua/cold_word_drop/logger.lua lua/cold_word_drop/reduce_freq_words.lua
rm -rf "$RIME/cold_word_drop"
```

```zsh
# 4) 下载万象 LTS 语言模型（约 400MB，一次性；archive 刷新不会删它）
curl -fL -o "$RIME/wanxiang-lts-zh-hans.gram" \
  https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram
```

```zsh
# 5) 迁移用户词库：旧 dict 名 rime_ice_custom → rime_frost_custom
#    （全拼/双拼本来就共用这一份 userdb；不存在则跳过）
[ -d "$RIME/rime_ice_custom.userdb" ] && \
  mv "$RIME/rime_ice_custom.userdb" "$RIME/rime_frost_custom.userdb"
rm -rf "$RIME/rime_ice.userdb"
```

```zsh
# 6) nvim rime-ls 的隔离目录（同走 external，同样有残留清理）：
LS=~/.local/share/rime-ls
if [ -d "$LS" ]; then
  cd "$LS" && rm -f \
    rime_ice.dict.yaml rime_ice.schema.yaml rime_ice.custom.yaml \
    rime_ice_custom.dict.yaml double_pinyin_flypy.custom.yaml \
    double_pinyin.schema.yaml double_pinyin_flypy.schema.yaml \
    symbols_caps_v.yaml t9.schema.yaml cn_dicts/tencent.dict.yaml \
    lua/uuid.lua lua/convert_ar_num_to_zh.lua \
    lua/cold_word_drop/logger.lua lua/cold_word_drop/reduce_freq_words.lua
  [ -d "$LS/rime_ice_custom.userdb" ] && \
    mv "$LS/rime_ice_custom.userdb" "$LS/rime_frost_custom.userdb"
fi
# symlink overlay（symlink_rime_frost* 等）由第 2 步的 chezmoi apply 一并更新
```

```zsh
# 7) 重新部署 + 验证
"/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --reload
sleep 12   # 等部署完成
grep -A3 '^grammar:' "$RIME/build/rime_frost.schema.yaml"   # language 应为 wanxiang-lts-zh-hans
setopt null_glob; rm -f "$RIME"/build/rime_ice* "$LS"/build/rime_ice*   # 清 build 旧缓存
```

- 手动验证：输入 `jianjiandejiubuzaiyile` 应首选「渐渐地就不在意了」而非
  「渐渐地不再一乐」；`Ctrl+`` 方案选单里应为「白霜拼音」+ 小鹤双拼；
  pin_candidate 置顶与 custom_phrase 短语行为不变。
- 若用户词库丢失（userdb 改名未生效）：用第 1 步备份里的 `sync/` 通过 Rime
  菜单「用户词典同步」恢复。
- 观察期调参：grammar 参数在 `rime_frost.custom.yaml`，若长句仍纠结可按
  RIME-LMDG wiki 微调 `collocation_penalty` / `non_collocation_penalty`；
  白霜 zip 自带 `zh-moqi.gram`（墨奇模型）可作为备选，把
  `grammar/language` 改为 `zh-moqi` 即可。
- 确认稳定后删除 `*.backup-*` 目录。

## Completion condition

```zsh
test -f ~/.config/Rime/rime_frost.schema.yaml            # 白霜底座就位（路径按机器调整）
! ls ~/.config/Rime/rime_ice* 2>/dev/null                # 雾凇残留已清
test -f ~/.config/Rime/wanxiang-lts-zh-hans.gram         # 万象模型就位
grep -q 'wanxiang-lts-zh-hans' ~/.config/Rime/build/rime_frost.schema.yaml  # 模型已生效
chezmoi diff | grep -i rime || true                      # chezmoi 无 Rime 残留 diff
```

全部满足后写本机标记：`mkdir -p ~/.local/state/chezmoi-migrations && date > ~/.local/state/chezmoi-migrations/2026-08-29-rime-frost-migration`。
