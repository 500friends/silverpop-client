module Silverpop
  class Engage < Request

    LIST_TYPE_DATABASE = 0
    LIST_TYPE_SEED_LIST = 6
    LIST_TYPE_SUPPRESSION_LIST = 13

    LIST_VISIBILITY_PRIVATE = 0
    LIST_VISIBILITY_SHARED = 1

    FILE_TYPE_CSV = 0
    FILE_TYPE_TSV = 1
    FILE_TYPE_PSV = 2

    COLUMN_TYPE_TEXT = 0
    COLUMN_TYPE_BOOLEAN = 1
    COLUMN_TYPE_NUMERIC = 2
    COLUMN_TYPE_DATE = 3
    COLUMN_TYPE_TIME = 4
    COLUMN_TYPE_COUNTRY = 5
    COLUMN_TYPE_SELECT_ONE = 6
    COLUMN_TYPE_SEGMENTING = 8
    COLUMN_TYPE_SYSTEM = 9
    COLUMN_TYPE_SMS = 15
    COLUMN_TYPE_PHONE = 16
    COLUMN_TYPE_TIMESTAMP = 17
    COLUMN_TYPE_MULTISELECT = 20

    def schedule_mailing(template_id, list_id, mailing_name, options = {})
      defaults = { visibility: 0 }
      xml_envelope { |x|
        x.ScheduleMailing {
          x.TEMPLATE_ID template_id
          x.LIST_ID list_id
          x.MAILING_NAME mailing_name
          build_options(x, options, defaults)
        }
      }
    end

    def create_contact_list(database_id, contact_list_name, visibility, options = {})
      xml_envelope { |x|
        x.CreateContactList {
          x.DATABASE_ID database_id
          x.CONTACT_LIST_NAME contact_list_name
          x.VISIBILITY visibility
          build_options(x, options)
        }
      }
    end

    def import_list(map_file, source_file)
      xml_envelope { |x|
        x.ImportList {
          x.MAP_FILE map_file
          x.SOURCE_FILE source_file
        }
      }
    end

    def list_import(action, list_id_or_name, list_visibility = 0, file_type = 0, hasheaders = true, options = {}, columns = [], mapping = [], contact_lists = [])
      xml = Builder::XmlMarkup.new
      xml.LIST_IMPORT { |x|
        x.LIST_INFO {
          x.ACTION action
          if ['CREATE'].include?(action)
            x.LIST_NAME list_id_or_name
            x.LIST_VISIBILITY list_visibility
          else
            x.LIST_ID list_id_or_name
          end
          x.FILE_TYPE file_type
          x.HASHEADERS hasheaders
        }
        build_options(x, options)
        x.COLUMNS { build_columns(x, columns) } unless columns.empty?
        x.MAPPING { build_columns(x, mapping) }
        build_options(x, contact_lists)
      }
    end

    def add_recipient(fields, list_id, created_from = 1, contact_list_id = [], options = {})
      xml_envelope { |x|
        x.AddRecipient {
          x.LIST_ID list_id
          x.CREATED_FROM  created_from
          x.CONTACT_LISTS { contact_list_id.each { |id| x.CONTACT_LIST_ID  id } }
          build_options(x, options)
          build_columns(x, fields)
        }
      }
    end

    def purge_data(target_id, source_id)
      xml_envelope { |x|
        x.PurgeData {
          x.TARGET_ID target_id
          x.SOURCE_ID source_id
        }
      }
    end

    def create_table(table_name, columns)
      xml_envelope { |x|
        x.CreateTable {
          x.TABLE_NAME table_name
          x.COLUMNS { build_columns(x, columns) }
        }
      }
    end

    def join_table(table_name_or_id = {}, list_id, map_fields)
      xml_envelope { |x|
        x.JoinTable {
          x.TABLE_NAME table_name_or_id[:table_name] if table_name_or_id[:table_name]
          x.TABLE_ID table_name_or_id[:table_id] if table_name_or_id[:table_id]
          x.LIST_ID list_id
          map_fields.each do |map_field|
            x.MAP_FIELD {
              x.LIST_FIELD map_field[:list_field]
              x.TABLE_FIELD map_field[:table_field]
            }
          end
        }
      }
    end

    def insert_update_relational_table(table_id, rows)
      xml_envelope { |x|
        x.InsertUpdateRelationalTable {
          x.TABLE_ID table_id
          x.ROWS {
            rows.each do |row|
              x.ROW {
                row.each do |column|
                  x.COLUMN(name: column[:name]) {
                    x.cdata!(column[:value])
                  }
                end
              }
            end
          }
        }
      }
    end

    def export_list(list_id, export_type, export_format, options={})
      xml_envelope { |x|
        x.ExportList {
          x.LIST_ID list_id
          x.EXPORT_TYPE export_type
          x.EXPORT_FORMAT export_format
          build_options(x, options, {})
        }
      }
    end

    def get_job_status(job_id)
      xml_envelope { |x|
        x.GetJobStatus {
          x.JOB_ID job_id
        }
      }
    end

    def invoke_api(method, *args, &block)
      response = post(xml(method, *args, &block))
      Silverpop::EngageResponse.new(response)
    end
  end
end