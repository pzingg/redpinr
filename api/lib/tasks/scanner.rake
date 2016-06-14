namespace :scanner do
  desc "perform a wifi scan"
  task scan: :environment do
    MacWifiScanner.scan(/^ksd-(student|guest)$/)
  end
end
