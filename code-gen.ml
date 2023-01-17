#use "compiler.ml"

let file_to_string input_file =
  let in_channel = open_in input_file in
  let rec run () =
    try 
      let ch = input_char in_channel in ch :: (run ())
    with End_of_file ->
      ( close_in in_channel;
	[] )
  in string_of_list (run ());;

let string_to_file output_file out_string =
  let out_channel = open_out output_file in
  ( output_string out_channel out_string;
    close_out out_channel );;

(* module type CODE_GENERATION =
  sig
    val compile_scheme_string : string -> string -> unit
    val compile_scheme_file : string -> string -> unit
  end;; *)

(* module Code_Generation : CODE_GENERATION= struct *)

  (* areas that raise this exception are NOT for the
   * final project! please leave these unimplemented,
   * as this will require major additions to your
   * compilers
   *)
  exception X_not_yet_supported;;

  let word_size = 8;;
  let label_start_of_constants_table = "L_constants";;
  let comment_length = 20;;

  let list_and_last =
    let rec run a = function
      | [] -> ([], a)
      | b :: s ->
         let (s, last) = run b s in
         (a :: s, last)
    in function
    | [] -> None
    | a :: s -> Some (run a s);;

  let split_to_sublists n = 
    let rec run = function
      | ([], _, f) -> [f []]
      | (s, 0, f) -> (f []) :: (run (s, n, (fun s -> s)))
      | (a :: s, i, f) ->
         (run (s, i - 1, (fun s -> f (a :: s))))
    in function
    | [] -> []
    | s -> run (s, n, (fun s -> s));;

  let remove_duplicates exp =
    List.fold_left(fun lst one -> if (List.mem one lst) then lst else (List.append lst [one])) [] exp

  let collect_constants exp = 
    let rec run exp' = 
    (match exp' with
      | ScmVarGet'(_) | ScmBox'(_) | ScmBoxGet'(_)-> []
      | ScmConst'(sexp) -> [sexp]
      | ScmBoxSet'(name, exp) | ScmVarSet'(name, exp) | ScmVarDef'(name, exp) -> run exp
      | ScmSeq'(exprs) | ScmOr'(exprs) -> 
        (List.fold_left (fun acc appendo -> (List.append acc appendo)) [] (List.map run exprs))
      | ScmIf'(test, dit, dif) -> List.append (run test) (List.append (run dit) (run dif))
      | ScmLambda'(_,_,exp) -> run exp
      | ScmApplic'(exp, exps',_) -> List.append (run exp) (List.fold_left (fun acc appendo -> (List.append acc appendo)) [] (List.map run exps'))) in
    List.fold_left (fun acc appendo -> (List.append acc appendo)) [] (List.map run exp)

  let add_sub_constants =
    let rec run sexpr = match sexpr with
      | ScmVoid -> [ScmVoid]
      | ScmNil -> [ScmNil]
      | ScmBoolean _ | ScmChar _ | ScmString _ | ScmNumber _ ->
         [sexpr]
      | ScmSymbol sym -> [ScmString(sym); sexpr]
      | ScmPair (car, cdr) -> (run car) @ (run cdr) @ [sexpr]
      | ScmVector sexprs -> (List.fold_left(fun acc sexp -> List.append acc (run sexp)) [] sexprs) @ [sexpr]
    and runs sexprs =
      List.fold_left (fun full sexpr -> full @ (run sexpr)) [] sexprs
    in fun exprs' ->
       [ScmVoid; ScmNil; ScmBoolean false; ScmBoolean true; ScmChar '\000'] @ (runs exprs');;

  type initialized_data =
    | RTTI of string
    | Byte of int
    | ASCII of string
    | Quad of int
    | QuadFloat of float
    | ConstPtr of int;;

  let search_constant_address const const_table = 
    let find_row = List.find (fun (sexp, loc, repr) -> const = sexp) const_table in
    (fun (sexp, loc, repr) -> loc) find_row

    (* (sexpr, loc, repr) *)


  let const_repr sexpr loc table = match sexpr with
    | ScmVoid -> ([RTTI "T_void"], 1)
    | ScmNil -> ([RTTI "T_nil"], 1)
    | ScmBoolean false ->
       ([RTTI "T_boolean_false"], 1)
    | ScmBoolean true ->
       ([RTTI "T_boolean_true"], 1)
    | ScmChar ch ->
       ([RTTI "T_char"; Byte (int_of_char ch)], 2)
    | ScmString str ->
       let count = String.length str in
       ([RTTI "T_string"; Quad count; ASCII str],
        1 + word_size + count)
    | ScmSymbol sym ->
       let addr = search_constant_address (ScmString sym) table in
       ([RTTI "T_symbol"; ConstPtr addr], 1 + word_size)
    | ScmNumber (ScmRational (numerator, denominator)) ->
       ([RTTI "T_rational"; Quad numerator; Quad denominator],
        1 + 2 * word_size)
    | ScmNumber (ScmReal x) ->
       ([RTTI "T_real"; QuadFloat x], 1 + word_size)
    | ScmVector s ->
       let addrs =
         List.map
           (fun si -> ConstPtr (search_constant_address si table)) s in
       let count = List.length s in
       ((RTTI "T_vector") :: (Quad count) :: addrs,
        1 + (count + 1) * word_size)
    | ScmPair (car, cdr) ->
       let (addr_car, addr_cdr) =
         (search_constant_address car table,
          search_constant_address cdr table) in
       ([RTTI "T_pair"; ConstPtr addr_car; ConstPtr addr_cdr],
        1 + 2 * word_size);;

  let make_constants_table =
    let rec run table loc = function
      | [] -> table
      | sexpr :: sexprs ->
         let (repr, len) = const_repr sexpr loc table in
         run (table @ [(sexpr, loc, repr)]) (loc + len) sexprs
    in
    fun exprs' ->
    run [] 0
      (remove_duplicates
         (add_sub_constants
            (remove_duplicates
               (collect_constants exprs'))));;    

  let asm_comment_of_sexpr sexpr =
    let str = string_of_sexpr sexpr in
    let str =
      if (String.length str) <= comment_length
      then str
      else (String.sub str 0 comment_length) ^ "..." in
    "; " ^ str;;

  let asm_of_representation sexpr =
    let str = asm_comment_of_sexpr sexpr in
    let run = function
      | [RTTI str] -> Printf.sprintf "\tdb %s" str
      | [RTTI "T_char"; Byte byte] ->
         Printf.sprintf "\tdb T_char, 0x%02X\t%s" byte str
      | [RTTI "T_string"; Quad length; ASCII const_str] ->
         Printf.sprintf "\tdb T_string\t%s\n\tdq %d%s"
           str length
           (let s = list_of_string const_str in
            let s = List.map
                      (fun ch -> Printf.sprintf "0x%02X" (int_of_char ch))
                      s in
            let s = split_to_sublists 8 s in
            let s = List.map (fun si -> "\n\tdb " ^ (String.concat ", " si)) s in
            String.concat "" s)
      | [RTTI "T_symbol"; ConstPtr addr] ->
         Printf.sprintf "\tdb T_symbol\t%s\n\tdq %s + %d"
           str label_start_of_constants_table addr
      | [RTTI "T_rational"; Quad numerator; Quad denominator] ->
         Printf.sprintf "\tdb T_rational\t%s\n\tdq %d, %d"
           str
           numerator denominator
      | [RTTI "T_real"; QuadFloat x] ->
         Printf.sprintf "\tdb T_real\t%s\n\tdq %f" str x
      | (RTTI "T_vector") :: (Quad length) :: addrs ->
         Printf.sprintf "\tdb T_vector\t%s\n\tdq %d%s"
           str length
           (let s = List.map
                      (function
                       | ConstPtr ptr ->
                          Printf.sprintf "%s + %d"
                            label_start_of_constants_table ptr
                       | _ -> raise
                               (X_this_should_not_happen
                                  "incorrect representation for a vector"))
                      addrs in
            let s = split_to_sublists 3 s in
            let s = List.map (fun si -> "\n\tdq " ^ (String.concat ", " si)) s in
            String.concat "" s)
      | [RTTI "T_pair"; ConstPtr car; ConstPtr cdr] ->
         Printf.sprintf "\tdb T_pair\t%s\n\tdq %s + %d, %s + %d"
           str
           label_start_of_constants_table car
           label_start_of_constants_table cdr
      | _ -> raise (X_this_should_not_happen "invalid representation!")
    in run;;

  let asm_of_constants_table =
    let rec run = function
      | [] -> ""
      | (sexpr, _, repr) :: rest ->
         (asm_of_representation sexpr repr) ^ "\n" ^ (run rest)
    in
    fun table ->
    Printf.sprintf "%s:\n%s"
      label_start_of_constants_table (run table);;

  let global_bindings_table =
    [ (* 1-10 *)
      ("null?", "L_code_ptr_is_null");
      ("pair?", "L_code_ptr_is_pair");
      ("void?", "L_code_ptr_is_void");
      ("char?", "L_code_ptr_is_char");
      ("string?", "L_code_ptr_is_string");
      ("symbol?", "L_code_ptr_is_symbol");
      ("vector?", "L_code_ptr_is_vector");
      ("procedure?", "L_code_ptr_is_closure");
      ("real?", "L_code_ptr_is_real");
      ("rational?", "L_code_ptr_is_rational");
      ("boolean?", "L_code_ptr_is_boolean");
      (* 11-20 *)
      ("number?", "L_code_ptr_is_number");
      ("collection?", "L_code_ptr_is_collection");
      ("cons", "L_code_ptr_cons");
      ("display-sexpr", "L_code_ptr_display_sexpr");
      ("write-char", "L_code_ptr_write_char");
      ("car", "L_code_ptr_car");
      ("cdr", "L_code_ptr_cdr");
      ("string-length", "L_code_ptr_string_length");
      ("vector-length", "L_code_ptr_vector_length");
      ("real->integer", "L_code_ptr_real_to_integer");
      (* 21-30*)
      ("exit", "L_code_ptr_exit");
      ("integer->real", "L_code_ptr_integer_to_real");
      ("rational->real", "L_code_ptr_rational_to_real");
      ("char->integer", "L_code_ptr_char_to_integer");
      ("integer->char", "L_code_ptr_integer_to_char");
      ("trng", "L_code_ptr_trng");
      ("zero?", "L_code_ptr_is_zero");
      ("integer?", "L_code_ptr_is_integer");
      ("__bin-apply", "L_code_ptr_bin_apply");
      ("__bin-add-rr", "L_code_ptr_raw_bin_add_rr");
      (* 31-40*)
      ("__bin-sub-rr", "L_code_ptr_raw_bin_sub_rr");
      ("__bin-mul-rr", "L_code_ptr_raw_bin_mul_rr");
      ("__bin-div-rr", "L_code_ptr_raw_bin_div_rr");
      ("__bin-add-qq", "L_code_ptr_raw_bin_add_qq");
      ("__bin-sub-qq", "L_code_ptr_raw_bin_sub_qq");
      ("__bin-mul-qq", "L_code_ptr_raw_bin_mul_qq");
      ("__bin-div-qq", "L_code_ptr_raw_bin_div_qq");
      ("error", "L_code_ptr_error");
      ("__bin-less-than-rr", "L_code_ptr_raw_less_than_rr");
      ("__bin-less-than-qq", "L_code_ptr_raw_less_than_qq");
      (* 41-50 *)
      ("__bin-equal-rr", "L_code_ptr_raw_equal_rr");
      ("__bin-equal-qq", "L_code_ptr_raw_equal_qq");
      ("quotient", "L_code_ptr_quotient");
      ("remainder", "L_code_ptr_remainder");
      ("set-car!", "L_code_ptr_set_car");
      ("set-cdr!", "L_code_ptr_set_cdr");
      ("string-ref", "L_code_ptr_string_ref");
      ("vector-ref", "L_code_ptr_vector_ref");
      ("vector-set!", "L_code_ptr_vector_set");
      ("string-set!", "L_code_ptr_string_set");
      (* 51-60 *)
      ("make-vector", "L_code_ptr_make_vector");
      ("make-string", "L_code_ptr_make_string");
      ("numerator", "L_code_ptr_numerator");
      ("denominator", "L_code_ptr_denominator");
      ("eq?", "L_code_ptr_eq");
    ];;

  let collect_free_vars =
    let rec run = function
      | ScmConst' _ -> []
      | ScmVarGet' (Var' (v, Free)) -> [v]
      | ScmVarGet' _ -> []
      | ScmIf' (test, dit, dif) -> List.append (List.append (run test) (run dit)) (run dif)
      | ScmSeq' exprs' -> runs exprs'
      | ScmOr' exprs' -> runs exprs'
      | ScmVarSet' (Var' (v, Free), expr') -> [v] @ run expr'
      | ScmVarSet' (_, expr') -> run expr'
      | ScmVarDef' (Var' (v, Free), expr') -> [v] @ run expr'
      | ScmVarDef' (_, expr') -> run expr'
      | ScmBox' (Var' (v, Free)) -> [v]
      | ScmBox' _ -> []
      | ScmBoxGet' (Var' (v, Free)) -> [v]
      | ScmBoxGet' _ -> []
      | ScmBoxSet' (Var' (v, Free), expr') -> [v] @ run expr'
      | ScmBoxSet' (_, expr') -> run expr'
      | ScmLambda' (_, _, expr') -> run expr'
      | ScmApplic' (expr', exprs', _) -> List.append (run expr') (runs exprs') 
    and runs exprs' =
      List.fold_left
        (fun vars expr' -> vars @ (run expr'))
        []
        exprs'
    in fun exprs' ->
       let primitives =
         List.map
           (fun (scheme_name, _) -> scheme_name)
           global_bindings_table
       and free_vars_in_code = runs exprs' in
       remove_duplicates
         (primitives @ free_vars_in_code);;

  let make_free_vars_table =
    let rec run index = function
      | [] -> []
      | v :: vars ->
         let x86_label = Printf.sprintf "free_var_%d" index in
         (v, x86_label) :: (run (index + 1) vars)
    in fun exprs' -> run 0 (collect_free_vars exprs');;

  let search_free_var_table =
    let rec run v = function
      | [] -> raise (X_this_should_not_happen
                      (Printf.sprintf
                         "The variable %s was not found in the free-var table"
                         v))
      | (v', x86_label) :: _ when v = v' -> x86_label
      | _ :: table -> run v table
    in run;;

  let asm_of_global_bindings global_bindings_table free_var_table =
    String.concat "\n"
      (List.map
         (fun (scheme_name, asm_code_ptr) ->
           let free_var_label =
             search_free_var_table scheme_name free_var_table in
           (Printf.sprintf "\t; building closure for %s\n" scheme_name)
           ^ (Printf.sprintf "\tmov rdi, %s\n" free_var_label)
           ^ (Printf.sprintf "\tmov rsi, %s\n" asm_code_ptr)
           ^ "\tcall bind_primitive\n")
         global_bindings_table);;
  
  let asm_of_free_vars_table table =
    let tmp = 
      List.map
        (fun (scm_var, asm_label) ->
          Printf.sprintf "%s:\t; location of %s\n\tresq 1"
            asm_label scm_var)
        table in
    String.concat "\n" tmp;;

  let make_make_label prefix =
    let index = ref 0 in
    fun () ->
    (index := !index + 1;
     Printf.sprintf "%s_%04x" prefix !index);;

  let make_if_else = make_make_label ".L_if_else";;
  let make_if_end = make_make_label ".L_if_end";;
  let make_or_end = make_make_label ".L_or_end";;
  let make_lambda_simple_loop_env =
    make_make_label ".L_lambda_simple_env_loop";;
  let make_lambda_simple_loop_env_end =
    make_make_label ".L_lambda_simple_env_end";;
  let make_lambda_simple_loop_params =
    make_make_label ".L_lambda_simple_params_loop";;
  let make_lambda_simple_loop_params_end =
    make_make_label ".L_lambda_simple_params_end";;
  let make_lambda_simple_code = make_make_label ".L_lambda_simple_code";;
  let make_lambda_simple_end = make_make_label ".L_lambda_simple_end";;
  let make_lambda_simple_arity_ok =
    make_make_label ".L_lambda_simple_arity_check_ok";;
  let make_lambda_opt_loop_env =
    make_make_label ".L_lambda_opt_env_loop";;
  let make_lambda_opt_loop_env_end =
    make_make_label ".L_lambda_opt_env_end";;
  let make_lambda_opt_loop_params =
    make_make_label ".L_lambda_opt_params_loop";;
  let make_lambda_opt_loop_params_end =
    make_make_label ".L_lambda_opt_params_end";;
  let make_lambda_opt_code = make_make_label ".L_lambda_opt_code";;
  let make_lambda_opt_end = make_make_label ".L_lambda_opt_end";;
  let make_lambda_opt_arity_exact =
    make_make_label ".L_lambda_opt_arity_check_exact";;
  let make_lambda_opt_arity_more =
    make_make_label ".L_lambda_opt_arity_check_more";;
  let make_lambda_opt_stack_ok =
    make_make_label ".L_lambda_opt_stack_adjusted";;
  let make_lambda_opt_loop =
    make_make_label ".L_lambda_opt_stack_shrink_loop";;
  let make_lambda_opt_loop_exit =
    make_make_label ".L_lambda_opt_stack_shrink_loop_exit";;
  let make_tc_applic_recycle_frame_loop =
    make_make_label ".L_tc_recycle_frame_loop";;
  let make_tc_applic_recycle_frame_done =
    make_make_label ".L_tc_recycle_frame_done";;

  let code_gen exprs' =
    let consts = make_constants_table exprs' in
    let free_vars = make_free_vars_table exprs' in

    let rec run params env = function
      | ScmConst' sexpr -> let constant_offset = search_constant_address sexpr consts in
          Printf.sprintf 
          "\tmov rax, qword (%s + %d)\n"
          label_start_of_constants_table constant_offset
      | ScmVarGet' (Var' (v, Free)) ->
         let label = search_free_var_table v free_vars in
         Printf.sprintf
           "\tmov rax, qword [%s]\n"
           label
      | ScmVarGet' (Var' (v, Param minor)) -> 
        let var_loc = 8 * (4 + minor) in  (* get var from stack by minor index + 4 (env, num_var...) times size*)
        Printf.sprintf "mov rax, qword [rbp + %d]\n" var_loc

      | ScmVarGet' (Var' (v, Bound (major, minor))) ->
        let major_loc = 8 * major in
        let minor_loc = 8 * minor in
        let env_loc = 8 * 2 in
        (Printf.sprintf "mov rax, qword [rbp + %d]\n" env_loc) ^
        (Printf.sprintf "mov rax, qword [rax + %d]\n" major_loc) ^
        (Printf.sprintf "mov rax, qword [rax + %d]\n" minor_loc)


      | ScmIf' (test, dit, dif) -> 
        let label_end = make_if_end() in
        let label_else = make_if_else() in 
        run params env test ^
        "\tcmp rax, sob_boolean_false\n" ^
        (Printf.sprintf "\tje %s\n" label_else) ^
        run params env dit ^
        (Printf.sprintf "\tjmp %s\n" label_end) ^
        (Printf.sprintf "\t%s:\n" label_else) ^
        "\t" ^
        run params env dif ^
        (Printf.sprintf "\t%s:\n" label_end) 

      | ScmSeq' exprs' ->
         String.concat "\n"
           (List.map (run params env) exprs')
       | ScmOr' exprs' ->
         let label_end = make_or_end () in
         let asm_code = 
           (match (list_and_last exprs') with
            | Some (exprs', last_expr') ->
               let exprs_code =
                 String.concat ""
                   (List.map
                      (fun expr' ->
                        let expr_code = run params env expr' in
                        expr_code
                        ^ "\tcmp rax, sob_boolean_false\n"
                        ^ (Printf.sprintf "\tjne %s\n" label_end))
                      exprs') in
               let last_expr_code = run params env last_expr' in
               exprs_code
               ^ last_expr_code
               ^ (Printf.sprintf "%s:\n" label_end)
            (* and just in case someone messed up the tag-parser: *)
            | None -> run params env (ScmConst' (ScmBoolean false)))
         in asm_code
         
      | ScmVarSet' (Var' (v, Free), expr') ->
        (* TODO: check if we need to throw error if free var wasn't defined before!*)
        let label = search_free_var_table v free_vars in
        (run params env expr') ^
        (Printf.sprintf "\tmov qword [%s], rax\n" label) ^
        "\tmov rax, sob_void\n"

       
      | ScmVarSet' (Var' (v, Param minor), expr') ->
        let var_loc = 8 * (4 + minor) in  (* get var from stack by minor index + 4 (env, num_var...) times size*)
        (run params env expr') ^
        (Printf.sprintf "mov qword [rbp + %d], rax\n" var_loc) ^
        "mov rax, sob_void"

         
      | ScmVarSet' (Var' (v, Bound (major, minor)), expr') ->
        let major_loc = 8 * major in
        let minor_loc = 8 * minor in
        let env_loc = 8 * 2 in
        (run params env expr') ^
        (Printf.sprintf "mov rbx, qword [rbp + %d]\n" env_loc) ^
        (Printf.sprintf "mov rbx, qword [rbx + %d]\n" major_loc) ^
        (Printf.sprintf "mov qword [rbx + %d], rax\n" minor_loc) ^
        "mov rax, sob_void"

        
      | ScmVarDef' (Var' (v, Free), expr') ->
         let label = search_free_var_table v free_vars in
         (run params env expr')
         ^ (Printf.sprintf "\tmov qword [%s], rax\n" label)
         ^ "\tmov rax, sob_void\n"

  
      | ScmVarDef' (Var' (v, Param minor), expr') ->
        let var_loc = 8 * (4 + minor) in  (* get var from stack by minor index + 4 (env, num_var...) times size*)
        (run params env expr') ^
        (Printf.sprintf "mov qword [rbp + %d], rax\n" var_loc) ^
        "mov rax, sob_void"
               

      
      | ScmVarDef' (Var' (v, Bound (major, minor)), expr') ->
        let major_loc = 8 * major in
        let minor_loc = 8 * minor in
        let env_loc = 8 * 2 in
        (run params env expr') ^
        (Printf.sprintf "mov rbx, qword [rbp + %d]\n" env_loc) ^
        (Printf.sprintf "mov rbx, qword [rbx + %d]\n" major_loc) ^
        (Printf.sprintf "mov qword [rbx + %d], rax\n" minor_loc) ^
        "mov rax, sob_void"
      

      | ScmBox' (Var' (v, Param minor)) ->
        (run params env (ScmVarGet'(Var' (v, Param minor)))) ^
        "mov rdi, 8\n" ^
        "mov rbx, rax\n" ^
        "call malloc\n" ^
        "mov qword [rax], rbx\n"

      
      | ScmBox' _ -> raise (X_this_should_not_happen "Tried to box a variable that is not parameter.")
      
      | ScmBoxGet' var' ->
         (run params env (ScmVarGet' var'))
         ^ "\tmov rax, qword [rax]\n"
        
      | ScmBoxSet' (var', expr') -> 
        (run params env expr') ^
        "push rax\n" ^
        (run params env (ScmVarGet' var')) ^
        "pop qword [rax]\n" ^
        "mov rax, sob_void\n"


      | ScmLambda' (params', Simple, body) ->
         let label_loop_env = make_lambda_simple_loop_env ()
         and label_loop_env_end = make_lambda_simple_loop_env_end ()
         and label_loop_params = make_lambda_simple_loop_params ()
         and label_loop_params_end = make_lambda_simple_loop_params_end ()
         and label_code = make_lambda_simple_code ()
         and label_arity_ok = make_lambda_simple_arity_ok ()
         and label_end = make_lambda_simple_end ()
         in
         "\tmov rdi, (1 + 8 + 8)\t; sob closure\n"
         ^ "\tcall malloc\n"
         ^ "\tpush rax\n"
         ^ (Printf.sprintf "\tmov rdi, 8 * %d\t; new rib\n" params)
         ^ "\tcall malloc\n"
         ^ "\tpush rax\n"
         ^ (Printf.sprintf "\tmov rdi, 8 * %d\t; extended env\n" (env + 1))
         ^ "\tcall malloc\n"
         ^ "\tmov rdi, ENV\n"
         ^ "\tmov rsi, 0\n"
         ^ "\tmov rdx, 1\n"
         ^ (Printf.sprintf "%s:\t; ext_env[i + 1] <-- env[i]\n"
              label_loop_env)
         ^ (Printf.sprintf "\tcmp rsi, %d\n" env)
         ^ (Printf.sprintf "\tje %s\n" label_loop_env_end)
         ^ "\tmov rcx, qword [rdi + 8 * rsi]\n"
         ^ "\tmov qword [rax + 8 * rdx], rcx\n"
         ^ "\tinc rsi\n"
         ^ "\tinc rdx\n"
         ^ (Printf.sprintf "\tjmp %s\n" label_loop_env)
         ^ (Printf.sprintf "%s:\n" label_loop_env_end)
         ^ "\tpop rbx\n"
         ^ "\tmov rsi, 0\n"
         ^ (Printf.sprintf "%s:\t; copy params\n" label_loop_params)
         ^ (Printf.sprintf "\tcmp rsi, %d\n" params)
         ^ (Printf.sprintf "\tje %s\n" label_loop_params_end)
         ^ "\tmov rdx, qword [rbp + 8 * rsi + 8 * 4]\n"
         ^ "\tmov qword [rbx + 8 * rsi], rdx\n"
         ^ "\tinc rsi\n"
         ^ (Printf.sprintf "\tjmp %s\n" label_loop_params)
         ^ (Printf.sprintf "%s:\n" label_loop_params_end)
         ^ "\tmov qword [rax], rbx\t; ext_env[0] <-- new_rib \n"
         ^ "\tmov rbx, rax\n"
         ^ "\tpop rax\n"
         ^ "\tmov byte [rax], T_closure\n"
         ^ "\tmov SOB_CLOSURE_ENV(rax), rbx\n"
         ^ (Printf.sprintf "\tmov SOB_CLOSURE_CODE(rax), %s\n" label_code)
         ^ (Printf.sprintf "\tjmp %s\n" label_end)
         ^ (Printf.sprintf "%s:\t; lambda-simple body\n" label_code)
         ^ (Printf.sprintf "\tcmp qword [rsp + 8 * 2], %d\n"
              (List.length params'))
         ^ (Printf.sprintf "\tje %s\n" label_arity_ok)
         ^ "\tpush qword [rsp + 8 * 2]\n"
         ^ (Printf.sprintf "\tpush %d\n" (List.length params'))
         ^ "\tjmp L_error_incorrect_arity_simple\n"
         ^ (Printf.sprintf "%s:\n" label_arity_ok)
         ^ "\tenter 0, 0\n"
         ^ (run (List.length params') (env + 1) body)
         ^ "\tleave\n"
         ^ (Printf.sprintf "\tret 8 * (2 + %d)\n" (List.length params'))
         ^ (Printf.sprintf "%s:\t; new closure is in rax\n" label_end)

         | ScmLambda' (params', Opt opt, body) -> 
          let arg_count = List.length params' in
          let loop_env_label = make_lambda_opt_loop_env () in
          let loop_env_end_label = make_lambda_opt_loop_env_end () in
          let loop_params_label =  make_lambda_opt_loop_params () in
          let loop_params_end_label =  make_lambda_opt_loop_params_end () in
          let loop_opt_spec_param_loop = make_lambda_opt_loop_params () in
          let loop_opt_spec_params_end_label =  make_lambda_opt_loop_params_end () in
          let opt_code_label = make_lambda_opt_code () in
          (* let make_lambda_opt_end = make_lambda_opt_end () in *)
          let arity_exact_label =  make_lambda_opt_arity_exact () in
          let arity_more_label = make_lambda_opt_arity_more () in
          let stack_ok_label = make_lambda_opt_stack_ok () in
          let opt_loop_label = make_lambda_opt_loop () in
          let opt_loop_exit_label = make_lambda_opt_loop_exit () in
          let label_end = make_lambda_opt_end () in
          let shrink_loop = make_lambda_opt_loop_params () in
          let shrink_end = make_lambda_opt_loop_params_end () in
  
            "\tmov rdi, (1 + 8 + 8)\t; sob closure\n"
          ^ "\tcall malloc\n"
          ^ "\tpush rax\n"
          ^ (Printf.sprintf "\tmov rdi, 8 * %d\t; new rib\n" params)
          ^ "\tcall malloc\n"
          ^ "\tpush rax\n"
          ^ (Printf.sprintf "\tmov rdi, 8 * %d\t; extended env\n" (env + 1))
          ^ "\tcall malloc\n"
          ^ "\tmov rdi, ENV\n"
          ^ "\tmov rsi, 0\n"
          ^ "\tmov rdx, 1\n"
          ^ (Printf.sprintf "%s:\t; ext_env[i + 1] <-- env[i]\n"
               loop_env_label)
          ^ (Printf.sprintf "\tcmp rsi, %d\n" env)
          ^ (Printf.sprintf "\tje %s\n" loop_env_end_label)
          ^ "\tmov rcx, qword [rdi + 8 * rsi]\n"
          ^ "\tmov qword [rax + 8 * rdx], rcx\n"
          ^ "\tinc rsi\n"
          ^ "\tinc rdx\n"
          ^ (Printf.sprintf "\tjmp %s\n" loop_env_label)
          ^ (Printf.sprintf "%s:\n" loop_env_end_label)
          ^ "\tpop rbx\n"
          ^ "\tmov rsi, 0\n"
          ^ (Printf.sprintf "%s:\t; copy params\n" loop_params_label)
          ^ (Printf.sprintf "\tcmp rsi, %d\n" params)
          ^ (Printf.sprintf "\tje %s\n" loop_params_end_label)
          ^ "\tmov rdx, qword [rbp + 8 * rsi + 8 * 4]\n"
          ^ "\tmov qword [rbx + 8 * rsi], rdx\n"
          ^ "\tinc rsi\n"
          ^ (Printf.sprintf "\tjmp %s\n" loop_params_label)
          ^ (Printf.sprintf "%s:\n" loop_params_end_label)
          ^ "\tmov qword [rax], rbx\t; ext_env[0] <-- new_rib \n"
          ^ "\tmov rbx, rax\n"
          ^ "\tpop rax\n"
          ^ "\tmov byte [rax], T_closure\n"
          ^ "\tmov SOB_CLOSURE_ENV(rax), rbx\n"
          ^ (Printf.sprintf "\tmov SOB_CLOSURE_CODE(rax), %s\n" opt_code_label)
          ^ (Printf.sprintf "\tjmp %s\n" label_end) ^
          
          
          (Printf.sprintf "%s:\n" opt_code_label) ^
          "mov r10, qword [rsp+8*2]\n" ^  (*r10 has the real num of arguments given*)
          (Printf.sprintf "cmp r10, %d\n" (List.length params')) ^
          (Printf.sprintf "je %s\n" arity_exact_label) ^
          (Printf.sprintf "cmp r10, %d\n" (List.length params')) ^ (*I think sholc be re checked*)
          (Printf.sprintf "jg %s\n" arity_more_label) ^
          (Printf.sprintf "jmp L_error_incorrect_arity_opt\n") ^
  
  
          (Printf.sprintf "%s:\n" arity_exact_label ) ^
          "sub rsp, 8\n" ^
          (Printf.sprintf "mov rdx, 3+%d\n" (List.length params')) ^ (*not sure if shoud be length + 1*)
          "mov qword rbx, rsp\n" ^
          (Printf.sprintf "%s:\n" loop_opt_spec_param_loop) ^ (*should maybe use different label*)
          "mov qword rcx, [rbx+8]\n" ^
          "mov qword [rbx], rcx\n" ^ 
          "dec rdx\n" ^
          "add rbx, 8\n" ^
          "cmp rdx, 0\n" ^
          (Printf.sprintf "je %s\n" loop_opt_spec_params_end_label) ^ 
          (Printf.sprintf "jmp %s\n" loop_opt_spec_param_loop) ^ 
          (Printf.sprintf "%s:\n" loop_opt_spec_params_end_label) ^
          (* "mov r9, [rbp]\n" ^
          "sub rbp, 8\n" ^ (*needed???? problem!*)
          "mov r9, [rbp]\n" ^ *)
          (* "lea rbx, [rsp+8*2]\n" ^ tries to change in order to get the right position *)
          "inc r10\n" ^ (*I want to put one more arg count*)
          "mov qword [rsp+8*2], r10\n" ^(*Problem! Can't get the correct address*)
          (* "lea rbx, [rbx+32]\n" ^ *)
          "add r10, 2\n" ^
          "mov qword [rsp + 8*(r10)], sob_nil\n" ^
          "mov r9, [rbp]\n" ^
          (Printf.sprintf"jmp %s\n" stack_ok_label) ^
  
  
  
          (Printf.sprintf "%s:\n" arity_more_label) ^
          "mov r13, [rsp+2*8]\n" ^
          "mov rax, sob_nil\n" ^
          "mov r10, [rsp+2*8]\n" ^
          (*PUSH R8????*)
          "lea r8, [rsp+ 8*(2+r10)]\n" ^
          (Printf.sprintf "sub r10, %d\n" (List.length params')) ^ (*because I want rbx to hold the number of args to put in the list*)
          (Printf.sprintf "%s:\n" opt_loop_label) ^
          "cmp r10, 0\n" ^
          (Printf.sprintf "je %s\n" opt_loop_exit_label) ^
          "mov rcx, rax\n" ^ (*rcx always holds the previous pair and soon to be cdr*)
          "mov rdx, [r8]\n" ^ (*rdx will hold the new car*)
          "mov rdi, 17\n" ^
          "call malloc\n" ^
          "mov byte [rax], T_pair\n" ^
          "mov SOB_PAIR_CDR(rax), rcx\n" ^
          "mov SOB_PAIR_CAR(rax), rdx\n" ^
          "sub r8, 8\n" ^
          "dec r10\n" ^
          (Printf.sprintf "jmp %s\n" opt_loop_label) ^
          (Printf.sprintf "%s:\n" opt_loop_exit_label) ^
          (*POP R8???*)
          (Printf.sprintf "mov [rsp+8*(2+%d)], rax\n" ((List.length params')+1)) ^
          (Printf.sprintf "mov r10, %d\n" ((List.length params')+1)) ^
          "mov [rsp+16], r10\n" ^
  
          (*shrinking the stack now*)
          (*I need to put it all up numOfParamsOnTheBeginning - *)
          "mov r12, rsp\n" ^
          (Printf.sprintf "add r12, 8*(2+%d)\n" ((List.length params')+1)) ^ (*r12 holds the first arg to move*)
          "sub r13, [rsp+16]\n" ^ (*creating the offset*)
          "mov r10, r13\n" ^
          "shl r10, 3\n" ^
          "mov r15, r10\n" ^
          "add r10, r12\n" ^ (*now r10 holds the place the first place that should be copied to*)
          "mov r9, [rsp+16]\n" ^
          "add r9, 3\n" ^ (*r9 has the num of reps*)
          (Printf.sprintf "%s:\n" shrink_loop) ^
          "cmp r9, 0\n" ^
          (Printf.sprintf "je %s\n" shrink_end) ^
          "mov r14, [r12]\n" ^
          "mov [r10], r14\n" ^
          "sub r12, 8\n" ^
          "sub r10, 8\n" ^
          "dec r9\n" ^
          (Printf.sprintf "jmp %s\n" shrink_loop) ^
  
          (Printf.sprintf "%s:\n" shrink_end) ^
          "add rsp, r15\n" ^
  
  
  
          
          (*start of regular body like simple*)
          (Printf.sprintf "%s:\n" stack_ok_label) ^
          "mov r9, [rbp]\n" ^
          "enter 0, 0\n" (*rbp, rsp*) ^
          (run ((List.length params')+1) (env + 1) body) ^
          "leave\n" ^
          "mov r9, [rbp]\n" ^
          (Printf.sprintf "ret 8 * (3 + %d)\n" (List.length params')) ^ (*not sure it should be 7*)
          (Printf.sprintf "%s:\t; new closure is in rax\n" label_end)



      | ScmApplic' (proc, args, Non_Tail_Call) -> 
        let args_asm_code = List.map (fun (exp) ->  (run params env exp) ^ "\tpush rax\n") args in 
        let args_asm_code = List.fold_left (fun acc lst -> lst ^ acc) "" args_asm_code in 
        let args_num = List.length args in
        let args_num = Printf.sprintf "\tpush %d\n" args_num  in
        let proc_asm_code = run params env proc in
        
        args_asm_code ^
        args_num ^
        proc_asm_code ^
        "\tcmp byte [rax], T_closure 
        jne L_code_ptr_error\n
        mov rbx, SOB_CLOSURE_ENV(rax)\n
        push rbx\n
        call SOB_CLOSURE_CODE(rax)\n
        "

      | ScmApplic' (proc, args, Tail_Call) ->
        let args_asm_code = List.map (fun (exp) ->  (run params env exp) ^ "\tpush rax\n") args in 
        let args_asm_code = List.fold_left (fun acc lst -> lst ^ acc) "" args_asm_code in 
        let args_num = List.length args in
        let args_num = Printf.sprintf "\tpush %d\n" args_num  in
        let proc_asm_code = run params env proc in 
        let label = make_lambda_simple_arity_ok() in
        let label_end_of_args = make_tc_applic_recycle_frame_done() in
        let label_args_loop = make_tc_applic_recycle_frame_loop() in 

        args_asm_code ^
        (* all args were pushed to stack *)

        args_num ^
        (* args num were pushed to stack *)
        proc_asm_code ^

        (Printf.sprintf "%s:\n" label) ^
        "\tcmp byte [rax], T_closure\n
        jne L_code_ptr_error                      ; rax <- proc\n

        mov rbx, SOB_CLOSURE_ENV(rax)             ; rbx <- env(proc)\n
        push rbx                                  ; env pushed\n
        push qword [ rbp + 8 * 1]                 ; old ret addr pushed\n
        ; sagydebug\n
        push qword [ rbp ]                        ; the same old rbp pushed\n
        
        
        mov r8, [ rbp + 3 * 8]                    ; r8 <- old_code_num_of_args_n\n
        mov r9, [ rsp + 3 * 8 ]                   ; r9 <- new_code_num_of_args_m\n

        mov r10, r9
        add r10, 4                                ; total elemnts left to copy: num_of_args + 4 (num_of_args, lexenv, retf, rbp in f)
        
        mov r15, r10
        add r15, -1
                                                       
        mov r12, r8                               ; r12 <- index in new code
        add r12, 4
        add r12, -1

        mov r14, 0                                ; r14 <- 0 : init box: curr_arg_to_copy\n" ^
                 


        (Printf.sprintf "%s:\n" label_args_loop) ^

        "\tmov r14, [rsp + (r15 * 8)]               ; r14 <- i_element_old_code\n
        mov [rbp + (r12 * 8)], r14\n


        mov r14, 0                                ; clean box\n

        add r15, -1           
        add r10, -1                               ; args_copied_counter--\n
        add r12, -1 

        cmp r10, 0                                ; element_copied_counter == 0 ?\n" ^

        (Printf.sprintf "\tjne %s\n" label_args_loop) ^

        (Printf.sprintf "%s:\n" label_end_of_args) ^

        
        ";this pop rbp in sot to the right place\n"^
        "mov r15, r8\n
        add r15, 4\n
        shl r15, 3\n
        add rsp, r15\n" ^
        
        "\tpop rbp                                  ; restore the old rbp\n
        mov rcx, qword [rbp]
        mov rbx, SOB_CLOSURE_CODE(rax)\n          ; rbx <- code(proc)\n
        jmp rbx\n"




    and runs params env exprs' =
      List.map
        (fun expr' ->
          let code = run params env expr' in
          let code =
            code
            ^ "\n\tmov rdi, rax"
            ^ "\n\tcall print_sexpr_if_not_void\n" in
          code)
        exprs' in
    let codes = runs 0 0 exprs' in
    let code = String.concat "\n" codes in
    (* let code = "global main\nmain:\n \tenter 0, 0\n\tleave\n\tret 0\n" in *)
    (* let code = "" in *)
    let code =
      (file_to_string "prologue-1.asm")
      ^ (asm_of_constants_table consts)
      ^ "\nsection .bss\n"
      ^ (asm_of_free_vars_table free_vars)
      ^ (file_to_string "prologue-2.asm")
      ^ (asm_of_global_bindings global_bindings_table free_vars)
      ^ "\n"
      ^ code
      ^ (file_to_string "epilogue.asm") in
    code;;

  let compile_scheme_string file_out user =
    let init = file_to_string "init.scm" in
    let source_code = init ^ user in
    let sexprs = (PC.star Reader.nt_sexpr source_code 0).found in
    let exprs = List.map Tag_Parser.tag_parse sexprs in
    let exprs' = List.map Semantic_Analysis.semantics exprs in
    let asm_code = code_gen exprs' in
    (string_to_file file_out asm_code;
     Printf.printf "!!! Compilation finished. Time to assemble!\n");;  

  let compile_scheme_file file_in file_out =
    compile_scheme_string file_out (file_to_string file_in);;

(* end;; end of Code_Generation struct *)

(* end-of-input *)

let combine str = 
  let read = (Reader.nt_sexpr str 0).found in
  let parsed = Tag_Parser.tag_parse read in
  (* let semanted =  *)
  Semantic_Analysis.semantics parsed 
  (* make_free_vars_table [semanted] *)