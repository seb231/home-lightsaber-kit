;;; init --- A home light saber kit

;; Copyright (C) 2016 Mastodon C Ltd

;;; Commentary:

;; Everything will be configured using packages from melpa or
;; elsewhere.  This is a minimal setup to get packages going.

;;; Code:

(require 'package)
(setq package-archives '(("elpa" . "http://elpa.gnu.org/packages/")
			 ("gnu" . "http://elpa.gnu.org/packages/")
			 ("melpa-stable" . "http://melpa-stable.milkbox.net/packages/")
			 ("melpa" . "http://melpa.org/packages/")
                         ("elpy" . "http://jorgenschaefer.github.io/packages/")))

(setq package-pinned-packages
      '((aggressive-indent . "melpa-stable")
        (bind-key . "melpa-stable")
        (cider . "melpa")
        (cider-eval-sexp-fu . "melpa")
	(clj-refactor . "melpa")
        (clojure-mode . "melpa")
        (company . "melpa-stable")
        ;; (dash . "melpa-stable")
        (diminish . "melpa-stable")
        (epl . "melpa-stable")
        (exec-path-from-shell . "melpa-stable")
        (flx . "melpa-stable")
        (flx-ido . "melpa-stable")
        (git-commit . "melpa-stable")
        (hydra . "melpa-stable")
        (ido . "melpa-stable")
        (ido-completing-read+ . "melpa-stable")
        (ido-vertical-mode . "melpa-stable")
        (flycheck-pos-tip . "melpa-stable")
        (flycheck . "melpa-stable")
        (highlight . "melpa") ;; woo! from the wiki https://www.emacswiki.org/emacs/highlight.el
        (highlight-symbol . "melpa-stable")
        (inflections . "melpa-stable")
        (magit . "melpa-stable")
        (magit-popup . "melpa-stable")
        (multiple-cursors . "melpa-stable")
        (paredit . "melpa-stable")
        (peg . "melpa-stable")
        (pkg-info . "melpa-stable")
        (pos-tip . "melpa-stable")
        (projectile . "melpa-stable")
        (rainbow-delimiters . "melpa-stable")
        (s . "melpa-stable")
        (seq . "elpa")
        (smex . "melpa-stable")
        (swiper . "melpa-stable")
        (use-package . "melpa-stable")
        (with-editor . "melpa-stable")
        (yasnippet . "melpa-stable")))

