type point = {
  x: int;
  y: int;
}

type person = {
  name: string;
  age: int;
  email: string option;
}

type nested_record = {
  id: int;
  location: point;
  owner: person;
}

type record_with_collections = {
  tags: string list;
  scores: float array;
  metadata: (string * int) option;
}

type complex_fields = {
  simple: int;
  optional: float option;
  nested_list: int list list;
  tuple_field: string * bool;
}

let make_point () : point = { x = 10; y = 20 }

let make_person () : person = {
  name = "Alice";
  age = 30;
  email = Some "alice@example.com";
}

let make_nested_record () : nested_record = {
  id = 1;
  location = { x = 100; y = 200 };
  owner = { name = "Bob"; age = 25; email = None };
}

let make_record_with_collections () : record_with_collections = {
  tags = ["ocaml"; "types"; "registry"];
  scores = [| 9.5; 8.7; 9.2 |];
  metadata = Some ("version", 1);
}

let make_complex_fields () : complex_fields = {
  simple = 42;
  optional = Some 3.14;
  nested_list = [[1; 2]; [3; 4]];
  tuple_field = ("test", true);
}
