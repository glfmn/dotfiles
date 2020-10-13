;;; Configuration --- configuration for emacs

;; Start up to a more minimal text editor

;;; Code

(setq inhibit-startup-message t)

(menu-bar-mode -1) ; no menu bar
(scroll-bar-mode -1) ; no visible scrollbar
(tool-bar-mode -1) ; no toolbar
(tooltip-mode -1) ; no tooltips
(set-fringe-mode 10) ; horizontal padding
(setq visible-bell t) ; visual instead of audio indicator for errors


(add-to-list 'default-frame-alist '(font . "Source Code Pro"))
(set-face-attribute 'default t :font "Source Code Pro")
(set-face-attribute 'default nil :height 105)

;; Make ESQ quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Line numbers
(column-number-mode)
(global-display-line-numbers-mode t)

(dolist (mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Initialize package sources

(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("gnu" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Themes

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))


(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (doom-themes-visual-bell-config)
  :init (load-theme 'doom-gruvbox t))

;; Search Functionality

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history))
  :config (setq ivy-initial-inputs-alist nil))

(use-package swiper)

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-partial-or-done)
	 ("C-j" . ivy-immediate-done)
	 ("RET" . ivy-alt-done)
         :map ivy-switch-buffer-map
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :init (ivy-rich-mode 1))

;; Help

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config (setq which-key-idle-delay 0.3))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;; Project management

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap ("C-c p" . projectile-command-map)
  :init (when (file-directory-p "~/Code")
	  (setq projectile-project-search-path '("~/Code"))))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

;; Programming

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Error checking
(use-package flycheck
  :hook (prog-mode . flycheck-mode))

;; Auto-completion
(use-package company
  :hook (prog-mode . company-mode)
  :config (setq company-tooltip-align-annotations t
		company-minimum-prefix-length 2))

;; Language server protocol
(use-package lsp-mode
    :hook ((lsp-mode . lsp-enable-which-key-integration))
    :commands lsp)

(use-package lsp-ivy
  :commands lsp-ivy-workspace-symbol)

;; Rust programming

(use-package rust-mode
  :hook (rust-mode . lsp))

(use-package flycheck-rust
  :config (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(use-package toml-mode)

(use-package cargo
  :diminish cargo-minor-mode
  :hook (rust-mode . cargo-minor-mode))

;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (counsel-projectile which-key use-package toml-mode rainbow-delimiters projectile lsp-ivy ivy-rich helpful flycheck-rust doom-themes doom-modeline counsel company cargo))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
