Util::Updater.new.run
pub_con=ActiveRecord::Base.establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"]).connection
pub_con.execute("
    DO
    $do$
      BEGIN
         IF NOT EXISTS ( SELECT FROM pg_catalog.pg_roles WHERE  rolname = 'read_only') THEN
            CREATE ROLE read_only;
         END IF;
      END
    $do$;")

pub_con.execute("alter role read_only in database aact set search_path = ctgov;")
pub_con.execute("grant connect on database aact to read_only;")
pub_con.execute("grant usage on schema ctgov TO read_only;")
pub_con.execute("grant select on all tables in schema ctgov to read_only;")
pub_con.execute("alter role read_only login;")

pub_con.execute("grant connect on database aact_alt to read_only;")
pub_con.execute("grant usage on schema ctgov TO read_only;")
pub_con.execute("grant select on all tables in schema ctgov to read_only;")
pub_con.execute("alter role read_only login;")
pub_con.reset!

