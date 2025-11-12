# Terraform Module: HTTP Proxy

Launches a [Tinyproxy](https://github.com/tinyproxy/tinyproxy)-based HTTP proxy instance to allow an application server to assume a static IP address for outgoing traffic, e.g. when using a third-party API that requires a static IP address.

Since this is based on an EC2 machine, you have to take care of keeping the machine's OS up to date (security updates). It also doesn't come with an automatic reboot on failure.
For a much more robust (and expensive) solution, consider using a NAT Gateway instead.

## Usage

Before launching this resource, create a key-pair; read the [docs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html).

### Using Mac OS
- You can generate a key-pair using the following command:
`ssh-keygen -t ed25519 -C <label>`

```terraform
module "http-proxy" {
  source = "github.com/dbl-works/terraform//aws/http-proxy?ref=main"

  project          = "dbl-works"
  environment      = "production"
  public_subnet_id = "subnet-1234567890"
  vpc_id           = "vpc-1234567890"
  cidr_block       = "123.123.123.123/32" # of the VPC in which your application server is running
  public_key       = "ssh-rsa xxx" # SSH key used for the initial set up

  # optional
  eip              = "12.34.5.678" # if omitted, a new EIP is allocated
  instance_type    = "t3.micro"
  maintenance_mode = false                   # switch this to "true" for the initial configuration, but keep it "false" for production
  ami_id           = "ami-0502e817a62226e03" # ubuntu 20.04 which has a free quota

  # protocol & cidr_block are optional and default to TCP and all IPs
  # protocol: one of "tcp", "udp", "icmp", or "-1" for all protocols
  egress_rules = [
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
}
```

NOTE: if you want to generally allow any egress traffic for the proxy, you can set the following rule:

```terraform
egress_rules = [{
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
}]
```

## Configuration of the Proxy

On a high level:

* establish an SSH connection to the proxy
* install tinyproxy
* overwrite the existing config file
* restart the proxy
* log out, then disable SSH access to the proxy server via terraform

Details:

Prepare your local ENV

⚠️ ensure that the password does not contain special chars, as this breaks tinyproxy.

```shell
export PATH_TO_SSH_KEY="~/.ssh/http_proxy_ed25519"
export SSH_USER="ubuntu"
export SERVER_HOST="YOUR_EIP"
export BASIC_AUTH_PASSWORD="CHOOSE_A_SECURE_PASSWORD"
```

make a local copy of `http-proxy/tinyproxy.conf` and overwrite the following values:

* `VPC_CIDR`: the CIDR block of the VPC in which your application server is running
* `USER_NAME`: choose a user name for basic auth, e.g. the app-name
* `PASSWORD`: choose a secure password for basic auth
* `YOUR_PROJECT_NAME`: name of your project, e.g. "dbl-works"

Run:

```shell
# on your local machine
ssh -i ${PATH_TO_SSH_KEY} ${SSH_USER}@${SERVER_HOST}

# you should now be logged into the proxy server
sudo apt-get update && sudo apt-get install -y tinyproxy && sudo /etc/init.d/tinyproxy start

sudo apt-get --only-upgrade install tinyproxy

# purge current config file
sudo cat /dev/null > /etc/tinyproxy/tinyproxy.conf # manually delete in nano if you get permission denied
sudo nano /etc/tinyproxy/tinyproxy.conf
#
# copy paste content from your local copy of `http-proxy/tinyproxy.conf` file, then delete your local copy
#
sudo /etc/init.d/tinyproxy restart

# verify that the proxy is running
sudo /etc/init.d/tinyproxy status
```

## Usage in an app

Set an ENV var on your machine:

```shell
http_proxy=http://usr:password@EIP:8888
```

If you are using Ruby and have a Rack-based app (e.g. Rails), setting the ENV var `http_proxy` is sufficient.

If you want to limit outbound traffic through the fixed IP to certain requests, you can also use e.g. [net/ssh/proxy/http](https://net-ssh.github.io/ssh/v2/api/classes/Net/SSH/Proxy/HTTP.html).

Example usage to assume static IP to access a FTP server:

```ruby

  sig { returns(Net::SFTP::Session) }
  def sftp_session
    @sftp_session ||= begin
      if ENV['HTTP_PROXY_DBL'].present?
        uri = URI.parse(ENV.fetch('HTTP_PROXY_DBL'))
        proxy = Net::SSH::Proxy::HTTP.new(
          uri.host,
          uri.port,
          user: uri.user,
          password: uri.password,
        )
      end
      params = { password: @password, proxy: proxy }.compact

      Net::SFTP.start(@host, @username, **params)
    end
  end
```
