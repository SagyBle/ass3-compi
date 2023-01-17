%define T_void 				0
%define T_nil 				1
%define T_char 				2
%define T_string 			3
%define T_symbol 			4
%define T_closure 			5
%define T_boolean 			8
%define T_boolean_false 		(T_boolean | 1)
%define T_boolean_true 			(T_boolean | 2)
%define T_number 			16
%define T_rational 			(T_number | 1)
%define T_real 				(T_number | 2)
%define T_collection 			32
%define T_pair 				(T_collection | 1)
%define T_vector 			(T_collection | 2)

%define SOB_CHAR_VALUE(reg) 		byte [reg + 1]
%define SOB_PAIR_CAR(reg)		qword [reg + 1]
%define SOB_PAIR_CDR(reg)		qword [reg + 1 + 8]
%define SOB_STRING_LENGTH(reg)		qword [reg + 1]
%define SOB_VECTOR_LENGTH(reg)		qword [reg + 1]
%define SOB_CLOSURE_ENV(reg)		qword [reg + 1]
%define SOB_CLOSURE_CODE(reg)		qword [reg + 1 + 8]

%define OLD_RDP 			qword [rbp]
%define RET_ADDR 			qword [rbp + 8 * 1]
%define ENV 				qword [rbp + 8 * 2]
%define COUNT 				qword [rbp + 8 * 3]
%define PARAM(n) 			qword [rbp + 8 * (4 + n)]
%define AND_KILL_FRAME(n)		(8 * (2 + n))

%macro ENTER 0
	enter 0, 0
	and rsp, ~15
%endmacro

%macro LEAVE 0
	leave
%endmacro

%macro assert_type 2
        cmp byte [%1], %2
        jne L_error_incorrect_type
%endmacro

%macro assert_type_integer 1
        assert_rational(%1)
        cmp qword [%1 + 1 + 8], 1
        jne L_error_incorrect_type
%endmacro

%define assert_void(reg)		assert_type reg, T_void
%define assert_nil(reg)			assert_type reg, T_nil
%define assert_char(reg)		assert_type reg, T_char
%define assert_string(reg)		assert_type reg, T_string
%define assert_symbol(reg)		assert_type reg, T_symbol
%define assert_closure(reg)		assert_type reg, T_closure
%define assert_boolean(reg)		assert_type reg, T_boolean
%define assert_rational(reg)		assert_type reg, T_rational
%define assert_integer(reg)		assert_type_integer reg
%define assert_real(reg)		assert_type reg, T_real
%define assert_pair(reg)		assert_type reg, T_pair
%define assert_vector(reg)		assert_type reg, T_vector

%define sob_void			(L_constants + 0)
%define sob_nil				(L_constants + 1)
%define sob_boolean_false		(L_constants + 2)
%define sob_boolean_true		(L_constants + 3)
%define sob_char_nul			(L_constants + 4)

%define bytes(n)			(n)
%define kbytes(n) 			(bytes(n) << 10)
%define mbytes(n) 			(kbytes(n) << 10)
%define gbytes(n) 			(mbytes(n) << 10)

section .data
L_constants:
	db T_void
	db T_nil
	db T_boolean_false
	db T_boolean_true
	db T_char, 0x00	; #\x0
	db T_string	; "ranover"
	dq 7
	db 0x72, 0x61, 0x6E, 0x6F, 0x76, 0x65, 0x72
	db T_symbol	; ranover
	dq L_constants + 6
	db T_rational	; 0
	dq 0, 1
	db T_string	; "+"
	dq 1
	db 0x2B
	db T_symbol	; +
	dq L_constants + 48
	db T_string	; "all arguments need ...
	dq 32
	db 0x61, 0x6C, 0x6C, 0x20, 0x61, 0x72, 0x67, 0x75
	db 0x6D, 0x65, 0x6E, 0x74, 0x73, 0x20, 0x6E, 0x65
	db 0x65, 0x64, 0x20, 0x74, 0x6F, 0x20, 0x62, 0x65
	db 0x20, 0x6E, 0x75, 0x6D, 0x62, 0x65, 0x72, 0x73
	db T_string	; "-"
	dq 1
	db 0x2D
	db T_symbol	; -
	dq L_constants + 108
	db T_rational	; 1
	dq 1, 1
	db T_string	; "*"
	dq 1
	db 0x2A
	db T_symbol	; *
	dq L_constants + 144
	db T_string	; "/"
	dq 1
	db 0x2F
	db T_symbol	; /
	dq L_constants + 163
	db T_string	; "generic-comparator"
	dq 18
	db 0x67, 0x65, 0x6E, 0x65, 0x72, 0x69, 0x63, 0x2D
	db 0x63, 0x6F, 0x6D, 0x70, 0x61, 0x72, 0x61, 0x74
	db 0x6F, 0x72
	db T_symbol	; generic-comparator
	dq L_constants + 182
	db T_string	; "all the arguments m...
	dq 33
	db 0x61, 0x6C, 0x6C, 0x20, 0x74, 0x68, 0x65, 0x20
	db 0x61, 0x72, 0x67, 0x75, 0x6D, 0x65, 0x6E, 0x74
	db 0x73, 0x20, 0x6D, 0x75, 0x73, 0x74, 0x20, 0x62
	db 0x65, 0x20, 0x6E, 0x75, 0x6D, 0x62, 0x65, 0x72
	db 0x73
	db T_string	; "make-list"
	dq 9
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x6C, 0x69, 0x73
	db 0x74
	db T_symbol	; make-list
	dq L_constants + 260
	db T_string	; "Usage: (make-list l...
	dq 45
	db 0x55, 0x73, 0x61, 0x67, 0x65, 0x3A, 0x20, 0x28
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x6C, 0x69, 0x73
	db 0x74, 0x20, 0x6C, 0x65, 0x6E, 0x67, 0x74, 0x68
	db 0x20, 0x3F, 0x6F, 0x70, 0x74, 0x69, 0x6F, 0x6E
	db 0x61, 0x6C, 0x2D, 0x69, 0x6E, 0x69, 0x74, 0x2D
	db 0x63, 0x68, 0x61, 0x72, 0x29
	db T_char, 0x41	; #\A
	db T_char, 0x5A	; #\Z
	db T_char, 0x61	; #\a
	db T_char, 0x7A	; #\z
	db T_string	; "make-vector"
	dq 11
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x76, 0x65, 0x63
	db 0x74, 0x6F, 0x72
	db T_symbol	; make-vector
	dq L_constants + 349
	db T_string	; "Usage: (make-vector...
	dq 43
	db 0x55, 0x73, 0x61, 0x67, 0x65, 0x3A, 0x20, 0x28
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x76, 0x65, 0x63
	db 0x74, 0x6F, 0x72, 0x20, 0x73, 0x69, 0x7A, 0x65
	db 0x20, 0x3F, 0x6F, 0x70, 0x74, 0x69, 0x6F, 0x6E
	db 0x61, 0x6C, 0x2D, 0x64, 0x65, 0x66, 0x61, 0x75
	db 0x6C, 0x74, 0x29
	db T_string	; "make-string"
	dq 11
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x73, 0x74, 0x72
	db 0x69, 0x6E, 0x67
	db T_symbol	; make-string
	dq L_constants + 430
	db T_string	; "Usage: (make-string...
	dq 43
	db 0x55, 0x73, 0x61, 0x67, 0x65, 0x3A, 0x20, 0x28
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x73, 0x74, 0x72
	db 0x69, 0x6E, 0x67, 0x20, 0x73, 0x69, 0x7A, 0x65
	db 0x20, 0x3F, 0x6F, 0x70, 0x74, 0x69, 0x6F, 0x6E
	db 0x61, 0x6C, 0x2D, 0x64, 0x65, 0x66, 0x61, 0x75
	db 0x6C, 0x74, 0x29
	db T_rational	; 2
	dq 2, 1
	db T_rational	; 3
	dq 3, 1
	db T_rational	; 4
	dq 4, 1
	db T_rational	; 5
	dq 5, 1
	db T_pair	; (5)
	dq L_constants + 562, L_constants + 1
	db T_pair	; (4 5)
	dq L_constants + 545, L_constants + 579
	db T_pair	; (3 4 5)
	dq L_constants + 528, L_constants + 596
	db T_pair	; (2 3 4 5)
	dq L_constants + 511, L_constants + 613
	db T_pair	; (1 2 3 4 5)
	dq L_constants + 127, L_constants + 630

section .bss
free_var_0:	; location of null?
	resq 1
free_var_1:	; location of pair?
	resq 1
free_var_2:	; location of void?
	resq 1
free_var_3:	; location of char?
	resq 1
free_var_4:	; location of string?
	resq 1
free_var_5:	; location of symbol?
	resq 1
free_var_6:	; location of vector?
	resq 1
free_var_7:	; location of procedure?
	resq 1
free_var_8:	; location of real?
	resq 1
free_var_9:	; location of rational?
	resq 1
free_var_10:	; location of boolean?
	resq 1
free_var_11:	; location of number?
	resq 1
free_var_12:	; location of collection?
	resq 1
free_var_13:	; location of cons
	resq 1
free_var_14:	; location of display-sexpr
	resq 1
free_var_15:	; location of write-char
	resq 1
free_var_16:	; location of car
	resq 1
free_var_17:	; location of cdr
	resq 1
free_var_18:	; location of string-length
	resq 1
free_var_19:	; location of vector-length
	resq 1
free_var_20:	; location of real->integer
	resq 1
free_var_21:	; location of exit
	resq 1
free_var_22:	; location of integer->real
	resq 1
free_var_23:	; location of rational->real
	resq 1
free_var_24:	; location of char->integer
	resq 1
free_var_25:	; location of integer->char
	resq 1
free_var_26:	; location of trng
	resq 1
free_var_27:	; location of zero?
	resq 1
free_var_28:	; location of integer?
	resq 1
free_var_29:	; location of __bin-apply
	resq 1
free_var_30:	; location of __bin-add-rr
	resq 1
free_var_31:	; location of __bin-sub-rr
	resq 1
free_var_32:	; location of __bin-mul-rr
	resq 1
free_var_33:	; location of __bin-div-rr
	resq 1
free_var_34:	; location of __bin-add-qq
	resq 1
free_var_35:	; location of __bin-sub-qq
	resq 1
free_var_36:	; location of __bin-mul-qq
	resq 1
free_var_37:	; location of __bin-div-qq
	resq 1
free_var_38:	; location of error
	resq 1
free_var_39:	; location of __bin-less-than-rr
	resq 1
free_var_40:	; location of __bin-less-than-qq
	resq 1
free_var_41:	; location of __bin-equal-rr
	resq 1
free_var_42:	; location of __bin-equal-qq
	resq 1
free_var_43:	; location of quotient
	resq 1
free_var_44:	; location of remainder
	resq 1
free_var_45:	; location of set-car!
	resq 1
free_var_46:	; location of set-cdr!
	resq 1
free_var_47:	; location of string-ref
	resq 1
free_var_48:	; location of vector-ref
	resq 1
free_var_49:	; location of vector-set!
	resq 1
free_var_50:	; location of string-set!
	resq 1
free_var_51:	; location of make-vector
	resq 1
free_var_52:	; location of make-string
	resq 1
free_var_53:	; location of numerator
	resq 1
free_var_54:	; location of denominator
	resq 1
free_var_55:	; location of eq?
	resq 1
free_var_56:	; location of caar
	resq 1
free_var_57:	; location of cadr
	resq 1
free_var_58:	; location of cdar
	resq 1
free_var_59:	; location of cddr
	resq 1
free_var_60:	; location of caaar
	resq 1
free_var_61:	; location of caadr
	resq 1
free_var_62:	; location of cadar
	resq 1
free_var_63:	; location of caddr
	resq 1
free_var_64:	; location of cdaar
	resq 1
free_var_65:	; location of cdadr
	resq 1
free_var_66:	; location of cddar
	resq 1
free_var_67:	; location of cdddr
	resq 1
free_var_68:	; location of caaaar
	resq 1
free_var_69:	; location of caaadr
	resq 1
free_var_70:	; location of caadar
	resq 1
free_var_71:	; location of caaddr
	resq 1
free_var_72:	; location of cadaar
	resq 1
free_var_73:	; location of cadadr
	resq 1
free_var_74:	; location of caddar
	resq 1
free_var_75:	; location of cadddr
	resq 1
free_var_76:	; location of cdaaar
	resq 1
free_var_77:	; location of cdaadr
	resq 1
free_var_78:	; location of cdadar
	resq 1
free_var_79:	; location of cdaddr
	resq 1
free_var_80:	; location of cddaar
	resq 1
free_var_81:	; location of cddadr
	resq 1
free_var_82:	; location of cdddar
	resq 1
free_var_83:	; location of cddddr
	resq 1
free_var_84:	; location of list?
	resq 1
free_var_85:	; location of list
	resq 1
free_var_86:	; location of not
	resq 1
free_var_87:	; location of fraction?
	resq 1
free_var_88:	; location of list*
	resq 1
free_var_89:	; location of apply
	resq 1
free_var_90:	; location of ormap
	resq 1
free_var_91:	; location of map
	resq 1
free_var_92:	; location of andmap
	resq 1
free_var_93:	; location of reverse
	resq 1
free_var_94:	; location of append
	resq 1
free_var_95:	; location of fold-left
	resq 1
free_var_96:	; location of fold-right
	resq 1
free_var_97:	; location of +
	resq 1
free_var_98:	; location of -
	resq 1
free_var_99:	; location of *
	resq 1
free_var_100:	; location of /
	resq 1
free_var_101:	; location of fact
	resq 1
free_var_102:	; location of <
	resq 1
free_var_103:	; location of <=
	resq 1
free_var_104:	; location of >
	resq 1
free_var_105:	; location of >=
	resq 1
free_var_106:	; location of =
	resq 1
free_var_107:	; location of make-list
	resq 1
free_var_108:	; location of char<?
	resq 1
free_var_109:	; location of char<=?
	resq 1
free_var_110:	; location of char=?
	resq 1
free_var_111:	; location of char>?
	resq 1
free_var_112:	; location of char>=?
	resq 1
free_var_113:	; location of char-downcase
	resq 1
free_var_114:	; location of char-upcase
	resq 1
free_var_115:	; location of char-ci<?
	resq 1
free_var_116:	; location of char-ci<=?
	resq 1
free_var_117:	; location of char-ci=?
	resq 1
free_var_118:	; location of char-ci>?
	resq 1
free_var_119:	; location of char-ci>=?
	resq 1
free_var_120:	; location of string-downcase
	resq 1
free_var_121:	; location of string-upcase
	resq 1
free_var_122:	; location of list->string
	resq 1
free_var_123:	; location of string->list
	resq 1
free_var_124:	; location of string<?
	resq 1
free_var_125:	; location of string<=?
	resq 1
free_var_126:	; location of string=?
	resq 1
free_var_127:	; location of string>=?
	resq 1
free_var_128:	; location of string>?
	resq 1
free_var_129:	; location of string-ci<?
	resq 1
free_var_130:	; location of string-ci<=?
	resq 1
free_var_131:	; location of string-ci=?
	resq 1
free_var_132:	; location of string-ci>=?
	resq 1
free_var_133:	; location of string-ci>?
	resq 1
free_var_134:	; location of length
	resq 1
free_var_135:	; location of list->vector
	resq 1
free_var_136:	; location of vector
	resq 1
free_var_137:	; location of vector->list
	resq 1
free_var_138:	; location of random
	resq 1
free_var_139:	; location of positive?
	resq 1
free_var_140:	; location of negative?
	resq 1
free_var_141:	; location of even?
	resq 1
free_var_142:	; location of odd?
	resq 1
free_var_143:	; location of abs
	resq 1
free_var_144:	; location of equal?
	resq 1
free_var_145:	; location of assoc
	resq 1

extern printf, fprintf, stdout, stderr, fwrite, exit, putchar
global main
section .text
main:
        enter 0, 0
        
	; building closure for null?
	mov rdi, free_var_0
	mov rsi, L_code_ptr_is_null
	call bind_primitive

	; building closure for pair?
	mov rdi, free_var_1
	mov rsi, L_code_ptr_is_pair
	call bind_primitive

	; building closure for void?
	mov rdi, free_var_2
	mov rsi, L_code_ptr_is_void
	call bind_primitive

	; building closure for char?
	mov rdi, free_var_3
	mov rsi, L_code_ptr_is_char
	call bind_primitive

	; building closure for string?
	mov rdi, free_var_4
	mov rsi, L_code_ptr_is_string
	call bind_primitive

	; building closure for symbol?
	mov rdi, free_var_5
	mov rsi, L_code_ptr_is_symbol
	call bind_primitive

	; building closure for vector?
	mov rdi, free_var_6
	mov rsi, L_code_ptr_is_vector
	call bind_primitive

	; building closure for procedure?
	mov rdi, free_var_7
	mov rsi, L_code_ptr_is_closure
	call bind_primitive

	; building closure for real?
	mov rdi, free_var_8
	mov rsi, L_code_ptr_is_real
	call bind_primitive

	; building closure for rational?
	mov rdi, free_var_9
	mov rsi, L_code_ptr_is_rational
	call bind_primitive

	; building closure for boolean?
	mov rdi, free_var_10
	mov rsi, L_code_ptr_is_boolean
	call bind_primitive

	; building closure for number?
	mov rdi, free_var_11
	mov rsi, L_code_ptr_is_number
	call bind_primitive

	; building closure for collection?
	mov rdi, free_var_12
	mov rsi, L_code_ptr_is_collection
	call bind_primitive

	; building closure for cons
	mov rdi, free_var_13
	mov rsi, L_code_ptr_cons
	call bind_primitive

	; building closure for display-sexpr
	mov rdi, free_var_14
	mov rsi, L_code_ptr_display_sexpr
	call bind_primitive

	; building closure for write-char
	mov rdi, free_var_15
	mov rsi, L_code_ptr_write_char
	call bind_primitive

	; building closure for car
	mov rdi, free_var_16
	mov rsi, L_code_ptr_car
	call bind_primitive

	; building closure for cdr
	mov rdi, free_var_17
	mov rsi, L_code_ptr_cdr
	call bind_primitive

	; building closure for string-length
	mov rdi, free_var_18
	mov rsi, L_code_ptr_string_length
	call bind_primitive

	; building closure for vector-length
	mov rdi, free_var_19
	mov rsi, L_code_ptr_vector_length
	call bind_primitive

	; building closure for real->integer
	mov rdi, free_var_20
	mov rsi, L_code_ptr_real_to_integer
	call bind_primitive

	; building closure for exit
	mov rdi, free_var_21
	mov rsi, L_code_ptr_exit
	call bind_primitive

	; building closure for integer->real
	mov rdi, free_var_22
	mov rsi, L_code_ptr_integer_to_real
	call bind_primitive

	; building closure for rational->real
	mov rdi, free_var_23
	mov rsi, L_code_ptr_rational_to_real
	call bind_primitive

	; building closure for char->integer
	mov rdi, free_var_24
	mov rsi, L_code_ptr_char_to_integer
	call bind_primitive

	; building closure for integer->char
	mov rdi, free_var_25
	mov rsi, L_code_ptr_integer_to_char
	call bind_primitive

	; building closure for trng
	mov rdi, free_var_26
	mov rsi, L_code_ptr_trng
	call bind_primitive

	; building closure for zero?
	mov rdi, free_var_27
	mov rsi, L_code_ptr_is_zero
	call bind_primitive

	; building closure for integer?
	mov rdi, free_var_28
	mov rsi, L_code_ptr_is_integer
	call bind_primitive

	; building closure for __bin-apply
	mov rdi, free_var_29
	mov rsi, L_code_ptr_bin_apply
	call bind_primitive

	; building closure for __bin-add-rr
	mov rdi, free_var_30
	mov rsi, L_code_ptr_raw_bin_add_rr
	call bind_primitive

	; building closure for __bin-sub-rr
	mov rdi, free_var_31
	mov rsi, L_code_ptr_raw_bin_sub_rr
	call bind_primitive

	; building closure for __bin-mul-rr
	mov rdi, free_var_32
	mov rsi, L_code_ptr_raw_bin_mul_rr
	call bind_primitive

	; building closure for __bin-div-rr
	mov rdi, free_var_33
	mov rsi, L_code_ptr_raw_bin_div_rr
	call bind_primitive

	; building closure for __bin-add-qq
	mov rdi, free_var_34
	mov rsi, L_code_ptr_raw_bin_add_qq
	call bind_primitive

	; building closure for __bin-sub-qq
	mov rdi, free_var_35
	mov rsi, L_code_ptr_raw_bin_sub_qq
	call bind_primitive

	; building closure for __bin-mul-qq
	mov rdi, free_var_36
	mov rsi, L_code_ptr_raw_bin_mul_qq
	call bind_primitive

	; building closure for __bin-div-qq
	mov rdi, free_var_37
	mov rsi, L_code_ptr_raw_bin_div_qq
	call bind_primitive

	; building closure for error
	mov rdi, free_var_38
	mov rsi, L_code_ptr_error
	call bind_primitive

	; building closure for __bin-less-than-rr
	mov rdi, free_var_39
	mov rsi, L_code_ptr_raw_less_than_rr
	call bind_primitive

	; building closure for __bin-less-than-qq
	mov rdi, free_var_40
	mov rsi, L_code_ptr_raw_less_than_qq
	call bind_primitive

	; building closure for __bin-equal-rr
	mov rdi, free_var_41
	mov rsi, L_code_ptr_raw_equal_rr
	call bind_primitive

	; building closure for __bin-equal-qq
	mov rdi, free_var_42
	mov rsi, L_code_ptr_raw_equal_qq
	call bind_primitive

	; building closure for quotient
	mov rdi, free_var_43
	mov rsi, L_code_ptr_quotient
	call bind_primitive

	; building closure for remainder
	mov rdi, free_var_44
	mov rsi, L_code_ptr_remainder
	call bind_primitive

	; building closure for set-car!
	mov rdi, free_var_45
	mov rsi, L_code_ptr_set_car
	call bind_primitive

	; building closure for set-cdr!
	mov rdi, free_var_46
	mov rsi, L_code_ptr_set_cdr
	call bind_primitive

	; building closure for string-ref
	mov rdi, free_var_47
	mov rsi, L_code_ptr_string_ref
	call bind_primitive

	; building closure for vector-ref
	mov rdi, free_var_48
	mov rsi, L_code_ptr_vector_ref
	call bind_primitive

	; building closure for vector-set!
	mov rdi, free_var_49
	mov rsi, L_code_ptr_vector_set
	call bind_primitive

	; building closure for string-set!
	mov rdi, free_var_50
	mov rsi, L_code_ptr_string_set
	call bind_primitive

	; building closure for make-vector
	mov rdi, free_var_51
	mov rsi, L_code_ptr_make_vector
	call bind_primitive

	; building closure for make-string
	mov rdi, free_var_52
	mov rsi, L_code_ptr_make_string
	call bind_primitive

	; building closure for numerator
	mov rdi, free_var_53
	mov rsi, L_code_ptr_numerator
	call bind_primitive

	; building closure for denominator
	mov rdi, free_var_54
	mov rsi, L_code_ptr_denominator
	call bind_primitive

	; building closure for eq?
	mov rdi, free_var_55
	mov rsi, L_code_ptr_eq
	call bind_primitive

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03ab:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03ab
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03ab
.L_lambda_simple_env_end_03ab:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03ab:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03ab
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03ab
.L_lambda_simple_params_end_03ab:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03ab
	jmp .L_lambda_simple_end_03ab
