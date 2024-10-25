$null = New-Item -Path ".\data\models",".\bin" -Type Directory -Force
conda create -n nohpac python=3.12
conda activate nohpac
pip install -r python/pip-pkgs.txt --no-input