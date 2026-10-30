import os
import traceback
from pathlib import Path

import imandrax_api
from imandrax_api.demo.interface import *


def main():
    try:
        api_key = os.environ.get("IMANDRAX_API_KEY")
        if api_key is None:
            api_key = Path("~/.config/imandrax/api_key").expanduser().read_text()

        c = Client(url=imandrax_api.client.url_dev, api_key=api_key)

        status = str(c.status()).strip()
        if status != 'msg: "OK"':
            print(f"Error: status is not ok: {status}")
        else:
            # Dump some code into imandrax
            rsp = c.eval_src("""
let f (xs: int list) : int list = List.map (fun x -> x + 1) xs
[@@decomp top ~prune:false () |>> prune]
eval(1 + 2)
theorem thm1 (xs: int list) = f xs = List.map (fun x -> x + 1) xs
instance (fun (xs: int list) (y : int) -> f xs <> List.map (fun x -> x + y) xs)
  """)
            print(f"Reqeuest success: {rsp.success}")
            print(f"Request errors: {rsp.errors}")

            # Now inspect all the tasks that imandrax spawned
            for t in rsp.tasks:
                print(f"Task {t.id}:")
                print(f"  Kind: {t.kind}")
                match t:
                    case EvaluationTask():
                        print(f"  Term: {t.term}")

                    case ProofObligationTask():
                        po = t.proof_obligation
                        print(f"  Description: {t.proof_obligation.description}")
                        vars, goal_term = po.goal
                        vars = " ".join(str(v) for v in vars)
                        # Note: instances are also proof obligations (just with a negated goal)
                        name = "Instance" if po.is_instance else "Goal"
                        print(f"  {name}: (fun {vars} -> {goal_term})")
                        print(f"  Tactic: {t.proof_obligation.tactic}")
                        if t.db:
                            print(f"  # Declarations in DB: {len(t.db.decls)}")
                            # Let's get all the names of functions used in the
                            # goal by drilling down the goal term
                            functions: set[Uid] = set()
                            for subterm in goal_term:
                                match subterm:
                                    case Apply(function=Symbol() as s):
                                        functions.add(s.symbol.id)
                                    case _:
                                        pass
                            print(f"  Functions in goal: {functions}")

                            # Any lifted lambdas in there?
                            lambdas = {f for f in functions if f.short_name == "$lambda"}
                            for lid in lambdas:
                                print(f"  Lambda '{lid.full_name}':")
                                # Then there must also be a definition for it
                                f = t.db.find_function(lid)
                                if f:
                                    print(f"    Signature: {f.type}")
                                    print(f"    Definition: {f}")

                            # There should also be (a) function(s) with a short name of `f`
                            for id, f in t.db.find_function_re("f/.*").items():
                                print(f"  Function '{id}':")
                                print(f"    Signature: {f.type}")
                                print(f"    Definition: {f}")

                    case DecompositionTask():
                        print(f"  Request: {t.decomp}")

                    case _:
                        pass

                # Every task has a result
                task_result = t.result
                print(f"  Result:")
                match task_result:
                    case EvaluationTaskResult() as r:
                        print(f"    Value: {r.value}")
                    case ProofObligationTaskResult() as r:
                        print(f"    From: {r.from_}")
                        print(f"    Proved: {"yes" if r.proved else "no"}")
                        print(f"    Model: {r.model}")
                    case DecompositionTaskResult() as r:
                        print(f"    Decomposition: {r}")
                    case _:
                        print(f"  Unknown task result type")

    except imandrax_api.twirp.exceptions.TwirpServerException as ex:
        print(f"Twirp exception: {ex}")
        print(f"Meta: {ex.meta}")
    except Exception as ex:
        traceback.print_exception(ex)
        print(f"Exception: {ex}")


if __name__ == "__main__":
    main()
