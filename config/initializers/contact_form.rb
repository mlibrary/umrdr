Rails.application.config.contact_issue_types = [
    'I have questions about depositing my data',
    'I need help with data management',
    'I want to deposit files larger than 2GB',
    'I have a general question or comment about Deep Blue Data',
    'Other'
  ].freeze

Rails.application.config.contact_issue_type_data_management = Rails.application.config.contact_issue_types[1]
