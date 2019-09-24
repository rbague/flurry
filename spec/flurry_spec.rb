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

  it 'should override the default settings' do
    Flurry.configuration.format = :json
    Flurry.configuration.time_zone = 'Etc/UTC'

    base = Flurry.from(:app_usage)
    expect(base.send(:format_partial_path)).to eq '&format=json'
    expect(base.format(:csv).send(:format_partial_path)).to eq '&format=csv'
    expect(base.send(:time_zone_partial_path)).to eq '&timeZone=Etc/UTC'
    expect(base.time_zone('Europe/Madrid').send(:time_zone_partial_path)).to eq '&timeZone=Europe/Madrid'

    Flurry.configuration.format = nil
    Flurry.configuration.time_zone = nil
  end

  it 'should build the right url' do
    token = Flurry.configuration.token

    expect(Flurry.from(:app_usage).select(:sessions).between(@now).send(:full_path))
      .to eq "/appUsage/day?token=#{token}&metrics=sessions&dateTime=2019-01-20/2019-01-21"
    expect(Flurry.from(:app_usage).select(:sessions).showing(app: :id).between(@now).send(:full_path))
      .to eq "/appUsage/day/app;show=id?token=#{token}&metrics=sessions&dateTime=2019-01-20/2019-01-21"
    expect(Flurry.from(:app_usage).select(:sessions).showing(app: :id).between(@now).sort(:sessions).send(:full_path))
      .to eq "/appUsage/day/app;show=id?token=#{token}&metrics=sessions&sort=sessions|desc&dateTime=2019-01-20/2019-01-21"
    expect(Flurry.from(:app_usage).select(:sessions).showing(app: :id).between(@now).having(sessions: { gt: 10, lt: 20 }).sort(:sessions).send(:full_path))
      .to eq "/appUsage/day/app;show=id?token=#{token}&metrics=sessions&sort=sessions|desc&having=sessions-gt[10],sessions-lt[20]&dateTime=2019-01-20/2019-01-21"
  end

  it 'should make a successful JSON request', http: true do
    response = Flurry.from(:app_usage).select(:sessions).between(@now - 7, @now).format(:json).fetch

    expect(response.body).not_to be_empty
    expect(response.body).to be_a(Hash)
    expect(response.code).to eq 200
  end

  it 'should make a successful CSV request', http: true do
    response = Flurry.from(:app_usage).select(:sessions).between(@now - 7, @now).format(:csv).fetch

    expect(response.body).not_to be_empty
    expect(response.body).to be_a(Array)
    expect(response.code).to eq 200
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
      expect(base.showing(app: :id).showing(platform: :name).send(:dimensions_partial_path)).to eq '/app;show=id/platform;show=name'
      expect(base.showing(app: :id).showing(app: :name).send(:dimensions_partial_path)).to eq '/app;show=id,name'
    end

    it 'should build time zone partial' do
      base = Flurry.from(:app_usage)

      expect(base.send(:time_zone_partial_path)).to be_empty
      expect(base.time_zone('').send(:time_zone_partial_path)).to be_empty
      expect(base.time_zone(nil).send(:time_zone_partial_path)).to be_empty
      expect(base.time_zone('Europe/Madrid').send(:time_zone_partial_path)).to eq '&timeZone=Europe/Madrid'
    end

    it 'should build format partial' do
      base = Flurry.from(:app_usage)

      expect(base.send(:format_partial_path)).to be_empty
      expect(base.format('').send(:format_partial_path)).to be_empty
      expect(base.format(nil).send(:format_partial_path)).to be_empty
      expect(base.format(:json).send(:format_partial_path)).to eq '&format=json'
      expect(base.format('json').send(:format_partial_path)).to eq '&format=json'
    end

    it 'should build metrics partial' do
      base = Flurry.from(:app_usage)

      expect { base.select.send(:metrics_partial_path) }.to raise_error(Flurry::Error)
      expect { base.select(nil).send(:metrics_partial_path) }.to raise_error(Flurry::Error)
      expect { base.select([]).send(:metrics_partial_path) }.to raise_error(Flurry::Error)
      expect(base.select(:sessions).send(:metrics_partial_path)).to eq '&metrics=sessions'
      expect(base.select([:sessions]).send(:metrics_partial_path)).to eq '&metrics=sessions'
      expect(base.select(:active_users, 'newDevices').send(:metrics_partial_path)).to eq '&metrics=activeUsers,newDevices'
      expect(base.select(:active_users, :new_devices).send(:metrics_partial_path)).to eq '&metrics=activeUsers,newDevices'
      expect(base.select(:active_users).select(:new_devices).send(:metrics_partial_path)).to eq '&metrics=activeUsers,newDevices'
    end

    it 'should build time range partial' do
      base = Flurry.from(:app_usage)

      expect { base.between.send(:time_range_partial_path) }.to raise_error(ArgumentError)
      expect { base.between(nil).send(:time_range_partial_path) }.to raise_error(Flurry::Error)
      expect(base.between(@now).send(:time_range_partial_path)).to eq '&dateTime=2019-01-20/2019-01-21'
      expect(base.between(@now, @now + 1).send(:time_range_partial_path)).to eq '&dateTime=2019-01-20/2019-01-21'
      expect(base.between(@now, format: '%Y-%m-%dT%H').send(:time_range_partial_path)).to eq '&dateTime=2019-01-20T00/2019-01-21T00'
      expect(base.between(@now, @now + 2, format: '%Y-%m-%dT%H').send(:time_range_partial_path)).to eq '&dateTime=2019-01-20T00/2019-01-22T00'
      expect(base.between(@now, '2019-02-15').send(:time_range_partial_path)).to eq '&dateTime=2019-01-20/2019-02-15'
      expect(base.between('2019-01-15', @now).send(:time_range_partial_path)).to eq '&dateTime=2019-01-15/2019-01-20'
      expect(base.between('2019-02-15').send(:time_range_partial_path)).to eq '&dateTime=2019-02-15/2019-02-15' # does not convert finish to start + 1 if start is a String
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
      expect(base.sort(sessions: :asc).sort(new_devices: :desc).send(:sort_partial_path)).to eq '&sort=sessions|asc,newDevices|desc'
      expect(base.sort(sessions: :asc).sort(sessions: :desc).send(:sort_partial_path)).to eq '&sort=sessions|desc'
      expect(base.sort({ sessions: :asc }, 5).send(:sort_partial_path)).to eq '&topN=5&sort=sessions|asc'
      expect(base.sort({}, 5).send(:sort_partial_path)).to be_empty
    end

    it 'should build having partial' do
      base = Flurry.from(:app_usage).select(:sessions, :new_devices)

      expect { Flurry.from(:app_usage).having(sessions: { gt: 100 }) }.to raise_error(Flurry::Error)
      expect(base.having({}).send(:having_partial_path)).to be_empty
      expect(base.having.send(:having_partial_path)).to be_empty
      expect(base.having(page_views: { eq: 0 }).send(:having_partial_path)).to be_empty
      expect(base.having(nil: { gt: 100 }).send(:having_partial_path)).to be_empty
      expect(base.having(sessions: {}).send(:having_partial_path)).to be_empty
      expect(base.having(sessions: { gt: 100 }).send(:having_partial_path)).to eq '&having=sessions-gt[100]'
      expect(base.having('newDevices': { gt: 100 }).send(:having_partial_path)).to eq '&having=newDevices-gt[100]'
      expect(base.having(sessions: { gt: 100, lt: 100 }).send(:having_partial_path)).to eq '&having=sessions-gt[100],sessions-lt[100]'
      expect(base.having(sessions: {}, new_devices: { gt: 100 }).send(:having_partial_path)).to eq '&having=newDevices-gt[100]'
      expect(base.having(sessions: { lt: 100 }, new_devices: { gt: 100 }).send(:having_partial_path)).to eq '&having=sessions-lt[100],newDevices-gt[100]'
      expect(base.having(sessions: { lt: 100 }).having(new_devices: { gt: 100 }).send(:having_partial_path)).to eq '&having=sessions-lt[100],newDevices-gt[100]'
      expect(base.having(sessions: { lt: 100, gt: 25 }).having(sessions: { lt: 50 }).send(:having_partial_path)).to eq '&having=sessions-lt[50],sessions-gt[25]'
    end
  end
end
