# output "name" {
#   value = "${aws_key_pair.ssh-key.key_name}"
# }

output "name" {
  value = aws_key_pair.ssh-key.key_name
}
