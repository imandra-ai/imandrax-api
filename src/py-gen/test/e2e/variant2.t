Setup: Define helper function
  $ fence() { printf '```python\n'; cat; printf '```'; }
  $ run_test() { (
  >    cd $DUNE_SOURCEROOT/src/py-gen && \
  >    py-gen-parse-model "test/data/$1" - \
  >    | uv run py-gen - \
  >    | fence
  > ); }

Variant 1
  $ run_test model/primitive/variant1.yaml
  ```python
  from dataclasses import dataclass
  
  
  @dataclass
  class Active:
      pass
  
  
  status = Active
  w: status = Active()
  
  ```

Variant 2
  $ run_test model/primitive/variant2.yaml
  ```python
  from dataclasses import dataclass
  
  
  @dataclass
  class Waitlist:
      arg0: int
  
  
  status = Waitlist
  w: status = Waitlist(1)
  
  ```



Variant 3
  $ run_test model/primitive/variant3.yaml
  ```python
  from dataclasses import dataclass
  
  
  @dataclass
  class Waitlist:
      arg0: int
      arg1: bool
  
  
  status = Waitlist
  w: status = Waitlist(2, True)
  
  ```
