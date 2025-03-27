from setuptools import setup

VERSION = "0.12"
setup(
    name="imandrax_api",
    version=VERSION,
    python_requires=">=3.12",
    install_requires=["protobuf", "requests", "structlog"],
    package_dir={"imandrax_api": "."},
)
