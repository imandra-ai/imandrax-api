open Common_

type t = {
  clique: TR.Ty_def.clique;
  cached: bool;
}
[@@deriving show { with_path = false }]
