(lang dune 2.9)
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
