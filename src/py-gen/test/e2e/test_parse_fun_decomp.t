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
      result: int = f(x=3)
      expected: int = 3
      assert result == expected
  
  
  def test_2():
      """test_2
  
      - invariant: 1 + x
      - constraints:
          - x <= 0
      """
      result: int = f(x=1)
      expected: int = 1
      assert result == expected
  
  ```
