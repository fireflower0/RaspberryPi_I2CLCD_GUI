;; Load packages
(load "packages.lisp" :external-format :utf-8)

(in-package :cl-cffi)

;; Load wrapper API
(load "libwiringPi.lisp" :external-format :utf-8)

;; I2C device address (0x3e)
(defconstant +i2c-addr+ #X3E)

;; LCD contrast (0x00-0x0F)
(defconstant +contrast+ #X0A)

;; LCD column (16)
(defconstant +column+ 16)

(defun i2c-lcd ()
  (setq fd (wiringPiI2CSetup +i2c-addr+))

  (setq fcnt (logior (logand +contrast+ #X0F) #X70))
  
  (wiringPiI2CWriteReg8 fd #X00 #X38) ; Function set : 8bit, 2 line
  (wiringPiI2CWriteReg8 fd #X00 #X39) ; Function set : 8bit, 2 line, IS=1
  (wiringPiI2CWriteReg8 fd #X00 #X14) ; Internal OSC freq
  (wiringPiI2CWriteReg8 fd #X00 fcnt) ; Contrast set
  (wiringPiI2CWriteReg8 fd #X00 #X5F) ; Power/ICON/Constract
  (wiringPiI2CWriteReg8 fd #X00 #X6A) ; Follower control
  (delay 300)                         ; Wait time (300 ms)
  (wiringPiI2CWriteReg8 fd #X00 #X38) ; Function set : 8 bit, 2 line, IS=0
  (wiringPiI2CWriteReg8 fd #X00 #X06) ; Entry mode set
  (wiringPiI2CWriteReg8 fd #X00 #X0C) ; Display on/off
  (wiringPiI2CWriteReg8 fd #X00 #X01) ; Clear display
  (delay 30)                          ; Wait time (0.3 ms)
  (wiringPiI2CWriteReg8 fd #X00 #X02) ; Return home
  (delay 30)                          ; Wait time (0.3 ms)

  (with-ltk ()
    (wm-title *tk* "Entry")
    (bind *tk* "<Alt-q>" (lambda (event)
                           (setq *exit-mainloop* t)))
    (let ((lbl1 (make-instance 'label :text "First line" :width 60))
          (entry1 (make-instance 'entry))
          (btn1 (make-instance 'button :text "Button1"))
          (lbl2 (make-instance 'label :text "Second line" :width 60))
          (entry2 (make-instance 'entry))
          (btn2 (make-instance 'button :text "Button2")))
      (setf (command btn1) (lambda ()
			     ;; Set cursor first line
			     (wiringPiI2CWriteReg8 fd #X00 #X80)
			     ;; Clear first line
			     (dotimes (count +column+)
			       (wiringPiI2CWriteReg8 fd #X40 #X20))
			     ;; Reset cursor first line
			     (wiringPiI2CWriteReg8 fd #X00 #X80)
			     ;; Display string
			     (loop :for char :across (text entry1)
				   :do (wiringPiI2CWriteReg8 fd #X40 (char-code char)))))
      (setf (command btn2) (lambda ()
			     ;; Set cursor first line
			     (wiringPiI2CWriteReg8 fd #X00 #XC0)
			     ;; Clear first line
			     (dotimes (count +column+)
			       (wiringPiI2CWriteReg8 fd #X40 #X20))
			     ;; Reset cursor first line
			     (wiringPiI2CWriteReg8 fd #X00 #XC0)
			     ;; Display string
			     (loop :for char :across (text entry2)
				   :do (wiringPiI2CWriteReg8 fd #X40 (char-code char)))))
      (focus entry1)
      (pack (list lbl1 entry1 btn1 lbl2 entry2 btn2) :fill :x))))

;; Execution
(i2c-lcd)
