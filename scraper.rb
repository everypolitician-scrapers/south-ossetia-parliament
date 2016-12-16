#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'pry'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//p[strong]').drop(1).each do |p|
    party = p.text.tidy
    p.xpath('following-sibling::p[1]').text.lines.map(&:tidy).each do |person|
      data = { 
        name: person.sub(/^\d+\.\s+/, ''),
        party: party,
        term: 2014,
        source: url,
      }
      ScraperWiki.save_sqlite([:name, :party, :term], data)
    end
  end
end

scrape_list('http://cominf.org/node/1166502155')
