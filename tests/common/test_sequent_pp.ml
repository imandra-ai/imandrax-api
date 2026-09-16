(** Layout tests for {!Imandrax_api_common.Sequent}.

    [pp_seq] must be a composable pretty-printer: no leading or trailing
    newline, and only relative breaks, so that it indents correctly when nested
    inside another box. The [`foo`]/[`bar`] markers below pin the absence of
    stray newlines at the edges. *)

module Sequent = Imandrax_api_common.Sequent

let pp = Sequent.pp_t_poly Fmt.string
let mk hyps concls : string Sequent.t_poly = { hyps; concls }

(* cases
   ===== *)

let cases : (string * string Sequent.t_poly) list =
  [
    ("no hypotheses", mk
      []
      [ None, "terminates f" ]
    );
    ( "unnamed and named hypotheses", mk
      [ None, "x > 0"; Some "h_named", "y = 3" ]
      [ None, "f x = 2" ]
    );
    ( "several conclusions", mk
      [ None, "x > 0" ]
      [ None, "f x = 2"; Some "c_named", "g x = 3" ]
    );
    ("no conclusions", mk
      [ None, "x > 0" ]
      []
    );
    ("empty sequent", mk
      []
      []
    );
    ("long hypothesis", mk
      [ None, "a_very_long_hypothesis_term && another_long_conjunct && yet_another_one" ]
      [ None, "a_very_long_hypothesis_term && another_long_conjunct && yet_another_one" ]
    );
  ] [@@ocamlformat "disable"]

(* top level
   --------- *)

let () =
  Fmt.pr "# Top level@.";
  Fmt.pr "There should be no leading or trailing new lines@.";
  cases
  |> List.iter (fun (name, seq) ->
         Fmt.pr "## %s@." name;
         Fmt.pr "`foo`%a`bar`@." pp seq;
         Fmt.pr "@.")

(* nested
   ------ *)

let () =
  Fmt.pr "# Nested in a record box@.";
  Fmt.pr
    "Every line should pick up the enclosing box's indentation instead of \
     jumping to column 0@.";
  cases
  |> List.iter (fun (name, seq) ->
         Fmt.pr "## %s@." name;
         Fmt.pr "@[<v 2>{ before1 = 0;@,before2 =@,`foo`%a`bar`;@,after1 = ...@]@,}@." pp
           seq;
         Fmt.pr "@.")

(* nested, mid-line
   ---------------- *)

let () =
  Fmt.pr "# Nested mid-line@.";
  Fmt.pr
    "The sequent starts mid-line, so its lines should align to the column \
     where it started, not to the enclosing box's own indentation@.";
  cases
  |> List.iter (fun (name, seq) ->
         Fmt.pr "## %s@." name;
         Fmt.pr "@[<v 6>outer { before = `foo`%a`bar`;@,after = ... }@]@." pp seq;
         Fmt.pr "@.")
