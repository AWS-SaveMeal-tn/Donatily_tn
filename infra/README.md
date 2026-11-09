# Donatily — Terraform · L3 Réseau et socle de calcul

**Donatily** est une plateforme SaaS qui met en relation les commerces avec les associations et les clubs solidaires afin de faciliter la redistribution des produits invendus, des dons et des ressources essentielles en Tunisie.

## Architecture déployée

```
                        Users
                          │
                    Cognito / WAF
                          │
                   Internet Gateway
                          │
                   ALB (subnets publics, 2 AZ)
                    ┌─────┴─────┐
           ASG Frontend       ASG Frontend
          (public, AZ-a)     (public, AZ-b)
                    └─────┬─────┘
           ASG Backend    │    ASG Backend
          (privé, AZ-a)   │   (privé, AZ-b)
                NAT GW ◄──┘             │
              (AZ-a, lié aux            │
             instances backend)         │
                          └─────────────┤
                               S3 Gateway Endpoint ──→ S3
                          │
              RDS + Sauvegarde Automatique
                (subnet privé DB, AZ-c) ──→ S3 (Backup)
```

> **NAT Gateway** : une seule NAT Gateway classique déployée dans le subnet public d'AZ-a, partagée par les instances backend des deux AZ.

## Modules

| Module | Rôle |
|---|---|
| `modules/vpc` | VPC, subnets 2 AZ, IGW, NAT Gateway classique, tables de routage |
| `modules/security_groups` | SG ALB / frontend / backend / DB |
| `modules/compute_app` | Première instance EC2 privée (frontend) |

Les fichiers racine (`vpc.tf`, `security_groups.tf`, `compute_frontend.tf`) **appellent** ces modules.

Prévu pour les livrables suivants (L4+) : ALB, ASG, RDS, S3, CloudWatch.

## Déploiement

```powershell
cd terraform
copy terraform.tfvars.example terraform.tfvars
terraform init -upgrade
terraform plan
terraform apply
```

Connexion à l'instance privée (pas d'IP publique) :

```powershell
terraform output ssm_connect
# puis coller la commande aws ssm start-session ...
```

Preuve du NAT :

```text
cat /usr/share/nginx/html/nat-check.txt
```

(`NAT_OK` + une IP publique = la sortie Internet fonctionne.)

## Destruction

```powershell
..\scripts\destroy.ps1
```
