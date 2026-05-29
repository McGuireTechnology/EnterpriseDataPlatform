package edp

default allow := false

public_classifications := {"public", "directory", "aggregate"}

approved_publication_channels := {"ckan"}

allow if {
	input.action == "publish_dataset"
	input.channel in approved_publication_channels
	input.dataset.classification in public_classifications
	not input.dataset.contains_student_level_records
	not input.dataset.contains_secrets
	input.dataset.approved == true
}

allow if {
	input.action == "export_data"
	input.requestor.role in {"data_steward", "platform_admin"}
	input.dataset.approved == true
	not input.destination.third_party || input.destination.data_sharing_agreement == true
}

deny contains reason if {
	input.action == "publish_dataset"
	input.channel == "ckan"
	input.dataset.contains_student_level_records
	reason := "student-level records cannot be published to CKAN"
}

deny contains reason if {
	input.action == "publish_dataset"
	input.channel == "ckan"
	not input.dataset.approved
	reason := "dataset must be approved before publication"
}

deny contains reason if {
	input.action == "export_data"
	input.destination.third_party
	not input.destination.data_sharing_agreement
	reason := "third-party exports require a data-sharing agreement"
}
