(lang dune 3.0)

(using mdx 0.2)

(generate_opam_files true)

(source
 (github imandra-ai/imandrax-api))

(name imandrax-api)

;; keep in sync with imandrax

(version 0.19)

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
  (imandra-proof-system
   (= :version))
  ppx_deriving
  ppx_deriving_yojson
  imandrakit
  imandrakit-log
  imandrakit-io
  (pbrt
   (>= 4.0))
  (pbrt_yojson
   (>= 4.0))
  (ocaml-protoc
   (and
    (>= 3.1.1)
    :with-dev-setup))
  ; TODO: bump to next release with the static build fix
  (cryptokit
   (>= 0.19))
  (odoc :with-doc))
 (depopts camlzip)
 (conflicts
  (containers
   (= 3.13))))

(package
 (name imandrax-api-ppx)
 (synopsis "Ppx-deriving for ImandraX API")
 (depends
  (ocaml
   (>= 4.12.0))
  (imandrax-api :version)
  (ppxlib
   (and
    (>= 0.34)
    (<= 0.35)))
  (odoc :with-doc)))

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
   (>= 4.14))
  (moonpool
   (and
    (>= 0.7)
    (< 0.11)))
  (pbrt
   (>= 4.0))
  (pbrt_yojson
   (>= 4.0))
  (pbrt_services
   (>= 4.0))))

(package
 (name imandrax-api-client-ezcurl)
 (synopsis "RPC client for ImandraX's API using Ezcurl")
 (depends
  (imandrax-api-client
   (= :version))
  imandrakit-thread
  ezcurl
  (moonpool
   (and
    (>= 0.7)
    (< 0.11)))
  (trace
   (>= 0.6))
  (pbrt
   (>= 4.0))
  (pbrt_yojson
   (>= 4.0))
  (pbrt_services
   (>= 4.0))))

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
   (>= 4.0))
  (pbrt_yojson
   (>= 4.0))
  (pbrt_services
   (>= 4.0))))

(package
 (name imandrax-api-top)
 (synopsis "Interactive toplevel for ImandraX's API")
 (depends
  (ocaml
   (>= 5.0))
  (containers
   (>= 3.0))
  (imandrax-api-client
   (= :version))
  (imandrax-api-client-ezcurl
   (= :version))
  (trace
   (>= 0.6))
  ppx_deriving))

(package
 (name imandra-proof-system)
 (synopsis "Description and codegen for Imandra's durable proof system")
 (depends
  (ocaml
   (>= 4.12))
  (yojson
   (>= 1.6))
  ppx_deriving
  ppx_deriving_yojson
  imandrakit
  (containers
   (>= 3.0))
  (cbor :with-test)))

(package
 (name imandrax-api-prelude)
 (synopsis "ImandraX Prelude")
 (depends
  (ocaml
   (>= 4.12))
  ppx_deriving
  (containers
   (>= 3.0))
  zarith
  imandrax-api-ppx))
