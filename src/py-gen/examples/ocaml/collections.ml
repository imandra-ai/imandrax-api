type int_option = int option
type string_list = string list
type float_array = float array

type nested_option = int list option
type nested_list = string option list
type nested_array = bool list array

type deep_nest = int list option list
type matrix = int list list
type triple_array = string array array array

type user_id = int
type user_list = user_id list
type optional_user = user_id option

let make_int_option () : int_option = Some 42
let make_string_list () : string_list = ["hello"; "world"]
let make_float_array () : float_array = [| 1.0; 2.0; 3.0 |]

let make_nested_option () : nested_option = Some [1; 2; 3]
let make_nested_list () : nested_list = [Some "a"; None; Some "b"]
let make_nested_array () : nested_array = [| [true; false]; [false; true] |]

let make_deep_nest () : deep_nest = [Some [1; 2]; None; Some [3]]
let make_matrix () : matrix = [[1; 2]; [3; 4]; [5; 6]]
let make_triple_array () : triple_array = [| [| [| "a" |] |] |]

let make_user_id () : user_id = 100
let make_user_list () : user_list = [1; 2; 3]
let make_optional_user () : optional_user = Some 42
