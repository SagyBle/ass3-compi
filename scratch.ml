| ScmIf'(test, dit, dif) -> 
  let if_num = (string_of_int (Stream.next if_gen)) in
    (run test env_size) ^
    "cmp rax, SOB_FALSE_ADDRESS
    je Lelse"^if_num^"
    "^(run dit env_size)^
    "jmp Ifexit"^if_num^"
    Lelse"^if_num^":
    "^(run dif env_size)^
    "Ifexit"^if_num^":
    "


    if test then else:

    rax <- eval(test) **
    compare rax, sob_boolean_false **
    je L_else **
      L_then:
        rax <- eval(then) **
        jmp L_end **
      L_else: **
        rax <- eval(else)
    L_end: 



    (lambda (a b) (+ a b))


  malloc closure size
  malloc parametrs_num ;; for a new rib


  | ScmApplic' (proc, args, Non_Tail_Call) -> raise X_not_yet_implemented

  | ScmApplic' (proc, args, Non_Tail_Call) -> raise X_not_yet_implemented

  proc = ScmVarGet' (Var' ("+", Free))
  args = [ScmVarGet' (Var' ("a", Free)); ScmConst' (ScmNumber (ScmRational (1, 1)))]
  Non_Tail_Call = Non_Tail_Call

    ScmApplic' (ScmVarGet' (Var' ("+", Free)),
    [ScmVarGet' (Var' ("a", Free)); ScmConst' (ScmNumber (ScmRational (1, 1)))],
    Non_Tail_Call)

  run parmas... proc (get_from_freevar_table(proc))

(* bar oz *)

  | ScmApplic'(rator, rands) ->
    let asm_rands_code = List.map (fun rand -> run rand env_size) rands in (* run on every operand and evaluate it *)
    let asm_rands_code = List.rev asm_rands_code in  (* list operands in reverse (matching the c convention) *)
    let arg_count = string_of_int (List.length rands) in (* also needed for the convention *)
    let asm_rator_code = run rator env_size in (* get the operator closure *)
    let last_push_rax = 
    (match arg_count with
    | "0" -> " ;applic code\n"
    | _ -> "push rax ;applic code\n") in  (* closure code pushed first to stack only *)


    let push_args_and_proc_code =  String.concat "push rax ;applic code\n" asm_rands_code in
    let push_args_and_proc_code = push_args_and_proc_code ^ last_push_rax ^ "push "^arg_count^"\n" in
    let push_args_and_proc_code = push_args_and_proc_code ^ asm_rator_code in
    push_args_and_proc_code ^
    "cmp byte [rax], T_CLOSURE
    jne ERROR
    push qword [rax+1]  ; closure env is at SOB_CLOSURE + 1
    call qword [rax+9]  ; closure code is at SOB_CLOSURE + 9
    add rsp, 8*1        ; pop env
    pop rbx             ; pop arg count
    lea rsp, [rsp + 8*rbx]  ; return rsp to previous rsp before pushing args\n"



(* yuval *)

| ScmApplic' (proc,exp_lst) ->(
  let magic = "push SOB_NIL_ADDRESS\n" in 
  let push_args = List.fold_left(fun init item ->item ^ init) "" (List.map (fun ex -> (generate_rec consts fvars ex depth) ^ "\npush rax\n") exp_lst) in
  let push_n = Printf.sprintf "push %d\n" ((List.length exp_lst)+1) in
  let proc_gen = generate_rec consts fvars proc depth in
  let verify = "cmp byte [rax],T_CLOSURE\n" in
  let lable_index = increas_and_get_label() in
  let jump_to_error = "jne ERROR\n"  in

  let push_env = "push qword [rax + TYPE_SIZE]\n" in
  let call = "call [rax+TYPE_SIZE+WORD_SIZE]\n" in
  let clean_lable = Printf.sprintf "Clean%d:\n" lable_index in
  let clean_code = clean_lable ^ "add rsp , 8*1 ; pop env\npop rbx ; pop arg count\nlea rsp , [rsp + 8*rbx]" in
  asm_line "APPLIC" ( magic^push_args^ push_n ^ proc_gen ^ verify ^ jump_to_error ^ push_env ^ call ^ clean_code ))



  magic 
  push_args **
  push_n
  proc_gen **
  verify
  jump_to_error
  push_env
  call
  clean_code





;; TODO: understand
; building closure for apply
mov rdi, free_var_56
mov rsi, L_code_ptr_bin_apply
call bind_primitive


(* how to print: *)
mov rdi, fmt_int
mov rsi, qword 1
mov rax, 0
call printf


(* moving above two pushed args *)
mov rbx, [rsp + 16]
mov [rsp], rbx


(* cancelling push to stack by jumping over *)
; mov rbx, [rsp + n * 8]
; mov [rsp], rbx



L_code_ptr_bin_apply:
        
        ENTER
        cmp COUNT, 3
        jne L_error_arg_count_3

        mov rax, PARAM(0)       ; rax <- closure
        cmp byte [rax], T_closure ;  is it a closure? 
        jne L_error_non_closure ;; if not closure jmp kibinimat
        ; make sure it is a closure                

        
        mov rax, qword PARAM(1)
        ; push rax                ; rax <- list of args

        ;; get car
	; push 1
	; mov rax, qword L_code_ptr_car
	; cmp byte [rax], T_closure 
        ; jne L_code_ptr_error

        ; mov rbx, SOB_CLOSURE_ENV(rax)

        ; push rbx

        ; call SOB_CLOSURE_CODE(rax)

        ; mov rdx, rax ;; keep first arg

        ;; get cadr ***
        ; push 1
	; mov rax, qword L_code_ptr_cdr
	; cmp byte [rax], T_closure 
        ; jne L_code_ptr_error

        ; mov rbx, SOB_CLOSURE_ENV(rax)

        ; push rbx

        ; call SOB_CLOSURE_CODE(rax)

        ; mov rdx, rax ;; keep first arg


        ; mov rbx, [rsp + 1 * 8]
        ; mov [rsp], rbx
        
        ; mov rbx, 2
        ; push rbx

	; cmp byte [rax], T_closure 
        ; jne L_code_ptr_error

        ; mov rbx, SOB_CLOSURE_ENV(rax)
        ; push rbx

        ; call SOB_CLOSURE_CODE(rax)

       LEAVE
        ret AND_KILL_FRAME(0)
        mov rdi, rax
	call print_sexpr_if_not_void

        ; mov rbx, [rsp + 1 * 8]
        ; mov [rsp], rbx

        LEAVE
        ret AND_KILL_FRAME(0)




        (* vvv this one aplly a function on two first args:  vvv*)


        L_code_ptr_bin_apply:
        
        ENTER
        cmp COUNT, 3
        jne L_error_arg_count_3

        mov rax, PARAM(0)       ; rax <- closure
        cmp byte [rax], T_closure ;  is it a closure? 
        jne L_error_non_closure ;; if not closure jmp kibinimat
        ;; make sure it is a closure                

        ;; goal to apply closure on 2 params
        mov rbx, qword PARAM(1)
        push rbx                ; push arg
        mov rcx, qword PARAM(2)
        push rcx                ; push arg
        
        mov rbx, 2
        push rbx

	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)
        push rbx

        call SOB_CLOSURE_CODE(rax)

	; mov rdi, rax
	; call print_sexpr_if_not_void

        LEAVE
        ret AND_KILL_FRAME(3)

    (* ^^^ this one aplly a function on two first args:  ^^^ *)

        



