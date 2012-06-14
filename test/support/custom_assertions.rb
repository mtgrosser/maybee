module CustomAssertions
  def assert_empty(collection)
    fail "collection expected, got nil" if collection.nil?
    assert collection.empty?
  end
  
  def assert_not_empty(collection)
    fail "collection expected, got nil" if collection.nil?
    assert !collection.empty?
  end
  
  def assert_float_equal(expected, actual, order = 1)
    assert_in_delta expected, actual, Float::EPSILON * 10**order
  end
  
  def assert_valid(record)
    fail "record expected, got nil" if record.nil?
    result = record.valid?
    errors = record.errors
    assert result, "Expected #{record} to be valid, but had errors on #{errors.keys.map(&:to_s).to_sentence}"
  end
  
  def assert_not_valid(record)
    fail "record expected, got nil" if record.nil?
    assert !record.valid?, "Expected #{record} not to be valid, but was"
  end
  
  def assert_error_on(record, attr_name, error = nil)
    fail "record expected, got nil" if record.nil?
    if error
      errors = record.errors
      #error_instances = errors[attr_name.to_s]
      message = "Expected validation error of type '#{error}' on attribute '#{attr_name}'"
      message << " but was on #{errors.keys.map { |k| "'#{k}'" }.to_sentence}" if errors.any? && !errors.keys.include?(attr_name.to_sym)
      message << " but was valid" if errors.empty?
      assert errors.added?(attr_name, error), message
    else
      assert record.errors[attr_name.to_sym], "Expected validation error on attribute '#{attr_name}'"
    end
  end
  
  def assert_no_error_on(record, *attr_names)
    fail "record expected, got nil" if record.nil?
    attr_names = Array(attr_names)
    if attr_names.empty?
      assert record.errors.empty?, "Expected no errors on #{record}, but found #{record.errors.full_messages * ", "}"
    else
      attr_names.each do |attr_name|
        assert record.errors[attr_name.to_sym].empty?, "Validation error on attribute #{attr_name}"
      end
    end
  end
  
  def assert_save(record)
    result = record.save
    return assert(true) if result
    assert_no_error_on record
    fail "could not save record #{record.inspect}, although there were no validation errors"
  end
  
  def assert_attrs(record, attrs)
    fail "record expected, got nil" if record.nil?
    attrs.each do |attr_name, value|
      assert_equal value, record.send(attr_name), attr_name
    end
  end

end
