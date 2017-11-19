_display__init_blank:
	push {r0-r7, lr}

	ldr r0, =DISPLAY_BUFFER_WITH_BRIGHTNESS_FIRST_ADDR

	ldr r2, =500; str r2, [r0, 0]
	ldr r2, =2000; str r2, [r0, 4]
	ldr r2, =2000; str r2, [r0, 8]
	ldr r2, =2000; str r2, [r0, 12]
	ldr r2, =2000; str r2, [r0, 16]
	ldr r2, =2000; str r2, [r0, 20]
	ldr r2, =500; str r2, [r0, 24]

	adds r0, #28
	ldr r2, =0; str r2, [r0, 0]
	ldr r2, =0; str r2, [r0, 4]
	ldr r2, =0; str r2, [r0, 8]
	ldr r2, =0; str r2, [r0, 12]
	ldr r2, =0; str r2, [r0, 16]
	ldr r2, =0; str r2, [r0, 20]
	ldr r2, =0; str r2, [r0, 24]

	adds r0, #28
	ldr r2, =0; str r2, [r0, 0]
	ldr r2, =0; str r2, [r0, 4]
	ldr r2, =0; str r2, [r0, 8]
	ldr r2, =0; str r2, [r0, 12]
	ldr r2, =0; str r2, [r0, 16]
	ldr r2, =0; str r2, [r0, 20]
	ldr r2, =0; str r2, [r0, 24]

	adds r0, #28
	ldr r2, =0; str r2, [r0, 0]
	ldr r2, =0; str r2, [r0, 4]
	ldr r2, =0; str r2, [r0, 8]
	ldr r2, =0; str r2, [r0, 12]
	ldr r2, =0; str r2, [r0, 16]
	ldr r2, =0; str r2, [r0, 20]
	ldr r2, =0; str r2, [r0, 24]

	adds r0, #28
	ldr r2, =0; str r2, [r0, 0]
	ldr r2, =0; str r2, [r0, 4]
	ldr r2, =0; str r2, [r0, 8]
	ldr r2, =0; str r2, [r0, 12]
	ldr r2, =0; str r2, [r0, 16]
	ldr r2, =0; str r2, [r0, 20]
	ldr r2, =0; str r2, [r0, 24]

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

			@ Figure out R5: row index.
			ldr r4, =ROW_1
			subs r5, r2, r4
			lsrs r5, #5 @ R5 / 32

			@ Figure R6: col index.
			ldr r4, =COL_1
			subs r6, r3, r4
			lsrs r6, #5 @ R6 / 32

			movs r7, #7
			muls r7, r6
			adds r7, r5 @ R7: display buffer index of the dot.
			lsls r7, 2 @ R7: display buffer mem offset of the dot.

			ldr r4, =DISPLAY_BUFFER_WITH_BRIGHTNESS_FIRST_ADDR
			ldr r4, [r4, r7]
			@ R4: brightness value.

			ldr r5, =2000
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


_display__flame:
	push {r0-r7, lr}

	mov r2, r9
	adds r2, #24

	_next_col_dot:
		ldr r1, [r2]

		// get random delta
		ldr r5, =RAND_OFFSET
		ldr r7, [r5]
		ldr r6, =EEPROM
		ldr r4, [r6, r7]
		adds r7, #4
		ldr r6, =396
		cmp r7, r6
		ble _save_new_rand_offset
			movs r7, #0
		_save_new_rand_offset:
		str r7, [r5]

		movs r3, #200
		muls r4, r3

		// subtract
		subs r1, r4

		// if negative, make it zero
		bpl _not_negative
			movs r1, #0
		_not_negative:


		str r1, [r2, #28]
		subs r2, #4
		cmp r2, r9
	bge _next_col_dot

	pop {r0-r7, pc}
