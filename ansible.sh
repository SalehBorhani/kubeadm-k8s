curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py --user

python3 -m pip install --user ansible

echo "export PATH=/root/.local/bin:$PATH" >> ~/.bashrc
source ~/.bashrc