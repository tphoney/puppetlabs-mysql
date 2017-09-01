require 'spec_helper_acceptance'
require_relative '../mysql_helper.rb'

describe 'mysql_user' do
  describe 'setup' do
    it 'works with no errors' do
      pp = <<-EOS
        class { 'mysql::server': }
      EOS

      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'using ashp@localhost' do
    describe 'adding user' do
      let(:pp) do
        <<-EOS
          mysql_user { 'ashp@localhost':
            password_hash => '*F9A8E96790775D196D12F53BCC88B8048FF62ED5',
          }
        EOS
      end

      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end

      it 'finds the user' do
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          check_script_output(result: r, match: '^1$')
        end
      end
      it 'has no SSL options' do
        shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          check_script_output(result: r, match: '^\s*$')
        end
      end
    end
  end

  context 'using ashp-dash@localhost' do
    describe 'adding user' do
      let(:pp) do
        <<-EOS
          mysql_user { 'ashp-dash@localhost':
            password_hash => '*F9A8E96790775D196D12F53BCC88B8048FF62ED5',
          }
        EOS
      end

      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end

      it 'finds the user' do
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'ashp-dash@localhost'\"") do |r|
          check_script_output(result: r, match: '^1$')
        end
      end
    end
  end

  context 'using ashp@LocalHost' do
    describe 'adding user' do
      let(:pp) do
        <<-EOS
          mysql_user { 'ashp@LocalHost':
            password_hash => '*F9A8E96790775D196D12F53BCC88B8048FF62ED5',
          }
        EOS
      end

      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end

      it 'finds the user' do
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          check_script_output(result: r, match: '^1$')
        end
      end
    end
  end
  context 'using resource should throw no errors' do
    describe 'find users' do
      it { # rubocop:disable RSpec/MultipleExpectations
        on default, puppet('resource mysql_user'), catch_failures: true do |r|
          expect(r.stdout).not_to match(%r{Error:})
          expect(r.stdout).not_to match(%r{must be properly quoted, invalid character:})
        end
      }
    end
  end
  context 'using user-w-ssl@localhost with SSL' do
    describe 'adding user' do
      let(:pp) do
        <<-EOS
          mysql_user { 'user-w-ssl@localhost':
            password_hash => '*F9A8E96790775D196D12F53BCC88B8048FF62ED5',
            tls_options   => ['SSL'],
          }
        EOS
      end

      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end

      it 'finds the user' do
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'user-w-ssl@localhost'\"") do |r|
          check_script_output(result: r, match: '^1$')
        end
      end
      it 'shows correct ssl_type' do
        shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'user-w-ssl@localhost'\"") do |r|
          check_script_output(result: r, match: '^ANY$')
        end
      end
    end
  end
  context 'using user-w-x509@localhost with X509' do
    describe 'adding user' do
      let(:pp) do
        <<-EOS
          mysql_user { 'user-w-x509@localhost':
            password_hash => '*F9A8E96790775D196D12F53BCC88B8048FF62ED5',
            tls_options   => ['X509'],
          }
        EOS
      end

      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end

      it 'finds the user' do
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'user-w-x509@localhost'\"") do |r|
          check_script_output(result: r, match: '^1$')
        end
      end
      it 'shows correct ssl_type' do
        shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'user-w-x509@localhost'\"") do |r|
          check_script_output(result: r, match: '^X509$')
        end
      end
    end
  end
end
