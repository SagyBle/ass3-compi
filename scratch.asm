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



(* this is how you do car *)
(* assumption: r9 have the pair *)
    mov r9, PARAM(0)   ; param0 is pair
    assert_pair(r9)
    mov rax, SOB_PAIR_CAR(r9)




    let e = Semantic_Analysis.semantics(Tag_Parser.tag_parse((Reader.nt_sexpr str 0).found));;

    
        


    left
    ; ; handle  caddr (car (cdr (cdr list)))
    ; assert_pair(r10)
    ; mov rcx, qword SOB_PAIR_CDR(r10)
    ; mov r10, qword rcx      ; r10 <- cdr
    ; assert_pair(r10)
    ; mov rcx, qword SOB_PAIR_CAR(r10)
    ; push rcx





    L_code_ptr_bin_apply:
        
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2

        mov rax, PARAM(0)       ; rax <- closure
        cmp byte [rax], T_closure ;  is it a closure? 
        jne L_error_non_closure ;; if not closure jmp kibinimat

        
        ; handle cdr
        mov r10, qword PARAM(1)
        assert_pair(r10)
        mov rcx, qword SOB_PAIR_CDR(r10)
        mov r10, qword rcx      ; r10 <- cdr
        assert_pair(r10)
        mov rcx, qword SOB_PAIR_CAR(r10)         ; r11 <- cadr
        mov r11, qword rcx
        push rcx                ; push rcx (cadr) ***

        ; handle car
        mov r9, PARAM(1)   
        assert_pair(r9)
        mov rcx, qword SOB_PAIR_CAR(r9)
        mov r9, qword rcx
        push rcx                ; push car


        
        
        mov rbx, 2
        push rbx

	cmp byte [rax], T_closure 
        jne L_code_ptr_error

        mov rbx, SOB_CLOSURE_ENV(rax)
        push rbx

        call SOB_CLOSURE_CODE(rax)

        mov r9, qword rax

	; mov rdi, rax
	; call print_sexpr_if_not_void

        ; if there are more args left in the list, go to list not done.
        ; get rest of the list
        ; r10 <- cdr already
        assert_pair(r10)
        mov rcx, qword SOB_PAIR_CDR(r10)
        mov r10, qword rcx
        cmp byte [r10], T_nil
        je .L_list_is_done
.L_list_not_done:
        ; r9 <- result, r10 <- rest of the list, r11 <- not relevnt
        assert_pair(r10)
        mov rcx, qword SOB_PAIR_CAR(r10)
        mov r11, qword rcx

        ; r9 <- result, r10 <- rest of the list, r11 <- car(rest of the list)
        push rcx
        mov rcx, qword r9
        push rcx
        mov rbx, 2
        push rbx

        mov rax, PARAM(0)       ; rax <- closure
        cmp byte [rax], T_closure ;  is it a closure? 
        jne L_error_non_closure ;; if not closure jmp kibinimat

        mov rbx, SOB_CLOSURE_ENV(rax)
        push rbx

        call SOB_CLOSURE_CODE(rax)


        ; supposed to do 3 args





.L_list_is_done:
        LEAVE
        ret AND_KILL_FRAME(2)


        

arg0 = +
arg1 = arg_list = (1 2 3 4)



return_address
lex_env(arg0)
num_of_args
arg_list[3]
arg_list[2]
arg_list[1]
arg_list[0]   <- first in stack

jmp to proc (+)













(* Current bin_apply*)

L_code_ptr_bin_apply:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2

        mov r11, 0                                              ; init args_counter with 0

        ;; push all args that in the list

        mov r9, qword PARAM(1)                                  ; r9 <- args_list
        ; assert_pair(r9)
        cmp byte [r9], T_nil 
        je .L_error_with_args_count


        assert_pair(r9)                                         ;
        mov rcx, qword SOB_PAIR_CAR(r9)                         ; rcx <- car(args_list)
        push rcx                                                ; push first arg to stack

        mov r11, (r11 +1)                                      ; increament args_counter
        

        assert_pair(r9)
        mov rcx, qword SOB_PAIR_CDR(r9)                         ; rcx <- rest of the list
        mov r9, qword rcx                                       ; r9 <- rest of the list
        
        cmp byte [r9], T_nil                                    ; check if rest of the list is empty
        je .L_error_with_args_count                             ; if empty go to args error, have to be at least 2
        
