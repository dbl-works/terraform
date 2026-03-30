## IAM for Humans

Policy that allows humans to login to AWS and manage their account (e.g. add MFA, change the password, etc).


```terraform
module "human_policies" {
  source = "github.com/dbl-works/terraform//aws/iam/iam-for-humans?ref=main"
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
