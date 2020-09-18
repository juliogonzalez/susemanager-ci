// Mandatory variables for terracumber
variable "URL_PREFIX" {
  type = "string"
  default = "https://ci.suse.de/view/Manager/view/Manager-4.0/job/manager-4.0-cucumber-PRV"
}

// Not really used as this is for --runall parameter, and we run cucumber step by step
variable "CUCUMBER_COMMAND" {
  type = "string"
  default = "export PRODUCT='SUSE-Manager' && run-testsuite"
}

variable "CUCUMBER_GITREPO" {
  type = "string"
  default = "https://github.com/SUSE/spacewalk.git"
}

variable "CUCUMBER_BRANCH" {
  type = "string"
  default = "Manager-4.0"
}

variable "CUCUMBER_RESULTS" {
  type = "string"
  default = "/root/spacewalk/testsuite"
}

variable "MAIL_SUBJECT" {
  type = "string"
  default = "Results 4.0-PRV $status: $tests scenarios ($failures failed, $errors errors, $skipped skipped, $passed passed)"
}

variable "MAIL_TEMPLATE" {
  type = "string"
  default = "../mail_templates/mail-template-jenkins.txt"
}

variable "MAIL_SUBJECT_ENV_FAIL" {
  type = "string"
  default = "Results 4.0-PRV: Environment setup failed"
}

variable "MAIL_TEMPLATE_ENV_FAIL" {
  type = "string"
  default = "../mail_templates/mail-template-jenkins-env-fail.txt"
}

variable "MAIL_FROM" {
  type = "string"
  default = "galaxy-ci@suse.de"
}

variable "MAIL_TO" {
  type = "string"
  default = "galaxy-ci@suse.de"
}

// sumaform specific variables
variable "SCC_USER" {
  type = "string"
}

variable "SCC_PASSWORD" {
  type = "string"
}

variable "GIT_USER" {
  type = "string"
  default = null // Not needed for master, as it is public
}

variable "GIT_PASSWORD" {
  type = "string"
  default = null // Not needed for master, as it is public
}

provider "libvirt" {
  uri = "qemu+tcp://metropolis.prv.suse.net/system"
}


module "cucumber_testsuite" {
  source = "./modules/cucumber_testsuite"

  product_version = "4.0-nightly"

  // Cucumber repository configuration for the controller
  git_username = var.GIT_USER
  git_password = var.GIT_PASSWORD
  git_repo     = var.CUCUMBER_GITREPO
  branch       = var.CUCUMBER_BRANCH

  cc_username = var.SCC_USER
  cc_password = var.SCC_PASSWORD

  # temporary: custom CentOS image due to broken Salt
  images = ["centos7o", "opensuse150o", "sles15sp1o", "sles15sp2o", "ubuntu1804o"]

  use_avahi    = false
  name_prefix  = "suma-40-"
  domain       = "prv.suse.net"
  from_email   = "root@suse.de"

  registry_uri = "minima-mirror.prv.suse.net"
  portus_uri = "minima-mirror.prv.suse.net:5000/cucutest"
  portus_username = "cucutest"
  portus_password = "cucusecret"
  git_profiles_repo = "https://github.com/uyuni-project/uyuni.git#:testsuite/features/profiles/internal_prv"

  mirror = "minima-mirror.prv.suse.net"
  use_mirror_images = true
  server_http_proxy = "galaxy-proxy.mgr.suse.de:3128"

  host_settings = {
    controller = {
      provider_settings = {
        mac = "52:54:00:00:00:06"
      }
    }
    server = {
      provider_settings = {
        mac = "52:54:00:00:00:01"
      }
    }
    proxy = {
      provider_settings = {
        mac = "52:54:00:00:00:07"
      }
    }
    suse-client = {
      image = "sles15sp1o"
      name = "cli-sles15"
      provider_settings = {
        mac = "52:54:00:00:00:02"
      }
    }
    suse-minion = {
      image = "sles15sp1o"
      name = "min-sles15"
      provider_settings = {
        mac = "52:54:00:00:00:03"
      }
    }
    build-host = {
      image = "sles15sp2o"
      provider_settings = {
        mac = "52:54:00:00:00:20"
      }
    }
    suse-sshminion = {
      image = "sles15sp1o"
      name = "minssh-sles15"
      provider_settings = {
        mac = "52:54:00:00:00:04"
      }
    }
    redhat-minion = {
      image = "centos7o"
      provider_settings = {
        mac = "52:54:00:00:00:05"
        // Openscap cannot run with less than 1.25 GB of RAM
        memory = 1280
      }
    }
    debian-minion = {
      provider_settings = {
        mac = "52:54:00:00:00:08"
      }
    }
    pxeboot-minion = {
      image = "sles15sp2o"
    }
    kvm-host = {
      image = "sles15sp1o"
      provider_settings = {
        mac = "52:54:00:00:00:09"
      }
    }
  }
  provider_settings = {
    pool = "ssd"
    network_name = null
    bridge = "br0"
    additional_network = "192.168.40.0/24"
  }
}

output "configuration" {
  value = module.cucumber_testsuite.configuration
}