;; This means we prefer things from ~/.emacs.d/elpa over the standard
;; packages.
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(defvar use-package-verbose t)
(require 'bind-key)
(require 'diminish)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; minor modes
(defvar lisp-mode-hooks '(emacs-lisp-mode-hook lisp-mode-hook clojure-mode-hook))
(defvar lisp-interaction-mode-hooks '(lisp-interaction-modes-hook cider-mode-hook cider-repl-mode-hook))

(defun bld/add-to-hooks (f hooks)
  "Add funcion F to all HOOKS."
  (dolist (hook hooks)
    (add-hook hook f)))

(use-package aggressive-indent
  :ensure t
  :diminish aggressive-indent-mode
  :config (bld/add-to-hooks #'aggressive-indent-mode lisp-mode-hooks))

(use-package eldoc
  :diminish eldoc-mode
  :config (bld/add-to-hooks #'eldoc-mode (append lisp-mode-hooks lisp-interaction-mode-hooks)))

(use-package paredit
  :ensure t
  :diminish paredit-mode
  :config (bld/add-to-hooks #'paredit-mode (append lisp-mode-hooks lisp-interaction-mode-hooks)))

(use-package auctex
  :defer t
  :ensure t)

(use-package flycheck-pos-tip
  :ensure t
  :config
  (eval-after-load 'flycheck
    '(setq flycheck-display-errors-function #'flycheck-pos-tip-error-messages)))

(use-package flycheck
  :ensure t
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))

(require 'flycheck-joker)

(use-package highlight-symbol
  :ensure t
  :diminish highlight-symbol
  :bind (("M-n" . highlight-symbol-next)
         ("M-p" . highlight-symbol-prev))
  :config (add-hook 'prog-mode-hook #'highlight-symbol-mode))

(use-package rainbow-delimiters
  :ensure t
  :diminish rainbow-delimiters
  :config (bld/add-to-hooks #'rainbow-delimiters-mode
                            (append lisp-mode-hooks lisp-interaction-mode-hooks)))

(use-package paren
  :config (bld/add-to-hooks #'show-paren-mode (append lisp-mode-hooks lisp-interaction-mode-hooks)))

(use-package projectile
  :ensure t
  :diminish projectile-mode
  :config
  (setq projectile-enable-caching t)
  (projectile-global-mode 1))

(use-package company
  :ensure t
  :diminish company-mode
  :config
  (global-company-mode))

;; (use-package swiper
;;   :ensure t
;;   :bind (("\C-s" . swiper)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; major modes

(use-package magit
  :ensure t
  :bind (("C-c g" . magit-status)))

(use-package ediff
  :config
  (setq ediff-window-setup-function 'ediff-setup-windows-plain))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cider and clojure(script)

;; good cider
(use-package cider
  :ensure t
  :defer t
  :config
  (setq cider-repl-history-file (concat user-emacs-directory "cider-history")
        cider-repl-history-size 1000
	cider-font-lock-dynamically '(macro core function var)
        cider-overlays-use-font-lock t
        cider-pprint-fn 'fipp
        cider-cljs-lein-repl "(do (use 'figwheel-sidecar.repl-api) (start-figwheel!) (cljs-repl))"))

;; bad cider config
;; (add-hook 'cider-mode-hook #'cider-enlighten-mode) causes problems
;; on cider-restart or other 2nd cider session
;; (use-package cider
;;   :ensure t
;;   :defer t
;;   :config
;;   (setq cider-repl-history-file (concat user-emacs-directory "cider-history")
;;         cider-repl-history-size 1000
;; 	cider-font-lock-dynamically '(macro core function var)
;;         cider-overlays-use-font-lock t
;;         cider-pprint-fn 'fipp
;;         cider-cljs-lein-repl "(do (use 'figwheel-sidecar.repl-api) (start-figwheel!) (cljs-repl))")
;;   (add-hook 'cider-mode-hook #'cider-enlighten-mode))

;; (eval-after-load 'cider
;;   '(define-key cider-mode-map (kbd "C-c ,") 'cider-test-run-test))

(use-package clojure-mode
  :ensure t
  :defer t
  :mode (("\\.clj\\'" . clojure-mode)
	 ("\\.edn\\'" . clojure-mode)))

;; (use-package cider-eval-sexp-fu
;;   :ensure t)

(use-package clj-refactor
  :ensure t
  :defer t
  :config
  (defun my-clj-refactor-hook ()
    (message "Running cljr hook.")
    (clj-refactor-mode 1)
    (cljr-add-keybindings-with-prefix "C-c r"))
  (add-hook 'clojure-mode-hook 'my-clj-refactor-hook))

(use-package yasnippet
  :ensure t
  :defer t
  :config (yas-global-mode 1))

(use-package flycheck-clojure
  :ensure t
  :defer t
  :config
  (eval-after-load 'flycheck '(flycheck-clojure-setup)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ido and smex
(use-package smex
  :ensure t
  :bind (("M-x" . smex))
  :config (smex-initialize))  ; smart meta-x (use IDO in minibuffer)

(use-package ido
  :ensure t
  :demand t
  :bind (("C-x b" . ido-switch-buffer))
  :config (ido-mode 1)
  (setq ido-create-new-buffer 'always  ; don't confirm when creating new buffers
        ido-enable-flex-matching t     ; fuzzy matching
        ido-everywhere t  ; tbd
        ido-case-fold t)) ; ignore case

(use-package flx-ido
  :ensure t
  :config (flx-ido-mode 1))

(use-package ido-vertical-mode
  :ensure t
  :config (ido-vertical-mode 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Latex


;;(load "preview-latex.el" nil t t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Text Modes
(use-package markdown-mode
  :mode "\\.md\\'"
  :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display Tweaking
(load-theme 'wheatgrass)

(when (memq window-system '(mac ns))
  (set-default-font "-apple-Menlo-medium-normal-normal-*-12-*-*-*-m-0-iso10646-1"))

;; no toolbar
(tool-bar-mode -1)

;; no scroll bar
(scroll-bar-mode -1)

;; no horizontal scroll bar
(when (boundp 'horizontal-scroll-bar-mode)
  (horizontal-scroll-bar-mode -1))

;; show line and column numbers
(line-number-mode 1)
(column-number-mode 1)


;; open as fullscreen
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Other useful defaults

(global-set-key (kbd "C-;") 'comment-dwim)

;; keep autobackups under control
(setq
 backup-by-copying t      ; don't clobber symlinks
 backup-directory-alist
 '(("." . "~/.saves"))    ; don't litter my fs tree
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)       ; use versioned backups

;; put custom stuff in a different file
(setq custom-file (concat user-emacs-directory "custom.el"))

;; uniquify buffers with the same file name but different actual files
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward)

;; Delete that horrible trailing whitespace
(add-hook 'before-save-hook
          (lambda nil
            (delete-trailing-whitespace)))

;; downcase, upcase and narrow-to-region
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;; tab indentation (outside of makefiles) is evil
(setq-default indent-tabs-mode nil)

;; human readable dired
(setq dired-listing-switches "-alh")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Platform specific stuff

;; No # on UK Macs
(when (memq window-system '(mac ns))
  (global-set-key (kbd "M-3") '(lambda () (interactive) (insert "#"))))

;; Handle unicode better
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))

;; get the path from shell
(use-package exec-path-from-shell
  :ensure t
  :init (exec-path-from-shell-initialize))

(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;; fix yer speling
(when (memq window-system '(mac ns))
  (setq ispell-program-name (executable-find "aspell")))

;; Handle unicode better
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Seb's edits

;; Change how to run clj tests
(global-set-key (kbd "C-,") 'cider-test-run-test)

(global-set-key (kbd "C-c M-,") 'cider-test-run-ns-tests)

;; fullscreen
(global-set-key (kbd "M-f") 'toggle-frame-maximized)

;; add line numbers
(global-linum-mode t)

;; Python

(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i --simple-prompt")

;; tmux

(require 'server)
;; some systems don't auto-detect the socket dir, so specify it here and for the client:
(setq server-socket-dir "/tmp/emacs-shared")
(server-start)

(defadvice terminal-init-screen
    ;; The advice is named `tmux', and is run before `terminal-init-screen' runs.
    (before tmux activate)
  ;; Docstring.  This describes the advice and is made available inside emacs;
  ;; for example when doing C-h f terminal-init-screen RET
  "Apply xterm keymap, allowing use of keys passed through tmux."
  ;; This is the elisp code that is run before `terminal-init-screen'.
  (if (getenv "TMUX")
      (let ((map (copy-keymap xterm-function-map)))
        (set-keymap-parent map (keymap-parent input-decode-map))
        (set-keymap-parent input-decode-map map))))

;;; init.el ends here
