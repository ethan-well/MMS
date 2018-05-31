desc "I am short, but comprehensive description for my cool task"
task :cache_sale_infos => :environment do
  Rails.cache.clear
  Goods.cache_goods_sale_info
  Goods.all.each do |goods|
    puts "goods_id: #{goods.id}"
    goods.cache_sale_info
    sleep 5
  end
end
