require 'spec_helper'

RSpec.describe Flurry do
  before(:all) do
    @now = Date.strptime('2019-01-20', '%Y-%m-%d')
  end

  it 'has a valid configuration' do
    expect(Flurry.configuration.token).not_to be nil
    expect(Flurry.configuration.time_zone).to be nil
  end

  it 'should create the base object' do
    expect { Flurry.from }.to raise_error(ArgumentError)
    expect { Flurry.from(nil) }.to raise_error(ArgumentError)
    expect { Flurry.from(nil, :day) }.to raise_error(ArgumentError)
    expect(Flurry.from(:app_usage)).to be_a(Flurry::Request)
    expect(Flurry.from(:app_usage, :day)).to be_a(Flurry::Request)
  end

  it 'should build the right url', focus: true do
    token = Flurry.configuration.token

    expect(Flurry.from(:app_usage).select(:sessions).between(@now).send(:full_path))
      .to eq "/appUsage/day?token=#{token}&metrics=sessions&dateTime=2019-01-20/2019-01-21"
    expect(Flurry.from(:app_usage).select(:sessions).showing(app: :id).between(@now).send(:full_path))
      .to eq "/appUsage/day/app;show=id?token=#{token}&metrics=sessions&dateTime=2019-01-20/2019-01-21"
    expect(Flurry.from(:app_usage).select(:sessions).showing(app: :id).between(@now).sort(:sessions).send(:full_path))
      .to eq "/appUsage/day/app;show=id?token=#{token}&metrics=sessions&sort=sessions|desc&dateTime=2019-01-20/2019-01-21"
  end

  describe 'path partials' do
    it 'should build base partial' do
      expect(Flurry.from(:app_usage).send(:base_partial_path)).to eq '/appUsage/day'
      expect(Flurry.from('appUsage').send(:base_partial_path)).to eq '/appUsage/day'
      expect(Flurry.from(:app_usage, :hour).send(:base_partial_path)).to eq '/appUsage/hour'
      expect(Flurry.from('appUsage', 'hour').send(:base_partial_path)).to eq '/appUsage/hour'
    end

    it 'should build dimensions partial' do
      base = Flurry.from(:app_usage)

      expect(base.showing(app: nil).send(:dimensions_partial_path)).to eq '/app'
      expect(base.showing(app: []).send(:dimensions_partial_path)).to eq '/app'
      expect(base.showing(app: %i[id name]).send(:dimensions_partial_path)).to eq '/app;show=id,name'
      expect(base.showing(app: %w[id platform|name]).send(:dimensions_partial_path)).to eq '/app;show=id,platform|name'
      expect(base.showing(app: :id, platform: %i[id name]).send(:dimensions_partial_path)).to eq '/app;show=id/platform;show=id,name'
      expect(base.showing(app_version: :id).send(:dimensions_partial_path)).to eq '/appVersion;show=id'
    end

    it 'should build metrics partial' do
      base = Flurry.from(:app_usage)

      expect { base.select.send(:metrics_partial_path) }.to raise_error(Flurry::Error)
      expect { base.select(nil).send(:metrics_partial_path) }.to raise_error(Flurry::Error)
      expect { base.select([]).send(:metrics_partial_path) }.to raise_error(Flurry::Error)
      expect(base.select(:sessions).send(:metrics_partial_path)).to eq '&metrics=sessions'
      expect(base.select([:sessions]).send(:metrics_partial_path)).to eq '&metrics=sessions'
      expect(base.select(:active_users, 'newDevices').send(:metrics_partial_path)).to eq '&metrics=activeUsers,newDevices'
    end

    it 'should build time range partial' do
      base = Flurry.from(:app_usage)

      expect { base.between.send(:time_range_partial_path) }.to raise_error(ArgumentError)
      expect { base.between(nil).send(:time_range_partial_path) }.to raise_error(Flurry::Error)
      expect(base.between(@now).send(:time_range_partial_path)).to eq '&dateTime=2019-01-20/2019-01-21'
      expect(base.between(@now, @now + 1).send(:time_range_partial_path)).to eq '&dateTime=2019-01-20/2019-01-21'
      expect(base.between(@now, format: '%Y-%m-%dT%H').send(:time_range_partial_path)).to eq '&dateTime=2019-01-20T00/2019-01-21T00'
      expect(base.between(@now, @now + 2, format: '%Y-%m-%dT%H').send(:time_range_partial_path)).to eq '&dateTime=2019-01-20T00/2019-01-22T00'
    end

    it 'should build sort partial' do
      base = Flurry.from(:app_usage).select(:sessions, :new_devices)

      expect { Flurry.from(:app_usage).sort(sessions: :asc) }.to raise_error(Flurry::Error)
      expect(base.sort(page_views: :asc).send(:sort_partial_path)).to be_empty
      expect(base.sort(nil: :asc).send(:sort_partial_path)).to be_empty
      expect(base.sort(:sessions).send(:sort_partial_path)).to eq '&sort=sessions|desc'
      expect(base.sort(sessions: :asc).send(:sort_partial_path)).to eq '&sort=sessions|asc'
      expect(base.sort(sessions: :asc, page_views: :desc).send(:sort_partial_path)).to eq '&sort=sessions|asc'
      expect(base.sort(sessions: :asc, new_devices: nil).send(:sort_partial_path)).to eq '&sort=sessions|asc,newDevices|desc'
      expect(base.sort(sessions: :asc, new_devices: :desc).send(:sort_partial_path)).to eq '&sort=sessions|asc,newDevices|desc'
      expect(base.sort({ sessions: :asc }, 5).send(:sort_partial_path)).to eq '&topN=5&sort=sessions|asc'
      expect(base.sort({}, 5).send(:sort_partial_path)).to be_empty
    end
  end
end
