(defpackage :lem-sucle
  (:use :cl :lem))
(in-package :lem-sucle)

(defclass sucle (lem:implementation)
  ()
  (:default-initargs
   :native-scroll-support nil
   :redraw-after-modifying-floating-window t))

(setf *implementation* (make-instance 'sucle))

(define-condition exit-editor (editor-condition)
  ((value
    :initarg :value
    :reader exit-editor-value
    :initform nil)))

(defvar *keycode-table* (make-hash-table))
(defvar *keyname-table* (make-hash-table :test 'equal))

(defun defkeycode (name code &optional key)
  (setf (gethash name *keyname-table*) code)
  (when key (setf (gethash code *keycode-table*) key)))

(defun get-code (name)
  (let ((code (gethash name *keyname-table*)))
    (assert code)
    code))

(defun char-to-key (char)
  (or (gethash (char-code char) *keycode-table*)
      (make-key :sym (string char))))

(defun get-key-from-name (name)
  (char-to-key (code-char (get-code name))))

(defkeycode "C-@" 0 (make-key :ctrl t :sym "@"))
(defkeycode "C-a" 1 (make-key :ctrl t :sym "a"))
(defkeycode "C-b" 2 (make-key :ctrl t :sym "b"))
(defkeycode "C-c" 3 (make-key :ctrl t :sym "c"))
(defkeycode "C-d" 4 (make-key :ctrl t :sym "d"))
(defkeycode "C-e" 5 (make-key :ctrl t :sym "e"))
(defkeycode "C-f" 6 (make-key :ctrl t :sym "f"))
(defkeycode "C-g" 7 (make-key :ctrl t :sym "g"))
(defkeycode "C-h" 8 (make-key :ctrl t :sym "h"))
(defkeycode "C-i" 9 (make-key :sym "Tab"))
(defkeycode "C-j" 10 (make-key :ctrl t :sym "j"))
(defkeycode "C-k" 11 (make-key :ctrl t :sym "k"))
(defkeycode "C-l" 12 (make-key :ctrl t :sym "l"))
(defkeycode "C-m" 13 (make-key :sym "Return"))
(defkeycode "C-n" 14 (make-key :ctrl t :sym "n"))
(defkeycode "C-o" 15 (make-key :ctrl t :sym "o"))
(defkeycode "C-p" 16 (make-key :ctrl t :sym "p"))
(defkeycode "C-q" 17 (make-key :ctrl t :sym "q"))
(defkeycode "C-r" 18 (make-key :ctrl t :sym "r"))
(defkeycode "C-s" 19 (make-key :ctrl t :sym "s"))
(defkeycode "C-t" 20 (make-key :ctrl t :sym "t"))
(defkeycode "C-u" 21 (make-key :ctrl t :sym "u"))
(defkeycode "C-v" 22 (make-key :ctrl t :sym "v"))
(defkeycode "C-w" 23 (make-key :ctrl t :sym "w"))
(defkeycode "C-x" 24 (make-key :ctrl t :sym "x"))
(defkeycode "C-y" 25 (make-key :ctrl t :sym "y"))
(defkeycode "C-z" 26 (make-key :ctrl t :sym "z"))
(defkeycode "escape" 27 (make-key :sym "Escape"))
(defkeycode "C-\\" 28 (make-key :ctrl t :sym "\\"))
(defkeycode "C-]" 29 (make-key :ctrl t :sym "]"))
(defkeycode "C-^" 30 (make-key :ctrl t :sym "^"))
(defkeycode "C-_" 31 (make-key :ctrl t :sym "_"))
(defkeycode "Spc" #x20 (make-key :sym "Space"))
(defkeycode "[backspace]" #x7F (make-key :sym "Backspace"))

(loop :for code :from #x21 :below #x7F
      :do (let ((string (string (code-char code))))
            (defkeycode string code (make-key :sym string))))

(defkeycode "[down]" #o402 (make-key :sym "Down"))
(defkeycode "[up]" #o403 (make-key :sym "Up"))
(defkeycode "[left]" #o404 (make-key :sym "Left"))
(defkeycode "[right]" #o405 (make-key :sym "Right"))
(defkeycode "C-down" 525 (make-key :ctrl t :sym "Down"))
(defkeycode "C-up" 566 (make-key :ctrl t :sym "Up"))
(defkeycode "C-left" 545 (make-key :ctrl t :sym "Left"))
(defkeycode "C-right" 560 (make-key :ctrl t :sym "Right"))
(defkeycode "[home]" #o406 (make-key :sym "Home"))
(defkeycode "[backspace]" #o407 (make-key :sym "Backspace"))
(defkeycode "[f0]" #o410 (make-key :sym "F0"))
(defkeycode "[f1]" #o411 (make-key :sym "F1"))
(defkeycode "[f2]" #o412 (make-key :sym "F2"))
(defkeycode "[f3]" #o413 (make-key :sym "F3"))
(defkeycode "[f4]" #o414 (make-key :sym "F4"))
(defkeycode "[f5]" #o415 (make-key :sym "F5"))
(defkeycode "[f6]" #o416 (make-key :sym "F6"))
(defkeycode "[f7]" #o417 (make-key :sym "F7"))
(defkeycode "[f8]" #o420 (make-key :sym "F8"))
(defkeycode "[f9]" #o421 (make-key :sym "F9"))
(defkeycode "[f10]" #o422 (make-key :sym "F10"))
(defkeycode "[f11]" #o423 (make-key :sym "F11"))
(defkeycode "[f12]" #o424 (make-key :sym "F12"))
(defkeycode "[sf1]" #o425 (make-key :shift t :sym "F1"))
(defkeycode "[sf2]" #o426 (make-key :shift t :sym "F2"))
(defkeycode "[sf3]" #o427 (make-key :shift t :sym "F3"))
(defkeycode "[sf4]" #o430 (make-key :shift t :sym "F4"))
(defkeycode "[sf5]" #o431 (make-key :shift t :sym "F5"))
(defkeycode "[sf6]" #o432 (make-key :shift t :sym "F6"))
(defkeycode "[sf7]" #o433 (make-key :shift t :sym "F7"))
(defkeycode "[sf8]" #o434 (make-key :shift t :sym "F8"))
(defkeycode "[sf9]" #o435 (make-key :shift t :sym "F9"))
(defkeycode "[sf10]" #o436 (make-key :shift t :sym "F10"))
(defkeycode "[sf11]" #o437 (make-key :shift t :sym "F11"))
(defkeycode "[sf12]" #o440 (make-key :shift t :sym "F12"))
(defkeycode "[dl]" #o510)
(defkeycode "[il]" #o511)
(defkeycode "[dc]" #o512 (make-key :sym "Delete"))
(defkeycode "C-dc" 519 (make-key :ctrl t :sym "Delete"))
(defkeycode "[ic]" #o513)
(defkeycode "[eic]" #o514)
(defkeycode "[clear]" #o515)
(defkeycode "[eos]" #o516)
(defkeycode "[eol]" #o517)
(defkeycode "[sf]" #o520 (make-key :shift t :sym "Down"))
(defkeycode "[sr]" #o521 (make-key :shift t :sym "Up"))
(defkeycode "[npage]" #o522 (make-key :sym "PageDown"))
(defkeycode "[ppage]" #o523 (make-key :sym "PageUp"))
(defkeycode "[stab]" #o524)
(defkeycode "[ctab]" #o525)
(defkeycode "[catab]" #o526)
(defkeycode "[enter]" #o527)
(defkeycode "[print]" #o532)
(defkeycode "[ll]" #o533)
(defkeycode "[a1]" #o534)
(defkeycode "[a3]" #o535)
(defkeycode "[b2]" #o536)
(defkeycode "[c1]" #o537)
(defkeycode "[c3]" #o540)
(defkeycode "[btab]" #o541  (make-key :shift t :sym "Tab"))
(defkeycode "[beg]" #o542)
(defkeycode "[cancel]" #o543)
(defkeycode "[close]" #o544)
(defkeycode "[command]" #o545)
(defkeycode "[copy]" #o546)
(defkeycode "[create]" #o547)
(defkeycode "[end]" #o550 (make-key :sym "End"))
(defkeycode "[exit]" #o551)
(defkeycode "[find]" #o552)
(defkeycode "[help]" #o553)
(defkeycode "[mark]" #o554)
(defkeycode "[message]" #o555)
(defkeycode "[move]" #o556)
(defkeycode "[next]" #o557)
(defkeycode "[open]" #o560)
(defkeycode "[options]" #o561)
(defkeycode "[previous]" #o562)
(defkeycode "[redo]" #o563)
(defkeycode "[reference]" #o564)
(defkeycode "[refresh]" #o565)
(defkeycode "[replace]" #o566)
(defkeycode "[restart]" #o567)
(defkeycode "[resume]" #o570)
(defkeycode "[save]" #o571)
(defkeycode "[sbeg]" #o572)
(defkeycode "[scancel]" #o573)
(defkeycode "[scommand]" #o574)
(defkeycode "[scopy]" #o575)
(defkeycode "[screate]" #o576)
(defkeycode "[sdc]" #o577 (make-key :shift t :sym "Delete"))
(defkeycode "[sdl]" #o600)
(defkeycode "[select]" #o601)
(defkeycode "[send]" #o602 (make-key :shift t :sym "End"))
(defkeycode "[seol]" #o603)
(defkeycode "[sexit]" #o604)
(defkeycode "[sfind]" #o605)
(defkeycode "[shelp]" #o606)
(defkeycode "[shome]" #o607 (make-key :shift t :sym "Home"))
(defkeycode "[sic]" #o610)
(defkeycode "[sleft]" #o611 (make-key :shift t :sym "Left"))
(defkeycode "[smessage]" #o612)
(defkeycode "[smove]" #o613)
(defkeycode "[snext]" #o614 (make-key :shift t :sym "PageDown"))
(defkeycode "[soptions]" #o615)
(defkeycode "[sprevious]" #o616 (make-key :shift t :sym "PageUp"))
(defkeycode "[sprint]" #o617)
(defkeycode "[sredo]" #o620)
(defkeycode "[sreplace]" #o621)
(defkeycode "[sright]" #o622 (make-key :shift t :sym "Right"))
(defkeycode "[srsume]" #o623)
(defkeycode "[ssave]" #o624)
(defkeycode "[ssuspend]" #o625)
(defkeycode "[sundo]" #o626)
(defkeycode "[suspend]" #o627)
(defkeycode "[undo]" #o630)
(defkeycode "[mouse]" #o631)
(defkeycode "[resize]" #o632)
(defkeycode "[event]" #o633)

(struct-to-clos:struct->class
 (defstruct ncurses-view
   scrwin
   modeline-scrwin
   x
   y
   width
   height))

(defun attribute-to-bits (attribute-or-name)
  (let ((attribute (ensure-attribute attribute-or-name nil))
        (cursorp (eq attribute-or-name 'cursor)))
    (if (null attribute)
        0
        (or (lem::attribute-%internal-value attribute)
            (let* ((foreground (attribute-foreground attribute))
                   (background (attribute-background attribute))
                   (bits (logior (if (or cursorp (lem::attribute-reverse-p attribute))
                                     (lem.term:get-color-pair background foreground)
                                     (lem.term:get-color-pair foreground background))
                                 0
                                 (if (lem::attribute-bold-p attribute)
                                     ;;charms/ll:a_bold
				     %lem-opengl::a_bold
                                     0)
                                 (if (lem::attribute-underline-p attribute)
                                     ;;charms/ll:a_underline
				     %lem-opengl::a_underline
                                     0))))
              (setf (lem::attribute-%internal-value attribute) bits)
              bits)))))
#+nil
(defun get-key (code)
  (let* ((char (let ((nbytes (utf8-bytes code)))
                 (if (= nbytes 1)
                   (code-char code)
                   (let ((vec (make-array nbytes :element-type '(unsigned-byte 8))))
                     (setf (aref vec 0) code)
                     (loop :for i :from 1 :below nbytes
                           :do (setf (aref vec i) (charms/ll:getch)))
                     (handler-case (schar (babel:octets-to-string vec) 0)
                       (babel-encodings:invalid-utf8-continuation-byte ()
                         (code-char code)))))))
         (key (char-to-key char)))
    key))
#+nil
(let ((resize-code (get-code "[resize]"))
      (abort-code (get-code "C-]"))
      (escape-code (get-code "escape")))
  (defun get-event ()
    ;;FIXME
    (tagbody :start
      (return-from get-event
        (let ((code (charms/ll:getch)))
          (cond ((= code -1) (go :start))
                ((= code resize-code) :resize)
                ((= code abort-code) :abort)
                ((= code escape-code)
                 (charms/ll:timeout 100)
                 (let ((code (prog1 (charms/ll:getch)
                               (charms/ll:timeout -1))))
                   (cond ((= code -1)
                          (get-key-from-name "escape"))
                         ((= code #.(char-code #\[))
                          (if (= (prog1 (charms/ll:getch)
                                   (charms/ll:timeout -1))
                                 #.(char-code #\<))
                              ;;sgr(1006)
                              (uiop:symbol-call :lem-mouse-sgr1006 :parse-mouse-event)
                              (get-key-from-name "escape"))) ;; [tbd] unknown escape sequence
                         (t
                          (let ((key (get-key code)))
                            (make-key :meta t
                                      :sym (key-sym key)
                                      :ctrl (key-ctrl key)))))))
                (t
                 (get-key code))))))))

(defun input-loop (editor-thread)
  (print "lem gl")
  (funcall
   (application::just-main
    (lambda ()
      (block out
	(handler-case
	    (block cya
	      (loop
		 (application:poll-app)
		 (%lem-opengl::per-frame)
		 (handler-case
		     (progn
		       (unless (bt:thread-alive-p editor-thread) (return-from cya))
		       (let ((event
			      (cond ((window:skey-j-p (window::keyval #\e)) :abort))
			       #+nil
			       (get-event)))
			 (if (eq event :abort)
			     (send-abort-event editor-thread nil)
			     ;;(send-event event)
			     )))
		   #+sbcl
		   (sb-sys:interactive-interrupt (c)
		     (declare (ignore c))
		     (send-abort-event editor-thread t)))))
	  (exit-editor (c) (return-from out c)))))
    :width (floor (* 80 %lem-opengl::*glyph-width*))
    :height (floor (* 25 %lem-opengl::*glyph-height*))
    :title "")))

#+nil
(defun input-loop (editor-thread)
  (handler-case
      (loop
        (handler-case
            (progn
              (unless (bt:thread-alive-p editor-thread) (return))
              (let ((event (get-event)))
                (if (eq event :abort)
                    (send-abort-event editor-thread nil)
                    (send-event event))))
          #+sbcl
          (sb-sys:interactive-interrupt (c)
            (declare (ignore c))
            (send-abort-event editor-thread t))))
    (exit-editor (c) (return-from input-loop c))))

(add-hook *before-init-hook*
          (lambda ()
            (load-theme "emacs-dark")))

(defmethod lem-if:invoke ((implementation sucle) function)
  (let ((result nil)
        (input-thread (bt:current-thread)))
    (lem.term:term-init)
    (let ((editor-thread
	   (funcall function
		    nil
		    (lambda (report)
		      (bt:interrupt-thread
		       input-thread
		       (lambda ()
			 (print report)
			 (error 'exit-editor :value report)))))))
      (setf result (input-loop editor-thread)))
    (when (and (typep result 'exit-editor)
               (exit-editor-value result))
      (format t "~&~A~%" (exit-editor-value result)))))

(defmethod lem-if:display-background-mode ((implementation sucle))
  (lem.term:background-mode))

(defmethod lem-if:update-foreground ((implementation sucle) color-name)
  (lem.term:term-set-foreground color-name))

(defmethod lem-if:update-background ((implementation sucle) color-name)
  (lem.term:term-set-background color-name))

(defmethod lem-if:display-width ((implementation sucle))
  (max 5
       %lem-opengl::*columns*
       ;;charms/ll:*cols*
       ))

(defmethod lem-if:display-height ((implementation sucle))
  (max 3
       %lem-opengl::*lines*
       ;;charms/ll:*lines*
       ))

(defmethod lem-if:make-view
    ((implementation sucle) window x y width height use-modeline)
  (flet ((newwin (nlines ncols begin-y begin-x main-screen)
           (declare (ignore main-screen))
           (let ((win
		  (;;charms/ll:newwin
		   %lem-opengl::ncurses-newwin
		   nlines ncols begin-y begin-x)))
             (when use-modeline (;;charms/ll:keypad
				 %lem-opengl::ncurses-keypad
				 win 1))
             ;; (when main-screen
             ;;   (charms/ll:idlok win 1)
             ;;   (charms/ll:scrollok win 1))
             win)))
    (make-ncurses-view
     :scrwin (newwin height width y x nil)
     :modeline-scrwin (when use-modeline (newwin 1 width (+ y height) x nil))
     :x x
     :y y
     :width width
     :height height)))

(defmethod lem-if:delete-view ((implementation sucle) view)
  (;;charms/ll:delwin
   %lem-opengl::ncurses-delwin
   (ncurses-view-scrwin view))
  (when (ncurses-view-modeline-scrwin view)
    (;;charms/ll:delwin
     %lem-opengl::ncurses-delwin
     (ncurses-view-modeline-scrwin view))))

(defmethod lem-if:clear ((implementation sucle) view)
  ;;;https://linux.die.net/man/3/clearok
  (;;charms/ll:clearok
   %lem-opengl::ncurses-clearok
   (ncurses-view-scrwin view) 1)
  (when (ncurses-view-modeline-scrwin view)
    (;;charms/ll:clearok
     %lem-opengl::ncurses-clearok
     (ncurses-view-modeline-scrwin view) 1)))

(defmethod lem-if:set-view-size ((implementation sucle) view width height)
  (setf (ncurses-view-width view) width)
  (setf (ncurses-view-height view) height)
  (;;charms/ll:wresize
   %lem-opengl::ncurses-wresize
   (ncurses-view-scrwin view) height width)
  (when (ncurses-view-modeline-scrwin view)
    (;;charms/ll:mvwin
     %lem-opengl::ncurses-mvwin
     (ncurses-view-modeline-scrwin view)
     (+ (ncurses-view-y view) height)
     (ncurses-view-x view))
    (;;charms/ll:wresize
     %lem-opengl::ncurses-wresize
     (ncurses-view-modeline-scrwin view)
     (minibuffer-window-height)
     width)))

(defmethod lem-if:set-view-pos ((implementation sucle) view x y)
  (setf (ncurses-view-x view) x)
  (setf (ncurses-view-y view) y)
  (;;charms/ll:mvwin
   %lem-opengl::ncurses-mvwin
   (ncurses-view-scrwin view) y x)
  (when (ncurses-view-modeline-scrwin view)
    (;;charms/ll:mvwin
     %lem-opengl::ncurses-mvwin
     (ncurses-view-modeline-scrwin view)
     (+ y (ncurses-view-height view))
     x)))

(defmethod lem-if:print ((implementation sucle) view x y string attribute)
  (let ((attr (attribute-to-bits attribute)))
    (;;charms/ll:wattron
     %lem-opengl::ncurses-wattron
     (ncurses-view-scrwin view) attr)
    ;;(charms/ll:scrollok (ncurses-view-scrwin view) 0)
    (;;charms/ll:mvwaddstr
     %lem-opengl::ncurses-mvwaddstr
     (ncurses-view-scrwin view) y x string)
    ;;(charms/ll:scrollok (ncurses-view-scrwin view) 1)
    (;;charms/ll:wattroff
     %lem-opengl::ncurses-wattroff
     (ncurses-view-scrwin view) attr)))

(defmethod lem-if:print-modeline ((implementation sucle) view x y string attribute)
  (let ((attr (attribute-to-bits attribute)))
    (;;charms/ll:wattron
     %lem-opengl::ncurses-wattron
     (ncurses-view-modeline-scrwin view) attr)
    (;;charms/ll:mvwaddstr
     %lem-opengl::ncurses-mvwaddstr
     (ncurses-view-modeline-scrwin view) y x string)
    (;;charms/ll:wattroff
     %lem-opengl::ncurses-wattroff
     (ncurses-view-modeline-scrwin view) attr)))

(defmethod lem-if:clear-eol ((implementation sucle) view x y)
  (;;charms/ll:wmove
   %lem-opengl::ncurses-wmove
   (ncurses-view-scrwin view) y x)
  (;;charms/ll:wclrtoeol
   %lem-opengl::ncurses-wclrtoeol
   (ncurses-view-scrwin view)))

(defmethod lem-if:clear-eob ((implementation sucle) view x y)
  (;;charms/ll:wmove
   %lem-opengl::ncurses-wmove
   (ncurses-view-scrwin view) y x)
  (;;charms/ll:wclrtobot
   %lem-opengl::ncurses-wclrtobot
   (ncurses-view-scrwin view)))

(defmethod lem-if:redraw-view-after ((implementation sucle) view focus-window-p)
  ;;FIXME
  (let ((attr (attribute-to-bits 'modeline)))
    (;;charms/ll:attron
     %lem-opengl::ncurses-attron
     attr)
    (when (and (ncurses-view-modeline-scrwin view)
               (< 0 (ncurses-view-x view)))
      (;;charms/ll:move
       %lem-opengl::ncurses-move
       (ncurses-view-y view)
       (1- (ncurses-view-x view)))
      (;;charms/ll:vline
       %lem-opengl::ncurses-vline
       (char-code #\space)
       (1+ (ncurses-view-height view))))
    (;;charms/ll:attroff
     %lem-opengl::ncurses-attron
     attr)
    (;;charms/ll:wnoutrefresh
     %lem-opengl::ncurses-wnoutrefresh
     ;;charms/ll:*stdscr*
     %lem-opengl::*std-scr*))
  (when (ncurses-view-modeline-scrwin view)
    (;;charms/ll:wnoutrefresh
     %lem-opengl::ncurses-wnoutrefresh
     (ncurses-view-modeline-scrwin view)))
  (;;charms/ll:wnoutrefresh
   %lem-opengl::ncurses-wnoutrefresh
   (ncurses-view-scrwin view)))

(defmethod lem-if:update-display ((implementation sucle))
  (let ((scrwin (ncurses-view-scrwin (window-view (current-window)))))
    (if (lem::covered-with-floating-window-p (current-window) lem::*cursor-x* lem::*cursor-y*)
        (;;charms/ll:curs-set
	 %lem-opengl::ncurses-curs-set
	 0)
        (progn
          (;;charms/ll:curs-set
	   %lem-opengl::ncurses-curs-set
	   1)
          (;;charms/ll:wmove
	   %lem-opengl::ncurses-wmove
	   scrwin lem::*cursor-y* lem::*cursor-x*)))
    ;;FIXME
    (;;charms/ll:wnoutrefresh
     %lem-opengl::ncurses-wnoutrefresh
     scrwin)
    (;;charms/ll:doupdate
     %lem-opengl::ncurses-doupdate)))

(defmethod lem-if:scroll ((implementation sucle) view n)
  (;;charms/ll:wscrl
   %lem-opengl::ncurses-wscrl
   (ncurses-view-scrwin view)
   n))

(defmethod lem-if:clipboard-paste ((implementation sucle))
  (trivial-clipboard:text))

(defmethod lem-if:clipboard-copy ((implementation sucle) text)
  (trivial-clipboard:text text))

(pushnew :lem-opengl *features*)
