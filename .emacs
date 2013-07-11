
;; package.el
;; ----------
;; This was installed by package-install.el.
;; This provides support for the package system and
;; interfacing with ELPA, the package archive.
;; Move this code earlier if you want to reference
;; packages in your .emacs.
;; install packages with M-x package-list-packages
;;(when
;;    (load
;;     (expand-file-name "~/.emacs.d/elpa/package.el"))
;;  (package-initialize))

;; load-path
;; ---------
(add-to-list 'load-path "~/.emacs.d/site-elisp")
(add-to-list 'load-path "~/.emacs.d/site-elisp/expand-region")

;; ido-mode
;; --------
(ido-mode 1)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t) ;; activate ido-mode with C-x C-f  

;; expand-region
;; -------------
(require 'expand-region)
;(add-to-list 'load-path "~/.emacs.d/expand-region.el/")

;; js2-mode
;; --------
;; from: https://github.com/magnars/js2-mode
(autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;; flymake
;; -------
;; csslint - check css synthax live
;; npm install csslint -g
;; jshint - check js synthax live
;; npm install jshint -g
(add-to-list 'load-path "~/.emacs.d/site-elisp/flymake")
(require 'flymake)
(add-hook 'js2-mode-hook (lambda () (flymake-mode 1)))
(custom-set-variables
     '(help-at-pt-timer-delay 0.4)
     '(help-at-pt-display-when-idle '(flymake-overlay)))

;; flyspell
;; --------
(add-hook 'message-mode-hook 'turn-on-flyspell)
(add-hook 'text-mode-hook 'turn-on-flyspell)
(add-hook 'js2-mode-hook 'flyspell-prog-mode)
(defun turn-on-flyspell ()
  "Force flyspell-mode on using a positive arg.  For use in hooks."
  (interactive)
  (flyspell-mode 1))

;; fic-mode
;; --------
;; highlight FIXME, TODO, BUG, KLUDGE, in comments
(require 'fic-mode)
(add-hook 'js2-mode-hook 'turn-on-fic-mode)

;; global configurations
;; ---------------------
(line-number-mode t)
(column-number-mode t)
(show-paren-mode 1)
(setq-default indent-tabs-mode nil) ;; don't use tabs to indent
(setq-default tab-width 4) ;; but maintain correct appearance
(setq hippie-expand-try-functions-list '(try-expand-dabbrev
                                         try-expand-dabbrev-all-buffers
                                         try-expand-dabbrev-from-kill
                                         try-complete-file-name-partially
                                         try-complete-file-name
                                         try-expand-all-abbrevs
                                         try-expand-list
                                         try-expand-line
                                         try-complete-lisp-symbol-partially
                                         try-complete-lisp-symbol))

;; my bindings
;; -----------
(global-set-key (kbd "C-c C-g") 'goto-line)
(global-set-key (kbd "C-c C-c") 'comment-region) ;; "C-u C-c C-c" to un-comment
(global-set-key (kbd "M-/") 'hippie-expand) ;; replace dabbrev-expand
(global-set-key (kbd "C-x \\") 'align-regexp)
(global-set-key (kbd "C-x p") 'proced)
(global-set-key (kbd "C-x m") 'eshell) ;; replace compose-mail
(global-set-key (kbd "C-x M") (lambda ()
                                "Start a new eshell even if one is active"
                                (interactive) (eshell t)))
(global-set-key (kbd "C-c e") (lambda eval-and-replace ()
                                "Replace the preceding sexp with its value."
                                (interactive)
                                (backward-kill-sexp)
                                (prin1 (eval (read (current-kill 0)))
                                       (current-buffer))))
(global-set-key (kbd "C-x O") (lambda ()
                                "Same as C-x o but to previous window"
                                (interactive)
                                (other-window -1)))
(global-set-key (kbd "C-x C-b") 'ibuffer) ;; replace buffer-list
(global-set-key (kbd "M-<up>") 'enlarge-window)
(global-set-key (kbd "M-<down>") 'shrink-window)
(global-set-key (kbd "M-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "M-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "C-v") 'er/expand-region)


;(global-set-key (kbd "") ')

;; melpa
(when (>= emacs-major-version 24)
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t))

;; js // nodejs-repl
;; -----------------
;; (global-set-key (kbd "C-c C-r") 'nodejs-repl)
(global-set-key (kbd "C-c C-r") 'run-js)
(global-set-key (kbd "C-c C-d") 'js-send-region-or-line)
(global-set-key (kbd "<f8>") 'foo-fii-faa)

(defun foo-fii-faa ()
  (interactive)
  (switch-to-buffer "*nodejs*")
  
)

(defun run-js ()
  "run the nodejs-repl"
  (interactive)
  (setq curwindow (selected-window))
  (nodejs-repl)
  (select-window curwindow))

(defun run-js-in-current-window ()
  "run the nodejs-repl"
  (interactive)
  (setq curwindow (selected-window))
  ;; save pop-up-frames value to restore it later
  ;; preventing to open a new window
  (setq sav-pop-up-frames pop-up-frames)
  (setq pop-up-frames t)
  (nodejs-repl)
  (setq pop-up-frames sav-pop-up-frames)
  (run-with-idle-timer 1 nil 'switch-to-buffer "*nodejs*")
  (select-window curwindow))

(defun js-send-region ()
  (buffer-substring (mark) (point)))

(defun js-send-line ()
  (save-excursion
    (end-of-line)
    (let ((end (point)))
      (beginning-of-line)
      (buffer-substring (point) end))))

(defun js-send-region-or-line ()
  "Send the current region if it exist, the line otherwise to the inferior Javascript process."
  (interactive)
  (setq curwindow (selected-window))
  ;; open a repl if not already running
  (if (not (get-buffer "*nodejs*"))
      (run-js))
  ;; chose between selection and line
  (setq my-txt (if (and mark-active
           (/= (mark) (point)))
      (js-send-region)
    (js-send-line)))
  (set-buffer "*nodejs*")
  (insert my-txt)
  (comint-send-input)
  (select-window curwindow))
