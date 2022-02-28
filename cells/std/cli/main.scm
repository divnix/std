; SPDX-FileCopyrightText: 2022 The Standard Authors
; SPDX-FileCopyrightText: 2022 The TVL Authors
; SPDX-FileCopyrightText: 2022 Vincent Ambo
;
; SPDX-License-Identifier: MIT

;; std helps you build & run thing from wherever you are
;;
;; this is a tiny tool designed to ease workflows in ropositories that are
;; modeled after Standard.
;;
;; it enables nix builds & runs from any repository location
;; specifying relative or absolute paths

(import (chicken base)
        (chicken format)
        (chicken irregex)
        (chicken port)
        (chicken process)
        (chicken process-context)
        (chicken pathname)
        (chicken string)
        (chicken pretty-print)
        (srfi-13)
        (fmt)
        (matchable)
        (medea)
        (shell)
        (only (chicken io) read-string))

(define usage #<<USAGE
usage: std <command> <target>

target:
  A target is an absolute or relative path to an organelle of types
  'runnables' & 'installables', that optionally specifies an
  attribute if the organelle is not a singleton output.

  run only available on organelles of type 'runnables'

  For example:

    //std/cli         - absolute target to a singleton organelle
    //foo/bar:baz     - absolute target to a multi-output organelle
    cli               - relative target to a singleton organelle
    bar:baz           - relative target to a multi-output organelle

commands:
  ls    - show list of all outputs
  run   - run a target (only for 'runnables')
  build - build a target
  shell - enter a shell with the target's build dependencies
  show  - peek at the nix derivation
USAGE
)

;; parse target definitions. trailing slashes on physical targets are
;; allowed for shell autocompletion.
;;
;; component ::= any string without "/" or ":"
;;
;; physical-target ::= <component>
;;                   | <component> "/"
;;                   | <component> "/" <physical-target>
;;
;; virtual-target ::= ":" <component>
;;
;; relative-target ::= <physical-target>
;;                   | <virtual-target>
;;                   | <physical-target> <virtual-target>
;;
;; root-anchor ::= "//"
;;
;; target ::= <relative-target> | <root-anchor> <relative-target>

