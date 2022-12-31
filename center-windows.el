;;; center-windows.el --- Mode and supporting functions for centering windows  -*- lexical-binding: t; -*-

;; Copyright (C) 2022 Toby Worland

;; Author: Toby Worland
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; A group of functions for centering both all and individual windows. Plus a
;; global minor mode to keep all windows centered.

;; Changed the desired width with the variable `center-windows-desired-width`

;;; Code:

(defgroup center-windows nil
  "Center windows using margins")

(defcustom center-windows-desired-width 80
  "The width windows should be"
  :type 'natnum
  :group 'center-windows)

(defmacro for-every-window (window &rest body)
  "Loop over every window.

Evaluate BODY with WINDOW bound to a window in every frame"
  (declare (indent 1))
  (let ((frame-sym (gensym)))
    `(dolist (,frame-sym (frame-list))
       (dolist (,window (window-list ,frame-sym))
	 ,@body))))

(defun reset-single-window (&optional window)
  "Reset the margins for the given WINDOW or the current if none is given"
  (interactive)
  (set-window-margins window 0 0))

(defun reset-all-windows ()
  "Reset all window margins back to zero"
  (interactive)
  (for-every-window window
    (reset-single-window window)))

(defun center-single-window (&optional window)
  "Center the given window by adding to the window margins until the window is the desired width

If no window is given then default to the currently selected one.
If the actual width is smaller than the desired width, the margins are set to zero"
  (interactive)
  (set-window-margins window 0 0)
  (let ((new-margin (/ (- (window-width window)
			  center-windows-desired-width)
		       2)))
    (when (cl-plusp new-margin)
      (set-window-margins window new-margin new-margin))))

(defun center-all-windows ()
  "Center all windows once"
  (interactive)
  (for-every-window window
    (center-single-window window)))

(define-minor-mode center-windows-mode
  "Toggle centering all windows"
  :global t
  :lighter " Centered"
  :group 'center-windows
  :after-hook
  (if center-windows-mode
      (progn
	(advice-add 'split-window-right :before #'reset-single-window)
	(add-hook 'window-state-change-hook #'center-all-windows)
	(center-all-windows))
    (progn
      (advice-remove 'split-window-right #'reset-single-window)
      (remove-hook 'window-state-change-hook #'center-all-windows)
      (reset-all-windows))))

(provide 'center-windows)
;;; center-windows.el ends here
