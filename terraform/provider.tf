// Change the alias in provider.tf
provider "aws" {
  region = var.aws_region_eu_west_1
  alias  = "new-alias-1"
}

provider "aws" {
  region = var.aws_region_eu_west_2
  alias  = "new-alias-2"
}

provider "kubernetes" {
  alias = "new-alias"
  // Configuration details here
}