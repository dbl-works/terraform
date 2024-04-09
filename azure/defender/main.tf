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
