module "network" {
  source = "./network"
}



module "compute_db" {
  source        = "./compute_db"
  aws_region    = "us-east-1"
  ami_id        = "ami-0b6c6ebed2801a5cb"
  instance_name = "mongo-server" 
}

module "compute_app" {
  source        = "./compute_app"
  aws_region    = "us-east-1"
  ami_id        = "ami-0b6c6ebed2801a5cb"
  instance_name = "mean-stack"
  mongo_ip      = module.compute_db.mongodb_private_ip
}

