Setup: Define helper function
  $ fence() { printf '```python\n'; cat; printf '```'; }
  $ run_test() { (
  >    cd $DUNE_SOURCEROOT/src/py-gen && \
  >    py-gen-parse-fun-decomp "test/data/fun_decomp/$1" - \
  >    | uv run py-gen - \
  >    | fence
  > ); }

basic
  $ run_test basic.yaml
  ```python
  def test_1():
      """test_1
  
      - invariant: x + 2
      - constraints:
          - x >= 1
      """
      result: int = f(x=1)
      expected: int = 3
      assert result == expected
  
  
  def test_2():
      """test_2
  
      - invariant: 1 + x
      - constraints:
          - x <= 0
      """
      result: int = f(x=0)
      expected: int = 1
      assert result == expected
  
  ```

complex_variant_record
  $ run_test complex_variant_record.yaml
  ```python
  from dataclasses import dataclass
  
  
  @dataclass
  class Inactive:
      pass
  
  
  status = Inactive
  
  
  @dataclass
  class user:
      id: int
      active: status
  
  
  @dataclass
  class Active:
      pass
  
  
  status = Active
  
  
  def test_1():
      """test_1
  
      - invariant: (-1)
      - constraints:
          - not (u.active = Active)
      """
      result: int = process_user(u=user(0, Inactive()))
      expected: int = -1
      assert result == expected
  
  
  def test_2():
      """test_2
  
      - invariant: 0
      - constraints:
          - u.active = Active
          - u.id <= 0
      """
      result: int = process_user(u=user(0, Active()))
      expected: int = 0
      assert result == expected
  
  
  def test_3():
      """test_3
  
      - invariant: u.id
      - constraints:
          - u.active = Active
          - u.id >= 1
      """
      result: int = process_user(u=user(1, Active()))
      expected: int = 1
      assert result == expected
  
  ```

composite_record
  $ run_test composite_record.yaml
  ```python
  from dataclasses import dataclass
  
  
  @dataclass
  class point:
      x: int
      y: int
  
  
  def test_1():
      """test_1
  
      - invariant: "positive"
      - constraints:
          - not (p.x + p.y = 0)
          - p.x + p.y >= 1
      """
      result: str = distance_category(p=point(0, 1))
      expected: str = 'positive'
      assert result == expected
  
  
  def test_2():
      """test_2
  
      - invariant: "origin"
      - constraints:
          - p.x + p.y = 0
      """
      result: str = distance_category(p=point(-38, 38))
      expected: str = 'origin'
      assert result == expected
  
  
  def test_3():
      """test_3
  
      - invariant: "negative"
      - constraints:
          - p.x + p.y <= (-1)
      """
      result: str = distance_category(p=point(0, -1))
      expected: str = 'negative'
      assert result == expected
  
  ```

composite_tuple
  $ run_test composite_tuple.yaml
  ```python
  def test_1():
      """test_1
  
      - invariant: _x_1_25.1 - _x_1_25.0
      - constraints:
          - not (_x_1_25.0 = _x_1_25.1)
          - _x_1_25.0 <= _x_1_25.1
      """
      result: int = tuple_compare(_x_1_25=(0, 1))
      expected: int = 1
      assert result == expected
  
  
  def test_2():
      """test_2
  
      - invariant: 0
      - constraints:
          - _x_1_25.0 = _x_1_25.1
          - _x_1_25.0 <= _x_1_25.1
      """
      result: int = tuple_compare(_x_1_25=(0, 0))
      expected: int = 0
      assert result == expected
  
  
  def test_3():
      """test_3
  
      - invariant: _x_1_25.0 - _x_1_25.1
      - constraints:
          - not (_x_1_25.0 <= _x_1_25.1)
      """
      result: int = tuple_compare(_x_1_25=(0, -1))
      expected: int = 1
      assert result == expected
  
  ```

list_operations
  $ run_test list_operations.yaml
  ```python
  def test_1():
      """test_1
  
      - invariant: 0
      - constraints:
          - not (xs <> [])
      """
      result: int = list_check(xs=[])
      expected: int = 0
      assert result == expected
  
  
  def test_2():
      """test_2
  
      - invariant: List.hd xs
      - constraints:
          - not ((List.tl xs) <> [])
          - xs <> []
      """
      result: int = list_check(xs=[0])
      expected: int = 0
      assert result == expected
  
  
  def test_3():
      """test_3
  
      - invariant: List.hd xs + List.hd (List.tl xs)
      - constraints:
          - (List.tl xs) <> []
          - xs <> []
      """
      result: int = list_check(xs=[1, 0])
      expected: int = 1
      assert result == expected
  
  ```

