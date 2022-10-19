provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = var.name
}

resource "azurerm_app_service_plan" "appplan" {
  location            = azurerm_resource_group.rg.location
  name                = "suraj-appserviceplan"
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    size = "S1"
    tier = "Standard"
  }
}

resource "azurerm_app_service" "appservice" {
  app_service_plan_id = azurerm_app_service_plan.appplan.id
  location            = azurerm_app_service_plan.appplan.location
  name                = "suraj-appservice"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_monitor_action_group" "actiongroup" {
  name                = "RequestActionByTF"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "action"
  email_receiver {
    email_address = "surajsingh5233@gmail.com"
    name          = "sendtoadmin"
  }
}

resource "azurerm_monitor_metric_alert" "metrics" {
  name                = "MetricsByTF"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_app_service.appservice.id]
  criteria {
    aggregation      = "Total"
    metric_name      = "Requests"
    metric_namespace = "Microsoft.Web/sites"
    operator         = "GreaterThan"
    threshold        = 3
  }
  action {
    action_group_id = azurerm_monitor_action_group.actiongroup.id
  }
}