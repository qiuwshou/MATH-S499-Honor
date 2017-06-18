#!/usr/bin/ruby



# 

def read_data(filename)
  file = File.open(filename, "r")
  lines = file.readlines
  count = 0
  data = {}  
  lines.each do |l|
    terms = l.split(',')
    if count != 0
      day = {}
      day["Usage"] = terms[3]
      day["Occupants"] = terms[4]   
      day["Max Beds"] = terms[5]
      day["% Occupied"] = terms [6]
      day["SqFt"] = terms[7]
      day["Maximum Air Temperature"] = terms[10]
      day["Minimum Air Temperature"] = terms[11]
      day["Maximum Relative Humidity"] = terms[12]
      day["Minimum Relative Humidity"] = terms[13]
      data[terms[1]] = day
    end
    count += 1
  end
  data["Days"] = count
  
  return data
end

file_list = Dir.entries("building")
file_list = file_list[2..-1]


  

