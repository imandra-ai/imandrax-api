open Common_

let fpf = Printf.fprintf

let gen ~out (cliques : TR.Ty_def.clique list) : unit =
  let@ oc = CCIO.with_out out in

  fpf oc "# generated using genbindings.ml\n";

  ignore cliques;
  ()
