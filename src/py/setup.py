from setuptools import find_packages, setup

VERSION = "0.21.0.1"
setup(
    name="imandrax_api",
    version=VERSION,
    packages=find_packages(include=["imandrax_api", "imandrax_api.*"]),
    python_requires=">=3.12",
    install_requires=["protobuf>=5.29.4, <6.0", "requests", "structlog"],
    extras_require={
        "async": ["aiohttp"],
    },
)
