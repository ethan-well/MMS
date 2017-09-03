class String
  def to_chinese
    case itself
    when 'Waiting'
      '等待支付'
    when 'Paied'
      '已付款等待处理'
    when 'Dealing'
      '处理中'
    when 'Finished'
      '已完成'
    when 'Cancel'
      '已取消'
    when 'Hidden'
      '已隐藏'
    else
      itself
    end
  end
end
