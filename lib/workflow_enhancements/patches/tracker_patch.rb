require_dependency 'tracker'

module RenderIssueEnhancements
  def render(*args, &block)
    if @issue_statuses
      return @issue_statuses
    elsif new_record?
      return []
    end

    ids = WorkflowTransition.connection.select_rows(
      "SELECT DISTINCT old_status_id, new_status_id
       FROM #{WorkflowTransition.table_name}
       WHERE tracker_id = #{id} AND type = 'WorkflowTransition'").flatten
    ids.concat TrackerStatus.connection.select_rows(
      "SELECT issue_status_id
       FROM #{TrackerStatus.table_name}
       WHERE tracker_id = #{id}")

    ids = ids.flatten.uniq
    @issue_statuses = IssueStatus.where(:id => ids).all.sort
  end
end

class Tracker
  has_many :tracker_statuses
  has_many :predef_issue_statuses, :through => :tracker_statuses
  
  # delegates partial views to module
  Tracker.send(:prepend, RenderIssueEnhancements)  #alias_method_chain :issue_statuses, :workflow_enhancements
  
  #def render_with_workflow_enhancements(*args, &block)... moved to RenderIssueEnhancements now called render()
  
end
