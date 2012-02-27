maintainer       "ParaVolve Development Corporation"
maintainer_email "jwb@paravolve.net"
license          "GNU Public License 2.0"
description      "Installs/Configures opensim"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

%w{ mysql }.each do |dep|
  depends dep
end

%{ ubuntu }.each do |sup|
  supports sup
end
