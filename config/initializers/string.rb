class String
  def to_chinese
    case itself
    when 'Waiting'
      '等待处理'
    when 'Dealing'
      '处理中'
    when 'Finished'
      '已完成'
    when 'Refund'
      '已经退款'
    else
      itself
    end
  end
end