.L_lambda_simple_code_03ab:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_07f0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_07f0:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_16]
.L_lambda_simple_arity_check_ok_07f1:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0446:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0446
.L_tc_recycle_frame_done_0446:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03ab:	; new closure is in rax
	mov qword [free_var_56], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03ac:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03ac
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03ac
.L_lambda_simple_env_end_03ac:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03ac:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03ac
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03ac
.L_lambda_simple_params_end_03ac:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03ac
	jmp .L_lambda_simple_end_03ac
.L_lambda_simple_code_03ac:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_07f2
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_07f2:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_16]
.L_lambda_simple_arity_check_ok_07f3:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0447:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0447
.L_tc_recycle_frame_done_0447:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03ac:	; new closure is in rax
	mov qword [free_var_57], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03ad:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03ad
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03ad
.L_lambda_simple_env_end_03ad:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03ad:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03ad
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03ad
.L_lambda_simple_params_end_03ad:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03ad
	jmp .L_lambda_simple_end_03ad
.L_lambda_simple_code_03ad:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_07f4
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_07f4:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_17]
.L_lambda_simple_arity_check_ok_07f5:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0448:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0448
.L_tc_recycle_frame_done_0448:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03ad:	; new closure is in rax
	mov qword [free_var_58], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03ae:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03ae
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03ae
.L_lambda_simple_env_end_03ae:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03ae:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03ae
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03ae
.L_lambda_simple_params_end_03ae:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03ae
	jmp .L_lambda_simple_end_03ae
.L_lambda_simple_code_03ae:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_07f6
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_07f6:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_17]
.L_lambda_simple_arity_check_ok_07f7:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0449:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0449
.L_tc_recycle_frame_done_0449:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03ae:	; new closure is in rax
	mov qword [free_var_59], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03af:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03af
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03af
.L_lambda_simple_env_end_03af:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03af:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03af
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03af
.L_lambda_simple_params_end_03af:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03af
	jmp .L_lambda_simple_end_03af
.L_lambda_simple_code_03af:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_07f8
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_07f8:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_56]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_16]
.L_lambda_simple_arity_check_ok_07f9:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_044a:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_044a
.L_tc_recycle_frame_done_044a:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03af:	; new closure is in rax
	mov qword [free_var_60], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03b0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03b0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03b0
.L_lambda_simple_env_end_03b0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03b0:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03b0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03b0
.L_lambda_simple_params_end_03b0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03b0
	jmp .L_lambda_simple_end_03b0
.L_lambda_simple_code_03b0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_07fa
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_07fa:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_57]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_16]
.L_lambda_simple_arity_check_ok_07fb:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_044b:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_044b
.L_tc_recycle_frame_done_044b:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03b0:	; new closure is in rax
	mov qword [free_var_61], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03b1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03b1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03b1
.L_lambda_simple_env_end_03b1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03b1:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03b1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03b1
.L_lambda_simple_params_end_03b1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03b1
	jmp .L_lambda_simple_end_03b1
.L_lambda_simple_code_03b1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_07fc
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_07fc:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_58]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_16]
.L_lambda_simple_arity_check_ok_07fd:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_044c:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_044c
.L_tc_recycle_frame_done_044c:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03b1:	; new closure is in rax
	mov qword [free_var_62], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03b2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03b2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03b2
.L_lambda_simple_env_end_03b2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03b2:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03b2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03b2
.L_lambda_simple_params_end_03b2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03b2
	jmp .L_lambda_simple_end_03b2
.L_lambda_simple_code_03b2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_07fe
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_07fe:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_59]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_16]
.L_lambda_simple_arity_check_ok_07ff:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_044d:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_044d
.L_tc_recycle_frame_done_044d:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03b2:	; new closure is in rax
	mov qword [free_var_63], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03b3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03b3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03b3
.L_lambda_simple_env_end_03b3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03b3:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03b3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03b3
.L_lambda_simple_params_end_03b3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03b3
	jmp .L_lambda_simple_end_03b3
.L_lambda_simple_code_03b3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0800
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0800:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_56]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_17]
.L_lambda_simple_arity_check_ok_0801:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_044e:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_044e
.L_tc_recycle_frame_done_044e:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03b3:	; new closure is in rax
	mov qword [free_var_64], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03b4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03b4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03b4
.L_lambda_simple_env_end_03b4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03b4:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03b4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03b4
.L_lambda_simple_params_end_03b4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03b4
	jmp .L_lambda_simple_end_03b4
.L_lambda_simple_code_03b4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0802
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0802:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_57]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_17]
.L_lambda_simple_arity_check_ok_0803:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_044f:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_044f
.L_tc_recycle_frame_done_044f:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03b4:	; new closure is in rax
	mov qword [free_var_65], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03b5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03b5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03b5
.L_lambda_simple_env_end_03b5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03b5:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03b5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03b5
.L_lambda_simple_params_end_03b5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03b5
	jmp .L_lambda_simple_end_03b5
.L_lambda_simple_code_03b5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0804
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0804:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_58]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_17]
.L_lambda_simple_arity_check_ok_0805:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0450:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0450
.L_tc_recycle_frame_done_0450:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03b5:	; new closure is in rax
	mov qword [free_var_66], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03b6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03b6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03b6
.L_lambda_simple_env_end_03b6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03b6:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03b6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03b6
.L_lambda_simple_params_end_03b6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03b6
	jmp .L_lambda_simple_end_03b6
.L_lambda_simple_code_03b6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0806
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0806:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_59]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_17]
.L_lambda_simple_arity_check_ok_0807:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0451:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0451
.L_tc_recycle_frame_done_0451:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03b6:	; new closure is in rax
	mov qword [free_var_67], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03b7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03b7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03b7
.L_lambda_simple_env_end_03b7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03b7:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03b7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03b7
.L_lambda_simple_params_end_03b7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03b7
	jmp .L_lambda_simple_end_03b7
.L_lambda_simple_code_03b7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0808
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0808:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_56]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_56]
.L_lambda_simple_arity_check_ok_0809:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0452:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0452
.L_tc_recycle_frame_done_0452:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03b7:	; new closure is in rax
	mov qword [free_var_68], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03b8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03b8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03b8
.L_lambda_simple_env_end_03b8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03b8:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03b8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03b8
.L_lambda_simple_params_end_03b8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03b8
	jmp .L_lambda_simple_end_03b8
.L_lambda_simple_code_03b8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_080a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_080a:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_57]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_56]
.L_lambda_simple_arity_check_ok_080b:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0453:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0453
.L_tc_recycle_frame_done_0453:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03b8:	; new closure is in rax
	mov qword [free_var_69], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03b9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03b9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03b9
.L_lambda_simple_env_end_03b9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03b9:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03b9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03b9
.L_lambda_simple_params_end_03b9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03b9
	jmp .L_lambda_simple_end_03b9
.L_lambda_simple_code_03b9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_080c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_080c:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_58]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_56]
.L_lambda_simple_arity_check_ok_080d:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0454:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0454
.L_tc_recycle_frame_done_0454:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03b9:	; new closure is in rax
	mov qword [free_var_70], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03ba:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03ba
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03ba
.L_lambda_simple_env_end_03ba:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03ba:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03ba
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03ba
.L_lambda_simple_params_end_03ba:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03ba
	jmp .L_lambda_simple_end_03ba
.L_lambda_simple_code_03ba:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_080e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_080e:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_59]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_56]
.L_lambda_simple_arity_check_ok_080f:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0455:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0455
.L_tc_recycle_frame_done_0455:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03ba:	; new closure is in rax
	mov qword [free_var_71], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03bb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03bb
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03bb
.L_lambda_simple_env_end_03bb:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03bb:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03bb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03bb
.L_lambda_simple_params_end_03bb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03bb
	jmp .L_lambda_simple_end_03bb
.L_lambda_simple_code_03bb:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0810
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0810:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_56]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_57]
.L_lambda_simple_arity_check_ok_0811:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0456:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0456
.L_tc_recycle_frame_done_0456:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03bb:	; new closure is in rax
	mov qword [free_var_72], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03bc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03bc
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03bc
.L_lambda_simple_env_end_03bc:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03bc:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03bc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03bc
.L_lambda_simple_params_end_03bc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03bc
	jmp .L_lambda_simple_end_03bc
.L_lambda_simple_code_03bc:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0812
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0812:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_57]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_57]
.L_lambda_simple_arity_check_ok_0813:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0457:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0457
.L_tc_recycle_frame_done_0457:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03bc:	; new closure is in rax
	mov qword [free_var_73], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03bd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03bd
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03bd
.L_lambda_simple_env_end_03bd:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03bd:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03bd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03bd
.L_lambda_simple_params_end_03bd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03bd
	jmp .L_lambda_simple_end_03bd
.L_lambda_simple_code_03bd:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0814
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0814:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_58]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_57]
.L_lambda_simple_arity_check_ok_0815:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0458:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0458
.L_tc_recycle_frame_done_0458:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03bd:	; new closure is in rax
	mov qword [free_var_74], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03be:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03be
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03be
.L_lambda_simple_env_end_03be:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03be:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03be
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03be
.L_lambda_simple_params_end_03be:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03be
	jmp .L_lambda_simple_end_03be
.L_lambda_simple_code_03be:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0816
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0816:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_59]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_57]
.L_lambda_simple_arity_check_ok_0817:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0459:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0459
.L_tc_recycle_frame_done_0459:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03be:	; new closure is in rax
	mov qword [free_var_75], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03bf:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03bf
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03bf
.L_lambda_simple_env_end_03bf:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03bf:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03bf
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03bf
.L_lambda_simple_params_end_03bf:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03bf
	jmp .L_lambda_simple_end_03bf
.L_lambda_simple_code_03bf:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0818
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0818:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_56]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_58]
.L_lambda_simple_arity_check_ok_0819:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_045a:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_045a
.L_tc_recycle_frame_done_045a:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03bf:	; new closure is in rax
	mov qword [free_var_76], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03c0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03c0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03c0
.L_lambda_simple_env_end_03c0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03c0:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03c0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03c0
.L_lambda_simple_params_end_03c0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03c0
	jmp .L_lambda_simple_end_03c0
.L_lambda_simple_code_03c0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_081a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_081a:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_57]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_58]
.L_lambda_simple_arity_check_ok_081b:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_045b:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_045b
.L_tc_recycle_frame_done_045b:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03c0:	; new closure is in rax
	mov qword [free_var_77], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03c1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03c1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03c1
.L_lambda_simple_env_end_03c1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03c1:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03c1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03c1
.L_lambda_simple_params_end_03c1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03c1
	jmp .L_lambda_simple_end_03c1
.L_lambda_simple_code_03c1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_081c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_081c:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_58]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_58]
.L_lambda_simple_arity_check_ok_081d:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_045c:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_045c
.L_tc_recycle_frame_done_045c:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03c1:	; new closure is in rax
	mov qword [free_var_78], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03c2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03c2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03c2
.L_lambda_simple_env_end_03c2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03c2:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03c2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03c2
.L_lambda_simple_params_end_03c2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03c2
	jmp .L_lambda_simple_end_03c2
.L_lambda_simple_code_03c2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_081e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_081e:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_59]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_58]
.L_lambda_simple_arity_check_ok_081f:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_045d:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_045d
.L_tc_recycle_frame_done_045d:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03c2:	; new closure is in rax
	mov qword [free_var_79], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03c3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03c3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03c3
.L_lambda_simple_env_end_03c3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03c3:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03c3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03c3
.L_lambda_simple_params_end_03c3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03c3
	jmp .L_lambda_simple_end_03c3
.L_lambda_simple_code_03c3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0820
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0820:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_56]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_59]
.L_lambda_simple_arity_check_ok_0821:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_045e:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_045e
.L_tc_recycle_frame_done_045e:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03c3:	; new closure is in rax
	mov qword [free_var_80], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03c4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03c4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03c4
.L_lambda_simple_env_end_03c4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03c4:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03c4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03c4
.L_lambda_simple_params_end_03c4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03c4
	jmp .L_lambda_simple_end_03c4
.L_lambda_simple_code_03c4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0822
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0822:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_57]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_59]
.L_lambda_simple_arity_check_ok_0823:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_045f:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_045f
.L_tc_recycle_frame_done_045f:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03c4:	; new closure is in rax
	mov qword [free_var_81], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03c5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03c5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03c5
.L_lambda_simple_env_end_03c5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03c5:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03c5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03c5
.L_lambda_simple_params_end_03c5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03c5
	jmp .L_lambda_simple_end_03c5
.L_lambda_simple_code_03c5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0824
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0824:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_58]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_59]
.L_lambda_simple_arity_check_ok_0825:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0460:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0460
.L_tc_recycle_frame_done_0460:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03c5:	; new closure is in rax
	mov qword [free_var_82], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03c6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03c6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03c6
.L_lambda_simple_env_end_03c6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03c6:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03c6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03c6
.L_lambda_simple_params_end_03c6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03c6
	jmp .L_lambda_simple_end_03c6
.L_lambda_simple_code_03c6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0826
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0826:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_59]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_59]
.L_lambda_simple_arity_check_ok_0827:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0461:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0461
.L_tc_recycle_frame_done_0461:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03c6:	; new closure is in rax
	mov qword [free_var_83], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03c7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03c7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03c7
.L_lambda_simple_env_end_03c7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03c7:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03c7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03c7
.L_lambda_simple_params_end_03c7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03c7
	jmp .L_lambda_simple_end_03c7
.L_lambda_simple_code_03c7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0828
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0828:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	jne .L_or_end_0049
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_1]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0236
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_84]
.L_lambda_simple_arity_check_ok_0829:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0462:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0462
.L_tc_recycle_frame_done_0462:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0236
	.L_if_else_0236:
		mov rax, qword (L_constants + 2)
	.L_if_end_0236:
.L_or_end_0049:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03c7:	; new closure is in rax
	mov qword [free_var_84], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_008b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_008b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_008b
.L_lambda_opt_env_end_008b:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_019f:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_019f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_019f
.L_lambda_opt_params_end_019f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_008b
	jmp .L_lambda_opt_end_008b
.L_lambda_opt_code_008b:
mov r10, qword [rsp+8*2]
cmp r10, 0
je .L_lambda_opt_arity_check_exact_008b
cmp r10, 0
jg .L_lambda_opt_arity_check_more_008b
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_008b:
sub rsp, 8
mov rdx, 3+0
mov qword rbx, rsp
.L_lambda_opt_params_loop_01a0:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01a0
jmp .L_lambda_opt_params_loop_01a0
.L_lambda_opt_params_end_01a0:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_008b
.L_lambda_opt_arity_check_more_008b:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 0
.L_lambda_opt_stack_shrink_loop_008b:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_008b
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_008b
.L_lambda_opt_stack_shrink_loop_exit_008b:
mov [rsp+8*(2+1)], rax
mov r10, 1
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+1)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01a1:
cmp r9, 0
je .L_lambda_opt_params_end_01a1
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01a1
.L_lambda_opt_params_end_01a1:
add rsp, r15
.L_lambda_opt_stack_adjusted_008b:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 32]
leave
mov r9, [rbp]
ret 8 * (3 + 0)
.L_lambda_opt_end_008b:	; new closure is in rax
	mov qword [free_var_85], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03c8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03c8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03c8
.L_lambda_simple_env_end_03c8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03c8:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03c8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03c8
.L_lambda_simple_params_end_03c8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03c8
	jmp .L_lambda_simple_end_03c8
.L_lambda_simple_code_03c8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_082a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_082a:
	enter 0, 0
mov rax, qword [rbp + 32]
	cmp rax, sob_boolean_false
	je .L_if_else_0237
	mov rax, qword (L_constants + 2)
	jmp .L_if_end_0237
	.L_if_else_0237:
		mov rax, qword (L_constants + 3)
	.L_if_end_0237:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03c8:	; new closure is in rax
	mov qword [free_var_86], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03c9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03c9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03c9
.L_lambda_simple_env_end_03c9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03c9:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03c9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03c9
.L_lambda_simple_params_end_03c9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03c9
	jmp .L_lambda_simple_end_03c9
.L_lambda_simple_code_03c9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_082b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_082b:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0238
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_28]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_86]
.L_lambda_simple_arity_check_ok_082c:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0463:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0463
.L_tc_recycle_frame_done_0463:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0238
	.L_if_else_0238:
		mov rax, qword (L_constants + 2)
	.L_if_end_0238:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03c9:	; new closure is in rax
	mov qword [free_var_87], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03ca:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03ca
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03ca
.L_lambda_simple_env_end_03ca:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03ca:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03ca
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03ca
.L_lambda_simple_params_end_03ca:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03ca
	jmp .L_lambda_simple_end_03ca
.L_lambda_simple_code_03ca:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_082d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_082d:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03cb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03cb
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03cb
.L_lambda_simple_env_end_03cb:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03cb:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03cb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03cb
.L_lambda_simple_params_end_03cb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03cb
	jmp .L_lambda_simple_end_03cb
.L_lambda_simple_code_03cb:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_082e
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_082e:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0239
mov rax, qword [rbp + 32]
	jmp .L_if_end_0239
	.L_if_else_0239:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_13]
.L_lambda_simple_arity_check_ok_082f:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0464:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0464
.L_tc_recycle_frame_done_0464:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0239:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03cb:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_008c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_008c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_008c
.L_lambda_opt_env_end_008c:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01a2:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01a2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01a2
.L_lambda_opt_params_end_01a2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_008c
	jmp .L_lambda_opt_end_008c
.L_lambda_opt_code_008c:
mov r10, qword [rsp+8*2]
cmp r10, 1
je .L_lambda_opt_arity_check_exact_008c
cmp r10, 1
jg .L_lambda_opt_arity_check_more_008c
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_008c:
sub rsp, 8
mov rdx, 3+1
mov qword rbx, rsp
.L_lambda_opt_params_loop_01a3:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01a3
jmp .L_lambda_opt_params_loop_01a3
.L_lambda_opt_params_end_01a3:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_008c
.L_lambda_opt_arity_check_more_008c:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 1
.L_lambda_opt_stack_shrink_loop_008c:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_008c
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_008c
.L_lambda_opt_stack_shrink_loop_exit_008c:
mov [rsp+8*(2+2)], rax
mov r10, 2
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+2)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01a4:
cmp r9, 0
je .L_lambda_opt_params_end_01a4
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01a4
.L_lambda_opt_params_end_01a4:
add rsp, r15
.L_lambda_opt_stack_adjusted_008c:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_0830:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0465:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0465
.L_tc_recycle_frame_done_0465:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 1)
.L_lambda_opt_end_008c:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03ca:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_88], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03cc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03cc
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03cc
.L_lambda_simple_env_end_03cc:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03cc:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03cc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03cc
.L_lambda_simple_params_end_03cc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03cc
	jmp .L_lambda_simple_end_03cc
.L_lambda_simple_code_03cc:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0831
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0831:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03cd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03cd
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03cd
.L_lambda_simple_env_end_03cd:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03cd:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03cd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03cd
.L_lambda_simple_params_end_03cd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03cd
	jmp .L_lambda_simple_end_03cd
.L_lambda_simple_code_03cd:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0832
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0832:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_1]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_023a
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_13]
.L_lambda_simple_arity_check_ok_0833:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0466:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0466
.L_tc_recycle_frame_done_0466:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_023a
	.L_if_else_023a:
	mov rax, qword [rbp + 32]
	.L_if_end_023a:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03cd:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_008d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_008d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_008d
.L_lambda_opt_env_end_008d:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01a5:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01a5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01a5
.L_lambda_opt_params_end_01a5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_008d
	jmp .L_lambda_opt_end_008d
.L_lambda_opt_code_008d:
mov r10, qword [rsp+8*2]
cmp r10, 1
je .L_lambda_opt_arity_check_exact_008d
cmp r10, 1
jg .L_lambda_opt_arity_check_more_008d
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_008d:
sub rsp, 8
mov rdx, 3+1
mov qword rbx, rsp
.L_lambda_opt_params_loop_01a6:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01a6
jmp .L_lambda_opt_params_loop_01a6
.L_lambda_opt_params_end_01a6:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_008d
.L_lambda_opt_arity_check_more_008d:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 1
.L_lambda_opt_stack_shrink_loop_008d:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_008d
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_008d
.L_lambda_opt_stack_shrink_loop_exit_008d:
mov [rsp+8*(2+2)], rax
mov r10, 2
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+2)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01a7:
cmp r9, 0
je .L_lambda_opt_params_end_01a7
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01a7
.L_lambda_opt_params_end_01a7:
add rsp, r15
.L_lambda_opt_stack_adjusted_008d:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_29]
.L_lambda_simple_arity_check_ok_0834:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0467:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0467
.L_tc_recycle_frame_done_0467:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 1)
.L_lambda_opt_end_008d:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03cc:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_89], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_008e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_008e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_008e
.L_lambda_opt_env_end_008e:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01a8:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_01a8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01a8
.L_lambda_opt_params_end_01a8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_008e
	jmp .L_lambda_opt_end_008e
