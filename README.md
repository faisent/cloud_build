# cloud_build
small POC stack deploy in AWS/Azure using Terraform, not really for public consumption

Usage (for Azure)

generate an ssh-key or use an existing one; pubkey is required for access to Azure nodes
check (perhaps double check) your outbound public IP, required for access to Azure nodes; I don't like public IPs with ssh open to the world
terraform apply in the base dir - should be documented well enough, sorry about the order (you'll see) 
switch to the ansible dir; edit your inventory file to reflect what you just built

IMPORTANT RUN dbserver setup before application server setup or things will fail when bugzilla tries to connect to the db.

ansible-playbook -i inventory -u vmadmin --key-file <keyfile> dbserver.yml
ansible-playbook -i inventory -u vmadmin --key-file <keyfile> webserver.yml
