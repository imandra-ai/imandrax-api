type success = {
  anchor: Imandrax_api.Anchor.t;
  decomp: Imandrax_api_cir.Fun_decomp.t;
}
[@@deriving twine, typereg, show { with_path = false }]

type error = Error of Imandrakit_error.Error_core.t
[@@deriving twine, typereg, show { with_path = false }]

type 'a result = ('a, error) Util_twine.Result.t
[@@deriving twine, typereg, show]

type t = {
  from:
    (Imandrax_api_cir.Decomp.t Imandrax_api_ca_store.Ca_ptr.t
    [@printer Imandrax_api_ca_store.Ca_ptr.pp]);
  res: success result;
  stats: Imandrax_api.Stat_time.t;
  report:
    (Imandrax_api_report.Report.t Imandrax_api.In_mem_archive.t
    [@twine.encode In_mem_archive.to_twine]
    [@twine.decode In_mem_archive.of_twine]
    [@printer In_mem_archive.pp ()]);
      (** The report, when it's not serialized it's stored compressed in memory. *)
}
[@@deriving twine, typereg, show { with_path = false }]
