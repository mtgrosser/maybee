# encoding: utf-8

require File.expand_path('../../test_helper', __FILE__)

class MaybeeTest < ActiveSupport::TestCase

  setup do
    %w(Opel GM Volkswagen Audi Porsche Jaguar Bugatti).each { |name| Make.create!(:name => name) }
    @bonnie = Driver.create!(:name => 'Bonnie', :level => 1)
    @clyde = Driver.create!(:name => 'Clyde', :level => 3)
    @ferdinand = Driver.create!(:name => 'Ferdinand', :level => 3, :super_powers => true)
    @opel_workshop = Workshop.create(:name => 'Opel Workshop', :make_ids => Make['Opel', 'GM'])
    @vag_workshop  = Workshop.create(:name => 'VAG Workshop', :make_ids => Make['Volkswagen', 'Audi', 'Porsche'])
    @jaguar_workshop = Workshop.create(:name => 'Jaguar Workshop', :make_ids => Make['Jaguar'])
  end
  
  test 'Translation of error messages is present' do
    assert_equal 'You are not authorized to create this object', I18n.t('activerecord.errors.messages.not_authorized', :access => 'create')
  end
  
  test 'Authorize sets error if unauthorized' do
    mantra = Car.new(:model => 'Opel Mantra', :make_id => Make[:Opel], :minimum_driver_level => 0)
    assert_valid mantra
    assert_nil mantra.authorization_subject
    assert_save mantra
    assert_equal false, mantra.authorize?(:destroy)
    assert_error_on mantra, :not_authorized
    mantra.authorization_subject = @bonnie
    assert_equal true, mantra.authorize?(:destroy)
  end
    
  test 'Creation, updating and destruction' do
    mantra = Car.new(:model => 'Opel Mantra', :make_id => Make[:Opel], :minimum_driver_level => 0)
    assert_valid mantra
    assert_nil mantra.authorization_subject
    assert_save mantra
    assert_equal true, mantra.update_attributes!(:minimum_driver_level => 2)
    assert_equal 2, mantra.reload.minimum_driver_level
    assert_no_difference 'Car.count' do
      assert_equal false, mantra.destroy
      assert_error_on mantra, :not_authorized
    end
    
  end
  
  test 'Exclusive authorizations' do
    bugatti = ExclusiveCar.new(:model => 'Bugatti Veyron', :make_id => Make['Bugatti'], :minimum_driver_level => 9)
    assert_equal false, bugatti.save
    bugatti.authorization_subject = @ferdinand
    assert_equal true, bugatti.authorize?(:create)
    assert_save bugatti
    bugatti = Car.find(bugatti.id)
    assert_nil bugatti.authorization_subject
    assert_no_difference 'Car.count' do
      assert_equal false, bugatti.destroy
      assert_error_on bugatti, :not_authorized
    end
    bugatti.authorization_subject = @ferdinand
    assert_difference 'Car.count', -1 do
      assert bugatti.destroy
    end
  end
  

  test 'Inheritance' do
    skip 'Test missing, flunk!'
  end

end
