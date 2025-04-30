from setuptools import setup

VERSION = "0.14"
setup(
    name="imandrax_api",
    version=VERSION,
    python_requires=">=3.12",
    install_requires=["protobuf>=5.0, <6.0", "requests", "structlog"],
    package_dir={"imandrax_api": "."},
)
