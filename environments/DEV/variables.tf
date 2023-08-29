variable "tags" {
  description = "A map of additional tags to add to all resource"
  type        = map(string)
  default     = {}
}
variable "cluster_tags" {
  description = "A map of additional cluser tags to add to all resource"
  type        = map(string)
  default     = {}
}