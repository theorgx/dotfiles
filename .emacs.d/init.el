;; Many thanks to @daviwil (https://github.com/daviwil)
;; This config is mainly based on your streams and examples and is expected to evolve...

;; define function for checking whether we're running on any im
(defun acemacs/is-im ()
    "Check whether we are on any im."
    (if (string-match "im.*" (system-name)) t nil))

(defun acemacs/is-orbi ()
    "Check whether we are on orbi."
    (if (string-match "orbi" (system-name)) t nil))


;; Basic UI Configuration ------------------------------------------------------

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
                term-mode-hook
		treemacs-mode-hook
                shell-mode-hook
		mu4e-headers-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Font Configuration ----------------------------------------------------------
(defvar acemacs/font "Iosevka")
(defvar acemacs/font-fixed-pitch "Iosevka Aile")

(if (acemacs/is-im) (setq acemacs/font "DejaVu Sans Mono" acemacs/font-fixed-pitch "DejaVu Sans"))

(set-face-attribute 'default nil :font acemacs/font :height acemacs/default-font-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font acemacs/font :height acemacs/default-font-size)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font acemacs/font-fixed-pitch :height acemacs/default-font-size :weight 'regular)

;; Package Manager Configuration -----------------------------------------------

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
(setq use-package-compute-statistics t)

(column-number-mode)
(global-display-line-numbers-mode t)


;; this makes company box behaving weard... I don'nt want this for now
;; (use-package tab-bar
;;   :ensure nil
;;   :init (tab-bar-mode t)
;;   :config
;;   (setq tab-bar-close-button-show nil
;; 	tab-bar-new-button-show nil
;; 	tab-bar-show nil
;; 	tab-bar-new-tab-choice "*scratch*"))

;; Ivy Configuration -----------------------------------------------------------

(use-package ivy
  :diminish
  :bind (("C-s" . swiper))
  :config
  (ivy-mode 1))

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

;; Key Binding Configuration ---------------------------------------------------

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
  (evil-global-set-key 'normal (kbd "C-w <right>") 'evil-window-right))
		    
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; uncomment when you are ready to set it up and use it
;;(use-package hydra)

;; Projectile Configuration ----------------------------------------------------

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

;; dired configuration
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


;; set pass as standard authentication method
(use-package auth-source-pass
  :config
  (setq auth-sources '(password-store)))

;; mu4e configuration so far only posteo account
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
						  ("/posteo/Dafts"   . ?d) ))))
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
						  ("/rwth/Dafts"         . ?d) ))))
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
						  ("/ient/Dafts"         . ?d) ))))
	   ))
  ;; work with mbsync
  (setq mu4e-get-mail-command "mbsync -a")
  (setq mu4e-change-filenames-when-moving t)
  
  ;; don't keep message buffers around
  (setq message-kill-buffer-on-exit t)
  
					; don't show related messages and threads by default. Toggle them with z r and z t
  (setq mu4e-headers-include-related nil)
  (setq mu4e-headers-show-threads nil))

;;store org-mode links to messages
(use-package org-mu4e
  :ensure nil
  :after mu4e
  :config
;;store link to message if in header view, not to header query
(setq org-mu4e-link-query-in-headers-mode nil))


;; Magit Configuration ---------------------------------------------------------

(use-package magit
  :defer t
  :hook
  (magit-mode . visual-line-mode)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; work with gitlab forges
(use-package forge
  :defer t
  :config
  (add-to-list 'forge-alist '("git.rwth-aachen.de" "git.rwth-aachen.de/api/v4" "git.rwth-aachen.de" forge-gitlab-repository)))


;; Org Mode Configuration ------------------------------------------------------

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
    (set-face-attribute (car face) nil :font "Iosevka Aile" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(defun acemacs/agenda-hook ()
  (shell-command "bash -c 'notify-send -t 60000 -u low \"$(khal list --format \"{start-time} : {title}\" today today)\"'"))

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
  (setq org-agenda-files
	'("~/org/"))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
    '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
      (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-capture-templates
	'(("t" "todo" entry (file+headline "~/org/todo.org" "Tasks")
           "* TODO [#A] %?\nSCHEDULED: %(org-insert-time-stamp (org-read-date nil t \"+0            d\"))\n%a\n")))

  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("@home" . ?H)
       ("@work" . ?W)
       ("agenda" . ?a)
       ("planning" . ?p)
       ("note" . ?n)
       ("idea" . ?i)))

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (matlab . t)))
  (acemacs/org-font-setup))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(use-package org-tree-slide
  :defer t)

