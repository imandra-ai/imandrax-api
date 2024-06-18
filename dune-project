(lang dune 3.0)

(using mdx 0.2)

(generate_opam_files true)

(source
 (github imandra-ai/imandrax-api))

(name imandrax-api)

(authors "the imandrax team")

(maintainers "imandra.ai")

; from imandrax

(package
 (name imandrax-api)
 (synopsis "Public API and types for ImandraX")
 (depends
  (ocaml
   (>= 4.12.0))
  (containers
   (>= 3.4))
  (iter
   (>= 1.0))
  (zarith
   (>= 1.12))
  ppx_deriving
  ppx_deriving_yojson
  imandrakit
  imandrakit-log
  imandrakit-io
  (pbrt
   (>= 3.0))
  (pbrt_yojson
   (>= 3.0))
  (cryptokit
   (>= 0.19))
  ; TODO: bump to next release with the static build fix
  ppxlib
  (odoc :with-doc))
 (depopts camlzip)
 (conflicts
  (containers
   (= 3.13))))

(package
 (name imandrax-api-proto)
 (synopsis "protobuf definitions for ImandraX's API")
 (depends
  (pbrt
   (>= 3.0))
  (pbrt_yojson
   (>= 3.0))
  (pbrt_services
   (>= 3.0))
  (ocaml-protoc
   (and
    (>= 3.0)
    :with-dev-setup))))

(package
 (name imandrax-api-client)
 (synopsis "RPC client for ImandraX's API (transport agnostic)")
 (depends
  (containers
   (and
    (>= 3.0)
    :with-test))
  (trace
   (>= 0.6))
  logs
  (ocaml
   (>= 4.12))
  (moonpool
   (and
    (>= 0.6)
    (< 0.7)))
  (pbrt
   (>= 3.0))
  (pbrt_yojson
   (>= 3.0))
  (pbrt_services
   (>= 3.0))))

(package
 (name imandrax-api-client-batrpc)
 (synopsis "RPC client for ImandraX's API using BatRPC")
 (depends
  (imandrax-api-client
   (= :version))
  batrpc
  moonpool
  (trace
   (>= 0.6))
  (pbrt
   (>= 3.0))
  (pbrt_yojson
   (>= 3.0))
  (pbrt_services
   (>= 3.0))))

(package
 (name imandrax-api-client-ezcurl)
 (synopsis "RPC client for ImandraX's API using Ezcurl")
 (depends
  (imandrax-api-client
   (= :version))
  ezcurl
  moonpool
  (trace
   (>= 0.6))
  (pbrt
   (>= 3.0))
  (pbrt_yojson
   (>= 3.0))
  (pbrt_services
   (>= 3.0))))

(package
 (name imandrax-api-client-cohttp)
 (synopsis "RPC client for ImandraX's API using cohttp + lwt")
 (depends
  (imandrax-api-client
   (= :version))
  lwt
  twirp_cohttp_lwt_unix
  (trace
   (>= 0.6))
  (pbrt
   (>= 3.0))
  (pbrt_yojson
   (>= 3.0))
  (pbrt_services
   (>= 3.0))))

(package
  (name imandrax-api-top)
  (synopsis "Interactive toplevel for ImandraX's API")
  (depends
    (ocaml (>= 5.0))
    moonpool
    (containers (>= 3.0))
    (imandrax-api-client (= :version))
    (imandrax-api-client-ezcurl (= :version))
    (trace (>= 0.6))
    ppx_deriving))

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
    (imandrax-api-client-batrpc (= :version))
    (trace (>= 0.6))
    uuidm
    xdg
    webbrowser
    ppx_deriving
    trace-tef
    (tiny_httpd (>= 0.16))
    (ppx_subliner (>= 0.2))
    (linenoise (and (>= 1.4) (< 2.0)))))
