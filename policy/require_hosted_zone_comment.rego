package main

import rego.v1

is_invalid_comment(comment) if {
  not is_string(comment)
}

is_invalid_comment(comment) if {
  comment == ""
}

is_invalid_comment(comment) if {
  comment == "Managed by Terraform"
}

deny contains msg if {
	some resource in input.resource_changes
	resource.type == "aws_route53_zone"
	every action in resource.change.actions {
		action != "delete"
	}
	comment := object.get(resource.change.after, "comment", "")
  is_invalid_comment(comment)
	msg := sprintf(
		"aws_route53_zone %q must include a non-empty comment",
		[resource.address],
	)
}
