# chetan.muneshwar@gmail.com
# A ruby script for collecting bounced email with status
require 'rubygems'
path = "/var/spool/postfix/defer"
defer = Dir.foreach("/var/spool/postfix/defer")

defer.each do |x|
	
  x.gsub("..",'').gsub(".",'')
  if File.directory?("#{path}/#{x}")
     if Dir["#{path}/#{x}"].empty?
       # "is empty"
     else
       # "is not empty"
       a = x.gsub("..",'').gsub(".",'')
       if a == ''
         #
       else
         sub_dir = "#{path}/#{a}"
         Dir.foreach("#{sub_dir}") do |doc|
            sub_sub_dir = doc.gsub("..",'').gsub(".",'')
            
            if sub_sub_dir  == ''
            #
            else
               contents = Array.new
               file = File.open("#{sub_dir}/#{sub_sub_dir}", "rb")
               file.each do |data|
                  contents << data
               end 
               output = Array.new
               arr = Array.new
               arr = contents.to_a.join
               arr.split("\n").each do |data|
                  if data =~ /^recipient=/ 
                    output << data
                  end
                  if data =~ /^status/
                    output << data
                  end
                  if data =~ /^reason/
                      output << data
                  end
                  
                      
               end
	       time_st = File.mtime(file)
               puts " #{time_st} | #{output[0]} | #{output[1]} | #{output[2]}"
               puts "!"   
            end
         end      
       
       end    
     end    
     
  else
     #
  end
end