multiple_parameters
  $ run_test multiple_parameters.yaml
  ```python
  def test_1():
      """test_1
  
      - invariant: 0
      - constraints:
          - not (b = c)
          - not (a = b)
          - a <= b
      """
      result: int = calculate(b=0, c=1, a=-1)
      expected: int = 0
      assert result == expected
  
  
  def test_2():
      """test_2
  
      - invariant: b * a
      - constraints:
          - b = c
          - not (a = b)
          - a <= b
      """
      result: int = calculate(a=-1, c=0, b=0)
      expected: int = 0
      assert result == expected
  
  
  def test_3():
      """test_3
  
      - invariant: a * c
      - constraints:
          - a = b
          - a <= b
      """
      result: int = calculate(b=0, a=0, c=0)
      expected: int = 0
      assert result == expected
  
  
  def test_4():
      """test_4
  
      - invariant: 0
      - constraints:
          - not (b = c)
          - not (a = b)
          - b <= c
          - not (a <= b)
      """
      result: int = calculate(b=0, a=1, c=1)
      expected: int = 0
      assert result == expected
  
  
  def test_5():
      """test_5
  
      - invariant: b * a
      - constraints:
          - b = c
          - not (a = b)
          - b <= c
          - not (a <= b)
      """
      result: int = calculate(a=1, c=0, b=0)
      expected: int = 0
      assert result == expected
  
  
  def test_6():
      """test_6
  
      - invariant: a + b + c
      - constraints:
          - not (b <= c)
          - not (a <= b)
      """
      result: int = calculate(c=-1, a=1, b=0)
      expected: int = 0
      assert result == expected
  
  ```

nested_conditions
  $ run_test nested_conditions.yaml
  ```python
  def test_1():
      """test_1
  
      - invariant: ~- x + y
      - constraints:
          - y <= 0
          - x <= 0
      """
      result: int = nested_check(y=0, x=0)
      expected: int = 0
      assert result == expected
  
  
  def test_2():
      """test_2
  
      - invariant: y - x
      - constraints:
          - y >= 1
          - x <= 0
      """
      result: int = nested_check(y=1, x=0)
      expected: int = 1
      assert result == expected
  
  
  def test_3():
      """test_3
  
      - invariant: x - y
      - constraints:
          - y <= 0
          - x >= 1
      """
      result: int = nested_check(y=0, x=1)
      expected: int = 1
      assert result == expected
  
  
  def test_4():
      """test_4
  
      - invariant: x + y
      - constraints:
          - y >= 1
          - x >= 1
      """
      result: int = nested_check(y=1, x=1)
      expected: int = 2
      assert result == expected
  
  ```

option_type
  $ run_test option_type.yaml
  ```python
  from dataclasses import dataclass
  
  @dataclass
  class Some:
      arg0: int
  option = Some
  
  @dataclass
  class None:
      pass
  option = None
  
  def test_1():
      """test_1
  
  - invariant: ~- Option.get opt
  - constraints:
      - not Is_a(None, opt)
      - Option.get opt <= 0
  """
      result: int = option_value(opt=Some(0))
      expected: int = 0
      assert result == expected
  
  def test_2():
      """test_2
  
  - invariant: Option.get opt
  - constraints:
      - not Is_a(None, opt)
      - Option.get opt >= 1
  """
      result: int = option_value(opt=Some(1))
      expected: int = 1
      assert result == expected
  
  def test_3():
      """test_3
  
  - invariant: 0
  - constraints:
      - Is_a(None, opt)
  """
      result: int = option_value(opt=None())
      expected: int = 0
      assert result == expected
  ```

primitive_bool
  $ run_test primitive_bool.yaml
  ```python
  def test_1():
      """test_1
  
      - invariant: 0
      - constraints:
          - not b
          - not a
      """
      result: int = bool_logic(a=False, b=False)
      expected: int = 0
      assert result == expected
  
  
  def test_2():
      """test_2
  
      - invariant: 2
      - constraints:
          - b
          - not a
      """
      result: int = bool_logic(a=False, b=True)
      expected: int = 2
      assert result == expected
  
  
  def test_3():
      """test_3
  
      - invariant: 2
      - constraints:
          - not b
          - a
      """
      result: int = bool_logic(a=True, b=False)
      expected: int = 2
      assert result == expected
  
  
  def test_4():
      """test_4
  
      - invariant: 1
      - constraints:
          - b
          - a
      """
      result: int = bool_logic(a=True, b=True)
      expected: int = 1
      assert result == expected
  
  ```

