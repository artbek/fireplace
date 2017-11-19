_nmi_handler:
	push {lr}
	bkpt
	pop {pc}


_hard_fault_handler:
	push {lr}
	bkpt
	pop {pc}


_svcall_handler:
	push {lr}
	bkpt
	pop {pc}


_pendsv_handler:
	push {lr}
	bkpt
	pop {pc}


_systick_handler:
	push {r0-r7, lr}

	ldr r0, =AUTO_POWER_OFF_TIME_REGISTER
	ldr r1, [r0]
	subs r1, #1
	bne _update_counter
	bl _helpers__go_to_sleep

	_update_counter:
		str r1, [r0]

	pop {r0-r7, pc}


_interrupt_handlers__TIM21:
	push {lr}

	ldr r0, =DISPLAY_BUFFER_WITH_BRIGHTNESS_LAST_ADDR
	subs r0, #24

	subs r0, #28
	mov r9, r0
	bl _display__flame

	subs r0, #28
	mov r9, r0
	bl _display__flame

	subs r0, #28
	mov r9, r0
	bl _display__flame

	subs r0, #28
	mov r9, r0
	bl _display__flame


	@ ldr r0, =COL_DECIMAL; mov r8, r0; bl _helpers__toggle_pin

	macros__register_bit_sr TIM21_SR 0 0 @ Clear UIF (Update Interrup Flag).


	pop {pc}

