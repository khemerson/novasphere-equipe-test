variable "db_password" {
  description = "Mot de passe applicatif, fourni par TF_VAR_db_password"
  type        = string
  ephemeral   = true
}

resource "aws_ssm_parameter" "db_password" {
  name             = "/novasphere/${var.environment}/db_password"
  type             = "SecureString"
  value_wo         = var.db_password
  value_wo_version = 1
}

# Role d'instance : profil precree LabInstanceProfile (Learner Lab, IAM verrouille).
# Version au moindre privilege pour un compte classique : iam_compte_classique.tf.exemple
