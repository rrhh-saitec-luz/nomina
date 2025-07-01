module ApplicationHelper
  def active_class(link_path)
    current_page?(link_path) ? 'list-group-item-primary' : ''
  end
end