primitive_int
  $ run_test primitive_int.yaml
  ```python
  def test_1():
      """test_1
  
      - invariant: 1
      - constraints:
          - not (x = 0)
          - x >= 1
      """
      result: int = classify_number(x=1)
      expected: int = 1
      assert result == expected
  
  
  def test_2():
      """test_2
  
      - invariant: 0
      - constraints:
          - x = 0
      """
      result: int = classify_number(x=0)
      expected: int = 0
      assert result == expected
  
  
  def test_3():
      """test_3
  
      - invariant: (-1)
      - constraints:
          - x <= (-1)
      """
      result: int = classify_number(x=-1)
      expected: int = -1
      assert result == expected
  
  ```

primitive_real
  $ run_test primitive_real.yaml
  ```python
  def test_1():
      """test_1
  
      - invariant: true
      - constraints:
          - true
      """
      result: bool = classify_temp(temp=0)
      expected: bool = True
      assert result == expected
  
  ```

variant_simple
  $ run_test variant_simple.yaml
  ```python
  from dataclasses import dataclass
  
  
  @dataclass
  class Red:
      pass
  
  
  color = Red
  
  
  @dataclass
  class Green:
      pass
  
  
  color = Green
  
  
  @dataclass
  class Blue:
      pass
  
  
  color = Blue
  
  
  def test_1():
      """test_1
  
      - invariant: 1
      - constraints:
          - not (c = Green)
          - not (c = Blue)
      """
      result: int = color_value(c=Red())
      expected: int = 1
      assert result == expected
  
  
  def test_2():
      """test_2
  
      - invariant: 2
      - constraints:
          - c = Green
          - not (c = Blue)
      """
      result: int = color_value(c=Green())
      expected: int = 2
      assert result == expected
  
  
  def test_3():
      """test_3
  
      - invariant: 3
      - constraints:
          - c = Blue
      """
      result: int = color_value(c=Blue())
      expected: int = 3
      assert result == expected
  
  ```

variant_with_data
  $ run_test variant_with_data.yaml
  ```python
  from dataclasses import dataclass
  
  
  @dataclass
  class Rectangle:
      arg0: int
      arg1: int
  
  
  shape = Rectangle
  
  
  @dataclass
  class Circle:
      arg0: int
  
  
  shape = Circle
  
  
  def test_1():
      """test_1
  
      - invariant: Destruct(Rectangle, 0, s) * Destruct(Rectangle, 1, s)
      - constraints:
          - not Is_a(Circle, s)
      """
      result: int = area(s=Rectangle(0, 1))
      expected: int = 0
      assert result == expected
  
  
  def test_2():
      """test_2
  
      - invariant: Destruct(Circle, 0, s) * Destruct(Circle, 0, s)
      - constraints:
          - Is_a(Circle, s)
      """
      result: int = area(s=Circle(0))
      expected: int = 0
      assert result == expected
  
  ```

with_basis
  $ run_test with_basis.yaml
  ```python
  def test_1():
      """test_1
  
      - invariant: helper (~- x)
      - constraints:
          - x <= 0
      """
      result: int = compute(x=0)
      expected: int = 0
      assert result == expected
  
  
  def test_2():
      """test_2
  
      - invariant: helper x
      - constraints:
          - x >= 1
      """
      result: int = compute(x=1)
      expected: int = 1
      assert result == expected
  
  ```

with_guards
  $ run_test with_guards.yaml
  ```python
  def test_1():
      """test_1
  
      - invariant: 0
      - constraints:
          - x <= 0
      """
      result: int = classify(x=0, y=0)
      expected: int = 0
      assert result == expected
  
  
  def test_2():
      """test_2
  
      - invariant: 0
      - constraints:
          - y <= 0
          - x >= 1
      """
      result: int = classify(y=0, x=1)
      expected: int = 0
      assert result == expected
  
  
  def test_3():
      """test_3
  
      - invariant: 3
      - constraints:
          - y <= x
          - x <= y
          - y >= 1
          - x >= 1
      """
      result: int = classify(y=1, x=1)
      expected: int = 3
      assert result == expected
  
  
  def test_4():
      """test_4
  
      - invariant: 2
      - constraints:
          - not (y <= x)
          - x <= y
          - y >= 1
          - x >= 1
      """
      result: int = classify(y=2, x=1)
      expected: int = 2
      assert result == expected
  
  
  def test_5():
      """test_5
  
      - invariant: 1
      - constraints:
          - not (x <= y)
          - y >= 1
          - x >= 1
      """
      result: int = classify(y=1, x=2)
      expected: int = 1
      assert result == expected
  
  ```

