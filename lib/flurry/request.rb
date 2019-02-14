require 'httparty'
require 'flurry/helper'

module Flurry
  class Request # :nodoc:
    include HTTParty
    include Helper

    base_uri 'https://api-metrics.flurry.com/public/v1/data'

    def initialize(table, group_by)
      raise ArgumentError, 'table must be non nil' if table.nil?

      @table = table
      @grain = group_by || :day
    end

    def showing(**dimensions)
      dup.tap { |it| it.dimensions = clean_dimensions(dimensions || {}) }
    end

    def select(*metrics)
      metrics = metrics.flatten.reject(&:nil?) || []
      raise Flurry::Error, 'at least one metric has to be provided' if metrics.empty?

      dup.tap { |it| it.metrics = metrics.map { |m| camelize(m.to_s) } }
    end

    def between(start, finish = nil, format: '%Y-%m-%d')
      raise Flurry::Error, 'at least start time has to be provided' unless start
      raise ArgumentError, 'start must be a Time/Date/DateTime' unless datetime?(start)
      raise ArgumentError, 'finish must be a Time/Date/DateTime' if finish && !datetime?(finish)

      finish = (finish || tomorrow(start)).strftime(format)
      start = start.strftime(format)

      dup.tap { |it| it.range = [start, finish] }
    end

    def sort(sorts, top = 0)
      raise Flurry::Error, 'metrics must be provided before sort' unless @metrics

      sorts = { sorts => nil } unless sorts.is_a?(Hash)
      dup.tap do |it|
        it.sorts = clean_sorts(sorts || {})
        it.top = top
      end
    end

    def having(**havings)
      raise Flurry::Error, 'metrics must be provided before having' unless @metrics

      dup.tap { |it| it.havings = clean_havings(havings || {}) }
    end

    def fetch
      self.class.get(full_path).response
    end

    protected

    attr_writer :table, :grain, :dimensions, :metrics, :range, :sorts, :top, :havings

    private

    def clean_dimensions(**dimens)
      dimens.each_with_object({}) do |(key, val), h|
        new_value = [val] unless val.is_a? Array
        new_value ||= val
        new_value.map! { |v| camelize(v.to_s) unless v.nil? }
        h[camelize(key.to_s)] = new_value
      end
    end

    def clean_sorts(sorts)
      sorts.each_with_object({}) do |(key, val), h|
        next if key.nil?

        k = camelize(key.to_s)
        h[k] = val || :desc if @metrics.include? k
      end
    end

    def clean_havings(sorts)
      sorts.each_with_object({}) do |(key, val), h|
        next if key.nil? || val.nil? || val.empty?

        k = camelize(key.to_s)
        h[k] = val if @metrics.include? k
      end
    end

    def base_partial_path
      "/#{camelize(@table.to_s)}/#{@grain}"
    end

    def dimensions_partial_path
      partial = ''.tap do |path|
        @dimensions.each do |dimension, fields|
          path << "/#{dimension}"
          path << ";show=#{fields.join(',')}" if fields.any?
        end
      end if @dimensions

      partial || ''
    end

    def metrics_partial_path
      '&metrics=' + @metrics.map do |metric|
        metric unless metric.nil?
      end.join(',')
    end

    def time_range_partial_path
      "&dateTime=#{@range.join('/')}"
    end

    def sort_partial_path
      return '' unless @sorts && @sorts.any?

      partial = ("&topN=#{@top}" if @top && @top.positive?) || ''
      partial.tap do |path|
        path << '&sort='
        path << @sorts.map { |k, v| "#{k}|#{v}" }.join(',')
      end
    end

    def having_partial_path
      return '' unless @havings && @havings.any?

      '&having=' + @havings.map do |metric, hs|
        hs.map { |k, v| "#{metric}-#{k}[#{v}]" }.join(',')
      end.join(',')
    end

    def full_path
      ''.tap do |path|
        path << base_partial_path
        path << dimensions_partial_path
        path << '?'
        path << 'token=' + Flurry.configuration.token
        path << '&timeZone=' + Flurry.configuration.time_zone if Flurry.configuration.time_zone
        path << metrics_partial_path
        path << sort_partial_path
        path << having_partial_path
        path << time_range_partial_path
      end
    end
  end
end
