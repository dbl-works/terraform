### Important

Before executing any Terraform commands, it's essential that you obtain your user object ID. This ID is required to ensure proper access and permissions within Terraform. Please follow these steps:

Open your command line interface.

1. Obtain your object ID
```shell
az ad signed-in-user show --query id --output tsv
```

3. Fill in your object ID value in `key_vault_config.user_ids` fields
