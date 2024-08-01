open Common_

type t = {
  tag: string;
  ty: TR.Ty_expr.t;
}

let show self = spf "{tag=%S, ty=%s}" self.tag (TR.Ty_expr.show self.ty)
