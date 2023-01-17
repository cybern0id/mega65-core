  ;; -------------------------------------------------------------------
  ;;   MEGA65 "HYPPOBOOT" Combined boot and hypervisor ROM.
  ;;   Paul Gardner-Stephen, 2014-2019.
  ;;   -------------------------------------------------------------------
  ;;   Purpose:
  ;;   1. Verify checksum of ROM area of slow RAM.
  ;;   2. If checksum fails, load complete ROM from SD card.
  ;;   3. Select default disk image for F011 emulation.

  ;;   The hyppo ROM is 16KB in length, and maps at $8000-$BFFF
  ;;   in hypervisor mode.

  ;;   Hyppo modifies RAM from $0000-$07FFF (ZP, stack, 40-column
  ;;   screen, 16-bit text mode) during normal boot.

  ;;   BG: is the below true still, I dont think so.
  ;;   If Hyppo needs to load the ROM from SD card, then it may
  ;;   modify the first 64KB of fast ram.

  ;;   We will use the convention of C=0 means failure, ie CLC/RTS,
  ;;                             and C=1 means success, ie SEC/RTS.


  ;;   This included file defines many of the alias used throughout
  ;;   it also suggests some memory-map definitions
  ;;   ----------------------------------------------------------------

!src "constants.asm"
!src "macros.asm"
!src "machine.asm"

!addr TrapEntryPoints_Start        = $8000
!addr RelocatedCPUVectors_Start    = $81f8
!addr Traps_Start                  = $8200
!addr DOSDiskTable_Start           = $bb00
!addr SysPartStructure_Start       = $bbc0
!addr DOSWorkArea_Start            = $bc00
!addr ProcessDescriptors_Start     = $bd00
!addr HyppoStack_Start             = $be00
!addr HyppoZP_Start                = $bf00
!addr Hyppo_End                    = $bfff

;; .file [name="../../bin/HICKUP.M65", type="bin", segments="TrapEntryPoints,RelocatedCPUVectors,Traps,DOSDiskTable,SysPartStructure,DOSWorkArea,ProcessDescriptors,HyppoStack,HyppoZP"]
	!to "bin/BRICKUP.M65", plain

;; .segmentdef TrapEntryPoints        [min=TrapEntryPoints_Start,     max=RelocatedCPUVectors_Start-1                         ]
;; .segmentdef RelocatedCPUVectors    [min=RelocatedCPUVectors_Start, max=Traps_Start-1                                       ]
;; .segmentdef Traps                  [min=Traps_Start,               max=DOSDiskTable_Start-1                                ]
;; .segmentdef DOSDiskTable           [min=DOSDiskTable_Start,        max=SysPartStructure_Start-1,                           ]
;; .segmentdef SysPartStructure       [min=SysPartStructure_Start,    max=DOSWorkArea_Start-1                                 ]
;; .segmentdef DOSWorkArea            [min=DOSWorkArea_Start,         max=ProcessDescriptors_Start-1                          ]
;; .segmentdef ProcessDescriptors     [min=ProcessDescriptors_Start,  max=HyppoStack_Start-1                                  ]
;; .segmentdef HyppoStack             [min=HyppoStack_Start,          max=HyppoZP_Start-1,            fill, fillByte=$3e      ]
;; .segmentdef HyppoZP                [min=HyppoZP_Start,             max=Hyppo_End,                  fill, fillByte=$3f      ]
;; .segmentdef Data                   [min=Data_Start,                max=$ffff                                               ]

;;         .segment TrapEntryPoints
        * = TrapEntryPoints_Start

;; /*  -------------------------------------------------------------------
;;     CPU Hypervisor Trap entry points.
;;     64 x 4 byte entries for user-land traps.
;;     some more x 4 byte entries for system traps (reset, page fault etc)
;;     ---------------------------------------------------------------- */

trap_entry_points:

        ;; Traps $00-$07 (user callable)
        ;;
        jmp dos_and_process_trap                ;; Trap #$00 (unsure what to call it)
        eom                                     ;; refer: hyppo_dos.asm
        jmp memory_trap                         ;; Trap #$01
        eom                                     ;; refer: hyppo_mem.asm
        jmp syspart_trap                        ;; Trap #$02
        eom                                     ;; refer: hyppo_syspart.asm
        jmp serialwrite                         ;; Trap #$03
        eom                                     ;; refer serialwrite in this file
        jmp emulatortrap                        ;; Trap #$04
        eom                                     ;; Reserved for Xemu to use
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom

        ;; Traps $08-$0F (user callable)
        ;;
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom

        ;; Traps $10-$17 (user callable)
        ;;
        jmp nosuchtrap
        eom
        jmp securemode_trap
        eom
        jmp leave_securemode_trap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom

        ;; Traps $18-$1F (user callable)
        ;;
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom

        ;; Traps $20-$27 (user callable)
        ;;
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom

        ;; Traps $28-$2F (user callable)
        ;;
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom

        ;; Traps $30-$37
        ;;
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom

        jmp protected_hardware_config           ;; Trap #$32 (Protected Hardware Configuration)
        eom                                     ;; refer: hyppo_task


        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom

        ;; Traps $38-$3F (user callable)
        ;;
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
	;; Writing to $D67F shall trap to freezer, as though user had triggered it.
        jmp restore_press_trap
        eom

        ;; Traps $40-$4F (reset, page fault and other system-generated traps)
        jmp reset_entry                         ;; Trap #$40 (power on / reset)
        eom                                     ;; refer: below in this file

        jmp page_fault                          ;; Trap #$41 (page fault)
        eom                                     ;; refer: hyppo_mem

        jmp restore_press_trap                  ;; Trap #$42 (press RESTORE for 0.5 - 1.99 seconds)
        eom                                     ;; refer: hyppo_task "1000010" x"42"

        jmp matrix_mode_toggle                  ;; Trap #$43 (C= + TAB combination)
        eom                                     ;; refer: hyppo_task

        jmp f011_virtual_read                   ;; Trap #$44 (virtualised F011 sector read)
        eom

        jmp f011_virtual_write                  ;; Trap #$45 (virtualised F011 sector write)
        eom

        jmp unstable_illegal_opcode_trap        ;; Trap #$46 (6502 unstable illegal opcode)
        eom
        jmp kill_opcode_trap                    ;; Trap #$47 (6502 KIL instruction)
        eom	
        jmp ethernet_remote_trap                ;; Trap #$48 (Ethernet remote control trap) 
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom
        jmp nosuchtrap
        eom

        ;; Leave room for relocated cpu vectors below
        ;;
        ;; .segment RelocatedCPUVectors
        * = RelocatedCPUVectors_Start

        ;; Then we have relocated CPU vectors at $81F8-$81FF
        ;; (which are 2-byte vectors for interrupts, not 4-byte
        ;; trap addresses).
        ;; These are used to catch interrupts in hypervisor mode
        ;; (although the need for them may have since been removed)
        !16 reset_entry    ;; unused vector
        !16 hypervisor_nmi ;; NMI
        !16 reset_entry    ;; RESET
        !16 hypervisor_irq ;; IRQ


        ;; .segment Traps
        * = Traps_Start

;; /*  -------------------------------------------------------------------
;;     Hypervisor traps
;;     ---------------------------------------------------------------- */

;; /*  -------------------------------------------------------------------
;;     Illegal trap / trap sub-function handlers

;;     Traps are triggered by writing to $D640-$D67F
;;     and trap to $8000+((address & $3F)*4) in the hypervisor

;;     Routine for unimplemented/reserved traps
;;     (Consider replacing with trap to hypervisor error screen with option
;;     to return?)
;;     ---------------------------------------------------------------- */
emulatortrap:
	;; FALL-THROUGH -- return failure on real hardware
	;; Xemu will intercept it itself
nosuchtrap:

        ;; Clear C flag for caller to indicate failure
        ;;
        lda hypervisor_flags
        and #$FE   ;; C flag is bit 0
        sta hypervisor_flags

        ;; set A to $FF
        ;;
        lda #$ff
        sta hypervisor_a

        ;; return from hypervisor
        ;;
        sta hypervisor_enterexit_trigger

;;         ========================

return_from_trap_with_success_and_file_descriptor_in_a:

        lda dos_current_file_descriptor
        sta hypervisor_a
        ;; FALL THROUGH to return_from_trap_with_success

;;         ========================

