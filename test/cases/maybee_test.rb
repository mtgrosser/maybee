# encoding: utf-8

require File.expand_path('../../test_helper', __FILE__)

class MaybeeTest < ActiveSupport::TestCase

  setup do
    %w(Opel GM Volkswagen Audi Porsche Jaguar Bugatti).each { |name| Make.create!(:name => name) }
    @bonnie = Driver.create!(:name => 'Bonnie', :level => 1)
    @clyde = Driver.create!(:name => 'Clyde', :level => 3)
    @ferdinand = Driver.create!(:name => 'Ferdinand', :level => 3, :super_powers => true)
    @opel_workshop = Workshop.create(:name => 'Opel Workshop', :makes => [Make['Opel'], Make['GM']])
    @vag_workshop  = Workshop.create(:name => 'VAG Workshop', :makes => [Make['Volkswagen'], Make['Audi'], Make['Porsche']])
    @jaguar_workshop = Workshop.create(:name => 'Jaguar Workshop', :makes => [Make['Jaguar']])
  end

  test 'Translation of error messages is present' do
    assert_equal 'You are not authorized to create this object', I18n.t('activerecord.errors.messages.not_authorized', :access => 'create')
  end

  test 'Authorize sets error if unauthorized' do
    mantra = Car.new(:model => 'Opel Mantra', :make => Make[:Opel], :minimum_driver_level => 0)
    assert_valid mantra
    assert_nil mantra.authorization_subject
    assert_save mantra
    assert_equal false, mantra.authorize?(:destroy)
    assert_error_on mantra, :not_authorized
    mantra.authorization_subject = @bonnie
    assert_equal true, mantra.authorize?(:destroy)
  end

  test 'Creation, updating and destruction' do
    mantra = Car.new(:model => 'Opel Mantra', :make => Make[:Opel], :minimum_driver_level => 0)
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
    bugatti = ExclusiveCar.new(:model => 'Bugatti Veyron', :make => Make['Bugatti'], :minimum_driver_level => 9)
    assert_equal false, bugatti.save
    bugatti.authorization_subject = @clyde
    assert_equal false, @clyde.super_powers?
    assert_equal false, bugatti.save
    assert_valid bugatti # clears errors
    assert_equal false, bugatti.save
    assert_error_on bugatti, :not_authorized
    bugatti.authorization_subject = @ferdinand
    assert_equal true, @ferdinand.super_powers?
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

  test 'Generic accesses and object methods' do
    # allows :workshops, :to => :repair, :if => :broken?, :if_subject => lambda { |car| makes.include?(car.make) }
    pana = Car.create!(:model => 'Porsche Panamerika', :make => Make[:Porsche], :minimum_driver_level => -10)
    assert_equal Make['Porsche'], pana.reload.make
    pana.broken = true
    assert_equal false, @opel_workshop.may?(:repair, pana)
    assert_no_error_on pana
    assert_equal true, @vag_workshop.may?(:repair, pana)
    assert_equal false, pana.repair!
    assert_error_on pana, :not_authorized
    pana.authorization_subject = @vag_workshop
    assert_equal true, pana.repair!
    assert_equal false, pana.broken?
    assert_empty pana.errors
    assert_equal false, @vag_workshop.authorized_to?(:repair, pana)
    assert_error_on pana, :not_authorized
  end

  test 'Inheritance' do
    skip 'flunk!'
  end

  test 'multiple declarations of the same access should extend authorizations' do
    skip 'flunk!'
  end
  
  test 'multiple declarations with different subject classes should respect these classes while extending authorizations' do
    skip 'flunk!'
  end

  test 'disabling authorization' do
    skip 'flunk!'
  end

end
