from setuptools import setup

VERSION="0.1"
setup(name="imandrax_api", version=VERSION, install_requires=["protobuf","twirp"], package_dir={"imandrax_api": "."})