;; read a path component until it looks like something else is coming
(define (read-component first port)
  (let ((keep-reading?
         (lambda () (not (or (eq? #\/ (peek-char port))
                             (eq? #\: (peek-char port))
                             (eof-object? (peek-char port)))))))
    (let reader ((acc (list first))
                 (condition (keep-reading?)))
      (if condition (reader (cons (read-char port) acc) (keep-reading?))
          (list->string (reverse acc))))))

;; read something that started with a slash. what will it be?
(define (read-slash port)
  (if (eq? #\/ (peek-char port))
      (begin (read-char port)
             'root-anchor)
      'path-separator))

;; read any target token and leave port sitting at the next one
(define (read-token port)
  (match (read-char port)
         [#\/ (read-slash port)]
         [#\: 'virtual-separator]
         [other (read-component other port)]))

;; read a target into a list of target tokens
(define (read-target target-str)
  (call-with-input-string
   target-str
   (lambda (port)
     (let reader ((acc '()))
       (if (eof-object? (peek-char port))
           (reverse acc)
           (reader (cons (read-token port) acc)))))))

(define-record target absolute components virtual)
(define (empty-target) (make-target #f '() #f))

(define-record-printer (target t out)
  (fprintf out (conc (if (target-absolute t) "//" "")
                     (string-intersperse (target-components t) "/")
                     (if (target-virtual t) ":" "")
                     (or (target-virtual t) ""))))

;; parse and validate a list of target tokens
(define parse-tokens
  (lambda (tokens #!optional (mode 'root) (acc (empty-target)))
    (match (cons mode tokens)
           ;; absolute target
           [('root . ('root-anchor . rest))
            (begin (target-absolute-set! acc #t)
                   (parse-tokens rest 'root acc))]

           ;; relative target minus potential garbage
           [('root . (not ('path-separator . _)))
            (parse-tokens tokens 'normal acc)]

           ;; virtual target
           [('normal . ('virtual-separator . rest))
            (parse-tokens rest 'virtual acc)]

           [('virtual . ((? string? v)))
            (begin
              (target-virtual-set! acc v)
              acc)]

           ;; chomp through all components and separators
           [('normal . ('path-separator . rest)) (parse-tokens rest 'normal acc)]
           [('normal . ((? string? component) . rest))
            (begin (target-components-set!
                    acc (append (target-components acc) (list component)))
                   (parse-tokens rest 'normal acc))]

           ;; nothing more to parse and not in a weird state, all done, yay!
           [('normal . ()) acc]

           ;; oh no, we ran out of input too early :(
           [(_ . ()) `(error . ,(format "unexpected end of input while parsing ~s target" mode))]

           ;; something else was invalid :(
           [_ `(error . ,(format "unexpected ~s while parsing ~s target" (car tokens) mode))])))

(define (parse-target target)
  (let ((target-str (normalize-pathname target))) ; transforms: // -> /
    (parse-tokens (read-target (if (substring=? "/" target-str)
                                   (conc "/" target-str) ; so we put it back in the begining
                                   target-str)))))

;; turn relative targets into absolute targets based on the current
;; directory
(define (normalise-target t)
  (when (not (target-absolute t))
    (target-components-set! t (append (relative-cell-path)
                                      (target-components t)))
    (target-absolute-set! t #t))
  t)

;; nix doesn't care about the distinction between physical and virtual
;; targets, normalise it away
(define (normalised-components t)
  (if (target-virtual t)
      (append (target-components t) (list (target-virtual t)))
      (target-components t)))

;; return the current repository root as a string
(define std--cell-root #f)
(define (cell-root)
  (or std--cell-root
      (begin
        (set! std--cell-root
              (normalize-pathname (get-environment-variable "CELL_ROOT")))
        std--cell-root)))

;; determine the current path relative to the cell root
;; and return it as a list of path components.
(define (relative-cell-path)
  (string-split
   (substring (current-directory) (string-length (cell-root))) "/"))

;; escape a string for interpolation in nix code
(define (nix-escape str)
  (string-translate* str '(("\"" . "\\\"")
                           ("${" . "\\${"))))


;; get current system
(define (current-system)
    (capture "nix eval --raw --impure --expr builtins.currentSystem"))

;; create a nix path to build the attribute at the specified target
(define (nix-url-for target)
  (let ((parts (normalised-components (normalise-target target)))
        (system (current-system)))
    (match parts
           [(cell organelle attr) (conc ".#" system "." cell "." organelle "." attr)]
           [(cell organelle) (conc ".#" system "." cell "." organelle ".default")])))

;; exit and complain at the user if something went wrong
(define (std-error message)
  (format (current-error-port) "[std] error: ~A~%" message)
  (exit 1))

(define (guarantee-success value)
  (match value
         [('error . message) (std-error message)]
         [_ value]))

(define (execute-ls)
  (let ((cmd (conc "nix eval --json --option warn-dirty false .#__std." (current-system))))
    (read-json (capture ,cmd))))

(define (ls args)
  (match args
         [() (ls-no-args)]
         [other (print "not yet implemented")]))

(define (ls-no-args)
  (let* ((result (execute-ls))
         (lines (car (map ls-level-1 result)))
         (formatted-parts (map ls-format-parts lines))
         (pre (string-join (map car formatted-parts) "\n"))
         (mid (string-join (map cadr formatted-parts) "\n"))
         (end (string-join (map caddr formatted-parts) "\n")))
    (fmt #t (tabular (dsp pre) " " (dsp mid) " - " (dsp end)))))

(define (ls-format-parts l)
  (match l
         [(cell organelle clade description)
          (list
            (sprintf "//~A/~A" cell organelle)
            (sprintf "(~A)" clade)
            description)]
         [(cell organelle name clade description)
          (list
            (sprintf "//~A/~A:~A" cell organelle name)
            (sprintf "(~A)" clade)
            description)]))

(define (ls-level-1 l) (map ls-level-2 (cdr l)))
(define (ls-level-2 l) (car (map ls-level-3 (cdr l))))
(define (ls-level-3 l)
  (let*
    ((name (car l))
     (value (cdr l))
     (cell (alist-ref '__std_cell value))
     (clade (alist-ref '__std_clade value))
     (description (alist-ref '__std_description value))
     (organelle (alist-ref '__std_organelle value)))
    (if (equal? name '||)
      (list cell organelle clade description)
      (list cell organelle name clade description))))

(define (execute-run t args)
  (let ((url (nix-url-for t)))
    (printf "[std] running target ~A~%" t)
    (process-execute "nix" (append (list "run" "--option" "warn-dirty" "false" url "--") args))))

(define (run args)
  (match args
         [() (print "not yet implemented")]

         ;; single argument should be a target spec
         [(arg args ...) (execute-run
                          (guarantee-success (parse-target arg)) args)]

         [other (print "not yet implemented")]))

(define (execute-build t)
  (let ((url (nix-url-for t)))
    (printf "[std] building target ~A~%" t)
    (process-execute "nix"
                     (list "build" "--option" "warn-dirty" "false" url "--show-trace"))))

(define (build args)
  (match args
         [() (print "not yet implemented")]

         ;; single argument should be a target spec
         [(arg) (execute-build
                 (guarantee-success (parse-target arg)))]

         [other (print "not yet implemented")]))

(define (execute-shell t)
  (let ((url (nix-url-for t))
        (user-shell (or (get-environment-variable "SHELL") "bash")))
    (printf "[std] entering devshell for ~A~%" t)
    (process-execute "nix"
                     (list "develop" "--option" "warn-dirty" "false" url "--command" user-shell))))

(define (shell args)
  (match args
         [() (print "not yet implemented")]
         [(arg) (execute-shell
                 (guarantee-success (parse-target arg)))]
         [other (print "not yet implemented")]))

(define (execute-show t)
  (let ((url (nix-url-for t)))
    (printf "[std] showing nix derivation of target ~A~%" t)
    (process-execute "nix" (list "edit" "--option" "warn-dirty" "false" url))))

(define (show args)
  (match args
         [() (print "not yet implemented")]
         [(arg) (execute-show
                 (guarantee-success (parse-target arg)))]
         [other (print "not yet implemented")]))

(define (main args)
  (match args
         [() (print usage)]
         [("ls" . _)    (ls    (cdr args))]
         [("run" . _)   (run   (cdr args))]
         [("build" . _) (build (cdr args))]
         [("shell" . _) (shell (cdr args))]
         [("show" . _)  (show  (cdr args))]
         [other (begin (print "unknown command: std " args)
                       (print usage))]))

(main (command-line-arguments))
