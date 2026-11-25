
// Jacob's ted configuration: everything here is a personal choice layered on the editor's
// defaults. ~/.config/ted/init.rhai links here; `M-x reload-init` reapplies it.

// Binds `C-c <key>`, and `C-c C-<key>` for when Ctrl is still held.
fn bind_cc(key, command) {
    bind([`C-c ${key}`, `C-c C-${key}`], command);
}

// ---------------------------------------------------------------------------------------
// Editing
// ---------------------------------------------------------------------------------------
set("tab_width", 2);

bind("C-c C-c", "comment-region");
bind_cc("u", "redo");
bind("C-j", "jump");
bind("markdown", "C-c C-d", "markdown-toggle-checkbox");

// ---------------------------------------------------------------------------------------
// Windows, buffers & display
// ---------------------------------------------------------------------------------------
bind("M-[", "previous-window");
bind("M-]", "other-window");
// Terminals pass keys to the program unless bound here.
bind("terminal", "M-[", "previous-window");
bind("terminal", "M-]", "other-window");
bind("terminal", "C-h [", "term-view-mode");
// C-g cancels in ted rather than reaching the program (Claude Code has a mode behind it).
bind("terminal", "C-g", "keyboard-quit");
// Cycle the workspace's terminals in the current window: `C-M-n` left, `C-M-p` right.
// Only from a terminal (live or in view mode), so other buffers keep the keys.
for keymap in ["terminal", "terminal-view"] {
    bind(keymap, "C-M-n", "term-previous");
    bind(keymap, "C-M-p", "term-next");
}

bind(["C-x j", "C-x C-j"], "switch-to-buffer");
bind(["C-x r", "C-x C-r"], "recentf-open-files");
bind_cc("b", "switch-to-scratch");

bind("M-z", "toggle-word-wrap");
bind_cc("l", "toggle-word-wrap");
bind_cc("t", "toggle-theme");

// Workspaces and window layouts live under `C-x`, which terminals pass to ted, unlike `C-c`.
// The workspace switcher also creates and manages them.
bind(["C-x w", "C-x C-w"], "workspace-switch");

// Window layouts: `C-x l s <n>` saves slot n, `C-x l <n>` (or `C-c <n>`) restores it.
for slot in 1..=5 {
    bind([`C-x l ${slot}`, `C-x C-l ${slot}`, `C-c ${slot}`, `C-c C-${slot}`], `restore-window-layout ${slot}`);
    bind([`C-x l s ${slot}`, `C-x C-l s ${slot}`], `save-window-layout ${slot}`);
}

// ---------------------------------------------------------------------------------------
// Search, navigation & builds
// ---------------------------------------------------------------------------------------
bind_cc("r", "replace-string");
alias("rs", "replace-string");
bind_cc("s", "file-search");
bind_cc("n", "compile");
bind("C-c m", "recompile");
bind("M-m", "find-references");

// ---------------------------------------------------------------------------------------
// Help
// ---------------------------------------------------------------------------------------
bind("C-c h", "describe-prefix C-c");

// ---------------------------------------------------------------------------------------
// Language servers
// ---------------------------------------------------------------------------------------
mode("go", #{
    // Sort, add and remove imports on every save. The rest of the file is left as written.
    "lsp.save_actions": ["source.organizeImports"],
    "lsp.settings": #{
        staticcheck: true,
        completeUnimported: true,
        analyses: #{ composites: false, ST1000: false, ST1020: false, ST1021: false, ST1022: false },
    },
});
