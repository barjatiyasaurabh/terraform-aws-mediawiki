# terraform-aws-mediawiki
Repository for using terraform to deploy mediawiki on AWS instances

Usage instructions:
1. Install terraform for appropriate OS.  Below steps are tried in CentOS 8.
2. Configure AWS CLI appropriately if not done already
   ```shell
   aws configure
   ```
3. Git clone repository
   ```shell
   git clone https://github.com/barjatiyasaurabh/terraform-aws-mediawiki.git
   ```
4. Create terraform keypair for use with the script
   ```shell
   ssh-keygen -t rsa -f terraform
   ``` 
5. Create file mysql-root-password with example password:
   ```shell
   echo "better-secret-than-this" > mysql-root-password
   ```
6. Initialize terraform and apply
   ```shell
   terraform init
   terraform apply
   ```
7. Open http://<mediawiki-public-ip>/mediawiki where mediawiki-public-ip can be found using:
   ```shell  
     terraform show | grep -B1  public_ipv4_pool | grep 'public_ip[^v]'
   ``` 
8. During setup note:
   - DB host :: Captured in mariadb-private-ip.txt
   - DB username :: mediawiki
   - DB password :: <Created in step 5 above>
9. Download the localsettings.php file and copy it to mediawiki server using:
   ```shell
   scp -i terraform LocalSettings.php centos@<mediawiki-public-ip>:
   ```
10. SSH to mediawiki server and move Localsettings.php file to correct location:
    ```shell
    ssh -i terraform centos@<mediawiki-public-ip>

    #Then on remote server
    sudo cp LocalSettings.php /var/www/html/mediawiki/
    sudo chown root:root /var/www/html/mediawiki/LocalSettings.php
    ```shell
11. Click "Enter your wiki" and test wiki is working as expected.

