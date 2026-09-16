(** Layout tests for {!Imandrax_api_eval.Ordinal}.

    [Ordinal.pp] emits breaks between the summands of an ordinal, so it must
    wrap them in a box of its own: otherwise where an ordinal wraps is decided
    by whatever box the caller happens to have open. The margin is narrowed
    below so the breaks actually fire. The [`foo`]/[`bar`] markers pin the
    absence of stray newlines at the edges. *)

module Ordinal = Imandrax_api_eval.Ordinal

let pp = Ordinal.pp
let i n : Ordinal.t = Int (Z.of_int n)
let cons a coeff tl : Ordinal.t = Cons (a, Z.of_int coeff, tl)

(* cases
   ===== *)

let cases : (string * Ordinal.t) list =
  [
    "finite", i 42;
    "omega", cons (i 1) 1 (i 0);
    "omega with coefficient and tail", cons (i 1) 3 (i 7);
    "several summands", cons (i 3) 5 (cons (i 2) 4 (cons (i 1) 3 (i 2)));
    ( "many summands, wraps",
      cons (i 9) 111
        (cons (i 8) 222
           (cons (i 7) 333
              (cons (i 6) 444 (cons (i 5) 555 (cons (i 4) 666 (i 777)))))) );
    "nested exponent", cons (cons (i 1) 1 (i 0)) 2 (i 1);
  ]

let () = Format.pp_set_margin Format.std_formatter 60

(* top level
   --------- *)

let () =
  Fmt.pr "# Top level (margin 60)@.";
  Fmt.pr "There should be no leading or trailing new lines@.";
  cases
  |> List.iter (fun (name, o) ->
         Fmt.pr "## %s@." name;
         Fmt.pr "`foo`%a`bar`@." pp o;
         Fmt.pr "@.")

(* nested, mid-line
   ---------------- *)

(* The regression this guards: the printer must break inside its own box, so
   that its summands align to where the ordinal started rather than to the
   enclosing box's indentation. *)

let () =
  Fmt.pr "# Nested mid-line@.";
  Fmt.pr
    "Summands should align to the column where the ordinal started, not to the \
     enclosing box's own indentation@.";
  cases
  |> List.iter (fun (name, o) ->
         Fmt.pr "## %s@." name;
         Fmt.pr "@[<v 6>outer { ord = `foo`%a`bar`;@,view = ... }@]@." pp o;
         Fmt.pr "@.")