.L_lambda_opt_code_008e:
mov r10, qword [rsp+8*2]
cmp r10, 1
je .L_lambda_opt_arity_check_exact_008e
cmp r10, 1
jg .L_lambda_opt_arity_check_more_008e
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_008e:
sub rsp, 8
mov rdx, 3+1
mov qword rbx, rsp
.L_lambda_opt_params_loop_01a9:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01a9
jmp .L_lambda_opt_params_loop_01a9
.L_lambda_opt_params_end_01a9:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_008e
.L_lambda_opt_arity_check_more_008e:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 1
.L_lambda_opt_stack_shrink_loop_008e:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_008e
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_008e
.L_lambda_opt_stack_shrink_loop_exit_008e:
mov [rsp+8*(2+2)], rax
mov r10, 2
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+2)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01aa:
cmp r9, 0
je .L_lambda_opt_params_end_01aa
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01aa
.L_lambda_opt_params_end_01aa:
add rsp, r15
.L_lambda_opt_stack_adjusted_008e:
mov r9, [rbp]
enter 0, 0
	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03ce:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03ce
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03ce
.L_lambda_simple_env_end_03ce:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03ce:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_03ce
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03ce
.L_lambda_simple_params_end_03ce:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03ce
	jmp .L_lambda_simple_end_03ce
.L_lambda_simple_code_03ce:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0835
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0835:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03cf:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_03cf
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03cf
.L_lambda_simple_env_end_03cf:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03cf:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03cf
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03cf
.L_lambda_simple_params_end_03cf:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03cf
	jmp .L_lambda_simple_end_03cf
.L_lambda_simple_code_03cf:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0836
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0836:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_1]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_023b
mov rax, qword [rbp + 32]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	jne .L_or_end_004a
mov rax, qword [rbp + 32]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_0837:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0468:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0468
.L_tc_recycle_frame_done_0468:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
.L_or_end_004a:
	jmp .L_if_end_023b
	.L_if_else_023b:
		mov rax, qword (L_constants + 2)
	.L_if_end_023b:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03cf:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
	push rax
	push 1
mov rax, qword [rbp + 32]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_0838:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0469:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0469
.L_tc_recycle_frame_done_0469:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03ce:	; new closure is in rax
.L_lambda_simple_arity_check_ok_0839:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_046a:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_046a
.L_tc_recycle_frame_done_046a:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 1)
.L_lambda_opt_end_008e:	; new closure is in rax
	mov qword [free_var_90], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_008f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_008f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_008f
.L_lambda_opt_env_end_008f:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01ab:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_01ab
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01ab
.L_lambda_opt_params_end_01ab:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_008f
	jmp .L_lambda_opt_end_008f
.L_lambda_opt_code_008f:
mov r10, qword [rsp+8*2]
cmp r10, 1
je .L_lambda_opt_arity_check_exact_008f
cmp r10, 1
jg .L_lambda_opt_arity_check_more_008f
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_008f:
sub rsp, 8
mov rdx, 3+1
mov qword rbx, rsp
.L_lambda_opt_params_loop_01ac:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01ac
jmp .L_lambda_opt_params_loop_01ac
.L_lambda_opt_params_end_01ac:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_008f
.L_lambda_opt_arity_check_more_008f:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 1
.L_lambda_opt_stack_shrink_loop_008f:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_008f
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_008f
.L_lambda_opt_stack_shrink_loop_exit_008f:
mov [rsp+8*(2+2)], rax
mov r10, 2
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+2)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01ad:
cmp r9, 0
je .L_lambda_opt_params_end_01ad
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01ad
.L_lambda_opt_params_end_01ad:
add rsp, r15
.L_lambda_opt_stack_adjusted_008f:
mov r9, [rbp]
enter 0, 0
	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03d0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03d0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03d0
.L_lambda_simple_env_end_03d0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03d0:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_03d0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03d0
.L_lambda_simple_params_end_03d0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03d0
	jmp .L_lambda_simple_end_03d0
.L_lambda_simple_code_03d0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_083a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_083a:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03d1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_03d1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03d1
.L_lambda_simple_env_end_03d1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03d1:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03d1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03d1
.L_lambda_simple_params_end_03d1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03d1
	jmp .L_lambda_simple_end_03d1
.L_lambda_simple_code_03d1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_083b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_083b:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	jne .L_or_end_004b
mov rax, qword [rbp + 32]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_023c
mov rax, qword [rbp + 32]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_083c:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_046b:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_046b
.L_tc_recycle_frame_done_046b:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_023c
	.L_if_else_023c:
		mov rax, qword (L_constants + 2)
	.L_if_end_023c:
.L_or_end_004b:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03d1:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
	push rax
	push 1
mov rax, qword [rbp + 32]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_083d:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_046c:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_046c
.L_tc_recycle_frame_done_046c:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03d0:	; new closure is in rax
.L_lambda_simple_arity_check_ok_083e:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_046d:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_046d
.L_tc_recycle_frame_done_046d:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 1)
.L_lambda_opt_end_008f:	; new closure is in rax
	mov qword [free_var_92], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 22)
	push rax
	mov rax, qword (L_constants + 22)
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03d2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03d2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03d2
.L_lambda_simple_env_end_03d2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03d2:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03d2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03d2
.L_lambda_simple_params_end_03d2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03d2
	jmp .L_lambda_simple_end_03d2
.L_lambda_simple_code_03d2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_083f
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_083f:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
mov rax, qword [rbp + 40]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 40], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03d3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03d3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03d3
.L_lambda_simple_env_end_03d3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03d3:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_03d3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03d3
.L_lambda_simple_params_end_03d3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03d3
	jmp .L_lambda_simple_end_03d3
.L_lambda_simple_code_03d3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0840
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0840:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_023d
	mov rax, qword (L_constants + 1)
	jmp .L_if_end_023d
	.L_if_else_023d:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_13]
.L_lambda_simple_arity_check_ok_0841:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_046e:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_046e
.L_tc_recycle_frame_done_046e:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_023d:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03d3:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03d4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03d4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03d4
.L_lambda_simple_env_end_03d4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03d4:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_03d4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03d4
.L_lambda_simple_params_end_03d4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03d4
	jmp .L_lambda_simple_end_03d4
.L_lambda_simple_code_03d4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0842
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0842:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_023e
	mov rax, qword (L_constants + 1)
	jmp .L_if_end_023e
	.L_if_else_023e:
	mov rax, qword [rbp + 40]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
	mov rax, qword [rax]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 40]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_89]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_13]
.L_lambda_simple_arity_check_ok_0843:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_046f:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_046f
.L_tc_recycle_frame_done_046f:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_023e:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03d4:	; new closure is in rax
push rax
mov rax, qword [rbp + 40]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0090:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0090
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0090
.L_lambda_opt_env_end_0090:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01ae:	; copy params
	cmp rsi, 2
	je .L_lambda_opt_params_end_01ae
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01ae
.L_lambda_opt_params_end_01ae:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0090
	jmp .L_lambda_opt_end_0090
.L_lambda_opt_code_0090:
mov r10, qword [rsp+8*2]
cmp r10, 1
je .L_lambda_opt_arity_check_exact_0090
cmp r10, 1
jg .L_lambda_opt_arity_check_more_0090
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0090:
sub rsp, 8
mov rdx, 3+1
mov qword rbx, rsp
.L_lambda_opt_params_loop_01af:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01af
jmp .L_lambda_opt_params_loop_01af
.L_lambda_opt_params_end_01af:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_0090
.L_lambda_opt_arity_check_more_0090:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 1
.L_lambda_opt_stack_shrink_loop_0090:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_0090
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_0090
.L_lambda_opt_stack_shrink_loop_exit_0090:
mov [rsp+8*(2+2)], rax
mov r10, 2
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+2)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01b0:
cmp r9, 0
je .L_lambda_opt_params_end_01b0
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01b0
.L_lambda_opt_params_end_01b0:
add rsp, r15
.L_lambda_opt_stack_adjusted_0090:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_023f
	mov rax, qword (L_constants + 1)
	jmp .L_if_end_023f
	.L_if_else_023f:
	mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_0844:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0470:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0470
.L_tc_recycle_frame_done_0470:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_023f:
leave
mov r9, [rbp]
ret 8 * (3 + 1)
.L_lambda_opt_end_0090:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03d2:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_91], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03d5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03d5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03d5
.L_lambda_simple_env_end_03d5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03d5:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03d5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03d5
.L_lambda_simple_params_end_03d5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03d5
	jmp .L_lambda_simple_end_03d5
.L_lambda_simple_code_03d5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0845
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0845:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03d6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03d6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03d6
.L_lambda_simple_env_end_03d6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03d6:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03d6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03d6
.L_lambda_simple_params_end_03d6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03d6
	jmp .L_lambda_simple_end_03d6
.L_lambda_simple_code_03d6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0846
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0846:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0240
mov rax, qword [rbp + 40]
	jmp .L_if_end_0240
	.L_if_else_0240:
	mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_13]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_0847:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0471:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0471
.L_tc_recycle_frame_done_0471:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0240:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03d6:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03d7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03d7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03d7
.L_lambda_simple_env_end_03d7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03d7:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03d7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03d7
.L_lambda_simple_params_end_03d7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03d7
	jmp .L_lambda_simple_end_03d7
.L_lambda_simple_code_03d7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0848
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0848:
	enter 0, 0
	mov rax, qword (L_constants + 1)
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_0849:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0472:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0472
.L_tc_recycle_frame_done_0472:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03d7:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03d5:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_93], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 22)
	push rax
	mov rax, qword (L_constants + 22)
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03d8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03d8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03d8
.L_lambda_simple_env_end_03d8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03d8:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03d8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03d8
.L_lambda_simple_params_end_03d8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03d8
	jmp .L_lambda_simple_end_03d8
.L_lambda_simple_code_03d8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_084a
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_084a:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
mov rax, qword [rbp + 40]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 40], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03d9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03d9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03d9
.L_lambda_simple_env_end_03d9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03d9:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_03d9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03d9
.L_lambda_simple_params_end_03d9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03d9
	jmp .L_lambda_simple_end_03d9
.L_lambda_simple_code_03d9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_084b
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_084b:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0241
mov rax, qword [rbp + 32]
	jmp .L_if_end_0241
	.L_if_else_0241:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_084c:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0473:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0473
.L_tc_recycle_frame_done_0473:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0241:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03d9:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03da:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03da
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03da
.L_lambda_simple_env_end_03da:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03da:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_03da
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03da
.L_lambda_simple_params_end_03da:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03da
	jmp .L_lambda_simple_end_03da
.L_lambda_simple_code_03da:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_084d
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_084d:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0242
mov rax, qword [rbp + 40]
	jmp .L_if_end_0242
	.L_if_else_0242:
	mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
	mov rax, qword [rax]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_13]
.L_lambda_simple_arity_check_ok_084e:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0474:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0474
.L_tc_recycle_frame_done_0474:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0242:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03da:	; new closure is in rax
push rax
mov rax, qword [rbp + 40]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0091:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0091
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0091
.L_lambda_opt_env_end_0091:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01b1:	; copy params
	cmp rsi, 2
	je .L_lambda_opt_params_end_01b1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01b1
.L_lambda_opt_params_end_01b1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0091
	jmp .L_lambda_opt_end_0091
.L_lambda_opt_code_0091:
mov r10, qword [rsp+8*2]
cmp r10, 0
je .L_lambda_opt_arity_check_exact_0091
cmp r10, 0
jg .L_lambda_opt_arity_check_more_0091
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0091:
sub rsp, 8
mov rdx, 3+0
mov qword rbx, rsp
.L_lambda_opt_params_loop_01b2:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01b2
jmp .L_lambda_opt_params_loop_01b2
.L_lambda_opt_params_end_01b2:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_0091
.L_lambda_opt_arity_check_more_0091:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 0
.L_lambda_opt_stack_shrink_loop_0091:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_0091
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_0091
.L_lambda_opt_stack_shrink_loop_exit_0091:
mov [rsp+8*(2+1)], rax
mov r10, 1
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+1)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01b3:
cmp r9, 0
je .L_lambda_opt_params_end_01b3
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01b3
.L_lambda_opt_params_end_01b3:
add rsp, r15
.L_lambda_opt_stack_adjusted_0091:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0243
	mov rax, qword (L_constants + 1)
	jmp .L_if_end_0243
	.L_if_else_0243:
	mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_084f:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0475:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0475
.L_tc_recycle_frame_done_0475:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0243:
leave
mov r9, [rbp]
ret 8 * (3 + 0)
.L_lambda_opt_end_0091:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03d8:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_94], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03db:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03db
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03db
.L_lambda_simple_env_end_03db:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03db:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03db
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03db
.L_lambda_simple_params_end_03db:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03db
	jmp .L_lambda_simple_end_03db
.L_lambda_simple_code_03db:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0850
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0850:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03dc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03dc
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03dc
.L_lambda_simple_env_end_03dc:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03dc:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03dc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03dc
.L_lambda_simple_params_end_03dc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03dc
	jmp .L_lambda_simple_end_03dc
.L_lambda_simple_code_03dc:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_0851
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0851:
	enter 0, 0
mov rax, qword [rbp + 48]
	push rax
	mov rax, qword [free_var_0]
	push rax
	push 2
	mov rax, qword [free_var_90]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0244
mov rax, qword [rbp + 40]
	jmp .L_if_end_0244
	.L_if_else_0244:
	mov rax, qword [rbp + 48]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 48]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 3
	mov rax, qword [free_var_89]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 3
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_0852:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0476:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0476
.L_tc_recycle_frame_done_0476:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0244:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_03dc:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0092:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0092
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0092
.L_lambda_opt_env_end_0092:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01b4:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01b4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01b4
.L_lambda_opt_params_end_01b4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0092
	jmp .L_lambda_opt_end_0092
.L_lambda_opt_code_0092:
mov r10, qword [rsp+8*2]
cmp r10, 2
je .L_lambda_opt_arity_check_exact_0092
cmp r10, 2
jg .L_lambda_opt_arity_check_more_0092
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0092:
sub rsp, 8
mov rdx, 3+2
mov qword rbx, rsp
.L_lambda_opt_params_loop_01b5:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01b5
jmp .L_lambda_opt_params_loop_01b5
.L_lambda_opt_params_end_01b5:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_0092
.L_lambda_opt_arity_check_more_0092:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 2
.L_lambda_opt_stack_shrink_loop_0092:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_0092
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_0092
.L_lambda_opt_stack_shrink_loop_exit_0092:
mov [rsp+8*(2+3)], rax
mov r10, 3
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+3)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01b6:
cmp r9, 0
je .L_lambda_opt_params_end_01b6
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01b6
.L_lambda_opt_params_end_01b6:
add rsp, r15
.L_lambda_opt_stack_adjusted_0092:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 48]
	push rax
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 3
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_0853:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0477:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0477
.L_tc_recycle_frame_done_0477:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 2)
.L_lambda_opt_end_0092:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03db:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_95], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03dd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03dd
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03dd
.L_lambda_simple_env_end_03dd:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03dd:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03dd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03dd
.L_lambda_simple_params_end_03dd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03dd
	jmp .L_lambda_simple_end_03dd
.L_lambda_simple_code_03dd:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0854
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0854:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03de:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03de
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03de
.L_lambda_simple_env_end_03de:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03de:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03de
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03de
.L_lambda_simple_params_end_03de:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03de
	jmp .L_lambda_simple_end_03de
.L_lambda_simple_code_03de:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_0855
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0855:
	enter 0, 0
mov rax, qword [rbp + 48]
	push rax
	mov rax, qword [free_var_0]
	push rax
	push 2
	mov rax, qword [free_var_90]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0245
mov rax, qword [rbp + 40]
	jmp .L_if_end_0245
	.L_if_else_0245:
		mov rax, qword (L_constants + 1)
	push rax
mov rax, qword [rbp + 48]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 3
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_13]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 48]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_94]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_89]
.L_lambda_simple_arity_check_ok_0856:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0478:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0478
.L_tc_recycle_frame_done_0478:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0245:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_03de:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0093:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0093
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0093
.L_lambda_opt_env_end_0093:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01b7:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01b7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01b7
.L_lambda_opt_params_end_01b7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0093
	jmp .L_lambda_opt_end_0093
.L_lambda_opt_code_0093:
mov r10, qword [rsp+8*2]
cmp r10, 2
je .L_lambda_opt_arity_check_exact_0093
cmp r10, 2
jg .L_lambda_opt_arity_check_more_0093
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0093:
sub rsp, 8
mov rdx, 3+2
mov qword rbx, rsp
.L_lambda_opt_params_loop_01b8:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01b8
jmp .L_lambda_opt_params_loop_01b8
.L_lambda_opt_params_end_01b8:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_0093
.L_lambda_opt_arity_check_more_0093:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 2
.L_lambda_opt_stack_shrink_loop_0093:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_0093
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_0093
.L_lambda_opt_stack_shrink_loop_exit_0093:
mov [rsp+8*(2+3)], rax
mov r10, 3
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+3)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01b9:
cmp r9, 0
je .L_lambda_opt_params_end_01b9
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01b9
.L_lambda_opt_params_end_01b9:
add rsp, r15
.L_lambda_opt_stack_adjusted_0093:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 48]
	push rax
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 3
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_0857:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0479:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0479
.L_tc_recycle_frame_done_0479:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 2)
.L_lambda_opt_end_0093:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03dd:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_96], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03df:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03df
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03df
.L_lambda_simple_env_end_03df:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03df:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03df
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03df
.L_lambda_simple_params_end_03df:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03df
	jmp .L_lambda_simple_end_03df
.L_lambda_simple_code_03df:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_0858
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0858:
	enter 0, 0
	mov rax, qword (L_constants + 67)
	push rax
	mov rax, qword (L_constants + 58)
	push rax
	push 2
	mov rax, qword [free_var_38]
.L_lambda_simple_arity_check_ok_0859:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_047a:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_047a
.L_tc_recycle_frame_done_047a:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_03df:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03e0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03e0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03e0
.L_lambda_simple_env_end_03e0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03e0:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03e0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03e0
.L_lambda_simple_params_end_03e0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03e0
	jmp .L_lambda_simple_end_03e0
.L_lambda_simple_code_03e0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_085a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_085a:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03e1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03e1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03e1
.L_lambda_simple_env_end_03e1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03e1:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03e1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03e1
.L_lambda_simple_params_end_03e1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03e1
	jmp .L_lambda_simple_end_03e1
.L_lambda_simple_code_03e1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_085b
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_085b:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0246
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_024a
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_34]
.L_lambda_simple_arity_check_ok_0862:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0481:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0481
.L_tc_recycle_frame_done_0481:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_024a
	.L_if_else_024a:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_024b
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_23]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_30]
.L_lambda_simple_arity_check_ok_0861:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0480:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0480
.L_tc_recycle_frame_done_0480:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_024b
	.L_if_else_024b:
		push 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_0860:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_047f:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_047f
.L_tc_recycle_frame_done_047f:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_024b:
	.L_if_end_024a:
	jmp .L_if_end_0246
	.L_if_else_0246:
	mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0247
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0248
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_23]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_30]
.L_lambda_simple_arity_check_ok_085f:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_047e:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_047e
.L_tc_recycle_frame_done_047e:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0248
	.L_if_else_0248:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0249
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_30]
.L_lambda_simple_arity_check_ok_085e:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_047d:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_047d
.L_tc_recycle_frame_done_047d:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0249
	.L_if_else_0249:
		push 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_085d:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_047c:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_047c
.L_tc_recycle_frame_done_047c:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0249:
	.L_if_end_0248:
	jmp .L_if_end_0247
	.L_if_else_0247:
		push 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_085c:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_047b:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_047b
.L_tc_recycle_frame_done_047b:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0247:
	.L_if_end_0246:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03e1:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03e2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03e2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03e2
.L_lambda_simple_env_end_03e2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03e2:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03e2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03e2
.L_lambda_simple_params_end_03e2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03e2
	jmp .L_lambda_simple_end_03e2
.L_lambda_simple_code_03e2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0863
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0863:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0094:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0094
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0094
.L_lambda_opt_env_end_0094:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01ba:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01ba
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01ba
.L_lambda_opt_params_end_01ba:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0094
	jmp .L_lambda_opt_end_0094
.L_lambda_opt_code_0094:
mov r10, qword [rsp+8*2]
cmp r10, 0
je .L_lambda_opt_arity_check_exact_0094
cmp r10, 0
jg .L_lambda_opt_arity_check_more_0094
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0094:
sub rsp, 8
mov rdx, 3+0
mov qword rbx, rsp
.L_lambda_opt_params_loop_01bb:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01bb
jmp .L_lambda_opt_params_loop_01bb
.L_lambda_opt_params_end_01bb:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_0094
.L_lambda_opt_arity_check_more_0094:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 0
.L_lambda_opt_stack_shrink_loop_0094:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_0094
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_0094
.L_lambda_opt_stack_shrink_loop_exit_0094:
mov [rsp+8*(2+1)], rax
mov r10, 1
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+1)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01bc:
cmp r9, 0
je .L_lambda_opt_params_end_01bc
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01bc
.L_lambda_opt_params_end_01bc:
add rsp, r15
.L_lambda_opt_stack_adjusted_0094:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	mov rax, qword (L_constants + 31)
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
	push 3
	mov rax, qword [free_var_95]
.L_lambda_simple_arity_check_ok_0864:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0482:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0482
.L_tc_recycle_frame_done_0482:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 0)
.L_lambda_opt_end_0094:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03e2:	; new closure is in rax
.L_lambda_simple_arity_check_ok_0865:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0483:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0483
.L_tc_recycle_frame_done_0483:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03e0:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_97], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03e3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03e3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03e3
.L_lambda_simple_env_end_03e3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03e3:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03e3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03e3
.L_lambda_simple_params_end_03e3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03e3
	jmp .L_lambda_simple_end_03e3
.L_lambda_simple_code_03e3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_0866
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0866:
	enter 0, 0
	mov rax, qword (L_constants + 67)
	push rax
	mov rax, qword (L_constants + 118)
	push rax
	push 2
	mov rax, qword [free_var_38]
.L_lambda_simple_arity_check_ok_0867:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0484:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0484
.L_tc_recycle_frame_done_0484:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_03e3:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03e4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03e4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03e4
.L_lambda_simple_env_end_03e4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03e4:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03e4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03e4
.L_lambda_simple_params_end_03e4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03e4
	jmp .L_lambda_simple_end_03e4
