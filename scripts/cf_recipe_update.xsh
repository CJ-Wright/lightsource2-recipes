import os
from contextlib import contextmanager

import requests

@contextmanager
def indir(d):
    """Context manager for temporarily entering into a directory."""
    old_d = os.getcwd()
    ![cd @(d)]
    yield
    ![cd @(old_d)]
for d in ['../recipes-dev', '../recipes-tag']:
    with indir(d):
        a = g`*`
        t = 'https://raw.githubusercontent.com/conda-forge/{}-feedstock/' \
            'master/recipe/meta.yaml'
        for b in a:
            os.makedirs(b, exist_ok=True)
            with indir(b):
                url = t.format(b)
                request = requests.get(url)
                if request.status_code == 200:
                    # TODO: pull all contents of the recipe folder
                    # TODO: remove all contents of the recipe folder
                    if 'meta.yaml' in g`*`:
                        rm meta.yaml
                    wget @(url)

