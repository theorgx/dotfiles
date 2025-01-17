;; define function for checking whether we're running on any im
   (defun acemacs/is-im ()
       "Check whether we are on any im."
       (if (string-match "im.*" (system-name)) t nil))

   (defun acemacs/is-orbi ()
       "Check whether we are on orbi."
       (if (string-match "orbi" (system-name)) t nil))

 ;; show every 30 minutes the events of the next 31 minutes from the calendar
(defun acemacs/events ()
  (shell-command "bash -c 'notify-send -t 5000 -u low \"$(khal list -d institut --format \"{start-time} : {title}\" now 31m)\"'"))
(run-with-timer 0  (* 30 60) 'acemacs/events)

;; do not exit on C-x C-c
(global-unset-key (kbd "C-x C-c"))

;; You will most likely need to adjust this font size for your system!
(defvar acemacs/default-font-size 120)

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
		  org-agenda-mode-hook
                term-mode-hook
                treemacs-mode-hook
                shell-mode-hook
                mu4e-headers-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Font Configuration ----------------------------------------------------------
(defvar acemacs/font "Iosevka")
(defvar acemacs/font-fixed-pitch "Iosevka")
(defvar acemacs/font-variable-pitch "Iosevka Aile")

(if (acemacs/is-im) (setq acemacs/font "DejaVu Sans Mono" acemacs/font-fixed-pitch "DejaVu Sans"))

(set-face-attribute 'default nil :font acemacs/font :height acemacs/default-font-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font acemacs/font :height acemacs/default-font-size)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font acemacs/font-variable-pitch :height acemacs/default-font-size)

(column-number-mode)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)

;; NOTE: The first time you load your configuration on a new machine, you'll
;; need to run the following command interactively so that mode line icons
;; display correctly:
;;
;; M-x all-the-icons-install-fonts

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package doom-themes
  :init
  (if (acemacs/is-orbi) (load-theme 'doom-dracula t) (load-theme 'doom-solarized-light t)))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)
;; debug load time of packages
;;(setq use-package-compute-statistics t)

;; set pass as standard authentication method
(use-package auth-source-pass
  :config
  (setq auth-sources '(password-store)))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper))
  :config
  (ivy-mode 1))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

;; use smex such that recent commands are listed first when hitting M-x
(use-package smex)

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-switch-buffer)
         ("C-x C-f" . counsel-find-file)
         ("C-x C-r" . counsel-recentf)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history)))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; make org-mode easily accessible
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