.L_lambda_simple_code_03e4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0868
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0868:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03e5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03e5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03e5
.L_lambda_simple_env_end_03e5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03e5:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03e5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03e5
.L_lambda_simple_params_end_03e5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03e5
	jmp .L_lambda_simple_end_03e5
.L_lambda_simple_code_03e5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0869
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0869:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_024c
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0250
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_35]
.L_lambda_simple_arity_check_ok_0870:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_048b:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_048b
.L_tc_recycle_frame_done_048b:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0250
	.L_if_else_0250:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0251
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_23]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_31]
.L_lambda_simple_arity_check_ok_086f:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_048a:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_048a
.L_tc_recycle_frame_done_048a:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0251
	.L_if_else_0251:
		push 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_086e:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0489:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0489
.L_tc_recycle_frame_done_0489:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0251:
	.L_if_end_0250:
	jmp .L_if_end_024c
	.L_if_else_024c:
	mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_024d
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_024e
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_23]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_31]
.L_lambda_simple_arity_check_ok_086d:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0488:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0488
.L_tc_recycle_frame_done_0488:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_024e
	.L_if_else_024e:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_024f
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_31]
.L_lambda_simple_arity_check_ok_086c:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0487:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0487
.L_tc_recycle_frame_done_0487:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_024f
	.L_if_else_024f:
		push 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_086b:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0486:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0486
.L_tc_recycle_frame_done_0486:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_024f:
	.L_if_end_024e:
	jmp .L_if_end_024d
	.L_if_else_024d:
		push 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_086a:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0485:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0485
.L_tc_recycle_frame_done_0485:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_024d:
	.L_if_end_024c:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03e5:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03e6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03e6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03e6
.L_lambda_simple_env_end_03e6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03e6:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03e6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03e6
.L_lambda_simple_params_end_03e6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03e6
	jmp .L_lambda_simple_end_03e6
.L_lambda_simple_code_03e6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0871
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0871:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0095:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0095
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0095
.L_lambda_opt_env_end_0095:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01bd:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01bd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01bd
.L_lambda_opt_params_end_01bd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0095
	jmp .L_lambda_opt_end_0095
.L_lambda_opt_code_0095:
mov r10, qword [rsp+8*2]
cmp r10, 1
je .L_lambda_opt_arity_check_exact_0095
cmp r10, 1
jg .L_lambda_opt_arity_check_more_0095
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0095:
sub rsp, 8
mov rdx, 3+1
mov qword rbx, rsp
.L_lambda_opt_params_loop_01be:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01be
jmp .L_lambda_opt_params_loop_01be
.L_lambda_opt_params_end_01be:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_0095
.L_lambda_opt_arity_check_more_0095:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 1
.L_lambda_opt_stack_shrink_loop_0095:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_0095
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_0095
.L_lambda_opt_stack_shrink_loop_exit_0095:
mov [rsp+8*(2+2)], rax
mov r10, 2
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+2)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01bf:
cmp r9, 0
je .L_lambda_opt_params_end_01bf
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01bf
.L_lambda_opt_params_end_01bf:
add rsp, r15
.L_lambda_opt_stack_adjusted_0095:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0252
mov rax, qword [rbp + 32]
	push rax
	mov rax, qword (L_constants + 31)
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_0875:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_048e:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_048e
.L_tc_recycle_frame_done_048e:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0252
	.L_if_else_0252:
	mov rax, qword [rbp + 40]
	push rax
	mov rax, qword (L_constants + 31)
	push rax
	mov rax, qword [free_var_97]
	push rax
	push 3
	mov rax, qword [free_var_95]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03e7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_03e7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03e7
.L_lambda_simple_env_end_03e7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03e7:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_03e7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03e7
.L_lambda_simple_params_end_03e7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03e7
	jmp .L_lambda_simple_end_03e7
.L_lambda_simple_code_03e7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0872
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0872:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_0873:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_048c:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_048c
.L_tc_recycle_frame_done_048c:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03e7:	; new closure is in rax
.L_lambda_simple_arity_check_ok_0874:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_048d:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_048d
.L_tc_recycle_frame_done_048d:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0252:
leave
mov r9, [rbp]
ret 8 * (3 + 1)
.L_lambda_opt_end_0095:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03e6:	; new closure is in rax
.L_lambda_simple_arity_check_ok_0876:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_048f:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_048f
.L_tc_recycle_frame_done_048f:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03e4:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_98], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03e8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03e8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03e8
.L_lambda_simple_env_end_03e8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03e8:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03e8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03e8
.L_lambda_simple_params_end_03e8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03e8
	jmp .L_lambda_simple_end_03e8
.L_lambda_simple_code_03e8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_0877
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0877:
	enter 0, 0
	mov rax, qword (L_constants + 67)
	push rax
	mov rax, qword (L_constants + 154)
	push rax
	push 2
	mov rax, qword [free_var_38]
.L_lambda_simple_arity_check_ok_0878:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0490:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0490
.L_tc_recycle_frame_done_0490:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_03e8:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03e9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03e9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03e9
.L_lambda_simple_env_end_03e9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03e9:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03e9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03e9
.L_lambda_simple_params_end_03e9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03e9
	jmp .L_lambda_simple_end_03e9
.L_lambda_simple_code_03e9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0879
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0879:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03ea:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03ea
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03ea
.L_lambda_simple_env_end_03ea:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03ea:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03ea
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03ea
.L_lambda_simple_params_end_03ea:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03ea
	jmp .L_lambda_simple_end_03ea
.L_lambda_simple_code_03ea:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_087a
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_087a:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0253
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0257
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_36]
.L_lambda_simple_arity_check_ok_0881:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0497:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0497
.L_tc_recycle_frame_done_0497:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0257
	.L_if_else_0257:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0258
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_23]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_32]
.L_lambda_simple_arity_check_ok_0880:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0496:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0496
.L_tc_recycle_frame_done_0496:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0258
	.L_if_else_0258:
		push 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_087f:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0495:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0495
.L_tc_recycle_frame_done_0495:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0258:
	.L_if_end_0257:
	jmp .L_if_end_0253
	.L_if_else_0253:
	mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0254
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0255
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_23]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_32]
.L_lambda_simple_arity_check_ok_087e:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0494:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0494
.L_tc_recycle_frame_done_0494:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0255
	.L_if_else_0255:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0256
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_32]
.L_lambda_simple_arity_check_ok_087d:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0493:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0493
.L_tc_recycle_frame_done_0493:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0256
	.L_if_else_0256:
		push 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_087c:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0492:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0492
.L_tc_recycle_frame_done_0492:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0256:
	.L_if_end_0255:
	jmp .L_if_end_0254
	.L_if_else_0254:
		push 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_087b:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0491:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0491
.L_tc_recycle_frame_done_0491:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0254:
	.L_if_end_0253:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03ea:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03eb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03eb
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03eb
.L_lambda_simple_env_end_03eb:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03eb:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03eb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03eb
.L_lambda_simple_params_end_03eb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03eb
	jmp .L_lambda_simple_end_03eb
.L_lambda_simple_code_03eb:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0882
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0882:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0096:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0096
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0096
.L_lambda_opt_env_end_0096:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01c0:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01c0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01c0
.L_lambda_opt_params_end_01c0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0096
	jmp .L_lambda_opt_end_0096
.L_lambda_opt_code_0096:
mov r10, qword [rsp+8*2]
cmp r10, 0
je .L_lambda_opt_arity_check_exact_0096
cmp r10, 0
jg .L_lambda_opt_arity_check_more_0096
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0096:
sub rsp, 8
mov rdx, 3+0
mov qword rbx, rsp
.L_lambda_opt_params_loop_01c1:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01c1
jmp .L_lambda_opt_params_loop_01c1
.L_lambda_opt_params_end_01c1:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_0096
.L_lambda_opt_arity_check_more_0096:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 0
.L_lambda_opt_stack_shrink_loop_0096:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_0096
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_0096
.L_lambda_opt_stack_shrink_loop_exit_0096:
mov [rsp+8*(2+1)], rax
mov r10, 1
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+1)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01c2:
cmp r9, 0
je .L_lambda_opt_params_end_01c2
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01c2
.L_lambda_opt_params_end_01c2:
add rsp, r15
.L_lambda_opt_stack_adjusted_0096:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	mov rax, qword (L_constants + 127)
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
	push 3
	mov rax, qword [free_var_95]
.L_lambda_simple_arity_check_ok_0883:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0498:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0498
.L_tc_recycle_frame_done_0498:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 0)
.L_lambda_opt_end_0096:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03eb:	; new closure is in rax
.L_lambda_simple_arity_check_ok_0884:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_0499:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_0499
.L_tc_recycle_frame_done_0499:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03e9:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_99], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03ec:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03ec
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03ec
.L_lambda_simple_env_end_03ec:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03ec:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03ec
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03ec
.L_lambda_simple_params_end_03ec:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03ec
	jmp .L_lambda_simple_end_03ec
.L_lambda_simple_code_03ec:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_0885
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0885:
	enter 0, 0
	mov rax, qword (L_constants + 67)
	push rax
	mov rax, qword (L_constants + 173)
	push rax
	push 2
	mov rax, qword [free_var_38]
.L_lambda_simple_arity_check_ok_0886:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_049a:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_049a
.L_tc_recycle_frame_done_049a:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_03ec:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03ed:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03ed
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03ed
.L_lambda_simple_env_end_03ed:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03ed:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03ed
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03ed
.L_lambda_simple_params_end_03ed:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03ed
	jmp .L_lambda_simple_end_03ed
.L_lambda_simple_code_03ed:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0887
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0887:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03ee:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03ee
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03ee
.L_lambda_simple_env_end_03ee:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03ee:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03ee
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03ee
.L_lambda_simple_params_end_03ee:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03ee
	jmp .L_lambda_simple_end_03ee
.L_lambda_simple_code_03ee:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0888
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0888:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0259
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_025d
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_37]
.L_lambda_simple_arity_check_ok_088f:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04a1:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04a1
.L_tc_recycle_frame_done_04a1:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_025d
	.L_if_else_025d:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_025e
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_23]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_33]
.L_lambda_simple_arity_check_ok_088e:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04a0:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04a0
.L_tc_recycle_frame_done_04a0:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_025e
	.L_if_else_025e:
		push 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_088d:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_049f:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_049f
.L_tc_recycle_frame_done_049f:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_025e:
	.L_if_end_025d:
	jmp .L_if_end_0259
	.L_if_else_0259:
	mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_025a
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_025b
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_23]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_33]
.L_lambda_simple_arity_check_ok_088c:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_049e:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_049e
.L_tc_recycle_frame_done_049e:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_025b
	.L_if_else_025b:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_025c
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_33]
.L_lambda_simple_arity_check_ok_088b:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_049d:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_049d
.L_tc_recycle_frame_done_049d:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_025c
	.L_if_else_025c:
		push 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_088a:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_049c:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_049c
.L_tc_recycle_frame_done_049c:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_025c:
	.L_if_end_025b:
	jmp .L_if_end_025a
	.L_if_else_025a:
		push 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_0889:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_049b:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_049b
.L_tc_recycle_frame_done_049b:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_025a:
	.L_if_end_0259:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03ee:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03ef:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03ef
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03ef
.L_lambda_simple_env_end_03ef:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03ef:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03ef
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03ef
.L_lambda_simple_params_end_03ef:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03ef
	jmp .L_lambda_simple_end_03ef
.L_lambda_simple_code_03ef:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0890
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0890:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0097:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0097
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0097
.L_lambda_opt_env_end_0097:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01c3:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01c3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01c3
.L_lambda_opt_params_end_01c3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0097
	jmp .L_lambda_opt_end_0097
.L_lambda_opt_code_0097:
mov r10, qword [rsp+8*2]
cmp r10, 1
je .L_lambda_opt_arity_check_exact_0097
cmp r10, 1
jg .L_lambda_opt_arity_check_more_0097
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0097:
sub rsp, 8
mov rdx, 3+1
mov qword rbx, rsp
.L_lambda_opt_params_loop_01c4:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01c4
jmp .L_lambda_opt_params_loop_01c4
.L_lambda_opt_params_end_01c4:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_0097
.L_lambda_opt_arity_check_more_0097:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 1
.L_lambda_opt_stack_shrink_loop_0097:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_0097
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_0097
.L_lambda_opt_stack_shrink_loop_exit_0097:
mov [rsp+8*(2+2)], rax
mov r10, 2
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+2)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01c5:
cmp r9, 0
je .L_lambda_opt_params_end_01c5
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01c5
.L_lambda_opt_params_end_01c5:
add rsp, r15
.L_lambda_opt_stack_adjusted_0097:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_025f
mov rax, qword [rbp + 32]
	push rax
	mov rax, qword (L_constants + 127)
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_0894:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04a4:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04a4
.L_tc_recycle_frame_done_04a4:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_025f
	.L_if_else_025f:
	mov rax, qword [rbp + 40]
	push rax
	mov rax, qword (L_constants + 127)
	push rax
	mov rax, qword [free_var_99]
	push rax
	push 3
	mov rax, qword [free_var_95]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03f0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_03f0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03f0
.L_lambda_simple_env_end_03f0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03f0:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_03f0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03f0
.L_lambda_simple_params_end_03f0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03f0
	jmp .L_lambda_simple_end_03f0
.L_lambda_simple_code_03f0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0891
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0891:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_0892:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04a2:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04a2
.L_tc_recycle_frame_done_04a2:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03f0:	; new closure is in rax
.L_lambda_simple_arity_check_ok_0893:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04a3:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04a3
.L_tc_recycle_frame_done_04a3:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_025f:
leave
mov r9, [rbp]
ret 8 * (3 + 1)
.L_lambda_opt_end_0097:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03ef:	; new closure is in rax
.L_lambda_simple_arity_check_ok_0895:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04a5:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04a5
.L_tc_recycle_frame_done_04a5:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03ed:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_100], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03f1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03f1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03f1
.L_lambda_simple_env_end_03f1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03f1:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03f1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03f1
.L_lambda_simple_params_end_03f1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03f1
	jmp .L_lambda_simple_end_03f1
.L_lambda_simple_code_03f1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0896
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0896:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_27]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0260
	mov rax, qword (L_constants + 127)
	jmp .L_if_end_0260
	.L_if_else_0260:
		mov rax, qword (L_constants + 127)
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_98]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_101]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_99]
.L_lambda_simple_arity_check_ok_0897:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04a6:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04a6
.L_tc_recycle_frame_done_04a6:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0260:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03f1:	; new closure is in rax
	mov qword [free_var_101], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_102], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_103], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_104], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_105], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_106], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03f2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03f2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03f2
.L_lambda_simple_env_end_03f2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03f2:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03f2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03f2
.L_lambda_simple_params_end_03f2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03f2
	jmp .L_lambda_simple_end_03f2
.L_lambda_simple_code_03f2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_0898
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0898:
	enter 0, 0
	mov rax, qword (L_constants + 218)
	push rax
	mov rax, qword (L_constants + 209)
	push rax
	push 2
	mov rax, qword [free_var_38]
.L_lambda_simple_arity_check_ok_0899:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04a7:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04a7
.L_tc_recycle_frame_done_04a7:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_03f2:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03f3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_03f3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03f3
.L_lambda_simple_env_end_03f3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03f3:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_03f3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03f3
.L_lambda_simple_params_end_03f3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03f3
	jmp .L_lambda_simple_end_03f3
.L_lambda_simple_code_03f3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_089a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_089a:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03f4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03f4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03f4
.L_lambda_simple_env_end_03f4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03f4:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03f4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03f4
.L_lambda_simple_params_end_03f4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03f4
	jmp .L_lambda_simple_end_03f4
.L_lambda_simple_code_03f4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_089b
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_089b:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03f5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_03f5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03f5
.L_lambda_simple_env_end_03f5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03f5:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_03f5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03f5
.L_lambda_simple_params_end_03f5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03f5
	jmp .L_lambda_simple_end_03f5
.L_lambda_simple_code_03f5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_089c
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_089c:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0261
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0265
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_08a2:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04ad:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04ad
.L_tc_recycle_frame_done_04ad:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0265
	.L_if_else_0265:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0266
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_23]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
.L_lambda_simple_arity_check_ok_08a1:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04ac:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04ac
.L_tc_recycle_frame_done_04ac:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0266
	.L_if_else_0266:
		push 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_08a0:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04ab:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04ab
.L_tc_recycle_frame_done_04ab:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0266:
	.L_if_end_0265:
	jmp .L_if_end_0261
	.L_if_else_0261:
	mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0262
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_9]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0263
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_23]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
.L_lambda_simple_arity_check_ok_089f:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04aa:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04aa
.L_tc_recycle_frame_done_04aa:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0263
	.L_if_else_0263:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0264
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
.L_lambda_simple_arity_check_ok_089e:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04a9:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04a9
.L_tc_recycle_frame_done_04a9:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0264
	.L_if_else_0264:
		push 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_089d:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04a8:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04a8
.L_tc_recycle_frame_done_04a8:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0264:
	.L_if_end_0263:
	jmp .L_if_end_0262
	.L_if_else_0262:
		mov rax, qword (L_constants + 0)
	.L_if_end_0262:
	.L_if_end_0261:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03f5:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03f4:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03f6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_03f6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03f6
.L_lambda_simple_env_end_03f6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03f6:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03f6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03f6
.L_lambda_simple_params_end_03f6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03f6
	jmp .L_lambda_simple_end_03f6
.L_lambda_simple_code_03f6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08a3
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08a3:
	enter 0, 0
	mov rax, qword [free_var_39]
	push rax
	mov rax, qword [free_var_40]
	push rax
	push 2
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03f7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_03f7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03f7
.L_lambda_simple_env_end_03f7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03f7:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03f7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03f7
.L_lambda_simple_params_end_03f7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03f7
	jmp .L_lambda_simple_end_03f7
.L_lambda_simple_code_03f7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08a4
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08a4:
	enter 0, 0
	mov rax, qword [free_var_41]
	push rax
	mov rax, qword [free_var_42]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03f8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_03f8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03f8
.L_lambda_simple_env_end_03f8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03f8:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03f8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03f8
.L_lambda_simple_params_end_03f8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03f8
	jmp .L_lambda_simple_end_03f8
.L_lambda_simple_code_03f8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08a5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08a5:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03f9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_03f9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03f9
.L_lambda_simple_env_end_03f9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03f9:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03f9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03f9
.L_lambda_simple_params_end_03f9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03f9
	jmp .L_lambda_simple_end_03f9
.L_lambda_simple_code_03f9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_08a6
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08a6:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_86]
.L_lambda_simple_arity_check_ok_08a7:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04ae:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04ae
.L_tc_recycle_frame_done_04ae:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03f9:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03fa:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_03fa
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03fa
.L_lambda_simple_env_end_03fa:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03fa:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03fa
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03fa
.L_lambda_simple_params_end_03fa:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03fa
	jmp .L_lambda_simple_end_03fa
.L_lambda_simple_code_03fa:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08a8
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08a8:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 6	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03fb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 5
	je .L_lambda_simple_env_end_03fb
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03fb
.L_lambda_simple_env_end_03fb:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03fb:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03fb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03fb
.L_lambda_simple_params_end_03fb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03fb
	jmp .L_lambda_simple_end_03fb
.L_lambda_simple_code_03fb:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_08a9
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08a9:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 40]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 16]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_08aa:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04af:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04af
.L_tc_recycle_frame_done_04af:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03fb:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 6	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03fc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 5
	je .L_lambda_simple_env_end_03fc
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03fc
.L_lambda_simple_env_end_03fc:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03fc:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03fc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03fc
.L_lambda_simple_params_end_03fc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03fc
	jmp .L_lambda_simple_end_03fc
.L_lambda_simple_code_03fc:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08ab
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08ab:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 7	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03fd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 6
	je .L_lambda_simple_env_end_03fd
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03fd
.L_lambda_simple_env_end_03fd:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03fd:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03fd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03fd
.L_lambda_simple_params_end_03fd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03fd
	jmp .L_lambda_simple_end_03fd
.L_lambda_simple_code_03fd:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_08ac
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08ac:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_86]
.L_lambda_simple_arity_check_ok_08ad:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04b0:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04b0
.L_tc_recycle_frame_done_04b0:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_03fd:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 7	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03fe:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 6
	je .L_lambda_simple_env_end_03fe
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03fe
.L_lambda_simple_env_end_03fe:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03fe:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03fe
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03fe
.L_lambda_simple_params_end_03fe:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03fe
	jmp .L_lambda_simple_end_03fe
.L_lambda_simple_code_03fe:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08ae
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08ae:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 8	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_03ff:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 7
	je .L_lambda_simple_env_end_03ff
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_03ff
.L_lambda_simple_env_end_03ff:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_03ff:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_03ff
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_03ff
.L_lambda_simple_params_end_03ff:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_03ff
	jmp .L_lambda_simple_end_03ff
.L_lambda_simple_code_03ff:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08af
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08af:
	enter 0, 0
	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 9	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0400:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 8
	je .L_lambda_simple_env_end_0400
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0400
.L_lambda_simple_env_end_0400:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0400:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0400
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0400
.L_lambda_simple_params_end_0400:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0400
	jmp .L_lambda_simple_end_0400
.L_lambda_simple_code_0400:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08b0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08b0:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 10	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0401:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 9
	je .L_lambda_simple_env_end_0401
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0401
.L_lambda_simple_env_end_0401:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0401:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0401
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0401
.L_lambda_simple_params_end_0401:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0401
	jmp .L_lambda_simple_end_0401
.L_lambda_simple_code_0401:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_08b1
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08b1:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	jne .L_or_end_004c
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0267
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08b2:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04b1:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04b1
.L_tc_recycle_frame_done_04b1:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0267
	.L_if_else_0267:
		mov rax, qword (L_constants + 2)
	.L_if_end_0267:
.L_or_end_004c:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0401:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 10	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0098:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 9
	je .L_lambda_opt_env_end_0098
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0098
.L_lambda_opt_env_end_0098:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01c6:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01c6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01c6
.L_lambda_opt_params_end_01c6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0098
	jmp .L_lambda_opt_end_0098
