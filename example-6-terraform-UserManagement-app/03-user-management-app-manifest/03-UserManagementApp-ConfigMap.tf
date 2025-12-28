resource "kubernetes_config_map_v1" "config_map" {
    metadata {
        name = "usermanagement-db-creation-script-config-map"
    }

    data = {
        "webapp.sql" = "${file("${path.module}/webappdb.sql")}"
    }
}