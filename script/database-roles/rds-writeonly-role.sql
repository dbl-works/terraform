-- creates a role to allow syncing data from fivetran to a database
DO
$$
  DECLARE
    table_name     varchar;
    project        varchar   := '';
    environment    varchar   := '';
    app_name       varchar   := 'fivetran';
    database_name  varchar   := 'my-database';
    allowed_tables varchar[] := array [
      'table1',
      'table2'
      ];
    password       varchar   := 'my-super-secret-password';
  BEGIN
    -- Check to see if the role exists, if not create it
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = format('%s_%s_sync_%s', project, environment, app_name))
    THEN
      EXECUTE format('CREATE ROLE %s_%s_sync_%s;', project, environment, app_name);
    END IF;
    -- Give the role a password
    EXECUTE format('ALTER ROLE %s_%s_sync_%s WITH LOGIN ENCRYPTED PASSWORD ''%s'';', project, environment, app_name,
                   password);
    -- Grant the role access to the database
    EXECUTE format('GRANT USAGE ON SCHEMA public TO %s_%s_sync_%s;', project, environment, app_name);
    -- Revoke all privileges on all tables in the public schema
    EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM %s_%s_sync_%s;', project,
                   environment, app_name);
    FOREACH table_name IN ARRAY allowed_tables
      LOOP
        -- Grant the role access to the table
        EXECUTE format('GRANT INSERT, SELECT, UPDATE, DELETE, ALTER ON TABLE %s TO %s_%s_sync_%s',
                       table_name, project, environment, app_name);
      END LOOP;
    -- Let the role create temporary tables
    EXECUTE format('GRANT TEMPORARY ON DATABASE %s TO %s_%s_sync_%s;', database_name, project, environment, app_name);
    -- Let the role create tables
    EXECUTE format('GRANT CREATE ON DATABASE %s TO %s_%s_sync_%s;', database_name, project, environment, app_name);
    -- Let the role create schemas
    EXECUTE format('GRANT CREATE ON SCHEMA public TO %s_%s_sync_%s;', project, environment, app_name);
  END
$$;
