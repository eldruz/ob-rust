(require 'ob)

(defvar org-babel-tangle-lang-exts)
(add-to-list 'org-babel-tangle-lang-exts '("rust" . "rs"))

(defcustom org-babel-rust-command "rustc"
  "Name of the rust command."
  :group 'org-babel
  :type 'string)

(defun org-babel-execute:rust (body params)
  (let* ((full-body (org-babel-expand-body:rust body params))
         (cmpflag (or (cdr (assq :cmpflag params)) ""))
         (cmdline (or (cdr (assq :cmdline params)) ""))
         (default-directory org-babel-temporary-directory)
         (src-file (org-babel-temp-file "rust-src-" ".rs"))
         (exe-file (org-babel-rust-exe-file src-file cmpflag))
         (results))
    (with-temp-file src-file
      (insert full-body)
      (when (require 'rust-mode nil t)
        (rust-format-buffer)))
    (org-babel-eval
     (format "%s %s %s" org-babel-rust-command cmpflag src-file) "")
    (setq results (org-babel-eval (format "%s %s" exe-file cmdline) ""))
    (org-babel-reassemble-table
     (org-babel-result-cond (cdr (assq :result-params params))
       (org-babel-read results)
       (let ((tmp-file (org-babel-temp-file "rs-")))
         (with-temp-file tmp-file (insert results))
         (org-babel-import-elisp-from-file tmp-file)))
     (org-babel-pick-name
      (cdr (assq :colname-names params)) (cdr (assq :colnames params)))
     (org-babel-pick-name
      (cdr (assq :rowname-names params)) (cdr (assq :rownames params))))))

  ;;; Helper functions.

(defun org-babel-rust-exe-file (src-file cmpflag)
  "Compute the executable name according to the parameters given
   to the command line. It assumes that the source file has been
   created at (org-babel-temporary-directory). For spaces to be
   correctly recognized they need to be escaped."
  (if (string= cmpflag "")
      (file-name-sans-extension src-file)
    (let* ((flag-list (split-string cmpflag " "))
           (out-file (nth 1 (member "-o" flag-list)))
           (out-dir (nth 1 (member "--out-dir" flag-list))))
      (cond
       (out-file
        (if (string-match-p "^/" out-file) ;naive absolute file path detection
            (expand-file-name out-file "/")
          (expand-file-name out-file org-babel-temporary-directory)))
       (out-dir
        (expand-file-name (file-name-base src-file) (file-name-as-directory out-dir)))
       (t
        (file-name-sans-extension src-file))))))

(defun org-babel-rust-ensure-main-wrap (body vars)
  "Wrap BODY in a \"main\" function call if none exist. Inserts
  the variables right after the main declaration, regardless of
  the \"main\" existence."
  (let ((rust-main-regexp "^[ \t]*fn[ \t\n\r]*main[ \t]*()[ \t\n]*{[ \t]*")
        (rust-main-wrapper "fn main() {\n\t%s\n\t%s\n}")
        (pos nil))
    (if (string-match rust-main-regexp body)
        (progn
          (setq pos (match-end 0))
          (concat
           (substring body 0 pos)
           "\n"
           (mapconcat 'org-babel-rust-var-to-rust vars "\n")
           (substring body pos nil)))
      (format
       rust-main-wrapper
       (mapconcat 'org-babel-rust-var-to-rust vars "\n")
       body))))

(defun org-babel-expand-body:rust (body params)
  "Expand a block of rust code with org-babel according to its
  header arguments."
  (let* ((main-p (not (string= (cdr (assq :main params)) "no")))
         (uses (org-babel-read (cdr (assq :use params)) nil))
         (vars (org-babel--get-vars params)))
    (when (stringp uses)
      (setq uses (split-string uses)))
    (mapconcat
     'identity
     (list
      ;; uses
      (mapconcat
       (lambda (use) (format "use %s;" use))
       uses
       "\n")
      ;; main vith vars if present
      (org-babel-rust-ensure-main-wrap body vars))
     "\n\t")))

(defun org-babel-rust-val-to-rust-type (val)
  "Infers the correct rust data type from the value of the given
  argument."
  (cond
   ((symbolp val)
    (cond
     ((= (length (symbol-name val)) 1) 'char)
     ((or (string= val "true") (string= val "false")) 'bool)
     (t '&str)))
   ((stringp val)
    (cond
     ((or (string= val "true") (string= val "false")) 'bool)
     (t '&str)))
   ((integerp val)
    'isize)
   ((floatp val)
    'f64)
   (t
    nil)))

(defun org-babel-rust-var-to-rust (var-pairs)
  "Formats a given variable name, variable value pair according
to its type in correct rust.

The variable name follows the following rules :

- if the name starts with \"mut_\", the variable will be declared
as mutable in rust code, and be referenced by its name minus the
\"mut\",

- if the name is followed by a \":\", the text preceding the
\"=\" sign will be treated as its type. If no type is given one
will be infered."
  (let* ((var (car var-pairs))
         (val (cdr var-pairs))
         (value-type (org-babel-rust-val-to-rust-type val))
         (var-s (symbol-name var))
         (var-regexp "\\(^mut_\\)?\\([[:alnum:]_]+\\)\\(: ?[[:alnum:]]+\\)?[ \t]*$")
         (mut
          (progn
            (string-match var-regexp var-s)
            (match-string 1 var-s)))
         (var-name
          (progn
            (string-match var-regexp var-s)
            (match-string 2 var-s)))
         (var-type
          (or
           (progn
             (string-match var-regexp var-s)
             (match-string 3 var-s))
           (format ":%s" (symbol-name (org-babel-rust-val-to-rust-type val)))))
         (pre (format "let %s"
                      (if (string-match "^mut_" var-s)
                          (concat "mut " (substring var-s (match-end 0) nil))
                        var)))
         (value (cond
                 ((string-match-p ": ?[iuf]" var-type) (format "%s" val))
                 ((string-match-p ": ?bool" var-type) (format "%s" val))
                 ((string-match-p ": ?char" var-type) (format "'%s'" val))
                 (t (format "\"%s\"" val)))))
    (setq mut (when mut "mut "))
    (concat "let " mut var-name var-type " = " value ";")))

(provide 'ob-rust)