.L_list_is_not_done:

        assert_pair(r9)
        mov rcx, qword SOB_PAIR_CAR(r9)                         ; rcx <- car of rest of the list
        push rcx                                                ; push arg

        mov r11, (r11 + 1)                                      ; args_counter++

        assert_pair(r9)
        mov rcx, qword SOB_PAIR_CDR(r9)                         ; rcx <- rest of rest of the list
        mov r9, qword rcx                                       ; r9 <- rest of rest of the list

        cmp byte [r9], T_nil                                    ; check if rest of the list is empty
        jne .L_list_is_not_done 

.L_list_is_done:
        
        push r11                                                ; push num_of_args

        ; invriant: r9 has the proc code
        mov r9, qword PARAM(0)                                  ; arg_proc to r9
        cmp byte [rax], T_closure                               ;  is it a closure? 
        jne L_error_non_closure                                 ; if not closure jmp kibinimat

        mov r10, SOB_CLOSURE_ENV(r9)                            ; get proc env
        push r10                                                ; push closure env to stack


        ; ??? need to push retaddress, which is it ???
        ; ??? need to think about rbp ???

        ;get proc code and jmp
        mov r9, qword PARAM(0)                                  ; arg_proc to r9
        mov r10, SOB_CLOSURE_CODE(r9)
        jmp r10                                                 ; jump to closure code






        (apply + '(1 2 3 4))













        ((lambda () (if #t
                (eq? 0 0)
                (eq? 1 0))))







push all args
push num of args
push lex_env(h) (differne from the previous stack)
ret->f          (similliar to the previous stack)
rbp in f






tail call


| ScmApplic' (proc, args, Tail_Call) ->
        let args_asm_code = List.map (fun (exp) ->  (run params env exp) ^ "\tpush rax\n") args in 
        let args_asm_code = List.fold_left (fun acc lst -> lst ^ acc) "" args_asm_code in 
        let args_num = List.length args in
        let args_num = Printf.sprintf "\tpush %d\n" args_num  in
        let proc_asm_code = run params env proc in 
        let label = make_lambda_simple_arity_ok() in
        let label_end_of_args = make_tc_applic_recycle_frame_done() in
        let label_args_loop = make_tc_applic_recycle_frame_loop() in 

        (Printf.sprintf "%s:\n" label) ^

        args_asm_code ^
        (* ;; all args were pushed to stack *)

        args_num ^
        (* ;; args num were pushed to stack *)
        proc_asm_code ^

        "\tcmp byte [rax], T_closure\n
        jne L_code_ptr_error\n

        (* ;; rax <- proc *)

        mov rbx, SOB_CLOSURE_ENV(rax)\n
        push rbx\n
        push qword [ rbp + 8 * 1]       ; old ret addr\n
        push qword [ rbp ]              ; the same old rbp\n









        | ScmApplic' (proc, args, Tail_Call) ->
                let args_asm_code = List.map (fun (exp) ->  (run params env exp) ^ "\tpush rax\n") args in 
                let args_asm_code = List.fold_left (fun acc lst -> lst ^ acc) "" args_asm_code in 
                let args_num = List.length args in
                let args_num = Printf.sprintf "\tpush %d\n" args_num  in
                let proc_asm_code = run params env proc in 
                let label = make_lambda_simple_arity_ok() in
                let label_end_of_args = make_tc_applic_recycle_frame_done() in
                let label_args_loop = make_tc_applic_recycle_frame_loop() in 
                
                (Printf.sprintf "%s:\n" label) ^
        
                args_asm_code ^
                args_num ^
                proc_asm_code ^
                "\tcmp byte [rax], T_closure\n
                jne L_code_ptr_error\n
                mov rbx, SOB_CLOSURE_ENV(rax)\n
                push rbx\n
                push qword [ rbp + 8 * 1]       ; old ret addr\n
                push qword [ rbp ]              ; the same old rbp\n
                
        
                mov r9, [ rsp + 3 * 8]          ; r9 <- num_of_args
                mov r8, (4 + r9)                ; r8 <- num_of_iterations       not sure r9 or list.length 
                "
                
        
                (Printf.sprintf "%s:\n" label_args_loop) ^    
                "
        
                cmp r8, 0                       ; num_of_iterations_left == 0 ?
                "
                (Printf.sprintf "je %s\n" label_end_of_args) ^
        
                "
                mov r10, [ rsp + (4 + ) * 8 ]        ;  arg to r10
                push r10
                "
        
        
        
                (Printf.sprintf "%s:\n" label_end_of_args) ^
        
                "
                ; copy lex env of h\n
                ; copy the old ret addr -> [ rbp + 8 * 1]\n
                ; copy the same old rbp -> [ rbp ]\n
                "
        


                ; r12 args_copied_counter becomes r12 curr_position_on_stack
                mov r14, r9                               ; r14 <- new_code_num_of_args_m
                mov [r10 - (r12 * 8)], r14                ; new_code_stack[i] <- r14
                mov r14, 0                                ; clean box
        
                mov r12, (r12 + 1)                        ; args_copied_counter++
        
                mov r14, [r11 - (r12 * 8)]                ; r14 <- lexEnv of h
                mov [r10 - (r12 * 8)], r14                ; new_code_stack[i] <- r14 : lexEnv of h
        
                mov r12, (r12 + 1)                        ; args_copied_counter++
        
                mov r14, [r11 - (r12 * 8)]                ; r14 <- ret => f
                mov [r10 - (r12 * 8)], r14                ; new_code_stack[i] <- r14 : ret => f
        
                mov r12, (r12 + 1)                        ; args_copied_counter++
        
        
                mov r14, [r11 - (r12 * 8)]                ; r14 <- rbp in f
                mov [r10 - (r12 * 8)], r14                ; new_code_stack[i] <- r14 : rbp in f
        
                mov r12, (r12 + 1)                        ; args_copied_counter++
        


        problematic
        mov r14, [r11 - (r12 * 8)]                ; r14 <- arg B_m-1
        mov [r10 - (r12 * 8)], r14                ; arg A_m-1 <- r14
        mov r14, [r11 - (r12 * 8)]                ; r14 <- arg B_m-1
        mov [r10 - (r12 * 8)], r14                ; arg A_m-1 <- r14




        | ScmApplic' (proc, args, Tail_Call) ->
                let args_asm_code = List.map (fun (exp) ->  (run params env exp) ^ "\tpush rax\n") args in 
                let args_asm_code = List.fold_left (fun acc lst -> lst ^ acc) "" args_asm_code in 
                let args_num = List.length args in
                let args_num = Printf.sprintf "\tpush %d\n" args_num  in
                let proc_asm_code = run params env proc in 
                let label = make_lambda_simple_arity_ok() in
                let label_end_of_args = make_tc_applic_recycle_frame_done() in
                let label_args_loop = make_tc_applic_recycle_frame_loop() in 
        
                (Printf.sprintf "%s:\n" label) ^
        
                args_asm_code ^
                (* all args were pushed to stack *)
        
                args_num ^ | ScmApplic' (proc, args, Tail_Call) ->
                        let args_asm_code = List.map (fun (exp) ->  (run params env exp) ^ "\tpush rax\n") args in 
                        let args_asm_code = List.fold_left (fun acc lst -> lst ^ acc) "" args_asm_code in 
                        let args_num = List.length args in
                        let args_num = Printf.sprintf "\tpush %d\n" args_num  in
                        let proc_asm_code = run params env proc in 
                        let label = make_lambda_simple_arity_ok() in
                        let label_end_of_args = make_tc_applic_recycle_frame_done() in
                        let label_args_loop = make_tc_applic_recycle_frame_loop() in 
                
                        (Printf.sprintf "%s:\n" label) ^
                
                        args_asm_code ^
                        (* all args were pushed to stack *)
                
                        args_num ^
                        (* args num were pushed to stack *)
                        proc_asm_code ^
                
                        "\tcmp byte [rax], T_closure\n
                        jne L_code_ptr_error                      ; rax <- proc\n
                
                        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)\n
                        push rbx                                  ; env pushed\n
                        push qword [ rbp + 8 * 1]                 ; old ret addr pushed\n
                        push qword [ rbp ]                        ; the same old rbp pushed\n
                
                        
                        ;mov r8, [ rbp + 3 * 8 ]                   ; r8 <- old_code_num_of_args_n\n                 
                        ;mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m\n
                
                        ;mov r10, [rbp + ((4 + r8) * 8) ]            ; r10 <- old_code nth-1 arg\n 
                        ;mov r11, [rsp + ((4 + r9) * 8) ]            ; r11 <- new_code mth-1 arg\n
                
                        
                
                        ;mov r14, 0                                ; r14 <- 0 : init  as curr_arg_to_copy\n
                        ;mov r12, 0                                ; r12 <- 0 : init as args_copied_counter\n" ^
                                 
                        
                        (* (Printf.sprintf "%s:\n" label_args_loop) ^ *)
                        
                        ";; copying B_m-1 to override A_n-1\n
                
                        ;mov r14, [r11 - (r12 * 8)]                ; r14 <- arg B_m-1\n
                        ;mov [r10 - (r12 * 8)], r14                ; arg A_m-1 <- r14\n
                
                        ;mov r14, 0                                ; clean box\n
                
                        ;mov r12, (r12 + 1)                        ; args_copied_counter++\n
                
                        ;cmp r12, r9 + 4                           ; args_copied_counter == new_code_num_of_args_m ?\n
                        ;jne label_args_loop\n" ^
                
                        (* (Printf.sprintf "%s:\n" label_end_of_args) ^ *)
                
                        ";pop rbp                                  ; restore the old rbp\n
                        ;mov rbx, SOB_CLOSURE_CODE(rax)\n          ; rbx <- code(proc)\n
                        ;jmp rbx\n"<- env(proc)\n
                push rbx                                  ; env pushed\n
                push qword [ rbp + 8 * 1]                 ; old ret addr pushed\n
                push qword [ rbp ]                        ; the same old rbp pushed\n
        
                
                ;mov r8, [ rbp + 3 * 8 ]                   ; r8 <- old_code_num_of_args_n\n                 
                ;mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m\n
        
                ;mov r10, [rbp + ((4 + r8) * 8) ]            ; r10 <- old_code nth-1 arg\n 
                ;mov r11, [rsp + ((4 + r9) * 8) ]            ; r11 <- new_code mth-1 arg\n
        
                
        
                ;mov r14, 0                                ; r14 <- 0 : init  as curr_arg_to_copy\n
                ;mov r12, 0                                ; r12 <- 0 : init as args_copied_counter\n" ^
                         
                
                (* (Printf.sprintf "%s:\n" label_args_loop) ^ *)
                
                ";; copying B_m-1 to override A_n-1\n
        
                ;mov r14, [r11 - (r12 * 8)]                ; r14 <- arg B_m-1\n
                ;mov [r10 - (r12 * 8)], r14                ; arg A_m-1 <- r14\n
        
                ;mov r14, 0                                ; clean box\n
        
                ;mov r12, (r12 + 1)                        ; args_copied_counter++\n
        
                ;cmp r12, r9 + 4                           ; args_copied_counter == new_code_num_of_args_m ?\n
                ;jne label_args_loop\n" ^
        
                (* (Printf.sprintf "%s:\n" label_end_of_args) ^ *)
        
                ";pop rbp                                  ; restore the old rbp\n
                ;mov rbx, SOB_CLOSURE_CODE(rax)\n          ; rbx <- code(proc)\n
                ;jmp rbx\n"




                mov r9, [ rsp + 3 * 8 ]                   
                mov r10, (r9 + 4)                       
                mov r12, (r8 + 4)  


        compile_scheme_string "./testing/sagytest.asm" "((lambda (x . y) x) 1)";;
        Segmentation fault (core dumped)    
        
        compile_scheme_string "./testing/sagytest.asm" "((lambda (x . y) x) 1 2)";;
        Segmentation fault (core dumped)

        compile_scheme_string "./testing/sagytest.asm" "((lambda (x . y) x) 1 2 3)";;
        Segmentation fault (core dumped)

        compile_scheme_string "./testing/sagytest.asm" "((lambda (x . y) x) 1 2 3 4)";;
        PERFECT

        compile_scheme_string "./testing/sagytest.asm" "((lambda (x . y) x) 1 2 3 4 5)";;
        PERFECT

        compile_scheme_string "./testing/sagytest.asm" "((lambda (x . y) x) 1 2 3 4 5 6)";;
        PERFECT


        | ScmLambda' (params', Opt opt, body) -> 
        "((lambda (x y z . w) x) 1 2 3 4 5)"


        13.1.23 16:19



