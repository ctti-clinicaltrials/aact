Managing AWS services with Ansible
==================================

Ansible
-------
We use [ansible](https://www.ansible.com) to provision our AWS infrastructure.
Ansible allows us to write [playbooks](http://docs.ansible.com/ansible/playbooks.html)
that specify how the AWS infrastructure should be, and these can be launched with
ansible-playbook to ensure that the AWS infrastructure requirements are met.
Playbooks are generally idempotent, meaning that if something specified in the playbook
is already created and configured to spec, it will not repeat the command to recreate
or reconfigure it.

Our ansible playbook requires [Ansible 2.2.0](http://docs.ansible.com/ansible/intro_installation.html).
It also requires the following python modules:
- psycopg2

Setting Up AWS Keys
-------------------
To run the playbook, you must have rights to create infrastructure in the
[CTTI AWS Console](ctti.signin.aws.amazon.com). Once you login to the ctti
AWS console, you must Create an Access Key for you IAM User account. To do this,
- Navigate to the IAM services page
- Click 'Users' in the menu on the right
- Click your User.
- Click 'Security Credentials' in the menu on the bottom right
- Click 'Create Access Key'
- Download your key.

This is the only way you can see your aws_secret_access_key. If you forget it,
or lose it, you must login to ctti.signin.aws.amazon.com, navigate to your User
IAM definition, and destroy and recreate the Access Key.

Once you download this file. You must create a source script that you can use
to store these values in the bash shell environment, which is used by the ansible
playbook.
- create a directory in your home directory ~/.aws
- you should secure this directory so that only you can read it
- move the downloaded file to this directory
- create a new file in ~/.aws called ctti.credentials.src. It should look like this:
```
export AWS_ACCESS_KEY_ID='copy this from the downloaded file inside these quotes'
export AWS_SECRET_ACCESS_KEY='copy this from the downloaded file inside these quotes'
```

Once you have created this source script, you must run the following before you
can run the ansible playbook:
```
source ~/.aws/ctti.credentials.src
```

Install AWS CLI
---------------
Our ansible playbook relies on the [aws cli](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) being installed on your machine.
The aws cli can also be very helpful in troubleshooting or testing the deployment.
It also uses the environment variables set by ctti.credentials.src.

aws.yml
-------
This playbook, located in the ansible directory, specifies the creation of all of the
resources needed by the aact2 system, for both dev and prod environments. To run the playbook (assuming you have ansible and the required python modules installed):
```
cd ansible
ansible-playbook aws.yml
```

This may not change anything.  The most important part of this playbook is the
'instances' var that is created at the top.  It currently specifies the entire
environment for aact-dev and aact-prod.  If you should want to create, say, aact-uatest
, add that to the list (yaml). Then run the playbook.  All of the resources
will be created for aact-uatest, while those for aact-dev and aact-prod will be
skipped, since they are already created.

You can also modify some of the commands to do things differently, say modify the
policy of the IAM workers, etc.  Ansible is smart enough to only change what needs
to change, without rerunning everything.
