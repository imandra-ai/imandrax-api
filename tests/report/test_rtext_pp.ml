(** Layout tests for {!Imandrax_api_report.Rtext}.

    Like {!Imandrax_api_common.Sequent}, [Rtext.pp] must lay out relative to the
    enclosing box. The interesting cases are the ones carrying text that is not
    under the printer's control: a string payload with embedded newlines, and an
    embedded sequent. The [`foo`]/[`bar`] markers pin the absence of stray
    newlines at the edges. *)

module Rtext = Imandrax_api_report.Rtext
module Sequent = Imandrax_api_common.Sequent

let pp = Rtext.pp Fmt.string

let seq : string Sequent.t_poly =
  { hyps = [ None, "x > 0" ]; concls = [ None, "f x = 2" ] }

(* cases
   ===== *)

let cases : (string * string Rtext.t) list =
  [
    "plain text", [ S "hello" ];
    "explicit newline item", [ S "before"; Newline; S "after" ];
    "string with embedded newlines", [ S "line one\nline two\nline three" ];
    "term", [ S "the term is "; Term "f x + 1" ];
    "embedded sequent", [ S "goal:"; Newline; Sequent seq ];
    "nested rtext", [ S "outer "; Sub [ S "inner"; Newline; S "more" ] ];
    "list of rtext", [ L [ [ S "a" ]; [ S "b" ]; [ S "c" ] ] ];
    "substitution", [ Subst [ "x", "1"; "y", "2" ] ];
  ]

(* top level
   --------- *)

let () =
  Fmt.pr "# Top level@.";
  Fmt.pr "There should be no leading or trailing new lines@.";
  cases
  |> List.iter (fun (name, t) ->
         Fmt.pr "## %s@." name;
         Fmt.pr "`foo`%a`bar`@." pp t;
         Fmt.pr "@.")

(* nested
   ------ *)

let () =
  Fmt.pr "# Nested in a record box@.";
  Fmt.pr
    "Every line should pick up the enclosing box's indentation instead of \
     jumping to column 0@.";
  cases
  |> List.iter (fun (name, t) ->
         Fmt.pr "## %s@." name;
         Fmt.pr "@[<v 2>{ id = 0;@,text =@,`foo`%a`bar`;@,view = ...@]@,}@." pp
           t;
         Fmt.pr "@.")

(* nested, mid-line
   ---------------- *)

let () =
  Fmt.pr "# Nested mid-line@.";
  Fmt.pr
    "The rtext starts mid-line, so its lines should align to the column where \
     it started, not to the enclosing box's own indentation@.";
  cases
  |> List.iter (fun (name, t) ->
         Fmt.pr "## %s@." name;
         Fmt.pr "@[<v 6>outer { text = `foo`%a`bar`;@,view = ... }@]@." pp t;
         Fmt.pr "@.")
