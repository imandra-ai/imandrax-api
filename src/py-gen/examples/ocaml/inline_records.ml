type event =
  | Click of { x: int; y: int }
  | Keypress of { key: char; modifiers: string list }
  | Scroll of { delta: float }

type user_action =
  | Login of { username: string; timestamp: int }
  | Logout
  | UpdateProfile of { fields: (string * string) list; timestamp: int }

type api_response =
  | Success of { data: string; code: int }
  | Error of { message: string; code: int; details: string option }
  | Pending

type database_query =
  | Select of { table: string; columns: string list; where_clause: string option }
  | Insert of { table: string; values: (string * string) list }
  | Update of { table: string; set_values: (string * string) list; where_clause: string }
  | Delete of { table: string; where_clause: string }

let make_event () : event = Click { x = 100; y = 200 }

let make_user_action () : user_action =
  Login { username = "alice"; timestamp = 1234567890 }

let make_api_response () : api_response =
  Success { data = "result"; code = 200 }

let make_database_query () : database_query =
  Select {
    table = "users";
    columns = ["id"; "name"; "email"];
    where_clause = Some "age > 18"
  }