(use-package org-roam
  :if (acemacs/is-orbi)
  :hook
  (after-init . org-roam-mode)
  :custom
  (org-roam-directory "~/org/notes")
  :bind
  (:map org-roam-mode-map
          (("C-c n l" . org-roam)
           ("C-c n f" . org-roam-find-file)
           ("C-c n g" . org-roam-graph))
          :map org-mode-map
          (("C-c n i" . org-roam-insert))
          (("C-c n I" . org-roam-insert-immediate))))

(use-package org-roam-server
  :after org-roam-mode
  :config
  (setq org-roam-server-host "127.0.0.1"
        org-roam-server-port 8080
        org-roam-server-authenticate nil
        org-roam-server-export-inline-images t
        org-roam-server-serve-files nil
        org-roam-server-served-file-extensions '("pdf" "mp4" "ogv")
        org-roam-server-network-poll t
        org-roam-server-network-arrows nil
        org-roam-server-network-label-truncate t
        org-roam-server-network-label-truncate-length 60
        org-roam-server-network-label-wrap-length 20))

(use-package org-roam-protocol
  :ensure nil
  :after org-roam-mode)

(server-start)

;; lsp-mode configuration --------------------------------------

;; lsp-mode
(defun acemacs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode)
  (setq gc-cons-threshold 100000000)
  (setq read-process-output-max (* 1024 1024)))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . acemacs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))
  
(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)

;; dap mode for debugging
(use-package dap-mode
  :config
  (setq dap-ui-controls-mode nil)
  :bind
  ("<f5>" . dap-hydra))


;; company mode for completion
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
  (global-company-mode)
  (global-set-key (kbd "TAB") #'company-indent-or-complete-common))

(use-package company-bibtex
  :if (acemacs/is-orbi)
  :after company
  :config
  (setq company-bibtex-bibliography "/home/urbi/Documents/diss/references.bib")
  (add-to-list 'company-backends 'company-bibtex))
  (setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))

;; (use-package company-box
;;   :hook (company-mode . company-box-mode))

;; snippets and advanced syntax checking
(use-package yasnippet
  :config
  (yas-global-mode))

(use-package yasnippet-snippets
  :after yasnippet)

(use-package flycheck
  :init (global-flycheck-mode))

;; python
(use-package elpy
  :defer t
  :custom
  (elpy-formatter "black")
  (elpy-rpc-timeout 10)
  :hook
  (elpy-mode . (lambda ()
                          (require 'dap-python)
                          (lsp-deferred)))
  :init
  (advice-add 'python-mode :before 'elpy-enable))

;; ein for interacting with notebooks
(use-package ein
  :defer t)

;;latex
(use-package lsp-latex
  :defer t)

(use-package tex
  :defer t
  :ensure auctex
  :hook
  (LaTeX-mode . (lambda ()
		  (require 'lsp-latex)
		  (lsp)
		  (flyspell-mode)))
  :config
  (TeX-source-correlate-mode)
  :custom
  (TeX-command-extra-options "--shell-escape")
  (TeX-source-correlate-start-server t))

;; not sure whether I really need that
(use-package ivy-bibtex
  :if (acemacs/is-orbi)
  :commands
  (ivy-bibtex)
  :custom
  (bibtex-completion-bibliography "~/Documents/diss/references.bib"))

;; matlab
(use-package matlab
  :if (acemacs/is-orbi)
  :defer t
  :ensure matlab-mode
  :config
  (setq matlab-shell-command "/home/urbi/Software/Matlab2019a/bin/matlab"))
  