return_from_trap_with_success:

        ;; Return from trap with C flag clear to indicate success

        jsr sd_unmap_sectorbuffer

        ;; set C flag for caller to indicate success
        ;;
        lda hypervisor_flags
        ora #$01   ;; C flag is bit 0
        sta hypervisor_flags

        +Checkpoint "return_from_trap_with_success"

	;; DO NOT Clear A on return
        ;; (else traps can't return anything in A register)

        ;; return from hypervisor
        sta hypervisor_enterexit_trigger

;;         ========================

return_from_trap_with_failure:

        jsr sd_unmap_sectorbuffer

        ;; report error in A
        ;;
        sta hypervisor_a
        lda hypervisor_flags
        and #$fe   ;; C flag is bit 0 (ie clear bit-0)
        sta hypervisor_flags

        +Checkpoint "return_from_trap_with_failure"

        ;; return from hypervisor
        sta hypervisor_enterexit_trigger

;;         ========================

invalid_subfunction:

        jmp nosuchtrap

;;         ========================

;; /*  -------------------------------------------------------------------
;;     System Partition functions
;;     ---------------------------------------------------------------- */

!src "syspart.asm"

;; /*  -------------------------------------------------------------------
;;     Freeze/Unfreeze functions
;;     ---------------------------------------------------------------- */
!src "freeze.asm"

;; /*  -------------------------------------------------------------------
;;     DOS, process control and related functions trap
;;     ---------------------------------------------------------------- */
!src "dos.asm"
!src "dos_write.asm"

;; /*  -------------------------------------------------------------------
;;     Virtual memory and memory management
;;     ---------------------------------------------------------------- */
!src "mem.asm"

;; /*  -------------------------------------------------------------------
;;     Task (process) management
;;     ---------------------------------------------------------------- */
!src "task.asm"

;; /*  -------------------------------------------------------------------
;;     Secure mode / compartmentalised operation management
;;     ---------------------------------------------------------------- */
!src "securemode.asm"

;; /*  -------------------------------------------------------------------
;;     SD-Card and FAT related functions
;;     ---------------------------------------------------------------- */
!src "sdfat.asm"

;; /*  -------------------------------------------------------------------
;;     Virtualised F011 access (used for disk over serial monitor)
;;     ---------------------------------------------------------------- */
!src "virtual_f011.asm"

;; /*  -------------------------------------------------------------------
;;     Audio mixer control functions
;;     ---------------------------------------------------------------- */
!src "audiomix.asm"

;; /*  -------------------------------------------------------------------
;;     Target-specific register setup
;;     ---------------------------------------------------------------- */
!src "targetsetup.asm"

;; /*  -------------------------------------------------------------------
;;     CPU Hypervisor Entry Point on reset
;;     ---------------------------------------------------------------- */

reset_machine_state:
        ;; get CPU state sensible
        sei
        cld
        see

        ;; ;; Disable reset watchdog (this happens simply by writing anything to
        ;; ;; this register)
        ;; ;; Enable /EXROM and /GAME from cartridge port (bit 0)
        ;; ;; enable flat 32-bit addressing (bit 1)
        ;; ;; do not engage ROM write protect (yet) (bit 2)
        ;; ;; do make ASC/DIN / CAPS LOCK control CPU speed (bit 3)
        ;; ;; do not force CPU to full speed (bit 4)
        ;; ;; also force 4502 CPU personality (6502 personality is still incomplete) (bit 5)
        ;; ;; and clear any pending IRQ or NMI event (bit 6)
        ;; ;;
        ;; ;; (The watchdog was added to catch reset problems where the machine
        ;; ;; would run off somewhere odd instead of resetting properly. Now it
        ;; ;; will auto-reset after 65535 cycles if the watchdog is not cleared).
        ;; ;;

        lda #$6b    ;; 01101011
        sta hypervisor_feature_enables

	;; Reset ethernet to clear any queued packets from before reset
	;; and ack 1 packet to get the controller into the right state
	lda #$00
	sta $d6e0
	lda #$03
	sta $d6e0
	sta $d6e1
	lda #$00
	sta $d6e1
	
	
	;; Enable cartridge /EXROM and /GAME lines in CPU addressing
	lda #$02
	tsb $d7fb

	;; /EXROM and /GAME follow cartridge port
        lda #$3f
        sta $d7fd

        jsr audiomix_setup
        ;; enable audio amplifier
        lda #$01
        sta audioamp_ctl

        ;; Return keyboard LEDs to automatic control
	lda #$00
	sta $d61d
	;; Disable VIC-IV debug modes
	sta $d066
        ;; Clear system partition present flag
        sta syspart_present
        ;; disable IRQ/NMI sources
        sta $D01A
        lda #$7f
	sta $d07f   		; Hide VIC-IV cross-hairs
        sta $DC0D
        sta $DD0D

        ;; clear UART interrupt status
        lda uart65_irq_flag

        ;; switch to fast mode
        ;; 1. C65 fast-mode enable, and disable extended attributes
	lda #$40
        sta $d031
        ;; 2. MEGA65 48MHz enable (requires C65 or C128 fast mode to truly enable, hence the above)
        lda #$c5
        tsb $d054

        ;; Setup I2C peripherals on the MEGAphone platform
        jsr targetspecific_setup

        ;; sprites off, and normal mode, 256-colour char data from chipram
        lda #$00
        sta $d015
	sta $d063
        sta $d055
        sta $d06b
        sta $d057
        lda #$f0
	tax
	trb $d049
	txa
	trb $d04b
	txa
	trb $d04d
	txa
	trb $d04f

        ;; We DO NOT need to mess with $01, because
        ;; the 4510 starts up with hyppo mapped at $8000-$BFFF
        ;; enhanced ($FFD3xxx) IO page mapped at $D000,
        ;; and fast RAM elsewhere.

        ;; Map SD card sector buffer to SD card, not floppy drive
        lda #$80
        sta sd_buffer_ctrl

        ;; Access cartridge IO area to force EXROM probe on R1 PCBs
        ;; XXX DONT READ $DExx ! This is a known crash causer for Action Replay
        ;; cartridges.  $DF00 should be okay, however.
        ;; XXX $DFxx can also be a problem for other cartridges, so we shouldn't do either.
        ;; this will mean cartridges don't work on the R1 PCB, but as that is no longer being
        ;; developed for, we can just ignore that now, and not touch anything.
        ;;lda $df00

        jsr resetdisplay
        jsr erasescreen
        jsr resetpalette

        ;; note that this first message does not get displayed correctly
        +Checkpoint "reset_machine_state"
        ;; but this second message does
        +Checkpoint "reset_machine_state"

        rts

;; /*  -------------------------------------------------------------------
;;     CPU Hypervisor reset/trap routines
;;     ---------------------------------------------------------------- */
reset_entry:
        sei

 	;; Put ZP and stack back where they belong
	lda #$bf
	tab
	ldy #$be
	tys
	ldx #$ff
	txs

	;; Clear mapping of lower memory area
	ldx #$00
	lda #$00
	ldy #$00
	ldz #$3f
	map
	eom

        jsr reset_machine_state

	;; If banner is in flash, load it _immediately_
	jsr tryloadbootlogofromflash

        ;; display welcome screen
        ;;
        ldx #<msg_hyppo
        ldy #>msg_hyppo
        jsr printmessage

        ;; leave a blank line below hyppo banner
        ;;
        ldx #<msg_blankline
        ldy #>msg_blankline
        jsr printmessage

        ;; Display GIT commit
        ;;
        ldx #<msg_gitcommit
        ldy #>msg_gitcommit
        jsr printmessage

	jsr resetdisplay

        ;; Try to read the MBR from the SD card to ensure SD card is happy
        ;;
        ldx #<msg_tryingsdcard
        ldy #>msg_tryingsdcard
        jsr printmessage

        ;; Work out if we are using primary or secondard SD card

        ;; First try resetting card 1 (external)
	;; so that if you have an external card, it will be used in preference
        lda #$c1
        sta $d680
        lda #$00
        sta $d680
        lda #$01
        sta $d680

        ldx #$03
morewaiting:
        jsr sdwaitawhile

        lda $d680
        and #$03
        bne trybus0

        phx

        ldx #<msg_usingcard1
        ldy #>msg_usingcard1
        jsr printmessage

        plx

        jmp tryreadmbr
trybus0:
        dex
        bne morewaiting

        lda #$c0
        sta $d680

        ldx #<msg_tryingcard0
        ldy #>msg_tryingcard0
        jsr printmessage

        ;; Try resetting card 0
        lda #$00
        sta $d680
        lda #$01
        sta $d680

        jsr sdwaitawhile

        lda $d680
        and #$03
        beq tryreadmbr

        ;; No working SD card -- This is a fatal error for this mode of operation,
	;; as the whole point is we need to load and start JOYFLASH.M65

        ldx #<msg_nosdcard
        ldy #>msg_nosdcard
        jsr printmessage
nosd:	inc $d020
	jmp nosd

tryreadmbr:
        jsr readmbr
        bcs gotmbr


        ;; Oops, cant read MBR
        ;; display debug message to screen
        ;;
        ldx #<msg_retryreadmbr
        ldy #>msg_retryreadmbr
        jsr printmessage

        ;; put sd card sector buffer back after scanning
        ;; keyboard
        lda #$81
        tsb sd_ctrl

        ;; display debug message to uart
        ;;
        +Checkpoint "re-try reading MBR of sdcard"

        jmp tryreadmbr

;;         ========================

gotmbr:
        ;; good, was able to read the MBR

        ;; Scan SD card for partitions and mount them.
        ;;
        jsr dos_clearall
        jsr dos_read_partitiontable

        ;; then print out some useful information
        ;;
        ldx #<msg_diskcount
        ldy #>msg_diskcount
        jsr printmessage
        ;;
        ldy #$00
        ldz dos_disk_count
        jsr printhex
        ;;
        ldy #$00
        ldz dos_default_disk
        jsr printhex

        ;; Go to root directory on default disk
        jsr cdroot_and_complain_if_fails

loadbannerfromsd:
        ;; Load and display boot logo

	jsr setup_banner_load_pointer

        ldx #<txt_JOYFLASHM65
        ldy #>txt_JOYFLASHM65
        jsr dos_setname

	lda #<$07FF
        sta <dos_file_loadaddress
	lda #>$07FF
        sta <(dos_file_loadaddress+1)
	lda #$00
        sta <(dos_file_loadaddress+2)
        sta <(dos_file_loadaddress+3)
	
        ;; print debug message
        ;;
        +Checkpoint "  try-loading JOYFLASH.M65"

        jsr dos_readfileintomemory
        bcs joyflashok
	
;;         ========================

        ;; FAILED: print debug message
        ;;
        +Checkpoint "  FAILED-loading JOYFLASH"

        ;; print debug message
        ;;
        ldx #<msg_nojoyflash
        ldy #>msg_nojoyflash
        jsr printmessage
        ldy #$00
        ldz dos_error_code
        jsr printhex

nojoy:	inc $d020
	jmp nojoy
	
        +Checkpoint "FAILED loading BOOTLOGO"

;;         ========================

joyflashok:
	jmp run_util_in_hypervisor_context

;;         ========================

cdroot_and_complain_if_fails:

        ldx dos_default_disk
        jsr dos_cdroot
        bcs @cdroot_ok

        ;; failed
        ;;
        ldx #<msg_cdrootfailed
        ldy #>msg_cdrootfailed
        jsr printmessage
        ldy #$00
        ldz dos_error_code
        jsr printhex
        clc
        rts

        +Checkpoint "FAILED CDROOT"
@cdroot_ok:
        sec
        rts

fileopenerror:
        ldx #<msg_fileopenerror
        ldy #>msg_fileopenerror
        jsr printmessage

sdcarderror:
        ldx #<msg_sdcarderror
        ldy #>msg_sdcarderror
        jsr printmessage

        jsr sdwaitawhile
        jmp reset_entry

;;         ========================

badfs:
        ldx #<msg_badformat
        ldy #>msg_badformat
        jsr printmessage

        jsr sdwaitawhile
        jmp reset_entry

;; /*  -------------------------------------------------------------------
;;     Display and basic IO routines
;;     ---------------------------------------------------------------- */

resetdisplay:
        ;; reset screen
        ;;
        lda #$40        ;; 0100 0000 = choose charset
        sta $d030        ;; VIC-III Control Register A

        lda $d031        ;; VIC-III Control Register B
        and #$40        ;; bit-6 is 4mhz
        sta $d031

        lda #$00        ;; black
        sta $D020       ;; border
        sta $D021       ;; background
	sta $D711 	;; Disable DMA audio

        ;; Start in 60Hz mode, since most monitors support it
        ;; (Also required to make sure matrix mode pixels aren't ragged on first boot).
	;; The label here is used so that the syspartition settings can be used to
	;; change the default video mode on reset.
pal_ntsc_minus_1:
        lda #$80
        sta $d06f

        ;; disable test pattern and various other strange video things that might be hanging around
        lda #$80
        trb $d066
        lda #$00
        sta $d06a ;; bank# for screen address
        sta $d06b ;; 16-colour sprites
        sta $d078 ;; sprite Y super MSBs
        sta $d05f ;; sprite X super MSBs
        lda #$78
        sta $d05a ;; correct horizontal scaling
        lda #$C0
        sta $D05D ;; enable hot registers, raster delay
        lda #80
        sta $D05C ;; Side border width LSB

        ;; point VIC-IV to bottom 16KB of display memory
        ;;
        lda #$ff
        sta $DD01
        sta $DD00

        ;; We use VIC-II style registers as this resets video frame in
        ;; least instructions, and 40 columns is fine for us.
        ;;
        lda #$14        ;; 0001 0100
        sta $D018        ;; VIC-II Character/Screen location

        lda #$1B        ;; 0001 1011
        sta $D011        ;; VIC-II Control Register

        lda #$C8        ;; 1100 1000
        sta $D016        ;; VIC-II Control Register

        ;; Now switch to 16-bit text mode so that we can use proportional
        ;; characters and full-colour characters for chars >$FF for the logo
	;; Also enable CRT emulation by default.
        ;;
        lda #$e5
        sta $d054        ;; VIC-IV Control Register C

        ;; and 80 bytes (40 16-bit characters) per row.
        ;;
        lda #<80
        sta $d058
        lda #>80
        sta $d059

        rts

;;         ========================

resetpalette:
        ;; reset VIC-IV palette to sensible defaults.
        ;; load C64 colours into palette bank 3 for use when
        ;; PAL bit in $D030 is set.
        ;;
        lda #$04
        tsb $D030        ;; enable PAL bit in $D030

	jsr setbannerpalette

        ;; C64 colours designed to look like C65 colours on an
        ;; RGBI screen.
	ldx #$0F
-       lda c64_colours_table+$00,x     ; load & store red component
        sta $D100,x
        lda c64_colours_table+$10,x     ; load & store green component
        sta $D200,x
        lda c64_colours_table+$20,x     ; load & store blue component
        sta $D300,x
        dex
        bpl -

	rts
	
c64_colours_table:
        ;   0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C | D | E | F
        !8 $00,$ff,$ba,$66,$bb,$55,$d1,$ae,$9b,$87,$dd,$b5,$b8,$0b,$aa,$8b  ; -- red
        !8 $00,$ff,$13,$ad,$f3,$ec,$e0,$5f,$47,$37,$39,$b5,$b8,$4f,$d9,$8b  ; -- green
        !8 $00,$ff,$62,$ff,$8b,$85,$79,$c7,$81,$00,$78,$b5,$b8,$ca,$fe,$8b  ; -- blue	

;;         ========================

;; erase standard 40-column screen
;;
erasescreen:
        ;; bank in 2nd KB of colour RAM
        ;;
        lda #$01
        tsb $D030

        ;; use DMA to clear screen and colour RAM
        ;; The screen is in 16-bit bit mode, so we actually need to fill
        ;; with $20,$00, ...
        ;;
        ;; We will cheat by setting the first four bytes, and then copying from
        ;; there, and it will then read from the freshly written bytes.
        ;; (two bytes might not be enough to allow the write from the last DMA
        ;;  action to be avaialble for reading because of how the DMAgic is
        ;;  pipelined).
        ;;
        lda #$20
        sta $0400
        sta $0402
        lda #$00
        sta $0401
        sta $0403

        ;; Set bottom 22 bits of DMA list address as for C65
        ;; (8MB address range)
        ;;
        lda #$ff
        sta $d702

        ;; Hyppo ROM is at $FFFE000 - $FFFFFFF, so
        ;; we need to tell DMAgic that DMA list is in $FFxxxxx.
        ;; this has to be done AFTER writing to $d702, as $d702
        ;; clears bits 27 - 22 of the DMA list address to help with
        ;; compatibility.
        ;;
        lda #$ff
        sta $d704

        lda #>erasescreendmalist
        sta $d701

        ;; set bottom 8 bits of address and trigger DMA.
        ;;
        lda #<erasescreendmalist
        sta $d705

        ;; bank 2nd KB of colour RAM back out
        ;;
        lda #$01
        trb $D030

;;         ========================

        ;; move cursor back to top of the screen
        ;; (but leave 8 rows for logo and banner text)
        ;;
        lda #$08
        sta screenrow

        ;; draw 40x8 char block for banner
        ;;
        ldy #$00
        lda #$00
logo1:
        sta $0400,y
        inc
        iny
        iny
        bne logo1
logo1a:
        sta $0500,y
        inc
        iny
        iny
        bne logo1a
logo1b:
        sta $0600,y
        inc
        iny
        iny
        cpy #$80
        bne logo1b

        ;; then write the high bytes for these (all $01, so char range will be
        ;; $100-$140. $100 x $40 = $4000-$4FFF
        ;;
        ldx #$00
        lda #$16     ;; $1600 x $40 = $58000 where banner tiles sit
logo2:
        sta $0401,x
        inc
        sta $0581,x
        dec
        sta $0501,x
        inx
        inx
        bne logo2

        ;; finally set palette for banner using contents of memory at $57D00-$57FFF
setbannerpalette:
        lda #$ff
        sta $D070        ;; select palette bank 3 for display and edit

	;; Set DMA list address
        ;;
        lda #>bannerpalettedmalist
        sta $d701
        lda #$0f
        sta $d702 ;; DMA list address is $xxFxxxx
        lda #$ff
        sta $d704 ;; DMA list address is $FFxxxxx

        ;; set bottom bits of DMA list address and trigger enhanced DMA
        ;;
        lda #<bannerpalettedmalist
        sta $d705

        rts

bannerpalettedmalist:
        ;; MEGA65 enhanced DMA options
        !8 $0A      ;; Request format is F018A
        !8 $80,$00,$81,$FF ;; src = $00xxxxx, dst=$FFxxxxx
        !8 $00 ;; no more options
        ;; F018A DMA list
        !8 $00   ;; COPY + no chained request
        !16 $0300
        !16 $7D00 ;;
        !8 $05   ;; source bank 05
        !16 $3100 ;; ; $xxx3100
        !8 $0D   ;; ; $xxDxxxx
        !16 $0000 ;; modulo (unused)



;;         ========================

erasescreendmalist:
        ;; Clear screen RAM
        ;;
        ;; MEGA65 enhanced DMA options
        !8 $0A      ;; Request format is F018A
        !8 $00 ;; no more options
        ;; F018A DMA list
        !8 $04   ;; COPY + chained request
        !16 1996  ;; 40x25x2-4 = 1996
        !16 $0400 ;; copy from start of screen at $0400
        !8 $00   ;; source bank 00
        !16 $0404 ;; ... to screen at $0402
        !8 $00   ;; screen is in bank $00
        !16 $0000 ;; modulo (unused)

        ;; Clear colour RAM
        ;;
        ;; MEGA65 DMA options
        !8 $81,$FF ;; Destination is $FFxxxxx
        !8 $00     ;; no more options
        ;; F018A dma list
        !8 $03     ;; FILL + no more chained requests
        !16 2000    ;; 40x25x2 = 2000
        !8 $01     ;; fill with white = $01
        !8 $00,$00 ;; rest of source address is ignored in fill
        !16 $0000   ;; destination address
        !8 $08     ;; destination bank
        !16 $0000   ;; modulo (unused)


;;         ========================

printmessage:        ;; HELPER routine
        ;;
        ;; This subroutine takes inputs from the X and Y registers,
        ;; so set these registers before calling this subroutine,
        ;; The X and Y registers need to point to a message as shown below:
        ;;
        ;;         ldx #<msg_foundsdcard
        ;;         ldy #>msg_foundsdcard
        ;;         jsr printmessage
        ;;
        ;; Ie: the X is the high-byte of the 16-bit address, and
        ;;     the Y is the low-byte  of the 16-bit address.

        stx <zptempp        ;; zptempp is 16-bit pointer to message
        sty <zptempp+1

        lda #$00
        sta <zptempp2        ;; zptempp2 is 16-bit pointer to screen
        lda #$04
        sta <zptempp2+1

        ldx screenrow

        ;; Makesure we can't accidentally write on row zero
        bne pm22
        ldx #$08
pm22:
        ;; if we have reached the bottom of the screen, start writing again
        ;; from the top of the screen (but don't touch the top 8 rows for
        ;; logo and banner)
        cpx #25
        bne pm2

	jsr scroll_screen
	ldx #24
	stx screenrow

        ;; work out the screen address
        ;;
pm2:
	cpx #$00
        beq pm1

        clc
        lda <zptempp2
        adc #$50          ;; 40 columns x 16 bit
        sta <zptempp2
        lda <zptempp2+1
        adc #$00
        sta <zptempp2+1

pm5:    dex
        bne pm2
pm1:

        ;; Clear line (16-bit chars, so write #$0020 to each word
        ;;
        ldy #$00
pm1b:   lda #$20
        sta (<zptempp2),y
        iny
        lda #$00
        sta (<zptempp2),y
        iny
        cpy #$50
        bne pm1b

writestring:
        phz
        ldy #$00
        ldz #$00
pm3:    lda (<zptempp),y
        beq endofmessage

        ;; convert ASCII/PETSCII to screen codes
        ;;
        cmp #$40
        bcc pm4
        and #$1f

pm4:                ;; write 16-bit character code
        ;;
        sta (<zptempp2),z
        inz
        pha
        lda #$00
        sta (<zptempp2),z
        pla
        iny
        inz
        bne pm3
endofmessage:
        inc screenrow

!if DEBUG_HYPPO {
	;; XXX DEBUG
	;; Require key press after each line displayed.
;;	jsr debug_wait_on_key
}

	plz
	rts

printbanner:
        stx <zptempp
        sty <zptempp+1
        lda #<$0504
        sta zptempp2
        lda #>$0504
        sta zptempp2+1
        jsr writestring
        dec screenrow
        rts

;;         ========================

printhex:
        ;; helper function
        ;;
        ;; seems to want to print the value if the z-reg onto the previous line written to the screen,
        ;; so currently the screen consists of say "mounted $$ images"
        ;; and this routine will go and change the "$$" to the value in the z-reg
        ;;
        ;; BG: surely this can be replaced with updating the "$$" before printing the string
        ;;
        ;; INPUT: .Y, BG seems to be an offset, should be set to zero?
        ;; INPUT: .Z, value in Z-reg to be displayed omn the screen
        ;;
        tza
        lsr
        lsr
        lsr
        lsr
        jsr printhexdigit
        tza
        and #$0f
printhexdigit:
        ;; find next $ sign to replace with hex digit
        ;;
        tax
phd3:   lda (<zptempp2),y
        cmp #$24
        beq phd2
        iny
        iny
        cpy #$50
        bcc phd3
        rts

phd2:   txa
        ora #$30
        cmp #$3a
        bcc phd1
        sbc #$39
phd1:   sta (<zptempp2),y
        iny
        iny
        rts

;;         ========================

go64:

;; Transfer control to C64 kernel.
;; (This also allows entry to C65 mode, because the
;;  C64-mode kernel on the C65 checks if C65 mode
;;  should be entered.)

        ;; unmap sector buffer so C64 can see CIAs
        ;;
        lda #$82
        sta sd_ctrl

        ;; copy routine to stack to switch to
        ;; C64 memory map and enter via reset
        ;; vector.

        ;; erase hyppo ROM copy from RAM
        ;; (well, at least enough so that BASIC doesn't get upset)
        ;; XXX - use DMA
        ;;
        ldx #$00
        txa
g61:    sta $0800,x
        inx
        bne g61

        lda #<40
        sta $d058
        lda #>40
        sta $d059

        ;; write protect ROM RAM
        lda #$04
        tsb hypervisor_feature_enables

        jsr task_set_c64_memorymap
        jsr task_set_pc_to_reset_vector
        jsr task_dummy_nmi_vector

        ;; This must happen last, so that the ultimax cartridge
        ;; reset vector is used, instead of the one in the loaded ROM
        jsr setup_for_ultimax_cartridge

        ;; Apply RESET to cartridge for a little while so that cartridges
        ;; with capacitors tied to EXROM or GAME are visible.
        ;; Do this last, because some cartridges remain visible for as little
        ;; as 512 usec.
        jsr reset_cartridge

go64_exit_hypervisor:
        ;; exit from hypervisor to start machine
        sta hypervisor_enterexit_trigger

!src "ultimax.asm"

;;         ========================

;; BG: the longpeek subroutine does not get called from hyppo,
;;     it gets called only from the hyppo_task file,
;;     so i suggest moving this subroutine to that file.

longpeek:
        ;; Use DMAgic to read any byte of RAM in 28bit address space.
        ;; Value gets read into $BC00 (hyppo_scratchbyte0)
        ;; ($FFFBC00 - $FFFBDFF)

        ;; Patch DMA list
        ;;
        stx longpeekdmalist_src_lsb
        sty longpeekdmalist_src_2sb
        stz longpeekdmalist_src_msb
        sta longpeekdmalist_src_mb

        ;; Set DMA list address
        ;;
        lda #>longpeekdmalist
        sta $d701
        lda #$0f
        sta $d702 ;; DMA list address is $xxFxxxx
        lda #$ff
        sta $d704 ;; DMA list address is $FFxxxxx

        ;; set bottom bits of DMA list address and trigger enhanced DMA
        ;;
        lda #<longpeekdmalist
        sta $d705
        rts

longpeekdmalist:
        ;; MEGA65 Enhanced DMA options
        !8 $0A      ;; Request format is F018A
        !8 $80
longpeekdmalist_src_mb:
        !8 $FF
        !8 $81,$FF ;; destination is always $FFxxxxx
        !8 $00 ;; end of options marker
        ;; F018A format request follows
        !8 $00 ;; COPY, no chain
        ;; 1 byte
        !16 $0001
        ;; source address
longpeekdmalist_src_lsb:
        !8 $00
longpeekdmalist_src_2sb:
        !8 $00
longpeekdmalist_src_msb:
        !8 $00
        ;; destination address ($xxFBC00)
        !16 hyppo_scratchbyte0
        !8 $0F
        !8 $00,00 ;; Modulo

longpoke:
        ;; Use DMAgic to write any byte of RAM in C65 1MB address space.
        ;; A = value
        ;; X = Address LSB
        ;; Y = Address MidB
        ;; Z = Address Bank

        ;; Patch DMA list
        ;;
        sta longpokevalue
        stx longpokeaddress+0
        sty longpokeaddress+1
        stz longpokeaddress+2
        tza
        lsr
        lsr
        lsr
        lsr
        sta longpokedmalist_dest_mb ;; DMAgic destination MB
        ;; and enable F108B enhanced mode by default
        lda #$01
        sta $d703

        ;; Set DMA list address
        ;;
        lda #>longpokedmalist
        sta $d701
        lda #$0f
        sta $d702 ;; DMA list address is $xxFxxxx
        lda #$ff
        sta $d704 ;; DMA list address is $FFxxxxx

        ;; set bottom bits of DMA list address and trigger enhhanced DMA
        ;;

        lda #<longpokedmalist
        sta $d705
        rts

longpokedmalist:
        ;; MEGA65 Enhanced DMA option list
        !8 $0A      ;; Request format is F018A
        !8 $81
longpokedmalist_dest_mb:
        !8 $00
        !8 $00 ;; no more enhanced DMA options
        ;; F018A dma list
        !8 $03 ;; FILL, no chain
        ;; 1 byte
        !16 $0001
        ;; source address (LSB = fill value)
longpokevalue:
        !8 $00
        !16 $0000
        ;; destination address
longpokeaddress:
        !16 $0000
        !8 $0F
        !8 $00,00 ;; Modulo


;;         ========================

;; reset memory map to default
resetmemmap:
        ;; clear memory MAP MB offset register
        ;;
        lda #$00
        ldx #$0f
        ldy #$00   ;; keep hyppo mapped at $8000-$BFFF
        ldz #$3f

        map

        ;; and clear all mapping
        ;;
        tax
        ldy #$00   ;; keep hyppo mapped at $8000-$BFFF
        ldz #$3f

        map
        eom

        rts

;;         ========================

hypervisor_nmi:
hypervisor_irq:
        ;; Default interrupt handlers for hypervisor: for now just mask the
        ;; interrupt source.  Later we can have raster splits in the boot
        ;; display if we so choose.
        sei
        rti

hypervisor_setup_copy_region:
        ;; Hypervisor copy region sit entirely within the first 32KB of
        ;; mapped address space. Since we allow a 256 byte copy region,
        ;; we limit the start address to the range $0000-$7EFF
        ;; XXX - We should also return an error if there is an IO
        ;; region mapped there, so that the hypervisor can't be tricked
        ;; into doing privileged IO operations as part of the copy-back

        lda hypervisor_y
        bmi hscr1
        cmp #$7f
        beq hscr1
        sta hypervisor_userspace_copy_vector +1
        lda #$00
        sta hypervisor_userspace_copy_vector +0

        +Checkpoint "hypervisor_setup_copy_region <success>"

        sec
        rts

hscr1:
        +Checkpoint "hypervisor_setup_copy_region <failure>"

        lda #dos_errorcode_invalid_address
        jmp dos_return_error

;;         ========================

!if DEBUG_HYPPO {

checkpoint:

        ;; Routine to record the progress of code through the hypervisor for
        ;; debugging problems in the hypervisor.
        ;; If the JSR checkpoint is followed by $00, then a text string describing the
        ;; checkpoint is inserted into the checkpoint log.
        ;; Checkpoint data is recorded in the 2nd 16KB of colour RAM.

        ;; Save all registers and CPU flags
        sta checkpoint_a
        stx checkpoint_x
        sty checkpoint_y
        stz checkpoint_z
        php
        pla
        sta checkpoint_p

        ;; pull PC return address from stack
        ;; (JSR pushes return_address-1, so add one)
        pla
        clc
        adc #$01
        sta checkpoint_pcl
        pla
        adc #$00
        sta checkpoint_pch

        ;; Only do checkpoints visibly if shift held during boot
        lda buckykey_status
        and #$03
        beq cp9

        ;; Write checkpoint byte values out as hex into message template
        ldx checkpoint_a
        jsr checkpoint_bytetohex
        sty msg_checkpoint_a+0
        stx msg_checkpoint_a+1

        ldx checkpoint_x
        jsr checkpoint_bytetohex
        sty msg_checkpoint_x+0
        stx msg_checkpoint_x+1

        ldx checkpoint_y
        jsr checkpoint_bytetohex
        sty msg_checkpoint_y+0
        stx msg_checkpoint_y+1

        ldx checkpoint_z
        jsr checkpoint_bytetohex
        sty msg_checkpoint_z+0
        stx msg_checkpoint_z+1

        ldx checkpoint_p
        jsr checkpoint_bytetohex
        sty msg_checkpoint_p+0
        stx msg_checkpoint_p+1

        ldx checkpoint_pch
        jsr checkpoint_bytetohex
        sty msg_checkpoint_pc+0
        stx msg_checkpoint_pc+1

        ldx checkpoint_pcl
        jsr checkpoint_bytetohex
        sty msg_checkpoint_pc+2
        stx msg_checkpoint_pc+3

        ;; Clear out checkpoint message
        ldx #59
        lda #$20
cp4:    sta msg_checkpointmsg,x
        dex
        bpl cp4
cp9:
        ;; Read next byte following the return address to see if it is $00,
        ;; if so, then also store the $00-terminated text message that follows.
        ;; e.g.:
        ;;
        ;; jsr checkpoint
        ;; !8 0,"OPEN DIRECTORY",0
        ;;
        ;; to record a checkpoint with the string "OPEN DIRECTORY"

        ldy #$00
        lda (<checkpoint_pcl),y

        bne nocheckpointmessage

        ;; Copy null-terminated checkpoint string
        ldx #$00
        iny
cp3:    lda (<checkpoint_pcl),y
        beq endofcheckpointmessage
        sta msg_checkpointmsg,x
        inx
        iny
        cpy #60
        bne cp3

        ;; flush out any excess bytes at end of message
cp44:   lda (<checkpoint_pcl),y
        beq endofcheckpointmessage
        iny
        bra cp44

endofcheckpointmessage:
        ;; Skip $00 at end of message
        iny

nocheckpointmessage:

        ;; Advance return address following any checkpoint message
        tya
        clc
        adc checkpoint_pcl
        sta checkpoint_pcl
        lda checkpoint_pch
        adc #$00
        sta checkpoint_pch

        ;; Only do checkpoints visibly if shift key held
        lda buckykey_status
        and #$03
        beq checkpoint_return

        ;; output checkpoint message to serial monitor
        ldx #0
        ;; do not adjust x-reg until label "checkpoint_return"
cp5:
        ;; wait for uart to be not busy
        lda hypervisor_write_char_to_serial_monitor        ;; LSB is busy status
        bne cp5                ;; branch if busy (LSB=1)

        ;; uart is not busy, so write the char
        lda msg_checkpoint,x
        sta hypervisor_write_char_to_serial_monitor
        inx

        cmp #10                ;; compare A-reg with "LineFeed"
        bne cp5

checkpoint_return:
        ;; restore registers
        lda checkpoint_p
        php
        lda checkpoint_a
        ldx checkpoint_x
        ldy checkpoint_y
        ldz checkpoint_z
        plp

        ;; return by jumping to the
        jmp (checkpoint_pcl)

;;         ========================

checkpoint_bytetohex:

        ;; BG: this is a helper function to convert a HEX-byte to
        ;;     its equivalent two-byte char representation
        ;;
        ;;     input ".X", containing a HEX-byte to convert
        ;;   outputs ".X" & ".Y", Y is MSB, X is LSB, print YX
        txa
        and #$f0
        lsr
        lsr
        lsr
        lsr
        jsr checkpoint_nybltohex
        tay
        txa
        and #$0f
        jsr checkpoint_nybltohex
        tax
        rts

;;         ========================

checkpoint_nybltohex:

        and #$0f
        ora #$30
        cmp #$3a
        bcs cpnth1
        rts

cpnth1: adc #$06
        rts

} ;; !if DEBUG_HYPPO


safe_video_mode:
	;; No digital audio, just pure DVI
	lda #$02
	sta $d61a
	;; NTSC
	lda #$80
	sta $d06f
	rts

run_util_in_hypervisor_context:
	;; XXX Move Stack and ZP to normal places, before letting C64 KERNAL loose on
	;; Hypervisor memory map!
	lda #$00
	!8 $5B ;; tab
	ldy #$01
	!8 $2B ;; tys

	jsr setup_for_openrom
	;; XXX Work around bug in OpenROMs that erases our banner palette when we do this
	;; by putting the palette back immediately.
        jsr setbannerpalette

	;; Actually launch the utility in the hypervisor context
	;; (so must not use RAM > $7FFF, is immune to freezing etc)
	jmp $080d

setup_for_openrom:

	;; Bank in KERNAL ROM space so megaflash can run
	;; Writing to $01 when ZP is relocated is a bit tricky, as
	;; we have to mess about with the Base Register, or force
	;; the assembler to do an absolute write.
	lda #$37
	!8 $8d,$01,$00 ;; ABS STA $0001

	;; We should also reset video mode to normal
	lda #$97
	trb $d054

	;; Clear memory map at $4000-5FFF
	;; (Why on earth do we even map some of the HyperRAM there, anyway???)
	lda #0
	tax
	tay
	ldz #$3f
	map
	eom
	;; And set MB low to $00, so that OpenROM doesn't jump into lala land
	lda #0
	ldx #$0f
	map
	eom

	;; Tell KERNAL screen is at $0400
	lda #>$0400
	sta $0288

	lda $fff9
	cmp #$ff
	beq @notOpenROM
	;; OpenROMs setup (XXX Won't work with Commodore C65 ROMs!)
	jsr ($fff8)
@notOpenROM:
	;; make sure not in quote mode etc
	lda #$00
	sta $d8 ;; number of insertions outstanding = 0
	sta $0f ;; clear quote mode

	;; Clear common interrupt sources

	;; CIAs
;;	lda #$ff
;;	sta $dc0d
;;	sta $dd0d
;;	lda $dc0d
;;	lda $dd0d

	;; VIC-IV
;;	dec $d019
;;	lda #$00
;;	sta $d01a

	;; Ethernet
;;	lda #$00
;;	sta $d6e1

	;; C65 UART
	;; XXX Actually it can't generate interrupts yet, so nothing to do :)

	;; Finally, clear any pending interrupts by using MAP instruction
;;	tax
;;	tay
;;	taz
;;	map
;;	lda #0    ;; to give time to effect clearing irq_pending in CPU
;;	eom

	;; And ignore any queued NMI (these don't get cleared by the MAP trick)

	;;  Clear pending NMI flag
        lda hypervisor_feature_enables
	and #$7f
        sta hypervisor_feature_enables

	;; Set safety-net NMI handler
	lda #$40
	sta $0420
	lda #<$0420
	sta $0318
	lda #>$0420
	sta $0319
	rts

screenrestore_dmalist:
        !8 $80,$00  ;; Copy from $00xxxxx
        !8 $81,$00  ;; Copy to $00xxxxx
        !8 $00 ;; no more options
        ;; F018A DMA list
        !8 $00 ;; copy + last in chain
        !16 $0800 ;; size of copy
        !16 $9000 ;; destination address is $0000
        !8 $00   ;; of bank $0
        !16 $0400 ;; starting addr
        !8 $00   ;; of bank $5
        !16 $0000 ;; modulo (unused)

scroll_screen:

        lda #$ff
        sta $d702
        sta $d704  ;; dma list is in top MB of address space

	;; Don't forget to reset colour RAM also
        lda #>scrollscreen_dmalist
        sta $d701
        ;; set bottom 8 bits of address and trigger DMA.
        ;;
        lda #<scrollscreen_dmalist
        sta $d705

	rts

scrollscreen_dmalist:
        !8 $80,$00  ;; Copy from $00xxxxx
        !8 $81,$00  ;; Copy to $00xxxxx
        !8 $00 ;; no more options
        ;; F018A DMA list
        !8 $00 ;; copy + last in chain
        !16 1280 ;; size of copy  ( (17-1) * 40 * 2 )
        !16 1744 ;; src address is line 9 of screen
        !8 $00   ;; of bank $0
        !16 1664 ;; starting addr is line 8 of screen
        !8 $00   ;; of bank $0
        !16 $0000 ;; modulo (unused)


utility_dmalist:
        ;; copy $FF8xxxx-$FF8yyyy to $00007FF-$000xxxx

        ;; MEGA65 Enhanced DMA options
        !8 $0A      ;; Request format is F018A
        !8 $80,$FF  ;; Copy from $FFxxxxx
        !8 $81,$00  ;; Copy to $00xxxxx
        !8 $00 ;; no more options
        ;; F018A DMA list
        !8 $00 ;; copy + last request in chain
utility_dmalist_length:
        !16 $FFFF ;; size of copy  (gets overwritten)
utility_dmalist_srcaddr:
        !16 $FFFF ;; starting addr (gets overwritten)
        !8 $08   ;; of bank $8
        !16 $07FF ;; destination address is $0801 - 2
        !8 $00   ;; of bank $0
        !16 $0000 ;; modulo (unused)


msg_utility_item:
        !text "1. 32 CHARACTERS OF UTILITY NAME...    "
        !8 0

utillist_next:

        ;; Advance pointer to the next pointer
        ldz #42
        lda [<zptempv32],z
        phx
        tax
        inz
        lda [<zptempv32],z
        ;; XXX - Make sure it can't point earlier into the colour RAM here

        sta <zptempv32+1
        stx <zptempv32
        plx
        rts

utillist_validity_check:
        ;; See if this is a valid utility entry
        ldz #0

        ;; Check for magic value
        lda [<zptempv32],z
        cmp #'M'
        bne ulvc_fail
        inz
        lda [<zptempv32],z
        cmp #'6'
        bne ulvc_fail
        inz
        lda [<zptempv32],z
        cmp #'5'
        bne ulvc_fail
        inz
        lda [<zptempv32],z
        cmp #'U'
        bne ulvc_fail

        ;; Check self address
        ldz #40
        lda [<zptempv32],z
        cmp zptempv32
        bne ulvc_fail
        inz
        lda [<zptempv32],z
        cmp zptempv32+1
        bne ulvc_fail

        ;; success
        sec
        rts

ulvc_fail:
        clc
        rts

tryloadbootlogofromflash:
	rts
setup_banner_load_pointer:
	rts
attempt_loadcharrom:
	rts
attempt_loadc65rom:
	rts
first_boot_flag_instruction:
	inc $d020
	rts
	
utillist_rewind:

        ;; Set pointer to first entry in colour RAM ($0850)
        lda #<$0850
        sta <zptempv32
        lda #>$0850
        sta <(zptempv32+1)
        lda #<$0FF8
        sta <(zptempv32+2)
        lda #>$0FF8
        sta <(zptempv32+3)

        rts

serialwrite:
        ;; write character to serial port

	;; First wait for it to go ready
	ldx hypervisor_write_char_to_serial_monitor
	bne serialwrite

        ;; XXX - Have some kind of permission control on this
        ;; XXX - $D67C should not work when matrix mode is enabled at all?
        sta hypervisor_write_char_to_serial_monitor
        sta hypervisor_enterexit_trigger

;;         ========================

!if DEBUG_HYPPO {

;; checkpoint message

msg_checkpoint:         !text "$"
msg_checkpoint_pc:      !text "%%%% A:"
msg_checkpoint_a:       !text "%%, X:"
msg_checkpoint_x:       !text "%%, Y:"
msg_checkpoint_y:       !text "%%, Z:"
msg_checkpoint_z:       !text "%%, P:"
msg_checkpoint_p:       !text "%% :"
msg_checkpointmsg:      !text "                                                             " ;; END_OF_STRING
                        !8 13,10  ;; CR/LF

}

;;         ========================

msg_checkpoint_eom:

;; messages all have to be <=40 bytes long

msg_utilitymenu:
        !text "SELECT UTILITY TO LAUNCH"
        !8 0

msg_noutilitymenu:
		        !text "HOLD ALT + POWER CYCLE FOR UTILITY MENU"
	                !8 0

msg_noflashmenu:
		        !text "HOLD NO SCROLL + POWER CYCLE FOR FLASH"
	                !8 0

msg_retryreadmbr:       !text "RE-TRYING TO READ MBR"
                        !8 0
msg_hyppo:              !text "MEGA65 MEGAOS HYPERVISOR V00.17"
                        !8 0
msg_hyppohelpfirst:     !text "NO SCROLL=FLASH, ALT=UTILS, CTRL=HOLD"
                        !8 0
msg_hyppohelpnotfirst:  !text "POWER OFF/ON FOR FLASH OR UTIL MENU"
                        !8 0
msg_romok:              !text "ROM CHECKSUM OK - BOOTING"
                        !8 0
;; msg_rombad:          !text "ROM CHECKSUM FAIL - LOADING ROMS"
;;                      !8 0
;; msg_charrombad:      !text "COULD NOT LOAD CHARROM.M65"
;;                      !8 0
msg_charromloaded:      !text "LOADED CHARROM.M65"
                        !8 0
msg_megaromloaded:      !text "LOADED MEGA65.ROM"
                        !8 0
msg_tryingsdcard:       !text "LOOKING FOR SDHC CARD >=4GB..."
                        !8 0
msg_foundsdcard:        !text "SD CARD IS NOT SDHC. MUST BE SDHC."
                        !8 0
msg_foundsdhccard:      !text "FOUND AND RESET SDHC CARD"
                        !8 0
msg_sdcarderror:        !text "ERROR READING FROM SD CARD"
                        !8 0
msg_sdredoread:         !text "RE-READING SDCARD"
                        !8 0
msg_nosdcard:           !text "NO SDCARD, TRYING BUILT-IN ROM"
                        !8 0
msg_badformat:          !text "BAD MBR OR DOS BOOT SECTOR."
                        !8 0
msg_sdcardfound:        !text "READ PARTITION TABLE FROM SDCARD"
                        !8 0
msg_foundromfile:       !text "FOUND ROM FILE. START CLUSTER = $$$$$$$$"
                        !8 0
msg_diskcount:          !text "DISK-COUNT=$$, DEFAULT-DISK=$$"
                        !8 0
;; msg_diskdata0:       !text "DISK-TABLE:"
;;                      !8 0
;; msg_diskdata:        !text "BB$$:$$.$$.$$.$$.$$.$$.$$.$$"
;;                      !8 0
msg_filelengths:        !text "LOOKING FOR $$ BYTES, I SEE $$ BYTES"
                        !8 0
msg_fileopenerror:      !text "COULD NOT OPEN ROM FILE FOR READING"
                        !8 0
msg_readingfile:        !text "READING ROM FILE..."
                        !8 0
msg_romfilelongerror:   !text "ROM TOO LONG: (READ $$$$ PAGES)"
                        !8 0
msg_romfileshorterror:  !text "ROM TOO SHORT: (READ $$$$ PAGES)"
                        !8 0
msg_clusternumber:      !text "CURRENT CLUSTER=$$$$$$$$"
                        !8 0
msg_sectoraddress:      !text "CURRENT SECTOR= $$$$$$$$"
                        !8 0
msg_nod81:              !text "CANNOT MOUNT D81 - (ERRNO: $$)"
                        !8 0
msg_d81mounted:         !text "D81 SUCCESSFULLY MOUNTED"
                        !8 0
msg_releasectrl:        !text "RELEASE CONTROL TO CONTINUE BOOTING."
                        !8 0
msg_dipswitch3on:       !text "SW3 OFF OR PRESS RUN/STOP TO CONTINUE."
                        !8 0
msg_romnotfound:        !text "COULD NOT FIND ROM MEGA65XXROM"
                        !8 0
msg_foundhickup:        !text "LOADING HICKUP.M65 INTO HYPERVISOR"
                        !8 0
msg_no1541rom:          !text "COULD NOT LOAD 1541ROM.M65"
                        !8 0
msg_nojoyflash:          !text "COULD NOT LOAD JOYFLASH.M65"
                        !8 0
;; msg_nohickup:        !text "NO HICKUP.M65 TO LOAD (OR BROKEN)"
;;                      !8 0
;; msg_hickuploaded:    !text "HICKUP LOADED TO 00004000 - $$$$$$$$"
;;                      !8 0
msg_alreadyhicked:      !text "RUNNING HICKED HYPERVISOR"
                        !8 0
msg_lookingfornextsector:
                        !text "LOOKING FOR NEXT SECTOR OF FILE"
                        !8 0
msg_nologo:             !text "COULD NOT LOAD BANNER.M65 (ERRNO:$$)"
                        !8 0
msg_cdrootfailed:       !text "COULD NOT CHDIR TO / (ERRNO:$$)"
                        !8 0
msg_tryingcard0:        !text "TRYING SDCARD BUS 0"
                        !8 0
msg_usingcard1:         !text "USING SDCARD BUS 1"
                        !8 0
msg_dmagica:            !text "DMAGIC REV A MODE"
                        !8 0
msg_dmagicb:            !text "DMAGIC REV B MODE"
                        !8 0

;; Include the GIT Message as a string
!src "../version.asm"

msg_blankline:          !8 0

;;         ========================
            ;; filename of 1541 ROM
txt_1541ROM:            !text "1541ROM.M65"
                        !8 0

            ;; filename of character ROM
txt_CHARROMM65:         !text "CHARROM.M65"
                        !8 0

            ;; filename of ROM we want to load in FAT directory format
            ;; (the two zero bytes are so that we can insert an extra digit after
            ;; the 5, when a user presses a key, so that they can choose a
            ;; different ROM to load).
            ;;
txt_MEGA65ROM:          !text "MEGA65.ROM"
                        !8 0,0

            ;; filename of 1581 disk image we mount by default
            ;;
txt_MEGA65D81:          !text "MEGA65.D81"
                        !8 0,0,0,0,0,0,0

            ;; filename of hyppo update file
            ;;
txt_HICKUPM65:          !text "HICKUP.M65"
                        !8 0

            ;; filename containing boot logo
            ;;
txt_BOOTLOGOM65:        !text "BANNER.M65"
                        !8 0

            ;; filename containing freeze menu
txt_FREEZER:            !text "FREEZER.M65"
                        !8 0

txt_ETHLOAD:		!text "ETHLOAD.M65"
			!8 0
	
            ;; If this file is present, then machine starts up with video
            ;; mode set to NTSC (60Hz), else as PAL (50Hz).
            ;; This is to allow us to boot in PAL by default, except for
            ;; those who have a monitor that cannot do 50Hz.
txt_NTSC:               !text "NTSC"
                        !8 0

txt_JOYFLASHM65:          !text "JOYFLASH.M65"
                        !8 0,0
	
;;         ========================

!if DEBUG_HYPPO {
        !src "debug.asm"
}

;;         ========================

        ;; Table of available disks.
        ;; Include native FAT32 disks, as well as (in the future at least)
        ;; mounted .D41, .D71, .D81 and .DHD files using Commodore DOS filesystems.
        ;; But for now, we are supporting only FAT32 as the filesystem.
        ;; See hyppo_dos.asm for information on how the table is used.
        ;; Entries are 32 bytes long, so we can have 6 of them.
        ;;
        dos_max_disks = 6

        ;; .segment DOSDiskTable
        * = DOSDiskTable_Start
dos_disk_table:

        ;; .segment SysPartStructure
        * = SysPartStructure_Start

syspart_structure:

syspart_start_sector:
        !8 0,0,0,0
syspart_size_in_sectors:
        !8 0,0,0,0
syspart_reserved:
        !8 0,0,0,0,0,0,0,0

;; For fast freezing/unfreezing, we have a number of contiguous
;; freeze slots that can each store the state of the machine
;; We note where the area begins, how big it is, how many slots
;; it has, and how many sectors are used at the start of the area
;; to hold a directory with 128 bytes per slot, the contains info
;; about the frozen program.
syspart_freeze_area_start:
        !8 0,0,0,0
syspart_freeze_area_size_in_sectors:
        !8 0,0,0,0
syspart_freeze_slot_size_in_sectors:
        !8 0,0,0,0
syspart_freeze_slot_count:
        !8 0,0
syspart_freeze_directory_sector_count:
        !8 0,0

        ;; The first 64 freeze slots are reserved for various purposes
       syspart_freeze_slots_reserved  = 64
        ;; Freeze slot 0 is used when the hypervisor needs to
        ;; temporarily shove all or part of the active process out
        ;; the way to do something
       freeze_slot_temporary = 0

        ;; Freeze slots 1 - 63 are currently reserved
        ;; They will likely get used for a service call-stack
        ;; among other purposes.

        ;; We then have a similar area for system services, which are stored
        ;; using much the same representation, but are used as helper
        ;; programs.
syspart_service_area_start:
        !8 0,0,0,0
syspart_service_area_size_in_bytes:
        !8 0,0,0,0
syspart_service_slot_size_in_bytes:
        !8 0,0,0,0
syspart_service_slot_count:
        !8 0,0
syspart_service_directory_sector_count:
        !8 0,0

;; /*  -------------------------------------------------------------------
;;     Hypervisor DOS work area and scratch pad at $BC00-$BCFF
;;     ---------------------------------------------------------------- */

        ;; .segment DOSWorkArea
        * = DOSWorkArea_Start

hyppo_scratchbyte0:
        !8 $00

        ;; The number of disks we have
        ;;
dos_disk_count:
        !8 $00

        ;; The default disk
        ;;
dos_default_disk:
        !8 $00

        ;; The current disk
        ;;
dos_disk_current_disk:
        !8 $00

        ;; Offset of current disk entry in disk table
        ;;
dos_disk_table_offset:
        !8 $00

        ;; cluster of current directory of current disk
        ;;
dos_disk_cwd_cluster:
        !8 0,0,0,0

;;         ========================

        ;; Current point in open directory
        ;;
dos_opendir_cluster:
        !8 0,0,0,0
dos_opendir_sector:
        !8 0
dos_opendir_entry:
        !8 0

;;         ========================

        ;; WARNING: dos_readdir_read_next_entry uses carnal knowledge about the following
        ;;          structure, particularly the length as calculated here:
        ;;
        dos_dirent_structure_length = dos_dirent_struct_end - dos_dirent_struct_start

        ;; Current long filename (max 64 bytes)
        ;;
dos_dirent_struct_start:
dos_dirent_longfilename:
        !text "Venezualen casaba melon productio" ;; 33-chars
        !text "n statistics (2012-2015).txt  "    ;; 30-chars
        !8 0

dos_dirent_longfilename_length:
        !8 0

dos_dirent_shortfilename:
        !text "FILENAME.EXT"
        !8 0

dos_dirent_cluster:
        !8 0,0,0,0

dos_dirent_length:
        !8 0,0,0,0

dos_dirent_type_and_attribs:
        !8 0
dos_dirent_struct_end:

;;         ========================

        ;; Requested file name and length
        ;;
dos_requested_filename_len:
        !8 0

dos_requested_filename:
        !text "Venezualen casaba melon productio"
        !text "n statistics (2007-2011).txt     "

;;         ========================

        ;; Details about current DOS request
        ;;
dos_sectorsread:                !16 0
dos_bytes_remaining:            !16 0,0
dos_current_sector:             !16 0,0
dos_current_cluster:            !16 0,0
dos_current_sector_in_cluster:  !8 0

;; Current file descriptors
;; Each descriptor has:
;;   disk id : 1 byte ($00-$07 = file open, $FF = file closed)
;;   access mode : 1 byte ($00 = read only)
;;   start cluster : 4 bytes
;;   current cluster : 4 bytes
;;   current sector in cluster : 1 byte
;;   offset in sector: 2 bytes
;;   file offset / $100 : 3 bytes
;;
        dos_filedescriptor_max = 4
        dos_filedescriptor_offset_diskid = 0
        dos_filedescriptor_offset_mode = 1
        dos_filedescriptor_offset_startcluster = 2
        dos_filedescriptor_offset_currentcluster = 6
;;
;; These last three fields must be contiguous, as dos_open_current_file
;; relies on it.
;;
        dos_filedescriptor_offset_sectorincluster = 10
        dos_filedescriptor_offset_offsetinsector = 11
        dos_filedescriptor_offset_fileoffset = 13

dos_file_descriptors:
        !8 $FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0        ;; each is 16 bytes
        !8 $FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        !8 $FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        !8 $FF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

    ;; The current file descriptor
    ;;
dos_current_file_descriptor:
        !8 0

    ;; Offset of current file descriptor
    ;;
dos_current_file_descriptor_offset:
        !8 0

dos_first_vfat_chunk_in_list_flag:
        !8 0

;;         ========================

    ;; For providing feedback on why DOS calls have failed
    ;; There is a set of error codes defined in hyppo_dos.asm
dos_error_code:
        !8 $00

    ;; Similarly for system partition related errors
syspart_error_code:
        !8 $00

    ;; Non-zero if there is a valid system partition
syspart_present:
        !8 $00

;; /*  -------------------------------------------------------------------
;;     Reserved space for Hypervisor Process work area $BD00-$BDFF
;;     ---------------------------------------------------------------- */
        ;; .segment ProcessDescriptors
        * = ProcessDescriptors_Start

!src "process_descriptor.asm"



;; /*  -------------------------------------------------------------------
;;     Reserved space for Hyppo ZP at $BF00-$BFFF
;;     ---------------------------------------------------------------- */
        ;; .segment HyppoZP
        * = HyppoZP_Start

        ;; Temporary vector storage for DOS
        ;;
dos_scratch_vector:
        !16 0,0
dos_scratch_byte_1:
        !8 0
dos_scratch_byte_2:
        !8 0

        ;; Vectors for copying data between hypervisor and user-space
        ;;
hypervisor_userspace_copy_vector:
        !16 0

        ;; general hyppo temporary variables
        ;;
zptempv:
        !16 0
zptempv2:
        !16 0
zptempp:
        !16 0
zptempp2:
        !16 0
zptempv32:
        !16 0,0
zptempv32b:
        !16 0,0
dos_file_loadaddress:
        !16 0,0

!if DEBUG_HYPPO {
        ;; Used for checkpoint debug system of hypervisor
        ;;
checkpoint_a:
        !8 0
checkpoint_x:
        !8 0
checkpoint_y:
        !8 0
checkpoint_z:
        !8 0
checkpoint_p:
        !8 0
checkpoint_pcl:
        !8 0
checkpoint_pch:
        !8 0
}

        ;; SD card timeout handling
        ;;
sdcounter:
        !8 0,0,0

;; /*  -------------------------------------------------------------------
;;     Scratch space in ZP space usually used by kernel
;;     we try to use address space not normally used by C64 kernel, so
;;     that it is possible to make calls to hyppo after boot. Eventually
;;     the desire is to have an SYS call that brings up a menu that lets
;;     you choose a disk image from a list.
;;     ---------------------------------------------------------------- */

romslab:
        !8 0
screenrow:
        !8 0
checksum:
        !32 0
file_pagesread:
        !16 0

        ;; Variables for testing of D81 boot image
d81_lasttype:
        !8 0
d81_clusternumber:
        !32 0
d81_clustersneeded:
        !16 0
d64_clustersneeded:
        !16 0
d71_clustersneeded:
        !16 0
d81_clustercount:
        !16 0

	;; Make sure we pad to full size
	* = Hyppo_End
	!8 0