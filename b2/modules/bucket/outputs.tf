output "name" {
  description = "The name of the bucket"
  value       = b2_bucket.this.bucket_name
}

output "id" {
  description = "The ID of the bucket"
  value       = b2_bucket.this.bucket_id
}
