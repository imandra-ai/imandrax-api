import os

from hypothesis import settings

# `dev` keeps local runs quick; CI selects `ci` via HYPOTHESIS_PROFILE.
settings.register_profile("dev", max_examples=100)
settings.register_profile("ci", max_examples=1000)
# a long local soak, e.g. after changing the decoder
settings.register_profile("soak", max_examples=50_000, deadline=None)
settings.load_profile(os.environ.get("HYPOTHESIS_PROFILE", "dev"))