<<<<<<< HEAD:scratch.asm
%define RET_ADDR 			qword [rbp + 8 * 1]
%define ENV 				qword [rbp + 8 * 2]
%define COUNT 				qword [rbp + 8 * 3]
%define PARAM(n) 			qword [rbp + 8 * (4 + n)]
        
L_code_ptr_bin_apply:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2

        mov r8, 0                                       ;; r8 <- list_of_args init 
        mov r9, 0                                       ; r9 <- car(list) init 
        mov r10, 0                                      ; r10 <- cdr (list) init 
        mov r11, 0                                      ;; r11 <- args_counter init               
        mov r12, 0                                      ;; r12 <- proc init
        mov r13, 0                                      ; r13 <- proc.lex_env / proc.code init
        mov r14, 0                                      ;; r14 <- return address init
        mov r15, 0                                      ;; r15 <- old_rbp init


        mov r8, qword PARAM(1)                          ; r8 <- list_of_args
        assert_pair(r8)

        cmp byte [r8], T_nil 
        je .L_error_with_args_count                     ; list.length == 0 ?\

        mov r11, qword [rsp + ]                            ; r11 <- args_counter

        mov r12, qword PARAM(0)                         ; r12 <- proc
        cmp byte [rax], T_closure
        jne L_error_non_closure 

        mov r14, qword RET_ADDR                         ; return address

        mov r15, qword OLD_RDP                          ; r15 <- old_rbp

        pop rcx
        pop rcx
        pop rcx
        pop rcx                                         ; clean




