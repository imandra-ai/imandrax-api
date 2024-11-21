from setuptools import setup

VERSION = "0.7"
setup(
    name="imandrax_api",
    version=VERSION,
    install_requires=["protobuf", "requests", "structlog"],
    package_dir={"imandrax_api": "."},
)
