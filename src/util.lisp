;;;; util.lisp --- Utilities used by the hooks system.
;;;;
;;;; Copyright (C) 2010, 2011, 2012, 2013 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:in-package #:hooks)

(defun read-value ()
  "Read a replacement value."
  (format *query-io* "Replacement value: ")
  (force-output *query-io*)
  (list (read *query-io*)))

(declaim (inline run-handler-without-restarts))

(defun run-handler-without-restarts (handler &rest args)
  (declare (optimize (speed 3) (safety 0) (debug 0)))
  "Run HANDLER with ARGS."
  (apply (the function handler) args))

(declaim (inline run-handler-with-restarts))

(defun run-handler-with-restarts (handler &rest args)
  "Run HANDLER with ARGS after installing appropriate restarts.
The installed restarts are:
+ retry
+ skip
+ use-value"
  (let ((result))
    (tagbody
     :retry
       (restart-case
	   (setf result (multiple-value-list
			 (apply (the function handler) args)))

	 ;; Retry running the handler.
	 (retry ()
	   :report
	   (lambda (stream)
	     (format stream
		     "~@<Retry running handler ~S.~:@>" handler))
	   (go :retry))

	 ;; Skip the handler.
	 (skip ()
	   :report
	   (lambda (stream)
	     (format stream
		     "~@<Skip handler ~S.~:@>" handler)))

	 ;; Use a replacement value.
	 (use-value (value)
	   :report
	   (lambda (stream)
	     (format stream
		     "~@<Specify a value to be used instead of the ~
result of running handler ~S.~:@>"
		     handler))
	   :interactive read-value
	   (setf result (list value)))))
    (apply #'values result)))

(defmacro with-hook-restarts (hook &body body)
  "Run BODY after installing restarts for HOOK.
The installed restarts are:
+ retry
+ use-value"
  (once-only (hook)
    `(let ((result))
       (tagbody
	:retry
	  (restart-case
	      (setf result (multiple-value-list (progn ,@body)))

	    ;; Retry running the hook.
	    (retry ()
	      :report
	      (lambda (stream)
		(format stream
			"Retry running hook ~S." ,hook))
	      (go :retry))

	    ;; Use a replacement value.
	    (use-value (value)
	      :report
	      (lambda (stream)
		(format stream
			"Specify a value instead of running hook ~S."
			,hook))
	      :interactive read-value
	      (setf result (list value)))))
       (apply #'values result))))