.L_list_of_args_not_empty_yet:

        assert_pair(r8)
        mov r9, qword SOB_PAIR_CAR(r8)                  ; r9 <- car(list)
        push r9                                         ; push curr_arg
        add r11, 1                                      ; args_counter ++

        mov r10, qword SOB_PAIR_CDR(r8)                 
        mov r8, qword r10                               ; r8 <- cdr(list)

        assert_pair(r8)                                 
        cmp byte [r8], T_nil                            ; rest of the list is empty?
        jne .L_list_of_args_not_empty_yet               

.L_list_of_args_totally_pushed:
        push r11                                        ; push args_counter
        
        mov r12, qword PARAM(0)                         ; r12 <- proc
        cmp byte [rax], T_closure
        jne L_error_non_closure 

        mov r13, SOB_CLOSURE_ENV(r12)                   ; r13 <- proc.env
        push r13






        mov r13, 0
        mov r13, SOB_CLOSURE_CODE(r12)                  ; r13 <- proc.code

        jmp r13                                         ; jmp to code




=======
;;; PLEASE IMPLEMENT THIS PROCEDURE
>>>>>>> 1ec4166309f37d8d9ead6344f70ce38e8a43e60a:scratch.ml
L_code_ptr_bin_apply:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2

<<<<<<< HEAD:scratch.asm
        mov r8, 0                                       ;; r8 <- list_of_args init 
        mov r9, 0                                       ; r9 <- car(list) init 
        mov r10, 0                                      ; r10 <- cdr (list) init 
        mov r11, 0                                      ;; r11 <- args_counter init               
        mov r12, 0                                      ;; r12 <- proc init
        mov r13, 0                                      ; r13 <- proc.lex_env / proc.code init
        mov r14, 0                                      ;; r14 <- return address init
        ; mov r15, 0                                      ;; r15 <- old_rbp init


        *mov r8, qword PARAM(1)                          ; r8 <- list_of_args
        *assert_pair(r8)

        *cmp byte [r8], T_nil 
        *je .L_error_with_args_count                     ; list.length == 0 ?\

        mov r11, qword [rsp + ]                            ; r11 <- args_counter

        *mov r12, qword PARAM(0)                         ; r12 <- proc
        *cmp byte [rax], T_closure
        *jne L_error_non_closure 

        *mov r14, qword RET_ADDR                         ; return address

        mov r15, qword OLD_RDP                          ; r15 <- old_rbp

        pop rcx
        pop rcx
        pop rcx
        pop rcx                                         ; clean




