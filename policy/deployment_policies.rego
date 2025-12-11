package custom.kubernetes

# Deny containers running with root privileges
deny[msg] {
  input.kind == "Deployment"
  not input.spec.template.spec.securityContext.runAsNonRoot
  msg := "Containers must not run as root (securityContext.runAsNonRoot must be true)"
}

# Ensure liveness probes are present
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.livenessProbe
  msg := sprintf("Container '%s' has no livenessProbe", [container.name])
}
