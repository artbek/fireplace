.thumb
.syntax unified
.cpu cortex-m0plus

.align 2
.global _start

.include "vector_table.s"
.include "STM32L031x6.s"
.include "mappings.s"
.include "constants.s"
.include "macros.s"

.include "interrupt_handlers.s"

.pool @ Literal Pools have limited range and LDR may fail.

.include "display.s"

.pool @ Literal Pools have limited range and LDR may fail.


_start:

	@ Little delay so that switching on feels less abrupt...
	ldr r1, =0x2ffff
	mov r8, r1
	bl _helpers__delay

	@ Enable GPIO clocks...
	macros__register_bit_sr RCC_IOPENR 0 1 @ Port A.
	macros__register_bit_sr RCC_IOPENR 1 1 @ Port B.
	macros__register_value GPIOA_OSPEEDR 0xffffffff


	@ SYSCLK + SysTick...
	bl _helpers__sysclk
	bl _helpers__enable_systick


	@ Init DISPLAY outputs...

	macros__init_row_pin ROW_1
	macros__init_row_pin ROW_2
	macros__init_row_pin ROW_3
	macros__init_row_pin ROW_4
	macros__init_row_pin ROW_5
	macros__init_row_pin ROW_6
	macros__init_row_pin ROW_7

	macros__init_pin COL_1
	macros__init_pin COL_2
	macros__init_pin COL_3
	macros__init_pin COL_4
	macros__init_pin COL_5
	macros__init_pin COL_DECIMAL


	@ Init ON/OFF button...

	macros__register_bit_sr RCC_APB1ENR 28 1 @ Enable clock for PWR.
	macros__register_bit_sr SCR 2 1 @ Enable SLEEPDEEP.
	macros__register_bit_sr PWR_CR 1 1 @ Standby when DeepSleep (PDDS bit).
	macros__register_bit_sr PWR_CSR 8 1 @ WKUP pin 1 (PA0).


	macros__register_value IS_BTN_ONOFF_ARMED 0
	macros__register_value RAND_OFFSET 0

	bl _display__init_blank


	@ TIM21 timer...
	macros__register_bit_sr RCC_APB2ENR 2 1 @ Enable clock for TIM21.
	macros__register_bit_sr TIM21_CR1 6 0 @ Center-aligned mode.
	macros__register_bit_sr TIM21_CR1 5 0 @ Center-aligned mode.
	macros__register_bit_sr TIM21_DIER 0 1 @ UIE (Update Interrupt Enable)
	macros__register_bit_sr NVIC_ISER 20 1 @ Interrupt Enable.
	macros__register_value TIM21_ARR 20 @ ARR.
	macros__register_value TIM21_PSC 20000 @ Prescaler.
	macros__register_value TIM21_CNT 0x0 @ Counter value.
	macros__register_bit_sr TIM21_CR1 0 1 @ CEN (Clock Enable).



b _loop
	.pool @ Literal Pools have limited range and LDR may fail.

_loop:

	bl _display__flush


	@ Progress flame...



	@ ON/OFF Button

	ldr r0, =IS_BTN_ONOFF_ARMED
	ldr r1, [r0]
	cmp r1, #1
	bne _btn_onoff_not_armed_yet

	ldr r0, =BTN_ONOFF
	push {r0}
	bl _helpers__read_pin
	bcc _keep_running
		bl _helpers__go_to_sleep
	_keep_running:

	_btn_onoff_not_armed_yet:

	ldr r0, =BTN_ONOFF
	push {r0}
	bl _helpers__read_pin
	bcs _btn_onoff_not_released_yet
		ldr r0, =IS_BTN_ONOFF_ARMED
		movs r1, #1
		str r1, [r0]
	_btn_onoff_not_released_yet:

b _loop


.include "helpers.s"

b _start