.L_lambda_opt_code_0098:
mov r10, qword [rsp+8*2]
cmp r10, 1
je .L_lambda_opt_arity_check_exact_0098
cmp r10, 1
jg .L_lambda_opt_arity_check_more_0098
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0098:
sub rsp, 8
mov rdx, 3+1
mov qword rbx, rsp
.L_lambda_opt_params_loop_01c7:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01c7
jmp .L_lambda_opt_params_loop_01c7
.L_lambda_opt_params_end_01c7:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_0098
.L_lambda_opt_arity_check_more_0098:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 1
.L_lambda_opt_stack_shrink_loop_0098:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_0098
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_0098
.L_lambda_opt_stack_shrink_loop_exit_0098:
mov [rsp+8*(2+2)], rax
mov r10, 2
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+2)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01c8:
cmp r9, 0
je .L_lambda_opt_params_end_01c8
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01c8
.L_lambda_opt_params_end_01c8:
add rsp, r15
.L_lambda_opt_stack_adjusted_0098:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08b3:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04b2:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04b2
.L_tc_recycle_frame_done_04b2:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 1)
.L_lambda_opt_end_0098:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0400:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08b4:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04b3:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04b3
.L_tc_recycle_frame_done_04b3:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03ff:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 8	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0402:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 7
	je .L_lambda_simple_env_end_0402
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0402
.L_lambda_simple_env_end_0402:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0402:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0402
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0402
.L_lambda_simple_params_end_0402:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0402
	jmp .L_lambda_simple_end_0402
.L_lambda_simple_code_0402:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08b5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08b5:
	enter 0, 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 32]
mov rax, qword [rax + 0]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_102], rax
	mov rax, sob_void

mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_103], rax
	mov rax, sob_void

mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_104], rax
	mov rax, sob_void

mov rax, qword [rbp + 16]
mov rax, qword [rax + 16]
mov rax, qword [rax + 0]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_105], rax
	mov rax, sob_void

mov rax, qword [rbp + 16]
mov rax, qword [rax + 24]
mov rax, qword [rax + 0]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_106], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0402:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08b6:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04b4:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04b4
.L_tc_recycle_frame_done_04b4:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03fe:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08b7:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04b5:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04b5
.L_tc_recycle_frame_done_04b5:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03fc:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08b8:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04b6:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04b6
.L_tc_recycle_frame_done_04b6:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03fa:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08b9:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04b7:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04b7
.L_tc_recycle_frame_done_04b7:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03f8:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08ba:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04b8:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04b8
.L_tc_recycle_frame_done_04b8:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03f7:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08bb:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04b9:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04b9
.L_tc_recycle_frame_done_04b9:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03f6:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08bc:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04ba:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04ba
.L_tc_recycle_frame_done_04ba:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_03f3:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        
	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0403:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0403
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0403
.L_lambda_simple_env_end_0403:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0403:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0403
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0403
.L_lambda_simple_params_end_0403:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0403
	jmp .L_lambda_simple_end_0403
.L_lambda_simple_code_0403:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08bd
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08bd:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0404:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0404
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0404
.L_lambda_simple_env_end_0404:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0404:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0404
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0404
.L_lambda_simple_params_end_0404:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0404
	jmp .L_lambda_simple_end_0404
.L_lambda_simple_code_0404:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_08be
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08be:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_27]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0268
	mov rax, qword (L_constants + 1)
	jmp .L_if_end_0268
	.L_if_else_0268:
	mov rax, qword [rbp + 40]
	push rax
	mov rax, qword (L_constants + 127)
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_98]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 40]
	push rax
	push 2
	mov rax, qword [free_var_13]
.L_lambda_simple_arity_check_ok_08bf:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04bb:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04bb
.L_tc_recycle_frame_done_04bb:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0268:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0404:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0099:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0099
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0099
.L_lambda_opt_env_end_0099:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01c9:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01c9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01c9
.L_lambda_opt_params_end_01c9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0099
	jmp .L_lambda_opt_end_0099
.L_lambda_opt_code_0099:
mov r10, qword [rsp+8*2]
cmp r10, 1
je .L_lambda_opt_arity_check_exact_0099
cmp r10, 1
jg .L_lambda_opt_arity_check_more_0099
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0099:
sub rsp, 8
mov rdx, 3+1
mov qword rbx, rsp
.L_lambda_opt_params_loop_01ca:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01ca
jmp .L_lambda_opt_params_loop_01ca
.L_lambda_opt_params_end_01ca:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_0099
.L_lambda_opt_arity_check_more_0099:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 1
.L_lambda_opt_stack_shrink_loop_0099:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_0099
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_0099
.L_lambda_opt_stack_shrink_loop_exit_0099:
mov [rsp+8*(2+2)], rax
mov r10, 2
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+2)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01cb:
cmp r9, 0
je .L_lambda_opt_params_end_01cb
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01cb
.L_lambda_opt_params_end_01cb:
add rsp, r15
.L_lambda_opt_stack_adjusted_0099:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0269
	mov rax, qword (L_constants + 4)
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08c2:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04be:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04be
.L_tc_recycle_frame_done_04be:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0269
	.L_if_else_0269:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_1]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_026b
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_026c
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_3]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_026c
	.L_if_else_026c:
		mov rax, qword (L_constants + 2)
	.L_if_end_026c:
	jmp .L_if_end_026b
	.L_if_else_026b:
		mov rax, qword (L_constants + 2)
	.L_if_end_026b:
	cmp rax, sob_boolean_false
	je .L_if_else_026a
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08c1:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04bd:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04bd
.L_tc_recycle_frame_done_04bd:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_026a
	.L_if_else_026a:
		mov rax, qword (L_constants + 287)
	push rax
	mov rax, qword (L_constants + 278)
	push rax
	push 2
	mov rax, qword [free_var_38]
.L_lambda_simple_arity_check_ok_08c0:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04bc:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04bc
.L_tc_recycle_frame_done_04bc:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_026a:
	.L_if_end_0269:
leave
mov r9, [rbp]
ret 8 * (3 + 1)
.L_lambda_opt_end_0099:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0403:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_107], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_108], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_109], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_110], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_111], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_112], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0405:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0405
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0405
.L_lambda_simple_env_end_0405:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0405:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0405
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0405
.L_lambda_simple_params_end_0405:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0405
	jmp .L_lambda_simple_end_0405
.L_lambda_simple_code_0405:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08c3
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08c3:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_009a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_009a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_009a
.L_lambda_opt_env_end_009a:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01cc:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01cc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01cc
.L_lambda_opt_params_end_01cc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_009a
	jmp .L_lambda_opt_end_009a
.L_lambda_opt_code_009a:
mov r10, qword [rsp+8*2]
cmp r10, 0
je .L_lambda_opt_arity_check_exact_009a
cmp r10, 0
jg .L_lambda_opt_arity_check_more_009a
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_009a:
sub rsp, 8
mov rdx, 3+0
mov qword rbx, rsp
.L_lambda_opt_params_loop_01cd:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01cd
jmp .L_lambda_opt_params_loop_01cd
.L_lambda_opt_params_end_01cd:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_009a
.L_lambda_opt_arity_check_more_009a:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 0
.L_lambda_opt_stack_shrink_loop_009a:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_009a
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_009a
.L_lambda_opt_stack_shrink_loop_exit_009a:
mov [rsp+8*(2+1)], rax
mov r10, 1
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+1)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01ce:
cmp r9, 0
je .L_lambda_opt_params_end_01ce
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01ce
.L_lambda_opt_params_end_01ce:
add rsp, r15
.L_lambda_opt_stack_adjusted_009a:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	mov rax, qword [free_var_24]
	push rax
	push 2
	mov rax, qword [free_var_91]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
.L_lambda_simple_arity_check_ok_08c4:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04bf:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04bf
.L_tc_recycle_frame_done_04bf:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 0)
.L_lambda_opt_end_009a:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0405:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0406:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0406
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0406
.L_lambda_simple_env_end_0406:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0406:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0406
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0406
.L_lambda_simple_params_end_0406:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0406
	jmp .L_lambda_simple_end_0406
.L_lambda_simple_code_0406:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08c5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08c5:
	enter 0, 0
	mov rax, qword [free_var_102]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_108], rax
	mov rax, sob_void

	mov rax, qword [free_var_103]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_109], rax
	mov rax, sob_void

	mov rax, qword [free_var_106]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_110], rax
	mov rax, sob_void

	mov rax, qword [free_var_104]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_111], rax
	mov rax, sob_void

	mov rax, qword [free_var_105]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_112], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0406:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        
	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_113], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_114], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 341)
	push rax
	push 1
	mov rax, qword [free_var_24]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	mov rax, qword (L_constants + 345)
	push rax
	push 1
	mov rax, qword [free_var_24]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_98]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0407:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0407
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0407
.L_lambda_simple_env_end_0407:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0407:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0407
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0407
.L_lambda_simple_params_end_0407:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0407
	jmp .L_lambda_simple_end_0407
.L_lambda_simple_code_0407:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08c6
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08c6:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0408:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0408
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0408
.L_lambda_simple_env_end_0408:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0408:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0408
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0408
.L_lambda_simple_params_end_0408:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0408
	jmp .L_lambda_simple_end_0408
.L_lambda_simple_code_0408:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08c7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08c7:
	enter 0, 0
	mov rax, qword (L_constants + 343)
	push rax
mov rax, qword [rbp + 32]
	push rax
	mov rax, qword (L_constants + 341)
	push rax
	push 3
	mov rax, qword [free_var_109]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_026d
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_24]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_97]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_25]
.L_lambda_simple_arity_check_ok_08c8:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04c0:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04c0
.L_tc_recycle_frame_done_04c0:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_026d
	.L_if_else_026d:
	mov rax, qword [rbp + 32]
	.L_if_end_026d:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0408:	; new closure is in rax
	mov qword [free_var_113], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0409:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0409
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0409
.L_lambda_simple_env_end_0409:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0409:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0409
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0409
.L_lambda_simple_params_end_0409:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0409
	jmp .L_lambda_simple_end_0409
.L_lambda_simple_code_0409:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08c9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08c9:
	enter 0, 0
	mov rax, qword (L_constants + 347)
	push rax
mov rax, qword [rbp + 32]
	push rax
	mov rax, qword (L_constants + 345)
	push rax
	push 3
	mov rax, qword [free_var_109]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_026e
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_24]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_98]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_25]
.L_lambda_simple_arity_check_ok_08ca:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04c1:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04c1
.L_tc_recycle_frame_done_04c1:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_026e
	.L_if_else_026e:
	mov rax, qword [rbp + 32]
	.L_if_end_026e:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0409:	; new closure is in rax
	mov qword [free_var_114], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0407:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        
	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_115], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_116], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_117], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_118], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_119], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_040a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_040a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_040a
.L_lambda_simple_env_end_040a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_040a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_040a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_040a
.L_lambda_simple_params_end_040a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_040a
	jmp .L_lambda_simple_end_040a
.L_lambda_simple_code_040a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08cb
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08cb:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_009b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_009b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_009b
.L_lambda_opt_env_end_009b:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01cf:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01cf
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01cf
.L_lambda_opt_params_end_01cf:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_009b
	jmp .L_lambda_opt_end_009b
.L_lambda_opt_code_009b:
mov r10, qword [rsp+8*2]
cmp r10, 0
je .L_lambda_opt_arity_check_exact_009b
cmp r10, 0
jg .L_lambda_opt_arity_check_more_009b
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_009b:
sub rsp, 8
mov rdx, 3+0
mov qword rbx, rsp
.L_lambda_opt_params_loop_01d0:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01d0
jmp .L_lambda_opt_params_loop_01d0
.L_lambda_opt_params_end_01d0:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_009b
.L_lambda_opt_arity_check_more_009b:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 0
.L_lambda_opt_stack_shrink_loop_009b:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_009b
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_009b
.L_lambda_opt_stack_shrink_loop_exit_009b:
mov [rsp+8*(2+1)], rax
mov r10, 1
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+1)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01d1:
cmp r9, 0
je .L_lambda_opt_params_end_01d1
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01d1
.L_lambda_opt_params_end_01d1:
add rsp, r15
.L_lambda_opt_stack_adjusted_009b:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_040b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_040b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_040b
.L_lambda_simple_env_end_040b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_040b:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_040b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_040b
.L_lambda_simple_params_end_040b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_040b
	jmp .L_lambda_simple_end_040b
.L_lambda_simple_code_040b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08cc
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08cc:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_113]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_24]
.L_lambda_simple_arity_check_ok_08cd:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04c2:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04c2
.L_tc_recycle_frame_done_04c2:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_040b:	; new closure is in rax
	push rax
	push 2
	mov rax, qword [free_var_91]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
.L_lambda_simple_arity_check_ok_08ce:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04c3:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04c3
.L_tc_recycle_frame_done_04c3:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 0)
.L_lambda_opt_end_009b:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_040a:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_040c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_040c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_040c
.L_lambda_simple_env_end_040c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_040c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_040c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_040c
.L_lambda_simple_params_end_040c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_040c
	jmp .L_lambda_simple_end_040c
.L_lambda_simple_code_040c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08cf
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08cf:
	enter 0, 0
	mov rax, qword [free_var_102]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_115], rax
	mov rax, sob_void

	mov rax, qword [free_var_103]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_116], rax
	mov rax, sob_void

	mov rax, qword [free_var_106]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_117], rax
	mov rax, sob_void

	mov rax, qword [free_var_104]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_118], rax
	mov rax, sob_void

	mov rax, qword [free_var_105]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_119], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_040c:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        
	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_120], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_121], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_040d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_040d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_040d
.L_lambda_simple_env_end_040d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_040d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_040d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_040d
.L_lambda_simple_params_end_040d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_040d
	jmp .L_lambda_simple_end_040d
.L_lambda_simple_code_040d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08d0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08d0:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_040e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_040e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_040e
.L_lambda_simple_env_end_040e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_040e:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_040e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_040e
.L_lambda_simple_params_end_040e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_040e
	jmp .L_lambda_simple_end_040e
.L_lambda_simple_code_040e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08d1
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08d1:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_123]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
	push 2
	mov rax, qword [free_var_91]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_122]
.L_lambda_simple_arity_check_ok_08d2:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04c4:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04c4
.L_tc_recycle_frame_done_04c4:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_040e:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_040d:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_040f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_040f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_040f
.L_lambda_simple_env_end_040f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_040f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_040f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_040f
.L_lambda_simple_params_end_040f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_040f
	jmp .L_lambda_simple_end_040f
.L_lambda_simple_code_040f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08d3
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08d3:
	enter 0, 0
	mov rax, qword [free_var_113]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_120], rax
	mov rax, sob_void

	mov rax, qword [free_var_114]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_121], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_040f:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        
	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_124], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_125], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_126], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_127], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_128], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_129], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_130], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_131], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_132], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 0)
	mov qword [free_var_133], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0410:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0410
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0410
.L_lambda_simple_env_end_0410:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0410:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0410
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0410
.L_lambda_simple_params_end_0410:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0410
	jmp .L_lambda_simple_end_0410
.L_lambda_simple_code_0410:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_08d4
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08d4:
	enter 0, 0
	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0411:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0411
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0411
.L_lambda_simple_env_end_0411:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0411:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0411
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0411
.L_lambda_simple_params_end_0411:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0411
	jmp .L_lambda_simple_end_0411
.L_lambda_simple_code_0411:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08d5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08d5:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0412:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0412
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0412
.L_lambda_simple_env_end_0412:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0412:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0412
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0412
.L_lambda_simple_params_end_0412:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0412
	jmp .L_lambda_simple_end_0412
.L_lambda_simple_code_0412:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 5
	je .L_lambda_simple_arity_check_ok_08d6
	push qword [rsp + 8 * 2]
	push 5
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08d6:
	enter 0, 0
mov rax, qword [rbp + 48]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_106]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_026f
mov rax, qword [rbp + 64]
	push rax
mov rax, qword [rbp + 48]
	push rax
	push 2
	mov rax, qword [free_var_102]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_026f
	.L_if_else_026f:
		mov rax, qword (L_constants + 2)
	.L_if_end_026f:
	cmp rax, sob_boolean_false
	jne .L_or_end_004d
mov rax, qword [rbp + 48]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_102]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0270
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 56]
	push rax
	push 2
	mov rax, qword [free_var_47]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 40]
	push rax
	push 2
	mov rax, qword [free_var_47]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	jne .L_or_end_004e
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 56]
	push rax
	push 2
	mov rax, qword [free_var_47]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 40]
	push rax
	push 2
	mov rax, qword [free_var_47]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0271
mov rax, qword [rbp + 64]
	push rax
mov rax, qword [rbp + 56]
	push rax
mov rax, qword [rbp + 48]
	push rax
mov rax, qword [rbp + 40]
	push rax
	mov rax, qword (L_constants + 127)
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_97]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 5
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08d7:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04c5:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04c5
.L_tc_recycle_frame_done_04c5:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0271
	.L_if_else_0271:
		mov rax, qword (L_constants + 2)
	.L_if_end_0271:
.L_or_end_004e:
	jmp .L_if_end_0270
	.L_if_else_0270:
		mov rax, qword (L_constants + 2)
	.L_if_end_0270:
.L_or_end_004d:
	leave
	ret 8 * (2 + 5)
.L_lambda_simple_end_0412:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0413:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0413
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0413
.L_lambda_simple_env_end_0413:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0413:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0413
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0413
.L_lambda_simple_params_end_0413:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0413
	jmp .L_lambda_simple_end_0413
.L_lambda_simple_code_0413:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_08d8
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08d8:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_18]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_18]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0414:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_0414
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0414
.L_lambda_simple_env_end_0414:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0414:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0414
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0414
.L_lambda_simple_params_end_0414:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0414
	jmp .L_lambda_simple_end_0414
.L_lambda_simple_code_0414:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_08d9
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08d9:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_103]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0272
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
	push rax
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
	mov rax, qword (L_constants + 31)
	push rax
	push 5
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08db:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04c7:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04c7
.L_tc_recycle_frame_done_04c7:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0272
	.L_if_else_0272:
	mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
	push rax
	mov rax, qword (L_constants + 31)
	push rax
	push 5
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08da:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04c6:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04c6
.L_tc_recycle_frame_done_04c6:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0272:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0414:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08dc:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04c8:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04c8
.L_tc_recycle_frame_done_04c8:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0413:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0415:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0415
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0415
.L_lambda_simple_env_end_0415:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0415:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0415
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0415
.L_lambda_simple_params_end_0415:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0415
	jmp .L_lambda_simple_end_0415
.L_lambda_simple_code_0415:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08dd
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08dd:
	enter 0, 0
	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0416:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_0416
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0416
.L_lambda_simple_env_end_0416:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0416:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0416
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0416
.L_lambda_simple_params_end_0416:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0416
	jmp .L_lambda_simple_end_0416
.L_lambda_simple_code_0416:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08de
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08de:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0417:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_0417
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0417
.L_lambda_simple_env_end_0417:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0417:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0417
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0417
.L_lambda_simple_params_end_0417:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0417
	jmp .L_lambda_simple_end_0417
.L_lambda_simple_code_0417:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_08df
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08df:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	jne .L_or_end_004f
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0273
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08e0:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04c9:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04c9
.L_tc_recycle_frame_done_04c9:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0273
	.L_if_else_0273:
		mov rax, qword (L_constants + 2)
	.L_if_end_0273:
.L_or_end_004f:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0417:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_009c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_009c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_009c
.L_lambda_opt_env_end_009c:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01d2:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01d2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01d2
.L_lambda_opt_params_end_01d2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_009c
	jmp .L_lambda_opt_end_009c
.L_lambda_opt_code_009c:
mov r10, qword [rsp+8*2]
cmp r10, 1
je .L_lambda_opt_arity_check_exact_009c
cmp r10, 1
jg .L_lambda_opt_arity_check_more_009c
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_009c:
sub rsp, 8
mov rdx, 3+1
mov qword rbx, rsp
.L_lambda_opt_params_loop_01d3:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01d3
jmp .L_lambda_opt_params_loop_01d3
.L_lambda_opt_params_end_01d3:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_009c
.L_lambda_opt_arity_check_more_009c:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 1
.L_lambda_opt_stack_shrink_loop_009c:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_009c
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_009c
.L_lambda_opt_stack_shrink_loop_exit_009c:
mov [rsp+8*(2+2)], rax
mov r10, 2
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+2)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01d4:
cmp r9, 0
je .L_lambda_opt_params_end_01d4
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01d4
.L_lambda_opt_params_end_01d4:
add rsp, r15
.L_lambda_opt_stack_adjusted_009c:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08e1:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04ca:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04ca
.L_tc_recycle_frame_done_04ca:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 1)
.L_lambda_opt_end_009c:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0416:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08e2:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04cb:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04cb
.L_tc_recycle_frame_done_04cb:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0415:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08e3:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04cc:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04cc
.L_tc_recycle_frame_done_04cc:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0411:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08e4:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04cd:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04cd
.L_tc_recycle_frame_done_04cd:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0410:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0418:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0418
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0418
.L_lambda_simple_env_end_0418:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0418:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0418
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0418
.L_lambda_simple_params_end_0418:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0418
	jmp .L_lambda_simple_end_0418
.L_lambda_simple_code_0418:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08e5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08e5:
	enter 0, 0
	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_108]
	push rax
	push 2
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_124], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	mov rax, qword [free_var_115]
	push rax
	push 2
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_129], rax
	mov rax, sob_void

	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_111]
	push rax
	push 2
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_128], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	mov rax, qword [free_var_118]
	push rax
	push 2
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_133], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0418:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        
	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0419:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0419
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0419
.L_lambda_simple_env_end_0419:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0419:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0419
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0419
.L_lambda_simple_params_end_0419:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0419
	jmp .L_lambda_simple_end_0419
.L_lambda_simple_code_0419:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_08e6
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08e6:
	enter 0, 0
	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_041a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_041a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_041a
.L_lambda_simple_env_end_041a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_041a:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_041a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_041a
.L_lambda_simple_params_end_041a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_041a
	jmp .L_lambda_simple_end_041a
.L_lambda_simple_code_041a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08e7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08e7:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_041b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_041b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_041b
.L_lambda_simple_env_end_041b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_041b:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_041b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_041b
.L_lambda_simple_params_end_041b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_041b
	jmp .L_lambda_simple_end_041b
.L_lambda_simple_code_041b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 5
	je .L_lambda_simple_arity_check_ok_08e8
	push qword [rsp + 8 * 2]
	push 5
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08e8:
	enter 0, 0
