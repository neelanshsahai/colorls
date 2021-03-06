require 'spec_helper'

RSpec.describe ColorLS::Flags do
  FIXTURES = 'spec/fixtures'.freeze

  subject { capture_stdout { described_class.new(*args).process } }

  def capture_stdout
    old = $stdout
    $stdout = fake = StringIO.new
    yield
    fake.string
  ensure
    $stdout = old
  end

  context 'with no flags' do
    let(:args) { [FIXTURES] }

    it { is_expected.not_to match(/((r|-).*(w|-).*(x|-).*){3}/) } # does not list file info
    it { is_expected.not_to match(/\.hidden-file/) } # does not display hidden files
    it { is_expected.not_to match(/Found \d+ contents/) } # does not show a report
    it { is_expected.to match(/a-file.+symlinks.+z-file/) } # displays dirs & files alphabetically
    it { is_expected.not_to match(/(.*\n){3}/) } # displays multiple files per line
    it { is_expected.not_to match(%r(\.{1,2}/)) } # does not display ./ or ../
    it { is_expected.not_to match(/├──/) } # does not display file hierarchy
  end

  context 'with --reverse flag' do
    let(:args) { ['--reverse', FIXTURES] }

    it { is_expected.to match(/z-file.+symlinks.+a-file/) } # displays dirs & files in reverse alphabetical order
  end

  context 'with --long flag & file path' do
    let(:args) { ['--long', "#{FIXTURES}/.hidden-file"] }

    it { is_expected.not_to match(/No Info/) } # lists info of a hidden file
  end

  context 'with --long flag' do
    let(:args) { ['--long', FIXTURES] }

    it { is_expected.to match(/((r|-).*(w|-).*(x|-).*){3}/) } # lists file info
  end

  context 'with --all flag' do
    let(:args) { ['--all', FIXTURES] }

    it { is_expected.to match(/\.hidden-file/) } # lists hidden files
  end

  context 'with --sort-dirs flag' do
    let(:args) { ['--sort-dirs', FIXTURES] }

    it { is_expected.to match(/symlinks.+a-file.+z-file/) } # sorts results alphabetically, directories first
  end

  context 'with --sort-files flag' do
    let(:args) { ['--sort-files', FIXTURES] }

    it { is_expected.to match(/a-file.+z-file.+symlinks/) } # sorts results alphabetically, files first
  end

  context 'with --sort=time' do
    entries = Dir.entries(FIXTURES).grep(/^[^.]/).shuffle.freeze
    mtime = Time.new(2017, 11, 7, 2, 2, 2).freeze

    files = entries.each_with_index do |e, i|
      t = mtime + i
      File.utime(t, t, File.join(FIXTURES, e))
      Regexp.quote(e)
    end

    expected = Regexp.new files.reverse.join('.+'), Regexp::MULTILINE

    let(:args) { ['--sort=time', FIXTURES] }

    it { is_expected.to match(expected) }
  end

  context 'with --sort=size flag' do
    let(:args) { ['--sort=size', FIXTURES] }

    it { is_expected.to match(/a-file.+z-file.+symlinks/) } # sorts results by size
  end

  context 'with --dirs flag' do
    let(:args) { ['--dirs', FIXTURES] }

    it { is_expected.not_to match(/a-file/) } # displays dirs only
  end

  context 'with --files flag' do
    let(:args) { ['--files', FIXTURES] }

    it { is_expected.not_to match(/symlinks/) } # displays files only
  end

  context 'with -1 flag' do
    let(:args) { ['-1', FIXTURES] }

    it { is_expected.to match(/(.*\n){3}/) } # displays one file per line
  end

  context 'with --almost-all flag' do
    let(:args) { ['--almost-all', FIXTURES] }

    it { is_expected.to match(/\.hidden-file/) } # displays hidden files
  end

  context 'with --tree flag' do
    let(:args) { ['--tree', FIXTURES] }

    it { is_expected.to match(/├──/) } # displays file hierarchy
  end
end
