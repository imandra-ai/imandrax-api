module P = Imandra_proof_system_encode
module E_cbor = Imandra_proof_system_encode_cbor

let () =
  let buf = Buffer.create 32 in
  let enc = E_cbor.encoder in

  let total_bytes = ref 0 in
  Printf.printf "start proof\n";

  (* make an output that shows an hexdump per entry *)
  let output_entry buf =
    let str = Buffer.contents buf in
    total_bytes := !total_bytes + String.length str;
    let cbor, _ = CBOR.Simple.decode_partial str in
    Printf.printf "entry (%dB): %s\n" (String.length str)
      (CBOR.Simple.to_diagnostic cbor);
    (* (CBOR.SiHex.hexdump_s @@ Hex.of_string @@ Buffer.contents buf); *)
    Buffer.clear buf
  in
  let out =
    P.Output.(Out { st = buf; enc; output_entry; gen_id = make_gen_id () })
  in

  let id_bool = P.ty_app out "bool" [] in
  let id_true = P.t_bool out true in

  let id_x = P.t_var out (P.var out "x" id_bool) in
  let id_x_eq_x = P.t_builtin_eq out id_bool id_x id_x in
  let _id_ass = P.p_assume out P.scope0 id_x_eq_x in

  Printf.printf "proof done (%d B total)\n%!" !total_bytes;
  ()
