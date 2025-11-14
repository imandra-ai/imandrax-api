from setuptools import setup

VERSION = "0.17.3.1"
setup(
    name="imandrax_api",
    version=VERSION,
    python_requires=">=3.12",
    install_requires=["protobuf>=5.29.4, <6.0", "requests", "structlog"],
    extras_require={
        "async": ["aiohttp"],
    },
    package_dir={"imandrax_api": "."},
)