;; evil config
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-i-jump nil)
  (setq evil-want-fine-undo t)
  :custom
  (evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal)

  ;; some keybindings for evil. Note that arrow keys are easily accessible on the UHK
  (evil-global-set-key 'motion (kbd "<down>") 'evil-next-visual-line)
  (evil-global-set-key 'motion (kbd "<up>") 'evil-previous-visual-line)
  (evil-global-set-key 'normal (kbd "C-w <down>") 'evil-window-down)
  (evil-global-set-key 'normal (kbd "C-w <up>") 'evil-window-up)
  (evil-global-set-key 'normal (kbd "C-w <left>") 'evil-window-left)
  (evil-global-set-key 'normal (kbd "C-w <right>") 'evil-window-right)
  (evil-global-set-key 'normal (kbd "H-k") 'evil-window-down)
  (evil-global-set-key 'normal (kbd "H-i") 'evil-window-up)
  (evil-global-set-key 'normal (kbd "H-j") 'evil-window-left)
  (evil-global-set-key 'normal (kbd "H-l") 'evil-window-right)
  (evil-global-set-key 'normal (kbd "H-c") 'evil-window-delete)
  (evil-global-set-key 'normal (kbd "H-v") 'evil-window-vsplit)
  (evil-global-set-key 'normal (kbd "H-s") 'evil-window-split))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package dired-single)

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(use-package mu4e
  :if (acemacs/is-orbi)
  :commands mu4e
  :defer t
  :ensure nil
  :config
  (setq message-send-mail-function 'smtpmail-send-it)
  (setq	user-full-name "Jens Schneider" )
  (setq mu4e-contexts
        `( ,(make-mu4e-context
             :name "Posteo"
             :enter-func (lambda () (mu4e-message "Entering Posteo context"))
             :leave-func (lambda () (mu4e-message "Leaving Posteo context"))
             ;; we match based on the contact-fields of the message
             :match-func (lambda (msg)
                           (when msg
                             (mu4e-message-contact-field-matches msg
                                                                 :to "jens.schneider.ac@posteo.de")))
             :vars '( ( user-mail-address	   . "jens.schneider.ac@posteo.de"  )
                      ( mu4e-sent-folder      . "/posteo/Sent" )
                      ( mu4e-trash-folder     . "/posteo/Trash" )
                      ( mu4e-drafts-folder    . "/posteo/Drafts" )
                      ( mu4e-refile-folder    . "/posteo/Archive" )
                      ( smtpmail-smtp-user    . "jens.schneider.ac@posteo.de" )
                      ( smtpmail-smtp-server  . "posteo.de")
                      ( smtpmail-smtp-service . 587)
                      (mu4e-maildir-shortcuts . ( ("/posteo/Inbox"   . ?i)
                                                  ("/posteo/Sent"    . ?s)
                                                  ("/posteo/Archive" . ?a)
                                                  ("/posteo/Trash"   . ?t)
                                                  ("/posteo/Drafts"   . ?d) ))))
           ,(make-mu4e-context
             :name "Rwth"
             :enter-func (lambda () (mu4e-message "Entering Rwth context"))
             :leave-func (lambda () (mu4e-message "Leaving Rwth context"))
             ;; we match based on the contact-fields of the message
             :match-func (lambda (msg)
                           (when msg
                             (mu4e-message-contact-field-matches msg
                                                                 :to "jens.schneider1@rwth-aachen.de")))
             :vars '( ( user-mail-address	   . "jens.schneider1@rwth-aachen.de"  )
                      ( mu4e-sent-folder      . "/rwth/Sent Items" )
                      ( mu4e-trash-folder     . "/rwth/Deleted Items" )
                      ( mu4e-drafts-folder    . "/rwth/Drafts" )
                      ( mu4e-refile-folder    . "/rwth/Archive" )
                      ( smtpmail-smtp-user    . "js199426@rwth-aachen.de" )
                      ( smtpmail-smtp-server  . "mail.rwth-aachen.de")
                      ( smtpmail-smtp-service . 587)
                      (mu4e-maildir-shortcuts . ( ("/rwth/Inbox"         . ?i)
                                                  ("/rwth/Sent Items"    . ?s)
                                                  ("/rwth/Archive"       . ?a)
                                                  ("/rwth/Deleted Items" . ?t)
                                                  ("/rwth/Drafts"         . ?d) ))))
           ,(make-mu4e-context
             :name "Ient"
             :enter-func (lambda () (mu4e-message "Entering Ient context"))
             :leave-func (lambda () (mu4e-message "Leaving Ient context"))
             ;; we match based on the contact-fields of the message
             :match-func (lambda (msg)
                           (when msg
                             (mu4e-message-contact-field-matches msg
                                                                 :to "schneider@ient.rwth-aachen.de")))
             :vars '( ( user-mail-address	   . "schneider@ient.rwth-aachen.de"  )
                      ( mu4e-sent-folder      . "/ient/Sent Items" )
                      ( mu4e-trash-folder     . "/ient/Deleted Items" )
                      ( mu4e-drafts-folder    . "/ient/Drafts" )
                      ( mu4e-refile-folder    . "/ient/Archive" )
                      ( smtpmail-smtp-user    . "js199426@ient.rwth-aachen.de" )
                      ( smtpmail-smtp-server  . "mail.rwth-aachen.de")
                      ( smtpmail-smtp-service . 587)
                      (mu4e-maildir-shortcuts . ( ("/ient/Inbox"         . ?i)
                                                  ("/ient/Sent Items"    . ?s)
                                                  ("/ient/Archive"       . ?a)
                                                  ("/ient/Deleted Items" . ?t)
                                                  ("/ient/Drafts"         . ?d) ))))
           ))
  ;; work with mbsync
  (setq mu4e-get-mail-command "mbsync -a")
  (setq mu4e-change-filenames-when-moving t)

  ;; don't keep message buffers around
  (setq message-kill-buffer-on-exit t)

  ;; set mu4e-view-fields 
  (setq mu4e-view-fields '(:from :to :cc :bcc :subject :date :maildir :tags :attachments :signature :decryption))

  ;; don't show related messages and threads by default. Toggle them with z r and z t
  (setq mu4e-headers-include-related nil)
  (setq mu4e-headers-show-threads nil))

;;store org-mode links to messages
(use-package org-mu4e
  :ensure nil
  :after mu4e
  :config
;;store link to message if in header view, not to header query
(setq org-mu4e-link-query-in-headers-mode nil))

(defun acemacs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(defun acemacs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font acemacs/font-variable-pitch :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

;; show todays calendar events, when opening org agenda
(defun acemacs/agenda-hook ()
  (shell-command "bash -c 'notify-send -t 60000 -u low \"$(khal list --format \"{start-time} : {title}\" today today)\"'"))

;; helper function for org-publish. Show the date of a post on the blog sitemap
(defun acemacs/site-format-entry (entry style project)
    (format "[[file:%s][%s]] --- %s"
            entry
            (org-publish-find-title entry project)
            (format-time-string "%Y-%m-%d" (org-publish-find-date entry project))))

(use-package org
  :if (acemacs/is-orbi)
  :hook
  (org-mode . acemacs/org-mode-setup)
  (org-agenda-mode . acemacs/agenda-hook)
  :ensure t
  :config
  (setq org-ellipsis " ▾")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-agenda-span 'day)
  (setq org-agenda-files
        '("~/org/"))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (require 'org-protocol)

  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w)" "|" "DONE(d!)" "CANC(c!)")))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

(setq org-capture-templates
  '(("g" "general")
      ("gt" "todo" entry (file+headline "~/org/todo.org" "Tasks")
       "* TODO %?\n")
      ("gm" "todo mail" entry (file+headline "~/org/todo.org" "Tasks")
       "* TODO %?\n from %a")
    ("w" "work")
      ("wt" "todo" entry (file+headline "~/org/work.org" "Todo")
       "* TODO %?\n")
    ("t" "tvv")
      ("tt" "todo" entry (file+headline "~/org/todo.org" "Todo")
       "* TODO %?\n")
      ("tm" "todo mail" entry (file+headline "~/org/tvv.org" "Inbox")
       "* TODO %?\n from %a")
    ))

  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("@home" . ?H)
       ("@work" . ?W)
       ("@tvv" .  ?T)
       ("@others" . ?O)
       ("idea" . ?i)))

  (setq org-html-doctype "html5"
        org-html-htmlize-output-type 'css)

  (setq org-publish-project-alist
      '(("orgfiles_blog"
         :base-directory "~/Documents/workspace/website/org"
         :base-extension "org"
         :publishing-directory "/ssh:labora:~/Dokumente/website/posts"
         :publishing-function org-html-publish-to-html
         :headline-levels 3
         :section-numbers nil
         :with-toc nil
         :with-date t
         :auto-sitemap t
         :sitemap-filename "blog.org"
         :sitemap-title "Blog"
         :sitemap-sort-files anti-chronologically
         :sitemap-format-entry acemacs/site-format-entry
         :sitemap-file-entry-format "%d - %t"
         :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"../org-style.css\" />
                     <link rel=\"stylesheet\" type=\"text/css\" href=\"../custom_style.css\" />
                     <link rel=\"stylesheet\" type=\"text/css\" href=\"../fonts/webfont-iosevka-5.0.1/iosevka.css\" />
                     <link rel=\"stylesheet\" type=\"text/css\" href=\"../fonts/webfont-iosevka-aile-4.0.0/iosevka-aile.css\" />"
         :html-postamble nil)

        ("images_blog"
         :base-directory "~/Documents/workspace/website/org/img"
         :base-extension "jpg\\|gif\\|png"
         :publishing-directory "/ssh:labora:~/Dokumente/website/posts/img"
         :publishing-function org-publish-attachment)

        ("blog" :components ("orgfiles_blog" "images_blog" ))))

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (matlab . t)
     (latex . t)))

  (acemacs/org-font-setup))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(use-package htmlize)

(use-package org-tree-slide
  :defer t)

(use-package khalel
  :config
  (setq khalel-khal-command "~/.local/bin/khal")
  (setq khalel-vdirsyncer-command "vdirsyncer")
  (setq khalel-default-calendar "ncpersonal")
  (setq khalel-capture-key "e")
  (setq khalel-import-org-file (concat org-directory "/calendar.org"))
  (setq khalel-import-time-delta "30d")
  (khalel-add-capture-template))

(use-package org-roam
    :if (acemacs/is-orbi)
;;    :hook
  ;;  (after-init . org-roam-mode)
    :config
    (require 'org-roam-protocol)
    :init
    (setq org-roam-v2-ack t)
    :custom
    (org-roam-directory "~/org/notes")
    :bind
    (   (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-insert)
         ("C-c n I" . org-roam-insert-immediate))))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/Software")
    (setq projectile-project-search-path '("~/Software")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

(use-package projectile-ripgrep
  :after projectile)

(use-package cmake-mode)

(use-package magit
  :defer t
  :hook
  (magit-mode . visual-line-mode)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (magit-diff-refine-hunk t))

;; work with gitlab forges
(use-package forge
  :defer t
  :config
  (add-to-list 'forge-alist '("git.rwth-aachen.de" "git.rwth-aachen.de/api/v4" "git.rwth-aachen.de" forge-gitlab-repository))
  (add-to-list 'forge-alist '("github.com" "api.github.com" "github.com" forge-github-repository)))

(use-package eglot
  :config
  (add-to-list 'eglot-server-programs '(tex-mode . ("digestif")))
  :hook
  ((LaTeX-mode . eglot-ensure)
  (c++-mode . eglot-ensure)
  (c-mode . eglot-ensure)
  (python-mode . eglot-ensure)))

(use-package c++-mode
:ensure nil
:hook
(c++-mode . company-mode))

(use-package c-mode
:ensure nil
:hook
(c-mode . company-mode))

(use-package elpy
    :defer t
    :custom
    (elpy-formatter "black")
    (elpy-rpc-timeout 10)
    :init
    (advice-add 'python-mode :before 'elpy-enable))

(use-package pyenv-mode)

(use-package ein
  :defer t)

(use-package yaml-mode)

(use-package tex
      :defer t
      :ensure auctex
      :hook
      (LaTeX-mode . (lambda () (flyspell-mode) (company-mode)))
      :config
      (TeX-source-correlate-mode)
      :custom
      (TeX-command-extra-options "--shell-escape")
      (TeX-source-correlate-start-server t))

    ;; ivy bibtex
    (use-package ivy-bibtex
      :if (acemacs/is-orbi)
      :commands
      (ivy-bibtex)
      :custom
      (bibtex-completion-bibliography "~/Documents/diss/references.bib"))
  ;; tikz
(use-package tikz)

(use-package matlab
  :if (acemacs/is-orbi)
  :defer t
  :ensure matlab-mode
  :config
  (setq matlab-shell-command "/home/urbi/Software/Matlab2019a/bin/matlab"))

(use-package lua-mode
  :config
  (setenv "LUA_PATH"
          "/usr/share/lua/5.3/?.lua;/usr/share/lua/5.3/?/init.lua;/usr/lib/lua/5.3/?.lua;/usr/lib/lua/5.3/?/init.lua;./?.lua;./?/init.lua;/home/urbi/.luarocks/share/lua/5.3/?.lua;/home/urbi/.luarocks/share/lua/5.3/?/init.lua")
  (setenv "LUA_CPATH"
          "/usr/lib/lua/5.3/?.so;/usr/lib/lua/5.3/loadall.so;./?.so;/home/urbi/.luarocks/lib/lua/5.3/?.so")
  (setq lua-default-application "lua5.3")
  )

;; append yasnippet support as described in the following link
;; https://www.reddit.com/r/emacs/comments/3r9fic/best_practicestip_for_companymode_andor_yasnippet/
(defvar company-mode/enable-yas t "Enable yasnippet for all backends.")
(defun company-mode/backend-with-yas (backend)
  (if (or (not company-mode/enable-yas) (and (listp backend) (member 'company-yasnippet backend)))
      backend
    (append (if (consp backend) backend (list backend))
            '(:with company-yasnippet))))

(use-package company
  :demand t
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection)
              ("<down>" . company-select-next))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.1)
  :config
  ;;    (global-company-mode)
  (global-set-key (kbd "TAB") #'company-indent-or-complete-common))

(use-package company-bibtex
  :if (acemacs/is-orbi)
  :after company
  :config
  (setq company-bibtex-bibliography "/home/urbi/Documents/diss/references.bib")
  (add-to-list 'company-backends 'company-bibtex))

(use-package company-lua
  :config
  (add-to-list 'company-backends 'company-lua))
(setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))

(use-package company-box
  :hook (company-mode . company-box-mode))

;; snippets and advanced syntax checking
(use-package yasnippet
  :config
  (yas-global-mode))

(use-package yasnippet-snippets
  :after yasnippet)

(server-start)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values '((buffer-read-only . 1))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
