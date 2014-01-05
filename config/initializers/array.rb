class Array
  def except(*args)
    self - args
  end unless public_method_defined? :except
end