mov rax, qword [rbp + 48]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_106]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	jne .L_or_end_0050
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 56]
	push rax
	push 2
	mov rax, qword [free_var_47]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 40]
	push rax
	push 2
	mov rax, qword [free_var_47]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	jne .L_or_end_0050
mov rax, qword [rbp + 48]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_102]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0274
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 56]
	push rax
	push 2
	mov rax, qword [free_var_47]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 40]
	push rax
	push 2
	mov rax, qword [free_var_47]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 8]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0275
mov rax, qword [rbp + 64]
	push rax
mov rax, qword [rbp + 56]
	push rax
mov rax, qword [rbp + 48]
	push rax
mov rax, qword [rbp + 40]
	push rax
	mov rax, qword (L_constants + 127)
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_97]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 5
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08e9:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04ce:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04ce
.L_tc_recycle_frame_done_04ce:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0275
	.L_if_else_0275:
		mov rax, qword (L_constants + 2)
	.L_if_end_0275:
	jmp .L_if_end_0274
	.L_if_else_0274:
		mov rax, qword (L_constants + 2)
	.L_if_end_0274:
.L_or_end_0050:
	leave
	ret 8 * (2 + 5)
.L_lambda_simple_end_041b:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_041c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_041c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_041c
.L_lambda_simple_env_end_041c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_041c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_041c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_041c
.L_lambda_simple_params_end_041c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_041c
	jmp .L_lambda_simple_end_041c
.L_lambda_simple_code_041c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_08ea
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08ea:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_18]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_18]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_041d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_041d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_041d
.L_lambda_simple_env_end_041d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_041d:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_041d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_041d
.L_lambda_simple_params_end_041d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_041d
	jmp .L_lambda_simple_end_041d
.L_lambda_simple_code_041d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_08eb
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08eb:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_103]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0276
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
	push rax
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
	mov rax, qword (L_constants + 31)
	push rax
	push 5
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08ed:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04d0:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04d0
.L_tc_recycle_frame_done_04d0:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0276
	.L_if_else_0276:
	mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
	push rax
	mov rax, qword (L_constants + 31)
	push rax
	push 5
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08ec:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04cf:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04cf
.L_tc_recycle_frame_done_04cf:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0276:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_041d:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08ee:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04d1:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04d1
.L_tc_recycle_frame_done_04d1:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_041c:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_041e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_041e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_041e
.L_lambda_simple_env_end_041e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_041e:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_041e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_041e
.L_lambda_simple_params_end_041e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_041e
	jmp .L_lambda_simple_end_041e
.L_lambda_simple_code_041e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08ef
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08ef:
	enter 0, 0
	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_041f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_041f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_041f
.L_lambda_simple_env_end_041f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_041f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_041f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_041f
.L_lambda_simple_params_end_041f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_041f
	jmp .L_lambda_simple_end_041f
.L_lambda_simple_code_041f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08f0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08f0:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0420:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_0420
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0420
.L_lambda_simple_env_end_0420:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0420:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0420
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0420
.L_lambda_simple_params_end_0420:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0420
	jmp .L_lambda_simple_end_0420
.L_lambda_simple_code_0420:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_08f1
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08f1:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	jne .L_or_end_0051
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0277
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08f2:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04d2:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04d2
.L_tc_recycle_frame_done_04d2:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0277
	.L_if_else_0277:
		mov rax, qword (L_constants + 2)
	.L_if_end_0277:
.L_or_end_0051:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0420:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_009d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_009d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_009d
.L_lambda_opt_env_end_009d:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01d5:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01d5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01d5
.L_lambda_opt_params_end_01d5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_009d
	jmp .L_lambda_opt_end_009d
.L_lambda_opt_code_009d:
mov r10, qword [rsp+8*2]
cmp r10, 1
je .L_lambda_opt_arity_check_exact_009d
cmp r10, 1
jg .L_lambda_opt_arity_check_more_009d
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_009d:
sub rsp, 8
mov rdx, 3+1
mov qword rbx, rsp
.L_lambda_opt_params_loop_01d6:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01d6
jmp .L_lambda_opt_params_loop_01d6
.L_lambda_opt_params_end_01d6:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_009d
.L_lambda_opt_arity_check_more_009d:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 1
.L_lambda_opt_stack_shrink_loop_009d:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_009d
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_009d
.L_lambda_opt_stack_shrink_loop_exit_009d:
mov [rsp+8*(2+2)], rax
mov r10, 2
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+2)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01d7:
cmp r9, 0
je .L_lambda_opt_params_end_01d7
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01d7
.L_lambda_opt_params_end_01d7:
add rsp, r15
.L_lambda_opt_stack_adjusted_009d:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08f3:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04d3:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04d3
.L_tc_recycle_frame_done_04d3:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 1)
.L_lambda_opt_end_009d:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_041f:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08f4:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04d4:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04d4
.L_tc_recycle_frame_done_04d4:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_041e:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08f5:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04d5:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04d5
.L_tc_recycle_frame_done_04d5:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_041a:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08f6:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04d6:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04d6
.L_tc_recycle_frame_done_04d6:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0419:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0421:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0421
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0421
.L_lambda_simple_env_end_0421:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0421:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0421
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0421
.L_lambda_simple_params_end_0421:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0421
	jmp .L_lambda_simple_end_0421
.L_lambda_simple_code_0421:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08f7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08f7:
	enter 0, 0
	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_108]
	push rax
	push 2
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_125], rax
	mov rax, sob_void

	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_108]
	push rax
	push 2
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_130], rax
	mov rax, sob_void

	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_111]
	push rax
	push 2
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_127], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	mov rax, qword [free_var_118]
	push rax
	push 2
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_132], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0421:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        
	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0422:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0422
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0422
.L_lambda_simple_env_end_0422:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0422:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0422
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0422
.L_lambda_simple_params_end_0422:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0422
	jmp .L_lambda_simple_end_0422
.L_lambda_simple_code_0422:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08f8
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08f8:
	enter 0, 0
	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0423:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0423
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0423
.L_lambda_simple_env_end_0423:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0423:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0423
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0423
.L_lambda_simple_params_end_0423:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0423
	jmp .L_lambda_simple_end_0423
.L_lambda_simple_code_0423:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_08f9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08f9:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0424:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0424
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0424
.L_lambda_simple_env_end_0424:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0424:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0424
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0424
.L_lambda_simple_params_end_0424:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0424
	jmp .L_lambda_simple_end_0424
.L_lambda_simple_code_0424:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 4
	je .L_lambda_simple_arity_check_ok_08fa
	push qword [rsp + 8 * 2]
	push 4
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08fa:
	enter 0, 0
mov rax, qword [rbp + 56]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_106]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	jne .L_or_end_0052
mov rax, qword [rbp + 56]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_102]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0278
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 48]
	push rax
	push 2
	mov rax, qword [free_var_47]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 40]
	push rax
	push 2
	mov rax, qword [free_var_47]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0279
mov rax, qword [rbp + 56]
	push rax
mov rax, qword [rbp + 48]
	push rax
mov rax, qword [rbp + 40]
	push rax
	mov rax, qword (L_constants + 127)
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_97]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 4
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08fb:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04d7:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04d7
.L_tc_recycle_frame_done_04d7:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0279
	.L_if_else_0279:
		mov rax, qword (L_constants + 2)
	.L_if_end_0279:
	jmp .L_if_end_0278
	.L_if_else_0278:
		mov rax, qword (L_constants + 2)
	.L_if_end_0278:
.L_or_end_0052:
	leave
	ret 8 * (2 + 4)
.L_lambda_simple_end_0424:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0425:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0425
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0425
.L_lambda_simple_env_end_0425:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0425:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0425
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0425
.L_lambda_simple_params_end_0425:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0425
	jmp .L_lambda_simple_end_0425
.L_lambda_simple_code_0425:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_08fc
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08fc:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_18]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_18]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0426:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_0426
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0426
.L_lambda_simple_env_end_0426:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0426:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0426
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0426
.L_lambda_simple_params_end_0426:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0426
	jmp .L_lambda_simple_end_0426
.L_lambda_simple_code_0426:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_08fd
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_08fd:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_106]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_027a
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
	mov rax, qword (L_constants + 31)
	push rax
	push 4
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_08fe:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04d8:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04d8
.L_tc_recycle_frame_done_04d8:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_027a
	.L_if_else_027a:
		mov rax, qword (L_constants + 2)
	.L_if_end_027a:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0426:	; new closure is in rax
.L_lambda_simple_arity_check_ok_08ff:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04d9:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04d9
.L_tc_recycle_frame_done_04d9:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0425:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0427:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0427
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0427
.L_lambda_simple_env_end_0427:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0427:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0427
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0427
.L_lambda_simple_params_end_0427:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0427
	jmp .L_lambda_simple_end_0427
.L_lambda_simple_code_0427:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0900
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0900:
	enter 0, 0
	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0428:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_0428
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0428
.L_lambda_simple_env_end_0428:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0428:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0428
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0428
.L_lambda_simple_params_end_0428:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0428
	jmp .L_lambda_simple_end_0428
.L_lambda_simple_code_0428:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0901
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0901:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0429:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_0429
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0429
.L_lambda_simple_env_end_0429:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0429:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0429
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0429
.L_lambda_simple_params_end_0429:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0429
	jmp .L_lambda_simple_end_0429
.L_lambda_simple_code_0429:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0902
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0902:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	jne .L_or_end_0053
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_027b
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_0903:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04da:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04da
.L_tc_recycle_frame_done_04da:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_027b
	.L_if_else_027b:
		mov rax, qword (L_constants + 2)
	.L_if_end_027b:
.L_or_end_0053:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0429:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_009e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_009e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_009e
.L_lambda_opt_env_end_009e:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01d8:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01d8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01d8
.L_lambda_opt_params_end_01d8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_009e
	jmp .L_lambda_opt_end_009e
.L_lambda_opt_code_009e:
mov r10, qword [rsp+8*2]
cmp r10, 1
je .L_lambda_opt_arity_check_exact_009e
cmp r10, 1
jg .L_lambda_opt_arity_check_more_009e
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_009e:
sub rsp, 8
mov rdx, 3+1
mov qword rbx, rsp
.L_lambda_opt_params_loop_01d9:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01d9
jmp .L_lambda_opt_params_loop_01d9
.L_lambda_opt_params_end_01d9:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_009e
.L_lambda_opt_arity_check_more_009e:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 1
.L_lambda_opt_stack_shrink_loop_009e:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_009e
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_009e
.L_lambda_opt_stack_shrink_loop_exit_009e:
mov [rsp+8*(2+2)], rax
mov r10, 2
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+2)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01da:
cmp r9, 0
je .L_lambda_opt_params_end_01da
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01da
.L_lambda_opt_params_end_01da:
add rsp, r15
.L_lambda_opt_stack_adjusted_009e:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_0904:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04db:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04db
.L_tc_recycle_frame_done_04db:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 1)
.L_lambda_opt_end_009e:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0428:	; new closure is in rax
.L_lambda_simple_arity_check_ok_0905:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04dc:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04dc
.L_tc_recycle_frame_done_04dc:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0427:	; new closure is in rax
.L_lambda_simple_arity_check_ok_0906:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04dd:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04dd
.L_tc_recycle_frame_done_04dd:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0423:	; new closure is in rax
.L_lambda_simple_arity_check_ok_0907:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04de:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04de
.L_tc_recycle_frame_done_04de:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0422:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_042a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_042a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_042a
.L_lambda_simple_env_end_042a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_042a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_042a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_042a
.L_lambda_simple_params_end_042a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_042a
	jmp .L_lambda_simple_end_042a
.L_lambda_simple_code_042a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0908
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0908:
	enter 0, 0
	mov rax, qword [free_var_110]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_126], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	push 1
mov rax, qword [rbp + 32]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_131], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_042a:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        
	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_042b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_042b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_042b
.L_lambda_simple_env_end_042b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_042b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_042b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_042b
.L_lambda_simple_params_end_042b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_042b
	jmp .L_lambda_simple_end_042b
.L_lambda_simple_code_042b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0909
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0909:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_027c
	mov rax, qword (L_constants + 31)
	jmp .L_if_end_027c
	.L_if_else_027c:
	mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_134]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	mov rax, qword (L_constants + 127)
	push rax
	push 2
	mov rax, qword [free_var_97]
.L_lambda_simple_arity_check_ok_090a:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04df:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04df
.L_tc_recycle_frame_done_04df:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_027c:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_042b:	; new closure is in rax
	mov qword [free_var_134], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_042c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_042c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_042c
.L_lambda_simple_env_end_042c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_042c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_042c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_042c
.L_lambda_simple_params_end_042c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_042c
	jmp .L_lambda_simple_end_042c
.L_lambda_simple_code_042c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_090b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_090b:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	jne .L_or_end_0054
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_1]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_027d
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_84]
.L_lambda_simple_arity_check_ok_090c:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04e0:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04e0
.L_tc_recycle_frame_done_04e0:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_027d
	.L_if_else_027d:
		mov rax, qword (L_constants + 2)
	.L_if_end_027d:
.L_or_end_0054:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_042c:	; new closure is in rax
	mov qword [free_var_84], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword [free_var_51]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_042d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_042d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_042d
.L_lambda_simple_env_end_042d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_042d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_042d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_042d
.L_lambda_simple_params_end_042d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_042d
	jmp .L_lambda_simple_end_042d
.L_lambda_simple_code_042d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_090d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_090d:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_009f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_009f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_009f
.L_lambda_opt_env_end_009f:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01db:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01db
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01db
.L_lambda_opt_params_end_01db:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_009f
	jmp .L_lambda_opt_end_009f
.L_lambda_opt_code_009f:
mov r10, qword [rsp+8*2]
cmp r10, 1
je .L_lambda_opt_arity_check_exact_009f
cmp r10, 1
jg .L_lambda_opt_arity_check_more_009f
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_009f:
sub rsp, 8
mov rdx, 3+1
mov qword rbx, rsp
.L_lambda_opt_params_loop_01dc:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01dc
jmp .L_lambda_opt_params_loop_01dc
.L_lambda_opt_params_end_01dc:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_009f
.L_lambda_opt_arity_check_more_009f:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 1
.L_lambda_opt_stack_shrink_loop_009f:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_009f
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_009f
.L_lambda_opt_stack_shrink_loop_exit_009f:
mov [rsp+8*(2+2)], rax
mov r10, 2
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+2)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01dd:
cmp r9, 0
je .L_lambda_opt_params_end_01dd
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01dd
.L_lambda_opt_params_end_01dd:
add rsp, r15
.L_lambda_opt_stack_adjusted_009f:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_027e
	mov rax, qword (L_constants + 0)
	jmp .L_if_end_027e
	.L_if_else_027e:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_1]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0280
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_0280
	.L_if_else_0280:
		mov rax, qword (L_constants + 2)
	.L_if_end_0280:
	cmp rax, sob_boolean_false
	je .L_if_else_027f
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_027f
	.L_if_else_027f:
		mov rax, qword (L_constants + 378)
	push rax
	mov rax, qword (L_constants + 369)
	push rax
	push 2
	mov rax, qword [free_var_38]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	.L_if_end_027f:
	.L_if_end_027e:
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_042e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_042e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_042e
.L_lambda_simple_env_end_042e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_042e:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_042e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_042e
.L_lambda_simple_params_end_042e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_042e
	jmp .L_lambda_simple_end_042e
.L_lambda_simple_code_042e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_090e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_090e:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_090f:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04e1:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04e1
.L_tc_recycle_frame_done_04e1:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_042e:	; new closure is in rax
.L_lambda_simple_arity_check_ok_0910:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04e2:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04e2
.L_tc_recycle_frame_done_04e2:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 1)
.L_lambda_opt_end_009f:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_042d:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_51], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword [free_var_52]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_042f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_042f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_042f
.L_lambda_simple_env_end_042f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_042f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_042f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_042f
.L_lambda_simple_params_end_042f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_042f
	jmp .L_lambda_simple_end_042f
.L_lambda_simple_code_042f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0911
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0911:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_00a0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_00a0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_00a0
.L_lambda_opt_env_end_00a0:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01de:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_01de
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01de
.L_lambda_opt_params_end_01de:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_00a0
	jmp .L_lambda_opt_end_00a0
.L_lambda_opt_code_00a0:
mov r10, qword [rsp+8*2]
cmp r10, 1
je .L_lambda_opt_arity_check_exact_00a0
cmp r10, 1
jg .L_lambda_opt_arity_check_more_00a0
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_00a0:
sub rsp, 8
mov rdx, 3+1
mov qword rbx, rsp
.L_lambda_opt_params_loop_01df:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01df
jmp .L_lambda_opt_params_loop_01df
.L_lambda_opt_params_end_01df:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_00a0
.L_lambda_opt_arity_check_more_00a0:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 1
.L_lambda_opt_stack_shrink_loop_00a0:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_00a0
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_00a0
.L_lambda_opt_stack_shrink_loop_exit_00a0:
mov [rsp+8*(2+2)], rax
mov r10, 2
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+2)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01e0:
cmp r9, 0
je .L_lambda_opt_params_end_01e0
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01e0
.L_lambda_opt_params_end_01e0:
add rsp, r15
.L_lambda_opt_stack_adjusted_00a0:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0281
	mov rax, qword (L_constants + 4)
	jmp .L_if_end_0281
	.L_if_else_0281:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_1]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0283
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_0283
	.L_if_else_0283:
		mov rax, qword (L_constants + 2)
	.L_if_end_0283:
	cmp rax, sob_boolean_false
	je .L_if_else_0282
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_0282
	.L_if_else_0282:
		mov rax, qword (L_constants + 459)
	push rax
	mov rax, qword (L_constants + 450)
	push rax
	push 2
	mov rax, qword [free_var_38]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	.L_if_end_0282:
	.L_if_end_0281:
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0430:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0430
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0430
.L_lambda_simple_env_end_0430:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0430:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0430
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0430
.L_lambda_simple_params_end_0430:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0430
	jmp .L_lambda_simple_end_0430
.L_lambda_simple_code_0430:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0912
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0912:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 8]
mov rax, qword [rax + 0]
.L_lambda_simple_arity_check_ok_0913:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04e3:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04e3
.L_tc_recycle_frame_done_04e3:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0430:	; new closure is in rax
.L_lambda_simple_arity_check_ok_0914:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04e4:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04e4
.L_tc_recycle_frame_done_04e4:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 1)
.L_lambda_opt_end_00a0:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_042f:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_52], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0431:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0431
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0431
.L_lambda_simple_env_end_0431:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0431:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0431
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0431
.L_lambda_simple_params_end_0431:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0431
	jmp .L_lambda_simple_end_0431
.L_lambda_simple_code_0431:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0915
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0915:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0432:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0432
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0432
.L_lambda_simple_env_end_0432:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0432:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0432
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0432
.L_lambda_simple_params_end_0432:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0432
	jmp .L_lambda_simple_end_0432
.L_lambda_simple_code_0432:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0916
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0916:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0284
	mov rax, qword (L_constants + 0)
	push rax
mov rax, qword [rbp + 40]
	push rax
	push 2
	mov rax, qword [free_var_51]
.L_lambda_simple_arity_check_ok_0919:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04e6:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04e6
.L_tc_recycle_frame_done_04e6:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0284
	.L_if_else_0284:
		mov rax, qword (L_constants + 127)
	push rax
mov rax, qword [rbp + 40]
	push rax
	push 2
	mov rax, qword [free_var_97]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0433:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0433
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0433
.L_lambda_simple_env_end_0433:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0433:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0433
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0433
.L_lambda_simple_params_end_0433:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0433
	jmp .L_lambda_simple_end_0433
.L_lambda_simple_code_0433:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0917
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0917:
	enter 0, 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 3
	mov rax, qword [free_var_49]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        
mov rax, qword [rbp + 32]
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0433:	; new closure is in rax
.L_lambda_simple_arity_check_ok_0918:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04e5:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04e5
.L_tc_recycle_frame_done_04e5:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0284:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0432:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0434:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0434
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0434
.L_lambda_simple_env_end_0434:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0434:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0434
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0434
.L_lambda_simple_params_end_0434:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0434
	jmp .L_lambda_simple_end_0434
.L_lambda_simple_code_0434:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_091a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_091a:
	enter 0, 0
	mov rax, qword (L_constants + 31)
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_091b:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04e7:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04e7
.L_tc_recycle_frame_done_04e7:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0434:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0431:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_135], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0435:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0435
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0435
.L_lambda_simple_env_end_0435:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0435:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0435
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0435
.L_lambda_simple_params_end_0435:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0435
	jmp .L_lambda_simple_end_0435
.L_lambda_simple_code_0435:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_091c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_091c:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0436:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0436
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0436
.L_lambda_simple_env_end_0436:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0436:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0436
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0436
.L_lambda_simple_params_end_0436:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0436
	jmp .L_lambda_simple_end_0436
.L_lambda_simple_code_0436:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_091d
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_091d:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0285
	mov rax, qword (L_constants + 4)
	push rax
mov rax, qword [rbp + 40]
	push rax
	push 2
	mov rax, qword [free_var_52]
.L_lambda_simple_arity_check_ok_0920:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04e9:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04e9
.L_tc_recycle_frame_done_04e9:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0285
	.L_if_else_0285:
		mov rax, qword (L_constants + 127)
	push rax
mov rax, qword [rbp + 40]
	push rax
	push 2
	mov rax, qword [free_var_97]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0437:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0437
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0437
.L_lambda_simple_env_end_0437:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0437:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0437
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0437
.L_lambda_simple_params_end_0437:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0437
	jmp .L_lambda_simple_end_0437
.L_lambda_simple_code_0437:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_091e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_091e:
	enter 0, 0
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 8]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 3
	mov rax, qword [free_var_50]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        
mov rax, qword [rbp + 32]
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0437:	; new closure is in rax
.L_lambda_simple_arity_check_ok_091f:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04e8:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04e8
.L_tc_recycle_frame_done_04e8:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0285:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0436:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0438:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0438
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0438
.L_lambda_simple_env_end_0438:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0438:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0438
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0438
.L_lambda_simple_params_end_0438:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0438
	jmp .L_lambda_simple_end_0438
