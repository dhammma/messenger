module Database
  module Postgres
    module Migrations
      module TableInheritance
        def create_check_for_duplicates
          sql = <<-SQL
                CREATE OR REPLACE FUNCTION check_for_duplicates()
                  RETURNS trigger AS
                $func$
                  DECLARE
                      table_name text;
                      tmpint  INTEGER := 0;
                  BEGIN
                    table_name := TG_ARGV[0];
                    EXECUTE format('SELECT 1 FROM %s WHERE $1=id;', table_name) USING NEW.id;

                    GET DIAGNOSTICS tmpint = ROW_COUNT;
                    IF tmpint > 0 THEN
                      RAISE unique_violation USING MESSAGE = 'Duplicate ID: ' || NEW.id;
                      RETURN NULL;
                    END IF;
                    RETURN NEW;
                  END;
                $func$ LANGUAGE plpgsql;
          SQL

          execute(sql)
        end

        def delete_check_for_duplicates
          sql = <<-SQL
                DROP FUNCTION IF EXISTS check_for_duplicates();
          SQL

          begin
            execute(sql)
          rescue PG::DependentObjectsStillExist
            false
          end
        end

        def create_inherit_table(descendant, parent, &block)
          reversible do |dir|
            dir.up do
              create_check_for_duplicates

              sql = <<-SQL
                CREATE TABLE IF NOT EXISTS #{descendant.table_name} ( CHECK (type='#{descendant}') ) INHERITS (#{parent.table_name});
                CREATE TRIGGER check_uniquiness_#{descendant.table_name}
                  BEFORE INSERT ON #{descendant.table_name}
                  FOR EACH ROW EXECUTE PROCEDURE check_for_duplicates(#{parent.table_name});
              SQL

              execute(sql)

              add_index descendant.table_name, :id

              if block_given?
                # Delegate table field creation to a block
                change_table descendant.table_name do |t|
                  block.call t
                end
              end
            end

            dir.down do
              sql = <<-SQL
                DROP TRIGGER IF EXISTS check_uniquiness_#{descendant.table_name} ON #{descendant.table_name};
                DROP TABLE IF EXISTS #{descendant.table_name};
              SQL

              execute(sql)
            end
          end
        end
      end
    end
  end
end