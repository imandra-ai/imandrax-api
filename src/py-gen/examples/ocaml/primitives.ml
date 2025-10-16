type my_int = int
type my_float = float
type my_string = string
type my_bool = bool
type my_char = char
type my_unit = unit
type my_bytes = bytes
type my_int32 = int32
type my_int64 = int64
type my_nativeint = nativeint

type age = int
type user_age = age

let make_my_int () : my_int = 42
let make_my_float () : my_float = 3.14
let make_my_string () : my_string = "hello"
let make_my_bool () : my_bool = true
let make_my_char () : my_char = 'a'
let make_my_unit () : my_unit = ()
let make_my_bytes () : my_bytes = Bytes.of_string "bytes"
let make_my_int32 () : my_int32 = 100l
let make_my_int64 () : my_int64 = 1000L
let make_my_nativeint () : my_nativeint = 999n

let make_age () : age = 25
let make_user_age () : user_age = 30