.L_list_of_args_not_empty_yet:

        assert_pair(r8)
        mov r9, qword SOB_PAIR_CAR(r8)                  ; r9 <- car(list)
        push r9                                         ; push curr_arg
        add r11, 1                                      ; args_counter ++

        mov r10, qword SOB_PAIR_CDR(r8)                 
        mov r8, qword r10                               ; r8 <- cdr(list)

        assert_pair(r8)                                 
        cmp byte [r8], T_nil                            ; rest of the list is empty?
        jne .L_list_of_args_not_empty_yet               

.L_list_of_args_totally_pushed:
        push r11                                        ; push args_counter
        
        mov r12, qword PARAM(0)                         ; r12 <- proc
        cmp byte [rax], T_closure
        jne L_error_non_closure 

        mov r13, SOB_CLOSURE_ENV(r12)                   ; r13 <- proc.env
        push r13






        mov r13, 0
        mov r13, SOB_CLOSURE_CODE(r12)                  ; r13 <- proc.code

        jmp r13                                         ; jmp to code


; (* current version!*)
L_code_ptr_bin_apply:
        
        
        mov r8, [rsp +  2 * 8]                          ; r8 <- num_of_args
        cmp r8, 2       
        jne L_error_arg_count_2                         ; check right number of parameters.           

        mov r8, qword [rsp + 4 * 8]                     ; r8 <- list_of_args
        assert_pair(r8)

        cmp byte [r8], T_nil 
        je .L_error_with_args_count                     ; list.length == 0 ?

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

        assert_pair(r8) 
        cmp byte [r8], T_nil                            ; rest of the list is empty?
        jne .L_list_of_args_not_empty_yet               

