output "pkslowPileNameList" {
  value = module.pkslow-file.*.file_name
  #  value = module.pkslow-file[*].file_name
}

output "larryFileName" {
  value = module.larry-file.file_name
}

output "larryFileResult" {
  value = module.echo-larry-result.stdout
}