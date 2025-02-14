(** A partial view of computation values.

    This doesn't capture closures, but it's enough for the needs of the API
    because ImandraX's models will never contain closures because of FO logic
    restrictions. *)

include Imandrax_api_eval.Value
