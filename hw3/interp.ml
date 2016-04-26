(* Name: 

   UID: 

   Others With Whom I Discussed Things:

   Other Resources I Consulted:
   
*)

(* EXCEPTIONS *)

(* This is a marker for places in the code that you have to fill in.
   Your completed assignment should never raise this exception. *)
exception ImplementMe of string

(* This exception is thrown when a type error occurs during evaluation
   (e.g., attempting to invoke something that's not a function).
   You should provide a useful error message.
*)
exception DynamicTypeError of string

(* This exception is thrown when pattern matching fails during evaluation. *)  
exception MatchFailure  

(* EVALUATION *)

(* See if a value matches a given pattern.  If there is a match, return
   an environment for any name bindings in the pattern. If there is not
   a match, raise the MatchFailure exception.
*)
let rec patMatch (pat:mopat) (value:movalue) : moenv =
  match (pat, value) with (* (name, value) -> map variables to their values *)
      (* an integer pattern matches an integer only when they are the same constant;
	 no variables are declared in the pattern so the returned environment is empty *)
      (IntPat(i), IntVal(j)) when i=j -> Env.empty_env()
    | (BoolPat(x), BoolVal(y)) when x=y -> Env.empty_env()
    | (WildcardPat, _)  -> Env.empty_env()
    | (VarPat(s), _)    -> (Env.add_binding s value (Env.empty_env())) 
    | _ -> raise(MatchFailure)
    

 (*   | (VarPat(s), BoolVal(i)) -> 
    | (TuplePat(patList1), TupleVal(patList2)) ->
    | (DataPat(s1, patOption), DataVal(s2, valOption)) ->
    | _ -> raise MatchFailure
  *)
(* return a local environment generated by patMatch *)
(* no existance enviornment *)

(* 
     
(* The syntax and representation of MOCaml patterns.

  p ::= intconst | boolconst | _ | var | (p1,...,pn) | C | C p
  intconst ::= integer constant
  boolconst ::= true | false
  var ::= variable -- an identifier whose first letter is lowercase
  C ::= data constructor -- an identifier whose first letter is uppercase

*)
type mopat =
    IntPat of int                     <-> IntVal
  | BoolPat of bool                   <-> BoolVal
  | WildcardPat                       <-> _
  | VarPat of string                  <-> IntVal, BoolVal, FunctionVal, TupleVal, DataVal
  | TuplePat of mopat list            <-> TupleVal 
  | DataPat of string * mopat option  <-> DataVal
  DataPat("Leaf", None) match with Leaf value
  DataPat("Node", WildcardPat) match with (Node _), which matches against any Node value
;;

(* The representation of MOCaml values, which are the results of
evaluating expressions.

  v ::= intconst | boolconst | function p -> e | (v1,...,vn) | C | C v
*)
type movalue =
    IntVal of int
  | BoolVal of bool
      (* A function value carries its lexical environment with it! *)
      (* If the function is recursive it also carries around its own name
         (the "string option" component below). *)
  | FunctionVal of string option * mopat * moexpr * moenv
  | TupleVal of movalue list
  | DataVal of string * movalue option

*)

    

    
(* Evaluate an expression in the given environment and return the
   associated value.  Raise a MatchFailure if pattern matching fails.
   Raise a DynamicTypeError if any other kind of error occurs (e.g.,
   trying to add a boolean to an integer) which prevents evaluation
   from continuing.
*)
let rec evalExpr (e:moexpr) (env:moenv) : movalue =
  match e with
      (* an integer constant evaluates to itself *)
    IntConst(i)     -> IntVal(i)
    | BoolConst(x)  -> BoolVal(x)
    | Var(s)        -> (
        try (Env.lookup s env) with 
        Env.NotBound -> raise(DynamicTypeError "unbounded variable"))
    | BinOp(exp1, op, exp2) -> (
        let v1 = evalExpr exp1 env in 
        let v2 = evalExpr exp2 env in 
        match (v1, v2) with 
        (IntVal v1, IntVal v2) -> 
        (match op with 
          Plus -> IntVal(v1 + v2)
          | Minus -> IntVal(v1 - v2)
          | Times ->  IntVal(v1 * v2)
          | Eq -> BoolVal(v1 = v2)
          | Gt -> BoolVal(v1 > v2))
        | _ -> raise (DynamicTypeError "operation can only applied to integers"))
    | Negate(e0)      -> (
        let v0 = evalExpr e0 env in
        match v0 with 
        IntVal(i) -> IntVal(-i) 
        | _ -> raise(DynamicTypeError "can only negate integers"))
    | If(e1, e2, e3)  -> (
        let v1 = try evalExpr e1 env with 
        Env.NotBound -> raise(DynamicTypeError "unbounded variable") in
        match v1 with
        BoolVal(b) -> 
          if b=true 
          then try evalExpr e2 env with Env.NotBound -> raise(DynamicTypeError "unbounded variable")
          else try evalExpr e3 env with Env.NotBound -> raise(DynamicTypeError "unbounded variable")
        | _ -> raise(DynamicTypeError "the first expression should return bool"))
    | Function(pattern, expression) -> FunctionVal(None, pattern, expression, env)
    | FunctionCall(exp1, exp2)      -> (
        let myFunction = try evalExpr exp1 env with 
        Env.NotBound -> raise(DynamicTypeError "unbounded variable") in 
        match myFunction with
        FunctionVal(fname0, param0, exp0, env0) -> 
          (let newEnv = Env.combine_envs env env0 in
          let argument = evalExpr exp2 newEnv in

        )
      )
(* 
    Function of mopat * moexp
    mopat = The formal parameter, not the argument type  
            so use pattern matching to bind arguments to their associated variables. 
    moexpr = an expression that represents the function body.
    e.g (function x -> x) would be represented by the data structure 
        Function(VarPat "hi", Var "hi")

    FunctionVal of string option * mopat * moexpr * moenv

  -----------

    FunctionCall of moexpr * moexpr
   
    This is our representation of function calls. 
    1st moexpr = an expression that should evaluate to a function
    2nd moexpr = the actual argument being passed to that function
    e.g (function x -> x) true  ==>
        FunctionCall(Function(VarPat "hi", Var "hi"), BoolConst true)

    Then before the function's body is evaluated during a function call, 
      the mapping from the stored name to the function value should be added 
      to the environment, ensuring that references to the function's name in 
      its own body will be handled properly.
*)

        
 (*   
      prerr_string ("x" ^ "y");;
      prerr_string(string_from_int x);;
*)

        

  (* 
type moop = Plus | Minus | Times | Eq | Gt
type moexpr =
  IntConst of int
  | BoolConst of bool
  | Var of string
  | BinOp of moexpr * moop * moexpr
  | Negate of moexpr 
  | If of moexpr * moexpr * moexpr
  | Function of mopat * moexpr
  | FunctionCall of moexpr * moexpr
  | Match of moexpr * (mopat * moexpr) list
  | Tuple of moexpr list
  | Data of string * moexpr option

 *)
    | _ -> raise MatchFailure


(* Evaluate a declaration in the given environment.  Evaluation
   returns the name of the variable declared (if any) by the
   declaration along with the value of the declaration's expression.
*)
let rec evalDecl (d:modecl) (env:moenv) : moresult =
  match d with
      (* a top-level expression has no name and is evaluated to a value *)
      Expr(e) -> (None, evalExpr e env)
    | Let(s, e) -> (Some s, evalExpr e env) (* let x = e *)
(*     | LetRec(s, e) -> () let rec f x = e, "let rec" can only used to declare functions *)















