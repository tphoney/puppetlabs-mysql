# A function that calls the _() function in gettext. This is because _ is protected in the puppet language
Puppet::Functions.create_function(:tstr) do
  dispatch :tstr do
    param 'String', :value
  end
  def tstr(value)
    _(value)
  end
end
