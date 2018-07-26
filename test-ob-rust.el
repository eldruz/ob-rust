(require 'ert)

(ert-deftest ob-rust/simple ()
  (when (executable-find org-babel-rust-command)
    (with-temp-buffer
      (insert-file-contents "./test-ob-rust.org")
      (org-babel-goto-named-src-block "test-simple")
      (should (= 42 (org-babel-execute-src-block))))))

(ert-deftest ob-rust/main-wrapper ()
  (when (executable-find org-babel-rust-command)
    (with-temp-buffer
      (insert-file-contents "test-ob-rust.org")
      (org-babel-goto-named-src-block "test-main-wrapper")
      (should (= 42 (org-babel-execute-src-block))))))

(ert-deftest ob-rust/var-integer ()
  (when (executable-find org-babel-rust-command)
    (with-temp-buffer
      (insert-file-contents "test-ob-rust.org")
      (org-babel-goto-named-src-block "test-var-integer")
      (should (= 42 (org-babel-execute-src-block))))))

(ert-deftest ob-rust/var-float ()
  (when (executable-find org-babel-rust-command)
    (with-temp-buffer
      (insert-file-contents "test-ob-rust.org")
      (org-babel-goto-named-src-block "test-var-float")
      (should (= 3.14 (org-babel-execute-src-block))))))

(ert-deftest ob-rust/var-char ()
  (when (executable-find org-babel-rust-command)
    (with-temp-buffer
      (insert-file-contents "test-ob-rust.org")
      (org-babel-goto-named-src-block "test-var-char")
      (should (string= "x" (org-babel-execute-src-block))))))

(ert-deftest ob-rust/var-string ()
  (when (executable-find org-babel-rust-command)
    (with-temp-buffer
      (insert-file-contents "test-ob-rust.org")
      (org-babel-goto-named-src-block "test-var-string")
      (should (string= "GOAT" (org-babel-execute-src-block))))))

(ert-deftest ob-rust/var-bool-true ()
  (when (executable-find org-babel-rust-command)
    (with-temp-buffer
      (insert-file-contents "test-ob-rust.org")
      (org-babel-goto-named-src-block "test-var-bool-true")
      (should (string= "42" (org-babel-execute-src-block))))))

(ert-deftest ob-rust/var-bool-false ()
  (when (executable-find org-babel-rust-command)
    (with-temp-buffer
      (insert-file-contents "test-ob-rust.org")
      (org-babel-goto-named-src-block "test-var-bool-false")
      (should (string= "42" (org-babel-execute-src-block))))))

(ert-deftest ob-rust/var-mutable ()
  (when (executable-find org-babel-rust-command)
    (with-temp-buffer
      (insert-file-contents "test-ob-rust.org")
      (org-babel-goto-named-src-block "test-var-mutable")
      (should (= 42 (org-babel-execute-src-block))))))

(ert-deftest ob-rust/var-given-type ()
  (when (executable-find org-babel-rust-command)
    (with-temp-buffer
      (insert-file-contents "test-ob-rust.org")
      (org-babel-goto-named-src-block "test-var-given-type")
      (should (= 42 (org-babel-execute-src-block))))))

(ert-deftest ob-rust/var-mutable-and-given-type ()
  (when (executable-find org-babel-rust-command)
    (with-temp-buffer
      (insert-file-contents "test-ob-rust.org")
      (org-babel-goto-named-src-block "test-var-mutable-and-given-type")
      (should (= 42 (org-babel-execute-src-block))))))

(ert-deftest ob-rust/var-no-main-wrapper ()
  (when (executable-find org-babel-rust-command)
    (with-temp-buffer
      (insert-file-contents "test-ob-rust.org")
      (org-babel-goto-named-src-block "test-var-no-main-wrapper")
      (should (= 42 (org-babel-execute-src-block))))))

(ert-deftest ob-rust/uses-and-command-line-arguments ()
  (when (executable-find org-babel-rust-command)
    (with-temp-buffer
      (insert-file-contents "test-ob-rust.org")
      (org-babel-goto-named-src-block "test-uses-and-command-line-arguments")
      (should (equal '((1 . (2 . ("bonjour")))) (org-babel-execute-src-block))))))
