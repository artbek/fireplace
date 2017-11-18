_nmi_handler:
	movs r6, #120
	bx lr


_hard_fault_handler:
	push {lr}
	bkpt
	pop {pc}


_svcall_handler:
	movs r6, #122
	bx lr


_pendsv_handler:
	movs r6, #123
	bx lr


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

	macros__register_bit_sr TIM21_SR 0 0 @ Clear UIF (Update Interrup Flag).

	pop {pc}

