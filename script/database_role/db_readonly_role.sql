CREATE ROLE {project}_{environment}_readonly;
GRANT CONNECT ON DATABASE {db_name} TO {project}_{environment}_readonly;
GRANT USAGE ON SCHEMA public TO {project}_{environment}_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO {project}_{environment}_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO {project}_{environment}_readonly;
GRANT rds_iam TO {project}_{environment}_readonly;
ALTER ROLE {project}_{environment}_readonly WITH LOGIN;
