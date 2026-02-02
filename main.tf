

module "mongodb" {
  source        = "./modules/mongodb"
  aws_region    = "us-east-1"
  ami_id        = "ami-0b6c6ebed2801a5cb"
  instance_name = "mongo-server" 
}

module "servidores" {
  source        = "./modules/instances"
  aws_region    = "us-east-1"
  ami_id        = "ami-0b6c6ebed2801a5cb"
  instance_name = "mean-stack"
  mongo_ip      = module.mongodb.mongodb_private_ip
}