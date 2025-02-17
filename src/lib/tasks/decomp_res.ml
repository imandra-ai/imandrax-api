type ('term, 'ty) success = {
  anchor: Imandrax_api.Anchor.t;
  decomp: ('term, 'ty) Imandrax_api_common.Fun_decomp.t_poly;
}
[@@deriving twine, typereg, map, iter, show { with_path = false }]

type error = Error of Imandrakit_error.Error_core.t
[@@deriving twine, typereg, show { with_path = false }]

type 'a result = ('a, error) Util_twine.Result.t
[@@deriving twine, typereg, map, iter, show]

type ('term, 'ty) shallow_poly = {
  from:
    ('term Decomp_task.decomp_poly Imandrax_api_ca_store.Ca_ptr.t
    [@printer Imandrax_api_ca_store.Ca_ptr.pp]);
  res: ('term, 'ty) success result;
  stats: Imandrax_api.Stat_time.t;
  report:
    (Imandrax_api_report.Report.t Imandrax_api.In_mem_archive.t
    [@twine.encode In_mem_archive.to_twine]
    [@twine.decode In_mem_archive.of_twine]
    [@printer In_mem_archive.pp ()]);
      (** The report, when it's not serialized it's stored compressed in memory.
      *)
}
[@@deriving twine, typereg, map, iter, show { with_path = false }]

type ('term, 'ty) full_poly = {
  from: 'term Decomp_task.decomp_poly;
  res: ('term, 'ty) success result;
  stats: Imandrax_api.Stat_time.t;
  report:
    (Imandrax_api_report.Report.t Imandrax_api.In_mem_archive.t
    [@twine.encode In_mem_archive.to_twine]
    [@twine.decode In_mem_archive.of_twine]
    [@printer In_mem_archive.pp ()]);
      (** The report, when it's not serialized it's stored compressed in memory.
      *)
}
[@@deriving twine, typereg, map, iter, show { with_path = false }]

module Shallow = struct
  type ('term, 'ty) t_poly = ('term, 'ty) shallow_poly
  [@@deriving twine, map, iter, show { with_path = false }]

  type t = (Imandrax_api_mir.Term.t, Imandrax_api_mir.Type.t) shallow_poly
  [@@deriving twine, typereg, show] [@@typereg.name "Shallow.t"]
end

module Full = struct
  type ('term, 'ty) t_poly = ('term, 'ty) full_poly
  [@@deriving twine, map, iter, show { with_path = false }]

  type t = (Imandrax_api_mir.Term.t, Imandrax_api_mir.Type.t) full_poly
  [@@deriving twine, typereg, show] [@@typereg.name "Full.t"]
end
