;;; emacs-badge.el --- providing a function to update on-dock badge.-*- lexical-binding: t; -*-

;; Copyright (C) 2021 Mingkai Dong

;; Author: Mingkai Dong <mk@dong.mk>
;; URL: https://github.com/mkvoya/emacs-badge
;; Version: 0.1
;; Package-Requires: ((emacs "29.0"))

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 3, or (at your
;; option) any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; This package provides the ability to update the badge on Emacs icon on the MacOS app dock.

;;; Code:

(defvar emacs-badge--current-badge)

(declare-function emacs-badge--update "emacs-badge-module")

(defun emacs-badge-current()
  "Return current label of the shown badge."
  (interactive)
  emacs-badge--current-badge)

(defun emacs-badge-update(label)
  "Update the on-icon badge label with LABEL."
  (interactive "sBadge label: ")
  (setq emacs-badge--current-badge label)
  (emacs-badge--update label))

(when (version< emacs-version "29.0")
  (error "emacs-badge requires an Emacs version >= 29")) ; I think we could relax this.

;; The following code (i.e., auto compiling) is borrowed from https://github.com/akermu/emacs-libvterm/blob/master/vterm.el. Big thanks!
;;;###autoload
(defun emacs-badge-module-compile ()
  "Compile emacs-badge-module."
  (interactive)
  (let* ((emacs-badge-directory
          (shell-quote-argument
           ;; NOTE: This is a workaround to fix an issue with how the Emacs
           ;; feature/native-comp branch changes the result of
           ;; `(locate-library "emacs-badge")'. See emacs-devel thread
           ;; https://lists.gnu.org/archive/html/emacs-devel/2020-07/msg00306.html
           ;; for a discussion.
           (file-name-directory (locate-library "emacs-badge.el" t))))
         (make-commands
          (concat "cd " emacs-badge-directory "; make debug; cd -"))
         (buffer (get-buffer-create " *Install emacs-badge* ")))
    (pop-to-buffer buffer)
    (compilation-mode)
    (if (zerop (let ((inhibit-read-only t))
                 (call-process "sh" nil buffer t "-c" make-commands)))
        (message "Compilation of `emacs-badge' module succeeded")
      (error "Compilation of `emacs-badge' module failed!"))))

;; If the emacs-badge-module is not compiled yet, compile it
(unless (require 'emacs-badge-module nil t)
  (if (y-or-n-p "emacs-badge needs `emacs-badge-module' to work.  Compile it now? ")
      (progn
        (emacs-badge-module-compile)
        (require 'emacs-badge-module))
    (error "emacs-badge will not work until `emacs-badge-module' is compiled!")))

(provide 'emacs-badge)
;;; emacs-badge.el ends here
