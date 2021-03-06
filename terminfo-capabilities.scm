;;; -*- Mode: Scheme; scheme48-package: terminfo -*-
;;;

(define *capabilities* (make-hash-table))

;;; see tigetflag, tigetnum, tigetstr
(define (terminal:capability terminal name)
  (let ((capability (hash-table-ref *capabilities* name)))
    (if (or (null? terminal)
            (not (terminal? terminal)))
        (error "Invalid terminfo object"))
    (if (null? capability)
        (error "Capability does not exist:" name))
    (let* ((accessor (car capability))
           (index    (cdr capability))
           (table    (accessor terminal)))
      (if (>= index (vector-length table))
          -1
          (vector-ref table index)))))

(define-syntax capability-available?
  (syntax-rules ()
    ((_ terminal name)
     (let ((value (terminal:capability terminal 'name)))
       (not (and (number? value) (negative? value)))))))

(define (*define-capability name type index)
  (hash-table-set! *capabilities*
                   name
                   (cons type index)))

(define-syntax define-capability
  (syntax-rules ()
    ((_ name type index)
     (begin (*define-capability 'name (capability-type type) index)
            (define name ((capability-accessor type) 'name))))))

(define-syntax capability-type
  (syntax-rules (boolean integer string)
    ((capability-type boolean) terminal:booleans)
    ((capability-type integer) terminal:numbers)
    ((capability-type string)  terminal:strings)))

(define-syntax capability-accessor
  (syntax-rules (boolean integer string)
    ((capability-accessor boolean) boolean-capability-accessor)
    ((capability-accessor integer) integer-capability-accessor)
    ((capability-accessor string)  string-capability-accessor)))

(define (find-terminal arguments)
  (if (and (not (null? arguments))
           (terminal? (last arguments)))
      (values (last arguments)
              (drop-right arguments 1))
      (values *current-terminal* arguments)))

(define (boolean-capability-accessor name)
  (lambda args
    (let-values (((term args) (find-terminal args)))
      (let ((value (terminal:capability term name)))
        (if (and (number? value) (negative? value))
            #f
            value)))))

(define (integer-capability-accessor name)
  (lambda args
    (let-values (((term args) (find-terminal args)))
      (let ((value (terminal:capability term name)))
        (if (and (number? value) (negative? value))
            0
            value)))))

(define (string-capability-accessor name)
  (lambda args
    (let-values (((term args) (find-terminal args)))
      (let ((value (terminal:capability term name)))
        (if (and (number? value) (negative? value))
            #f
            (tparm value args))))))

(define-capability auto-left-margin boolean 0)
(define-capability auto-right-margin boolean 1)
(define-capability no-esc-ctlc boolean 2)
(define-capability ceol-standout-glitch boolean 3)
(define-capability eat-newline-glitch boolean 4)
(define-capability erase-overstrike boolean 5)
(define-capability generic-type boolean 6)
(define-capability hard-copy boolean 7)
(define-capability has-meta-key boolean 8)
(define-capability has-status-line boolean 9)
(define-capability insert-null-glitch boolean 10)
(define-capability memory-above boolean 11)
(define-capability memory-below boolean 12)
(define-capability move-insert-mode boolean 13)
(define-capability move-standout-mode boolean 14)
(define-capability over-strike boolean 15)
(define-capability status-line-esc-ok boolean 16)
(define-capability dest-tabs-magic-smso boolean 17)
(define-capability tilde-glitch boolean 18)
(define-capability transparent-underline boolean 19)
(define-capability xon-xoff boolean 20)
(define-capability needs-xon-xoff boolean 21)
(define-capability prtr-silent boolean 22)
(define-capability hard-cursor boolean 23)
(define-capability non-rev-rmcup boolean 24)
(define-capability no-pad-char boolean 25)
(define-capability non-dest-scroll-region boolean 26)
(define-capability can-change boolean 27)
(define-capability back-color-erase boolean 28)
(define-capability hue-lightness-saturation boolean 29)
(define-capability col-addr-glitch boolean 30)
(define-capability cr-cancels-micro-mode boolean 31)
(define-capability has-print-wheel boolean 32)
(define-capability row-addr-glitch boolean 33)
(define-capability semi-auto-right-margin boolean 34)
(define-capability cpi-changes-res boolean 35)
(define-capability lpi-changes-res boolean 36)
(define-capability backspaces-with-bs boolean 37)
(define-capability crt-no-scrolling boolean 38)
(define-capability no-correctly-working-cr boolean 39)
(define-capability gnu-has-meta-key boolean 40)
(define-capability linefeed-is-newline boolean 41)
(define-capability has-hardware-tabs boolean 42)
(define-capability return-does-clr-eol boolean 43)

(define-capability columns integer 0)
(define-capability init-tabs integer 1)
(define-capability lines integer 2)
(define-capability lines-of-memory integer 3)
(define-capability magic-cookie-glitch integer 4)
(define-capability padding-baud-rate integer 5)
(define-capability virtual-terminal integer 6)
(define-capability width-status-line integer 7)
(define-capability num-labels integer 8)
(define-capability label-height integer 9)
(define-capability label-width integer 10)
(define-capability max-attributes integer 11)
(define-capability maximum-windows integer 12)
(define-capability max-colors integer 13)
(define-capability max-pairs integer 14)
(define-capability no-color-video integer 15)
(define-capability buffer-capacity integer 16)
(define-capability dot-vert-spacing integer 17)
(define-capability dot-horz-spacing integer 18)
(define-capability max-micro-address integer 19)
(define-capability max-micro-jump integer 20)
(define-capability micro-col-size integer 21)
(define-capability micro-line-size integer 22)
(define-capability number-of-pins integer 23)
(define-capability output-res-char integer 24)
(define-capability output-res-line integer 25)
(define-capability output-res-horz-inch integer 26)
(define-capability output-res-vert-inch integer 27)
(define-capability print-rate integer 28)
(define-capability wide-char-size integer 29)
(define-capability buttons integer 30)
(define-capability bit-image-entwining integer 31)
(define-capability bit-image-type integer 32)
(define-capability magic-cookie-glitch-ul integer 33)
(define-capability carriage-return-delay integer 34)
(define-capability new-line-delay integer 35)
(define-capability backspace-delay integer 36)
(define-capability horizontal-tab-delay integer 37)
(define-capability number-of-function-keys integer 38)

(define-capability back-tab string 0)
(define-capability bell string 1)
(define-capability carriage-return string 2)
(define-capability change-scroll-region string 3)
(define-capability clear-all-tabs string 4)
(define-capability clear-screen string 5)
(define-capability clr-eol string 6)
(define-capability clr-eos string 7)
(define-capability column-address string 8)
(define-capability command-character string 9)
(define-capability cursor-address string 10)
(define-capability cursor-down string 11)
(define-capability cursor-home string 12)
(define-capability cursor-invisible string 13)
(define-capability cursor-left string 14)
(define-capability cursor-mem-address string 15)
(define-capability cursor-normal string 16)
(define-capability cursor-right string 17)
(define-capability cursor-to-ll string 18)
(define-capability cursor-up string 19)
(define-capability cursor-visible string 20)
(define-capability delete-character string 21)
(define-capability delete-line string 22)
(define-capability dis-status-line string 23)
(define-capability down-half-line string 24)
(define-capability enter-alt-charset-mode string 25)
(define-capability enter-blink-mode string 26)
(define-capability enter-bold-mode string 27)
(define-capability enter-ca-mode string 28)
(define-capability enter-delete-mode string 29)
(define-capability enter-dim-mode string 30)
(define-capability enter-insert-mode string 31)
(define-capability enter-secure-mode string 32)
(define-capability enter-protected-mode string 33)
(define-capability enter-reverse-mode string 34)
(define-capability enter-standout-mode string 35)
(define-capability enter-underline-mode string 36)
(define-capability erase-chars string 37)
(define-capability exit-alt-charset-mode string 38)
(define-capability exit-attribute-mode string 39)
(define-capability exit-ca-mode string 40)
(define-capability exit-delete-mode string 41)
(define-capability exit-insert-mode string 42)
(define-capability exit-standout-mode string 43)
(define-capability exit-underline-mode string 44)
(define-capability flash-screen string 45)
(define-capability form-feed string 46)
(define-capability from-status-line string 47)
(define-capability init-1string string 48)
(define-capability init-2string string 49)
(define-capability init-3string string 50)
(define-capability init-file string 51)
(define-capability insert-character string 52)
(define-capability insert-line string 53)
(define-capability insert-padding string 54)
(define-capability key-backspace string 55)
(define-capability key-catab string 56)
(define-capability key-clear string 57)
(define-capability key-ctab string 58)
(define-capability key-dc string 59)
(define-capability key-dl string 60)
(define-capability key-down string 61)
(define-capability key-eic string 62)
(define-capability key-eol string 63)
(define-capability key-eos string 64)
(define-capability key-f0 string 65)
(define-capability key-f1 string 66)
(define-capability key-f10 string 67)
(define-capability key-f2 string 68)
(define-capability key-f3 string 69)
(define-capability key-f4 string 70)
(define-capability key-f5 string 71)
(define-capability key-f6 string 72)
(define-capability key-f7 string 73)
(define-capability key-f8 string 74)
(define-capability key-f9 string 75)
(define-capability key-home string 76)
(define-capability key-ic string 77)
(define-capability key-il string 78)
(define-capability key-left string 79)
(define-capability key-ll string 80)
(define-capability key-npage string 81)
(define-capability key-ppage string 82)
(define-capability key-right string 83)
(define-capability key-sf string 84)
(define-capability key-sr string 85)
(define-capability key-stab string 86)
(define-capability key-up string 87)
(define-capability keypad-local string 88)
(define-capability keypad-xmit string 89)
(define-capability lab-f0 string 90)
(define-capability lab-f1 string 91)
(define-capability lab-f10 string 92)
(define-capability lab-f2 string 93)
(define-capability lab-f3 string 94)
(define-capability lab-f4 string 95)
(define-capability lab-f5 string 96)
(define-capability lab-f6 string 97)
(define-capability lab-f7 string 98)
(define-capability lab-f8 string 99)
(define-capability lab-f9 string 100)
(define-capability meta-off string 101)
(define-capability meta-on string 102)
(define-capability new-line string 103)
(define-capability pad-char string 104)
(define-capability parm-dch string 105)
(define-capability parm-delete-line string 106)
(define-capability parm-down-cursor string 107)
(define-capability parm-ich string 108)
(define-capability parm-index string 109)
(define-capability parm-insert-line string 110)
(define-capability parm-left-cursor string 111)
(define-capability parm-right-cursor string 112)
(define-capability parm-rindex string 113)
(define-capability parm-up-cursor string 114)
(define-capability pkey-key string 115)
(define-capability pkey-local string 116)
(define-capability pkey-xmit string 117)
(define-capability print-screen string 118)
(define-capability prtr-off string 119)
(define-capability prtr-on string 120)
(define-capability repeat-char string 121)
(define-capability reset-1string string 122)
(define-capability reset-2string string 123)
(define-capability reset-3string string 124)
(define-capability reset-file string 125)
(define-capability restore-cursor string 126)
(define-capability row-address string 127)
(define-capability save-cursor string 128)
(define-capability scroll-forward string 129)
(define-capability scroll-reverse string 130)
(define-capability set-attributes string 131)
(define-capability set-tab string 132)
(define-capability set-window string 133)
(define-capability tab string 134)
(define-capability to-status-line string 135)
(define-capability underline-char string 136)
(define-capability up-half-line string 137)
(define-capability init-prog string 138)
(define-capability key-a1 string 139)
(define-capability key-a3 string 140)
(define-capability key-b2 string 141)
(define-capability key-c1 string 142)
(define-capability key-c3 string 143)
(define-capability prtr-non string 144)
(define-capability char-padding string 145)
(define-capability acs-chars string 146)
(define-capability plab-norm string 147)
(define-capability key-btab string 148)
(define-capability enter-xon-mode string 149)
(define-capability exit-xon-mode string 150)
(define-capability enter-am-mode string 151)
(define-capability exit-am-mode string 152)
(define-capability xon-character string 153)
(define-capability xoff-character string 154)
(define-capability ena-acs string 155)
(define-capability label-on string 156)
(define-capability label-off string 157)
(define-capability key-beg string 158)
(define-capability key-cancel string 159)
(define-capability key-close string 160)
(define-capability key-command string 161)
(define-capability key-copy string 162)
(define-capability key-create string 163)
(define-capability key-end string 164)
(define-capability key-enter string 165)
(define-capability key-exit string 166)
(define-capability key-find string 167)
(define-capability key-help string 168)
(define-capability key-mark string 169)
(define-capability key-message string 170)
(define-capability key-move string 171)
(define-capability key-next string 172)
(define-capability key-open string 173)
(define-capability key-options string 174)
(define-capability key-previous string 175)
(define-capability key-print string 176)
(define-capability key-redo string 177)
(define-capability key-reference string 178)
(define-capability key-refresh string 179)
(define-capability key-replace string 180)
(define-capability key-restart string 181)
(define-capability key-resume string 182)
(define-capability key-save string 183)
(define-capability key-suspend string 184)
(define-capability key-undo string 185)
(define-capability key-sbeg string 186)
(define-capability key-scancel string 187)
(define-capability key-scommand string 188)
(define-capability key-scopy string 189)
(define-capability key-screate string 190)
(define-capability key-sdc string 191)
(define-capability key-sdl string 192)
(define-capability key-select string 193)
(define-capability key-send string 194)
(define-capability key-seol string 195)
(define-capability key-sexit string 196)
(define-capability key-sfind string 197)
(define-capability key-shelp string 198)
(define-capability key-shome string 199)
(define-capability key-sic string 200)
(define-capability key-sleft string 201)
(define-capability key-smessage string 202)
(define-capability key-smove string 203)
(define-capability key-snext string 204)
(define-capability key-soptions string 205)
(define-capability key-sprevious string 206)
(define-capability key-sprint string 207)
(define-capability key-sredo string 208)
(define-capability key-sreplace string 209)
(define-capability key-sright string 210)
(define-capability key-srsume string 211)
(define-capability key-ssave string 212)
(define-capability key-ssuspend string 213)
(define-capability key-sundo string 214)
(define-capability req-for-input string 215)
(define-capability key-f11 string 216)
(define-capability key-f12 string 217)
(define-capability key-f13 string 218)
(define-capability key-f14 string 219)
(define-capability key-f15 string 220)
(define-capability key-f16 string 221)
(define-capability key-f17 string 222)
(define-capability key-f18 string 223)
(define-capability key-f19 string 224)
(define-capability key-f20 string 225)
(define-capability key-f21 string 226)
(define-capability key-f22 string 227)
(define-capability key-f23 string 228)
(define-capability key-f24 string 229)
(define-capability key-f25 string 230)
(define-capability key-f26 string 231)
(define-capability key-f27 string 232)
(define-capability key-f28 string 233)
(define-capability key-f29 string 234)
(define-capability key-f30 string 235)
(define-capability key-f31 string 236)
(define-capability key-f32 string 237)
(define-capability key-f33 string 238)
(define-capability key-f34 string 239)
(define-capability key-f35 string 240)
(define-capability key-f36 string 241)
(define-capability key-f37 string 242)
(define-capability key-f38 string 243)
(define-capability key-f39 string 244)
(define-capability key-f40 string 245)
(define-capability key-f41 string 246)
(define-capability key-f42 string 247)
(define-capability key-f43 string 248)
(define-capability key-f44 string 249)
(define-capability key-f45 string 250)
(define-capability key-f46 string 251)
(define-capability key-f47 string 252)
(define-capability key-f48 string 253)
(define-capability key-f49 string 254)
(define-capability key-f50 string 255)
(define-capability key-f51 string 256)
(define-capability key-f52 string 257)
(define-capability key-f53 string 258)
(define-capability key-f54 string 259)
(define-capability key-f55 string 260)
(define-capability key-f56 string 261)
(define-capability key-f57 string 262)
(define-capability key-f58 string 263)
(define-capability key-f59 string 264)
(define-capability key-f60 string 265)
(define-capability key-f61 string 266)
(define-capability key-f62 string 267)
(define-capability key-f63 string 268)
(define-capability clr-bol string 269)
(define-capability clear-margins string 270)
(define-capability set-left-margin string 271)
(define-capability set-right-margin string 272)
(define-capability label-format string 273)
(define-capability set-clock string 274)
(define-capability display-clock string 275)
(define-capability remove-clock string 276)
(define-capability create-window string 277)
(define-capability goto-window string 278)
(define-capability hangup string 279)
(define-capability dial-phone string 280)
(define-capability quick-dial string 281)
(define-capability tone string 282)
(define-capability pulse string 283)
(define-capability flash-hook string 284)
(define-capability fixed-pause string 285)
(define-capability wait-tone string 286)
(define-capability user0 string 287)
(define-capability user1 string 288)
(define-capability user2 string 289)
(define-capability user3 string 290)
(define-capability user4 string 291)
(define-capability user5 string 292)
(define-capability user6 string 293)
(define-capability user7 string 294)
(define-capability user8 string 295)
(define-capability user9 string 296)
(define-capability orig-pair string 297)
(define-capability orig-colors string 298)
(define-capability initialize-color string 299)
(define-capability initialize-pair string 300)
(define-capability set-color-pair string 301)
(define-capability set-foreground string 302)
(define-capability set-background string 303)
(define-capability change-char-pitch string 304)
(define-capability change-line-pitch string 305)
(define-capability change-res-horz string 306)
(define-capability change-res-vert string 307)
(define-capability define-char string 308)
(define-capability enter-doublewide-mode string 309)
(define-capability enter-draft-quality string 310)
(define-capability enter-italics-mode string 311)
(define-capability enter-leftward-mode string 312)
(define-capability enter-micro-mode string 313)
(define-capability enter-near-letter-quality string 314)
(define-capability enter-normal-quality string 315)
(define-capability enter-shadow-mode string 316)
(define-capability enter-subscript-mode string 317)
(define-capability enter-superscript-mode string 318)
(define-capability enter-upward-mode string 319)
(define-capability exit-doublewide-mode string 320)
(define-capability exit-italics-mode string 321)
(define-capability exit-leftward-mode string 322)
(define-capability exit-micro-mode string 323)
(define-capability exit-shadow-mode string 324)
(define-capability exit-subscript-mode string 325)
(define-capability exit-superscript-mode string 326)
(define-capability exit-upward-mode string 327)
(define-capability micro-column-address string 328)
(define-capability micro-down string 329)
(define-capability micro-left string 330)
(define-capability micro-right string 331)
(define-capability micro-row-address string 332)
(define-capability micro-up string 333)
(define-capability order-of-pins string 334)
(define-capability parm-down-micro string 335)
(define-capability parm-left-micro string 336)
(define-capability parm-right-micro string 337)
(define-capability parm-up-micro string 338)
(define-capability select-char-set string 339)
(define-capability set-bottom-margin string 340)
(define-capability set-bottom-margin-parm string 341)
(define-capability set-left-margin-parm string 342)
(define-capability set-right-margin-parm string 343)
(define-capability set-top-margin string 344)
(define-capability set-top-margin-parm string 345)
(define-capability start-bit-image string 346)
(define-capability start-char-set-def string 347)
(define-capability stop-bit-image string 348)
(define-capability stop-char-set-def string 349)
(define-capability subscript-characters string 350)
(define-capability superscript-characters string 351)
(define-capability these-cause-cr string 352)
(define-capability zero-motion string 353)
(define-capability char-set-names string 354)
(define-capability key-mouse string 355)
(define-capability mouse-info string 356)
(define-capability req-mouse-pos string 357)
(define-capability get-mouse string 358)
(define-capability set-a-foreground string 359)
(define-capability set-a-background string 360)
(define-capability pkey-plab string 361)
(define-capability device-type string 362)
(define-capability code-set-init string 363)
(define-capability set0-des-seq string 364)
(define-capability set1-des-seq string 365)
(define-capability set2-des-seq string 366)
(define-capability set3-des-seq string 367)
(define-capability set-lr-margin string 368)
(define-capability set-tb-margin string 369)
(define-capability bit-image-repeat string 370)
(define-capability bit-image-newline string 371)
(define-capability bit-image-carriage-return string 372)
(define-capability color-names string 373)
(define-capability define-bit-image-region string 374)
(define-capability end-bit-image-region string 375)
(define-capability set-color-band string 376)
(define-capability set-page-length string 377)
(define-capability display-pc-char string 378)
(define-capability enter-pc-charset-mode string 379)
(define-capability exit-pc-charset-mode string 380)
(define-capability enter-scancode-mode string 381)
(define-capability exit-scancode-mode string 382)
(define-capability pc-term-options string 383)
(define-capability scancode-escape string 384)
(define-capability alt-scancode-esc string 385)
(define-capability enter-horizontal-hl-mode string 386)
(define-capability enter-left-hl-mode string 387)
(define-capability enter-low-hl-mode string 388)
(define-capability enter-right-hl-mode string 389)
(define-capability enter-top-hl-mode string 390)
(define-capability enter-vertical-hl-mode string 391)
(define-capability set-a-attributes string 392)
(define-capability set-pglen-inch string 393)
(define-capability termcap-init2 string 394)
(define-capability termcap-reset string 395)
(define-capability linefeed-if-not-lf string 396)
(define-capability backspace-if-not-bs string 397)
(define-capability other-non-function-keys string 398)
(define-capability arrow-key-map string 399)
(define-capability acs-ulcorner string 400)
(define-capability acs-llcorner string 401)
(define-capability acs-urcorner string 402)
(define-capability acs-lrcorner string 403)
(define-capability acs-ltee string 404)
(define-capability acs-rtee string 405)
(define-capability acs-btee string 406)
(define-capability acs-ttee string 407)
(define-capability acs-hline string 408)
(define-capability acs-vline string 409)
(define-capability acs-plus string 410)
(define-capability memory-lock string 411)
(define-capability memory-unlock string 412)
(define-capability box-chars-1 string 413)