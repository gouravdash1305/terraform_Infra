# Used for deleting and unmounting the /perforce volume, we just shut down the instance so it can be terminated after creating a snapshot
# Also creates a snapshot on deletion
resource "null_resource" "perforce_ondestroy" {

  provisioner "remote-exec" {
    when = destroy

    inline = [
      "sudo shutdown"
    ]
  }
}