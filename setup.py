from setuptools import setup
from Cython.Build import cythonize

setup(ext_modules=cythonize("linked_list.pyx", language_level="3"))
