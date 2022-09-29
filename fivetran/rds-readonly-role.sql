-- creates a read-only role for fivetran to connect to RDS

CREATE ROLE {project}_{environment}_fivetran;
ALTER ROLE {project}_{environment}_fivetran WITH LOGIN ENCRYPTED PASSWORD 'generate-a-secure-password';

GRANT CONNECT ON DATABASE {project}_{environment} TO {project}_{environment}_fivetran;
GRANT USAGE ON SCHEMA public TO {project}_{environment}_fivetran;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO {project}_{environment}_fivetran;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO {project}_{environment}_fivetran;
