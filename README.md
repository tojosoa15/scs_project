Puis exécuter la commande pour créer la base

```bash
php  bin/console doctrine:database:create
```

Exécuter les migrations

```bash
php  bin/console doctrine:migrations:migrate
```

Exécuter la fixture

```bash
php bin/console d:f:l --append
`

Lancer le build en temps réel de yarn

```bash
yarn encore dev --watch
```

Lancer le serveur local s'il n'y a pas de virtual host

```bash
php  -S localhost:8000 -t public

ou

symfony serve 


3.	Génération des entités (étape cruciale)
# Génère le mapping depuis la base
php bin/console doctrine:mapping:import "App\Entity" annotation --path=src/Entity --force

# Génère les classes d'entités
php bin/console doctrine:mapping:convert annotation ./src/Entity

# Crée les getters/setters
php bin/console make:entity --regenerate App\\Entity


4.	Configuration spécifique SQL Server (config/packages/doctrine.yaml)
doctrine:
    dbal:
        driver: 'sqlsrv'
        mapping_types:
            datetime: datetime
            varbinary: string
        options:
            # Important pour les procédures stockées
            MultipleActiveResultSets: false
            # Si vous utilisez des schémas SQL Server
            # schema_filter: ~^(?!sys)~ 

    orm:
        auto_generate_proxy_classes: true
        naming_strategy: doctrine.orm.naming_strategy.underscore
        auto_mapping: true
        mappings:
            App:
                is_bundle: false
                type: annotation
                dir: '%kernel.project_dir%/src/Entity'
                prefix: 'App\Entity'