.L_list_of_args_totally_pushed:

        push r11                                        ; * push args_counter *

        mov r13, SOB_CLOSURE_ENV(r12)                   ; r13 <- proc.env
        push r13                                        ; * push proc env *

        push r14                                        ; * push return address *


.L_flip_args_order:

.L_all_args_are_flipped:

        mov r13 SOB_CLOSURE_CODE(r12)
        jmp r13



        
=======
        mov r11, 0                                              ; init args_counter with 0

        ;; push all args that in the list

        mov r9, qword PARAM(1)                                  ; r9 <- args_list
        ; assert_pair(r9)
        cmp byte [r9], T_nil 
        je .L_error_with_args_count


        assert_pair(r9)                                         ;
        mov rcx, qword SOB_PAIR_CAR(r9)                         ; rcx <- car(args_list)
        push rcx                                                ; push first arg to stack

        mov r11, (r11 +1)                                      ; increament args_counter
        

        assert_pair(r9)
        mov rcx, qword SOB_PAIR_CDR(r9)                         ; rcx <- rest of the list
        mov r9, qword rcx                                       ; r9 <- rest of the list
        
        cmp byte [r9], T_nil                                    ; check if rest of the list is empty
        je .L_error_with_args_count                             ; if empty go to args error, have to be at least 2
        
.L_list_is_not_done:

        assert_pair(r9)
        mov rcx, qword SOB_PAIR_CAR(r9)                         ; rcx <- car of rest of the list
        push rcx                                                ; push arg

        mov r11, (r11 + 1)                                      ; args_counter++

        assert_pair(r9)
        mov rcx, qword SOB_PAIR_CDR(r9)                         ; rcx <- rest of rest of the list
        mov r9, qword rcx                                       ; r9 <- rest of rest of the list

        cmp byte [r9], T_nil                                    ; check if rest of the list is empty
        jne .L_list_is_not_done 

