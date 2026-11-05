# Règles d'équipe novasphere-infra

- Une branche par changement, nommée `feat/…` ou `fix/…`.
- Pull request relue par un autre membre avant merge sur `main`.
- Un tag par séance : `v5.<séance>.0`.
- Jamais commité : `*.tfstate*`, `*.tfvars`, `*.pem`, `.env`, `ansible/inventory*.ini`.
- `terraform plan` lu intégralement avant tout `apply`.
- `force-unlock` seulement après avoir vérifié que personne n'a d'opération en cours.
- Avant de quitter : `terraform destroy`, ou `scripts/stop-evening.sh prod` si l'infra sert demain.
- Lecture S1 : la documentation du backend S3 indique que `dynamodb_table` est déprécié au profit de `use_lockfile`.
