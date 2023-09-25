+resource "cloudflare_ruleset" "clickjacking" {
+  zone_id     = data.cloudflare_zone.default.id
+  name        = "Clickjacking"
+  description = "Prevent clickjacking"
+  kind        = "zone"
+  phase       = "http_response_headers_transform"
+
+  rules {
+    action = "rewrite"
+    action_parameters {
+      headers {
+        name      = "X-Frame-Options"
+        operation = "set"
+        value     = "SAMEORIGIN"
+      }
+    }
+    expression  = "true"
+    description = "Clickjacking"
+    enabled     = true
+  }
+}
