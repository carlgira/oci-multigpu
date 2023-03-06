#!/bin/bash

main_function() {
USER='opc'
dnf install  git git-lfs python39 python39-pip unzip zip rustc cargo jq -y

VENV=/home/$USER/.venv
su -c "python3.9 -m venv $VENV; source $VENV/bin/activate; pip install --upgrade pip; pip install flask flask_api gunicorn pydantic accelerate huggingface_hub deepspeed deepspeed-mii" $USER

# Install pdsh
wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/pdsh/pdsh-2.29.tar.bz2
tar xvfj pdsh-2.29.tar.bz2 
cd pdsh-2.29/
./configure --without-rsh --with-ssh
make
make install
ln -s /usr/local/bin/pdsh /bin/pdsh

su -c "git clone https://github.com/microsoft/DeepSpeedExamples.git /home/$USER/DeepSpeedExamples" $USER

INSTANCE_COUNT=`curl -L http://169.254.169.254/opc/v1/instance/ | jq -r '.metadata."instance_count"'`
GPU_COUNT=`curl -L http://169.254.169.254/opc/v1/instance/ | jq -r '.metadata."gpus_per_instance"'`
PRIVATE_KEY=`curl -L http://169.254.169.254/opc/v1/instance/ | jq -r '.metadata."private_key"'`

su -c "mkdir -p /home/$USER/.ssh" $USER
su -c "echo \"$PRIVATE_KEY\" > /home/$USER/.ssh/id_rsa" $USER
su -c "chmod 600 /home/$USER/.ssh/id_rsa" $USER

for i in $(seq 0 $(expr $INSTANCE_COUNT - 1)); do
    su -c "ssh-keyscan -H multigpu-$i.subnet.vcn.oraclevcn.com >> /home/$USER/.ssh/known_hosts" $USER
    su -c "echo \"multigpu-$i.subnet.vcn.oraclevcn.com slots=$GPU_COUNT\" >> /home/$USER/.deepseed-hosts" $USER
done

}

main_function 2>&1 >> /var/log/startup.log
