;;; symbol.lisp --- Hooks that reside in variables
;;
;; Copyright (C) 2010 Jan Moringen
;;
;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>
;;
;; This Program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This Program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses>.

(in-package :hooks)


;;; Behavior for Symbols
;;

(defmethod hook-combination ((hook symbol))
  (get hook 'hook-combination 'cl:progn))

(defmethod (setf hook-combination) ((new-value t) (hook symbol))
  (setf (get hook 'hook-combination) new-value))

(defmethod hook-handlers ((hook symbol))
  (symbol-value hook))

(defmethod (setf hook-handlers) ((new-value list) (hook symbol))
  (setf (symbol-value hook) new-value))

(defmethod documentation ((hook symbol) (type (eql 'hook)))
  (or (get hook 'hook-documentation)
      (documentation hook 'variable)))

(defmethod (setf documentation) ((new-value string) (hook symbol) (type (eql 'hook)))
  (setf (get hook 'hook-documentation) new-value))
