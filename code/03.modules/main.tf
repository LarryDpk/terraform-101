module "pkslow-file" {
  count   = 6
  source  = "./random-file"
  prefix  = "pkslow-${count.index}"
  content = "Hi guys, this is www.pkslow.com\nBest wishes!"
}

module "larry-file" {
  source  = "./random-file"
  prefix  = "larrydpk"
  content = "Hi guys, this is Larry Deng!"
}

# external module
module "echo-larry-result" {
  source  = "matti/resource/shell"
  version = "1.5.0"
  command = "cat ${module.larry-file.file_name}"
}