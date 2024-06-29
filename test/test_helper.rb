# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'blnk'
require 'pry'
require 'webmock/minitest'
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

Blnk.address = 'http://localhost:5001'
Blnk.secret_token = 'secret_token'
