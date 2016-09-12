class GroupChat < Chat
  self.table_name = self.to_s.underscore.pluralize
end
