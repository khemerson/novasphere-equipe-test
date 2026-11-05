# Exemples de la S6, a activer un a un pendant le TP (fichier documentaire, blocs commentes).

# Etape 1 : importer un parametre SSM cree a la main, puis generer sa configuration
#   aws ssm put-parameter --name /novasphere/dev/message_accueil --type String --value "Bienvenue sur NovaSphere"
#   terraform plan -generate-config-out=generated.tf   (le plan echoue : value = null, a reecrire)
# Pourquoi pas un bucket S3 : dans le Learner Lab, le provider ne peut ni creer ni importer
# un aws_s3_bucket (s3:GetBucketObjectLockConfiguration refuse par une SCP AWS Academy).
# import {
#   to = aws_ssm_parameter.message_accueil
#   id = "/novasphere/dev/message_accueil"
# }
#
# Version nettoyee, dans accueil.tf :
# resource "aws_ssm_parameter" "message_accueil" {
#   name  = "/novasphere/${var.environment}/message_accueil"
#   type  = "String"
#   value = "Bienvenue sur NovaSphere"
# }

# Etape 2 : renommer une ressource sans destruction (en meme temps que son bloc resource)
# moved {
#   from = aws_security_group.alb
#   to   = aws_security_group.lb
# }

# Etape 4 : sortir une ressource du state sans la detruire (supprimer accueil.tf dans le meme changement)
# removed {
#   from = aws_ssm_parameter.message_accueil
#   lifecycle {
#     destroy = false
#   }
# }
