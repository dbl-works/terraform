# @TODO
# 1. Microsoft Defender for APIs should be enabled. https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-apis-deploy

# NOTE: To turn on the Defender CSPM Plan, user would need to have the subscription owner permission to access the full plan's capabilities
# Cloud security posture management (CSPM) is the process of monitoring cloud-based systems and infrastructures for risks and misconfigurations
resource "azurerm_security_center_subscription_pricing" "main" {
  tier          = "Standard"
  resource_type = "CloudPosture"

  extension {
    name = "ContainerRegistriesVulnerabilityAssessments"
  }

  # extension {
  #   name = "AgentlessVmScanning"
  #   additional_extension_properties = {
  #     ExclusionTags = "[]"
  #   }
  # }

  extension {
    name = "SensitiveDataDiscovery"
  }
}

# NOTE: Need owner access to edit this
# This will resolve the alert -- Subscriptions should have a contact email address for security issues
resource "azurerm_security_center_contact" "main" {
  name  = "Developer"
  email = var.devop_email

  alert_notifications = true
  alerts_to_admins    = var.alerts_to_admins
}

# NOT SURE
# - SQL server-targeted autoprovisioning should be enabled for SQL servers on machines plan:
# https://portal.azure.com/#view/Microsoft_Azure_Policy/ResourceComplianceDetail.ReactView/assignmentId/%2Fproviders%2Fmicrosoft.management%2Fmanagementgroups%2F72e15514-5be9-46a8-8b0b-af9b1b77b3b8%2Fproviders%2Fmicrosoft.authorization%2Fpolicyassignments%2F68a7acb17eee49c4b2a34762/policyDefinitionId/%2Fproviders%2Fmicrosoft.authorization%2Fpolicydefinitions%2Fc6283572-73bb-4deb-bf2c-7a2b8f7462cb/policyDefinitionReferenceId/sqlservertargetedautoprovisioningshouldbeenabledforsqlserversonmachinesplan/initiativeId/%2Fproviders%2FMicrosoft.Authorization%2FpolicySetDefinitions%2F1f3afdf9-d0c9-4c3d-847f-89da613e70a8/isPolicy~/true/scopes~/%5B%22%2Fsubscriptions%2Ffd2fde95-3aee-489f-8c8b-9687d023bc03%22%5D/resourceId/%2Fsubscriptions%2Ffd2fde95-3aee-489f-8c8b-9687d023bc03%2Fproviders%2Fmicrosoft.security%2Fpricings%2Fsqlservervirtualmachines/resourceName/sqlservervirtualmachines/resourceType/microsoft.security%2Fpricings/lastEvaluated/09%2F04%2F2024%2C%2018%3A46%3A56%20GMT%2B8
