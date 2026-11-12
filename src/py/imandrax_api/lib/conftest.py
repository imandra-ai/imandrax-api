import os

from hypothesis import settings

# `dev` (the default) keeps runs quick; select others via HYPOTHESIS_PROFILE
settings.register_profile("dev", max_examples=100)
# the deadline catches inputs that blow up decoding time; loosened for slow shared
# runners. Print a blob to replay failures locally
settings.register_profile("ci", max_examples=1000, deadline=1000, print_blob=True)
# a long local soak, e.g. after changing the decoder
settings.register_profile("soak", max_examples=50_000, deadline=1000)
settings.load_profile(os.environ.get("HYPOTHESIS_PROFILE", "dev"))
