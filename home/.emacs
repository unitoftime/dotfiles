;; .emacs -> (load "~/git/config/linux/init.el")
;; --------------------------------------------------------------------------------

;; --------------------------------------------------------------------------------
;; Basic configurations that should always load regardless of package loading errors
;; --------------------------------------------------------------------------------
(setq ring-bell-function 'ignore)

;;Disable backups and autosaves
(setq make-backup-files nil)
(setq auto-save-default nil)

(define-key global-map (kbd "C-c C-c") 'comment-region)


(tool-bar-mode -1) ;; Disable toolbar
(menu-bar-mode -1) ;; Disable Menu
(scroll-bar-mode -1) ;; Disable scrollbar
(setq inhibit-startup-screen t) ;; turn off help screen
(global-display-line-numbers-mode 1) ;;turn on line numbers

;; make it easy to change between buffers
(global-set-key "\M-[" 'previous-multiframe-window)
(global-set-key "\M-]" 'next-multiframe-window)

(with-eval-after-load 'vterm
  ;; Brute-force map the keys directly inside vterm
  (define-key vterm-mode-map "\M-[" 'previous-multiframe-window)
  (define-key vterm-mode-map "\M-]" 'next-multiframe-window))

;; --------------------------------------------------------------------------------
;; Automatic package loading
;; --------------------------------------------------------------------------------
;; first, declare repositories
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
;        ("marmalade" . "http://marmalade-repo.org/packages/")
        ("melpa" . "http://melpa.org/packages/")))

;; Init the package facility
(require 'package)
(package-initialize)

;; Declare packages
(setq my-packages
      '(
	exec-path-from-shell
        helm
        magit
        markdown-mode
        yaml-mode
        json-mode
        toml-mode
;        keychain-refresh-environment
        keychain-environment
	whitespace
;;	text-scale-mode
        go-mode
        lsp-mode
        rust-mode
        nginx-mode
        web-mode
        ace-jump-mode
        ;dumb-jump
        catppuccin-theme
	zenburn-theme
        company
        ;; projectile
	))

;; Iterate on packages and install missing ones
(dolist (pkg my-packages)
  (unless (package-installed-p pkg)
    (package-install pkg)))

;; --- Theme ---
;(require 'catppuccin-theme)
;(load-theme 'catppuccin :no-confirm)
;(load-theme 'zenburn t)
(load-theme 'tango-dark t)

;; ------------------ Config -------------------------
(setq whitespace-line-column 1000)
(setq whitespace-style '(face trailing lines-tail))
;;(setq whitespace-style '(face lines-tail))
(setq whitespace-line "font-lock-warning-face")
(global-whitespace-mode t)

(require 'exec-path-from-shell)
(exec-path-from-shell-copy-env "SSH_AGENT_PID")
(exec-path-from-shell-copy-env "SSH_AUTH_SOCK")
(keychain-refresh-environment)

;; https://stackoverflow.com/questions/12224909/is-there-a-way-to-get-my-emacs-to-recognize-my-bash-aliases-and-custom-functions/12229404#12229404
(setq shell-file-name "bash")
(setq shell-command-switch "-ic")

;; Setup Path - https://www.emacswiki.org/emacs/ExecPath
(setenv "PATH" (concat (getenv "PATH") ":/home/jacob/go/bin/"))
(setq exec-path (append exec-path '("/home/jacob/go/bin/")))

;; ------------------ Bindings ----------------------
(define-key global-map (kbd "C-j") 'ace-jump-mode)
;(define-key global-map (kbd "C-c C-c") 'comment-region)

;; (default-text-scale-mode)
;; (define-key global-map (kbd "C-c ]") (lambda () (interactive) (default-text-scale-increment 40)))
;; (define-key global-map (kbd "C-c [") (lambda () (interactive) (default-text-scale-reset)))

;;------------------------------------------------------------------------------
;; Package Configs
;;------------------------------------------------------------------------------
(use-package ag
  :ensure t)

(use-package vterm
  :ensure t)
;; Force standard terminal capabilities so CLIs redraw instead of append
(setq vterm-environment
      '("TERM=xterm-256color"
        "COLORTERM=truecolor"))


(defun my-web-mode-hook ()
  (local-set-key (kbd "C-c C-c") 'web-mode-comment-or-uncomment))

(add-hook 'web-mode-hook 'my-web-mode-hook)

;; display a list of recent files
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-saved-items 2048)
(setq recentf-max-menu-items 32)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)
;(global-set-key "\C-x\ \C-j" 'recentf-open-files)

;; Helm Mode Bindings
(helm-mode 1)
(setq helm-move-to-line-cycle-in-source nil) ;; Lets you C-n through sections
(global-set-key "\C-x\ \C-r" 'helm-recentf)
;(global-set-key "\C-x\C-b" 'helm-locate)
;(global-set-key "\C-x\C-b" 'helm-mini)
(global-set-key "\C-x\C-j" 'helm-mini)
;(setq helm-xref-candidate-formatting-function 'helm-xref-format-candidate-full-path)
(setq helm-xref-candidate-formatting-function 'helm-xref-format-candidate-long)

;; Magit bindings
(global-set-key "\C-x\ g" 'magit-status)


;; markdown mode
(defun my/markdown-smart-tab ()
  "If on a list item, indent (demote) it. Otherwise, run normal tab behavior."
  (interactive)
  (if (markdown-list-item-at-point-p)
      (markdown-demote-list-item)
    (markdown-cycle))) ;; Or use (indent-for-tab-command) if you hate folding

(defun my/markdown-smart-backtab ()
  "If on a list item, outdent (promote) it. Otherwise, cycle global visibility."
  (interactive)
  (if (markdown-list-item-at-point-p)
      (markdown-promote-list-item)
    (markdown-shifttab)))

(with-eval-after-load 'markdown-mode
  (define-key markdown-mode-map (kbd "S-TAB") nil)
  (define-key markdown-mode-map (kbd "TAB") nil)
  (define-key markdown-mode-map (kbd "<C-return>") 'markdown-insert-list-item)
  (define-key markdown-mode-map (kbd "<S-return>") 'markdown-insert-list-item)

  (define-key markdown-mode-map (kbd "<tab>") 'my/markdown-smart-tab)
  (define-key markdown-mode-map (kbd "<backtab>") 'my/markdown-smart-backtab)
)

(defface my/markdown-dim-checked-face
  '((t (:foreground "#808080" :inherit shadow)))
  "Face for completed markdown tasks to make them less visible.")

(with-eval-after-load 'markdown-mode
  (font-lock-add-keywords 'markdown-mode
   '(("^\\s-*[-*+] \\[[xX]\\].*$"                ; 1. Match the checked line (Parent)
      (0 'my/markdown-dim-checked-face t)        ; 2. Dim the parent
      ("\\(?:\n[ \t]*[^ \t-*+\n].*\\)+"          ; 3. Match following lines that are NOT bullets
       nil nil                                   ; (pre/post-match forms - leave empty)
       (0 'my/markdown-dim-checked-face t))))    ; 4. Dim those lines too
   'append))



;; (require 'projectile)
;; ;; Recommended keymap prefix on macOS
;; ;; (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
;; ;; Recommended keymap prefix on Windows/Linux
;; (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
;; (projectile-mode +1)


;; ;; Dumb Jump Bindings
;; (global-set-key "\M-." 'godef-jump)
;; (global-set-key "\M-," 'dumb-jump-back)

;; Recompile binding
(setq compile-command "make")

;; unbind html mode from using C-c C-c
(with-eval-after-load 'mhtml-mode
  (define-key mhtml-mode-map (kbd "C-c C-c") nil)) ;; unbind

;; (global-set-key "\C-c\ n" 'compile)
(global-set-key "\C-c\ n" 'project-compile)
(global-set-key "\C-c\ m" 'recompile)
(setq compilation-auto-jump-to-first-error nil)
(setq compilation-scroll-output 1) ;;Follow-mode

(global-set-key "\C-c\ r" 'replace-string)
(global-set-key "\C-c\ s" 'helm-do-grep-ag)

;; Aliases
(defalias 'rs 'replace-string)
(defalias 'ag 'helm-do-grep-ag)

;; default to use only spaces
(setq-default indent-tabs-mode nil)

;; avoid accidental closing
(defun ask-before-closing ()
  "Ask whether or not to close, and then close if y was pressed"
  (interactive)
  (if (y-or-n-p (format "Are you sure you want to exit Emacs? "))
      (if (< emacs-major-version 22)
          (save-buffers-kill-terminal)
        (save-buffers-kill-emacs))
    (message "Canceled exit")))

;(when window-system
(global-set-key (kbd "C-x C-c") 'ask-before-closing);)

;; omit uninteresting files from dired
(require 'dired-x)
(setq-default dired-omit-files-p t)
(setq dired-omit-files
      (concat dired-omit-files "\\|^\\..+$"))

(put 'erase-buffer 'disabled nil) ;; What is this????
;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(ansi-color-faces-vector
;;    [default default default italic underline success warning error])
;;  '(custom-enabled-themes (quote (tango-dark)))
;;  '(package-selected-packages
;;    (quote
;;     (god-mode keyfreq hydra ace-jump-mode dumb-jump helm haskell-mode magit go-mode)))
;;  '(tool-bar-mode nil))

;; (setq gofmt-command "goimports")
;; ;(add-to-list 'load-path "/home/you/somewhere/emacs/")
;; (require 'go-mode-load)
;; (add-hook 'before-save-hook 'gofmt-before-save)

;;indents as 2 spaces
(setq default-tab-width 2)
(add-hook 'go-mode-hook
          (lambda ()
            (setq indent-tabs-mode 1)
            (setq tab-width 2)))

(add-to-list 'same-window-buffer-names "*compilation*")

(add-to-list 'auto-mode-alist '("\\.cppm\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.tgo\\'" . go-mode))


;; Remove foreground from highlights, so that highlight bars show syntax highlighting
(set-face-foreground 'highlight nil)
;(set-face-background 'highlight nil)
(set-face-attribute 'highlight nil :background "#444")

;; Insert Date
;(defun blog-date () (interactive)
;       (insert (shell-command-to-string "echo -n $(date -u +%Y-%m-%dT%H:%M:%S%z)")))


;(global-set-key "\C-x\C-j" 'helm-mini) already have this above


;; Golang LSP
(require 'lsp-mode)
(add-hook 'go-mode-hook #'lsp-deferred)
;; https://go.googlesource.com/tools/+/refs/heads/master/gopls/doc/analyzers.md?autodive=0%2F%2F%2F%2F
(setq lsp-go-analyses
      '((composites . :json-false)
        (ST1000 . :json-false)
        (ST1020 . :json-false)
        (ST1021 . :json-false)
        (ST1022 . :json-false)))

(lsp-register-custom-settings
 '(("gopls.completeUnimported" t t)
   ("gopls.staticcheck" t t)))
(setq lsp-signature-auto-activate nil)


;; Company Mode: https://company-mode.github.io/manual/Customization.html
(add-hook 'after-init-hook 'global-company-mode)

;; ;; 0.3 is default, 0.0 is react immediately
;; (setq company-idle-delay
;;       (lambda () (if (company-in-string-or-comment) nil 0.0)))
(setq company-idle-delay 1
      company-tooltip-idle-delay 1
      company-require-match nil
      company-frontends
      '(company-pseudo-tooltip-unless-just-one-frontend-with-delay
        company-preview-frontend
        company-echo-metadata-frontend)
      company-backends '(company-capf))

;; (global-set-key (kbd "<tab>")
;;                 (lambda ()
;;                   (interactive)
;;                   (let ((company-tooltip-idle-delay 0.0))
;;                     (company-complete)
;;                     (and company-candidates
;;                          (company-call-frontends 'post-command)))))


;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
;  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; xref bindings
(global-set-key "\M-." 'lsp-find-definition)
(global-set-key "\M-," 'xref-go-back)
(global-set-key "\M-m" 'lsp-find-references)


;; Custom commands
(defun gid (CountX)
  "Insert CountX random hexadecimal digits.
CountX default to 5.
Call `universal-argument' and type a number, then, call this command, for different count.
URL `http://xahlee.info/emacs/emacs/elisp_insert_random_number_string.html'
Version: 2017-08-03 2023-01-13"
  (interactive "P")
  (let ((xn (if (numberp CountX) (abs CountX) 16 )))
    (insert (concat "0x" (format  (concat "%0" (number-to-string xn) "x" ) (random (expt 16 xn)))))))

(define-key global-map (kbd "C-c i") 'gid)

(load-file "/home/jacob/git/language/oll-mode.el")

;; Manage Layouts
(dotimes (i 5)
  (let* ((n (+ i 1))                             ; Slots 1-5
         (reg (string-to-char (number-to-string n))) ; Char code
         (save-func-name (intern (format "my/save-layout-%d" n)))
         (load-func-name (intern (format "my/load-layout-%d" n))))

    ;; 1. SAVE Function (Unchanged - saves the splits and files)
    (defalias save-func-name
      `(lambda ()
         (interactive)
         (window-configuration-to-register ,reg)
         (message "Layout saved to register %d" ,n)))

    ;; 2. LOAD Function (The Fix)
    (defalias load-func-name
      `(lambda ()
         (interactive)
         (if (get-register ,reg)
             (let ((buffer-points (make-hash-table :test 'eq)))
               
               ;; Step A: Save current "real" positions of ALL buffers
               (dolist (buf (buffer-list))
                 (with-current-buffer buf
                   (puthash buf (point) buffer-points)))
               
               ;; Step B: Restore the layout (which wrongly resets cursors)
               (jump-to-register ,reg)
               
               ;; Step C: Fix the cursors
               ;; We walk through the newly restored windows and force them
               ;; to go to the "real" position we saved in Step A.
               (dolist (win (window-list))
                 (let* ((buf (window-buffer win))
                        (real-point (gethash buf buffer-points)))
                   (when real-point
                     (set-window-point win real-point)))))
             
           (message "Register %d is empty." ,n))))

    ;; 3. Bind Keys
    (global-set-key (kbd (format "C-c %d" n)) load-func-name)
    (global-set-key (kbd (format "C-c w %d" n)) save-func-name)))

;; (dotimes (i 5)
;;   (let* ((n (+ i 1))                             ; Slots 1-5
;;          (reg (string-to-char (number-to-string n))) ; Char code for register
;;          (save-func-name (intern (format "my/save-layout-%d" n)))
;;          (load-func-name (intern (format "my/load-layout-%d" n))))

;;     ;; 1. Define SAVE function
;;     ;; Notice the backtick ` before (lambda
;;     (defalias save-func-name
;;       `(lambda ()
;;          (interactive)
;;          (window-configuration-to-register ,reg) ; ,reg injects the value
;;          (message "Layout saved to register %d" ,n)))

;;     ;; 2. Define LOAD function
;;     ;; Notice the backtick ` before (lambda
;;     (defalias load-func-name
;;       `(lambda ()
;;          (interactive)
;;          (if (get-register ,reg)
;;              (jump-to-register ,reg)
;;            (message "Register %d is empty." ,n))))

;;     ;; 3. Bind keys
;;     (global-set-key (kbd (format "C-c %d" n)) load-func-name)
;;     (global-set-key (kbd (format "C-c w %d" n)) save-func-name)))


;; ----------------- AI ----------------------
(global-auto-revert-mode 1)

(require 'transient)

;; 1. The Core Engine (Not mapped to a key, just runs quietly)
(defun my-gemini-vterm-execute (instruction)
  "Finds an active vterm, formats context, and pastes it directly into the running CLI."
  (let* ((file-path (buffer-file-name))
         (filename (if file-path (file-name-nondirectory file-path) ""))
         (region-text (if (use-region-p)
                          (buffer-substring-no-properties (region-beginning) (region-end))
                        ""))
         
         ;; 1. Format a clean, human-readable prompt
         (full-payload (format "Context: I am working in %s.\nInstruction: %s\n\nTarget Snippet:\n%s" 
                               filename 
                               instruction 
                               region-text))
         
         ;; 2. Hunt down the first open vterm buffer
         (vterm-buf (catch 'found
                      (dolist (b (buffer-list))
                        (with-current-buffer b
                          (when (eq major-mode 'vterm-mode)
                            (throw 'found b))))
                      nil)))

    (if vterm-buf
        (progn
          ;; 3. Put the formatted text into the Emacs clipboard
          (kill-new full-payload)

          ;; 4. Split window and jump to the vterm buffer
          (pop-to-buffer vterm-buf)

          ;; 5. Paste securely (triggers bracketed paste)
          (vterm-yank)

          ;; Wait for the terminal to finish processing the massive paste
          (sleep-for 0.1)

          ;; 6. First Enter: Closes the multi-line paste block
          (vterm-send-return)

          ;; Tiny breath for the CLI state to update
          (sleep-for 0.05)

          ;; 7. Second Enter: Actually sends the prompt to the AI
          (vterm-send-return))

      ;; Fallback warning if you forgot to open the terminal
      (message "No vterm buffer found! Open vterm and start the Gemini CLI first."))))

;; 2. The Command Definitions
(defun my-gemini-cmd-tests ()
  "Ask the agent to generate unit tests."
  (interactive)
  (my-gemini-vterm-execute "Write comprehensive unit tests for this code. Focus on edge cases."))

(defun my-gemini-cmd-finish ()
  "Ask the agent to complete the logic."
  (interactive)
  (my-gemini-vterm-execute "Finish implementing this function or struct based on the current context and naming patterns."))

(defun my-gemini-cmd-bugs ()
  "Ask the agent to audit for memory leaks and edge cases."
  (interactive)
  (my-gemini-vterm-execute "Analyze this code for bugs, memory leaks, or unhandled edge cases. Provide the corrected code."))

(defun my-gemini-cmd-custom ()
  "Prompt for a specific, one-off instruction."
  (interactive)
  (my-gemini-vterm-execute (read-string "Agent task: ")))

;; 3. The Visual Menu (The Magit-style popup)
(transient-define-prefix my-gemini-menu ()
  "AI Agent Command Palette"
  ["Gemini Agent Commands"
   ("t" "Write Tests" my-gemini-cmd-tests)
   ("f" "Finish Function" my-gemini-cmd-finish)
   ("b" "Check for Bugs" my-gemini-cmd-bugs)
   ("c" "Custom Prompt" my-gemini-cmd-custom)])

;; 4. The Trigger Key
(global-set-key (kbd "C-c g") 'my-gemini-menu)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(tango-dark))
 '(package-selected-packages
   '(ace-jump-mode ag catppuccin-theme company exec-path-from-shell
                   go-mode gptel helm json-mode keychain-environment
                   lsp-mode magit nginx-mode projectile rust-mode
                   toml-mode vterm web-mode yaml-mode zenburn-theme
                   zig-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


