_display__init_blank:
	push {r0-r7, lr}

	ldr r0, =DISPLAY_BUFFER_WITH_BRIGHTNESS_FIRST_ADDR

	ldr r2, =2000; str r2, [r0, 0]
	ldr r2, =2000; str r2, [r0, 4]
	ldr r2, =2000; str r2, [r0, 8]
	ldr r2, =2000; str r2, [r0, 12]
	ldr r2, =2000; str r2, [r0, 16]
	ldr r2, =2000; str r2, [r0, 20]
	ldr r2, =2000; str r2, [r0, 24]

	adds r0, #28
	ldr r2, =1000; str r2, [r0, 0]
	ldr r2, =1000; str r2, [r0, 4]
	ldr r2, =1000; str r2, [r0, 8]
	ldr r2, =1000; str r2, [r0, 12]
	ldr r2, =1000; str r2, [r0, 16]
	ldr r2, =1000; str r2, [r0, 20]
	ldr r2, =1000; str r2, [r0, 24]

	adds r0, #28
	ldr r2, =0500; str r2, [r0, 0]
	ldr r2, =0500; str r2, [r0, 4]
	ldr r2, =0500; str r2, [r0, 8]
	ldr r2, =0500; str r2, [r0, 12]
	ldr r2, =0500; str r2, [r0, 16]
	ldr r2, =0500; str r2, [r0, 20]
	ldr r2, =0500; str r2, [r0, 24]

	adds r0, #28
	ldr r2, =0250; str r2, [r0, 0]
	ldr r2, =0250; str r2, [r0, 4]
	ldr r2, =0250; str r2, [r0, 8]
	ldr r2, =0250; str r2, [r0, 12]
	ldr r2, =0250; str r2, [r0, 16]
	ldr r2, =0250; str r2, [r0, 20]
	ldr r2, =0250; str r2, [r0, 24]

	adds r0, #28
	ldr r2, =0050; str r2, [r0, 0]
	ldr r2, =0050; str r2, [r0, 4]
	ldr r2, =0050; str r2, [r0, 8]
	ldr r2, =0050; str r2, [r0, 12]
	ldr r2, =0050; str r2, [r0, 16]
	ldr r2, =0050; str r2, [r0, 20]
	ldr r2, =0050; str r2, [r0, 24]


	pop {r0-r7, pc}



_display__flush:
	push {r0-r7, lr}

	@ R3: column address.
	ldr r3, =COL_1

	_col:

		@ Column ON:
		mov r8, r3
		bl _helpers__set_pin_high

		@ R2: row address.
		ldr r2, =ROW_1

		_row:

			ldr r4, =ROW_1
			subs r5, r2, r4
			lsrs r5, #5 @ R5 / 32
			@ R5: row index.

			ldr r4, =COL_1
			subs r6, r3, r4
			lsrs r6, #5 @ R5 / 32
			@ R6: col index.

			movs r7, #7
			muls r7, r6
			adds r7, r5 @ R7: display buffer index of the dot.
			lsls r7, 2 @ R7: display buffer mem offset of the dot.
		
			ldr r4, =DISPLAY_BUFFER_WITH_BRIGHTNESS_FIRST_ADDR
			ldr r4, [r4, r7]
			@ R4: brightness value.

			ldr r5, =DISPLAY__FADE_DARKNESS_MAX
			subs r5, r4
			@ R5: darkness value.


			mov r8, r2
			bl _helpers__set_pin_low
			
			@ Wait in brigtness ...
			mov r8, r4
			bl _helpers__delay

			mov r8, r2
			bl _helpers__set_pin_high

			@ Wait in darkness ...
			mov r8, r5
			bl _helpers__delay

			adds r2, #32 @ Next row address.
			ldr r4, =ROW_7
			cmp r2, r4

		ble _row

		@ Column OFF:
		mov r8, r3
		bl _helpers__set_pin_low

		adds r3, #32 @ Next column address.
		ldr r4, =COL_5
		cmp r3, r4

	ble _col
		
	pop {r0-r7, pc}



_display__flush_old:
	push {r0-r7, lr}

	ldr r2, =COL_1
	movs r3, 1 @ Column index.

	ldr r4, =DISPLAY_BUFFER_CURSOR
	ldr r4, [r4]
	adds r3, r4 @ Cursor-X.

	_col2:
		ldr r0, =DISPLAY_BUFFER_FIRST_ADDR
		ldr r1, =ROW_1

		push {r0-r3} @ Save current row addr and current row data addr.

		ldr r0, =BRIGHTNESS_LEVELS
		movs r1, r3
		lsls r1, 2
		adds r0, r1
		ldr r1, [r0]
		mov r12, r1

		push {r2}; bl _helpers__set_pin_high @ Column ON.
		pop {r0-r3} @ Load current row addr and current row data addr.

		_row2:
			push {r0-r3} @ Save current row addr and current row data addr.

			ldr r4, [r0] @ R0: current row address.
			lsls r4, r3 @ Get the first bit.
			bcs _row_on @ If set (1) row on.
				push {r1}; bl _helpers__set_pin_high
				b _after_row_on
			_row_on:
				push {r1}; bl _helpers__set_pin_low

		_after_row_on:
			pop {r0-r3} @ Load current row addr and current row data addr.

			push {r0-r3} @ Save current row addr and current row data addr.
			mov r2, r12 @ R12 how long keep it off
			ldr r1, =DISPLAY__FADE_DARKNESS_MAX
			subs r1, r2
			push {r1}; bl _helpers__delay
			pop {r0-r3} @ Load current row addr and current row data addr.

			push {r0-r3} @ Save current row addr and current row data addr.
			push {r1}; bl _helpers__set_pin_high
			pop {r0-r3} @ Load current row addr and current row data addr.

			push {r0-r3} @ Save current row addr and current row data addr.
			mov r1, r12
			push {r1}; bl _helpers__delay
			pop {r0-r3} @ Load current row addr and current row data addr.

			adds r0, 4
			adds r1, 24 @ 6 words.

			ldr r4, =DISPLAY_BUFFER_LAST_ADDR
			cmp r0, r4
		ble _row2

		push {r0-r3} @ Save current row addr and current row data addr.
		push {r2}; bl _helpers__set_pin_low @ Column OFF.
		pop {r0-r3} @ Load current row addr and current row data addr.

		adds r2, 24 @ Next colum data address. 6 words.
		adds r3, 1 @ Next column index.
		ldr r4, =COL_5
		cmp r2, r4
	ble _col2

	pop {r0-r7, pc}

