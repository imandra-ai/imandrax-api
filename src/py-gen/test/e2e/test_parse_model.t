Setup: Define helper function
  $ fence() { printf '```python\n'; cat; printf '```'; }
  $ run_test() { (
  >    cd $DUNE_SOURCEROOT/src/py-gen && \
  >    py-gen-parse-model "test/data/model/$1" - \
  >    | uv run py-gen - \
  >    | fence
  > ); }

inline_record
  $ run_test composite/inline_record.yaml
  ```python
  from dataclasses import dataclass
  
  
  @dataclass
  class Scroll:
      arg0: real
  
  
  event = Scroll
  w: event = Scroll(2.0)
  
  ```

map_default_value_only
  $ run_test composite/map_default_value_only.yaml
  ```python
  w: defaultdict[_a_0, bool] = defaultdict(lambda: False)
  
  ```

map_int_bool
  $ run_test composite/map_int_bool_0.yaml
  ```python
  w: defaultdict[int, bool] = defaultdict(lambda: False)
  
  ```

map_int_bool_1
  $ run_test composite/map_int_bool_1.yaml
  ```python
  w: defaultdict[int, bool] = defaultdict(lambda: False, {2: True})
  
  ```

map_int_bool_2
  $ run_test composite/map_int_bool_2.yaml
  ```python
  w: defaultdict[int, bool] = defaultdict(lambda: False, {2: True, 3: True})
  
  ```

map_int_bool_3
  $ run_test composite/map_int_bool_3.yaml
  ```python
  w: defaultdict[int, bool] = defaultdict(
      lambda: False, {2: True, 3: False, 5: True}
  )
  
  ```

multiset_empty
  $ run_test composite/multiset_empty.yaml
  ```python
  w: defaultdict[_a_0, int] = defaultdict(lambda: 0)
  
  ```

multiset_nonempty
  $ run_test composite/multiset_nonempty.yaml
  ```python
  w: defaultdict[int, int] = defaultdict(lambda: 0, {1: 2, 3: 1, 2: 2})
  
  ```

set_empty
  $ run_test composite/set_empty.yaml
  ```python
  w: defaultdict[_a_0, bool] = defaultdict(lambda: False)
  
  ```

set_nonempty
  $ run_test composite/set_nonempty.yaml
  ```python
  w: defaultdict[int, bool] = defaultdict(
      lambda: False, {1: True, 3: True, 2: True}
  )
  
  ```

variant_and_record
  $ run_test composite/variant_and_record.yaml
  ```python
  from dataclasses import dataclass
  
  
  @dataclass
  class position:
      x: int
      y: int
      z: real
  
  
  @dataclass
  class North:
      pass
  
  
  direction = North
  
  
  @dataclass
  class Move:
      arg0: position
      arg1: direction
  
  
  movement = Move
  w: movement = Move(position(1, 2, 3.0), North())
  
  ```

bool list
  $ run_test primitive/bool_list.yaml
  ```python
  w: list[bool] = [True, False]
  
  ```

empty list
  $ run_test primitive/empty_list.yaml
  ```python
  w = []
  
  ```

int option
  $ run_test primitive/int_option.yaml
  ```python
  from dataclasses import dataclass
  
  
  @dataclass
  class Some:
      arg0: int
  
  
  option = Some
  w: option = Some(2)
  
  ```

int
  $ run_test primitive/int.yaml
  ```python
  w: int = 2
  
  ```

LChar
  $ run_test primitive/LChar.yaml
  ```python
  w: str = '\x00'
  
  ```

LString
  $ run_test primitive/LString.yaml
  ```python
  w: list[str] = ['h', 'i']
  
  ```

real
  $ run_test primitive/real.yaml
  ```python
  w: float = 3.14
  
  ```

record
  $ run_test primitive/record.yaml
  ```python
  from dataclasses import dataclass
  
  
  @dataclass
  class user:
      id: int
      active: bool
  
  
  w: user = user(1, True)
  
  ```

single element int list
  $ run_test primitive/single_element_int_list.yaml
  ```python
  w: list[int] = [1]
  
  ```

tuple (bool * int)
  $ run_test primitive/tuple_(bool_*_int).yaml
  syntax error near unexpected token `('
  `run_test primitive/tuple_(bool_*_int).yaml'
  [1]

variant1
  $ run_test primitive/variant1.yaml
  ```python
  from dataclasses import dataclass
  
  
  @dataclass
  class Active:
      pass
  
  
  status = Active
  w: status = Active()
  
  ```

variant2
  $ run_test primitive/variant2.yaml
  ```python
  from dataclasses import dataclass
  
  
  @dataclass
  class Waitlist:
      arg0: int
  
  
  status = Waitlist
  w: status = Waitlist(1)
  
  ```

variant3
  $ run_test primitive/variant3.yaml
  ```python
  from dataclasses import dataclass
  
  
  @dataclass
  class Waitlist:
      arg0: int
      arg1: bool
  
  
  status = Waitlist
  w: status = Waitlist(2, True)
  
  ```

