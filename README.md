# OCI MultiGPU 

OCI MultiGPU Inference & Training with deepseed

## Requirements
- Terraform
- ssh-keygen

## Configuration

1. Follow the instructions to add the authentication to your tenant https://medium.com/@carlgira/install-oci-cli-and-configure-a-default-profile-802cc61abd4f.
2. Clone this repository:
    ```bash
    git clone https://github.com/carlgira/oci-multigpu.git
    ```

3. Set three variables in your path. 
- The tenancy OCID, 
- The comparment OCID where the instance will be created.
- The number of instances to create
- The number of available GPUs in each instance
- The "Region Identifier" of region of your tenancy.
> **Note**: [More info on the list of available regions here.](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm)

```bash
export TF_VAR_tenancy_ocid='<tenancy-ocid>'
export TF_VAR_compartment_ocid='<comparment-ocid>'
export TF_VAR_instance_count=<number-of-instances>
export TF_VAR_gpus_per_instance=<number-of-gpus-per-instance>
export TF_VAR_region='<oci-region>'
```

1. If you're using a Linux OS, you may need to execute the following command to obtain execution permissions on the shell script:
    ```bash
    chmod a+x generate-keys.sh
    ```
2. Execute the script generate-keys.sh to generate private key to access the instance. 
    ```bash
    sh generate-keys.sh
    ```

## Build

To build the terraform solution, simply execute: 
    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

# Deepseed

    ```bash
    deepspeed --hostfile=/home/opc/multigpu/deepseed-hosts --master_addr multigpu-0.subnet.vcn.oraclevcn.com --master_port 3000 DeepSpeedExamples/inference/huggingface/text-generation/inference-test.py --name bigscience/bloom-3b --batch_size 2
    ```

## Acknowledgements

* **Author** - [Carlos Giraldo](https://www.linkedin.com/in/carlos-giraldo-a79b073b/), Oracle
* **Last Updated Date** - March 6th, 2023