output "accept_status-requester" {
  value = aws_vpc_peering_connection.peer.accept_status
}

output "accept_status-accepter" {
  value = aws_vpc_peering_connection_accepter.peer.accept_status
}
