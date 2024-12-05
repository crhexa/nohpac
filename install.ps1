$null = New-Item -Path ".\data",".\bin" -Type Directory -Force
conda create -n nohpac python=3.11
conda activate nohpac
conda install jupyter -q -y
pip install -r python/pip-pkgs.txt --no-input