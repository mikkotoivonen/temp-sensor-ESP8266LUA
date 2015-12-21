function get_http_req (instr)
   local t = {}
   local first = nil
   local key, v, strt_ndx, end_ndx

   for str in string.gmatch (instr, "([^\n]+)") do

      if (first == nil) then
         first = 1
         strt_ndx, end_ndx = string.find (str, "([^ ]+)")
         v = trim (string.sub (str, end_ndx + 2))
         key = trim (string.sub (str, strt_ndx, end_ndx))
         t["METHOD"] = key
         t["REQUEST"] = v
      else 
         strt_ndx, end_ndx = string.find (str, "([^:]+)")
         if (end_ndx ~= nil) then
            v = trim (string.sub (str, end_ndx + 2))
            key = trim (string.sub (str, strt_ndx, end_ndx))
            t[key] = v
         end
      end
   end

   return t
end

function trim (s)
  return (s:gsub ("^%s*(.-)%s*$", "%1"))
end

ss=net.createServer(net.TCP,5)
ss:listen(80,function(c)
   c:on("receive",function(c,payload)
      print("Request received\n------")
      query_data = get_http_req (payload)
      words = {}
      for word in query_data["REQUEST"]:gmatch('([^ ]+)') do table.insert(words, word) end
      print("Path: |" .. words[1] .. "|")
      words[1] = string.gsub(words[1], "%%22", '%"')
      
      tmr.delay(100)
      print(node.heap())

      if words[1]:find('%/(cfg)%?') then

     for ks in words[1]:gmatch('{(.-)}') do 
          print(ks)
          print("{" .. ks .. "}")
          configs = cjson.decode("{" .. ks .. "}")
          for k, v in pairs( configs ) do
               print(k, v)
          end
          file.open("config","w+")
          file.write("{" .. ks .. "}")
          file.close()
          
      end
      
      c:send("HTTP/1.1 200 OK\n\n")
      c:send("Data received") 
      node.restart()
      else
          c:send("HTTP/1.1 404 Not Found \n")
          c:send("Connection: close\n\n")
      end

      c:on("sent",function(c) print("Closing connection") c:close() end)
      c:on("disconnection",function(c) print("Disconnected...") end)
    end)
end)

function restartNode()
          print("Time out. Restarting.")
          node.restart()
end

tmr.alarm(0,60000,1,restartNode)