.L_list_is_done:
        
        push r11                                                ; push num_of_args

        ; invriant: r9 has the proc code
        mov r9, qword PARAM(0)                                  ; arg_proc to r9
        cmp byte [rax], T_closure                               ;  is it a closure? 
        jne L_error_non_closure                                 ; if not closure jmp kibinimat

        mov r10, SOB_CLOSURE_ENV(r9)                            ; get proc env
        push r10                                                ; push closure env to stack


        ; ??? need to push retaddress, which is it ???
        ; ??? need to think about rbp ???

        ;get proc code and jmp
        mov r9, qword PARAM(0)                                  ; arg_proc to r9
        mov r10, SOB_CLOSURE_CODE(r9)
        jmp r10    
>>>>>>> 1ec4166309f37d8d9ead6344f70ce38e8a43e60a:scratch.ml






; L_code_ptr_bin_apply:
;         ENTER
;         cmp COUNT, 2
;         jne L_error_arg_count_2

;         mov r8, 0                                       ;; r8 <- list_of_args init 
;         mov r9, 0                                       ; r9 <- car(list) init 
;         mov r10, 0                                      ; r10 <- cdr (list) init 
;         mov r11, 0                                      ;; r11 <- args_counter init               
;         mov r12, 0                                      ;; r12 <- proc init
;         mov r13, 0                                      ; r13 <- proc.lex_env / proc.code init
;         mov r14, 0                                      ;; r14 <- return address init
;         mov r15, 0                                      ;; r15 <- old_rbp init


;         mov r8, qword PARAM(1)                          ; r8 <- list_of_args
;         assert_pair(r8)

;         cmp byte [r8], T_nil 
;         je .L_error_with_args_count                     ; list.length == 0 ?\

;         mov r11, qword COUNT                            ; r11 <- args_counter

;         pop rcx
;         pop rcx
;         pop rcx
;         pop rcx                                         ; clean




; .L_list_of_args_not_empty_yet:

;         *assert_pair(r8)
;         *mov r9, qword SOB_PAIR_CAR(r8)                  ; r9 <- car(list)
;         *push r9                                         ; push curr_arg
;         *add r11, 1                                      ; args_counter ++

;         *mov r10, qword SOB_PAIR_CDR(r8)                 
;         *mov r8, qword r10                               ; r8 <- cdr(list)

;         *assert_pair(r8)                                 
;         *cmp byte [r8], T_nil                            ; rest of the list is empty?
;         *jne .L_list_of_args_not_empty_yet               

; .L_list_of_args_totally_pushed:
;         *push r11                                        ; push args_counter
        
;         *mov r12, qword PARAM(0)                         ; r12 <- proc
;         *cmp byte [rax], T_closure
;         *jne L_error_non_closure 

;         mov r13, SOB_CLOSURE_ENV(r12)                   ; r13 <- proc.env
;         push r13






;         mov r13, 0
;         mov r13, SOB_CLOSURE_CODE(r12)                  ; r13 <- proc.code

;         jmp r13                                         ; jmp to code

;         mov r15, qword OLD_RDP                          ; r15 <- old_rbp

;         pop rcx
;         pop rcx
;         pop rcx
;         pop rcx                                         ; clean




; .L_list_of_args_not_empty_yet:

;         *assert_pair(r8)
;         *mov r9, qword SOB_PAIR_CAR(r8)                  ; r9 <- car(list)
;         *push r9                                         ; push curr_arg
;         *add r11, 1                                      ; args_counter ++

;         *mov r10, qword SOB_PAIR_CDR(r8)                 
;         *mov r8, qword r10                               ; r8 <- cdr(list)

;         *assert_pair(r8)                                 
;         *cmp byte [r8], T_nil                            ; rest of the list is empty?
;         *jne .L_list_of_args_not_empty_yet               

; .L_list_of_args_totally_pushed:
;         *push r11                                        ; push args_counter
        
;         *mov r12, qword PARAM(0)                         ; r12 <- proc
;         *cmp byte [rax], T_closure
;         *jne L_error_non_closure 

;         mov r13, SOB_CLOSURE_ENV(r12)                   ; r13 <- proc.env
;         push r13






;         mov r13, 0
;         mov r13, SOB_CLOSURE_CODE(r12)                  ; r13 <- proc.code

;         jmp r13                                         ; jmp to code

