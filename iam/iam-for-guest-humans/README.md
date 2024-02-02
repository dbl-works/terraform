## IAM for Guest Humans

Policy that allows guest humans to login to AWS and manage their account (e.g. add MFA, change the password, etc).


```terraform
module "human_policies" {
  source = "github.com/dbl-works/terraform//iam/iam-for-humans?ref=v2022.05.27"
}
```

```terraform
locals {
  users = {
    gh-user = {
      iam                                  = "gh-jane-doe"
      github                               = "jane-doe"
      name                                 = "jane Doe"
      production-developer-access-projects = "some-project-name"
      production-admin-access-projects     = "some-project-name"

      groups = [
        "humans"
      ]
    }
  }
}
```


You can test policies for IAM users: https://policysim.aws.amazon.com/home/index.jsp