.L_lambda_simple_code_0438:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0921
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0921:
	enter 0, 0
	mov rax, qword (L_constants + 31)
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_0922:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04ea:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04ea
.L_tc_recycle_frame_done_04ea:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0438:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0435:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_122], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_00a1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_00a1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_00a1
.L_lambda_opt_env_end_00a1:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_01e1:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_01e1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_01e1
.L_lambda_opt_params_end_01e1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_00a1
	jmp .L_lambda_opt_end_00a1
.L_lambda_opt_code_00a1:
mov r10, qword [rsp+8*2]
cmp r10, 0
je .L_lambda_opt_arity_check_exact_00a1
cmp r10, 0
jg .L_lambda_opt_arity_check_more_00a1
jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_00a1:
sub rsp, 8
mov rdx, 3+0
mov qword rbx, rsp
.L_lambda_opt_params_loop_01e2:
mov qword rcx, [rbx+8]
mov qword [rbx], rcx
dec rdx
add rbx, 8
cmp rdx, 0
je .L_lambda_opt_params_end_01e2
jmp .L_lambda_opt_params_loop_01e2
.L_lambda_opt_params_end_01e2:
inc r10
mov qword [rsp+8*2], r10
add r10, 2
mov qword [rsp + 8*(r10)], sob_nil
mov r9, [rbp]
jmp .L_lambda_opt_stack_adjusted_00a1
.L_lambda_opt_arity_check_more_00a1:
mov r13, [rsp+2*8]
mov rax, sob_nil
mov r10, [rsp+2*8]
lea r8, [rsp+ 8*(2+r10)]
sub r10, 0
.L_lambda_opt_stack_shrink_loop_00a1:
cmp r10, 0
je .L_lambda_opt_stack_shrink_loop_exit_00a1
mov rcx, rax
mov rdx, [r8]
mov rdi, 17
call malloc
mov byte [rax], T_pair
mov SOB_PAIR_CDR(rax), rcx
mov SOB_PAIR_CAR(rax), rdx
sub r8, 8
dec r10
jmp .L_lambda_opt_stack_shrink_loop_00a1
.L_lambda_opt_stack_shrink_loop_exit_00a1:
mov [rsp+8*(2+1)], rax
mov r10, 1
mov [rsp+16], r10
mov r12, rsp
add r12, 8*(2+1)
sub r13, [rsp+16]
mov r10, r13
shl r10, 3
mov r15, r10
add r10, r12
mov r9, [rsp+16]
add r9, 3
.L_lambda_opt_params_loop_01e3:
cmp r9, 0
je .L_lambda_opt_params_end_01e3
mov r14, [r12]
mov [r10], r14
sub r12, 8
sub r10, 8
dec r9
jmp .L_lambda_opt_params_loop_01e3
.L_lambda_opt_params_end_01e3:
add rsp, r15
.L_lambda_opt_stack_adjusted_00a1:
mov r9, [rbp]
enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_135]
.L_lambda_simple_arity_check_ok_0923:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04eb:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04eb
.L_tc_recycle_frame_done_04eb:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
leave
mov r9, [rbp]
ret 8 * (3 + 0)
.L_lambda_opt_end_00a1:	; new closure is in rax
	mov qword [free_var_136], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0439:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0439
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0439
.L_lambda_simple_env_end_0439:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0439:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0439
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0439
.L_lambda_simple_params_end_0439:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0439
	jmp .L_lambda_simple_end_0439
.L_lambda_simple_code_0439:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0924
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0924:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_043a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_043a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_043a
.L_lambda_simple_env_end_043a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_043a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_043a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_043a
.L_lambda_simple_params_end_043a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_043a
	jmp .L_lambda_simple_end_043a
.L_lambda_simple_code_043a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_0925
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0925:
	enter 0, 0
mov rax, qword [rbp + 48]
	push rax
mov rax, qword [rbp + 40]
	push rax
	push 2
	mov rax, qword [free_var_102]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0286
mov rax, qword [rbp + 48]
	push rax
	mov rax, qword (L_constants + 127)
	push rax
mov rax, qword [rbp + 40]
	push rax
	push 2
	mov rax, qword [free_var_97]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 3
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_47]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_13]
.L_lambda_simple_arity_check_ok_0926:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04ec:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04ec
.L_tc_recycle_frame_done_04ec:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0286
	.L_if_else_0286:
		mov rax, qword (L_constants + 1)
	.L_if_end_0286:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_043a:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_043b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_043b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_043b
.L_lambda_simple_env_end_043b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_043b:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_043b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_043b
.L_lambda_simple_params_end_043b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_043b
	jmp .L_lambda_simple_end_043b
.L_lambda_simple_code_043b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0927
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0927:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_18]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	mov rax, qword (L_constants + 31)
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 3
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_0928:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04ed:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04ed
.L_tc_recycle_frame_done_04ed:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_043b:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0439:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_123], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 22)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_043c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_043c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_043c
.L_lambda_simple_env_end_043c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_043c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_043c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_043c
.L_lambda_simple_params_end_043c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_043c
	jmp .L_lambda_simple_end_043c
.L_lambda_simple_code_043c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0929
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0929:
	enter 0, 0
mov rax, qword [rbp + 32]
mov rdi, 8
mov rbx, rax
call malloc
mov qword [rax], rbx
mov qword [rbp + 32], rax
mov rax, sob_void
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_043d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_043d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_043d
.L_lambda_simple_env_end_043d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_043d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_043d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_043d
.L_lambda_simple_params_end_043d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_043d
	jmp .L_lambda_simple_end_043d
.L_lambda_simple_code_043d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_092a
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_092a:
	enter 0, 0
mov rax, qword [rbp + 48]
	push rax
mov rax, qword [rbp + 40]
	push rax
	push 2
	mov rax, qword [free_var_102]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0287
mov rax, qword [rbp + 48]
	push rax
	mov rax, qword (L_constants + 127)
	push rax
mov rax, qword [rbp + 40]
	push rax
	push 2
	mov rax, qword [free_var_97]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 3
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_48]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_13]
.L_lambda_simple_arity_check_ok_092b:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04ee:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04ee
.L_tc_recycle_frame_done_04ee:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0287
	.L_if_else_0287:
		mov rax, qword (L_constants + 1)
	.L_if_end_0287:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_043d:	; new closure is in rax
push rax
mov rax, qword [rbp + 32]
pop qword [rax]
mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_043e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_043e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_043e
.L_lambda_simple_env_end_043e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_043e:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_043e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_043e
.L_lambda_simple_params_end_043e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_043e
	jmp .L_lambda_simple_end_043e
.L_lambda_simple_code_043e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_092c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_092c:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_19]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	mov rax, qword (L_constants + 31)
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 3
mov rax, qword [rbp + 16]
mov rax, qword [rax + 0]
mov rax, qword [rax + 0]
	mov rax, qword [rax]
.L_lambda_simple_arity_check_ok_092d:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04ef:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04ef
.L_tc_recycle_frame_done_04ef:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_043e:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_043c:	; new closure is in rax
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	mov qword [free_var_137], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_043f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_043f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_043f
.L_lambda_simple_env_end_043f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_043f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_043f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_043f
.L_lambda_simple_params_end_043f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_043f
	jmp .L_lambda_simple_end_043f
.L_lambda_simple_code_043f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_092e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_092e:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 0
	mov rax, qword [free_var_26]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_44]
.L_lambda_simple_arity_check_ok_092f:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04f0:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04f0
.L_tc_recycle_frame_done_04f0:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_043f:	; new closure is in rax
	mov qword [free_var_138], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0440:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0440
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0440
.L_lambda_simple_env_end_0440:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0440:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0440
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0440
.L_lambda_simple_params_end_0440:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0440
	jmp .L_lambda_simple_end_0440
.L_lambda_simple_code_0440:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0930
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0930:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	mov rax, qword (L_constants + 31)
	push rax
	push 2
	mov rax, qword [free_var_102]
.L_lambda_simple_arity_check_ok_0931:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04f1:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04f1
.L_tc_recycle_frame_done_04f1:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0440:	; new closure is in rax
	mov qword [free_var_139], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0441:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0441
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0441
.L_lambda_simple_env_end_0441:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0441:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0441
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0441
.L_lambda_simple_params_end_0441:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0441
	jmp .L_lambda_simple_end_0441
.L_lambda_simple_code_0441:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0932
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0932:
	enter 0, 0
	mov rax, qword (L_constants + 31)
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_102]
.L_lambda_simple_arity_check_ok_0933:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04f2:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04f2
.L_tc_recycle_frame_done_04f2:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0441:	; new closure is in rax
	mov qword [free_var_140], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0442:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0442
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0442
.L_lambda_simple_env_end_0442:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0442:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0442
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0442
.L_lambda_simple_params_end_0442:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0442
	jmp .L_lambda_simple_end_0442
.L_lambda_simple_code_0442:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0934
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0934:
	enter 0, 0
	mov rax, qword (L_constants + 511)
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_44]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_27]
.L_lambda_simple_arity_check_ok_0935:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04f3:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04f3
.L_tc_recycle_frame_done_04f3:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0442:	; new closure is in rax
	mov qword [free_var_141], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0443:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0443
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0443
.L_lambda_simple_env_end_0443:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0443:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0443
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0443
.L_lambda_simple_params_end_0443:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0443
	jmp .L_lambda_simple_end_0443
.L_lambda_simple_code_0443:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0936
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0936:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_141]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 1
	mov rax, qword [free_var_86]
.L_lambda_simple_arity_check_ok_0937:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04f4:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04f4
.L_tc_recycle_frame_done_04f4:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0443:	; new closure is in rax
	mov qword [free_var_142], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0444:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0444
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0444
.L_lambda_simple_env_end_0444:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0444:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0444
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0444
.L_lambda_simple_params_end_0444:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0444
	jmp .L_lambda_simple_end_0444
.L_lambda_simple_code_0444:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0938
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0938:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_140]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0288
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_98]
.L_lambda_simple_arity_check_ok_0939:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04f5:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04f5
.L_tc_recycle_frame_done_04f5:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0288
	.L_if_else_0288:
	mov rax, qword [rbp + 32]
	.L_if_end_0288:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0444:	; new closure is in rax
	mov qword [free_var_143], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0445:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0445
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0445
.L_lambda_simple_env_end_0445:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0445:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0445
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0445
.L_lambda_simple_params_end_0445:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0445
	jmp .L_lambda_simple_end_0445
.L_lambda_simple_code_0445:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_093a
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_093a:
	enter 0, 0
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_1]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0291
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_1]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_0291
	.L_if_else_0291:
		mov rax, qword (L_constants + 2)
	.L_if_end_0291:
	cmp rax, sob_boolean_false
	je .L_if_else_0289
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_16]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_144]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0290
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_144]
.L_lambda_simple_arity_check_ok_093e:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04f9:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04f9
.L_tc_recycle_frame_done_04f9:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0290
	.L_if_else_0290:
		mov rax, qword (L_constants + 2)
	.L_if_end_0290:
	jmp .L_if_end_0289
	.L_if_else_0289:
	mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_6]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_028e
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_6]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_028f
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_19]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_19]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_106]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_028f
	.L_if_else_028f:
		mov rax, qword (L_constants + 2)
	.L_if_end_028f:
	jmp .L_if_end_028e
	.L_if_else_028e:
		mov rax, qword (L_constants + 2)
	.L_if_end_028e:
	cmp rax, sob_boolean_false
	je .L_if_else_028a
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_137]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_137]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_144]
.L_lambda_simple_arity_check_ok_093d:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04f8:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04f8
.L_tc_recycle_frame_done_04f8:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_028a
	.L_if_else_028a:
	mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_4]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_028c
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_4]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_028d
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_18]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 1
	mov rax, qword [free_var_18]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_106]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	jmp .L_if_end_028d
	.L_if_else_028d:
		mov rax, qword (L_constants + 2)
	.L_if_end_028d:
	jmp .L_if_end_028c
	.L_if_else_028c:
		mov rax, qword (L_constants + 2)
	.L_if_end_028c:
	cmp rax, sob_boolean_false
	je .L_if_else_028b
mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_126]
.L_lambda_simple_arity_check_ok_093c:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04f7:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04f7
.L_tc_recycle_frame_done_04f7:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_028b
	.L_if_else_028b:
	mov rax, qword [rbp + 40]
	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_55]
.L_lambda_simple_arity_check_ok_093b:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04f6:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04f6
.L_tc_recycle_frame_done_04f6:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_028b:
	.L_if_end_028a:
	.L_if_end_0289:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0445:	; new closure is in rax
	mov qword [free_var_144], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_0446:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0446
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0446
.L_lambda_simple_env_end_0446:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0446:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0446
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0446
.L_lambda_simple_params_end_0446:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0446
	jmp .L_lambda_simple_end_0446
.L_lambda_simple_code_0446:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_093f
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_093f:
	enter 0, 0
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_0]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0292
	mov rax, qword (L_constants + 2)
	jmp .L_if_end_0292
	.L_if_else_0292:
	mov rax, qword [rbp + 32]
	push rax
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_56]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
	push 2
	mov rax, qword [free_var_55]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	cmp rax, sob_boolean_false
	je .L_if_else_0293
mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_16]
.L_lambda_simple_arity_check_ok_0941:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04fb:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04fb
.L_tc_recycle_frame_done_04fb:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	jmp .L_if_end_0293
	.L_if_else_0293:
	mov rax, qword [rbp + 40]
	push rax
	push 1
	mov rax, qword [free_var_17]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        	push rax
mov rax, qword [rbp + 32]
	push rax
	push 2
	mov rax, qword [free_var_145]
.L_lambda_simple_arity_check_ok_0940:
	cmp byte [rax], T_closure

        jne L_code_ptr_error                      ; rax <- proc


        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)

        push rbx                                  ; env pushed

        push qword [ rbp + 8 * 1]                 ; old ret addr pushed

        ; sagydebug

        push qword [ rbp ]                        ; the same old rbp pushed

        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n

        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m


        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy
.L_tc_recycle_frame_loop_04fa:
	mov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code

        mov [rbp + (r12 * 8)], r14



        mov r14, 0                                ; clean box


        add r15, -1           
        add r10, -1                               ; args_copied_counter--

        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?
	jne .L_tc_recycle_frame_loop_04fa
.L_tc_recycle_frame_done_04fa:
;this pop rbp in sot to the right place
mov r15, r8

        add r15, 4

        shl r15, 3

        add rsp, r15
	pop rbp                                  ; restore the old rbp

        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)
          ; rbx <- code(proc)

        jmp rbx
	.L_if_end_0293:
	.L_if_end_0292:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0446:	; new closure is in rax
	mov qword [free_var_145], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword (L_constants + 647)
	push rax
	mov rax, qword [free_var_97]
	push rax
	push 2
	mov rax, qword [free_var_89]
	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)

        push rbx

        call SOB_CLOSURE_CODE(rax)

        
	mov rdi, rax
	call print_sexpr_if_not_void

        mov rdi, fmt_memory_usage
        mov rsi, qword [top_of_memory]
        sub rsi, memory
        mov rax, 0
	ENTER
        call printf
	LEAVE
	leave
	ret

L_error_non_closure:
        mov rdi, qword [stderr]
        mov rsi, fmt_non_closure
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -2
        call exit

L_error_improper_list:
	mov rdi, qword [stderr]
	mov rsi, fmt_error_improper_list
	mov rax, 0
	ENTER
	call fprintf
	LEAVE
	mov rax, -7
	call exit

L_error_incorrect_arity_simple:
        mov rdi, qword [stderr]
        mov rsi, fmt_incorrect_arity_simple
        jmp L_error_incorrect_arity_common
L_error_incorrect_arity_opt:
        mov rdi, qword [stderr]
        mov rsi, fmt_incorrect_arity_opt
L_error_incorrect_arity_common:
        pop rdx
        pop rcx
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -6
        call exit

section .data
fmt_incorrect_arity_simple:
        db `!!! Expected %ld arguments, but given %ld\n\0`
fmt_incorrect_arity_opt:
        db `!!! Expected at least %ld arguments, but given %ld\n\0`
fmt_memory_usage:
        db `\n\n!!! Used %ld bytes of dynamically-allocated memory\n\n\0`
fmt_non_closure:
        db `!!! Attempting to apply a non-closure!\n\0`
fmt_error_improper_list:
	db `!!! The argument is not a proper list!\n\0`

section .bss
memory:
	resb gbytes(1)

section .data
top_of_memory:
        dq memory

section .text
malloc:
        mov rax, qword [top_of_memory]
        add qword [top_of_memory], rdi
        ret
        
print_sexpr_if_not_void:
	cmp rdi, sob_void
	jne print_sexpr
	ret

section .data
fmt_void:
	db `#<void>\0`
fmt_nil:
	db `()\0`
fmt_boolean_false:
	db `#f\0`
fmt_boolean_true:
	db `#t\0`
fmt_char_backslash:
	db `#\\\\\0`
fmt_char_dquote:
	db `#\\"\0`
fmt_char_simple:
	db `#\\%c\0`
fmt_char_null:
	db `#\\nul\0`
fmt_char_bell:
	db `#\\bell\0`
fmt_char_backspace:
	db `#\\backspace\0`
fmt_char_tab:
	db `#\\tab\0`
fmt_char_newline:
	db `#\\newline\0`
fmt_char_formfeed:
	db `#\\page\0`
fmt_char_return:
	db `#\\return\0`
fmt_char_escape:
	db `#\\esc\0`
fmt_char_space:
	db `#\\space\0`
fmt_char_hex:
	db `#\\x%02X\0`
fmt_closure:
	db `#<closure at 0x%08X env=0x%08X code=0x%08X>\0`
fmt_lparen:
	db `(\0`
fmt_dotted_pair:
	db ` . \0`
fmt_rparen:
	db `)\0`
fmt_space:
	db ` \0`
fmt_empty_vector:
	db `#()\0`
fmt_vector:
	db `#(\0`
fmt_real:
	db `%f\0`
fmt_fraction:
	db `%ld/%ld\0`
fmt_zero:
	db `0\0`
fmt_int:
	db `%ld\0`
fmt_unknown_sexpr_error:
	db `\n\n!!! Error: Unknown type of sexpr (0x%02X) `
	db `at address 0x%08X\n\n\0`
fmt_dquote:
	db `\"\0`
fmt_string_char:
        db `%c\0`
fmt_string_char_7:
        db `\\a\0`
fmt_string_char_8:
        db `\\b\0`
fmt_string_char_9:
        db `\\t\0`
fmt_string_char_10:
        db `\\n\0`
fmt_string_char_11:
        db `\\v\0`
fmt_string_char_12:
        db `\\f\0`
fmt_string_char_13:
        db `\\r\0`
fmt_string_char_34:
        db `\\"\0`
fmt_string_char_92:
        db `\\\\\0`
fmt_string_char_hex:
        db `\\x%X;\0`

section .text

print_sexpr:
	ENTER
	mov al, byte [rdi]
	cmp al, T_void
	je .Lvoid
	cmp al, T_nil
	je .Lnil
	cmp al, T_boolean_false
	je .Lboolean_false
	cmp al, T_boolean_true
	je .Lboolean_true
	cmp al, T_char
	je .Lchar
	cmp al, T_symbol
	je .Lsymbol
	cmp al, T_pair
	je .Lpair
	cmp al, T_vector
	je .Lvector
	cmp al, T_closure
	je .Lclosure
	cmp al, T_real
	je .Lreal
	cmp al, T_rational
	je .Lrational
	cmp al, T_string
	je .Lstring

	jmp .Lunknown_sexpr_type

.Lvoid:
	mov rdi, fmt_void
	jmp .Lemit

.Lnil:
	mov rdi, fmt_nil
	jmp .Lemit

.Lboolean_false:
	mov rdi, fmt_boolean_false
	jmp .Lemit

.Lboolean_true:
	mov rdi, fmt_boolean_true
	jmp .Lemit

.Lchar:
	mov al, byte [rdi + 1]
	cmp al, ' '
	jle .Lchar_whitespace
	cmp al, 92 		; backslash
	je .Lchar_backslash
	cmp al, '"'
	je .Lchar_dquote
	and rax, 255
	mov rdi, fmt_char_simple
	mov rsi, rax
	jmp .Lemit

.Lchar_whitespace:
	cmp al, 0
	je .Lchar_null
	cmp al, 7
	je .Lchar_bell
	cmp al, 8
	je .Lchar_backspace
	cmp al, 9
	je .Lchar_tab
	cmp al, 10
	je .Lchar_newline
	cmp al, 12
	je .Lchar_formfeed
	cmp al, 13
	je .Lchar_return
	cmp al, 27
	je .Lchar_escape
	and rax, 255
	cmp al, ' '
	je .Lchar_space
	mov rdi, fmt_char_hex
	mov rsi, rax
	jmp .Lemit	

.Lchar_backslash:
	mov rdi, fmt_char_backslash
	jmp .Lemit

.Lchar_dquote:
	mov rdi, fmt_char_dquote
	jmp .Lemit

.Lchar_null:
	mov rdi, fmt_char_null
	jmp .Lemit

.Lchar_bell:
	mov rdi, fmt_char_bell
	jmp .Lemit

.Lchar_backspace:
	mov rdi, fmt_char_backspace
	jmp .Lemit

.Lchar_tab:
	mov rdi, fmt_char_tab
	jmp .Lemit

.Lchar_newline:
	mov rdi, fmt_char_newline
	jmp .Lemit

.Lchar_formfeed:
	mov rdi, fmt_char_formfeed
	jmp .Lemit

.Lchar_return:
	mov rdi, fmt_char_return
	jmp .Lemit

.Lchar_escape:
	mov rdi, fmt_char_escape
	jmp .Lemit

.Lchar_space:
	mov rdi, fmt_char_space
	jmp .Lemit

.Lclosure:
	mov rsi, qword rdi
	mov rdi, fmt_closure
	mov rdx, SOB_CLOSURE_ENV(rsi)
	mov rcx, SOB_CLOSURE_CODE(rsi)
	jmp .Lemit

.Lsymbol:
	mov rdi, qword [rdi + 1] ; sob_string
	mov rsi, 1		 ; size = 1 byte
	mov rdx, qword [rdi + 1] ; length
	lea rdi, [rdi + 1 + 8]	 ; actual characters
	mov rcx, qword [stdout]	 ; FILE *
	call fwrite
	jmp .Lend
	