;         ENTER
;         cmp COUNT, 2
;         jne L_error_arg_count_2

;         mov r11, 0                                              ; init args_counter with 0

;         ;; push all args that in the list

;         mov r9, qword PARAM(1)                                  ; r9 <- args_list
;         ; assert_pair(r9)
;         cmp byte [r9], T_nil 
;         je .L_error_with_args_count


;         assert_pair(r9)                                         ;
;         mov rcx, qword SOB_PAIR_CAR(r9)                         ; rcx <- car(args_list)
;         push rcx                                                ; push first arg to stack

;         mov r11, (r11 +1)                                      ; increament args_counter
        

;         assert_pair(r9)
;         mov rcx, qword SOB_PAIR_CDR(r9)                         ; rcx <- rest of the list
;         mov r9, qword rcx                                       ; r9 <- rest of the list
        
;         cmp byte [r9], T_nil                                    ; check if rest of the list is empty
;         je .L_error_with_args_count                             ; if empty go to args error, have to be at least 2
        
; .L_list_is_not_done:

;         assert_pair(r9)
;         mov rcx, qword SOB_PAIR_CAR(r9)                         ; rcx <- car of rest of the list
;         push rcx                                                ; push arg

;         mov r11, (r11 + 1)                                      ; args_counter++

;         assert_pair(r9)
;         mov rcx, qword SOB_PAIR_CDR(r9)                         ; rcx <- rest of rest of the list
;         mov r9, qword rcx                                       ; r9 <- rest of rest of the list

;         cmp byte [r9], T_nil                                    ; check if rest of the list is empty
;         jne .L_list_is_not_done 

; .L_list_is_done:
        
;         push r11                                                ; push num_of_args

;         ; invriant: r9 has the proc code
;         mov r9, qword PARAM(0)                                  ; arg_proc to r9
;         cmp byte [rax], T_closure                               ;  is it a closure? 
;         jne L_error_non_closure                                 ; if not closure jmp kibinimat

;         mov r10, SOB_CLOSURE_ENV(r9)                            ; get proc env
;         push r10                                                ; push closure env to stack


;         ; ??? need to push retaddress, which is it ???
;         ; ??? need to think about rbp ???

;         ;get proc code and jmp
;         mov r9, qword PARAM(0)                                  ; arg_proc to r9
;         mov r10, SOB_CLOSURE_CODE(r9)
;         jmp r10               





; (* current version!*)
; L_code_ptr_bin_apply:
;         enter 0, 0
;         cmp COUNT, 2       
;         jne L_error_arg_count_2                         ; check right number of parameters.           

;         mov r8, PARAM(1)                                ; r8 <- list_of_args
;         assert_pair(r8)

;         cmp byte [r8], T_nil 
;         je L_error_arg_count_0                       ; list.length == 0 ?

;         mov r11, 0                                      ; list_asrgs_counter init

;         mov r12, qword PARAM(0)                    ; r12 <- proc
;         cmp byte [rax], T_closure
;         jne L_error_non_closure

;         mov r14, qword [rsp]                            ; r14 <- ret address
;         add rsp, 5 * 8                                  ; set rsp to override the last args
;                                                         ; similliar to 4 pops.
        
; .L_list_of_args_not_empty_yet:

;         assert_pair(r8)
;         mov r9, qword SOB_PAIR_CAR(r8)                  ; r9 <- car(list)
;         push r9                                         ; * push arg *
        
;         add r11, 1                                      ; args_counter ++

;         mov r10, qword SOB_PAIR_CDR(r8)                 
;         mov r8, qword r10                               ; r8 <- cdr(list)

;         assert_pair(r8) 
;         cmp byte [r8], T_nil                            ; rest of the list is empty?
;         jne .L_list_of_args_not_empty_yet               

; .L_list_of_args_totally_pushed:

;         push r11                                        ; * push args_counter *

;         mov r13, SOB_CLOSURE_ENV(r12)                   ; r13 <- proc.env
;         push r13                                        ; * push proc env *

;         push r14                                        ; * push return address *


; .L_flip_args_order:

; .L_all_args_are_flipped:

;         mov r13, SOB_CLOSURE_CODE(r12)
;         jmp r13

