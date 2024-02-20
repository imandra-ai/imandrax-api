(lang dune 3.0)
(using mdx 0.2)
(generate_opam_files true)
(source
 (github imandra-ai/imandrax-api))
(authors "the imandrax team")
(maintainers "imandra.ai")

(package
  (name imandrax-api-proto)
  (synopsis "protobuf definitions for ImandraX's API")
  (depends
    (pbrt (>= 3.0))
    (pbrt_yojson (>= 3.0))
    (pbrt_services (>= 3.0))))

(package
  (name imandrax-api-client)
  (synopsis "RPC client for ImandraX's API")
  (depends
    batrpc
    moonpool
    (trace (>= 0.6))
    (pbrt (>= 3.0))
    (pbrt_yojson (>= 3.0))
    (pbrt_services (>= 3.0))))

(package
  (name imandrax-api-cli)
  (synopsis "CLI for ImandraX's API")
  (depends
    (ocaml (>= 5.0))
    batrpc
    moonpool
    (linenoise (>= 1.4))
    (containers (>= 3.0))
    (imandrax-api-client (= :version))
    (trace (>= 0.6))
    ppx_deriving
    trace-tef
    (ppx_subliner (>= 0.2))
    (linenoise (and (>= 1.4) (< 2.0)))))
