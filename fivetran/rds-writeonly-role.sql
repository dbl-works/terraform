-- creates a write-only role for fivetran to connect to RDS for specific tables
DO
$$
  DECLARE
    table_name     varchar;
    project        varchar   := '';
    environment    varchar   := '';
    allowed_tables varchar[] := array [
      'table1',
      'table2'
      ];
    password       varchar   := 'my-super-secret-password';
  BEGIN
    EXECUTE format('CREATE ROLE %s_%s_writeonly_fivetran;', project, environment);
    EXECUTE format('ALTER ROLE %s_%s_writeonly_fivetran WITH LOGIN ENCRYPTED PASSWORD ''%s'';', project, environment,
                   password);
    EXECUTE format('GRANT USAGE ON SCHEMA public TO %s_%s_writeonly_fivetran;', project, environment);
    FOREACH table_name IN ARRAY allowed_tables
      LOOP
        EXECUTE format('GRANT CREATE, UPDATE ON TABLE %s TO %s_%s_writeonly_fivetran', table_name, project,
                       environment);
      END LOOP;
    EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO %s_%s_writeonly_fivetran;',
                   project, environment);
  END
$$;
