(defpackage #:%lem-opengl
  (:use #:cl #:utility #:application #:opengl-immediate
	#:sprite-chain #:point #:rectangle)
  (:export #:start))
(in-package :%lem-opengl)

(defparameter *ticks* 0)
(defparameter *saved-session* nil)
(defun per-frame ()
  (on-session-change *saved-session*
    (init))
  (incf *ticks*)
  (app))

(defparameter *glyph-height* 16.0)
(defparameter *glyph-width* 8.0)

(defparameter *columns* 80)
(defparameter *lines* 25)

(defparameter *app* nil)
(defun start ()
  (application:main
   (lambda ()
     (loop
	(application:poll-app)
					;(if *app*)
	;;(testbed::per-frame)
	(progn
	  ;;#+nil
	  (per-frame)
	  #+nil
	  (when (window:skey-j-p (window::keyval #\e))
	    (window::toggle-mouse-capture)))
	#+nil
	(when (window:skey-j-p (window::keyval #\h))
	  (toggle *app*))))
   :width (floor (* *columns* *glyph-width*))
   :height (floor (* *lines* *glyph-height*))
   :title ""))

(defclass sprite ()
  ((bounding-box :accessor sprite.bounding-box
		 :initform (make-instance 'rectangle
					  :x0 -0.25 :y0 -0.25
					  :x1 0.25 :y1 0.25)
		 :initarg :bounding-box)
   (absolute-rectangle :accessor sprite.absolute-rectangle
		       :initform (make-instance 'rectangle)
		       :initarg :absolute-rectangle)
   (string :accessor sprite.string
	   :initform "Hello World"
	   :initarg :string)
   (tickfun :accessor sprite.tickfun
	    :initform nil
	    :initarg :tickfun)
   (onclick :accessor sprite.onclick
	    :initform nil
	    :initarg :onclick)
   (position :accessor sprite.position
	     :initform (make-instance 'point)
	     :initarg :position)))

(defun closest-multiple (x n)
  (* n (round x n)))

(defparameter *mouse-x* 0.0)
(defparameter *mouse-y* 0.0)

(defun random-point ()
  (make-instance 'point
		 :x (* *glyph-width* (random 80))
		 :y (* *glyph-height* (random 25))))

(defun integer-point (x y)
  (make-instance 'point
		 :x (* *glyph-width* x)
		 :y (* *glyph-height* y)))

(defun string-bounding-box (string &optional (rectangle (make-instance 'rectangle)))
  (multiple-value-bind (x y) (string-bounds string)
    (with-slots (x0 y0 x1 y1) rectangle
      (setf x0 0.0
	    y0 (- (* *glyph-height* y))
	    x1 (* *glyph-width* x)
	    y1 *glyph-height*))))
(defun string-bounds (string)
  (let ((len (length string))
	(maxx 0)
	(x 0)
	(y 0))
    (dotimes (index len)
      (let ((char (aref string index)))
	(cond ((char= char #\Newline)
	       (when (> x maxx)
		 (setf maxx x))
	       (setf x 0)
	       (decf y))
	      (t
	       (setf x (1+ x))))))
    (values (max x maxx) y)))

(defparameter *selection* nil)
(defparameter *hovering* nil)
(defparameter *drag-offset-x* 0.0)
(defparameter *drag-offset-y* 0.0)

(defun init ())
(defun app ()
  (setf *mouse-x* (floatify window::*mouse-x*)
	*mouse-y* (- window::*height* (floatify window::*mouse-y*)))
  (when (window::skey-j-p (window::keyval #\esc))
    (pop-sprite-chain-stack))
  (do-sprite-chain (sprite t) ()
    (let ((fun (sprite.tickfun sprite)))
      (when fun
	(funcall fun))))
  (when 
    (window::skey-j-p (window::mouseval 4))
    (typecase *hovering*
      (sprite
       (sprite-chain:remove-sprite *hovering*)
       (setf *hovering* nil))))

  (let ((mousex *mouse-x*)
	(mousey *mouse-y*))
      ;;search for topmost sprite to drag
    (let
	((sprite
	  (block cya
	    (do-sprite-chain (sprite) ()
	      (with-slots (absolute-rectangle) sprite
		(when (coordinate-inside-rectangle-p mousex mousey absolute-rectangle)
		  (return-from cya sprite)))))))
      (setf *hovering* sprite)
      (when sprite	
	(when (window::skey-j-p (window::mouseval :left))
	  (let ((onclick (sprite.onclick sprite)))
	    (when onclick
	      (funcall onclick sprite))))
	(when (window::skey-j-p (window::mouseval 5))
	  (with-slots (position) sprite
	    (with-slots (x y) position
	      (setf *drag-offset-x* (- x mousex)
		    *drag-offset-y* (- y mousey))))
	  (setf *selection* sprite)
	  (topify-sprite sprite))))
    (typecase *selection*
      (sprite (with-slots (x y) (slot-value *selection* 'position)
		(let ((xnew (closest-multiple (+ *drag-offset-x* mousex) *glyph-width*))
		      (ynew (closest-multiple (+ *drag-offset-y* mousey) *glyph-height*)))
		  (unless (eq x xnew)
		    (setf x xnew))
		  (unless (eq y ynew)
		    (setf y ynew)))))))
  (when (window::skey-j-r (window::mouseval 5))
    (setf *selection* nil))
  
  (do-sprite-chain (sprite t) ()
    (update-bounds sprite))
  

  (glhelp:set-render-area 0 0 window:*width* window:*height*)
  (gl:clear-color 0.5 0.25 0.25 0.0)
  ;(gl:clear :color-buffer-bit)
  (gl:polygon-mode :front-and-back :fill)
  (gl:disable :cull-face)
  (gl:disable :blend)
  (render-stuff))

(defun update-bounds (sprite)
  (with-slots (bounding-box position absolute-rectangle)
      sprite
    (with-slots (x0 y0 x1 y1) bounding-box
      (with-slots ((xpos x) (ypos y)) position
	(let ((px0 (+ x0 xpos))
	      (py0 (+ y0 ypos))
	      (px1 (+ x1 xpos))
	      (py1 (+ y1 ypos)))
	  (with-slots (x0 y0 x1 y1) absolute-rectangle
	    (setf x0 px0 y0 py0 x1 px1 y1 py1)))))))

(progn
  (deflazy flat-shader-source ()
    (glslgen:ashader
     :vs
     (glslgen2::make-shader-stage
      :out '((value-out "vec4"))
      :in '((position "vec4")
	    (value "vec4")
	    (pmv "mat4"))
      :program
      '(defun "main" void ()
	(= "gl_Position" (* pmv position))
	(= value-out value)))
     :frag
     (glslgen2::make-shader-stage
      :in '((value "vec4"))
      :program
      '(defun "main" void ()
	(=
	 :gl-frag-color
	 value
	 )))
     :attributes
     '((position . 0) 
       (value . 3))
     :varyings
     '((value-out . value))
     :uniforms
     '((:pmv (:vertex-shader pmv)))))
  (deflazy flat-shader (flat-shader-source gl-context)
    (glhelp::create-gl-program flat-shader-source)))

(defun bytecolor (r g b &optional (a 3))
  "each channel is from 0 to 3"
  (byte/255		    
   (text-sub::color-rgba r g b a)
   ))

(defun draw-string
    (x y string &optional
		  (fgcol
		   (bytecolor 0 0 0 3
		    ))
		  (bgcol		   
		   (bytecolor 3 3 3 3)
		    ))
  (let ((start x)
	(len (length string)))
    (dotimes (index len)
      (let ((char (aref string index)))
	(cond ((char= char #\Newline)
	       (setf x start)
	       (decf y))
	      (t
	       (color (byte/255 (char-code char))
		      bgcol
		      fgcol)
	       (vertex (floatify x)
		       (floatify y)
		       0.0)			  
	       (incf x)))))))

(defun render-stuff ()
  (text-sub::with-data-shader (uniform rebase)
    (gl:clear :color-buffer-bit)
    (gl:disable :depth-test)

    ;;"sprites"
    (do-sprite-chain (sprite t) ()
      (with-slots (position string)
	  sprite
	(with-slots ((xpos x) (ypos y)) position
	  (multiple-value-bind (fgcolor bgcolor) 
	    (cond ((eq sprite *selection*)
		   (values
		    (bytecolor 3 0 0 3)
		    (bytecolor 0 3 3 0)))
		  ((eq sprite *hovering*)
		   (values
		    (bytecolor 0 0 0)
		    (bytecolor 3 3 3)))
		  (t
		   (values
		    (bytecolor 3 3 3)
		    (bytecolor 0 0 0))))
	    (draw-string (/ xpos *glyph-width*)
			 (/ ypos *glyph-height*)
			 string
			 fgcolor
			 bgcolor)))))
    
    (rebase -128.0 -128.0))
  (gl:point-size 1.0)
  (gl:with-primitives :points
    (opengl-immediate::mesh-vertex-color))
  (text-sub::with-text-shader (uniform)
    (gl:uniform-matrix-4fv
     (uniform :pmv)
     (load-time-value (nsb-cga:identity-matrix))
     nil)   
    (glhelp::bind-default-framebuffer)
    (glhelp:set-render-area 0 0 (getfnc 'application::w) (getfnc 'application::h))
    (gl:enable :blend)
    (gl:blend-func :src-alpha :one-minus-src-alpha)
    (gl:call-list (glhelp::handle (getfnc 'text-sub::fullscreen-quad)))))

(defun plain-button (fun &optional
			   (str (string (gensym "nameless-button-")))
			   (pos (random-point))
			   (sprite (make-instance 'sprite)))
  "a statically named button"
  (let ((rect (make-instance 'rectangle)))
    (string-bounding-box str rect)
    (with-slots (position bounding-box string onclick) sprite
      (setf position pos
	    bounding-box rect
	    string str
	    onclick fun)))
  sprite)

(progn
  (defparameter *sprite-chain-stack* nil)
  (defparameter *sprite-chain-stack-depth* 0)
  (defun push-sprite-chain-stack (&optional (new-top (sprite-chain:make-sprite-chain)))
    (push sprite-chain::*sprites* *sprite-chain-stack*)
    (setf sprite-chain::*sprites* new-top)
    (incf *sprite-chain-stack-depth*))
  (defun pop-sprite-chain-stack ()
    (let ((top (pop *sprite-chain-stack*)))
      (when top
	(decf *sprite-chain-stack-depth*)
	(setf sprite-chain::*sprites* top))))
  (defun replace-sprite-chain-stack ()
    (pop-sprite-chain-stack)
    (push-sprite-chain-stack)))

(defun bottom-layer ()
  #+nil
  (add-sprite
   (plain-button
    (lambda (this) (remove-sprite this))
    "hello world"))
  (add-sprite
   (plain-button
    (lambda (this)
      (declare (ignorable this))
      (application::quit))
    "quit"
    (integer-point 0 1)))
  #+nil
  (add-sprite
   (plain-button
    (lambda (this)
      (declare (ignorable this))
      (new-layer))
    "new"))
  #+nil
  (let ((rect (make-instance 'rectangle))
	(numbuf (make-array 0 :fill-pointer 0 :adjustable t :element-type 'character)))
    (add-sprite
     (make-instance
      'sprite
      :position (integer-point 10 1)
      :bounding-box rect
      :tickfun
      (lambda ()
	;;mouse coordinates
	(setf (fill-pointer numbuf) 0)
	(with-output-to-string (stream numbuf :element-type 'character)
	  #+nil
	  (princ (list (floor *mouse-x*)
		       (floor *mouse-y*))
		 stream)
	  (princ (aref block-data::*names*
		       testbed::*blockid*)
		 stream)
	  )
	(string-bounding-box numbuf rect))
      :string numbuf
      ))))

(defun new-layer ()
  (push-sprite-chain-stack)
  (add-sprite 
   (plain-button
    (lambda (this)
      (declare (ignorable this))
      (new-layer))
    "new"))
  (add-sprite
   (plain-button
    (lambda (this)
      (declare (ignorable this))
      (pop-sprite-chain-stack))
    "back"))
  (add-sprite
   (plain-button
    nil
    (format nil "layer ~a" *sprite-chain-stack-depth*))))

(progn
  (setf sprite-chain::*sprites* (sprite-chain:make-sprite-chain))
  (bottom-layer))

(defparameter *fg-default-really* 0)
(defparameter *bg-default-really* #xffffff)

(defparameter *fg-default* *fg-default-really*)
(defparameter *bg-default* *bg-default-really*)

(defparameter *pairs* (let ((pairs (make-hash-table)))
			(setf (gethash 0 pairs)
			      (cons *fg-default*
				    *bg-default*) ;;;;FIXME whats white and black for default? short?
			      )
			pairs))

(defun ncurses-init-pair (pair-counter fg bg)
  (setf (gethash pair-counter *pairs*)
	(cons fg bg)))
(defun ncurses-color-pair (pair-counter)
  (gethash pair-counter *pairs*))

(defun ncurses-pair-content (pair-counter)
  (let ((pair (ncurses-color-pair pair-counter)))
    (values (car pair)
	    (cdr pair))))

(defun ncurses-assume-default-color (fg bg)
  ;;;;how ncurses works. see https://users-cs.au.dk/sortie/sortix/release/nightly/man/man3/assume_default_colors.3.html
  (setf *fg-default* (if (= fg -1)
			 *fg-default-really*
			 fg)
	*bg-default* (if (= bg -1)
			 *bg-default-really*
			 bg)))

(defparameter *ncurses-windows* (make-hash-table))
(defun add-win (win)
  (setf (gethash win *ncurses-windows*)
	t))
(defun remove-win (win)
  (remhash win *ncurses-windows*))

(struct-to-clos:struct->class
 (defstruct win
   lines
   COLS
   y
   x
   keypad-p ;;see https://linux.die.net/man/3/keypad
   clearok
   scrollok
   attr-bits
   cursor-y
   cursor-x
   data))

(set-pprint-dispatch 'win 'print-win)
(defun print-win (stream win)
  (format stream "lines: ~a cols: ~a" (win-lines win) (win-cols win))
  (print-grid (win-data win) stream (win-cursor-x win) (win-cursor-y win)))

;;window is an array of lines, for easy swapping and scrolling of lines. optimizations later
(defun make-row (width)
  (make-array width :initial-element *clear-glyph*))
(defun make-grid (rows columns)
  (let ((rows-array (make-array rows)))
    (dotimes (i rows)
      (setf (aref rows-array i)
	    (make-row columns)))
    rows-array))

(defun grid-rows (grid)
  (length grid))
(defun grid-columns (grid)
  (length (aref grid 0)))
(utility::etouq
  (let ((place '(aref (aref grid y) x))
	(args '(x y grid)))
    `(progn
       (defun ref-grid (,@args)
	 ,place)
       (defun (setf ref-grid) (new ,@args)
	 (setf ,place new)
	 new))))

(defun print-grid (grid &optional (stream *standard-output*) (cursor-x 0) (cursor-y 0))
  (dotimes (grid-row (grid-rows grid))
    (terpri stream)
    (write-char #\| stream)
    (let ((row-data (aref grid grid-row)))	
      (dotimes (grid-column (grid-columns grid)) ;;FIXME dereferencing redundancy
	(let ((cursor-here-p (and (= grid-column cursor-x)
				  (= grid-row cursor-y)))
	      (x (aref row-data grid-column)))
	  (when cursor-here-p (write-char #\[ stream))
	  (write-char 
	   (typecase x
	     (glyph (glyph-value x))
	     (t #\space))
	   stream)
	  (when cursor-here-p (write-char #\] stream)))))
    (write-char #\| stream))
  (terpri stream)
  grid)

(defun move-row (old-n new-n grid)
  "move row old-n to new-n"
  (cond ((> (grid-rows grid) new-n -1)
	 (setf (aref grid new-n)
	       (aref grid old-n))
	 (setf (aref grid old-n) nil))
	(t (error "moving to a row that does not exist")))
  grid)

(defun transfer-data (grid-src grid-dest)
  (let ((shared-rows
	 (min (grid-rows grid-src)
	      (grid-rows grid-dest)))
	(shared-columns
	 (min (grid-columns grid-src)
	      (grid-columns grid-dest))))
    (dotimes (row-index shared-rows)
      ;;FIXME optimization? can cache the row. but its a fragile optimization
      (dotimes (column-index shared-columns)
	(setf (ref-grid column-index row-index grid-dest)
	      (ref-grid column-index row-index grid-src)))))
  grid-dest)

(defparameter *win* nil)

(defun ncurses-newwin (nlines ncols begin-y begin-x)
  (let ((win (make-win :lines nlines
		       :cols ncols
		       :y begin-y
		       :x begin-x
		       :data (make-grid nlines ncols))))
    (add-win win)
    (setf *win* win)
    win))

(defun ncurses-keypad (win value)
  (setf (win-keypad-p win) value))
(defun ncurses-delwin (win)
  (remove-win win))

(defun c-true (value)
  (not (zerop value)))

(defun ncurses-clearok (win value)
  "If clearok is called with TRUE as argument, the next call to wrefresh with this window will clear the screen completely and redraw the entire screen from scratch. This is useful when the contents of the screen are uncertain, or in some cases for a more pleasing visual effect. If the win argument to clearok is the global variable curscr, the next call to wrefresh with any window causes the screen to be cleared and repainted from scratch. "
  (setf (win-clearok win)
	(c-true value)))

;;;FIXME add default window for ncurses like stdscr

(defun ncurses-mvwin (win x y)
  "Calling mvwin moves the window so that the upper left-hand corner is at position (x, y). If the move would cause the window to be off the screen, it is an error and the window is not moved. Moving subwindows is allowed, but should be avoided."
  ;;;FIXME: detect off screen 
  (setf (win-x win) x
	(win-y win) y))

(defun ncurses-wresize (win height width)
  (setf (win-lines win) height
	(win-cols win) width)
  (let ((old-data (win-data win))
	(new-grid (make-grid height width)))
    (transfer-data old-data new-grid)
    (setf (win-data win)
	  new-grid)))

(defparameter *mouse-enabled-p* nil)

(defun ncurses-wattron (win attr)
  (let ((old (win-attr-bits win)))
    (setf (win-attr-bits win)
	  (logior attr old))))

(defun ncurses-wattroff (win attr)
  (let ((old (win-attr-bits win)))
    (setf (win-attr-bits win)
	  (logand (lognot attr) old))))

;;(defun ncurses-wscrl (win n))
;;https://linux.die.net/man/3/scrollok
(defun ncurses-wmove (win y x)
  (setf (win-cursor-x win) x
	(win-cursor-y win) y))

(defparameter *cursor-state* :normal)
(defun ncurses-curs-set (value)
  "The curs_set routine sets the cursor state is set to invisible, normal, or very visible for visibility equal to 0, 1, or 2 respectively. If the terminal supports the visibility requested, the previous cursor state is returned; otherwise, ERR is returned."
  (setf *cursor-state*
	(case value
	  (0 :invisible)
	  (1 :normal)
	  (2 :very-visible))))

(defparameter A_BOLD #x00200000)
(defparameter A_UNDERLINE #x00020000)

(defun %ncurses-wscrl (grid n)
  (let ((width (grid-columns grid)))
    (cond ((plusp n)
	   ;;scrolling up means lines get moved up,
	   ;;which means start at top of screen to move, which is smallest.
	   (loop :for i :from n :below (grid-rows grid)
	      :do
	      (move-row i
			(- i n)
			grid)))
	  ((minusp n)
	   ;;scrolling down means lines get moved down,
	   ;;which means start at bottom of screen to move, which is largest.
	   (let ((move-distance (- n)))
	     (loop :for i :from (- (grid-rows grid) 1 move-distance) :downto 0
		:do
		(move-row i
			  (+ i move-distance)
			  grid))))
	  ((zerop n) t))
    ;;;;fill in those nil's. OR FIXME
    (map-into grid (lambda (x) (or x (make-row width))) grid))
  grid)
(defun ncurses-wscrl (win n)
  (%ncurses-wscrl (win-data win) n))

(struct-to-clos:struct->class
 (defstruct glyph
   value
   attributes))

(defparameter *clear-glyph* (make-glyph :value #\Space))

(defun ncurses-mvwaddstr (win y x string))
(defun ncurses-wclrtoeol (&optional (win *win*))
  "The clrtoeol() and wclrtoeol() routines erase the current line to the right of the cursor, inclusive, to the end of the current line. https://www.mkssoftware.com/docs/man3/curs_clear.3.asp"
  (let ((x (win-cursor-x win))
	(y (win-cursor-y win)))
    (loop :for i :from x :below (win-cols win)
       :do (add-char i y #\Space win)))
  win)
(defun ncurses-wclrtobot (&optional (win *win*))
  "The clrtobot() and wclrtobot() routines erase from the cursor to the end of screen. That is, they erase all lines below the cursor in the window. Also, the current line to the right of the cursor, inclusive, is erased. https://www.mkssoftware.com/docs/man3/curs_clear.3.asp"
  (ncurses-wclrtoeol win)
  (let ((y (win-cursor-y win)))
    (loop :for i :from (+ y 1) :below (win-lines win)
       :do
       (loop :for z :from 0 :below (win-cols win)
	  :do (add-char z i #\Space win))))
  win)

(defun max-cursor-y (&optional (win *win*))
  "the greatest value a cursor's y pos can be"
  (1- (win-lines win)))
(defun max-cursor-x (&optional (win *win*))
  "the greatest value a cursor's x pos can be"
  (1- (win-cols win)))

(defun ncurses-waddch (win char)
  " The addch(), waddch(), mvaddch() and mvwaddch() routines put the character ch into the given window at its current window position, which is then advanced. They are analogous to putchar() in stdio(). If the advance is at the right margin, the cursor automatically wraps to the beginning of the next line. At the bottom of the current scrolling region, if scrollok() is enabled, the scrolling region is scrolled up one line.

If ch is a tab, newline, or backspace, the cursor is moved appropriately within the window. Backspace moves the cursor one character left; at the left edge of a window it does nothing. Newline does a clrtoeol(), then moves the cursor to the window left margin on the next line, scrolling the window if on the last line). Tabs are considered to be at every eighth column. https://www.mkssoftware.com/docs/man3/curs_addch.3.asp If ch is any control character other than tab, newline, or backspace, it is drawn in ^X notation. Calling winch() after adding a control character does not return the character itself, but instead returns the ^-representation of the control character. (To emit control characters literally, use echochar().) "
  (let ((x (win-cursor-x win))
	(y (win-cursor-y win)))
    (flet ((advance ()	     
	     (if (= (max-cursor-x win) x)
		 (if (= (max-cursor-y win) y)
		     (cond ((win-scrollok win) ;;scroll the window and reset to x pos
			    (ncurses-wscrl win 1)
			    (setf (win-cursor-x win) 0))
			   (t (progn ;;do nothing
				)))
		     ;;reset x and go to next line, theres space
		     (setf (win-cursor-x win) 0
			   (win-cursor-y win) (+ 1 y)))
		 ;;its not at the end of line, no one cares
		 (setf (win-cursor-x win) (+ 1 x)))))
      (cond 
	((char= char #\tab)
	 (setf (win-cursor-x win)
	       (next-8 x)))
	((char= char #\newline)
	 (ncurses-clrtoeol)
	 (let ((max-cursor-y (max-cursor-y win)))
	   (if (= max-cursor-y y)
	       (ncurses-wscrl win 1)
	       (setf (win-cursor-y win)
		     (min (+ 1 y)
			  max-cursor-y))))
	 (setf (win-cursor-x win) 0))
	((char= char #\backspace)
	 (setf (win-cursor-x win)
	       (max 0 (- x 1))))
	((char-control char)
	 (add-char x y #\^ win)
	 (advance)
	 (ncurses-waddch win (char-control-printable char)))
	((standard-char-p char)
	 (add-char x y char win)
	 (advance))
	(t (error "what char? ~s" (char-code char)))))))

(defun next-8 (n)
  "this is for tabbing, see waddch. its every 8th column"
  (* 8 (+ 1 (floor n 8))))

(defun add-char (x y value &optional (win *win*))
  (setf (ref-grid x y (win-data win))
	(make-glyph :value value
		    :attributes (win-attr-bits win)))
  win)

(defun char-control (char)
  ;;FIXME: not portable common lisp, requires ASCII
  (let ((value (char-code char)))
	(if (> 64 value)
	    t
	    nil)))

(defun char-control-printable (char)
  ;;FIXME: not portable common lisp, requires ASCII
  (code-char (logior 64 (char-code char))))

(defun fuzz (&optional (win *win*))
  (dotimes (x 100)
    (add-char (random (win-cols win))
	      (random (win-lines win))
	      #\a
	      win))
  win)


#+nil
(let ((program (getfnc 'flat-shader)))
  (glhelp::use-gl-program program)
  (glhelp:with-uniforms uniform program
    (gl:uniform-matrix-4fv (uniform :pmv)
			   (nsb-cga:matrix*
			    (nsb-cga:scale*
			     (/ 2.0 (floatify window::*width*))
			     (/ 2.0 (floatify window::*height*))
			     1.0)
			    (nsb-cga:translate* 
			     (/ (floatify window::*width*)
				-2.0)				 
			     (/ (floatify window::*height*)
				-2.0)
			     0.0))
			   nil)))
#+nil
(progn
  (do-sprite-chain (sprite t) ()
    (render-sprite sprite))
  (gl:with-primitive :quads
    (mesh-vertex-tex-coord-color)))

#+nil
(defparameter *pen-color* (list 1.0 0.0 0.0 1.0))

#+nil
(defun render-sprite (sprite)
  (with-slots (absolute-rectangle)
      sprite
    (let ((*pen-color*
	   (cond ((eq sprite *selection*)
		  '(1.0 0.0 0.0 1.0))
		 ((eq sprite *hovering*)
		  '(0.0 0.0 0.0 1.0))
		 (t
		  '(1.0 1.0 1.0 1.0)))))
      (with-slots (x0 y0 x1 y1) absolute-rectangle
	(draw-quad x0 y0 
		   x1 y1)))))

#+nil
(defun render-tile (char-code x y background-color foreground-color)
  (color (byte/255 char-code)
	 (byte/255 background-color)
	 (byte/255 foreground-color))
  (vertex
   (floatify x)
   (floatify y)))
#+nil
;;a rainbow
(let ((count 0))
  (dotimes (x 16)
    (dotimes (y 16)
      (render-tile count x y count (- 255 count))
      (incf count))))

;;;more geometry
#+nil
(defun draw-quad (x0 y0 x1 y1)
  (destructuring-bind (r g b a) *pen-color*
    (color r g b a)
    (vertex x0 y0)
    (color r g b a)
    (vertex x0 y1)
    (color r g b a)
    (vertex x1 y1)
    (color r g b a)
    (vertex x1 y0)))
