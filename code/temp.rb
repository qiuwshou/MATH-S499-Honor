#!/usr/bin/ruby


def read_data(filename)
  file = File.open(filename,"r")
  words = file.readlines
  avgmax = 0
  avgmin = 0
  count = 0
  month={}
  day={}
  words.each do |w|
    w = w.split(',')
    if "24" == w[0] then
      data={}
      everyday = w[2]
      data["Maximum Air Temperature"] = w[6]
      data["Time of Maximum Temperature"] = w[7]
      data["Minimum Air Temperature"] = w[8]
      data["Time of Minimum Temperature"] = w[9]

      day[everyday] = data      
      avgmax = avgmax + w[6].to_f
      avgmin = avgmin + w[8].to_f
      count = count +1
    end
  end
  month["avgmax"] = (avgmax / count).round(5)
  month["avgmin"] = (avgmin / count).round(5)
  month[filename] = day
  return month
end



file_list = Dir.entries("ww")
file_list.sort!
file_list = file_list[2..-1]

month={}
day ={}
data ={}
final =File.open( "temperature information.txt","w")
final.puts("[Month] [Day] [Maximum Temperature] [Minimum Temperature] [Avg Max] [Avg Min]")
file_list.each do |filename|
  month = read_data("ww/"+filename)
  day = month["ww/"+filename]
  day.each_key do |everyday|
    data = day[everyday]
    s = filename[0..6]+" "+ everyday.to_s+" "+data["Maximum Air Temperature"]+" "+data["Minimum Air Temperature"]+" "+month["avgmax"].to_s+" "+month["avgmin"].to_s
  final.puts(s)
  end
end
final.close
 