.Lpair:
	push rdi
	mov rdi, fmt_lparen
	mov rax, 0
        ENTER
	call printf
        LEAVE
	mov rdi, qword [rsp] 	; pair
	mov rdi, SOB_PAIR_CAR(rdi)
	call print_sexpr
	pop rdi 		; pair
	mov rdi, SOB_PAIR_CDR(rdi)
.Lcdr:
	mov al, byte [rdi]
	cmp al, T_nil
	je .Lcdr_nil
	cmp al, T_pair
	je .Lcdr_pair
	push rdi
	mov rdi, fmt_dotted_pair
	mov rax, 0
	ENTER
	call printf
	LEAVE
	pop rdi
	call print_sexpr
	mov rdi, fmt_rparen
	mov rax, 0
	ENTER
	call printf
	LEAVE
	LEAVE
	ret

.Lcdr_nil:
	mov rdi, fmt_rparen
	mov rax, 0
	ENTER
	call printf
	LEAVE
	LEAVE
	ret

.Lcdr_pair:
	push rdi
	mov rdi, fmt_space
	mov rax, 0
	ENTER
	call printf
	LEAVE
	mov rdi, qword [rsp]
	mov rdi, SOB_PAIR_CAR(rdi)
	call print_sexpr
	pop rdi
	mov rdi, SOB_PAIR_CDR(rdi)
	jmp .Lcdr

.Lvector:
	mov rax, qword [rdi + 1] ; length
	cmp rax, 0
	je .Lvector_empty
	push rdi
	mov rdi, fmt_vector
	mov rax, 0
	ENTER
	call printf
	LEAVE
	mov rdi, qword [rsp]
	push qword [rdi + 1]
	push 1
	mov rdi, qword [rdi + 1 + 8] ; v[0]
	call print_sexpr
.Lvector_loop:
	; [rsp] index
	; [rsp + 8*1] limit
	; [rsp + 8*2] vector
	mov rax, qword [rsp]
	cmp rax, qword [rsp + 8*1]
	je .Lvector_end
	mov rdi, fmt_space
	mov rax, 0
	ENTER
	call printf
	LEAVE
	mov rax, qword [rsp]
	mov rbx, qword [rsp + 8*2]
	mov rdi, qword [rbx + 1 + 8 + 8 * rax] ; v[i]
	call print_sexpr
	inc qword [rsp]
	jmp .Lvector_loop

.Lvector_end:
	add rsp, 8*3
	mov rdi, fmt_rparen
	jmp .Lemit	

.Lvector_empty:
	mov rdi, fmt_empty_vector
	jmp .Lemit

.Lreal:
	push qword [rdi + 1]
	movsd xmm0, qword [rsp]
	add rsp, 8*1
	mov rdi, fmt_real
	mov rax, 1
	ENTER
	call printf
	LEAVE
	jmp .Lend

.Lrational:
	mov rsi, qword [rdi + 1]
	mov rdx, qword [rdi + 1 + 8]
	cmp rsi, 0
	je .Lrat_zero
	cmp rdx, 1
	je .Lrat_int
	mov rdi, fmt_fraction
	jmp .Lemit

.Lrat_zero:
	mov rdi, fmt_zero
	jmp .Lemit

.Lrat_int:
	mov rdi, fmt_int
	jmp .Lemit

.Lstring:
	lea rax, [rdi + 1 + 8]
	push rax
	push qword [rdi + 1]
	mov rdi, fmt_dquote
	mov rax, 0
	ENTER
	call printf
	LEAVE
.Lstring_loop:
	; qword [rsp]: limit
	; qword [rsp + 8*1]: char *
	cmp qword [rsp], 0
	je .Lstring_end
	mov rax, qword [rsp + 8*1]
	mov al, byte [rax]
	and rax, 255
	cmp al, 7
        je .Lstring_char_7
        cmp al, 8
        je .Lstring_char_8
        cmp al, 9
        je .Lstring_char_9
        cmp al, 10
        je .Lstring_char_10
        cmp al, 11
        je .Lstring_char_11
        cmp al, 12
        je .Lstring_char_12
        cmp al, 13
        je .Lstring_char_13
        cmp al, 34
        je .Lstring_char_34
        cmp al, 92              ; \
        je .Lstring_char_92
        cmp al, ' '
        jl .Lstring_char_hex
        mov rdi, fmt_string_char
        mov rsi, rax
.Lstring_char_emit:
        mov rax, 0
        ENTER
        call printf
        LEAVE
        dec qword [rsp]
        inc qword [rsp + 8*1]
        jmp .Lstring_loop

.Lstring_char_7:
        mov rdi, fmt_string_char_7
        jmp .Lstring_char_emit

.Lstring_char_8:
        mov rdi, fmt_string_char_8
        jmp .Lstring_char_emit
        
.Lstring_char_9:
        mov rdi, fmt_string_char_9
        jmp .Lstring_char_emit

.Lstring_char_10:
        mov rdi, fmt_string_char_10
        jmp .Lstring_char_emit

.Lstring_char_11:
        mov rdi, fmt_string_char_11
        jmp .Lstring_char_emit

.Lstring_char_12:
        mov rdi, fmt_string_char_12
        jmp .Lstring_char_emit

.Lstring_char_13:
        mov rdi, fmt_string_char_13
        jmp .Lstring_char_emit

.Lstring_char_34:
        mov rdi, fmt_string_char_34
        jmp .Lstring_char_emit

.Lstring_char_92:
        mov rdi, fmt_string_char_92
        jmp .Lstring_char_emit

.Lstring_char_hex:
        mov rdi, fmt_string_char_hex
        mov rsi, rax
        jmp .Lstring_char_emit        

.Lstring_end:
	add rsp, 8 * 2
	mov rdi, fmt_dquote
	jmp .Lemit

.Lunknown_sexpr_type:
	mov rsi, fmt_unknown_sexpr_error
	and rax, 255
	mov rdx, rax
	mov rcx, rdi
	mov rdi, qword [stderr]
	mov rax, 0
	ENTER
	call fprintf
	LEAVE
	mov rax, -1
	call exit

.Lemit:
	mov rax, 0
	ENTER
	call printf
	LEAVE
	jmp .Lend

.Lend:
	LEAVE
	ret

;;; rdi: address of free variable
;;; rsi: address of code-pointer
bind_primitive:
        ENTER
        push rdi
        mov rdi, (1 + 8 + 8)
        call malloc
        pop rdi
        mov byte [rax], T_closure
        mov SOB_CLOSURE_ENV(rax), 0 ; dummy, lexical environment
        mov SOB_CLOSURE_CODE(rax), rsi ; code pointer
        mov qword [rdi], rax
        LEAVE
        ret


;;; PLEASE IMPLEMENT THIS PROCEDURE
; (* cuurent version!*)
L_code_ptr_bin_apply:
        mov rcx, qword [rsp]
        mov r8, [rsp +  2 * 8]                          ; r8 <- num_of_args
        cmp r8, 2       
        jne L_error_arg_count_2                         ; check right number of parameters.           

        mov r8, qword [rsp + 4 * 8]                     ; r8 <- list_of_args
        assert_pair(r8)

        cmp byte [r8], T_nil 
        je L_error_arg_count_0                       ; list.length == 0 ?

        mov r11, 0                                      ; list_asrgs_counter init

        mov r12, qword [rsp + 3 * 8]                    ; r12 <- proc
        cmp byte [rax], T_closure
        jne L_error_non_closure

        mov r14, qword [rsp]                            ; r14 <- ret address
        add rsp, 5 * 8                                  ; set rsp to override the last args
                                                        ; similliar to 4 pops.

.L_list_of_args_not_empty_yet:

        assert_pair(r8)
        mov r9, qword SOB_PAIR_CAR(r8)                  ; r9 <- car(list)
        push r9                                         ; * push arg *
        
        add r11, 1                                      ; args_counter ++

        mov r10, qword SOB_PAIR_CDR(r8)                 
        mov r8, qword r10                               ; r8 <- cdr(list)
 
        cmp byte [r8], T_nil                            ; rest of the list is empty?
        jne .L_list_of_args_not_empty_yet               

.L_list_of_args_totally_pushed:

        push r11                                        ; * push args_counter *

        mov r13, SOB_CLOSURE_ENV(r12)                   ; r13 <- proc.env
        push r13                                        ; * push proc env *

        push r14                                        ; * push return address *


.L_flip_args_order:
        mov r8, r11  
        add r8, -1                                      ; limit                              
        mov r10, qword 0
        
.L_flip_loop:
        cmp r8, 0
        je .L_end_of_flip_loop
        mov r15, qword [rsp + (2 + r11) * 8]                    ; r15 <- top
        mov r14, qword [rsp + (3 + r10) * 8]                    ;  r14 <- down
        mov [rsp + (2 + r11) * 8], qword r14                    ; swap
        mov [rsp + (3 + r10) * 8], qword r15                    

        add r10, 1
        add r11, -1

        add r8, -2                                      ; arg_left_to_swap -= 2

        cmp r8, 0
        jg .L_flip_loop

.L_end_of_flip_loop:
.L_all_args_are_flipped:

        mov r13, SOB_CLOSURE_CODE(r12)
        jmp r13

	
L_code_ptr_is_null:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_nil
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_pair:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_pair
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_is_void:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_void
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_char:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_char
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_string:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_string
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_symbol:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_symbol
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_vector:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_vector
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_closure:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_closure
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_real:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_real
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_rational:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_rational
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_boolean:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        mov bl, byte [rax]
        and bl, T_boolean
        je .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_is_number:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        mov bl, byte [rax]
        and bl, T_number
        je .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_is_collection:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        mov bl, byte [rax]
        and bl, T_collection
        je .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_cons:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rdi, (1 + 8 + 8)
        call malloc
        mov byte [rax], T_pair
        mov rbx, PARAM(0)
        mov SOB_PAIR_CAR(rax), rbx
        mov rbx, PARAM(1)
        mov SOB_PAIR_CDR(rax), rbx
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_display_sexpr:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rdi, PARAM(0)
        call print_sexpr
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_write_char:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_char(rax)
        mov al, SOB_CHAR_VALUE(rax)
        and rax, 255
        mov rdi, fmt_char
        mov rsi, rax
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_car:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rax, SOB_PAIR_CAR(rax)
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_cdr:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rax, SOB_PAIR_CDR(rax)
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_string_length:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_string(rax)
        mov rdi, SOB_STRING_LENGTH(rax)
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_vector_length:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_vector(rax)
        mov rdi, SOB_VECTOR_LENGTH(rax)
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_real_to_integer:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rbx, PARAM(0)
        assert_real(rbx)
        movsd xmm0, qword [rbx + 1]
        cvttsd2si rdi, xmm0
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_exit:
        ENTER
        cmp COUNT, 0
        jne L_error_arg_count_0
        mov rax, 0
        call exit

L_code_ptr_integer_to_real:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_integer(rax)
        push qword [rax + 1]
        cvtsi2sd xmm0, qword [rsp]
        call make_real
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_rational_to_real:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_rational(rax)
        push qword [rax + 1]
        cvtsi2sd xmm0, qword [rsp]
        push qword [rax + 1 + 8]
        cvtsi2sd xmm1, qword [rsp]
        divsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_char_to_integer:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_char(rax)
        mov al, byte [rax + 1]
        and rax, 255
        mov rdi, rax
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_integer_to_char:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_integer(rax)
        mov rbx, qword [rax + 1]
        cmp rbx, 0
        jle L_error_integer_range
        cmp rbx, 256
        jge L_error_integer_range
        mov rdi, (1 + 1)
        call malloc
        mov byte [rax], T_char
        mov byte [rax + 1], bl
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_trng:
        ENTER
        cmp COUNT, 0
        jne L_error_arg_count_0
        rdrand rdi
        shr rdi, 1
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(0)

L_code_ptr_is_zero:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_rational
        je .L_rational
        cmp byte [rax], T_real
        je .L_real
        jmp L_error_incorrect_type
.L_rational:
        cmp qword [rax + 1], 0
        je .L_zero
        jmp .L_not_zero
.L_real:
        pxor xmm0, xmm0
        push qword [rax + 1]
        movsd xmm1, qword [rsp]
        ucomisd xmm0, xmm1
        je .L_zero
.L_not_zero:
        mov rax, sob_boolean_false
        jmp .L_end
.L_zero:
        mov rax, sob_boolean_true
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_integer:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_rational
        jne .L_false
        cmp qword [rax + 1 + 8], 1
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_raw_bin_add_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        addsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_sub_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        subsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_mul_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        mulsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_div_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        pxor xmm2, xmm2
        ucomisd xmm1, xmm2
        je L_error_division_by_zero
        divsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_add_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1 + 8] ; den 2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1]     ; num2
        cqo
        imul rbx
        add rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1 + 8] ; den2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_sub_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1 + 8] ; den 2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1]     ; num2
        cqo
        imul rbx
        sub rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1 + 8] ; den2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_mul_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1] ; num2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1 + 8] ; den2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_raw_bin_div_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        cmp qword [r9 + 1], 0
        je L_error_division_by_zero
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1 + 8] ; den 2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1] ; num2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)
        
normalize_rational:
        push rsi
        push rdi
        call gcd
        mov rbx, rax
        pop rax
        cqo
        idiv rbx
        mov r8, rax
        pop rax
        cqo
        idiv rbx
        mov r9, rax
        mov rdi, (1 + 8 + 8)
        call malloc
        mov byte [rax], T_rational
        mov qword [rax + 1], r9
        mov qword [rax + 1 + 8], r8
        ret

iabs:
        mov rax, rdi
        cmp rax, 0
        jl .Lneg
        ret
.Lneg:
        neg rax
        ret

gcd:
        call iabs
        mov rbx, rax
        mov rdi, rsi
        call iabs
        cmp rax, 0
        jne .L0
        xchg rax, rbx
.L0:
        cmp rbx, 0
        je .L1
        cqo
        div rbx
        mov rax, rdx
        xchg rax, rbx
        jmp .L0
.L1:
        ret

L_code_ptr_error:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_symbol(rsi)
        mov rsi, PARAM(1)
        assert_string(rsi)
        mov rdi, fmt_scheme_error_part_1
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rdi, PARAM(0)
        call print_sexpr
        mov rdi, fmt_scheme_error_part_2
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rax, PARAM(1)       ; sob_string
        mov rsi, 1              ; size = 1 byte
        mov rdx, qword [rax + 1] ; length
        lea rdi, [rax + 1 + 8]   ; actual characters
        mov rcx, qword [stdout]  ; FILE*
        call fwrite
        mov rdi, fmt_scheme_error_part_3
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rax, -9
        call exit

L_code_ptr_raw_less_than_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_real(rsi)
        mov rdi, PARAM(1)
        assert_real(rdi)
        movsd xmm0, qword [rsi + 1]
        movsd xmm1, qword [rdi + 1]
        comisd xmm0, xmm1
        jae .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_raw_less_than_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_rational(rsi)
        mov rdi, PARAM(1)
        assert_rational(rdi)
        mov rax, qword [rsi + 1] ; num1
        cqo
        imul qword [rdi + 1 + 8] ; den2
        mov rcx, rax
        mov rax, qword [rsi + 1 + 8] ; den1
        cqo
        imul qword [rdi + 1]          ; num2
        sub rcx, rax
        jge .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_equal_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_real(rsi)
        mov rdi, PARAM(1)
        assert_real(rdi)
        movsd xmm0, qword [rsi + 1]
        movsd xmm1, qword [rdi + 1]
        comisd xmm0, xmm1
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_raw_equal_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_rational(rsi)
        mov rdi, PARAM(1)
        assert_rational(rdi)
        mov rax, qword [rsi + 1] ; num1
        cqo
        imul qword [rdi + 1 + 8] ; den2
        mov rcx, rax
        mov rax, qword [rdi + 1 + 8] ; den1
        cqo
        imul qword [rdi + 1]          ; num2
        sub rcx, rax
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_quotient:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_integer(rsi)
        mov rdi, PARAM(1)
        assert_integer(rdi)
        mov rax, qword [rsi + 1]
        mov rbx, qword [rdi + 1]
        cmp rbx, 0
        je L_error_division_by_zero
        cqo
        idiv rbx
        mov rdi, rax
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_remainder:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_integer(rsi)
        mov rdi, PARAM(1)
        assert_integer(rdi)
        mov rax, qword [rsi + 1]
        mov rbx, qword [rdi + 1]
        cmp rbx, 0
        je L_error_division_by_zero
        cqo
        idiv rbx
        mov rdi, rdx
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_set_car:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rbx, PARAM(1)
        mov SOB_PAIR_CAR(rax), rbx
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_set_cdr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rbx, PARAM(1)
        mov SOB_PAIR_CDR(rax), rbx
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_string_ref:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rdi, PARAM(0)
        assert_string(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov bl, byte [rdi + 1 + 8 + 1 * rcx]
        mov rdi, 2
        call malloc
        mov byte [rax], T_char
        mov byte [rax + 1], bl
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_vector_ref:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rdi, PARAM(0)
        assert_vector(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov rax, [rdi + 1 + 8 + 8 * rcx]
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_vector_set:
        ENTER
        cmp COUNT, 3
        jne L_error_arg_count_3
        mov rdi, PARAM(0)
        assert_vector(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov rax, PARAM(2)
        mov qword [rdi + 1 + 8 + 8 * rcx], rax
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(3)

L_code_ptr_string_set:
        ENTER
        cmp COUNT, 3
        jne L_error_arg_count_3
        mov rdi, PARAM(0)
        assert_string(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov rax, PARAM(2)
        assert_char(rax)
        mov al, byte [rax + 1]
        mov byte [rdi + 1 + 8 + 1 * rcx], al
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(3)

L_code_ptr_make_vector:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rcx, PARAM(0)
        assert_integer(rcx)
        mov rcx, qword [rcx + 1]
        cmp rcx, 0
        jl L_error_integer_range
        mov rdx, PARAM(1)
        lea rdi, [1 + 8 + 8 * rcx]
        call malloc
        mov byte [rax], T_vector
        mov qword [rax + 1], rcx
        mov r8, 0
.L0:
        cmp r8, rcx
        je .L1
        mov qword [rax + 1 + 8 + 8 * r8], rdx
        inc r8
        jmp .L0
.L1:
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_make_string:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rcx, PARAM(0)
        assert_integer(rcx)
        mov rcx, qword [rcx + 1]
        cmp rcx, 0
        jl L_error_integer_range
        mov rdx, PARAM(1)
        assert_char(rdx)
        mov dl, byte [rdx + 1]
        lea rdi, [1 + 8 + 1 * rcx]
        call malloc
        mov byte [rax], T_string
        mov qword [rax + 1], rcx
        mov r8, 0
.L0:
        cmp r8, rcx
        je .L1
        mov byte [rax + 1 + 8 + 1 * r8], dl
        inc r8
        jmp .L0
.L1:
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_numerator:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_rational(rax)
        mov rdi, qword [rax + 1]
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_denominator:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_rational(rax)
        mov rdi, qword [rax + 1 + 8]
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_eq:
	ENTER
	cmp COUNT, 2
	jne L_error_arg_count_2
	mov rdi, PARAM(0)
	mov rsi, PARAM(1)
	cmp rdi, rsi
	je .L_eq_true
	mov dl, byte [rdi]
	cmp dl, byte [rsi]
	jne .L_eq_false
	cmp dl, T_char
	je .L_char
	cmp dl, T_symbol
	je .L_symbol
	cmp dl, T_real
	je .L_real
	cmp dl, T_rational
	je .L_rational
	jmp .L_eq_false
.L_rational:
	mov rax, qword [rsi + 1]
	cmp rax, qword [rdi + 1]
	jne .L_eq_false
	mov rax, qword [rsi + 1 + 8]
	cmp rax, qword [rdi + 1 + 8]
	jne .L_eq_false
	jmp .L_eq_true
.L_real:
	mov rax, qword [rsi + 1]
	cmp rax, qword [rdi + 1]
.L_symbol:
	; never reached, because symbols are static!
	; but I'm keeping it in case, I'll ever change
	; the implementation
	mov rax, qword [rsi + 1]
	cmp rax, qword [rdi + 1]
.L_char:
	mov bl, byte [rsi + 1]
	cmp bl, byte [rdi + 1]
	jne .L_eq_false
.L_eq_true:
	mov rax, sob_boolean_true
	jmp .L_eq_exit
.L_eq_false:
	mov rax, sob_boolean_false
.L_eq_exit:
	LEAVE
	ret AND_KILL_FRAME(2)

make_real:
        ENTER
        mov rdi, (1 + 8)
        call malloc
        mov byte [rax], T_real
        movsd qword [rax + 1], xmm0
        LEAVE
        ret
        
make_integer:
        ENTER
        mov rsi, rdi
        mov rdi, (1 + 8 + 8)
        call malloc
        mov byte [rax], T_rational
        mov qword [rax + 1], rsi
        mov qword [rax + 1 + 8], 1
        LEAVE
        ret
        
L_error_integer_range:
        mov rdi, qword [stderr]
        mov rsi, fmt_integer_range
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -5
        call exit

L_error_arg_count_0:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_0
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_1:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_1
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_2:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_2
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_12:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_12
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_3:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_3
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit
        
L_error_incorrect_type:
        mov rdi, qword [stderr]
        mov rsi, fmt_type
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -4
        call exit

L_error_division_by_zero:
        mov rdi, qword [stderr]
        mov rsi, fmt_division_by_zero
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -8
        call exit

section .data
fmt_char:
        db `%c\0`
fmt_arg_count_0:
        db `!!! Expecting zero arguments. Found %d\n\0`
fmt_arg_count_1:
        db `!!! Expecting one argument. Found %d\n\0`
fmt_arg_count_12:
        db `!!! Expecting one required and one optional argument. Found %d\n\0`
fmt_arg_count_2:
        db `!!! Expecting two arguments. Found %d\n\0`
fmt_arg_count_3:
        db `!!! Expecting three arguments. Found %d\n\0`
fmt_type:
        db `!!! Function passed incorrect type\n\0`
fmt_integer_range:
        db `!!! Incorrect integer range\n\0`
fmt_division_by_zero:
        db `!!! Division by zero\n\0`
fmt_scheme_error_part_1:
        db `\n!!! The procedure \0`
fmt_scheme_error_part_2:
        db ` asked to terminate the program\n`
        db `    with the following message:\n\n\0`
fmt_scheme_error_part_3:
        db `\n\nGoodbye!\n\n\0`
