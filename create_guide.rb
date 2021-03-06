require 'nokogiri'
require 'byebug'

doc = Nokogiri::HTML(open('/home/evaldas/rspec_guide.html'))

File.open('rspec_guide.md', 'w') do |file|
  doc.css('article').each do |article|
    file.puts "### #{article.css('h1 a').text}\n\n"
    article.css('p').each do |p|
      if p.attributes['class'] && p.attributes['class'].value =~ /wrong|correct|base/
        file.puts "```ruby"
        file.puts "# #{p.text}"
        p.next_element.css('pre')[0].text.split("\n").each do |line|
          file.puts line
        end
        file.puts "```\n\n"
      else
        next if p.text =~ /Discuss this guideline|Learn more about|More about/
        if p.elements.empty?
          file.puts p.text.strip.gsub("\n", '').gsub(/\s\s+/, ' ')
        else
          if p.elements[0].name == 'a'
            file.puts p.text.gsub(/#{p.elements.text}/, "[#{p.elements.text}](#{p.elements[0].attributes['href'].value})").strip.gsub("\n", '').gsub(/\s\s+/, ' ')
          end
        end
        file.puts "\n"
      end
    end
  end
end
